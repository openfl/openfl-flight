# Flight Gaps

Upstream flight-hx capabilities needed for OpenFL parity that are missing,
incomplete, or unclear. Each entry describes what OpenFL needs and what Flight
currently provides (or doesn't).

## Confirmed Gaps

- **SimpleButton menu tracking**: Flight has no menu-release interaction model
  corresponding to OpenFL's `trackAsMenu` behavior.

- **SimpleButton sounds**: Flight has no binding for the embedded button sounds
  controlled by OpenFL button states and `soundTransform`.

- **Detached button hit-state transforms**: A detached transformed
  `hitTestState` node is evaluated in its own Flight world space, so it cannot
  fully reproduce OpenFL's button-local hit-test coordinates.

- **Immediate cursor-property synchronization**: Plain OpenFL cursor fields do
  not expose a mutation hook; Flight cursor state can only be refreshed when
  pointer activity is observed.

- **Per-object interaction metadata**: Flight does not expose per-node
  equivalents for OpenFL's `doubleClickEnabled`, context-menu metadata, or
  soft-keyboard input area.

- **Raw Context3D command model**: Flight has no public immediate-mode API that
  maps OpenFL's AGAL programs and registers, separate vertex/index buffers, GPU
  state setters, draw calls, and `present()` lifecycle.

- **Context3D texture bridges**: Flight has no adapter for compressed ATF,
  `ByteArray`/typed-array uploads, arbitrary mip levels, render-target textures,
  or `VideoTexture`. BitmapData uploads at the base mip are supported.

## Suspected Gaps

- **Event system bridging**: OpenFL's capture/target/bubble event model is kept
  as-is (not bridged to Flight signals). If Flight's interaction model should
  eventually replace this, the signal-to-event adapter needs design work.

- **Text metrics in interp/headless mode**: OpenFL's TextField.textWidth/textHeight
  depend on font measurement. Flight's TextLayout may require a renderer context.

## Resolved

(Entries move here when flight-hx ships the fix or the gap turns out to be a
misunderstanding of the API.)
