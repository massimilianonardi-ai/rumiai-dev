# TextEdit — current standalone text-engine contract

Status: **Current / v0.1.0**  
Updated: 2026-10-11

## Responsibility and ownership

`TextEdit` is a standalone, GUI-independent JavaScript library distributed
with `m` at `rumiai-os/lib/sys/js/text-edit.lib.js`. Its role is text storage,
oriented multi-range editing, a source-mapped representation, and translation
of advanced selections. This first library release does not define a GUI,
rendering backend, font/layout engine, IME adapter, event/listener bus or
history system. The separately versioned project/repository packaging boundary
is not established by this release; product code is the authoritative source
for its exact published public library.

The public `TextEdit` library object exposes `VERSION`, `TextEdit`,
`PieceDocument`, `FlatDocument`, `TextEditSelections`,
`TextEditRepresentation` and `TextEditAdvancedSelections`.
The public JS operational manual is `res/sys/manual/text-edit.lib.js`.
JavaScript text positions and payload lengths are UTF-16 code units.
No GUI-specific dependency or mandatory third-party runtime is permitted.

## Document and selections

The base document contract consists of one-interval `length`,
`slice(start,end)` and `replace(start,end,text)`. `TextEditBase` is a
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
transparent wrappers; no lower-layer listeners are introduced.

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

The minimal base interface does not provide monotonically increasing source
revision IDs. An external edit that preserves both length and line count and
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
