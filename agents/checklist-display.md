# `openfl.display` internal behavior audit

Reference: OpenFL 9.5.2 under
`../haxelib/openfl/9,5,2/src/openfl/display/`, including the non-renderer
helpers in `_internal/`. Adapter: `src/openfl/display/`. This is a behavioral
checklist, not an API inventory. It concentrates on state transitions, implicit
side effects, event and command ordering, and package boundaries that a
signature comparison does not expose.

Legend:

- [x] The adapter preserves the behavior at the Flight boundary.
- [ ] The behavior is missing, observably different, or still needs a focused
  compatibility fixture before it can be claimed.
- [!] The behavior is blocked by a confirmed entry in `agents/flight-gaps.md`;
  the entry names that gap exactly.

## `DisplayObject`

### Transforms, bounds, and hit testing

- [x] Position, scale, rotation, alpha, visibility, name, and the local matrix
  are synchronized immediately to the object's Flight `Node2D`; transform
  getters and `localToGlobal`/`globalToLocal` read through the same graph.
- [x] `scrollRect` is defensively copied, negative dimensions are clamped to
  zero, its origin translates render coordinates, and its rectangle becomes a
  Flight clip used by hit collection. Public logical bounds remain independent
  of the clip.
- [ ] The reference has distinct `__getBounds`, `__getFilterBounds`, and
  `__getRenderBounds` walks. In particular, a `scrollRect` substitutes its
  transformed rectangle for render bounds, filters expand render bounds, and
  render bounds omit masks and either-axis-zero children. The adapter has only
  the logical `__getBounds` walk.
- [ ] Reference `__hitTest` first rejects an invisible hit owner and any object
  marked `__isMask`, applies the owner's mask with precise `__hitTestMask`, and
  only then tests graphics. The adapter's boolean helper tests `scrollRect`,
  graphics, and fallback local bounds, but does not enforce visibility,
  `__isMask`, or shape-mask clipping itself.
- [ ] A mask is single-owner in both implementations, but the adapter only
  updates `__mask`/`__maskTarget`. It never toggles the reference's `__isMask`
  state, invalidates the mask transform/render state, suppresses the mask from
  normal rendering, or attaches equivalent shape-mask clipping to Flight.
- [ ] `root` is `Lib.current` for any staged reference object. The adapter
  instead returns the topmost child below its `Stage`, which can differ when a
  stage has more than one root-level child.

### Dirty and derived render state

- [ ] Reference `__setRenderDirty` marks the object, propagates to
  `__renderParent` or `parent`, and optionally queues an update. The adapter
  turns every render dirtiness request directly into `stage.__invalidated`, so
  ordinary visual mutation can cause a `RENDER` broadcast that OpenFL reserves
  for `Stage.invalidate()`.
- [ ] Reference `__setTransformDirty` recursively invalidates descendant world
  transforms, dirties the render ancestry, and lazily rebuilds dirty ancestors
  in root-to-leaf order when a world transform is requested. Flight computes
  world matrices, but the adapter has no equivalent logical dirty propagation
  or update ordering.
- [ ] Reference `__update` derives renderability from visibility, both nonzero
  scales, mask status, and render-parent mask status; it also composes world
  alpha/color transform and inherits normal/null blend mode, shader, and
  scale9 state. The adapter synchronizes local Flight fields only, with no
  compatibility state for those derived/inherited values.
- [ ] Reference alpha assignment maps `NaN` to zero before clamping to `[0, 1]`.
  The adapter range-clamps ordinary numbers but leaves `NaN` unchanged.
- [ ] Reference `null` and `NORMAL` blend modes inherit the render parent's
  world blend mode during update. The adapter normalizes `null` to `NORMAL` and
  assigns it directly to each Flight node, losing that inheritance rule.

### Cache, filters, and exposed object ownership

- [x] `filters` assignment clones each non-null filter, its getter returns a
  fresh array,
  and a nonempty filter list forces the `cacheAsBitmap` getter to `true`.
  `ColorMatrixFilter` is attached as a Flight color adjustment.
- [ ] A null member in a nonempty `filters` array fails when the reference calls
  `clone()`; the adapter silently retains that null slot and skips it when
  synchronizing Flight effects.
- [!] Non-color-matrix display filters cannot affect a node even though their
  Flight descriptors are synchronized. Blocked by **Per-node render-effect
  attachment**.
- [!] `cacheAsBitmap` and `cacheAsBitmapMatrix` retain public state but do not
  create or refresh raster cache pixels. Blocked by **Portable display-object
  rasterization**.
- [ ] The reference clones a matrix on `cacheAsBitmapMatrix` assignment but
  returns its stored matrix directly from the getter. The adapter also clones
  on read, changing post-get mutation/identity behavior.
- [ ] Reference mask/cache/filter/shader/scale9 setters all dirty the
  renderer-dependent state. Several adapter setters retain values without an
  appearance invalidation, so later Flight rendering need not observe the
  mutation at the same boundary.

## `DisplayObjectContainer`

### Child mutation and event ordering

- [x] Child storage is bottom-to-top. Flight child indices include a stable
  offset for the container's own graphics node, so `addChildAt`, swaps, and
  ordinary reorders preserve OpenFL display order.
- [x] Adding a child that already has this parent performs an in-place reorder
  without `REMOVED`/`ADDED` events. Reparenting through another container calls
  the old parent's removal path before inserting into the new parent.
- [x] On staged addition, the child's recursive `stage` reference is populated
  before bubbling `ADDED`; `ADDED_TO_STAGE` follows for the child tree.
- [x] On removal, bubbling `REMOVED` occurs while `parent` and `stage` still
  identify the old tree; `REMOVED_FROM_STAGE` is sent before recursive stage
  references are cleared and before `parent` becomes null.
- [ ] Reference descendant broadcast reuses one event object, rewrites its
  target for each child, and stops traversal when dispatch is canceled. Adapter
  `__dispatchChildren` allocates a new base `Event` per direct child and ignores
  the dispatch result, changing event identity, subclass payload, and
  cancellation behavior for `ADDED_TO_STAGE` and `REMOVED_FROM_STAGE`.
- [ ] Removing the exact object held by `stage.focus` clears focus before the
  removal events. The adapter leaves a detached object focused.
- [x] `removeChildren(begin, end)` validates the range and repeatedly removes
  at `begin`, so removal events occur in original ascending child order.
- [ ] OpenFL 9.5.2 accepts `setChildIndex(child, numChildren)` and inserts at
  the top after removing the child. The adapter rejects `index >= numChildren`.
- [x] Null/self/stage/invalid-index addition cases are rejected,
  `contains(this)` is true, and name lookup returns the first bottommost match.
- [ ] The adapter adds a recursive-containment `#2024` guard, while the actual
  OpenFL 9.5.2 `addChildAt` source only guards self and Stage. This is safer but
  not source-equivalent behavior for an ancestor-cycle attempt.

### Bounds and interactive selection

- [ ] Logical container bounds include masks and skip a child only when both
  scales are zero; render/filter bounds skip masks and a child when either
  scale is zero. The adapter has no logical/render distinction and does not
  reproduce these scale/mask exclusions.
- [ ] `getObjectsUnderPoint` is produced by the reference's reverse visual hit
  walk and returned in display order, including recursive hits while respecting
  masks, clips, visibility, and precise-vs-bounds behavior. The adapter does a
  separate recursive collection and misses the mask contracts, so ordering and
  membership are not yet fully equivalent.
- [ ] Reference interactive hit testing builds a root-to-target stack in
  reverse visual order, respects `mouseEnabled` and `mouseChildren` during the
  walk, and collapses a child hit to its container when `mouseChildren` is
  false. The adapter first collects geometric hits and reconstructs a target in
  `Stage`, which does not preserve all stack-selection rules.
- [x] Stage-reference propagation and per-frame `__enterFrame` traversal visit
  descendants in ascending child order.

## `Stage`

### Frame, invalidation, and broadcast lifecycle

- [x] The adapter broadcasts `ENTER_FRAME`, `FRAME_CONSTRUCTED`, and
  `EXIT_FRAME` in that order, then advances descendants, matching the reference
  frame phase order.
- [ ] Reference `invalidate()` sets both invalidation and render dirtiness;
  a render pass clears invalidation before broadcasting `RENDER`, and a
  listener may invalidate the next pass. The broadcast is gated by an actual
  `shouldRender` decision. Adapter `invalidate()` sets only its flag and
  broadcasts on the next `__advanceFrame` regardless of renderability, while
  unrelated display dirtiness also sets the flag, conflating two lifecycles.
- [ ] Reference broadcast dispatch reuses the supplied event and walks the live
  broadcast-listener registry. The adapter copies the dispatcher array and
  creates a new base event per receiver, changing identity, subclass fields,
  and listener-mutation behavior.
- [!] Listener exceptions are not routed through `UncaughtErrorEvents` because
  adapter `__handleError` is empty and ordinary dispatch propagates to its
  caller. Blocked by **Application event-error boundary**.
- [!] Flight has no per-node callback at the point OpenFL automatically invokes
  renderer-backed `RenderEvent` listeners. Blocked by **Custom render-event
  lifecycle**.

### Focus and keyboard

- [x] Direct focus changes store the new focus before bubbling `FOCUS_OUT` from
  the old object and then `FOCUS_IN` from the new object, with reciprocal
  `relatedObject` values.
- [ ] The reference retains a cached focus for host activate/deactivate and
  dispatches focus events through an explicitly built interactive stack. The
  adapter has no cache/activation restoration and relies on general event
  bubbling.
- [ ] Mouse-driven focus first sends cancellable `MOUSE_FOCUS_CHANGE` and obeys
  `allowMouseFocus`; Tab navigation sends cancellable `KEY_FOCUS_CHANGE`. The
  adapter never performs either focus transition.
- [ ] Reference key handling flushes pending mouse motion, publishes modifier
  state, targets focus-or-stage through a capture stack, honors host
  cancellation, synthesizes focused button clicks for Space/Enter, performs
  explicit/tab-index traversal with Shift wrapping, and maps editing shortcuts.
  Adapter handling only constructs and dispatches `KEY_DOWN`/`KEY_UP`.

### Pointer, drag, resize, and window state

- [ ] Reference pointer dispatch derives one hit stack, preserves related
  targets, and orders `MOUSE_OUT`, ancestor `ROLL_OUT`, ancestor `ROLL_OVER`,
  then `MOUSE_OVER`. It tracks each mouse button's down target, synthesizes
  click/right/middle/double-click or `RELEASE_OUTSIDE`, and honors wheel/default
  cancellation. Adapter handling emits only the incoming down/move/up event at
  a reconstructed target.
- [ ] `MouseEvent.updateAfterEvent()` triggers `__renderAfterEvent`, and cursor
  selection walks the active hit stack/down target. Both adapter hooks are
  absent; wheel and leave-window input are also not registered.
- [!] Per-object `doubleClickEnabled`, context-menu metadata, and soft-keyboard
  hit metadata cannot be represented on Flight nodes. Blocked by **Per-object
  interaction metadata**.
- [ ] Reference dragging normalizes negative bounds, computes lock-center or
  parent-space pointer offsets, updates on pointer movement, clamps position,
  ignores the dragged object while computing `dropTarget`, and stops the global
  drag regardless of the caller. The adapter only stores object/bounds and
  conditionally clears them; it never moves or updates `dropTarget`.
- [ ] Resize derives a stage display matrix from window scale, `scaleMode`,
  `align`, full-screen source rect, and HDPI, updates backend sizes, and emits
  `RESIZE` for logical-size change. Adapter logical resize only changes Flight
  scene dimensions and dispatches `RESIZE`; `scaleMode`/`align` do not affect a
  transform.
- [ ] `fullScreenSourceRect` changes immediately run resize; host fullscreen
  callbacks synchronize `displayState` and emit `FullScreenEvent`. Adapter
  clones/stores the rectangle and can request window fullscreen, but has no
  callback/event synchronization.
- [ ] Reference `frameRate` delegates to the host window and `quality` changes
  renderer smoothing. Adapter properties are state-only and do not affect
  Flight scheduling or sampling.
- [x] Stage transform/position/size setters remain immutable or throw the
  expected `IllegalOperationError` for prohibited interactive properties.

## `Graphics`

### Recording, dirtiness, bounds, and readback

- [x] Supported style and geometry calls append to Flight's flat Shape command
  stream in call order with no redundant-command deduplication; style changes
  therefore affect only following geometry.
- [x] The implicit pen starts at `(0, 0)`, geometry updates it, and `clear()`
  resets pen, fill state, paths, retained bitmap paints, and recorded commands.
  `copyFrom()` copies the command/path state and current pen into the receiver.
- [ ] OpenFL `moveTo` and non-geometry style/state commands append without
  setting Graphics `__dirty`; later geometry is what dirties the owner. The
  adapter invalidates its owner for these calls, which can also cause an extra
  `RENDER` event through `DisplayObject.__setRenderDirty`.
- [ ] Reference Graphics tracks `__visible`: `clear()` resets it, bitmap fills
  and drawn primitives set it, and solid/gradient fills set it only if alpha is
  nonzero. The adapter has no equivalent Graphics visibility state and
  `copyFrom()` therefore cannot copy it.
- [ ] Reference gradient styles synthesize all-one alphas and evenly spaced
  ratios when those arrays are null, and reject arrays shorter than `colors`.
  The adapter passes null or mismatched arrays directly to Flight; defaulting,
  rejection, and mutation ownership therefore need parity work.
- [ ] A null bitmap fill/style is still recorded in the reference command
  stream (and a bitmap fill marks Graphics visible). The adapter returns before
  recording when it cannot create a Flight texture.
- [ ] Reference bounds are accumulated as commands arrive, including quadratic
  and cubic extrema, signed dimensions, stroke thickness, joins, caps, miter,
  and transformed coordinates. The adapter asks Flight for path bounds and
  adds coarse stroke/line expansion; exact extrema and stroke cases remain
  unverified and some manual line padding is asymmetric.
- [x] Precise shape hit testing is requested only for HTML5 or Lime-CFFI-like
  configurations; other targets deliberately fall back through Flight's bounds
  mode, matching the reference target split.
- [ ] Reference renderer update derives a scaled raster size, caps it to the
  backend maximum, pixel-snaps world placement, and separately clears software
  and hardware dirtiness after consumption. Flight owns vector rendering, but
  the adapter has no equivalent cache-size or dirty-acknowledgement state.
- [ ] `readGraphicsData(true)` recursively flattens the owner's child display
  tree after its own data. Adapter readback ignores `recurse`, and it omits or
  cannot reconstruct line bitmap/gradient styles, triangles, quads, shader
  fills, matrix overrides, and blend overrides.
- [ ] Reference command storage retains object/array arguments shallowly (with
  selected caller-side matrix clones), so later input mutation can affect
  readback. Flight conversion copies some color/ratio arrays and matrices,
  changing aliasing and identity behavior.
- [!] `beginShaderFill` records nothing in the adapter. Blocked by **Graphics
  shader paints**.
- [!] `overrideBlendMode` changes the whole Flight Shape to the last supported
  mode instead of recording transitions between commands. Blocked by
  **Graphics command-level blend modes**.

### `DrawCommandBuffer` and `DrawCommandReader`

- [x] OpenFL performs no command deduplication, and the Flight Shape command
  stream likewise retains every supported call in original order.
- [x] Bounds are a `Graphics` responsibility in the reference, not a
  `DrawCommandBuffer`/reader responsibility. The adapter likewise derives
  bounds from its Flight Path rather than mutating bounds while reading the
  Shape command stream.
- [ ] Reference storage consists of a canonical type stream plus parallel
  bool/int/float/object/nested-array streams. A reader advances those streams
  according to the previously consumed or skipped command and exposes
  lightweight views. The adapter has no compatible buffer/reader types; its
  `[name, argumentCount, arguments...]` Flight stream is only consumed by
  `Graphics.readGraphicsData`.
- [ ] Appending into an empty reference buffer aliases all backing arrays and
  marks both buffers copy-on-write; the first later write detaches every array.
  `copy()` uses this path. Nonempty append replays typed commands, but its
  switch omits `OVERRIDE_BLEND_MODE`, so that one record is silently dropped.
  Flight command copying does not expose or test this ownership/drop contract.
- [ ] Reference copies are shallow for bitmaps, matrices, vectors, and nested
  gradient arrays stored as command arguments. The adapter clones retained
  bitmap-fill matrices and relies on Flight's command copy semantics for the
  rest, so mutation-after-copy parity is unclear.
- [ ] Reader views are tied to mutable cursor positions rather than copied value
  objects; callers must read or `skip()` exactly once per type. `reset()` zeros
  positions but leaves `prev` unchanged, so a reset after reading has a
  previous-command advance edge case. No adapter equivalent exercises these
  ordering semantics.
- [ ] The Flight stream does not preserve all reference-only records:
  `BEGIN_SHADER_FILL`, command-level `OVERRIDE_BLEND_MODE`, `OVERRIDE_MATRIX`,
  and the full typed representations of quads/triangles and line paints cannot
  round-trip through the adapter reader.

## `BitmapData`

### Storage, pixels, and lifetime

- [x] Construction normalizes dimensions, forces opaque alpha to `0xFF`, and
  discards RGB when a transparent fill has zero alpha. Public pixels remain
  straight ARGB while Flight storage is converted to/from premultiplied RGBA.
- [x] `setPixel` preserves destination alpha; `setPixel32` respects supplied
  alpha unless the bitmap is opaque. Out-of-bounds reads return zero and writes
  are ignored.
- [x] `dispose()` clears readable/valid state, dimensions, rectangle, bitmap,
  image, and cached texture references. Later adapter operations consistently
  guard disposed storage.
- [x] `lock()` and `unlock()` are intentional no-ops: OpenFL 9.5.2 only gives
  them batching behavior on AIR/Flash, not on this target.
- [x] `setPixels` preflights the complete byte length and throws error 2030
  before writing when short. OpenFL passes a pointer at the current position
  without advancing the `ByteArray`; the adapter's read-and-restore path
  preserves that same final position.
- [x] `compare` preserves sentinel ordering (`0`, `-1`, `-2`, `-3`, `-4`) and
  opaque absolute RGB-difference pixels.
- [ ] For an alpha-only difference, the reference assigns
  `sourceAlpha - otherAlpha` directly to the eight-bit alpha channel; the
  adapter uses an absolute difference. The current fixture covers only the
  positive subtraction direction, so swapping the operands exposes a mismatch.

### Region operations and drawing

- [ ] `copyPixels` supports basic clipping, alpha masks, and `mergeAlpha`, but
  exact self-overlap and mask-intersection behavior is unclear. In particular,
  the adapter can write a transparent source where the reference skips pixels
  outside the alpha bitmap's intersection.
- [x] Drawing another `BitmapData` applies matrix resampling, optional color
  transform, clipping, and supported blend composition through Flight bitmap
  operations.
- [!] Drawing a `DisplayObject` has a bitmap-only tree flattener and a
  Lime-Cairo-specific Flight path, but the portable path cannot reproduce the
  reference's temporary visibility override, render update, inverse
  world/color/alpha composition, scroll clipping, and arbitrary subtree
  rasterization. Blocked by **Portable display-object rasterization**.
- [x] `threshold` masks packed ARGB before applying all six comparison
  operators, supports `copySource`, clips the region, and reports the changed
  pixel count.
- [x] An invalid `threshold` operation returns zero in both OpenFL/Lime and the
  adapter rather than throwing the error described in the public documentation.
- [ ] Exact self-source overlap and out-of-range `threshold` edge behavior need
  a focused capture; the adapter snapshots source and destination into separate
  Flight bitmaps before applying the operation.
- [ ] Reference `getColorBoundsRect` normalizes alpha in `color` when an opaque
  bitmap or alpha-bearing mask makes zero-alpha RGB unobservable. Adapter sends
  raw mask/color values to Flight and can return different bounds.

### Procedural pixels and texture invalidation

- [ ] `noise` uses OpenFL's exact one-warm-up LCG and a specific per-pixel,
  per-selected-channel sample order; grayscale shares one RGB sample and alpha
  defaults to 255. Flight noise is deterministic but uses a different stream,
  including a separately seeded alpha bitmap, so seeded pixels are not parity.
- [ ] `perlinNoise` delegates to different implementations. Both ignore
  `fractalNoise`, offsets, and selected alpha in OpenFL 9.5.2-compatible ways,
  but exact seeded pixels, octave persistence, and stitch behavior are not
  established as equal.
- [x] Reference `getTexture` caches for the current Context3D and reuploads only
  when `image.version` exceeds `__textureVersion`. The adapter binds its cached
  texture to the same mutable Flight Bitmap; every Flight mutation bumps the
  bitmap's version and the Flight GL realization cache reuploads on version
  change, preserving the lazy texture-invalidation handshake.
- [ ] Reference texture upload may first flush a Cairo surface and create a
  premultiplied or power-of-two clone. Flight owns format conversion at its
  texture resolver instead; exact dimensions/format behavior for those build
  flags has not been captured.
- [!] Synchronous `fromBase64`, `fromBytes`, and `fromFile` decoding cannot be
  implemented over Flight's Promise-only codec surface. Blocked by
  **Synchronous BitmapData image construction**.
- [!] Cairo surface conversion and OpenFL quad/scale9 Stage3D cache buffers have
  no matching public Flight types. Blocked by **BitmapData platform and Stage3D
  cache types**.
- [!] Full OpenFL filter composition, full 32-bit cross-channel palette-map
  summation, and JPEG XR encoding are not representable by the current Flight
  adapters. Blocked by **Remaining BitmapData semantic adapters**.

## `SimpleButton`

- [x] Defaults are `enabled = true`, `trackAsMenu = false`, and
  `useHandCursor = true`; absent up/hit states become empty `DisplayObject`
  instances while over/down may remain null. Current state initially points to
  up state.
- [x] Only the current visual state contributes bounds and rendering. State
  objects are render children rather than public display-list children; making
  one current detaches it from any ordinary parent, propagates stage state, and
  replaces the prior Flight visual.
- [x] Replacing a state immediately changes the current state only when the
  current state was the old value. Current and detached hit-state stage and
  transform propagation are handled separately.
- [x] State transitions match the internal listener order: enabled mouse-down
  selects down; mouse-out clears ignore and selects up; mouse-over during a
  pressed button sets ignore; ordinary enabled over selects over; mouse-up
  clears ignore and chooses over only when still over, otherwise up.
- [x] `enabled` suppresses the internal visual/cursor transition logic but does
  not disable event listeners; callers still need `mouseEnabled = false` to
  suppress interaction delivery, as in the reference.
- [ ] When `hitTestState` is null, OpenFL falls back to the current visual for
  hit testing. Adapter `__hitTest` returns false immediately.
- [!] A detached transformed `hitTestState` cannot be evaluated in the button's
  local render-parent space with current Flight hit-area semantics. Blocked by
  **Detached button hit-state transforms**.
- [ ] Reference button hit testing also gates visibility, mask status, the
  button's mask, and `mouseEnabled`, then rewrites a hit-state stack entry back
  to the button. Adapter hit testing inherits the generic missing mask/stack
  behavior.
- [!] Direct mutation of `enabled` or `useHandCursor` cannot update the Flight
  cursor until pointer activity runs the adapter synchronizer. Blocked by
  **Immediate cursor-property synchronization**.
- [!] `trackAsMenu` is retained but has no menu-style release interaction.
  Blocked by **SimpleButton menu tracking**.
- [!] `soundTransform` is defensively copied on set/get, but state transition
  sounds are not bound. Blocked by **SimpleButton sounds**.
- [ ] SimpleButton installs Flight pointer signals while `Stage` separately
  translates Lime pointer input into OpenFL events. Until a single authoritative
  route is established, transition timing and duplicate delivery need an
  end-to-end host fixture.

## Renderer-owned side effects noted, not adopted

The OpenFL renderer-specific files were not treated as an implementation path,
because Flight is the sole rendering substrate. Their mutations still define
observable internal boundaries worth preserving:

- [x] The adapter deliberately has no live Canvas/Cairo/DOM/Context3D display
  walk; display properties, shapes, textures, labels, and child order are sent
  directly to Flight nodes.
- [ ] OpenFL renderers clear child/container `__renderDirty` after traversal and
  clear Graphics software/hardware dirtiness only after the corresponding
  cache consumes commands. Adapter invalidation has no equivalent acknowledged
  state, which contributes to its Stage invalidation conflation.
- [ ] OpenFL cache-bitmap renderers short-circuit normal subtree drawing, keep
  cached bitmap stage state synchronized, and combine mask clipping with cache
  clipping. The adapter retains the properties without those side effects.
- [x] Bitmap renderers remember an observed image version before refreshing
  pixels. Flight owns the analogous source-version cache: adapter mutations
  increment `Bitmap.version`, and Flight's GL texture cache compares that value
  before upload.
- [ ] DOM shape rendering temporarily substitutes Graphics render transforms
  and acknowledges transform dirtiness after drawing. Flight computes its own
  world transforms, but no compatibility hook exposes that before/after
  lifecycle.

## Highest-value fixture gaps

- [ ] Capture `Stage.invalidate()` versus ordinary property/Graphics mutation,
  including reinvalidation from a `RENDER` listener and shared broadcast-event
  identity.
- [ ] Capture removal of the focused child, descendant
  `REMOVED_FROM_STAGE` cancellation/identity, and the accepted
  `setChildIndex(child, numChildren)` endpoint.
- [ ] Capture reversed alpha-only `compare`, overlapping/self `copyPixels`,
  alpha-mask intersection, color-bounds alpha normalization, and texture
  dimension/format behavior under power-of-two build flags.
- [ ] Capture seeded `noise` and `perlinNoise` pixel hashes, precise curve/stroke
  bounds, and mutation-after-`Graphics.copyFrom` command ownership.
- [ ] Add an end-to-end host pointer fixture covering roll ordering, synthesized
  click/release-outside/double-click, focus change cancellation, drag bounds,
  drop target, SimpleButton state timing, and duplicate event delivery.
