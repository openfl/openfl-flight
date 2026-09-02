# TODO Inventory

Snapshot taken at `5d7f11d` before the follow-up cleanup commits in this
assignment. The requested canonical sweep,
`grep -rn "// TODO" src/openfl/ --include="*.hx"`, finds 110 entries. A broader
`TODO` sweep finds three additional spellings, which are included below so the
inventory is comprehensive:

- `src/openfl/geom/Matrix3D.hx:930` uses `TODO:` inside a block comment.
- `src/openfl/net/DatagramSocket.hx:161` uses `//TODO` without a space.
- `src/openfl/text/StyleSheet.hx:250` uses an indented `TODO` in commented code.

`File.hx`, `BitmapData.hx`, and `Assets.hx` are also being audited in parallel.
Their entries describe this snapshot rather than predicting the peer changes
that may land later.

## Counts

| Category | Count |
| --- | ---: |
| implemented | 3 |
| blocked:GL-draw-seam | 31 |
| blocked:binding-regen | 0 |
| blocked:flight-gap | 21 |
| adapter-todo | 33 |
| optimization | 12 |
| intentional-stub | 13 |
| **Total** | **113** |

## implemented

These comments describe work that is already complete or obsolete and should
be removed.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/events/FullScreenEvent.hx:85` | 1 | `fullScreen` and `interactive` are already stored; the old question about a separate `activating` value is stale. |
| `src/openfl/text/Font.hx:289` | 1 | The source guard and initialization path are implemented; the inherited Lime question is stale. |
| `src/openfl/utils/Assets.hx:702` | 1 | The repository uses Lime 8.3.2, newer than the referenced 8.2.0 release boundary. |

## blocked:GL-draw-seam

These require the raw Context3D command model described by **Raw Context3D
command model** in `agents/flight-gaps.md` (and, for texture uploads, the
related **Context3D texture bridges** entry).

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/display3D/Context3D.hx:59,67,107,112,117,122,127,132,137,142,147,153,158,163,168,173,178,183,190,195,200,205` | 22 | Render-target clear/configuration, resource disposal/readback, draw/present, GPU state, program/constants, render-target, sampler, scissor/stencil, texture, and vertex-buffer binding all need a public immediate-mode draw seam. |
| `src/openfl/display3D/textures/RectangleTexture.hx:35,40` | 2 | Raw byte and typed-array uploads have no public Context3D texture upload seam. |
| `src/openfl/display/Stage3D.hx:54,65` | 2 | Context creation and binding require a public Flight graphics-context seam. |
| `src/openfl/display/OpenGLRenderer.hx:55` | 1 | The legacy renderer cannot translate into an active Context3D backend until the draw seam exists. |
| `src/openfl/display/BitmapData.hx:457,477,490,496` | 4 | GPU texture readback plus Context3D index-buffer, texture, and vertex-buffer exposure require the same raw resource seam. |

## blocked:binding-regen

No remaining TODO in this snapshot is blocked solely on regeneration of an
already-landed Flight API. Known binding-regeneration gaps exist elsewhere in
the adapter, but none of their current source markers match this TODO sweep.

## blocked:flight-gap

Each row cites the corresponding named entry in `agents/flight-gaps.md`.

| Location | Count | Flight gap |
| --- | ---: | --- |
| `src/openfl/desktop/NativeProcess.hx:602` | 1 | **Object wire formats** — AMF0/AMF3 serialization is unavailable. |
| `src/openfl/display/DisplayObjectRenderer.hx:69` | 1 | **Portable display-object rasterization** — Flight cannot portably render an arbitrary OpenFL drawable through this compatibility renderer. |
| `src/openfl/display/ShaderData.hx:7`; `ShaderJob.hx:7`; `ShaderParameter.hx:36,41,46`; `ShaderInput.hx:10,169` | 7 | **OpenFL shader execution model** — arbitrary GLSL/Pixel Bender programs, inputs, parameters, buffers, and standalone jobs have no Flight execution bridge. |
| `src/openfl/filesystem/FileStream.hx:726,1493` | 2 | **Object wire formats** — AMF file decoding and encoding are unavailable. |
| `src/openfl/media/Sound.hx:106` | 1 | **Synchronous audio file factories** — Flight decoding is promise-based and cannot satisfy `Sound.fromFile()` synchronously. |
| `src/openfl/net/FileReference.hx:110,195` | 2 | **FileReference network transfers and cancellation** — combined download/save and multipart upload workflows are missing. |
| `src/openfl/net/SharedObject.hx:78,149,155` | 3 | **SharedObject quota prompts and remote synchronization** — Flight has no remote shared-object protocol. |
| `src/openfl/net/Socket.hx:751,1025` | 2 | **Object wire formats** — AMF socket decoding and encoding are unavailable. |
| `src/openfl/profiler/Telemetry.hx:139` | 1 | **Desktop application metadata and shell capabilities** — the AIR metadata needed by telemetry initialization is unavailable. |
| `src/openfl/text/StyleSheet.hx:250` | 1 | **StyleSheet CSS parsing** — the commented CSS `display` path needs stylesheet/layout semantics Flight does not expose. |

## adapter-todo

These are implementable adapter work or unresolved adapter design. Event-bridge
items stay here because **Event system bridging** is cataloged only as a
suspected gap, not a confirmed Flight capability gap.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/Lib.hx:166,763` | 2 | Add Array/Map qualified-name handling and return the active OpenFL application. |
| `src/openfl/Vector.hx:640,652` | 2 | Reconcile `unshift()`'s declared return type with the documented new-length result for both Haxe overload branches. |
| `src/openfl/display/Application.hx:69,226` | 2 | Connect the OpenFL application/display root and clear adapter-owned Flight singleton state on exit. |
| `src/openfl/display/BitmapData.hx:420,426,445,451` | 4 | Adapt the public Flight image resource/codec surfaces to the synchronous base64, bytes, file, and platform-image factories, using a compatible fallback where the synchronous contract requires it. |
| `src/openfl/display/NativeWindow.hx:1134,1150` | 2 | Refine application activate/deactivate dispatch across focus transitions between this application's windows. |
| `src/openfl/display/DisplayObjectRenderer.hx:74` | 1 | Define custom render-event dispatch for the compatibility renderer; the broader event bridge is not yet a confirmed gap. |
| `src/openfl/events/EventDispatcher.hx:410` | 1 | Define the listener error boundary without depending on removed private Stage internals. |
| `src/openfl/events/RenderEvent.hx:163` | 1 | Replace the compatibility copy once adapter-owned render-event snapshots exist. |
| `src/openfl/external/ExternalInterface.hx:162,296` | 2 | Wire browser callback registration and host object-ID lookup where the current host exposes them. |
| `src/openfl/filesystem/File.hx:169,306,399,401,1016,1485,2090,2252,2290` | 9 | Wire cache/symlink/usage/charset surfaces exposed by the current host where possible; improve copy error handling, relative paths, Windows hidden metadata, application-directory write protection, and application URL schemes. |
| `src/openfl/filesystem/FileStream.hx:162` | 1 | Replace the zero-length asynchronous-write workaround with explicit buffer state. |
| `src/openfl/geom/Transform.hx:207` | 1 | Move color-transform synchronization to the appropriate display-object adapter boundary. |
| `src/openfl/net/FileReferenceList.hx:132` | 1 | Use Flight's public open-file dialog with `multiple: true`. |
| `src/openfl/display/Tileset.hx:76` | 1 | Add an adapter helper/API for generating uniform tile rectangles with margin and spacing. |
| `src/openfl/utils/Assets.hx:988,994` | 2 | Route diagnostics through the already-public `flight.Log` facade. |
| `src/openfl/geom/Matrix3D.hx:930` | 1 | Correct the existing `pointAt()` implementation and normalize its degenerate-input behavior. |

## optimization

These are performance or maintenance improvements; the current behavior is
otherwise functional.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/events/Event.hx:929` | 1 | Move reflective event string formatting to a compile-time/rest-parameter helper. |
| `src/openfl/display/Tile.hx:516,936` | 2 | Avoid the runtime type check and clarify/reduce Rectangle pooling/allocation. |
| `src/openfl/display/TileContainer.hx:182,426,449,474,497` | 5 | Reduce temporary Rectangle allocation while aggregating child bounds. |
| `src/openfl/filesystem/File.hx:2372` | 1 | Simplify or cache parent-path construction. |
| `src/openfl/utils/Assets.hx:294,298` | 2 | Stream music instead of fully decoding it; the current `getSound()` fallback is correct but less memory-efficient. |
| `src/openfl/net/DatagramSocket.hx:161` | 1 | Reduce temporary host/address allocation during bind. |

## intentional-stub

These are retained compatibility surfaces for backend-specific or unsupported
platform behavior rather than active implementation promises.

| Location | Count | Inventory |
| --- | ---: | --- |
| `src/openfl/display/BitmapData.hx:484` | 1 | A Flight bitmap intentionally exposes no legacy Cairo surface. |
| `src/openfl/display/CairoRenderer.hx:33` | 1 | Legacy Cairo backend transform hook; Flight uses its own renderer. |
| `src/openfl/display/CanvasRenderer.hx:37,43` | 2 | Legacy Canvas backend smoothing/transform hooks; Flight uses its own renderer. |
| `src/openfl/display/DOMRenderer.hx:44,49` | 2 | Legacy DOM style hooks retained for API compatibility, not the Flight scene path. |
| `src/openfl/display/DisplayObjectRenderer.hx:47` | 1 | There is no legacy active renderer to clear in the retained Flight scene graph. |
| `src/openfl/display/Window.hx:223` | 1 | Flash display-root attachment is intentionally absent from non-Flash Flight hosts. |
| `src/openfl/filesystem/File.hx:234,304,379,381` | 4 | AIR/mobile-only downloaded, package, permission-status, and backup-exclusion properties remain omitted compatibility surfaces. |
| `src/openfl/utils/Assets.hx:434` | 1 | The Flash-only asset-binding branch intentionally retains its platform behavior. |
