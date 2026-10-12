# TextEdit — current standalone text-engine contract

Status: **Current — TextEditBase v0.2.0 implemented; selection/representation realignment pending**  
Updated: 2026-10-12

## Responsibility and ownership

`TextEdit` is a standalone, GUI-independent JavaScript library distributed
with `m` at `rumiai-os/lib/sys/js/text-edit.lib.js`. Its role is text storage,
oriented multi-range editing, a source-mapped representation, and translation
of advanced selections. The current v0.2.0 library defines no GUI, rendering
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

## TextEditBase contract — implemented in v0.2.0

This section defines the implemented and validated public document-store
contract for both `PieceDocument` and `FlatDocument` in the v0.2.0 product
source. The operational manual and permanent store tests have been aligned.
The older sequential selection-editing facade and explicit representation
rebase path remain operational but have **not** been realigned to produce one
store commit and one rebase per multi-caret user action. That separate
integration remains pending and must not be reported as completed.

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
representations, and each should consume a committed source mutation
**exactly once**. The source of an edit must not independently rebase the
same selection or representation a second time through the existing
facade's returned change result.

The pending representation/selection integration must be adapted to rebase
from the committed original arguments and revision without requiring
`removed` or other extra data from `TextEditBase` notifications. The current `representation.rebase(changes)` still requires old-text-containing
results and does not yet consume the new document notification contract.
Its reconciliation is required before the wider selection/representation
integration can be called complete; it does not block the base-store contract.

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

The current base exposes cyclic source revisions and direct committed-edit
notifications. `TextEditRepresentation` still requires an explicit
confirmed-change rebase through the existing facade; it does not subscribe
to those notifications automatically. Callers must arrange consistent view
updates without applying the same source edit twice.

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

The current v0.2.0 library is checked against the actual product source by
permanent Node tests in `rumiai-tests/tests/rumiai-os/text-edit/core.test.mjs`
and `base.test.mjs`, executed through their target-discovering test entrypoint
and pinned by `rumiai-os/.github/workflows/text-edit.yml`. The workflow
checks JavaScript syntax, executes the tests on Node 22, and builds a
standalone source archive. These checks validate the store behavior,
including error-atomic persistent staging and indexed line access, but do
not establish GUI/host parity, the pending higher-layer integration or
unconditional atomicity for arbitrary broken external backends. Physical
GUI validation remains a separate work unit.
