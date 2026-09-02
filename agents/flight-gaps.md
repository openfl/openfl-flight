# Flight Gaps

Upstream flight-hx capabilities needed for OpenFL parity that are missing,
incomplete, or unclear. Each entry describes what OpenFL needs and what Flight
currently provides (or doesn't). An upstream Flight implementation is not
treated as resolved here until the refreshed generated flight-hx facade exposes
the capability that this adapter can compile against.

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

- **Application event-error boundary**: OpenFL routes listener failures through
  private Stage and application internals. Flight exposes no corresponding
  public application-level error handler, so adapter event listeners currently
  propagate thrown errors to their caller.

- **Custom render-event lifecycle**: The adapter can populate and dispatch an
  OpenFL `RenderEvent` from its internal `DisplayObjectRenderer` hook, including
  the active renderer binding, transform, color transform, and smoothing state.
  Flight owns the actual scene renderer and exposes no per-node pre-render
  callback that invokes this compatibility hook, so automatic host-driven
  custom render events still require a Flight render-lifecycle bridge.

- **Touch maximums and gesture recognition**: Flight Platform reports whether
  a host is touch-capable and Flight Input exposes typed pointer contacts, but
  neither API publishes a hardware maximum-contact count or recognizes the
  OpenFL gesture catalog. `Multitouch` retains OpenFL's default maximum and can
  raise it from observed concurrent Flight contacts; gesture support and the
  supported-gesture list remain unavailable.

- **Native gamepad attachment and sample history**: Flight Input exposes
  portable gamepad signals and browser attachment/polling, but no equivalent
  native-host attachment helper or sampled-control history buffer. OpenFL
  `GameInput` consumes Flight's signals and attaches them automatically on
  HTML5; native hosts still need a Flight input bridge, while
  `GameInputDevice.startCachingSamples()` and `getCachedSamples()` remain
  deterministic no-ops.

- **Per-object interaction metadata**: Flight does not expose per-node
  equivalents for OpenFL's `doubleClickEnabled`, context-menu metadata, or
  soft-keyboard input area.

- **Raw Context3D command model**: Flight's public GL surface exposes
  `beginGlRenderPass()` and `endGlRenderPass()`, but no active-state callback or
  immediate-mode API that maps OpenFL's AGAL programs and registers, separate
  vertex/index buffers, GPU state setters, arbitrary indexed draw calls, and
  `present()` lifecycle. `withGlRenderState()` and `drawGlFullscreenPass()` are
  not available on the public generated facade; even if exposed, the fullscreen
  helper would not represent `drawTriangles()`.

- **Context3D texture bridges**: Flight has no adapter for compressed ATF,
  `ByteArray`/typed-array uploads, arbitrary mip levels, render-target textures,
  or `VideoTexture`. BitmapData uploads at the base mip and hardware-only
  `BitmapData.fromTexture()` aliases are supported; cross-context readback is
  not.

### Context3D public-surface audit

The 22 command TODOs were audited against the current generated Flight facade.
`configureBackBuffer()` can preserve its observable OpenFL dimensions now, and
`dispose()` can clear adapter-local bridge state. The other commands stay
deterministic stubs until the named public seam exists; they are classified
explicitly in source rather than being left as unqualified TODOs.

| Context3D method | Classification | Public Flight seam verdict |
| --- | --- | --- |
| `clear` | blocked on GL draw seam | `beginGlRenderPass()`/`endGlRenderPass()` do not expose attachment-clear commands; an active-state seam with clear operations is required. |
| `configureBackBuffer` | implementable now (metadata); GPU work blocked on GL draw seam | Width and height are retained now. The render-state/target attachment still cannot be acquired or configured publicly. |
| `dispose` | adapter stub | Local bridge state can be cleared, but Flight exposes no Context3D-owned render-state/resource lifetime to release or recreate. |
| `drawToBitmapData` | blocked on texture bridges | No public render-target readback converts the active GL target into an OpenFL `BitmapData`. |
| `drawTriangles` | blocked on GL draw seam | An active-state callback is necessary but not sufficient: arbitrary indexed program/buffer drawing is required; a fullscreen-pass helper does not cover it. |
| `present` | blocked on GL draw seam | Flight can present a known render target, but Context3D cannot publicly acquire or retain that target. |
| `setBlendFactors` | blocked on GL draw seam | Requires public active-state blend mutation. |
| `setColorMask` | blocked on GL draw seam | Requires public active-state color-write-mask mutation. |
| `setCulling` | blocked on GL draw seam | Requires public active-state culling mutation. |
| `setDepthTest` | blocked on GL draw seam | Requires public active-state depth-write and comparison mutation. |
| `setProgram` | blocked on GL draw seam | Requires both a Program3D-to-Flight shader bridge and public active-state binding. |
| `setProgramConstantsFromByteArray` | blocked on GL draw seam | Requires an AGAL register-buffer bridge and active-state binding. |
| `setProgramConstantsFromMatrix` | blocked on GL draw seam | Requires an AGAL register-buffer bridge and active-state binding. |
| `setProgramConstantsFromVector` | blocked on GL draw seam | Requires an AGAL register-buffer bridge and active-state binding. |
| `setRenderToBackBuffer` | blocked on GL draw seam | Requires a public Context3D render-state/back-buffer binding. |
| `setRenderToTexture` | blocked on texture bridges | Flight sampled textures have no public conversion to a render target compatible with this command. |
| `setSamplerStateAt` | blocked on GL draw seam | Flight can create typed samplers, but cannot bind them by Context3D sampler slot on an active state. |
| `setScissorRectangle` | blocked on GL draw seam | Requires public active-state scissor mutation. |
| `setStencilActions` | blocked on GL draw seam | Requires public per-face stencil-action mutation. |
| `setStencilReferenceValue` | blocked on GL draw seam | Requires public stencil reference/read-mask/write-mask mutation. |
| `setTextureAt` | blocked on GL draw seam | Flight textures can be resolved only with an active state; public texture-slot binding is also absent. |
| `setVertexBufferAt` | blocked on GL draw seam | Requires a VertexBuffer3D-to-Flight buffer/layout bridge and public active-state binding. |

`setFillMode` is not part of the OpenFL 9.5.2 `Context3D` public surface, so the
adapter does not add a new method for it.

- **Synchronous BitmapData image construction**: Flight's public `ImageCodec`
  decodes encoded bytes through Promises, while `BitmapData.fromBase64()`,
  `fromBytes()`, and `fromFile()` are synchronous OpenFL factories. Flight also
  exposes no public cross-target conversion from Lime `Image` to a Flight Image
  resource, so `fromImage()` remains blocked on an image-handle bridge.

- **BitmapData platform and Stage3D cache types**: Flight raster surfaces do not
  expose a Lime `CairoImageSurface` conversion, and Flight has no public mesh
  buffer/layout abstraction matching OpenFL's cached quad and scale9 index and
  vertex buffers. `getSurface()`, `getIndexBuffer()`, and `getVertexBuffer()`
  therefore remain unavailable rather than returning unrelated handle types.

- **Remaining BitmapData semantic adapters**: Flight's effect-only shadow,
  glow, bevel, and displacement primitives do not directly preserve OpenFL's
  source composition, offsets, knockout, bounds, and convolution fill-edge
  rules. Display-object drawing still needs the portable rasterization bridge
  below, full 32-bit cross-channel palette-map summation is not representable by
  Flight's independent channel maps, and JPEG XR has no Flight encoder.

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

- **Byte compression encoders and LZMA**: OpenFL `ByteArray.compress`,
  `uncompress`, `deflate`, and `inflate` require encoders and decoders for zlib,
  raw deflate, and LZMA. The current generated `flight.Compression` facade
  exposes the framing-aware `inflateDeflate` decoder, which now backs zlib and
  raw-deflate decoding, but has no matching encoder or LZMA codec. The adapter
  retains Haxe standard-library encoders for zlib and raw deflate while
  preserving OpenFL's in-place length and position semantics; LZMA remains a
  deterministic no-op.

- **Shareable ByteArray atomics**: OpenFL's Flash-only
  `atomicCompareAndSwapIntAt` and `atomicCompareAndSwapLength` require a
  shareable byte buffer with atomic integer and length mutation. The generated
  Flight facade and `haxe.io.Bytes` expose no shareable atomic byte-storage
  primitive, so these APIs remain Flash-only rather than pretending that an
  ordinary resize or read/write is atomic.

- **Public flight-hx UTF-8 byte codec binding**: OpenFL
  `ByteArray.readUTFBytes` and `writeUTFBytes` require conversion between UTF-8
  and raw bytes. The upstream `@flighthq/encoding` update reports public
  `encodeUTF8` and `decodeUTF8` functions, but after `haxelib update flight git`
  the generated facade still has no Encoding module or either function. The
  codec implementation has landed upstream; exposing the refreshed pin through
  flight-hx remains the gap, and ByteArray continues to use `haxe.io.Bytes`.

- **Object wire formats**: OpenFL `ByteArray.readObject` and `writeObject`
  support AMF0, AMF3, HXSF, and JSON encodings, while `Socket` retains its HXSF
  fallback and shares the AMF gap. Flight 0.4.0 exposes no public object
  serialization API. HXSF and JSON currently fall back to Haxe standard
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

- **URLLoader/URLStream cancellation, chunks, and early response metadata**:
  Flight Net requests use Flight's configured network backend, and the refreshed
  generated `NetRequestOptions` accepts a
  `flight._internal.dom.AbortSignal`. Flight still exposes no public,
  cross-target abort-controller factory that an OpenFL network loader can own.
  `URLLoader.close()` and `URLStream.close()` can suppress stale callbacks but
  cannot cancel the active transport. Flight internally reads response streams
  and emits byte counts, but progress signals contain no downloaded chunk and
  `NetResponse.body` is available only after completion; `URLStream` therefore
  cannot expose bytes incrementally during progress. Flight also exposes status
  and headers only with the completed body, so OpenFL's earlier
  `httpResponseStatus` timing cannot be reproduced. `URLLoader` preserves the
  final status/event ordering through `flight.Net`; OpenFL 9.5.2 `URLStream`
  itself forwards only progress, completion, and error events from its internal
  loader, so the adapter deliberately retains its lack of `open`, `httpStatus`,
  and `httpResponseStatus` events and properties. Flight 0.4.0 also exposes only
  its fetch-backed default through the public `flight.Net` facade; non-JavaScript
  hosts need a public backend installation hook before URLLoader can perform
  native requests instead of reporting a transport failure.

- **SharedObject quota prompts and remote synchronization**: Flight Storage's
  host-explicit local string backend now backs OpenFL local shared objects via
  the Web host and active sys Lime/Clay hosts; headless targets fall back to
  adapter-local process memory. A rejected host write returns OpenFL's
  `PENDING` status while retaining a process-local copy. Flight has no
  equivalent of Flash Player's quota-increase dialog, `minDiskSpace`
  reservation, or `NetStatusEvent` result after a pending flush. Flight also
  has no remote shared-object protocol for `connect`, `send`, `setDirty`, or
  synchronization; those methods remain compatibility stubs and `getRemote`
  returns `null` like OpenFL 9.5.2's unsupported implementation.

- **Raw TCP flight-hx binding on native hosts**: The upstream Flight update
  reports a raw TCP `SocketBackend` in `@flighthq/socket`, but the refreshed
  generated `flight.Socket` facade still exposes the WebSocket-shaped
  `SocketOptions` (`url`, protocols, and binary type) and no raw TCP factory or
  endpoint options. Flight currently backs HTML5 WebSocket connection events,
  binary messages, closure, errors, and buffered sends. OpenFL `Socket`
  therefore retains its Haxe system transport with timer-driven polling for
  native raw TCP until flight-hx exposes the new backend and a maintained
  native host installs it.

- **UDP datagram sockets**: Flight Socket accepts a WebSocket URL and exposes a
  connection-oriented message channel. It has no UDP endpoint, local bind,
  `sendTo`/`readFrom`, peer-address metadata, or datagram delivery semantics.
  `DatagramSocket` therefore retains OpenFL's `sys.net.UdpSocket` transport on
  native targets and remains unavailable on HTML5. A Flight implementation
  requires a distinct host UDP capability rather than adaptation through the
  existing WebSocket API.

- **XMLSocket servers on HTML5**: `XMLSocket` composes the Flight-backed OpenFL
  `Socket`, and its adapter consistently appends and reassembles null-delimited
  XML messages. Browsers can expose only Flight's framed WebSocket transport,
  however, not the raw TCP stream required by a traditional XMLSocket daemon.
  HTML5 therefore requires a WebSocket-capable endpoint or bridge; native
  targets retain the Haxe system transport described above.

- **Authored StaticText import**: Flight provides a renderable `TextLabel`, which
  now backs `StaticText` and can mirror its read-only string through the private
  authoring hook. OpenFL exposes no public `StaticText` constructor, and this
  adapter has no SWF/authoring importer that supplies the source text, glyph
  layout, formatting, and authored bounds. Existing authored static-text assets
  therefore need an asset-import bridge before their full layout can appear.

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

- **Graphics shader paints**: Flight Shape supports solid, gradient, and bitmap
  texture fills and strokes, but its command registry has no custom-shader paint.
  Flight custom shaders are render effects over an already-rendered surface and
  therefore cannot back `Graphics.beginShaderFill()` without a shape-material
  shader command and an OpenFL-to-Flight shader-input bridge.

- **Graphics command-level blend modes**: Flight stores blending on the whole
  Shape node, so `Graphics.overrideBlendMode()` can apply the last supported
  mode to the shape but cannot preserve different modes between recorded
  commands. Flight supports normal, add, darken, difference, hard-light,
  lighten, multiply, overlay, and screen; OpenFL's alpha, erase, invert, layer,
  and subtract modes fall back to normal.

- **Portable display-object rasterization**: Flight exposes backend render
  states, render targets, raster surfaces, and render caches, but no portable
  public operation that draws an arbitrary `Node2D` into a Flight bitmap.
  `BitmapData.draw(displayObject)` and the pixel-generating portion of
  `cacheAsBitmap` need that offscreen bridge. The OpenFL 9.5.2 interpreter
  reference itself produces an empty bitmap for this operation, which is
  preserved as the headless compatibility fixture rather than treated as a
  completed rendering implementation.

- **Per-channel audio pan binding and peak metering**: The upstream Flight
  update reports an AudioChannel `pan` field and `setSourcePan`, but the refreshed
  generated facade still exposes only `AudioBus.pan` and no AudioChannel/source
  pan API. A flight-hx binding is still needed for OpenFL's independently
  mutable `SoundChannel.soundTransform`. Flight also exposes no left/right peak
  levels, so peak metering remains a separate capability gap after pan lands.

- **Synchronous audio file factories**: Flight audio decoding and URL resolution
  return promises. The adapter uses Flight's public Lime audio-context factory
  for `Sound.load()`, byte decoding, PCM resources, and playback, but cannot
  reproduce OpenFL's synchronous `Sound.fromFile()` contract on every target.

- **Dynamic PCM sample streaming**: Flight can create a complete audio resource
  from PCM channel arrays, which backs `Sound.loadPCMFromByteArray()`, but it has
  no callback-driven streaming channel corresponding to OpenFL's repeated
  `sampleData` events. Empty `Sound` playback therefore cannot stream generated
  samples until Flight exposes a public streaming PCM source.

- **OpenFL asset registry and streaming music**: Flight Loader schedules
  caller-provided Promise jobs and reports queue progress, but it is not a
  named resource registry, manifest reader, synchronous cache, or library
  resolver. Flight's image, font, and audio loaders also return Flight resource
  handles rather than OpenFL `BitmapData`, `Font`, and `Sound` instances. The
  adapter therefore retains Lime asset libraries where available and its local
  OpenFL library/cache contracts elsewhere. `Assets.getMusic()` continues to
  use decoded `Sound` data because Flight exposes no incrementally playable
  streaming audio source.

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
  FileSystem back single- and multi-file selection, metadata, loading, and
  saving, but their promise operations do not expose cancellation handles.
  `FileReference` ignores stale completions after `cancel()` and reports an IO
  error for its unsupported transfer entry points; true host-operation
  cancellation and the combined download/save and multipart upload workflows
  still require Flight primitives that compose dialog, filesystem, and network
  operations.

- **Filesystem metadata, locations, and synchronous contracts**: Flight
  FileSystem backs text/binary reads and writes, copies, moves, deletion,
  directory creation/listing, file statistics, access checks, and optional disk
  usage. Its generated facade still hardcodes empty well-known filesystem paths
  plus unsupported real-path, permissions, symlink mutation/read, and watch
  operations; maintained native hosts also cannot currently report disk usage
  or portable symlink state. Flight has no equivalents for AIR's downloaded,
  package/bundle, backup-exclusion, static permission-status, hidden-attribute,
  or filesystem-charset metadata. All Flight filesystem IO returns promises,
  so OpenFL's synchronous `File` methods can only be satisfied by a host whose
  promise settles immediately; truly asynchronous hosts must use the OpenFL
  asynchronous methods. Flight promises also expose no operation cancellation,
  leaving `File.cancel()` able to suppress stale events but not stop host IO.

- **Native file-dialog option and result contract skew**: Flight's generated
  open/save option records omit OpenFL's dialog title and starting path, while
  its maintained Lime host reads those fields reflectively. The generated
  facade declares outcome-wrapped result records, but the same host currently
  resolves raw handles or handle arrays. The adapter tolerates both result
  shapes and forwards the extra native options reflectively; the Flight dialog
  contract should expose those options and make the native host return the
  declared result records.

- **Native filesystem streaming and read-ahead**: Flight exposes file read and
  write stream factories plus ranged binary reads, but its maintained Lime host
  currently returns no stream handles and the public stream contract has no
  seek, truncate, or random-access operation. `FileStream` therefore uses
  whole-file Flight reads and serialized whole-buffer write snapshots. Its
  asynchronous open still preserves the promise and event boundary, but a read
  can report only one completed progress chunk and `readAhead` cannot control
  incremental loading until Flight supplies a native streaming backend.

- **Native child-process flight-hx binding**: The upstream Flight update reports
  process spawn, standard streams, and exit status in `@flighthq/shell`, but the
  refreshed generated `flight.Shell` facade still contains only external/path,
  trash, shortcut, and beep operations. `NativeProcess.start()` and its
  asynchronous IO events need the new shell process surface generated into
  flight-hx before the adapter can consume it.

- **Sensor cadence and mobile location policy**: Flight Sensors exposes sensor
  readings and capability queries, but its public `attachSensors` entry point
  cannot receive the update-frequency options supported by its backends, so
  OpenFL `DeviceRotation.setRequestedUpdateInterval()` remains a compatibility
  hint. Flight Geolocation can forward accuracy and cached-position age, but it
  has no requested update cadence, always-versus-when-in-use permission choice,
  or background pause policy corresponding to OpenFL's geolocation fields. Its
  public API can prompt for access and report that prompt's outcome, but cannot
  query the current permission state or subscribe to later permission changes;
  OpenFL's `permissionStatus` therefore updates only from prompt outcomes and
  geolocation watch errors.

- **Desktop application metadata and shell capabilities**: Flight exposes the
  authoritative application and window handles needed for lifecycle and window
  operations, but it has no AIR runtime-version or runtime-patch metadata,
  application-identifier getter, default-file-association API, focused editing
  command router, or adapter from OpenFL `NativeMenu` objects to Flight menu
  templates. It also has no definitive capability queries for OpenFL's
  dock-icon, system-tray-icon, and native-menu support flags. Flight App login
  items and Power keep-awake operations back `startAtLogin` and
  `systemIdleMode`; the remaining surfaces stay deterministic stubs.

- **TextField and StageText host input ownership**: Flight TextInput provides
  the RichText editor, selection, restrictions, focus manager, and a connector
  for an explicit `TextInputSource`. Flight Text also exposes change and scroll
  signals, which the adapters can translate to OpenFL events. OpenFL's Stage
  surface does not yet retain or expose the host-local Flight `InputManager`,
  however, so TextField and StageText can back their text, selection,
  restrictions, formatting, focus state, and scene nodes with Flight but cannot
  autonomously connect native keyboard/text ingress. The display bridge needs
  to own one host input source per Stage and make it available to both classes.

- **Embedded-versus-device text font selection**: Flight resolves registered
  font families for text formats but exposes no per-RichText policy equivalent
  to OpenFL's `TextField.embedFonts`. The adapter preserves the flag and sends
  the requested family and bold/italic properties to Flight, but it cannot
  require an embedded face or suppress device-font fallback when the flag is
  true.

- **TextMarkup on non-JavaScript flight-hx targets**: Flight TextMarkup exposes
  the standard tags, entities, format ranges, and class-style resolver needed
  by `TextField.htmlText`. The current generated Haxe implementation calls the
  JavaScript-only `String.search` method while tokenizing a tag, causing
  `parseTextMarkup()` to fail under the eval/interp target. TextField retains a
  small adapter parser until the generated facade uses a portable string/regex
  operation; StyleSheet CSS parsing remains the separate gap below.

- **StyleSheet CSS parsing**: Flight TextMarkup parses and formats markup and
  can register normalized class-to-text-format records, but it has no CSS text
  parser or mutable stylesheet abstraction. OpenFL's limited CSS1 parsing,
  case-insensitive style registry, merge behavior, and `TextFormat` transform
  therefore remain in the Haxe adapter. A future Flight CSS parser could
  replace this code while feeding TextMarkup's existing class-style registry.

- **Screen display modes and safe-area geometry**: Flight Screen exposes display
  bounds, work areas, the current mode, and scale information, but its current
  public facade has no query for the complete supported-mode list required by
  OpenFL `Screen.modes`. The adapter returns the current mode as a singleton
  until Flight restores that query. `ScreenInfo` also has no safe-area inset or
  rectangle for notches, cutouts, and rounded corners, so the adapter uses
  OpenFL's documented fallback of returning `visibleBounds` until Flight can
  expose host safe-area geometry.

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

- **ByteArray zlib/raw-deflate decoding and portable object fallbacks**: The
  public `flight.Compression.inflateDeflate` decoder now handles both RFC 1950
  zlib and raw-deflate frames while preserving ByteArray position semantics.
  The ByteArray audit also confirmed that HXSF, large HXSF, JSON, and large JSON
  round-trip through the Haxe standard serializers; only LZMA and AMF0/AMF3
  remain upstream codec gaps.

- **BitmapData CPU operations and encoding primitives**: The refreshed public
  `flight.Bitmap` facade exposes scroll, noise, Perlin noise, threshold, merge,
  channel copy, color-bounds, histogram, palette-map, image encoding, and pixel
  dissolve operations. Region-taking methods use explicit `BitmapRegion`
  inputs, while the generated scroll and encode signatures operate on the
  owning Bitmap. These primitives no longer need to be reported as missing
  Flight capabilities; wiring OpenFL methods to them is adapter work.

- **Timeline scene navigation and labels**: The Timeline audit found no missing
  Flight primitive. The adapter now keeps a global internal playhead while
  exposing scene-relative frames, labels, and scene transitions, and it merges
  multiple scripts on one frame in declaration order.

- **TextField render and query substrate**: Flight's public RichText node,
  TextLayout queries, TextInput selection/options, Text format ranges, and text
  field signals cover TextField rendering plus measurement, line, scrolling,
  selection, password, restriction, and maximum-character state. TextField now
  retains a RichText child and synchronizes these surfaces through the public
  Flight facades; host input ownership, embedded-font policy, and non-JavaScript
  TextMarkup portability remain the narrower gaps above.
