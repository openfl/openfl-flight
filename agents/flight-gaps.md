# Flight Gaps

Upstream flight-hx capabilities needed for OpenFL parity that are missing,
incomplete, or unclear. Each entry describes what OpenFL needs and what Flight
currently provides (or doesn't). An upstream Flight implementation is not
treated as resolved here until the refreshed generated flight-hx facade exposes
the capability that this adapter can compile against.

Last updated: merged Flight team feedback with ByteArray/Timeline audit (2026-09-02).

## Confirmed Gaps

- **Bitmap explicit dispose/release**: OpenFL's `BitmapData.dispose()` explicitly
  frees pixel storage and sets width/height to 0. Flight's `flight.Bitmap` has no
  public explicit release API — disposal relies on GC collecting the handle.
  Workaround: drop the reference and let GC handle it. Impact: apps that allocate
  many large bitmaps and dispose them in a tight loop may see higher peak memory.

- **Synchronous image decode for Loader.loadBytes**: OpenFL's `Loader.loadBytes()`
  synchronously decodes image bytes into a Bitmap/BitmapData and makes them
  available as `contentLoaderInfo.content`. Flight's image decoding is promise-based
  and host-dependent — no synchronous Loader-to-DisplayObject adapter exists in
  interp/headless mode.

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
  OpenFL gesture catalog.

- **Native gamepad attachment and sample history**: Flight Input exposes
  portable gamepad signals and browser attachment/polling, but no equivalent
  native-host attachment helper or sampled-control history buffer.
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

The creation methods were audited alongside the command TODOs. `createTexture`,
`createCubeTexture`, `createRectangleTexture`, and `createVideoTexture` all
produce Flight-owned texture entities. Cube creation uses Flight's generic
public texture factory because the convenience `createCubeTexture()` helper's
JavaScript-style face-array copy is not portable to Flight's pure-eval runtime.
`createProgram`, `createIndexBuffer`, and `createVertexBuffer` construct the
OpenFL resource shells, but remain adapter stubs until Flight exposes the
program and independently bindable buffer bridges described above.

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

- **Object wire formats (AMF0/AMF3)**: OpenFL `ByteArray.readObject` and
  `writeObject` support AMF0, AMF3, HXSF, and JSON encodings. Flight exposes no
  public object serialization API. HXSF and JSON fall back to Haxe standard
  serializers and round-trip correctly; AMF0 and AMF3 are explicit no-ops.

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
  native targets and remains unavailable on HTML5.

- **XMLSocket servers on HTML5**: Browsers can expose only Flight's framed
  WebSocket transport, not the raw TCP stream required by a traditional
  XMLSocket daemon. HTML5 therefore requires a WebSocket-capable endpoint or
  bridge; native targets use the Haxe system transport.

- **Authored StaticText import**: Flight provides a renderable `TextLabel`, which
  now backs `StaticText` and can mirror its read-only string through the private
  authoring hook. OpenFL exposes no public `StaticText` constructor, and this
  adapter has no SWF/authoring importer that supplies the source text, glyph
  layout, formatting, and authored bounds. Existing authored static-text assets
  therefore need an asset-import bridge before their full layout can appear.

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

- **Audio peak metering**: Flight exposes no left/right peak levels for
  playing audio channels. `SoundChannel.leftPeak` and `rightPeak` remain
  zero.

- **Native Lime audio device backend**: `HostLime.enableHostLime()` does not
  install an `AudioDeviceBackend`, so Flight Media resolves its silent sentinel
  for Neko and other native Lime targets. Flight contains a prospective
  `LimeAudioDevice`, but it is excluded behind `flight_host_develop`; when
  activated against the current facade its PCM conversion casts Flight's Lime
  `_Float32Array` storage to `Array<Float>` and raises `Unsupported operation`.
  Flight needs to ship and install a native device backend that reads its typed
  channel arrays portably. Until then decoded OpenFL sounds can create logical
  channels, but native playback cannot reach the host audio device.

- **Synchronous audio file factories**: Flight audio decoding and URL resolution
  return promises. The adapter uses Flight's public Lime audio-context factory
  for `Sound.load()`, byte decoding, PCM resources, and playback, but cannot
  reproduce OpenFL's synchronous `Sound.fromFile()` contract on every target.

- **Dynamic PCM sample streaming**: Flight can create a complete audio resource
  from PCM channel arrays, but it has no callback-driven streaming channel
  corresponding to OpenFL's repeated `sampleData` events.

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

- **Sensor cadence and mobile location policy**: Flight Sensors cannot receive
  update-frequency options, always-versus-when-in-use permission choice, or
  background pause policy. `permissionStatus` updates only from prompt
  outcomes and geolocation watch errors.

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

- **StageText host input ownership**: OpenFL's Stage surface does not yet
  retain or expose the host-local Flight `InputManager`, so StageText cannot
  autonomously connect native keyboard/text ingress. The display bridge needs
  to own one host input source per Stage and make it available to StageText.

- **StyleSheet CSS parsing**: Flight TextMarkup has no CSS text parser or
  mutable stylesheet abstraction. OpenFL's limited CSS1 parsing remains in
  the Haxe adapter.

- **Screen display modes and safe-area geometry**: Flight Screen has no query
  for the complete supported-mode list required by OpenFL `Screen.modes`, and
  no safe-area inset or rectangle for notches/cutouts/corners.

- **OpenFL shader execution model**: Flight cannot execute the broader OpenFL
  shader model (Pixel Bender, bitmap/sampler inputs, Boolean/integer/matrix
  parameters, synchronous/asynchronous `ShaderJob` execution). The adapter
  reflects GLSL declarations into OpenFL data objects and retains a Flight
  custom-effect descriptor.

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

## Pending flight-hx Binding Regeneration

These capabilities have landed upstream in Flight source but are NOT yet visible
in the generated flight-hx Haxe facade. The adapter cannot compile against them
until bindings are regenerated. Recorded as landed pending exposure.

- **Public UTF-8 byte codec**: `encodeUTF8` / `decodeUTF8` in
  `@flighthq/encoding`. ByteArray continues to use `haxe.io.Bytes` until
  the binding appears.

- **Raw TCP sockets on native hosts**: `SocketBackend` byte-stream TCP types
  in `@flighthq/socket`. Socket adapter retains Haxe system transport.

- **Native child processes**: Process spawn, stdio, exit status in
  `@flighthq/shell`. NativeProcess adapter retains no-op stubs.

- **Per-channel audio pan**: `AudioChannel.pan` and `setSourcePan` on
  `AudioDeviceBackend`. SoundChannel pan remains a no-op.

## In Progress (upstream)

These are actively being implemented in Flight:

- **Byte compression encoders**: Named compress functions (`compressDeflate`,
  etc.) alongside the existing decompress registry. Will address zlib and
  raw-deflate encoding; LZMA remains unaddressed.

- **Interaction dispatch layers**: Composable layer registration between
  hit-test resolution and bubble dispatch via
  `connectInteractionDispatchLayer(manager, layer, { priority })`. This is the
  seam openfl-flight needs to intercept resolved interactions and run its own
  three-phase capture/target/bubble router while suppressing Flight's bubble
  traversal.

- **Double-click interaction signal**: `onPointerDoubleClick` with opt-in per
  node. Addresses the `doubleClickEnabled` part of the per-object interaction
  metadata gap.

- **Bitmap displacement effect**: New `BitmapDisplacementEffect` kind accepting
  a texture source, channel selection, and scale factors. Distinct from the
  existing procedural `DisplacementEffect`. Will resolve the bitmap-map
  displacement gap.

- **Effect capture geometry helper**: `computeRenderEffectCaptureGeometry`
  collapses bounds/padding/size/transform computation for the per-node effect
  lane. Reduces boilerplate for the filter-to-effect adapter.

- **GL draw seam**: Promoting existing internal draw primitives
  (`withGlRenderState`, `drawGlFullscreenPass`, `beginGlRenderPass`/
  `endGlRenderPass`, etc.) to the public surface. Provides the "set state +
  draw triangles" primitive that Context3D adapter needs (AGAL is not worth
  supporting — this is the right level).

- **File operation cancellation**: AbortSignal on filesystem/dialog operations.
  Will address `FileReference.cancel()`.

- **Signal dispatch safety**: Tombstone discipline for mutation-safe iteration,
  tracked connections, and bulk lifecycle teardown via signal scopes.

## Adapter-Level (not Flight gaps)

These are the adapter's responsibility by design — Flight has the primitives,
the mapping work belongs in openfl-flight:

- **Inverse matrix determinant threshold** (1e-6 vs 1e-11): Flight's stricter
  threshold is correct; adapter pre-checks before calling Flight.

- **Negative-scale decomposition axis** (X vs Z): Arbitrary convention;
  adapter remaps in a few lines.

- **Perspective projection from focalLength**: One-line conversion:
  `fovY = 2 * atan(aperture / (2 * focalLength))`. Flight's
  `createPerspectiveProjection` takes fovY.

- **Synchronous clipboard reads**: Web Clipboard API is async by spec.
  Flight's async reads are correct. The adapter reconciles OpenFL's sync API
  with Flight's async one by shadowing writes.

- **Synchronous audio loading**: Async decode is the correct modern pattern.
  The adapter bridges OpenFL's sync constructor.

- **Three-phase event routing** (capture/target/bubble): The interaction
  dispatch layer seam (in progress above) gives openfl-flight the hook it
  needs. The actual routing logic belongs in the adapter.

- **SWF-specific loader metadata and sandboxes**: SWF-specific, not
  general-purpose. The adapter uses OpenFL-compatible defaults.

- **SharedObject quota dialogs and remote synchronization**: Flash
  Player-specific features. Flight Storage provides the underlying storage
  primitive; quota dialogs and remote sync are compatibility stubs.

- **AGAL / Context3D command model**: AGAL is not worth supporting. The GL
  draw seam (in progress) provides the underlying primitive.

- **SimpleButton menu tracking / sounds**: Flash-specific interaction idioms.
  The adapter retains the properties as no-ops.

- **OpenFL per-tile shaders**: Shader-to-Flight-material bridge is adapter
  work. Flight materials can tint and adjust tile appearance.

- **Desktop/AIR metadata**: AIR-platform-specific. Adapter uses stubs.

- **Per-node render effects**: Flight handles per-node blur/glow/shadow/bevel
  through an explicit capture-and-compose lane, not through
  `displayObject.filters`. `ColorMatrixFilter` maps through Flight's
  `addNodeColorAdjustment`. The new `computeRenderEffectCaptureGeometry`
  helper (in progress) reduces boilerplate. The adapter maps OpenFL's filter
  array to Flight's explicit lane.

## Suspected Gaps

- **Text metrics in interp/headless mode**: OpenFL's TextField.textWidth/textHeight
  depend on font measurement. Flight's TextLayout may require a renderer context.

## Resolved

(Entries move here when flight-hx ships the fix or the gap turns out to be a
misunderstanding of the API.)

- **System pause and resume**: `NativeApplication` now owns and exposes the
  authoritative Flight `Application` handle internally, so the static `System`
  API can route pause and resume through Flight without constructing a second
  application.

- **Immediate cursor-property synchronization**: `setNodeCursor` now triggers
  an immediate cursor update when the pointer is hovering over the affected
  node. No more waiting for the next rollover event.

- **Net request cancellation**: AbortSignal support on `sendNetRequest`.
  URLLoader/URLStream can now cancel active transport via the abort signal.

- **ByteArray zlib/raw-deflate decoding and portable object fallbacks**: The
  public `flight.Compression.inflateDeflate` decoder now handles both RFC 1950
  zlib and raw-deflate frames while preserving ByteArray position semantics.
  HXSF and JSON round-trip through the Haxe standard serializers; only LZMA
  and AMF0/AMF3 remain upstream codec gaps.

- **BitmapData CPU operations and encoding primitives**: The refreshed public
  `flight.Bitmap` facade exposes scroll, noise, Perlin noise, threshold, merge,
  channel copy, color-bounds, histogram, palette-map, image encoding, and pixel
  dissolve operations. These are now adapter work, not Flight gaps.

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

- **Arbitrary batched tile hierarchies**: Flight's `@flighthq/quadbatch`
  already provides this. `QuadBatch` is a scene graph node with per-instance
  atlas region IDs and full matrix3x2 affine transforms. Use
  `setQuadBatchInstanceMatrix` with `transformType: 'matrix3x2'` for freely
  positioned/rotated/scaled quads. OpenFL's nested Tile/TileContainer maps
  directly to quadbatch instances.

- **Per-object doubleClickEnabled**: `onPointerDoubleClick` landing in Flight
  (in progress section). Context-menu metadata and soft-keyboard input area
  remain adapter-level concerns.

- **FileReference cancellation**: File operation cancellation via AbortSignal
  landing in Flight (in progress section).
