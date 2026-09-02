# Text and Cross-Package Behavior Audit

Reference behavior is the OpenFL 9.5.2 source under
`/tmp/builder3-haxelib/openfl/9,5,2/src/openfl/`; the implementation under audit
is `src/openfl/`. This checklist records source parity, including observable
OpenFL 9.5.2 quirks rather than substituting Flash documentation where the two
differ.

- `[x]` handled: the current adapter has the required state and behavior, or
  deliberately matches the 9.5.2 source behavior.
- `[ ]` missing/unclear: adapter work or a focused parity test is still needed.
- `[!]` Flight gap: the adapter cannot complete the behavior through the
  current public Flight surface. These entries correspond to the durable gap
  descriptions in `agents/flight-gaps.md`.

## TextField content, layout state, and invalidation

- [x] A `TextField` owns a Flight `RichText` child and synchronizes text,
  per-character format ranges, default format, dimensions, background, border,
  wrapping, scrolling, selection, password options, and input constraints.
- [x] Plain `text` assignment rejects `null`, resets HTML state and character
  formats to clones of `defaultTextFormat`, resets the selection to zero, and
  does not dispatch `Event.CHANGE`, matching the observable 9.5.2 assignment
  path.
- [x] `appendText`, `replaceText`, and `replaceSelectedText` preserve unaffected
  character formats, insert the default format, update selection/caret state,
  and reject replacement while a StyleSheet is assigned.
- [x] Programmatic `text`, `appendText`, and `replaceText` are not truncated by
  `maxChars` or filtered by `restrict`; OpenFL 9.5.2 applies those constraints to
  user input, not these calls.
- [x] RichText setters advance Flight content/appearance/bounds revisions, so
  text, format, dimension, background, border, and wrapping changes invalidate
  the actual render node without needing the old OpenFL renderer dirty flags.
- [ ] The OpenFL-side `Stage.__invalidated` flag is not set by most TextField
  setters. Flight rendering sees the revisions, but explicit `Event.RENDER`
  invalidation semantics have not been demonstrated for these mutations.
- [ ] `TextField` does not override `__getBounds` and does not set its own
  `__localBounds`. Its Flight child can render, but `getBounds`, `getRect`, hit
  testing, container bounds, and width/height-derived display behavior do not
  receive the field rectangle that OpenFL 9.5.2's TextEngine supplies.
- [x] `autoSize` recomputes field dimensions from text metrics and retains the
  left, center, or right anchor used when the mode is selected.
- [ ] Auto-size parity is only covered for the basic fixture path. Empty text,
  `wordWrap`, scaled fields, later x/width mutations, border gutters, and
  multi-format/HTML content need focused comparisons; the current implementation
  recomputes eagerly instead of using OpenFL's layout-dirty pass.
- [x] `multiline`, `wordWrap`, width, and height feed the Flight layout and
  RichText node; scaled width/height setters retain local unscaled dimensions.
- [ ] Changing `multiline` from true to false does not normalize existing line
  breaks. The current `__withoutLineBreak` helper is unused, so the single-line
  normalization behavior remains unverified.

## TextField selection, scrolling, interaction, and events

- [x] `setSelection`, selection getters, and `caretIndex` retain OpenFL 9.5.2's
  raw indices, including reversed and out-of-range values, while forwarding the
  selection to Flight TextInput.
- [ ] OpenFL 9.5.2 scrolls the caret into view from `setSelection`; the current
  method only sets the Flight selection. Programmatic selection scrolling and
  selection rendering therefore need an adapter call/test.
- [x] `scrollH` and `scrollV` are rounded and clamped by Flight, mirrored back
  through the scroll signal, and dispatch `Event.SCROLL` only when the effective
  value changes. Maximum and bottom scroll values are layout-derived.
- [x] Appending while pinned to the bottom advances the rendered bottom line
  while preserving the reported `scrollV` quirk captured from OpenFL 9.5.2.
- [x] Basic line/character/paragraph queries delegate to Flight TextLayout and
  apply the current horizontal and vertical scroll offsets:
  `getCharBoundaries`, `getCharIndexAtPoint`, `getLineIndexAtPoint`,
  `getLineIndexOfChar`, line offset/length/text/metrics, and paragraph queries.
- [ ] Query parity is incomplete for proportional fonts, wrapped whitespace,
  tabs, surrogate pairs/non-ASCII strings, mixed-size runs, empty trailing
  lines, and scrolled coordinates. The headless fixtures use zero glyph widths,
  so they do not validate glyph x positions or point-to-character boundaries.
- [!] Flight has selectable-text and editable-text managers, pointer selection,
  keyboard editing, focus, restrictions, and a `TextInputSource` connector, but
  the OpenFL Stage bridge owns no host-local Flight input manager/source. Native
  keyboard and text ingress therefore cannot autonomously reach a TextField.
- [ ] `TextField.type` and `tabEnabled` retain the public dynamic/input state,
  but changing type does not focus/blur a Flight TextInput manager or install
  the OpenFL focus/input lifecycle that 9.5.2 starts and stops.
- [x] Generic Stage focus assignment dispatches bubbling OpenFL `FOCUS_IN` and
  `FOCUS_OUT` events to a TextField.
- [ ] Mouse selection is not wired. The current TextField installs no mouse
  down/move/up/wheel listeners and does not route OpenFL pointer coordinates to
  Flight's selectable/editable text managers; single/double/triple-click and
  drag selection are absent.
- [ ] Link interaction is not wired. Flight exposes
  `dispatchRichTextLinkAtPoint` and `onTextFieldLink`, but TextField neither
  connects the link signal nor converts it to OpenFL `TextEvent.LINK`.
- [x] A Flight-originated text mutation is mirrored to `text`, formats,
  selection, and auto-size, then produces OpenFL `Event.CHANGE`; a programmatic
  assignment is ignored by the callback after the adapter has already updated
  its shadow string.
- [ ] Input `Event.CHANGE` must bubble in the OpenFL 9.5.2 path, but the current
  Flight callback constructs the non-bubbling default `Event.CHANGE`.
- [ ] OpenFL's cancellable, bubbling `TextEvent.TEXT_INPUT` is not emitted before
  Flight edits. The current change signal is post-mutation and cannot implement
  cancellation by itself.
- [x] Flight-originated scroll changes produce OpenFL `Event.SCROLL`; the event
  is non-bubbling, matching the 9.5.2 setter path.
- [ ] Cursor blink, selection collapse on focus loss, clipboard shortcuts, and
  keyboard caret navigation are present in the 9.5.2 TextField event handlers
  but have no OpenFL-to-Flight interaction bridge in the current class.
- [x] `restrict`, `maxChars`, password mode/character, `selectable`, mouse-wheel
  enablement, and multiline mode are retained and passed to Flight.
- [!] Their user-editing effect remains blocked with host input. In addition,
  OpenFL `TEXT_INPUT` cancellation would require an adapter-level pre-edit seam,
  even after Stage owns the Flight manager.

## TextFormat ranges and defaults

- [x] `defaultTextFormat` is clone-on-read and merge-on-write. Existing
  per-character formats remain unchanged while subsequent plain assignment or
  inserted text uses the merged default.
- [x] `setTextFormat` implements the public index defaults and range errors,
  merges only non-null fields, synchronizes format ranges to Flight, and
  invalidates layout/auto-size.
- [x] All public OpenFL 9.5.2 `TextFormat` fields used by the text renderer are
  mapped to and from Flight: alignment, margins/indent, bold/italic/underline/
  strikethrough, color, family/size, kerning/leading/letter spacing, bullets,
  tab stops, URL, and target.
- [ ] `getTextFormat(begin, end)` returns only the format at `begin`. OpenFL
  9.5.2 compares every intersecting range and sets each mixed property to
  `null`; mixed-range reads are therefore incorrect.
- [ ] The current one-range-per-character synchronization is observably usable
  but loses OpenFL's compact run structure. Unicode indexing and edits across
  multi-code-unit characters need explicit coverage before this representation
  can be considered equivalent.

## HTML text and StyleSheet

- [x] `htmlText` rejects `null`, keeps the raw HTML shadow for readback, updates
  plain `text`, resets selection to the end, and supports basic entity decoding.
- [x] The current fallback recognizes `<br>`, `<b>`, `<i>`, `<u>`, and
  `<font color=...>`, plus decimal/hex numeric entities and the common named
  entities `lt`, `gt`, `quot`, `amp`, `nbsp`, and apostrophe.
- [ ] The OpenFL 9.5.2 HTMLParser behavior is substantially broader. Missing
  behavior includes `<a href>`/URL ranges, `<em>`, `<p align>` paragraph breaks,
  `<li>` bullet insertion, `<font face>` and absolute/relative `size`,
  `<textformat>` margins/indent/leading/tab stops, tag-name styles, `.class` and
  `tag.class` styles, `a:link`, nesting matched by tag name, multiline-aware
  `<br>`, and the full `StringTools.htmlUnescape` entity set.
- [ ] The fallback stack pops on every closing tag rather than matching the tag
  being closed, and treats unknown opening tags as no-ops. Malformed/nested HTML
  therefore differs from the 9.5.2 parser.
- [!] Flight TextMarkup exposes the standard markup, entities, format ranges,
  and class-style resolver, but the generated non-JavaScript implementation
  calls JavaScript-only `String.search`. The adapter cannot replace its fallback
  parser with TextMarkup on eval/native until that generated portability defect
  is fixed.
- [x] `StyleSheet` retains the 9.5.2 case-insensitive registry, clear/get/set
  behavior, live style-name cache quirks, style-object copy on assignment, and
  merge-on-`parseCSS` behavior used by the harness.
- [x] The supported StyleSheet-to-TextFormat conversions match 9.5.2, including
  first-family selection and `mono`/`sans-serif`/`serif` aliases. The 9.5.2
  numeric regex quirks (integer prefix, ignored sign/fraction in several
  properties) are deliberately retained.
- [ ] The replacement CSS regex parser is not equivalent to the 9.5.2 internal
  CSSParser for malformed rules, escaped/quoted delimiters, comments in unusual
  positions, or parser recovery. Only the ordinary rule/declaration subset has
  comparison coverage.
- [!] Flight has no CSS text parser or mutable StyleSheet abstraction. Keeping
  OpenFL's CSS parsing and style registry in the adapter is required unless a
  new Flight CSS surface is added.
- [ ] Assigning a StyleSheet reparses HTML and forces `type=DYNAMIC`, but the
  current HTML fallback never consults the sheet. Tag, class, compound, and
  `a:link` rules consequently do not affect content at all.
- [x] StyleSheet `display` and `kerning` conversion remain unimplemented exactly
  as in OpenFL 9.5.2; they are not new adapter regressions.

## TextEngine replacement: line construction, glyphs, and bounds

- [x] Flight TextLayout provides line-break discovery, multiline termination,
  word wrapping, long-word splitting, per-line ascent/descent/leading/height/
  width arrays, per-run format groups, alignment, margins, indent, bullets,
  kerning-aware advances, letter spacing, and tab-stop/default-tab advances.
- [x] Flight returns group offsets, per-character advances, line indices, text
  width/height, and line/character query helpers; TextField consumes these
  rather than carrying OpenFL's private TextEngine/TextLayout classes.
- [x] Explicit newlines and ordinary space wrapping follow the same broad
  pipeline as OpenFL 9.5.2, including gutter-based measurements and a final
  line.
- [ ] Exact breaking parity is unclear around hyphens, tabs used as break
  opportunities, repeated/leading/trailing whitespace, CR/CRLF, combining
  marks, surrogate pairs, and a format boundary within a word. OpenFL's engine
  has target-specific UTF8String and glyph-position adjustments that the
  current Haxe adapter does not normalize before calling Flight.
- [ ] OpenFL 9.5.2 derives public TextField bounds and text bounds during its
  layout pass. Flight computes RichText local bounds, but the adapter does not
  copy those bounds into the owning OpenFL TextField (see the missing
  `TextField.__getBounds` item above).
- [ ] There is no explicit text measurement provider installed by openfl-flight.
  The comparison harness consequently records `textWidth == 0` and cannot test
  proportional layout. Host render setup may supply measurements on a live
  target, but eager metrics before first render and consistency across GL,
  Cairo, Canvas, and DOM need verification.
- [x] The Flight RichText node supplies the actual renderer-facing embedded/
  device family string and bold/italic selection rather than retaining the old
  target-specific TextEngine render branches.
- [!] Flight exposes no per-RichText `embedFonts` policy. The flag is retained,
  but it cannot require an embedded face or disable device fallback as OpenFL
  does.

## Font registration, enumeration, and matching

- [x] `Font.registerFont` accepts both a Font subclass and an instance, creates
  the subclass when necessary, appends the instance to the global registered
  list, and replaces the exact-name map entry, matching 9.5.2.
- [x] Native Lime/Cairo registration forwards the Lime font and its regular,
  bold, italic, or bold-italic style to Flight's maintained `LimeFonts` bridge.
  This is the path that makes registered embedded fonts available to native
  Flight text rendering.
- [x] `enumerateFonts(false)` returns the registered backing array, including
  its 9.5.2 live-array behavior. Native `enumerateFonts(true)` extends a copy
  with device `.ttf` files, preserving the reference implementation path.
- [x] Font name state is mirrored into the Flight font entity, and async Lime
  font adoption updates that name.
- [ ] The old TextEngine matched an exact registered `fontName`, then an exact
  full font path or path basename on native, and selected registered family
  variants named ` Bold`, ` Italic`, or ` Bold Italic`. The current TextField
  sends only the requested family/style to Flight; path/basename fallback and
  equivalent variant matching have not been demonstrated.
- [ ] `registerFont` only forwards to the render backend when a native
  Lime/Cairo font has non-null source data. HTML5, non-Cairo native, late-loaded
  font data, duplicate names/styles, and registration before initialization
  need target tests.
- [!] `embedFonts` cannot control registered-vs-device resolution through the
  public Flight RichText API, even when registration itself succeeds.

## Display and geometry interactions

- [x] x/y/scale/rotation and `Transform.matrix` mutations immediately update the
  OpenFL matrix and Flight node. Matrix reads are clones, and
  `concatenatedMatrix` is freshly rebuilt from the parent chain, so later parent
  and child mutations cannot leave a stale OpenFL matrix cache.
- [x] `localToGlobal` and `globalToLocal` delegate to Flight's scene graph and
  have coverage for nested transforms and `scrollRect` origin changes.
- [x] Vector/local bounds are transformed through all four rectangle corners;
  container bounds recursively union child geometry in the requested target
  coordinate space. Basic translation/scale/rotation cases match the fixtures.
- [x] `getRect` delegates to `getBounds`, matching OpenFL 9.5.2's current source
  implementation even though the API documentation distinguishes stroke
  handling.
- [ ] Bounds coverage is incomplete for masks, zero-axis scales, empty/line-only
  children, `scrollRect`, filters' render bounds, TextField, and disposed
  bitmaps. Current `Rectangle.isEmpty` union gating can also discard degenerate
  geometry that the 9.5.2 `__expand` path retains.
- [x] `Transform.colorTransform` is clone-on-read and copy-on-write, and setting
  its alpha multiplier updates `DisplayObject.alpha` as the current harness
  expects.
- [ ] RGB color multipliers/offsets on `Transform.colorTransform` are not
  attached to the Flight node, so they are state-only and do not affect normal
  rendering.
- [ ] `concatenatedColorTransform` and `pixelBounds` are constructed once and
  never refreshed. The existing fixtures capture OpenFL's pre-render identity/
  empty quirk, but after an update/render pass OpenFL 9.5.2 populates these from
  world color state and stage pixel bounds; the adapter cannot do so today.
- [ ] Assigning a `Transform` whose active representation is `matrix3D` does not
  transfer the 3D/matrix mutual-exclusion state to the destination. The current
  setter reads only `value.matrix` and its color transform.

## Display filters and cacheAsBitmap

- [x] Filter assignment clones every non-null filter and stores an independent
  array. Getter calls return distinct arrays containing the stored filter
  objects, matching OpenFL 9.5.2: mutating the returned array is isolated, while
  mutating a returned filter changes the stored filter.
- [x] A non-empty filter list forces the observable `cacheAsBitmap` getter to
  true regardless of the explicitly assigned cache flag; clearing filters
  reveals the explicit flag again.
- [x] Filter list order is retained, and filter property setters keep their
  Flight effect descriptors synchronized.
- [x] `ColorMatrixFilter` values are attached to the Flight node as ordered
  color adjustments, so this filter family participates in normal rendering.
- [!] Flight can construct blur, bevel, glow, shadow, convolution, and shader
  `RenderEffect` descriptors, but exposes no public per-Node2D effect-list
  attachment. Those assigned filters cannot participate in display rendering.
- [ ] OpenFL's internal filter/render bounds expand by each filter's left/top/
  right/bottom extensions. The adapter has no `__getFilterBounds` or equivalent
  expansion path, so cached/offscreen allocation and clipping cannot honor the
  filters even though public `getBounds` correctly remains unexpanded.
- [!] `cacheAsBitmap` retains public state but has no general implementation.
  Flight exposes no public portable operation that rasterizes an arbitrary
  Node2D subtree into a bitmap, which is required for the cache surface and for
  cache invalidation on child/transform/filter changes.
- [ ] Full filter render-order contracts are not met: OpenFL applies the list in
  order to a flattened object subtree, with color transform/blend/cache/mask
  composition around that surface. Only the directly attached color adjustments
  currently execute; mixed and repeated filters need the node-effect and
  offscreen seams above.

## BitmapData.draw and Bitmap display interaction

- [x] `Bitmap.bitmapData` retains the assigned reference, resets `smoothing` to
  false like OpenFL 9.5.2, rebuilds the Flight texture, updates local bitmap
  bounds, invalidates node appearance, and marks the Stage for OpenFL render
  events.
- [x] Bitmap pixel changes mutate a shared versioned Flight bitmap source, so
  Bitmap instances continue to share the same underlying BitmapData content.
- [x] Bitmap smoothing selects Flight's clamp-linear sampler when true and the
  pixel-art/nearest sampler when false.
- [ ] `smoothing` is a plain field with no setter; changing it rebuilds the
  sampler only during `Bitmap.__enterFrame`. Immediate render invalidation and
  rendering without an intervening frame are not guaranteed. This is a likely
  interaction point for the observed bitmap smoothing discrepancy.
- [x] `BitmapData.draw(BitmapData, ...)` applies the supplied matrix in
  destination coordinates, uses nearest/bilinear sampling from `smoothing`,
  applies the explicit color transform, clips in destination space, and
  composites with the mapped blend mode.
- [ ] `BitmapData.draw(DisplayObject, ...)` incorrectly includes the root source
  object's own local transform. OpenFL 9.5.2 treats the source as library-local
  and applies only the method's matrix to the root, while retaining descendant
  transforms.
- [ ] The portable bitmap-only display-tree flattener handles nested Bitmaps,
  transforms, alpha, visibility, and blend modes, but ignores masks,
  `scrollRect`, object color transforms, filters, shaders, opaque backgrounds,
  and cache surfaces. Encountering vector graphics abandons that path.
- [!] Native Cairo can rasterize the remaining Flight scene subtree, but Flight
  has no portable arbitrary-Node2D-to-bitmap operation. DisplayObject drawing on
  non-Cairo targets and exact filtered/cached composition remain blocked on
  that offscreen bridge.
- [ ] The Cairo fallback still needs coordinate/order parity checks for the
  source root transform, supplied matrix, scroll rectangle, filters, and source
  visibility restoration against the 9.5.2 software renderer.
- [ ] Disposing BitmapData clears its adapter handle, dimensions, rect, and
  readability, but existing Bitmap instances retain their Flight texture and a
  copied pre-disposal local bound. They are not notified or resynchronized, so
  stale pixels/bounds may continue to render until `bitmapData` is reassigned.
- [x] Calls made directly on disposed BitmapData generally return the same
  inert/null/zero forms enforced by the current readable/handle guards; the
  outstanding defect is propagation to display objects that already reference
  it.

## Highest-value follow-up coverage

- [ ] Add a live-measurement TextField fixture with a known font, mixed format
  runs, wrapping, tabs, Unicode, character bounds, and point queries.
- [ ] Add HTML/StyleSheet fixtures covering all 9.5.2 tags, attributes,
  entities, nested tags, tag/class/compound/a:link selectors, and link events.
- [ ] Add Stage input fixtures for focus, keyboard editing, pointer selection,
  `TEXT_INPUT` cancellation, bubbling `CHANGE`, restrictions, maxChars,
  clipboard operations, and caret scrolling.
- [ ] Add rendered transform/filter fixtures after an actual frame to cover
  concatenated color, pixel bounds, filter order/expansion, and cache
  invalidation rather than only public property storage.
- [ ] Add BitmapData draw fixtures with a transformed root source, nested
  children, mask/scrollRect/color transform/filter/blend composition, smoothing
  changes, and disposal while one or more Bitmaps retain the data.

## Verification

- [x] `haxe test/harness/compare.hxml` passes all 90 scenarios after this audit.
  The pass establishes that the documented gaps are not regressions against the
  current fixture set; the follow-up list above identifies the behavior those
  fixtures do not yet exercise.
