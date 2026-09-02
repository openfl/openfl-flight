# TODO Inventory

Reconciliation was repeated after the filesystem round and the Context3D
public-surface audit. The canonical sweep,
`grep -rn "// TODO" src/openfl/ --include="*.hx"`, finds 39 entries. A broader
`TODO` sweep finds three additional spellings, included here so the inventory
covers all 42 remaining markers:

- `src/openfl/geom/Matrix3D.hx:930` uses `TODO:` inside a block comment.
- `src/openfl/net/DatagramSocket.hx:161` uses `//TODO` without a space.
- `src/openfl/text/StyleSheet.hx:250` uses `TODO` in commented code.

The 22 Context3D command markers are now classified directly in source and in
`agents/flight-gaps.md`, and Stage3D's two request markers became an explicit
asynchronous failure adapter. The filesystem round removed another 20 resolved
or explicitly classified markers. None remain in this literal TODO inventory.

## Counts

| Category | Count |
| --- | ---: |
| implemented | 1 |
| blocked:GL-draw-seam | 5 |
| blocked:binding-regen | 0 |
| blocked:flight-gap | 14 |
| adapter-todo | 11 |
| optimization | 3 |
| intentional-stub | 8 |
| **Total** | **42** |

## implemented

This comment describes work that is already complete and should be removed.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/text/Font.hx:289` | 1 | The source guard and initialization path are implemented; the inherited Lime question is stale. |

## blocked:GL-draw-seam

These require the raw Context3D command model described by **Raw Context3D
command model** in `agents/flight-gaps.md`, plus the related texture/resource
bridge entries where noted.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/display3D/textures/RectangleTexture.hx:35,40` | 2 | Byte and typed-array uploads have no public Context3D texture-upload seam. |
| `src/openfl/display/OpenGLRenderer.hx:55` | 1 | The legacy renderer cannot translate into an active Context3D backend until the draw seam exists. |
| `src/openfl/display/BitmapData.hx:495,522` | 2 | Index- and vertex-buffer cache exposure requires the Stage3D geometry bridge recorded under **BitmapData platform and Stage3D cache types**. |

## blocked:binding-regen

No remaining marker is blocked solely on regenerating an already-landed Flight
binding.

## blocked:flight-gap

Each row cites the corresponding named entry in `agents/flight-gaps.md`.

| Location | Count | Flight gap |
| --- | ---: | --- |
| `src/openfl/desktop/NativeProcess.hx:602` | 1 | **Object wire formats** — AMF0/AMF3 serialization is unavailable. |
| `src/openfl/display/DisplayObjectRenderer.hx:73` | 1 | **Portable display-object rasterization** — Flight cannot portably render an arbitrary OpenFL drawable through this compatibility renderer. |
| `src/openfl/display/ShaderInput.hx:10,169` | 2 | **OpenFL shader execution model** — arbitrary GLSL/Pixel Bender inputs have no Flight execution bridge. |
| `src/openfl/media/Sound.hx:106` | 1 | **Synchronous audio file factories** — Flight decoding is promise-based and cannot satisfy `Sound.fromFile()` synchronously. |
| `src/openfl/utils/Assets.hx:297,302` | 2 | **Dynamic PCM sample streaming** — Flight exposes complete decoded audio resources, not an incremental streaming source. |
| `src/openfl/profiler/Telemetry.hx:139` | 1 | **Desktop application metadata and shell capabilities** — the AIR metadata needed by telemetry initialization is unavailable. |
| `src/openfl/display/BitmapData.hx:429,436,456,463` | 4 | **Synchronous BitmapData image construction** — Flight's public image decoding/resource pipeline is asynchronous and has no Lime-image handle bridge. |
| `src/openfl/display/BitmapData.hx:503` | 1 | **BitmapData platform and Stage3D cache types** — Flight raster surfaces are not compatible with Lime's `CairoImageSurface`. |
| `src/openfl/text/StyleSheet.hx:250` | 1 | **StyleSheet CSS parsing** — the commented CSS `display` path needs stylesheet/layout semantics Flight does not expose. |

## adapter-todo

These are implementable adapter work or unresolved adapter design.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/Vector.hx:640,652` | 2 | Reconcile `unshift()`'s declared return type with the documented new-length result for both Haxe overload branches. |
| `src/openfl/display/Application.hx:76,233` | 2 | Connect the OpenFL application/display root and clear adapter-owned Flight singleton state on exit. |
| `src/openfl/display/NativeWindow.hx:1134,1150` | 2 | Refine application activate/deactivate dispatch across focus transitions between this application's windows. |
| `src/openfl/external/ExternalInterface.hx:162,296` | 2 | Wire browser callback registration and host object-ID lookup where the current host exposes them. |
| `src/openfl/geom/Transform.hx:207` | 1 | Move color-transform synchronization to the appropriate display-object adapter boundary. |
| `src/openfl/display/Tileset.hx:76` | 1 | Add an adapter helper/API for generating uniform tile rectangles with margin and spacing. |
| `src/openfl/geom/Matrix3D.hx:930` | 1 | Correct `pointAt()` and normalize its degenerate-input behavior. |

## optimization

These are performance or maintenance improvements; current behavior is
otherwise functional.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/display/Tile.hx:520,940` | 2 | Avoid the runtime type check and clarify/reduce Rectangle pooling/allocation. |
| `src/openfl/net/DatagramSocket.hx:161` | 1 | Reduce temporary host/address allocation during bind. |

## intentional-stub

These are retained compatibility surfaces for backend-specific or unsupported
platform behavior rather than active implementation promises.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/display/CairoRenderer.hx:33` | 1 | Legacy Cairo transform hook; Flight uses its own renderer. |
| `src/openfl/display/CanvasRenderer.hx:37,43` | 2 | Legacy Canvas smoothing/transform hooks; Flight uses its own renderer. |
| `src/openfl/display/DOMRenderer.hx:44,49` | 2 | Legacy DOM style hooks retained for API compatibility, not the Flight scene path. |
| `src/openfl/display/DisplayObjectRenderer.hx:51` | 1 | There is no legacy active renderer to clear in the retained Flight scene graph. |
| `src/openfl/display/Window.hx:223` | 1 | Flash display-root attachment is intentionally absent from non-Flash Flight hosts. |
| `src/openfl/utils/Assets.hx:439` | 1 | The Flash-only asset-binding branch intentionally retains its platform behavior. |
