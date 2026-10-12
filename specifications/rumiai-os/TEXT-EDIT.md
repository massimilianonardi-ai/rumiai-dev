# TextEdit — current standalone text-engine contract

Status: **Current — released v0.1.0 and accepted next TextEditBase contract (implementation pending)**  
Updated: 2026-10-12

## Responsibility and ownership

`TextEdit` is a standalone, GUI-independent JavaScript library distributed
with `m` at `rumiai-os/lib/sys/js/text-edit.lib.js`. Its role is text storage,
oriented multi-range editing, a source-mapped representation, and translation
of advanced selections. Released v0.1.0 does not define a GUI, rendering backend, font/layout engine,
IME adapter, event/listener bus or history system. The accepted next document
contract below adds only direct mutation notifications, not a generic event bus. The separately versioned project/repository packaging boundary
is not established by this release; product code is the authoritative source
for its exact published public library.

The public `TextEdit` library object exposes `VERSION`, `TextEdit`,
`PieceDocument`, `FlatDocument`, `TextEditSelections`,
`TextEditRepresentation` and `TextEditAdvancedSelections`.
The public JS operational manual is `res/sys/manual/text-edit.lib.js`.
JavaScript text positions and payload lengths are UTF-16 code units.
No GUI-specific dependency or mandatory third-party runtime is permitted.

## Accepted next TextEditBase contract — pending product realignment

This section is the binding **next implementation contract**, not a description
of the released v0.1.0 product. The source implementation, operational manual,
selection/representation integration and permanent tests still implement and
validate the v0.1.0 interface; they must be realigned together in a separately
authorized product work unit. The next release must not be described as
implemented or validated until that work succeeds.

`TextEditBase` remains a structural document interface, not a selectable
editor, not an instantiable class, and not a view, rendering or history engine.
Its public document interface is precisely:

```javascript
length                       // property: source UTF-16 length
revision                     // property: committed mutation sequence
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
records or a history entry. `subscribe` requires a function listener and
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

Logical source lines are separated by LF (`\n`), including LF in CRLF.
An empty document has one empty line; a trailing LF creates an additional
empty final line. `lineCount` equals one plus the number of LF characters.
Line indexes are zero-based and valid in `[0,lineCount)`.

`lineStart(line)` returns the first offset of that line. `lineAt(offset)`
accepts safe integer source positions `[0,length]`, including EOF, and
returns the line containing that position; the LF separator itself belongs
to the preceding line, while the offset immediately after it belongs to the
next line. `lineInfo(line)` returns exactly
`{start,end,nextStart}`: `start` is the first content position,
`end` is the exclusive end of content without its LF or CRLF terminator,
and `nextStart` is the position after that terminator, or `length` on the
last line. In CRLF, both CR and LF are excluded from the content interval;
a standalone CR is ordinary text. For the last line, `nextStart === length`.
All three operations use source, not projected or wrapped, coordinates.
Invalid indexes/ranges fail without mutating state.

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

`revision` starts at zero for a newly initialized document. It increases
**exactly once per successful public `replace` call**, for either overload,
including committed no-effect calls; it does not change for reads, listener
registration, or rejected/failed edits. Revision progression must remain
represented exactly by a safe integer; exhaustion fails before a mutation.

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
after the atomic commit and revision increment, in registration order; each
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
representations, and each should consume a committed source mutation
**exactly once**. The source of an edit must not independently rebase the
same selection or representation a second time through the existing
facade's returned change result.

The next representation/selection integration must be adapted to rebase
from the committed original arguments and revision without requiring
`removed` or other extra data from `TextEditBase` notifications. The
released v0.1.0 `representation.rebase(changes)` currently requires
old-text-containing results and is **not** yet compatible with this new
notification contract. Its reconciliation is required before the target
document contract can be called implemented.

Notifications coordinate copies/consumers that already share the same
ordered source revisions; the base does **not** resolve independent
concurrent edits against divergent copies. Distributed conflict resolution,
OT, CRDT, remote transport, history/undo and replay-log storage are outside
this document-base responsibility.

## Document and selections

In the released v0.1.0 implementation, the base document contract consists of
one-interval `length`, `slice(start,end)` and `replace(start,end,text)`. `TextEditBase` is a
structural contract, **not** an instantiable class. `PieceDocument` is the
current indexed-piece-treap implementation; its `lineCount` and
`lineStart(logicalLine)` index logical source rows. `FlatDocument`
is a simple reference baseline.

`TextEditSelections` owns oriented UTF-16 selections with zero-length caret
ranges, preserves caller identity/order, and applies selections as primitive
document edits. It does not know folding, GUI geometry or clipboard semantics.
A compound operation prepares its results and uses compensating restoration
on identifiable synchronous underlying failures. Unrecoverable/uncertain
backends must fail closed, never silently claim successful text restoration.

`TextEdit` composes the document, selections, representation and advanced
selection resolver. Its `replace(textOrTexts)` executes selected editing and
then explicitly rebases the representation from the confirmed change result.
The constructor may accept a selection-compatible implementation for future
transparent wrappers. Released v0.1.0 introduces no lower-layer listeners.

## Document representation and source mapping

`TextEditRepresentation` is a view-independent **representation of source
text**, not a second editable copy of that text and not the DOM.
`replace(start,end,text)` modifies **only this representation** by replacing
the source interval `[start,end)` with any user-provided JavaScript string,
including empty strings, Unicode and newlines. The original document remains
unchanged. The source coordinates are mandatory, even if that interval is
not currently displayed one-to-one. A replacement requires nonempty source
span with Unicode-grapheme-safe boundaries. A matching source span may be
updated. Overlapping spans are rejected rather than implicitly nested.

`project(start,end)` emits bounded source-referenced text and substitution
segments, with UTF-16 grapheme boundaries for fully projected text segments,
plus separate annotation metadata. The caller may request windows rather
than materializing all visible source text. Projection boundaries may not
cut a grapheme or a substitution. Annotation anchors are source positions;
annotation text is not counted in projected string coordinates.

`sourceToView` and `viewToSource` resolve exact UTF-16 locations outside
substituted regions and describe the **entire replaced source/view region**
for positions with no one-to-one mapping. In particular, empty substitution
regions are not treated as a falsely unique original source position.
Representation mapping never manufactures an editable original offset in
a hidden or synthetically substituted segment.

After a successful source edit, the caller uses confirmed change records to
call `representation.rebase(changes)`. Source regions modified inside an
existing substitution are invalidated, and ambiguous annotations are returned
as unresolved, rather than silently re-anchored. At insertion points,
annotation affinity is explicit (`before`/`after`); unknown affinity remains
unresolved. Low-level text or selection stores have no history listeners or
projection hooks.

Released v0.1.0's minimal base interface does not provide monotonically
increasing source revision IDs. An external edit that preserves both length and line count and
is not supplied as a confirmed change cannot be detected. Callers must
coordinate source edits through the public facade or explicitly rebase the
representation; they must not rely on automatic observation of arbitrary
changes outside that boundary.

## Advanced selections and deferred responsibilities

`TextEditAdvancedSelections` expresses logical-line and rectangular
selection requests, translates them into ordinary UTF-16 selections, and
delegates to `TextEditSelections`. Rectangular geometry uses explicit
grapheme widths and tab stops supplied by the caller. Positions inside
wide cells and overlapping selection targets are rejected rather than
snapped silently. These first APIs operate on **logical source rows**,
not wrapped GUI pixel rows or arbitrary post-fold visual rows. Rectangles
crossing substitutions are rejected pending an explicit high-level policy.

The future history feature will be a transparent wrapper containing
`TextEditSelections`, substituting for it at the composition point without
modifying lower layers or upper callers. It is not implemented in v0.1.0.
Rendering, true font metrics, wrapping, complex bidi shaping, IME,
nested/syntactic folding, visual-row selection, incremental optimization
and GUI integration are outside this first core release.

## Validation and release boundary

The initial library release is exercised against the actual product file
by permanent Node tests in
`rumiai-tests/tests/rumiai-os/text-edit/core.test.mjs`, with a pinned
test revision in `rumiai-os/.github/workflows/text-edit.yml`.
The workflow builds the standalone distribution archive. Passing a
JavaScript/browser build smoke or an earlier PoC does not establish
GUI/host parity or unconditional atomicity for arbitrary broken backends.
Physical host GUI validation will be a separate work unit.
