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

- **General-purpose byte compression**: OpenFL `ByteArray.compress`,
  `uncompress`, `deflate`, and `inflate` require zlib, raw deflate, and LZMA
  codecs over an in-memory byte buffer. Flight 0.4.0 exposes only GPU texture
  compression entry points; it has no public byte-codec API. The adapter uses
  Haxe standard-library fallbacks for zlib and raw deflate while preserving
  OpenFL's in-place length and position semantics, but LZMA remains unavailable.

- **Public UTF-8 byte codec**: OpenFL `ByteArray.readUTFBytes` and
  `writeUTFBytes` require conversion between UTF-8 and raw bytes. Flight 0.4.0
  has portable `_TextEncoder` and `_TextDecoder` helpers only in
  `flight._internal`, with no supported public equivalent. The current
  ByteArray implementation must use `haxe.io.Bytes` instead of Flight for this
  behavior.

- **Object wire formats**: OpenFL `ByteArray.readObject` and `writeObject`
  support AMF0, AMF3, HXSF, and JSON encodings. Flight 0.4.0 exposes no public
  object serialization API. HXSF and JSON currently fall back to Haxe standard
  serializers; AMF0 and AMF3 are explicit no-ops because their OpenFL internal
  readers and writers cannot be carried into this adapter. Flight needs an
  encoding-selectable serializer/deserializer that consumes and returns bytes,
  including the number of bytes read for ByteArray position updates.

- **URLLoader cancellation and early response metadata**: Flight Net requests
  use Flight's configured network backend and accept an abort signal, but Flight
  has no public abort-controller factory that an OpenFL `URLLoader` can own.
  `URLLoader.close()` can suppress stale progress/completion callbacks but
  cannot cancel the active transport. Flight's `NetResponse` also exposes
  status and headers only with the completed body, so OpenFL's earlier
  `httpResponseStatus` timing cannot be reproduced. The adapter preserves final
  status/event ordering through `flight.Net`.

- **Arbitrary batched tile hierarchies**: Flight's native `Tilemap` is a regular
  row/column grid. OpenFL tilemaps accept freely positioned, rotated, scaled,
  nested `Tile`/`TileContainer` nodes with per-tile source rectangles. The
  adapter can preserve those semantics with Flight sprites and display-object
  nodes backed by a Flight texture atlas, but Flight has no equivalent batched
  primitive for that arbitrary hierarchy.

- **OpenFL per-tile shaders**: Flight materials can tint and adjust tile
  appearance, but there is no adapter from an OpenFL `Shader` assigned to a
  `Tile` into a Flight material. The public property is preserved while custom
  shader rendering remains unsupported.

- **Per-channel audio pan and peak metering**: Flight audio channels expose
  gain, time, playback rate, and lifecycle controls, but no direct pan control
  or left/right peak levels. Flight audio buses can pan only through a mixer and
  audio context, which does not map to OpenFL's independently mutable
  `SoundChannel.soundTransform` without additional routing infrastructure.

- **Cross-target synchronous audio loading**: Flight audio decoding and URL
  resolution return promises and require a host `AudioContext`. OpenFL `Sound`
  has synchronous construction/playback entry points and target-independent
  load events, but the adapter has no application audio-context injection point
  in interpreter/headless mode. It retains Flight embedded/external resource
  references immediately; decoding and playable-channel creation remain
  pending on an asynchronous host bridge.

- **Synchronous desktop clipboard reads**: Flight clipboard reads are
  asynchronous, while OpenFL's `Clipboard.getData()` and `hasFormat()` return
  synchronously. Flight also clears the whole clipboard rather than one format
  at a time and does not expose OpenFL-style deferred data handlers. The adapter
  synchronously shadows its own text, HTML, and RTF writes, but cannot reflect
  external clipboard changes until Flight provides synchronous inspection (or
  OpenFL adopts an asynchronous boundary).

- **Native child processes**: Flight 0.4.0's public shell API has no process
  spawn, standard-stream, or exit-status primitive that can back
  `NativeProcess.start()` and its asynchronous IO events.

- **Desktop application metadata and shell capabilities**: Flight exposes the
  authoritative application and window handles needed for lifecycle and window
  operations, but it has no public application-identifier getter or definitive
  capability queries for OpenFL's dock-icon, system-tray-icon, and native-menu
  support flags.

## Suspected Gaps

- **Event system bridging**: OpenFL's capture/target/bubble event model is kept
  as-is (not bridged to Flight signals). If Flight's interaction model should
  eventually replace this, the signal-to-event adapter needs design work.

- **Text metrics in interp/headless mode**: OpenFL's TextField.textWidth/textHeight
  depend on font measurement. Flight's TextLayout may require a renderer context.

## Resolved

(Entries move here when flight-hx ships the fix or the gap turns out to be a
misunderstanding of the API.)

- **System pause and resume**: `NativeApplication` now owns and exposes the
  authoritative Flight `Application` handle internally, so the static `System`
  API can route pause and resume through Flight without constructing a second
  application.
