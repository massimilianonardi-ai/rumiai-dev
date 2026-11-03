# TextEdit — current standalone text-engine contract

Status: **Current — TextEdit 0.8.2 document, physical selections, logical policies and deferred materialization implemented**  
Updated: 2026-10-13

## Responsibility and ownership

`TextEdit` is a standalone, GUI-independent JavaScript library distributed
with `m` at `rumiai-os/lib/sys/js/text-edit.lib.js`. Its role is text storage,
oriented multi-range editing, a source-mapped representation, and translation
of advanced selections. The current v0.8.2 library defines no GUI, rendering
backend, font/layout engine, IME adapter, generic event bus or history system.
The base provides only direct committed-mutation notifications. No separate
repository/packaging boundary for this library has been established; the
product source owns the current JavaScript implementation.

The public `TextEdit` library object exposes `VERSION`, `TextEdit`,
`PieceDocument`, `FlatDocument`, `TextEditSelections`,
`TextEditRepresentation` and `TextEditAdvancedSelections`.
The public JS operational manual is `res/sys/manual/text-edit.lib.js`.
JavaScript text positions and payload lengths are UTF-16 code units.
No GUI-specific dependency or mandatory third-party runtime is permitted.
The classic browser script exposes `globalThis.TextEdit` while the CommonJS
export uses `module.exports` without adding a Node global. The runtime
requires standard JavaScript `Intl.Segmenter` support for grapheme handling.

The `TextEdit` facade composes one document, physical selections, one
representation and advanced logical selection operations. Its
`replace(textOrTexts)` delegates one selected action and returns the
selected-edit result plus representation invalidation metadata. Its
idempotent `dispose()` stops using the facade and releases the
representation and its **internally created** selection provider; it never
disposes the shared source document or a caller-injected selection provider.
Using `TextEdit.replace` after disposal is invalid. A caller that injects a
selector owns its lifetime. The advanced selection layer owns no source
subscription and requires no separate disposer.

## TextEditBase contract — implemented in v0.2.0

This section defines the implemented and validated public document-store
contract for both `PieceDocument` and `FlatDocument` in the v0.2.0 product
source. The operational manual and permanent store tests have been aligned.
`TextEditSelections` uses one atomic store commit per multicaret action,
and both selections and representations observe committed edits from
other views through the document's native notifications.

`TextEditBase` remains a structural document interface, not a selectable
editor, not an instantiable class, and not a view, rendering or history engine.
Its public document interface is precisely:

```javascript
length                       // property: source UTF-16 length
revision                     // property: committed mutation counter (safe Number, cyclic)
lineCount                    // property: logical source-line count
slice(start, end)             // source substring
lineStart(line)               // logical line -> start offset
lineAt(offset)                // source offset -> logical line
lineInfo(line)                // {start, end, nextStart}
toString()                    // entire source text
replace(start, end, text)     // one interval
replace([{start, end, text}, ...]) // one atomic multi-interval operation
subscribe(listener)           // unsubscribe function
```

`length`, `lineCount` and `revision` are read-only properties; `slice` and
`toString` return strings. A successful `replace` returns `undefined`,
as the existing primitive implementation does; it does not return change
records, a history entry or a success boolean. Failure is reported through
exceptions, **never** by returning `false`. Invalid argument types raise
`TypeError`; invalid positions, ranges or incompatible edit targets raise
`RangeError`; resource and implementation failures raise appropriate errors.
An exception must not be interpreted as a successful mutation or trigger
committed-edit notifications. `subscribe` requires a function listener and
returns its idempotent unsubscriber. Source text is modified only through
`replace`; direct writing to implementation-internal storage does not form
part of the public document API and must not bypass notifications.

There is one public mutation method, overloaded by argument shape.
`replaceMany`, `chunks`, separate `insert`/`delete` and generic transaction
lifecycle methods are not part of this interface. Repeated bounded `slice`
calls suffice for caller-controlled incremental extraction. `toString()`
explicitly materializes the full text and is unsuitable for huge-document
viewport reads.

All source positions and text lengths use JavaScript UTF-16 code units.
Offsets are zero-based; each input `start`/`end` interval is half-open.
For reads and edits, valid offsets are safe integers satisfying
`0 <= start <= end <= length`, including empty spans and EOF insertion.
`slice` and `replace` operate on exact code units, without grapheme or
display-cell snapping. Replacement text must be a JavaScript string. The
representation and selection layers, not the base, own grapheme/display
policies and oriented selections.

### Source-line semantics

The base holds and exposes the exact source text, without line-ending
configuration, normalization or automatic conversion. Text input and file
output conventions belong to callers outside the base. `length` counts
every actual source UTF-16 code unit, including both units of CRLF, and
equals `toString().length` whenever the full text can be materialized.

Logical source lines are separated by CR (`\r`), LF (`\n`), or an
adjacent CRLF (`\r\n`) pair. CRLF is **one** logical separator occupying
two source UTF-16 units; lone CR and lone LF each occupy one. All three forms
may coexist in one document. The rule applies to the complete current source
text, irrespective of internal piece boundaries or the edit operations that
created or separated an adjacent CRLF pair. An empty document has one empty
line; a trailing separator creates an additional empty last line.
`lineCount` is one plus the number of recognized separators. Line indexes
are zero-based and valid in `[0,lineCount)`.

`lineStart(line)` returns the first offset of that line. `lineAt(offset)`
accepts safe integer source positions `[0,length]`, including EOF, and
returns the logical line at that position. Offsets on any code unit of a
separator (including either unit of CRLF) belong to the preceding line;
the offset immediately after the complete separator belongs to the next
line. `lineInfo(line)` returns exactly `{start,end,nextStart}`:
`start` is the first content position, `end` is the exclusive end of
content without its CR, LF or CRLF terminator, and `nextStart` is the
position after that terminator, or `length` on the last line. For the
last line, `nextStart === length`. All three operations use exact source,
not projected or wrapped, coordinates. Invalid indexes/ranges fail without
mutating state.

### Replace and atomicity

The three-argument form has the same semantics as a single-element array
form, but each form retains its original calling shape for notifications.
The array form requires a nonempty array of records containing
`{start,end,text}` and nothing selection-specific. All ranges refer to
the **same pre-edit document** regardless of array order. The array is not
required to be sorted; sorting for execution must not alter the recorded
public arguments or implied results. Nonempty replaced spans may touch but
not overlap. At most one insertion may occupy a position; insertions strictly
inside a nonempty replaced span are invalid. Insertion at a replacement's
start precedes its replacement text; insertion at its end follows its
replacement text (including when this is a shared boundary of adjacent
replacements). These rules make the final result independent of input order.

Every accepted `replace` invocation is one logical mutation commit:
either its entire requested effect becomes visible at once or the call fails
without publishing any partial edit. This also applies to calls replacing
text by identical text, or inserting the empty string at an empty span;
such successful invocations are still observable commits, avoiding a costly
implicit content-equality check. The empty edit array is invalid.
Validate all ranges, types, collision rules and resulting representable
length before exposing a mutation. An implementation that cannot establish
whether a failed backend write was restored must fail closed; it must never
continue exposing an uncertain document as successfully updated. Backend
algorithms are free to use staging, copying or compensating restoration,
but no intermediate write is observable as a committed document revision.

### Revision and mutation notification

`revision` is a read-only JavaScript `Number` counter initialized to `0`.
Each successful public `replace` call, including committed no-effect calls,
updates it exactly once: increase it by one while it is less than
`Number.MAX_SAFE_INTEGER`; if it already equals that limit, reset it to `0`
on that successful commit. The new value is published after the atomic edit
and before notifying listeners. Failed/rejected edits, reads and listener
registration do not change it. Counter exhaustion must **never** reject an
otherwise valid edit, and there are no timed or discretionary resets.

A consumer that maintains an incremental representation or mirrored copy
must track the revision of the document state it has actually processed.
For every received post-commit notification, if the current
`document.revision` is exactly its last successfully processed revision plus
one, it may apply the notified edit incrementally; otherwise it must discard
its incremental assumptions and rebuild/reload from the document's **current**
source state, then record that current revision. This includes the
`Number.MAX_SAFE_INTEGER` -> `0` transition, which deliberately forces a
reload. A new consumer must first establish a consistent snapshot of the
current document and its revision before relying on incremental updates.
The base supplies no replay log or missed-edit recovery mechanism; a reload
may read source in bounded slices rather than requiring full `toString()`.

Because numbers are eventually reused after a wrap, `revision` is a local
sequence/checkpoint, **not** a permanently unique document-state identity.
Comparing arbitrary old and current values only for equality cannot prove
that no edits occurred across an entire counter cycle; consumers relying on
continuity must validate each received step. This extremely remote aliasing
possibility does not justify failing document edits at the counter limit.

`subscribe(listener)` registers a callback for committed source edits and
returns an idempotent unsubscribe function. The callback receives **only the
exact public `replace` argument values, in their original order and
overload shape**:

```javascript
document.subscribe((...args) => {
    // Replaying onto a separately held copy at the same prior revision:
    mirror.replace(...args);
});
```

For example, `replace(2,4,"X")` calls `listener(2,4,"X")`;
`replace([{start:2,end:4,text:"X"}])` calls
`listener([{start:2,end:4,text:"X"}])` once. No derived deltas,
removed-text payloads, origin identifiers, method descriptors, revision
fields, `details` object or history records accompany the callback.
The listener can read `document.revision` synchronously when needed.

The implementation snapshots array-form argument **values** so mutations
of caller-owned objects or one listener's received values cannot change the
committed command or what subsequent listeners observe. Snapshots are
immutable; notifications preserve argument order and actual string content
rather than retaining mutable caller references. Listeners run synchronously
after the atomic commit and revision update, in registration order; each
sees the complete new document. Subscription changes during notification
affect subsequent commits, not the current delivery snapshot.
Mutations of the same document from within its notification callbacks are
rejected to keep a stable revision for every listener. Listener exceptions
must neither undo a committed mutation, abort delivery to remaining
listeners nor masquerade as a failed `replace`; errors remain diagnosable
through host integration, outside the mutation notification payload.

### Composition boundary and scope

The base owns raw source updates and their atomic publication only.
`TextEditSelections` continues to own selection identity, orientation,
cursor state and target planning, but delegates the final prepared set
of replacements to one `document.replace(edits)` call. Different views
may share the same document with independently owned selections and
representations. Both view-local layers consume each committed mutation
**exactly once** directly from the source subscription. The originating
facade delegates one atomic edit; it never supplies duplicate manual rebases.
No removed-text records or source history are needed to keep a shared view
consistent with the confirmed source commit.

Notifications coordinate copies/consumers that already share the same
ordered source revisions; the base does **not** resolve independent
concurrent edits against divergent copies. Distributed conflict resolution,
OT, CRDT, remote transport, history/undo and replay-log storage are outside
this document-base responsibility.

## Document and selections

The v0.2.0 document stores implement the full `TextEditBase` interface above.
It is a structural contract, **not** an instantiable class. `PieceDocument`
uses a persistent indexed-piece treap with CR/LF/CRLF logical-line metadata
(including piece-boundary pairs); `FlatDocument` is a flat-string reference
baseline. Both preserve exact source UTF-16 units and atomic replacement.
`PieceDocument.stats()` is an implementation-specific, non-mutating diagnostic
returning `{nodes,maxDepth,sources}` for the current indexed-piece tree;
`sources` counts distinct retained source buffers. It is not part of the
shared structural `TextEditBase` interface, and `FlatDocument` need not
implement it.

### TextEditSelections public API and state contract

In TextEdit 0.8.2, \`TextEditSelections\` is the view-local **sole owner**
of effective ordered physical selections, including virtual positions.
It does not own source text, rendering, history or input interpretation.

\`\`\`javascript
new TextEditSelections(document)
getSelections()
setSelections([{start:{row,col},end:{row,col},forward}, ...])
addSelections([{start:{row,col},end:{row,col},forward}, ...])
replace(textOrTexts)
dispose()
\`\`\`

Physical \`row\` indexes source rows, while \`col\` is a zero-based UTF-16
code-unit boundary from the content start of that row, **not** a visual
cell column. Every input \`row\` and \`col\` must be a nonnegative safe
integer. Selection endpoints are ordered \`start <= end\` by row then
column; \`forward\` is boolean, retaining orientation even for carets.
Selections can be overlapping, duplicated or in arbitrary collection
order without automatic merging or sorting.
Numeric flat-offset selection records are invalid; linear UTF-16 offsets
remain solely in `TextEditBase` and internal translation/edit planning. Input and output snapshots
are copied; \`setSelections([])\` clears, \`addSelections([])\` is a
no-op, and both return the selection instance.

Rows beyond \`document.lineCount\` and columns beyond the source row's
content end are valid **virtual physical coordinates**. They require
the shared source document's \`lineCount\`, \`lineAt\` and \`lineInfo\`
operations and carry no obligation to allocate text. Navigating or
setting selections must neither alter source text nor advance revision.
Physical selection coordinates cannot represent the position inside
a CRLF pair; that exact code-unit position remains accessible through
\`TextEditBase\`.

\`replace(textOrTexts)\` accepts a shared scalar or an array assigning
values to selections in their original collection order. Supported scalars
and array entries are strings, numbers, booleans, \`null\` and \`undefined\`.
Numbers and booleans are converted with standard JavaScript \`String(value)\`
(not locale formatting): this includes \`NaN\`, \`Infinity\`, \`-Infinity\`,
\`-0\` becoming \`"0"\`, and boolean \`"true"\`/\`"false"\`.
An empty string, \`null\` or \`undefined\` means an empty replacement, deleting
the selected source content. An array may contain fewer entries than
selections; absent entries (including sparse array holes), \`null\` and
\`undefined\` each mean empty replacement. An empty array therefore deletes
all selected content. Arrays exceeding the number of selections, unsupported
value types (including objects, nested arrays, symbols, functions and bigint),
and an edit without selections are rejected before committing. No per-selection
truncation or warning is owned by this library; an external paste/import adapter
may truncate excess array elements with an appropriate user warning.
All values are validated and normalized before planning source edits. It constructs compatible pre-edit source intervals and
all needed virtual materialization in \`TextEditSelections\`, then calls
\`TextEditBase.replace([...])\` **once** for one materializing editing
action. Virtual EOL columns require space padding; future rows require
line separators, using LF normally but CR after a trailing lone CR
to avoid accidental CRLF fusion. When an inserted CR combines with a
following existing LF, an inserted-text caret is placed after the
resulting CRLF rather than inside its terminator.

Several virtual positions may map to the same old physical EOL/EOF.
The selection layer coalesces compatible payloads at that source
offset, preserving their individual resulting carets. Physically
conflicting edits fail rather than silently dropping user input.
An edit consisting only of deleting nonexistent virtual space does
not materialize or commit anything. A successful actual edit returns
\`{before,after}\`, with independent snapshots and edited selections
collapsed to oriented carets. A forward selection places its caret after the
inserted payload; a reverse selection places its caret at the payload start
(after any required virtual padding). Each retained caret and its orientation
can participate in subsequent edits, regardless of which API constructed it.
Rejected edits do not publish partial changes.

The selector subscribes to committed source edits and tracks source
revision. Ordinary real-source selection boundaries use the established
right insertion affinity for starts and carets and left affinity for
ends. Virtual columns retain their displacement from their original
source EOL anchor as long as its new position can be determined;
future rows follow materialized source-row growth where unambiguous.
Ambiguous anchor changes and revision discontinuities invalidate the
dependent physical state rather than invent a clipped source offset.
Source notifications are consumed exactly once, including edits made
through the same selector.

\`dispose()\` unsubscribes, clears the collection and leaves the shared
document intact. The future history wrapper, GUI, IME and clipboard
distribution are outside this class.

## Document representation and source mapping

\`TextEditRepresentation\` is a GUI-independent, view-local **representation of
one shared source document**, not a second editable copy and not the DOM. It
owns ordered, non-overlapping source-range substitution overlays, source
annotations and the result of the most recent committed rebase. The base
document is the only owner of editable source text.

The representation v0.8.2 public surface is:

\`\`\`javascript
new TextEditRepresentation(document, selections=null)
representation.setReplacements([{start,end,text}, ...])
representation.replace(start,end,text)
representation.remove(start,end)
representation.clear()
representation.setAnnotations([{id,at,text,affinity?}, ...])
representation.replacements  // read-only snapshot property
representation.annotations   // read-only snapshot property
representation.unresolved    // latest committed invalidations, snapshot
representation.length        // projected UTF-16 text length
representation.project(start=0,end=document.length,{maxSourceUnits=65536}={})
representation.sourceToView(sourceOffset)
representation.viewToSource(viewOffset)
representation.setColumnMetrics({tabSize=4,widthOf}={})
representation.columnToSource(row,col)
representation.sourceToColumn(offset)
representation.logicalRowWidth(row)
representation.rowCount
representation.getSelections()  // requires bound physical selections
representation.setSelections(logicalSelections)
representation.addSelections(logicalSelections)
representation.dispose()
\`\`\`

The optional second constructor argument binds the representation to
\`TextEditSelections\` for logical selection get/set/add operations. These
operations convert logical grapheme/tab-based \`{row,col}\` positions to
physical source \`{row,col}\` positions and back. \`logicalRowWidth(row)\`
returns current source row width in logical display cells, or zero for a
future row. This translation is **policy-neutral**: clipping and virtual
retention are owned by \`TextEditAdvancedSelections\`, not the
representation. No representation method constructs padding or modifies
source text.

The constructor requires a \`TextEditBase\` with source line access, a cyclic
\`revision\` counter and \`subscribe\`. It automatically subscribes once; two
representations of the same document are independent and have their own
overlays and metadata. Public snapshots are independent copies. Annotations
have unique, nonempty string \`id\`, string \`text\`, source \`at\` in
\`[0,document.length]\`, and optional \`affinity\` exactly \`before\` or
\`after\`; additional metadata keys are preserved as data. Annotations are
returned ordered by source offset and then ID. Invalid replacements,
annotations, duplicate IDs or overlapping overlay spans are rejected without
partial publication of representation state. An annotation-input getter that
causes a committed source change cannot publish coordinates from the old
revision. \`setReplacements\`, \`setAnnotations\`, \`remove\` and \`clear\`
modify only the representation and never the underlying document or its
revision.

A substitution \`[start,end)\` requires \`start<end\` and source UTF-16
grapheme boundaries. Its \`text\` is an arbitrary JavaScript string, including
empty, Unicode, and newlines; overlay text does not imply a document edit.
\`replace(start,end,text)\` adds or updates an exact existing source range;
it does not silently merge overlapping ranges. \`remove\` removes only an
exact range; \`clear\` removes all substitution overlays, not annotations.

\`project(start,end,{maxSourceUnits})\` takes a SOURCE interval; it may not
cut an existing substitution or a Unicode grapheme. It returns
\`{source,segments,annotations,readUnits}\`. Each ordinary text segment
includes its exact source range, text and UTF-16 grapheme boundaries; a
substitution segment contains its source range and virtual text. Annotation
metadata is separate from text and does not contribute to projected length.
\`readUnits\` counts source text units projected, and \`maxSourceUnits\` caps
them; callers can request small windows instead of complete content.
Common ASCII boundaries can be checked from adjacent source units without
materializing large source lines. Overlay geometry is indexed by cumulative
UTF-16 displacement so source/view coordinate conversions do not scan all
preceding overlays on every lookup. Source projection likewise seeks the
requested window rather than scanning all preceding substitutions and
annotations. For general Unicode grapheme boundaries,
validation may require more source context; no false editable boundary is
fabricated. \`sourceToView\` and \`viewToSource\` return \`{kind:'offset',offset}\`
only when the mapping is unique; otherwise they describe the full
\`{kind:'replaced-region',source:{start,end},view:{start,end}}\`. A
zero-length virtual substitution remains explicitly ambiguous in
\`viewToSource\`.

### Logical source-row column geometry

`TextEditRepresentation` also owns source grapheme segmentation, logical display-cell
widths and tab-stop expansion, not `TextEditAdvancedSelections`. The optional
`setColumnMetrics({tabSize=4,widthOf}={})` sets a positive safe-integer tab
stop and a `widthOf(grapheme,column,row)` callback for non-tab graphemes;
omitting `widthOf` uses one logical cell per grapheme. Tabs advance to the
next tab stop regardless of `widthOf`. Each callback result must be a
positive safe integer. Metrics belong to a representation instance, not to
each advanced-selection action. Host pixel measurements may inform the
callback but no font or DOM dependency enters this library.

`columnToSource(row,col)` accepts zero-based logical SOURCE rows and zero-based
cell-boundary columns; it returns `{kind:'offset',offset}` for an exact
grapheme boundary, `{kind:'inside-grapheme',cell,before,after}` inside
a tab or other multi-cell grapheme, and `{kind:'virtual',offset,virtualSpaces}`
for a column beyond the row's content. The virtual result retains the
requested displacement beyond the original EOL and is **not** silently
converted into a physical caret at the EOL. `sourceToColumn(offset)`
returns `{kind:'column',row,col}` at a grapheme boundary, or an
`inside-grapheme` result when the source offset splits a grapheme.
The source offset at a line's content end is a valid column boundary,
while an offset strictly inside its CRLF line terminator is not.
Logical line contents are determined by `TextEditBase.lineInfo()` for
all CR, LF and CRLF forms; neither line-ending units nor overlays are
interpreted as source-line cells. These functions operate on **logical
source rows**; folding, viewport wrapping, bidi, pixel hit-testing and
post-overlay visual-row layout are distinct higher-layer policies.
Column traversal uses bounded source reads; it need not materialize
a multi-megabyte ASCII line to resolve an early column.

### Automatic source synchronization and invalidation

\`TextEditRepresentation\` consumes **exactly one** synchronous committed
notification per source edit from \`TextEditBase\`; an explicit
\`representation.rebase(changes)\` is no longer a public API. On each
notification it checks that the current document revision equals the last
successfully processed revision plus one, then interprets the original
\`replace(start,end,text)\` or \`replace([{start,end,text},...])\` argument
shape in old source coordinates. No removed-text payload, extra listener
argument, history or source-text copy is required. Even an edit preserving
length and line count must be processed; successful no-effect edits also
advance the revision checkpoint.

Every surviving substitution whose source interval lies strictly outside
edited regions is moved by the total old-coordinate batch displacement.
Insertions strictly inside an overlay invalidate that overlay; insertions
at its start/end are excluded from the overlay (the start moves after the
insertion, the end stays before it). Nonempty source replacements intersecting
an overlay invalidate it; merely touching an endpoint is not an overlap.
A surviving overlay whose new boundary is no longer a valid grapheme boundary
is invalidated rather than silently snapped.

Annotation anchors outside replaced source ranges shift with edits. If a
nonempty replacement consumes an anchor at \`start <= at < end\`, that
annotation is invalidated. At a pure insertion at the anchor's position,
explicit \`before\` or \`after\` affinity positions the annotation on the
corresponding side; without affinity the anchor is invalidated as ambiguous.
For a batch containing an insertion and a replacement at the same position,
the original anchor at that replaced position is invalid regardless of its
insertion affinity. These rules apply to the complete old-coordinate batch;
they are not separate replays or dependent on the input array order.

Invalidated elements are removed from the active representation and appear
in the read-only \`unresolved\` snapshot for the **most recent source
notification**, with a source region or annotation ID and a reason. The next
successful notification replaces that snapshot (including with \`[]\`).
The source document is never rolled back because a view cannot rebase.

A revision gap, including \`Number.MAX_SAFE_INTEGER\` wrapping to zero,
or failure to process a committed notification reliably invalidates all
current overlays and annotations. The representation clears its dependent
state, records their invalidation reasons in \`unresolved\`, and adopts the
current source revision and length. This is a conservative rebuild of the
empty representation: recovering the meaning of an old overlay or annotation
without edit history is not possible. New caller-supplied metadata can
subsequently establish new state. Outside notification delivery, an observed
revision mismatch rejects potentially stale reads or writes rather than
silently presenting an obsolete mapping.

\`dispose()\` is idempotent, unsubscribes and clears view-owned state;
subsequent public operations other than \`dispose()\` reject use. The shared
source document is not disposed. No representation-specific event bus,
automatic repaint, history, clipboard or GUI policy is introduced.

\`TextEdit\` composes the document, \`TextEditSelections\`, representation,
and advanced selection interpreter. Its \`replace(textOrTexts)\` delegates
the atomic edit **once** to \`TextEditSelections\`; both local and external
representations update through their own document subscriptions. It returns
\`{before,after,representation:{unresolved}}\`, where \`unresolved\` is the
representation's most recent committed invalidation snapshot. The prior
higher-layer old-text \`changes\` adapter and explicit representation
\`rebase\` have been removed.

## Advanced logical selection architecture — implemented in v0.8.2

The implemented v0.8.2 architecture separates logical selection construction,
policy-neutral coordinate translation and physical editing. Exactly one
`TextEditSelections` instance owns the effective ordered selection
collection, including nonmaterialized coordinates. Only physical row/UTF-16-column coordinates are valid public selection records; linear source offsets remain exclusively in `TextEditBase`.

### Responsibilities and coordinate systems

`TextEditAdvancedSelections` constructs selections exclusively from logical
text-grid `{row,col}` coordinates and **owns all selection-shape policies**,
including virtual-retaining versus clipped selection behavior. These policies
operate on complete **logical** coordinates before any physical conversion.
Its elementary logical-selection operations are reused by
`lineSelection(start,end)` and `rectangularSelection(start,end)`, which
accept the same endpoint shape.
A line selection always constructs one forward-oriented range covering
complete included source rows, including existing line terminators, regardless
of requested endpoint order. A rectangular selection constructs an ordered
array of ordinary selections covering the included text-grid cells on each row:
the requested vertical traversal controls array order, and horizontal direction
controls each range's `forward`. Higher-level endpoints are inclusive.
Neither constructor persists a special selection kind or input mode.
The advanced layer performs no source-coordinate translation, grapheme/tab
measurement or source edits.

`TextEditRepresentation` is the **policy-neutral coordinate
translator** for these logical operations. It measures the logical content
width of a source row (including grapheme and tab metrics), and translates
source-row and display-cell logical coordinates into physical `{row,col}`
coordinates and back. It does not decide selection shape or choose clipping
versus virtual retention. A logical column
does not necessarily equal a physical column. The representation exposes
logical selection-management operations analogous to those of
`TextEditSelections` and forwards the resulting physical selections to
that component. It must not independently materialize source padding,
newlines or rows, nor become a competing owner of the effective selection
collection. Representation-specific projection metadata may remain
view-local without duplicating authoritative physical selection state.

The ordered collection of oriented selections is the only editable selection
state; creation history, rectangle membership and line-selection kinds are not
persisted or consulted for editing. Input adapters may apply configurable text
transformations independently to each selected payload according to `forward`.
The advanced layer's `virtual` and `clipped` options are construction-geometry
policies, not replacement/input policies.

`TextEditSelections` is the **sole owner of effective physical selections**
and caret state. Its physical selection coordinates are
`{row,col}`, where `row` denotes a source row and `col` denotes a
UTF-16 code-unit boundary relative to that row's content start. These are
**physical row/column coordinates**, not rendered pixels or display-cell
columns. They may refer to a column past source EOL or a row beyond source
EOF: such positions are *virtual physical positions*, not invalid source
offsets or materialized characters. Selection ranges remain ordered,
oriented and may include multiple independent carets. Internal flat
UTF-16 anchors are permitted where needed for exact source-edit/rebase
semantics and performance; a flat offset alone cannot encode a virtual
row or column.

`TextEditBase` remains the exact text owner and accepts only existing
linear UTF-16 source offsets for its unchanged atomic `replace`
operations. Its existing `lineCount`, `lineStart`, `lineAt` and
`lineInfo(row) -> {start,end,nextStart}` provide source-row geometry.
Here `end` is the content boundary immediately *before* the actual
CR/LF/CRLF terminator, and `nextStart` follows that terminator.
The ordinary physical `{row,col}` selection interface does not expose
a caret **inside** a CRLF pair. Exact arbitrary code-unit access, including
the CRLF interior, remains available through `TextEditBase`; physical selection endpoints cannot refer to this interior position.

### Virtual and clipped selection policies

`TextEditAdvancedSelections` must support both **virtual-retaining**
selection semantics (keep the entire requested logical geometry beyond
source EOL and EOF) and **clipped** selection semantics (take the
geometrical intersection with existing logical text-grid content).
It obtains the row's actual logical width from
`TextEditRepresentation` rather than measuring graphemes or tab stops
itself. Clipping occurs **before** translation to physical coordinates,
not by clamping source offsets; an entirely out-of-source selection does
not silently become a caret at EOF. Both policies feed complete,
policy-resolved logical selections through the same neutral representation
conversion into `TextEditSelections`.

Constructing or moving a selection, including one beyond EOL/EOF, must not
modify source text, insert padding or increment `TextEditBase.revision`.
An effective virtual physical selection is retained by
`TextEditSelections` until an edit, external change or explicit selection
operation affects it. The advanced layer chooses the logical geometry; the representation
translates it without introducing another policy or independently
holding authoritative virtual physical selection state.

### Deferred physical materialization

`TextEditSelections` owns the **single materialization mechanism** for
edits through its selections. On an editing action it determines the
necessary physical padding and missing source lines from the physical
selection coordinates and existing `TextEditBase` row information;
`TextEditRepresentation` neither constructs that padding nor executes
source commits. Materialization occurs only when the chosen edit semantics
require it; in particular, selection navigation never writes to the source
and deleting empty virtual space does not create it merely to delete it.

All effects of **one** user editing action, including multiple carets,
padding, new rows and inserted/replaced text, must be prepared against one
source revision and sent as **one atomic** `TextEditBase.replace` commit.
Several distinct virtual positions can collapse to the *same* original
EOL/EOF source offset; `TextEditSelections` must coalesce their compatible
physical insertions into a single valid source edit at that offset rather
than submit duplicate insertions forbidden by the base contract. True
conflicts at the same requested physical cell must not be resolved by
silently dropping one input. No separate physical editing path may bypass
the selection layer for a normal selection-initiated edit.

Committed external source edits must continue to rebase or safely
invalidate selections while preserving orientation, collection order
and meaningful anchors. A virtual-row/column selection cannot count
unchanged numeric `row,col` as evidence that its source-relative anchor
has been correctly rebased after another view edits the text.

### Remaining scope

The physical `{row,col}` selector, neutral representation gateway,
advanced logical selection policies and deferred materialization are
implemented in v0.8.2. The v0.8.2 operational manual and permanent tests
validate source rows, physical virtual coordinates, CRLF-safe padding,
multicaret insertion grouping, logical clipping, Unicode/tab conversion,
and rejection of numeric offset selection records. Comprehensive distribution
of multiline clipboard, Excel and CSV payloads over different source and
target geometries, full native MadEdit-Mod interaction parity and GUI/IME
remain separate future editor work.

History remains the separate transparent wrapper around
`TextEditSelections` and must record one complete user action per
undo/redo entry, including the corresponding selection state. GUI, IME,
pixel hit-testing, bidi, wrapped visual rows and clipboard-distribution
policies remain outside this library revision.

## Separate new `m` core: abstract `Selections` interface

The separately compiled JavaScript `m.text.selection` namespace exports
`Selections` as an abstract base for mode-dependent selection interpreters.
This is **not** part of the unchanged standalone TextEdit 0.8.2 library,
which continues to expose its own `TextEditSelections` API.

The nominal `Selections` interface defines exactly four abstract methods:

```javascript
getSelections()
setSelections(selections)
addSelection(position)
remSelection(position)
```

Direct `new Selections()` construction throws `TypeError`.
An inherited method not overridden by a concrete subclass throws `Error`.
Concrete implementations determine how an operation maps to effective
selections: `addSelection` and `remSelection` do not require literal
single-element append/removal and may reorganize the whole collection.
The interface itself has no selections storage, geometry policy,
`selectionMode`, source editing, GUI handling, clipboard handling or
lifecycle method.

The existing new-core `TextEditSelections` remains an independent physical
selection/editing class, **not** a subclass of `Selections`: its current
`addSelections` API is not the `addSelection` interpreter contract and it
does not provide `remSelection`.

### Concrete selection modes in the separately compiled core

The same `m.text.selection` namespace also exports these `Selections`
subclasses:

```javascript
new LineSelections(owner)
new RectangleSelections(owner)
new FreeFormSelections(owner)
```

`owner` supplies `getSelections()` and `setSelections(selections)` and is
the **single owner of effective selections** shared by all mode instances.
These mode interpreters do not store or modify document text and do not
create alternative authoritative selection collections. Each exposes the
four `Selections` operations in the caller's own `{row,col}` space.
A selection record is `{start:{row,col},end:{row,col},forward}`, with
ordered half-open endpoints; cursors have equal endpoints. Record order,
orientation and mixed-mode ranges/cursors are preserved when passed through
`setSelections` and returned by `getSelections`.

`LineSelections` produces an oriented linear range between the first and
most recent submitted cells, including those endpoint cells.
`RectangleSelections` produces one ordinary range for each included row,
from the first to the last row in gesture order and with horizontal
orientation preserved. `FreeFormSelections` produces distinct zero-length
cursors at visited positions in visitation order. In all modes,
`addSelection` and `remSelection` can recompute the effective collection.
Another mode may add to the existing selection set without erasing the
previous mode's results: rectangle followed by free-form yields a rectangle
plus additional cursors.

The exact interaction lifecycle, later `Document2D` mode registry and
editing/representation composition are **not** implemented here. The
separate standalone TextEdit 0.8.2 specification and engine remain unchanged.

## Separate new `m` core: abstract `Document2D` interface

The new `m.text.document.Document2D` is a **separate nominal abstract
interface**, not a subclass of `Document`. It describes text and editing
in the particular two-dimensional coordinate space exposed to a consumer,
regardless of whether the backing content is physical text, a logical
representation, virtual content or the output of another representation.
The GUI must not need to distinguish the provenance or internal coordinate
encoding to invoke the same `Document2D` API.

The exported abstract class defines these members:

```javascript
get rowCount()
get colCount()
get revision()
getRowWidth(row)
getRegions(rowStart, colStart, rowEnd, colEnd)
getRect(rowStart, colStart, rowEnd, colEnd)
read()
getSelections()
setSelections(selections)
addSelection(position)
remSelection(position)
get selectionMode()
set selectionMode(mode)
get insertMode()
set insertMode(mode)
insert(content)
replace(edits, expectedRevision)
subscribe(listener)
destroy()
```

`rowCount` describes the exposed document's rows. `colCount` describes
its maximum text column; neither property reveals source storage geometry.
`getRect` reads a **bounded 2D window** for display, including a bounded
column range; `getRowWidth(row)` reports occupied columns for a
single exposed row (zero for future rows). `getRegions` reads a bounded
half-open 2D window in the same coordinate space, returning one array
per existing requested row. Each region is a detached
`{kind,text,start:{row,col},end:{row,col}}` record, with an optional
stable `id` for an additive annotation. Ordinary content regions have
positive extent. A protected occupied `kind:'substitution'` region
replaces a positive input interval in the exposed geometry but carries
source-less display text; an additive `kind:'annotation'` is a **zero-width,
source-less overlay** with identical start/end coordinates, independently
coexisting with any content region at the same column. A zero-width
annotation is included only when its anchor is in the requested
half-open column window, including on an empty row. Positive-width
indivisible regions intersecting a window are returned whole even when
their boundaries extend beyond the requested columns. Overlays do not
consume columns, change `getRect` or take part in `read()`. Region
kinds are presentation data, not edit policies. Internal input/source mappings remain private
to the implementing document; GUI consumers do not need to know its
provenance. A displayed grapheme may have a JavaScript string length
different from its occupied display-cell width.
`read()` separately reads the *current selections* for transfer
to external consumers. Coordinate interpretation, selected text production,
selection-mode policies and input-mode parsing belong to concrete
implementations. `addSelection` and `remSelection` may reorganize the entire
effective selection set according to the selected interpretation mode.
`insert(content)` receives content for selected editing without requiring
the interface to know where the content originated; system clipboard
transport and GUI pointer/key events are external responsibilities.
`subscribe(listener)` observes document changes; `destroy()` is the
lifetime endpoint of an implementing view.

`revision` identifies the observable 2D coordinate space, not merely the
underlying physical text revision. A representation that changes its exposed
geometry independently of its backing document must invalidate previously
captured coordinate revisions. The GUI still does not know the backing
source or the mapping between representation layers.

`replace(edits, expectedRevision)` is an atomic explicit-edit operation:
`edits` is a nonempty array of
`{start:{row,col},end:{row,col},text}` records in the exposed 2D
coordinates, all referring to the same pre-edit revision. The captured
`expectedRevision` argument is mandatory; stale coordinates must be
rejected without a partial commit. Explicit edits are independent of the
selection-driven `insert(content)`. Implementations must translate and
validate the entire batch before one atomic backing commit. Ambiguous or
unsupported edits must be rejected instead of silently clipped, redirected
or partly applied.

### Composition and coordinate correspondence invariants

Every transformed `Document2D` defines a distinct exposed coordinate space
and translates its accepted operations into the coordinate space of its
**immediate** input `Document2D`. A chain of transformations does not
bypass intermediate layers or expose a backing document directly to the
GUI. A layer must distinguish the visible region geometry returned by
`getRegions` from the **private** correspondence needed to interpret
selections and edits. The display stream is not a provenance or
edit-authorization API: neither a region kind nor the presence of an
annotation label proves that a region is editable.

Correspondence need not be bijective. A grapheme may combine multiple
input UTF-16 code units into one exposed cell, while a TAB may expand
one input code unit into multiple display cells. An inline fold can
concatenate pieces from different source rows into one visible row;
a protected fold marker has no source text, while an occupied
substitution can replace an arbitrary positive same-row source interval
with synthetic cells. A derived substitution may concatenate disjoint input fragments, while a source fragment can appear in multiple protected display regions without creating extra editable destinations. A zero-width annotation adds visible metadata
without occupying or owning text. The two exposed boundaries
of a protected inline marker can refer to **different** input positions.
They must not be merged into a single source point merely because
the displayed marker is one indivisible cell. An input point hidden by
a fold has no valid exposed counterpart.

The shared internal `_replaceMapped` delegation is the already
demonstrated common responsibility across `CellDocument2D`,
`FoldDocument2D` and `AnnotationDocument2D`. The coordinate
mapping itself remains local to each view: a shared commit protocol
does not imply a reusable arbitrary-region transformation or a
second selection owner.

An accepted selection endpoint must have an unambiguous translation
through **every** layer. A selected interval may not implicitly include
input content that is hidden by any layer, even when its endpoints are
individually representable. The same requirement applies to explicit
edit intervals. A request whose translation is ambiguous, crosses a
protected source-less region, or would secretly modify omitted input
content must be rejected without a partial operation. Valid multiple
targets remain a *single* `replace(edits, expectedRevision)` batch
through the layers and ultimately one atomic physical commit.
`getSelections` and `read()` must not silently relabel hidden source
content as visible text.

A local display configuration change advances the coordinate revision
of its layer; downstream composition observes the change and
invalidates its own captured geometry. Until a correct old/new geometry
mapping exists, whole-view invalidation and conservative clearing of
row-indexed source anchors are preferable to retaining stale
relationships. The existing `getRegions` and `getRect` viewport
contract remains bounded: a fold is not allowed to force a full
materialization of omitted source rows.

These are invariants of currently supported compositions, not a claim
that arbitrary region graphs, occupied source-less edits, a
public `Representation` abstraction, or persistent source-anchored
rebasing are implemented.

Direct construction throws `TypeError('Document2D is abstract')`; inherited
abstract members throw `Error` until implemented by a subclass. The class
contains no storage, registrations, selection owner, rendering
algorithm or concrete editing policy. It supplies an **internal**
`_replaceMapped(input,edits,expectedRevision,translate)` helper shared
by composed 2D views. This method is not a GUI-facing public API:
the implementing view supplies its own private translation of each
edit and its policy for rejecting hidden, partial or ambiguous
intervals. The helper snapshots each edit record's fields once,
checks the exposed and immediate-input revisions before and after
translation, then delegates the complete batch to exactly one
`input.replace`. It cannot implement a region correspondence
without the concrete view's mapping rules.

`Document`, `FlatDocument`, `PieceDocument`, `Selections` and
`TextEditSelections` retain their existing contracts.
Concrete consumers now have `RawDocument2D` described below.
Logical/document-representation adapters, general pluggable mode registries,
and richer projected content formats are not supplied by the raw adapter.

### `RawDocument2D`: physical 2D adapter over `Document`

`new RawDocument2D(document)` requires a nominal `Document` and implements
the complete `Document2D` public surface. Both `FlatDocument` and
`PieceDocument` are supported. It is the GUI-facing entry point for an
untransformed source: a caller does **not** separately instantiate or call
`TextEditSelections`. It retains exactly one private `TextEditSelections`
instance to reuse the existing proven source-relative selection anchors,
external-edit rebasing, virtual-position materialization and one-commit
multi-selection replacement. The source document belongs to its caller:
`destroy()` releases the adapter and its subscriptions but not the document.
The standalone TextEdit 0.8.2 library remains unchanged.

A raw coordinate `{row,col}` means source line and UTF-16 code-unit column.
The adapter's exposed 2D space deliberately has **no** grapheme width,
tab-expanded display cells, folding or logical substitutions. The GUI can
depend on the `Document2D` interface, not on this coordinate interpretation;
other implementations may expose different internally constructed spaces.

`rowCount` is `document.lineCount`; `colCount` is the greatest raw line
content length (UTF-16 code units, terminators excluded).
`getRowWidth(row)` returns that row's raw UTF-16 content width, or
zero for a future row. `getRegions` produces at most one ordinary
`kind:'text'` segment per requested existing row, clipped to the
requested UTF-16 columns. Such a raw range can divide a Unicode
grapheme; the untransformed raw view intentionally exposes code units.
The maximum-column result is revision-cached but may require a scan of
all source rows when invalidated.
`getRect(rowStart, colStart, rowEnd, colEnd)` accepts nonnegative safe-integer
**half-open** row/column boundaries and returns an array of raw text strings,
one per existing source row in the requested window. Reads clip to existing
rows and EOL, exclude terminators and never allocate virtual padding or
materialize full long rows just to return the requested columns.
`read()` returns an ordered array of strings, one for each current selection.
It preserves actual source terminators when a range crosses rows and clips
nonmaterialized virtual portions; cursors contribute empty strings.

The built-in `selectionMode` values are `line` (initial), `rectangle`,
and `free-form`. They delegate the four selection-management operations
to the corresponding `Selections` strategy sharing the **same** private
physical selection owner. Changing mode leaves previously effective ranges
and carets in place: drawing a rectangle then switching to free-form retains
the rectangle while subsequent points add free-form cursors.

`insert(content)` replaces the selected ranges and commits through the
physical selector. `insertMode` values are `raw` (initial, one value
repeated across selections), `lines` (split CR/LF/CRLF into values),
`csv` and `tsv` (parse delimiter-separated cells including quoted
fields and doubled quote escapes). A supplied array always means explicit
values ordered by selections, independent of the current insertion mode.
More values than selected targets fail without a source commit; missing
values follow the existing physical selector's empty/deletion semantics.
Every successful real edit goes through one atomic `Document.replace`.

`RawDocument2D.revision` equals the underlying `Document.revision`.
`RawDocument2D.replace(edits, expectedRevision)` checks that revision
before and after preparing physical offsets. Explicit positions must be
within existing rows and at or before the actual end of line; unlike
`insert(content)`, this API does not materialize virtual columns or rows.
Zero-length ranges insert text; ranges may span rows. The underlying
`Document.replace` validates collision/order semantics and executes the
entire converted array as one atomic commit. Existing physical selections
continue to rebase from the committed document notification.

`subscribe(listener)` returns an unsubscribe callback. Notifications
carry `{type,revision}`, where `type` is `content`, `selections`,
`selectionMode` or `insertMode`.
Content notifications follow the physical selector's source-rebase
notification and retain `invalidation:{all:true}`, which conservatively
invalidates the entire exposed 2D geometry. For current core
`FlatDocument` and `PieceDocument` inputs, an additional immutable
`geometry` record describes the exact pre-/post-commit source boundaries:

```javascript
{
  type:'content', revision,
  invalidation:{all:true},
  geometry:{
    previousRevision, revision, oldRowCount, newRowCount,
    edits:[
      {
        old:{start:{row,col,offset},end:{row,col,offset}},
        new:{start:{row,col,offset},end:{row,col,offset}}
      }
    ]
  }
}
```

One geometry record is published per successful physical commit, including
successful no-effect edits. Its `edits` follow the **caller's original
argument order**, not the order in which physical replacements were staged.
`old` endpoints identify the replaced source span in the old document;
`new` endpoints identify the inserted-text span after all edits have
committed, including earlier disjoint edit shifts and same-boundary insertion
ordering. Every `offset` is an exact UTF-16 boundary in the corresponding
source revision. `row` comes from `Document.lineAt(offset)`, and
`col=offset-Document.lineInfo(row).start`; a position inside CRLF can have
a column beyond the editable row width. These are **source mutation
coordinates**, not automatically valid GUI selection or edit points.

The old geometry is captured *before* staging a physical commit; the new
geometry is resolved after the committed source is installed and before
the source listeners run. The payload and its nested arrays and points are
frozen, not modifiable references into document state. The stable
`Document.subscribe` contract remains unchanged: its listener still
receives **only** the exact original `replace` arguments. Geometry uses
an implementation-private coordination channel between the core
`_DocumentStore` and `RawDocument2D`, not an extra source notification
argument or public `Document` method.

When an input `Document` lacks this internal support or geometry cannot
be established after a committed edit, the raw content event omits
`geometry` while still publishing conservative whole-view invalidation;
the physical commit is never reported as failed because metadata could
not be derived. Revision wrap from `Number.MAX_SAFE_INTEGER` to `0`
retains the established loss-of-continuity semantics.

The raw adapter continues publishing whole-view invalidation. A directly
composed `CellDocument2D` can now project supported raw pre/post edit
endpoints through an internal pre-commit observation. No fine-grained
viewport invalidation, replay log, downstream fold/annotation/substitution
geometry or persistent source-anchor rebasing is supplied.
Clipboard transport, GUI device events and pixel hit-testing do not belong to
the adapter.



### `CellDocument2D`: row-preserving grapheme and TAB projection

`new CellDocument2D(input, tabSize=4)` requires an existing nominal
`Document2D` and a positive safe-integer tab size. It implements the
complete `Document2D` API in a transformed cell space: one ordinary
Unicode grapheme occupies one column, and a TAB advances to the next
tab stop. The input may itself be a transformed `Document2D`;
`Intl.Segmenter` is required. The adapter has no DOM, font or
pixel dependency. Configurable widths of other graphemes are not
implemented yet.

The bounded `getRegions` call returns whole grapheme and TAB
regions in the exposed coordinates. A `kind:'tab'` retains
`text:'\\t'` in the region record, while `getRect` expands only
the TAB cells intersecting the requested window into spaces.
A grapheme may contain multiple UTF-16 units but occupy one cell.
Non-text input regions, and regions whose cell extent differs from
their UTF-16 text length, retain their existing extent; ordinary
one-to-one text regions are segmented into graphemes. Additive
zero-width `kind:'annotation'` regions preserve their `id`, `text`
and anchor when mapped into cell coordinates. They contribute no width
and are excluded from `getRect`. An annotation anchored strictly
inside a grapheme, TAB or other indivisible element cannot be mapped
unambiguously and must be rejected rather than inventing an edit or
selection boundary. Public region records are detached values and
cannot alter the view's mapping.

The scanner requests at most 2048 input columns per read chunk and
retains a trailing grapheme across boundaries. A bounded window near
the beginning of a long row need not materialize the entire row.
Computing complete row widths and `colCount` can scan complete
rows or the whole document; no general indexed layout or huge-file
performance claim is made.

`CellDocument2D` does **not** own a second effective selection set.
Its local `Selections` mode interpreters operate in displayed cell
coordinates and forward complete effective ranges to the input's
existing selection owner. Selected text `read()` and selected
`insert(content)` continue using the input's behavior.
A source position strictly inside a grapheme and a view position
strictly inside a multi-cell TAB are not exact selectable/editable
boundaries: they are rejected rather than snapped. Virtual
columns retain their displacement beyond the actual EOL.
The user-facing policy for partial-TAB selections remains open.

`replace(edits, expectedRevision)` translates all requested cell
endpoints to input coordinates, verifies revision consistency, then
forwards one batch through `input.replace`. No rejected batch can
partially mutate the input. This view's own numeric revision
increments whenever the input coordinate revision changes; it
publishes conservative whole-space geometric invalidation then.
Selection/mode events do not advance the view-coordinate revision.
`destroy()` unsubscribes this view but does not destroy its input.

This concrete class is deliberately limited to grapheme/TAB
geometry.

A cell view directly over `RawDocument2D`, backed by the current
`_DocumentStore`, observes the physical edit through an internal
pre-commit hook while the old source still exists. After that edit
commits, it projects the new endpoints from the new source geometry.
Only when every endpoint is exactly representable does its `content`
event include immutable `geometry` in the cell view's coordinates:

```javascript
{
  previousRevision, revision, oldRowCount, newRowCount,
  edits:[
    {
      old:{start:{row,col},end:{row,col}},
      new:{start:{row,col},end:{row,col}}
    }
  ]
}
```

Edits retain the original physical batch order; cell points contain no
underlying source offsets. The source `Document.subscribe` contract is
unchanged; this hook is internal and is not a public `Document2D` method.

Even when `geometry` is available, `invalidation:{all:true}` remains:
TAB stops and neighboring graphemes can change outside the inserted
span. If any endpoint is inside a grapheme, source terminator or other
nonrepresentable boundary, or if the pre-commit observation, matching
post-commit raw geometry or revision continuity is absent, the cell
event omits `geometry` and still reports whole-view invalidation.
This fallback never turns a completed physical edit into an error.
Revision wrap also disables precise projection for that commit.

The precise projection is limited to direct raw-to-cell composition.
Nested cell, fold, annotation and substitution compositions still
invalidate conservatively. This geometry does not yet prove safe
persistent rebasing of fold, annotation or substitution anchors.
Neither `BaseDocument2D` nor a public `Representation` interface is
introduced by this implementation.


### `FoldDocument2D`: protected whole-row and cross-row inline folding

`new FoldDocument2D(input)` requires an existing nominal
`Document2D`, including `RawDocument2D` or `CellDocument2D`.
It implements the full `Document2D` interface. Each configured
half-open interval of complete input rows is represented by one
synthetic output row; source content and terminators are unchanged.

`setFolds([{startRow,endRow}, ...])` accepts arbitrarily ordered,
nonoverlapping intervals in **input-row coordinates**, with
`0 <= startRow < endRow <= input.rowCount`. Invalid batches cause
no state change. The `folds` property returns detached
`{startRow,endRow}` snapshots. Repeating an identical normalized
configuration is a no-op; actual configuration changes advance the
view's coordinate revision and publish
`{type:'content',revision,invalidation:{all:true}}`.

Each synthetic row has width one, reads as `…` in `getRect`,
and exposes an indivisible `{kind:'fold',text:'…'}` region in
`getRegions`, with exposed half-open columns `[0,1)`.
Unfolded output rows retain the content, column geometry and region
kinds of their input rows, remapped to exposed row coordinates.
All returned region and configuration objects are detached from
internal mappings. An input annotation overlay from a visible row
retains its `id` and zero-width anchor after translating the row;
overlays in hidden rows are not returned. Bounded reads do not
materialize hidden input rows. Exact `colCount` may scan all visible rows and is not a
general indexed huge-document layout promise.

The synthetic fold row has **no editable input coordinate**.
Both selection and explicit batch editing reject endpoints on a
fold marker and intervals that would traverse any hidden source
rows. `getSelections`, `read` and `insert(content)` likewise
reject input-owned selections with hidden endpoints or spans
crossing hidden rows; they may not silently copy or edit hidden
text. Other valid selections are translated into the existing
single effective selection collection owned by the input
`Document2D`; no second selection owner is created. Local
`LineSelections`, `RectangleSelections` and `FreeFormSelections`
strategies interpret gestures in the folded view. Explicit
`replace(edits, expectedRevision)` validates and translates
the entire batch, then invokes `input.replace` exactly once;
the input retains atomicity and its own validation rules.

Folds are indexed by input row numbers, not persistent source
anchors. Although the raw document may now publish exact old/new physical
source-edit endpoints, transforming those changes through arbitrary
intermediate representations and safely rebasing fold anchors is **not**
implemented. Therefore **every input coordinate-revision change clears all folds**,
increments the folded view revision and emits a conservative
whole-view geometric invalidation. This includes successful
edits made through the folded view. Callers must not reuse
previous folded coordinates after this change. Destroying a
folded view unsubscribes its listeners but never destroys
its input document.

The same class also supports **one cross-row inline fold** through
`setInlineFold({start:{row,col},end:{row,col}})`, with both endpoints
in the input `Document2D` coordinate space. The first point must
belong to an earlier existing input row, and both columns must be
at/before their real EOL. Cuts strictly inside indivisible graphemes,
TABs or protected synthetic regions are rejected. The
`inlineFold` getter returns a detached snapshot or `null`.

For an inline fold from `(s,a)` to `(e,b)`, with `s<e`,
the output row `s` contains the input row `s` prefix
`[0,a)`, an indivisible synthetic `…` region in output
columns `[a,a+1)`, then the input row `e` suffix `[b,EOL)`
translated to start at output column `a+1`. Source rows
`s+1..e` disappear as separate output rows, so the exposed
`rowCount` decreases by `e-s`. All other visible rows retain
their input content, geometry and region kinds, with row indexes
adjusted after the splice. `getRegions` and `getRect` read only
the requested visible prefix/suffix fragments; hidden source rows
are never materialized for a bounded view. Source-less annotations
on visible fragments and at the two cut boundaries retain their
identities, while annotations inside the folded interval remain
hidden. The synthetic marker occupies exactly one exposed cell.

The two marker boundaries map independently: output `(s,a)`
to the start cut and output `(s,a+1)` to the end cut.
An insertion precisely at either boundary acts on that particular
source-side position; an interval that includes the marker or
otherwise intersects hidden input content is rejected before any
edit commits. Selection mapping follows the same rule: source
points strictly inside the folded interval are not representable,
and selected reads/inserts must not expose hidden text. Visible
prefix and suffix fragments can each be selected and edited
normally, including as different targets within one atomic
`replace(edits,expectedRevision)` batch. A view-local fold
configuration change increments the coordinate revision;
upstream changes clear this inline fold conservatively, just as
they clear whole-row folds.

Only one inline fold can be configured in one `FoldDocument2D`
at a time. `setInlineFold(null)` clears all folds in that view.
`setInlineFold(...)` and `setFolds(...)` are mutually exclusive
configurations: applying either replaces the other. Repeating
the same normalized configuration is a no-op. Independent folded
views may still be composed. A `CellDocument2D` above the
inline-folded view recomputes TAB widths in the new row;
a cell view below it retains widths computed in the original
input rows. Both orders preserve the respective exposed coordinate
contract and reject partial-cell edits.

The initial folding contract does **not** allow selecting or
editing the synthetic marker itself, preserve folds across input
edits, implement multiple inline splices in a single view, or
provide generic arbitrary-region substitution. The separate
`AnnotationDocument2D` owns creation of additive overlays;
`FoldDocument2D` only forwards overlays belonging to visible
regions. Precise old/new 2D invalidations and general source↔view
region relations remain open. `BaseDocument2D` and a public
`Representation` interface remain deferred until their shared
responsibilities are demonstrated by concrete implementations.



### `AnnotationDocument2D`: additive source-less metadata in `getRegions`

`new AnnotationDocument2D(input)` wraps any nominal `Document2D`,
including cell and folded views. The wrapper does not change the
input's `rowCount`, `colCount`, `getRowWidth`, `getRect`,
selected `read`, selection strategies or underlying edit storage.
The sole effective selection collection remains owned by the input.
It implements the full `Document2D` API, forwarding selection
operations and selected editing to the input without inventing a
second source or replacing the input's proven atomicity.

`setAnnotations([{id,text,at:{row,col}}, ...])` is an atomic,
view-local replacement of the annotation configuration. Each
`id` and `text` is a nonempty string; ids are unique within
this view. Anchors refer to existing input rows and real cell
boundaries up to and including EOL, not future/virtual rows.
Annotations inside indivisible input regions are rejected, as are
anchors on synthetic fold markers without a source position.
Records are sorted by row, column and id. `annotations` returns
detached `{id,text,at}` snapshots. Reapplying an identical
normalized configuration does not advance the revision; a
successful change advances the view's revision and publishes
`{type:'content',revision,invalidation:{all:true}}`.

`getRegions` returns all input regions together with additional
`{kind:'annotation',id,text,start:{row,col},end:{row,col}}`
records, where start and end are the **same point**. Multiple
annotations may share an anchor; they do not claim a text interval.
The overlay records are included when `colStart <= col < colEnd`
in the requested bounded row/column window, even on an otherwise
empty row. No separate `noteAt` query is required. Their labels
are UI-facing metadata, **not** source contents; the ordinary
`getRect`, selected `read` and `insert` continue to work only
with the input's text. `replace(edits, expectedRevision)` validates
this view's revision and forwards the complete batch once to
`input.replace(edits, inputRevision)`. A caller cannot edit the
annotation label by submitting a text edit: a text edit at the same
coordinate targets the original underlying text, not the overlay.

On any upstream coordinate-revision change, the view clears
all annotations and increments its own revision, with conservative
whole-view invalidation. Reanchoring across edits requires future
precise mutation geometry and is not inferred. `destroy()`
unsubscribes the view while leaving the input alive.
`CellDocument2D` additionally passes through zero-width
annotations below it, remapping anchors to cell coordinates;
`FoldDocument2D` preserves identities of visible annotations
and omits those inside folded rows. A raw UTF-16 annotation that
would split a logical grapheme can be valid in the raw coordinate
space but is rejected by a downstream cell transform, never
silently snapped.

This first implementation does **not** reserve layout cells,
render inline badges, implement annotation hit-testing, attach
persistent/rebased source anchors, or make annotation text editable.
The general semantics of occupied source-less regions, overlapping
editable projections and precise 2D invalidation remain open.
Neither `BaseDocument2D` nor a public `Representation` interface
is introduced by this incremental case.



### `SubstitutionDocument2D`: protected occupied and source-derived regions

`new SubstitutionDocument2D(input)` wraps a nominal `Document2D`,
including raw, cell, folded and annotated views. It implements
the full interface with the **same exposed row count** as its
immediate input. Each configured positive same-row input interval
is replaced in the display space by one read-only synthetic region,
while the underlying document text remains unchanged. The one
effective selection collection and atomic physical edits remain
owned by the input chain.

`setSubstitutions([{id,start:{row,col},end:{row,col},text}, ...])`
atomically replaces the view-local configuration. Each record has
a unique nonempty string `id`, with `0 <= start.col < end.col
<= input.getRowWidth(start.row)` on the same existing input row.
An entry must provide **exactly one** of:

- `text`: a nonempty literal display string;
- `sources:[{start:{row,col},end:{row,col}}, ...]`: a nonempty
  **ordered** list of positive, same-input-row fragments, each of
  which is read from the immediate input via `getRect` and
  concatenated into a protected, source-derived display string.

A derived entry may reference fragments on different input rows,
including disjoint or repeated fragments and fragments also
referenced by other entries. Each source fragment must lie within
a real input row and contain only ordinary `kind:'text'` content.
An input source fragment may not cut or cover an indivisible TAB,
grapheme, existing protected synthetic region or fold marker;
invalid configurations have no effects. The derived string is
assembled at the captured input revision, **not** re-read for each
subsequent viewport request. Neither literal nor assembled
display text may be empty or contain TAB, CR or LF. Its display
width is the number of Unicode grapheme segments determined by
`Intl.Segmenter`; one grapheme occupies one exposed cell.
This configuration-time materialization can read large source spans;
it does not establish a streaming or huge-file performance guarantee.

Substituted input intervals may be provided in any order and
normalized to ascending coordinates, but they may not overlap.
Adjacent intervals are permitted. Repeating the same normalized
configuration does not advance the view revision. The
`substitutions` getter returns detached source-coordinate
configuration snapshots: literal entries retain `text`;
derived entries retain their original `sources` records, rather
than exposing a mutable materialized display buffer. Internal
display-offset maps and source-copy relationships are not exposed
to `getRegions` consumers.

A substituted input interval `[a,b)` creates one positive-width
`{kind:'substitution',id,text,start:{row,col},end:{row,col}}`
region. `getRegions` returns the **entire** region when it
intersects the requested column window, whereas `getRect`
displays only the intersecting grapheme cells. Other visible
input regions and their metadata are translated into output
columns using cumulative changes in row width; multiple disjoint
substitutions therefore alternate real and synthetic fragments.
Annotations on still-visible fragments and cut boundaries are
reprojected, while those inside hidden input intervals are not.
A `CellDocument2D` composed above this view preserves the
substitution's `id`, occupied width and indivisible region type.

**Display dependencies are not edit destinations.** The synthetic
region's exposed start and end map to the two respective boundaries
of the *replaced* input interval, not to the optional source
fragments used to render the label. Even if one source fragment
appears in several labels, editing or selecting any of its copies
does not authorize modification of its original text. Positions
strictly inside synthetic display regions have no editable
input coordinates. An input point inside replaced source text
has no visible counterpart. Selections and edits spanning a
substituted interval are rejected **even when both endpoints
individually map**. `getSelections`, `read` and selected
`insert` refuse input-owned selections that would reveal or
modify hidden text. Unaffected selections continue to use the
single input-owned selection collection. Accepted explicit edits
translate through `Document2D._replaceMapped` and commit once.

Changing the local configuration advances the view-coordinate
revision and publishes conservative
`{type:'content',invalidation:{all:true}}`. **Any upstream
coordinate-revision change clears all substitutions**, including
derived source relationships, advances this view's revision and
invalidates previous coordinates. Persistent source anchoring
would require accurate old/new 2D change geometry, which is not
yet provided. `destroy()` leaves the input alive.
Bounded viewport reads do not materialize hidden input spans.

This implementation demonstrates *read-only* many-to-one and
one-to-many derivation, but not an editable general many-to-many
region engine, cross-row substitution of the destination interval,
automatic rebasing or a public `Representation` abstraction.
`BaseDocument2D` is likewise not introduced by this feature.


## Validation and release boundary

The current v0.8.2 library is checked against the actual product source by
permanent Node tests in `rumiai-tests/tests/rumiai-os/text-edit/core.test.mjs`,
`base.test.mjs`, `selections.test.mjs`, `representation.test.mjs` and `advanced.test.mjs`, executed through their target-discovering test entrypoint
and pinned by `rumiai-os/.github/workflows/text-edit.yml`. The workflow
checks JavaScript syntax, executes the tests on Node 22, and builds a
standalone source archive. These checks validate the store, selection and representation contracts,
including atomic multicaret commits, document revision continuity, geometric
cross-view rebasing and independent seeded reference tests. They do not establish GUI/host parity or unconditional atomicity for
arbitrary broken external backends. Physical
GUI validation remains a separate work unit.
