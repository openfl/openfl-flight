# openfl.display — Rendering Record

Status: Flight scene-graph display objects are active; the legacy
`DisplayObjectRenderer` facade is retained as a compatibility shell.

## Rendering ownership

The adapter does not use OpenFL's Canvas/Cairo/DOM/Context3D renderer walk.
`DisplayObject` creates a Flight `Node2D`, concrete display classes attach
Flight shapes, sprites, textures, or labels to that node, and `Stage` owns the
Flight `Scene2D` root. Public display properties are synchronized directly to
the Flight graph.

A source-wide call-site audit found no construction of `CanvasRenderer`,
`CairoRenderer`, `DOMRenderer`, or `OpenGLRenderer`, and no calls to the private
`DisplayObjectRenderer` methods outside their declarations. `RenderEvent` and
bitmap filters still retain the renderer type in their compatibility signatures,
but do not instantiate it.

## `DisplayObjectRenderer` audit

| Method or state | Status | Current effect |
| --- | --- | --- |
| constructor defaults | Implemented state only | Initializes smoothing, pixel ratio, world alpha, and blend mode for a future facade instance. |
| `__getAlpha()` | Implemented | Multiplies by the renderer world alpha, matching the OpenFL helper. It has no current call site. |
| `__getColorTransform()` | Partial | Returns the supplied transform or the renderer world transform; it does not compose both as OpenFL 9.5.2 does. It has no current call site. |
| `__setBlendMode()` | Implemented state only | Retains the requested mode but does not change a render backend. Live display blending is synchronized directly on Flight nodes. |
| `__shouldCacheHardware()` and `__shouldCacheHardware_DisplayObject()` | Compatibility placeholders | Return the caller's prior decision without inspecting content. Flight cache selection is not routed through this facade. |
| `__clear()` | Stub | No renderer target is cleared. |
| `__pushMask*()` and `__popMask*()` | Stubs | No legacy backend mask stack is maintained. Flight exposes per-node clip regions, which need direct display-property synchronization instead. |
| `__render()` | Stub | No OpenFL drawable-to-renderer dispatch occurs. This is one reason `BitmapData.draw()` cannot currently rasterize a display object. |
| `__renderEvent()` | Stub | Custom `RENDER_CANVAS`, `RENDER_CAIRO`, `RENDER_DOM`, `CLEAR_DOM`, and `RENDER_OPENGL` events are not dispatched. |
| `__resize()` | Stub | No legacy renderer target is resized; `Stage` size changes update the Flight scene directly. |
| `__updateCacheBitmap()` | Stub returning `false` | No renderer-driven bitmap cache is created or refreshed. |

The four renderer subclasses are likewise compatibility shells. Their public
backend handles and a small amount of state are present, but their drawable,
mask, transform, smoothing, and backend blend operations are stubs. Implementing
the base facade alone would therefore not make that renderer hierarchy active.

## Harness visibility

The compatibility harness currently runs state and Flight scene-graph checks
under the Haxe interpreter; it does not create a Canvas, Cairo, DOM, or OpenGL
renderer and does not capture rendered pixels. Consequently, none of the
`DisplayObjectRenderer` stubs changes an existing harness result.

Related public properties can still have observable non-pixel behavior and are
tested independently: property round-trips, bounds, clone semantics, and Flight
node state. Pixel-visible behavior remains absent where it depends on the
legacy renderer path, notably custom render events, display-object
`BitmapData.draw()`, renderer-generated `cacheAsBitmap`, and mask-stack output.

The `display/rendering-composition` fixture captures these boundaries against
OpenFL 9.5.2. `scrollRect` keeps public bounds unchanged while translating the
render coordinate system and clipping visible hit collection; the adapter maps
that behavior to Flight's node transform and `ClipRegion`. `cacheAsBitmap`,
`opaqueBackground`, and filter assignment/readback preserve their public state
semantics. OpenFL's interpreter capture produces no pixels for
`BitmapData.draw(displayObject)`, so the fixture deliberately records the same
empty result without claiming that offscreen rendering is implemented.

## Direction

Rendering work should continue at the Flight scene-graph boundary instead of
reviving the legacy renderer walk:

1. map shape masks to Flight node clip regions (`scrollRect` is already mapped);
2. attach supported filters through Flight node effects or adjustments;
3. use Flight render caches for `cacheAsBitmap` when a public scene render state
   is available;
4. add an explicit Flight offscreen rasterization bridge for `BitmapData.draw()`;
5. define custom-render event behavior separately, because those events expose
   OpenFL backend-specific renderer objects rather than a scene node.
