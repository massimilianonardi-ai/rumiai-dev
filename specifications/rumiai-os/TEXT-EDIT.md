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
