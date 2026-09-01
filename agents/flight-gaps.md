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

- **Per-node render-effect attachment**: Flight Effects creates typed bevel,
  blur, convolution, shadow, and glow descriptors, but Flight Node exposes only
  color-adjustment attachment and has no public way to associate a
  `RenderEffect` list with an arbitrary Scene2D node. `ColorMatrixFilter` maps
  through Flight color adjustments; the remaining OpenFL display-object filters
  retain synchronized Flight descriptors until a node-level effect hook exists.

- **Bitmap-map displacement as a render effect**: Flight Bitmap can displace a
  pixel region from a bitmap map with selected channels, scales, and edge modes,
  but Flight's render-pipeline `DisplacementEffect` is procedural and accepts no
  bitmap map or channel selection. The adapter retains a Flight bitmap-region
  handle for `DisplacementMapFilter`, but cannot attach that map-driven effect to
  display objects without a corresponding render-effect descriptor.

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

- **SWF-specific loader metadata and sandboxes**: Flight image resource
  references preserve embedded bytes or external URIs and MIME resolution
  state, but they expose no ActionScript or SWF version, nominal SWF frame
  rate, application-domain ownership, security-domain relationship, sandbox
  bridge, or definition-to-loader metadata. `LoaderInfo` retains the Flight
  image reference while using OpenFL-compatible defaults and an adapter-local
  definition registry for those SWF-only surfaces.

- **URLLoader cancellation and early response metadata**: Flight Net requests
  use Flight's configured network backend and accept an abort signal, but Flight
  has no public abort-controller factory that an OpenFL `URLLoader` can own.
  `URLLoader.close()` can suppress stale progress/completion callbacks but
  cannot cancel the active transport. Flight's `NetResponse` also exposes
  status and headers only with the completed body, so OpenFL's earlier
  `httpResponseStatus` timing cannot be reproduced. The adapter preserves final
  status/event ordering through `flight.Net`. Flight 0.4.0 also exposes only its
  fetch-backed default through the public `flight.Net` facade; non-JavaScript
  hosts need a public backend installation hook before URLLoader can perform
  native requests instead of reporting a transport failure.

- **SharedObject quota prompts and remote synchronization**: Flight Storage
  provides synchronous local string persistence, which backs OpenFL local
  shared objects where a storage backend is configured; headless targets fall
  back to adapter-local process memory. Flight has no equivalent of
  Flash Player's quota-increase dialog, `minDiskSpace` reservation, or
  `NetStatusEvent` result after a pending flush. Flight also has no remote
  shared-object protocol for `connect`, `send`, `setDirty`, or synchronization;
  those methods remain compatibility stubs.

- **Raw TCP sockets on native hosts**: Flight Socket models framed WebSocket
  connections, and Flight's Web host provides that backend. Its maintained
  Lime and Clay hosts expose HTTP but no `net.socket` provider, while OpenFL
  `Socket` requires a raw TCP byte stream on native targets. HTML5 sockets now
  route through Flight Socket; native sockets retain the Haxe system transport
  with timer-driven polling until Flight exposes a raw-stream socket capability
  or native socket host.

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

- **OpenFL shader execution model**: Flight custom 2D effects accept a registered
  fragment shader using Flight's full-screen effect ABI and scalar/vector float
  uniforms. OpenFL `Shader` also accepts paired arbitrary GLSL vertex/fragment
  sources, Pixel Bender bytecode, bitmap and sampler inputs, Boolean/integer and
  matrix parameters, and synchronous or asynchronous `ShaderJob` execution over
  bitmap or numeric buffers. The adapter reflects GLSL declarations into the
  OpenFL data objects and retains a Flight custom-effect descriptor, but Flight
  cannot execute the broader OpenFL shader model or register its source without
  an active render-state bridge.

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

- **Cross-target NetStream video source**: Flight can wrap an HTML video
  element in a `VideoResource`, which lets the JavaScript/HTML5 adapter attach
  OpenFL's existing `NetStream` element to a Flight video texture. Other
  targets expose no decoded-frame or media-source handle from `NetStream`, so
  the Flight-backed `Video` surface remains empty there until a portable stream
  bridge exists.

- **Synchronous desktop clipboard reads**: Flight clipboard reads are
  asynchronous, while OpenFL's `Clipboard.getData()` and `hasFormat()` return
  synchronously. Flight also clears the whole clipboard rather than one format
  at a time and does not expose OpenFL-style deferred data handlers. The adapter
  synchronously shadows its own text, HTML, and RTF writes, but cannot reflect
  external clipboard changes until Flight provides synchronous inspection (or
  OpenFL adopts an asynchronous boundary).

- **FileReference network transfers and cancellation**: Flight Dialog and
  FileSystem can back file selection, metadata, loading, and saving, but their
  promise operations do not expose cancellation handles. `FileReference`
  ignores stale completions after `cancel()`; true host-operation cancellation
  and the combined download/save and multipart upload workflows still require
  Flight primitives that compose dialog, filesystem, and network operations.

- **Native child processes**: Flight 0.4.0's public shell API has no process
  spawn, standard-stream, or exit-status primitive that can back
  `NativeProcess.start()` and its asynchronous IO events.

- **Sensor cadence and mobile location policy**: Flight Sensors exposes sensor
  readings and capability queries, but its public `attachSensors` entry point
  cannot receive the update-frequency options supported by its backends, so
  OpenFL `DeviceRotation.setRequestedUpdateInterval()` remains a compatibility
  hint. Flight Geolocation can forward accuracy and cached-position age, but it
  has no requested update cadence, always-versus-when-in-use permission choice,
  or background pause policy corresponding to OpenFL's geolocation fields.

- **Desktop application metadata and shell capabilities**: Flight exposes the
  authoritative application and window handles needed for lifecycle and window
  operations, but it has no AIR runtime-version or runtime-patch metadata,
  application-identifier getter, default-file-association API, focused editing
  command router, or adapter from OpenFL `NativeMenu` objects to Flight menu
  templates. It also has no definitive capability queries for OpenFL's
  dock-icon, system-tray-icon, and native-menu support flags. Flight App login
  items and Power keep-awake operations back `startAtLogin` and
  `systemIdleMode`; the remaining surfaces stay deterministic stubs.

- **StageText host input ownership**: Flight TextInput provides the RichText
  editor, selection, restrictions, focus manager, and a connector for an
  explicit `TextInputSource`. OpenFL's Stage surface does not yet retain or
  expose the host-local Flight `InputManager`, so StageText can back its text,
  selection, restrictions, formatting, focus state, and scene node with Flight
  but cannot autonomously connect native keyboard/text ingress. The display
  bridge needs to own one host input source per Stage and make it available to
  StageText; Flight-driven edits also need a change signal from TextInput so
  OpenFL `Event.CHANGE` can be dispatched without polling the RichText value.

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
