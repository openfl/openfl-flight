# `openfl.filters` behavioral specification (OpenFL 9.5.2)

This is a source-level behavioral reference for OpenFL 9.5.2, not a gap list or a transcription of Flash documentation. The pinned sources are under `/tmp/tmp.OcIrt2boMR/openfl/src/openfl/filters/`; executable source wins where its API comments disagree. `[x]` means the adapter preserves the contract, `[ ]` means it is absent or different, and `[!]` identifies a contract blocked by the named Flight gap.

Filters have three separately observable layers: their value objects, `BitmapData.applyFilter`, and filtered display rendering. A status on one does not imply the other two. In OpenFL, assigning `DisplayObject.filters` clones the array and every non-null filter, and reading it returns a new array containing those stored filter objects. Public `getBounds()` does not expand for filters; private render/cache bounds do.

## `BitmapFilter`

- [x] Although the comments say it cannot be instantiated or extended, the non-Flash class has a public zero-argument constructor and is not final. It initializes zero edge extensions and shader passes, smooth sampling true, normal shader blend mode, requires a second bitmap, and does not preserve the original object.
- [x] Base `clone()` returns a fresh base `BitmapFilter`; it has no public properties to copy. Its internal bitmap application returns the source unchanged and its shader initializer returns null.
- [x] A DisplayObject stores a clone of each filter on assignment, treats a null or empty array as no filters, returns `[]` when none are stored, and makes `cacheAsBitmap` read true whenever filters are present. Its getter shallow-copies the array but not the stored filter objects, so a filter fetched from one returned array can be mutated before the array is reassigned.
- [ ] A null element in a nonempty OpenFL filter array is dereferenced during cloning and fails. The adapter instead retains null elements, skips them during Flight synchronization, and therefore accepts input that upstream rejects.
- [ ] OpenFL's internal cached-render bounds use each filter's top/right/bottom/left extensions while public geometric bounds remain unchanged. The adapter preserves unexpanded public bounds but has no corresponding internal filter-bound expansion.
- [!] Except for the separately mapped `ColorMatrixFilter`, stored filter descriptors are not attached to live Flight display nodes, so bevel, blur, convolution, displacement, shadow, glow, and shader display effects are not rendered. Blocker: **Per-node render-effect attachment**.

### Common `BitmapData.applyFilter` pipeline

- [ ] OpenFL returns immediately only when the destination is unreadable, the supplied source is null, or the source is unreadable. It then accidentally passes the destination (`this`) as the source to the filter, so the non-null `sourceBitmapData` argument is used only by that initial guard. The adapter adds null guards for sourceRect, destPoint, and filter and correctly filters the supplied source; this deliberately does not preserve the 9.5.2 source-selection bug.
- [ ] A filter that needs a second bitmap receives a transparent destination-sized temporary; otherwise it writes to the receiver. A preserve-object filter also snapshots the receiver, applies its effect, then draws the snapshot over the result. If the filter returns the second temporary, that image replaces the receiver image. OpenFL finally marks/increments image dirtiness even when the selected filter ultimately leaves pixels unchanged. The adapter's direct region operations do not reproduce this allocation, preservation, image-replacement, or no-op versioning pipeline.
- [ ] A null filter passes the upstream readability guards and is then dereferenced, whereas the adapter treats it as a no-op. Null sourceRect or destPoint behavior depends on the selected upstream filter and commonly fails when the private implementation dereferences it.

## `BevelFilter`

- [x] Construction defaults to `(distance=4, angle=45, highlightColor=0xFFFFFF, highlightAlpha=1, shadowColor=0, shadowAlpha=1, blurX=4, blurY=4, strength=1, quality=1, type="inner", knockout=false)`. `clone()` returns a new BevelFilter containing the effective stored values.
- [x] `blurX` and `blurY` clamp to `[0,255]`; both alpha properties clamp to `[0,1]`; `quality` is integer-clamped to `[1,15]`; and `strength` clamps to `[1,255]`. Highlight and shadow colors are unsigned and capped at `0xFFFFFF`. Distance and degree-valued angle are unrestricted.
- [x] `type` retains only exact `"inner"` or `"outer"`; every other value, including null on permissive targets, becomes `"full"`. `knockout` is stored directly.
- [!] Its shader uses degrees for the directional vector, premultiplies each highlight/shadow RGB by its alpha, runs horizontal/vertical blur passes based on rounded `blur*quality/4`, then combines using inner/outer/full and knockout state. The adapter captures the public parameters in a Flight descriptor, but cannot attach that descriptor to the live node. Blocker: **Per-node render-effect attachment**.
- [ ] Internal render extensions are `ceil(blur + directional contribution)` on each side, with the directional contribution suppressed for `inner`. Construction and blur/distance/angle changes recompute them, but changing `type` does not—an upstream stale-bounds quirk. The adapter does not expose these extensions to its cache bounds.
- [ ] `BitmapData.applyFilter` in 9.5.2 executes only a Gaussian blur for a bevel, then preserves/draws the original content; it does not perform the bevel color/combine stage. The adapter returns without changing the destination for BevelFilter.

## `BlurFilter`

- [x] The constructor defaults to `(blurX=4, blurY=4,quality=1)`, retains all three values verbatim without clamping or integer-range normalization, and `clone()` copies them to an independent filter. Every setter also stores its input verbatim.
- [ ] OpenFL calculates horizontal passes as zero for `blurX<=0`, otherwise `round(blurX*quality/4)+1`, likewise vertically, and sums them. A quality change recalculates pass counts; arbitrary negative quality is permitted. The adapter's Flight blur descriptor omits quality and therefore does not retain this pass behavior.
- [ ] Lime bitmap application calls `gaussianBlur` with the raw blur values and quality and may replace the destination image with the returned image. The adapter uses Flight's box blur with rounded half-radii and clamps passes to `[1,3]`, so exact pixels and out-of-range quality behavior are not generally equivalent.
- [ ] Internal padding per positive axis is `ceil(value*max(quality,1)*3)+2` in Lime builds (`ceil(value)+2` otherwise), and zero for nonpositive blur. Source order produces a quirk: blur is initially set while quality is still target-default zero; the later quality setter calls the blur setters with unchanged values, so constructor padding is based on one pass. A quality-only change likewise does not update padding. The adapter does not implement internal filter-bound expansion.
- [!] The adapter builds a Flight blur descriptor from blurX/blurY, but quality is not represented and the descriptor is not attached to display nodes. Blocker: **Per-node render-effect attachment**.

## `ColorMatrixFilter`

- [x] Passing null constructs the row-major 4×5 identity. Any non-null Array, of any length, is retained by reference with no validation. The getter returns a copy, so editing a fetched Array does not mutate the filter; assigning an Array and later editing that original does.
- [x] `clone()` passes the internal Array to the new instance, so clones share the same backing Array even though each public getter returns a copy. Reassigning either filter's `matrix` breaks that sharing.
- [x] Pixel evaluation computes output R/G/B/A from rows beginning at indices `0,5,10,15`, adds offsets at `4,9,14,19`, clamps each result to `[0,255]`, and truncates with `Std.int`. A source pixel with alpha zero is forced to fully transparent black instead of evaluating the matrix.
- [ ] The 9.5.2 Lime source iterates rows from `Std.int(sourceRect.y)` to `Std.int(sourceRect.height)` and columns from `x` to `width`, using an x/y-swapped destination offset expression. The adapter uses a conventional width-by-height extracted region. Normal origin fixtures agree, but nonzero source rectangles do not preserve those executable source quirks.
- [x] A valid 20-element matrix maps to a Flight ColorMatrixAdjustment and is attached as a DisplayObject color adjustment; null resets to identity.
- [ ] Invalid lengths remain valid public state. OpenFL's shader still reads its expected indices from that Array, whereas the adapter deliberately creates no Flight adjustment, so display behavior for malformed matrices differs.
- [x] Color matrices have zero internal bound extension and do not change public bounds.

## `ConvolutionFilter`

- [x] Constructor defaults are `matrixX=0`, `matrixY=0`, `matrix=null`, `divisor=1`, `bias=0`, `preserveAlpha=true`, `clamp=true`, `color=0`, and `alpha=0`. It writes the constructor matrix directly, so null and arbitrary lengths are accepted there; all scalar fields are freely writable and unvalidated.
- [x] Assigning `matrix=null` substitutes `[0,0,0,0,1,0,0,0,0]`. Any non-null assigned Array whose length is not exactly nine throws the string `"Only a 3x3 matrix is supported"`. Getter and setter retain/return the actual backing Array, allowing element mutation without reassignment.
- [x] `clone()` copies scalar values but passes the same matrix reference, so element edits are shared between the original and clone.
- [x] OpenFL's display shader is always a fixed 3×3 sample kernel regardless of `matrixX`/`matrixY`. It sums nine samples, divides only when `divisor>0`, adds bias, optionally replaces result alpha with the center pixel, and clamps output channels. The public `clamp`, `color`, and `alpha` fields are not consumed by that shader.
- [ ] The adapter's Flight descriptor accepts `matrixX*matrixY`, so it does not preserve the fixed-3×3 display behavior. Further, only construction and whole-matrix assignment resynchronize it; later writes to public scalar fields or in-place Array elements leave the descriptor stale.
- [ ] OpenFL does not override the base bitmap-filter operation for convolution, so `BitmapData.applyFilter` effectively leaves the source content. The adapter instead applies convolution when `clamp=true` and parameters are valid, producing an effect where upstream does not.
- [x] Convolution has zero internal edge extension in 9.5.2 and public bounds are unchanged.
- [!] No convolution descriptor reaches a live display node. Blocker: **Per-node render-effect attachment**.

## `DisplacementMapFilter`

- [x] Defaults are `mapBitmap=null`, a newly allocated `(0,0)` `mapPoint`, `componentX=0`, `componentY=0`, `scaleX=0`, `scaleY=0`, `mode=WRAP`, `color=0`, and `alpha=0`. All nine properties retain values without validation or clamping. `mapBitmap` and `mapPoint` getters expose the retained references directly.
- [x] `clone()` shares `mapBitmap`, clones `mapPoint`, and copies all other values. Because the mapPoint setter accepts null, cloning after assigning null dereferences null and fails.
- [x] RED/GREEN/BLUE component values select channel columns 0/1/2; every other value selects alpha. Displacement scales are normalized by `mapBitmap.width` and height, with mapPoint likewise converted to texture-coordinate offsets. Null mapBitmap fails when filtering rather than being treated as a no-op.
- [x] In executable 9.5.2, `mode`, `color`, and `alpha` are retained and dirty rendering but never affect either the Lime displacement call or display shader. The actual edge behavior is therefore not selected by `WRAP`, `CLAMP`, `IGNORE`, or `COLOR` as comments claim.
- [ ] The upstream bitmap call ignores its sourceRect and destPoint when invoking the underlying displacement utility. The adapter does not implement DisplacementMapFilter in `BitmapData.applyFilter` and returns without mutation.
- [x] The filter has zero internal edge extensions and one shader pass; public bounds are unchanged.
- [!] Bitmap-data and display displacement need a bitmap-map adapter and live render-effect attachment. Blockers: **Bitmap-map displacement as a render effect** and **Per-node render-effect attachment**.

## `DropShadowFilter`

- [x] Construction defaults to `(distance=4, angle=45, color=0, alpha=1, blurX=4, blurY=4, strength=1, quality=1, inner=false, knockout=false, hideObject=false)`. Every property is stored verbatim: source comments advertise ranges, but setters do not clamp or normalize. `clone()` copies all effective primitive values.
- [ ] Direction uses degrees and truncates each component: `offsetX=Std.int(distance*cos(angle*π/180))` and similarly for y. Blur pass counts use zero when an axis is nonpositive, otherwise `round(blur*quality/4)+1`; total passes add two for inner or one for outer. The Flight descriptor retains angle/distance/quality rather than these derived, truncation-sensitive values.
- [!] Display rendering optionally inverts alpha for inner shadows, blurs alpha horizontally/vertically, applies color/alpha and final-pass strength, then combines with original content according to `inner`, `knockout`, and `hideObject`. The adapter captures parameters but cannot attach the effect to a live node. Blocker: **Per-node render-effect attachment**.
- [ ] Angle, distance, blurX, and blurY changes recalculate offsets, extensions, and pass counts. Quality and inner setters only store/dirty: they do **not** recalculate pass counts, an executable stale-state quirk. Knockout/hideObject/color/alpha/strength likewise only dirty. Adapter setters instead rebuild a descriptor from all current values.
- [ ] Internal extensions are `ceil(blur + max(±truncatedOffset,0))` per side. They can be negative when blur is sufficiently negative. The adapter does not use these for internal cache bounds.
- [ ] Bitmap application blurs at destPoint plus the directional offset, color-transforms the entire returned image to shadow RGB/alpha, and explicitly does not support inner or knockout; its preserve-object step then draws the original. The adapter does not apply DropShadowFilter to BitmapData.

## `GlowFilter`

- [x] Construction defaults to `(color=0xFF0000, alpha=1, blurX=6, blurY=6, strength=2, quality=1, inner=false, knockout=false)`. Every property remains completely unrestricted despite documented ranges. `clone()` copies the primitive values to a new filter.
- [!] Display rendering optionally inverts alpha for inner glow, performs per-axis alpha blur passes, applies color/alpha and final-pass strength, then combines with original content according to inner/knockout state. The adapter captures parameters but cannot attach the effect to a live node. Blocker: **Per-node render-effect attachment**.
- [ ] Positive-axis internal extension is `ceil(blur*1.5)` symmetrically; nonpositive blur yields zero. Pass counts use zero for nonpositive blur, otherwise `round(blur*quality/4)+1`, plus two combination passes for inner or one otherwise. These derived values are absent from the adapter.
- [ ] Blur setters recompute size and passes. Inner, knockout, and quality changes recalculate passes; color, alpha, and strength only dirty rendering. Adapter setters instead rebuild a descriptor from all current values, so these source update-order effects are not retained.
- [ ] The adapter neither performs the internal bounds expansion nor handles GlowFilter in `BitmapData.applyFilter`. OpenFL's bitmap path Gaussian-blurs and color-transforms but explicitly ignores inner/knockout before preserving the original.

## `GradientBevelFilter` and `GradientGlowFilter`

- [x] Neither class exists in the OpenFL 9.5.2 non-Flash source tree, despite both names appearing in `BitmapFilter` documentation. There is consequently no 9.5.2 constructor, property, clone, bitmap, or display-render contract to reproduce on this target, and the adapter correctly has no implementation. Flash-target builds defer to the platform Flash classes rather than OpenFL source behavior.

## `ShaderFilter`

- [x] `new ShaderFilter(shader)` retains the supplied Shader reference, including null. `blendMode` is a directly writable field initialized to `BlendMode.NORMAL`; shader is also directly writable. Neither assignment automatically marks the filter dirty.
- [x] `topExtension`, `rightExtension`, `bottomExtension`, and `leftExtension` default to zero and store arbitrary signed integers without validation. Their setters likewise do not mark rendering dirty.
- [x] `invalidate()` has no return value and only marks render state dirty; callers must invoke it after modifying shader parameters or other fields when they require a refresh.
- [x] `clone()` shares the Shader reference and copies the four extensions and current blend mode into a new ShaderFilter.
- [x] OpenFL uses exactly one shader pass, returns the retained Shader for that pass, and applies `blendMode` as the shader pass's blend mode. Its internal filtered render bounds expand by the four supplied extensions; public bounds do not.
- [ ] The adapter preserves the value/clone/invalidation surface and creates a Flight shader descriptor. A direct `shader` change is not synchronized into that descriptor until `invalidate()` (or filter reassignment invokes synchronization); `blendMode` has no Flight-descriptor representation. Internal cache bounds are not expanded.
- [ ] `BitmapData.applyFilter` reaches the base no-op because ShaderFilter has no bitmap override in 9.5.2; the adapter also returns without mutation, matching the final pixels.
- [!] ShaderFilter has no live node-render path. Blocker: **Per-node render-effect attachment**.

## Supporting constants

- [x] `BitmapFilterQuality.LOW`, `MEDIUM`, and `HIGH` are exactly `1`, `2`, and `3`.
- [x] `BitmapFilterType.INNER`, `FULL`, and `OUTER` are integer abstract values `0`, `1`, `2` on non-JavaScript targets, with exact string conversions `"inner"`, `"full"`, `"outer"`; OpenFL-JS exposes those strings directly. An unknown string converts to null on non-JS.
- [x] `DisplacementMapFilterMode.WRAP`, `CLAMP`, `IGNORE`, and `COLOR` are the literal strings `"wrap"`, `"clamp"`, `"ignore"`, and `"color"`.
