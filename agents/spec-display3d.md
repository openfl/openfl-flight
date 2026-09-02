# `openfl.display3D` and `Stage3D` behavior specification

Reference: OpenFL 9.5.2 under
`../haxelib/openfl/9,5,2/src/openfl/display3D/` and
`../haxelib/openfl/9,5,2/src/openfl/display/Stage3D.hx`. Adapter: the matching
`src/openfl/` paths. Private `_internal` GL/AGAL helpers are described only
where they determine a public result.

Legend:

- [x] The adapter preserves the observable OpenFL 9.5.2 behavior.
- [ ] The adapter is missing, divergent, or still needs a compatibility fixture.
- [!] The behavior is blocked by a confirmed entry in `agents/flight-gaps.md`;
  the exact gap title is shown in bold.

## `Stage3D`

- [ ] `Stage` creates its `stage3Ds` eagerly: the reference creates two on a
  mobile build and four otherwise, while the adapter always creates four.
  `Stage3D.new(stage)` itself is private/package-controlled.
- [x] A new instance has `context3D == null`, `visible == true`, and `x == y ==
  0`. `context3D` is externally read-only; `visible`, `x`, and `y` are mutable.
- [ ] Reference `x`/`y` changes rebuild the Stage3D render transform from the
  device-scaled translation and projection matrix. The adapter retains only the
  numeric values, so they never affect rendering.
- [!] Reference `requestContext3D(renderMode = AUTO, profile = BASELINE)` marks
  one request pending and schedules creation after 1 ms. It shares or creates a
  hardware context for OpenGL, can create a WebGL canvas for a DOM renderer,
  and reports `ErrorEvent.ERROR("Context3D not available")` for unsupported
  renderers. The adapter always takes that asynchronous error path and never
  populates `context3D`. Blocked by **Raw Context3D command model**.
- [x] A second request while one is pending is ignored. If a context already
  exists, the reference asynchronously re-dispatches `CONTEXT3D_CREATE` rather
  than creating another one. Request completion clears the pending flag before
  dispatch.
- [ ] `requestContext3DMatchingProfiles(profiles)` ignores the vector and calls
  `requestContext3D()` in both sources; neither validates entries or chooses the
  highest supplied profile as the API prose promises.
- [ ] Reference resize updates an optional DOM canvas, projection matrix, and
  device-scaled render translation. The adapter records only width and height.
- [!] On context loss the reference disposes the context and remembers that a
  recreation is pending; restoration creates it and emits the creation event.
  The adapter nulls `context3D`, but restoration can only emit the unavailable
  error. Blocked by **Raw Context3D command model**.

## `Context3D`

### Construction and properties

- [!] `Context3D` is final and cannot be publicly constructed. The reference
  constructor captures Stage/Stage3D and a real GL context, allocates command
  state and AGAL constant registers, queries GL capabilities, and creates its
  shared quad index buffer. The adapter constructor creates only a resource
  shell. Blocked by **Raw Context3D command model**.
- [x] `supportsVideoTexture` is true only for `js && html5` in both sources.
- [ ] `backBufferWidth` and `backBufferHeight` begin at zero in both. Reference
  `configureBackBuffer` may DPI-scale its arguments and builds real back/front
  targets; the adapter only assigns the two requested integers.
- [ ] `driverInfo` starts as `"OpenGL (Direct blitting)"`, but the reference
  replaces it with queried vendor/version/renderer/GLSL details and appends
  `" (Disposed)"` on internal disposal. The adapter never changes the default.
- [ ] `maxBackBufferWidth` and `maxBackBufferHeight` are the queried maximum GL
  viewport dimension in the reference; they are zero in the adapter.
- [x] `profile` is externally read-only and defaults to `STANDARD` in both.
- [x] `enableErrorChecking` is adapter-local mutable Boolean state defaulting to
  false in both public implementations.
- [ ] `totalGPUMemory` returns the difference between total/current NVX memory
  in bytes when that extension exists, otherwise zero. The adapter always
  returns zero.

### Resource factories

- [x] `createProgram(format = AGAL)`, `createIndexBuffer(numIndices, usage =
  STATIC_DRAW)`, and `createVertexBuffer(numVertices, data32PerVertex, usage =
  STATIC_DRAW)` return private-constructed resource objects retaining their
  context, sizes/stride inputs, and format/usage intent.
- [x] `createTexture(width, height, format, optimizeForRenderToTexture,
  streamingLevels = 0)`, `createRectangleTexture(width, height, format,
  optimizeForRenderToTexture)`, and `createCubeTexture(size, format,
  optimizeForRenderToTexture, streamingLevels = 0)` return the corresponding
  texture subclasses. The adapter retains dimensions/options internally and
  creates a Flight texture handle.
- [ ] Reference `createVideoTexture()` returns a texture only on HTML5 and
  otherwise throws `Error("Video textures are not supported on this
  platform")`. The adapter constructs one on every target even though
  `supportsVideoTexture` remains false outside HTML5.

### Back buffer, draw, and presentation commands

- [!] `clear(red, green, blue, alpha, depth, stencil, mask)` applies exactly the
  selected `Context3DClearMask` attachments, temporarily forces writable masks,
  and clears the active framebuffer. The adapter is a no-op. Blocked by **Raw
  Context3D command model**.
- [!] `configureBackBuffer(width, height, antiAlias,
  enableDepthAndStencil = true, wantsBestResolution = false,
  wantsBestResolutionOnBrowserZoom = false)` retains all requested state and
  creates/resizes Stage3D double buffers in the reference. Only width/height are
  retained by the adapter; GPU configuration is blocked by **Raw Context3D
  command model**.
- [!] `drawTriangles(indexBuffer, firstIndex = 0, numTriangles = -1)` flushes
  pending render state/program constants, binds the index buffer, and calls
  indexed triangle drawing for all indices or `numTriangles * 3`, with a
  two-byte offset per first index. The adapter is a no-op. Blocked by **Raw
  Context3D command model**.
- [!] `present()` returns to the back buffer, performs an implicit transparent
  clear if necessary, swaps Stage3D front/back textures, and marks the context
  for presentation. The adapter is a no-op. Blocked by **Raw Context3D command
  model**.
- [!] `drawToBitmapData(destination, srcRect = null, destPoint = null)` is a
  null-destination no-op; otherwise it copies host-window pixels for the Stage
  context or reads the Stage3D framebuffer and restores its former render
  target. The adapter never changes the destination. Blocked by **Context3D
  texture bridges**.
- [ ] `dispose(recreate = true)` nulls the reference GL handle and releases its
  Context3D/Stage3D-owned state; `recreate` is not inspected. The adapter only
  nulls its already-null dynamic GL slot and leaves created resource shells
  intact.

### Pipeline state and binding commands

Each method below mutates deferred Context3D state in the reference and becomes
effective when drawing flushes that state. Each adapter method is currently a
deterministic no-op:

- [!] `setBlendFactors(sourceFactor, destinationFactor)` uses the same factors
  for RGB and alpha with add blending. Blocked by **Raw Context3D command
  model**.
- [!] `setColorMask(red, green, blue, alpha)` controls four attachment write
  channels. Blocked by **Raw Context3D command model**.
- [!] `setCulling(triangleFaceToCull)` selects no/back/front/both-face culling;
  invalid values fail when flushed. Blocked by **Raw Context3D command model**.
- [!] `setDepthTest(depthMask, passCompareMode)` retains depth write and compare
  state; actual writes are also gated by the selected target's depth/stencil
  capability. Blocked by **Raw Context3D command model**.
- [!] `setProgram(program)` selects the AGAL/GLSL program and copies its sampler
  defaults into still-unset sampler slots. Blocked by **Raw Context3D command
  model**.
- [!] `setProgramConstantsFromByteArray(programType, firstRegister,
  numRegisters, data, byteArrayOffset)`, `setProgramConstantsFromMatrix(...,
  transposedMatrix = false)`, and `setProgramConstantsFromVector(...,
  numRegisters = -1)` populate vertex/fragment register banks and dirty the
  selected range; zero registers is a no-op and `-1` derives a count. The
  adapter retains no constants. Blocked by **Raw Context3D command model**.
- [!] `setRenderToBackBuffer()` clears the active texture target;
  `setRenderToTexture(texture, enableDepthAndStencil = false, antiAlias = 0,
  surfaceSelector = 0)` retains all target options. Both adapter methods are
  no-ops. The latter is also blocked by **Context3D texture bridges**.
- [!] `setSamplerStateAt(sampler, wrap, filter, mipfilter)` creates/reuses one
  sampler-state record per slot. Blocked by **Raw Context3D command model**.
- [!] `setScissorRectangle(rectangle)` copies a non-null rectangle and enables
  scissoring; null disables it. The copy prevents later caller mutation from
  changing the state. Blocked by **Raw Context3D command model**.
- [!] `setStencilActions(triangleFace = FRONT_AND_BACK, compareMode = ALWAYS,
  actionOnBothPass = KEEP, actionOnDepthFail = KEEP,
  actionOnDepthPassStencilFail = KEEP)` and
  `setStencilReferenceValue(referenceValue, readMask = 0xFF, writeMask = 0xFF)`
  retain the complete stencil state. Blocked by **Raw Context3D command model**.
- [!] `setTextureAt(sampler, texture)` assigns or clears a texture slot. Blocked
  by **Raw Context3D command model** and, for render-target/raw uploads, by
  **Context3D texture bridges**.
- [!] `setVertexBufferAt(index, buffer, bufferOffset = 0, format = FLOAT_4)` is
  a no-op for a negative index, disables that attribute for null buffer, and
  otherwise binds a 1-4 float or normalized four-byte view with byte offset
  `bufferOffset * 4`; invalid format throws `IllegalOperationError`. The adapter
  performs none of this. Blocked by **Raw Context3D command model**.
- [x] `setFillMode` is not part of the OpenFL 9.5.2 `Context3D` surface and the
  adapter correctly does not add it.

## Programs and buffers

### `Program3D`

- [!] `Program3D` is final/private-constructed. Reference AGAL construction
  creates sampler/uniform registries; GLSL construction creates attribute,
  sampler, uniform-name/type/location arrays. Adapter construction retains only
  context and requested format. Blocked by **Raw Context3D command model**.
- [ ] For AGAL, `getAttributeIndex("vaN")` and
  `getConstantIndex("vcN"|"fcN")` return `Std.parseInt(N)`; other prefixes
  return -1. The adapter matches numeric names but changes a matching,
  non-numeric suffix from the reference's null parse result to -1.
- [!] For GLSL, the reference methods search linked attribute names or return
  the stored uniform location cast to an integer. The adapter always returns
  -1 because it never links a program. Blocked by **Raw Context3D command
  model**.
- [!] `upload(vertexProgram, fragmentProgram)` acts only for AGAL: it converts
  both bytecodes to GLSL, deletes prior shaders, compiles/links, builds uniform
  mappings, and adopts converted sampler state. `uploadSources(vertexSource,
  fragmentSource)` acts only for GLSL: it prefixes precision declarations,
  skips identical sources, parses declared attributes/uniforms/samplers, then
  compiles/links and resolves locations. Both are no-ops in the adapter.
  Blocked by **Raw Context3D command model**.
- [!] `dispose()` deletes reference shader resources; it is a no-op in the
  adapter. Blocked by **Raw Context3D command model**.

### `IndexBuffer3D` and `VertexBuffer3D`

- [!] Reference construction creates a GL buffer and selects dynamic/static GL
  usage. `IndexBuffer3D` retains index count; `VertexBuffer3D` retains vertex
  count, 32-bit values per vertex, and byte stride. Adapter shells retain the
  counts (and vertex size) but allocate no buffer. Blocked by **Raw Context3D
  command model**.
- [!] Each `dispose()` deletes its GL buffer in the reference and is a no-op in
  the adapter. Blocked by **Raw Context3D command model**.
- [!] Index `uploadFromByteArray(data, byteArrayOffset, startOffset, count)`
  views `count` UInt16s beginning at `byteArrayOffset + startOffset * 2`;
  `uploadFromVector(data, startOffset, count)` copies that slice to a reusable
  UInt16 array. Vertex equivalents use
  `byteArrayOffset + startVertex * stride` and copy
  `numVertices * data32PerVertex` floats. Adapter methods are no-ops. Blocked by
  **Raw Context3D command model**.
- [!] Both `uploadFromTypedArray(data, byteLength = -1)` methods ignore
  `byteLength`, return for null, bind their GL target, and upload the whole view
  using recorded usage. Adapter methods are no-ops. Blocked by **Raw Context3D
  command model**.

## Textures

### Shared `TextureBase`

- [!] `TextureBase` is an `EventDispatcher` with private construction. Reference
  instances own GL texture/framebuffer/renderbuffer/sampler state;
  `dispose()` recursively disposes an alpha texture and deletes GPU resources.
  Adapter instances retain dimensions/options and a Flight texture handle;
  base `dispose()` only nulls that handle. Full parity is blocked by
  **Context3D texture bridges**.

### `Texture`, `RectangleTexture`, and `CubeTexture`

- [ ] Adapter construction does create Flight 2D, rectangle, and cube texture
  resources and applies a mipmap sampler when `streamingLevels > 0`, but ignores
  the requested Context3D texture format and render-target optimization.
- [ ] Base-mip `uploadFromBitmapData` maps a BitmapData Flight bitmap into a 2D
  or rectangle texture; cube upload maps the requested numeric face. Unlike the
  reference, the adapter dereferences a null source, performs no size/face
  validation, ignores `generateMipmap`, and ignores every nonzero mip level.
- [!] `Texture.uploadFromByteArray`, `.uploadFromTypedArray`, and
  `.uploadCompressedTextureFromByteArray`; the corresponding rectangle methods;
  and the cube byte/typed/compressed methods are all adapter no-ops. Reference
  raw uploads apply byte offsets and mip dimensions; compressed upload parses
  ATF and, when `async`, dispatches `TEXTURE_READY` after a 1 ms timer. Blocked
  by **Context3D texture bridges**.
- [!] Reference texture subclasses can create framebuffer attachments for
  render-to-texture, including selecting a cube face. The Flight resources
  cannot be used that way by Context3D. Blocked by **Context3D texture bridges**.

### `VideoTexture`

- [ ] `videoWidth` and `videoHeight` initialize to zero. On HTML5, reference
  `attachNetStream` waits for playable media, tracks changing video time,
  uploads the current frame on texture access, updates dimensions, and
  dispatches `TEXTURE_READY`. The adapter attaches the NetStream HTML video to
  a Flight video resource and snapshots dimensions immediately, but emits no
  ready/dimension event and does not refresh those dimensions later.
- [!] Outside HTML5, the adapter retains the stream but has no decoded source
  to attach. Blocked by **Cross-target NetStream video source**.
- [x] `attachNetStream(null)` detaches the old association. Adapter
  `dispose()` clears the stream, destroys the Flight video texture, disposes
  the video resource, then nulls the base handle.

## Context3D value types

- [x] Except for `Context3DClearMask`, non-`openfljs` value types are nullable
  integer-backed abstracts with private string conversion; `openfljs` uses the
  strings directly. Unknown strings map to null. Public string values are:

  - `Context3DBlendFactor`: `destinationAlpha`, `destinationColor`, `one`,
    `oneMinusDestinationAlpha`, `oneMinusDestinationColor`,
    `oneMinusSourceAlpha`, `oneMinusSourceColor`, `sourceAlpha`, `sourceColor`,
    `zero`.
  - `Context3DBufferUsage`: `dynamicDraw`, `staticDraw`.
  - `Context3DCompareMode`: `always`, `equal`, `greater`, `greaterEqual`,
    `less`, `lessEqual`, `never`, `notEqual`.
  - `Context3DMipFilter`: `miplinear`, `mipnearest`, `mipnone`.
  - `Context3DProfile`: `baseline`, `baselineConstrained`, `baselineExtended`,
    `standard`, `standardConstrained`, `standardExtended`.
  - `Context3DProgramFormat`: `agal`, `glsl`.
  - `Context3DProgramType`: `fragment`, `vertex`.
  - `Context3DRenderMode`: `auto`, `software`.
  - `Context3DStencilAction`: `decrementSaturate`, `decrementWrap`,
    `incrementSaturate`, `incrementWrap`, `invert`, `keep`, `set`, `zero`.
  - `Context3DTextureFilter`: `anisotropic16x`, `anisotropic2x`,
    `anisotropic4x`, `anisotropic8x`, `linear`, `nearest`.
  - `Context3DTextureFormat`: `bgrPacked565`, `bgra`, `bgraPacked4444`,
    `compressed`, `compressedAlpha`, `rgbaHalfFloat`.
  - `Context3DTriangleFace`: `back`, `front`, `frontAndBack`, `none`.
  - `Context3DVertexBufferFormat`: `bytes4`, `float1`, `float2`, `float3`,
    `float4`.
  - `Context3DWrapMode`: `clamp`, `clamp_u_repeat_v`, `repeat`,
    `repeat_u_clamp_v`.
- [x] `Context3DClearMask` is a UInt bit mask:
  `COLOR = 0x01`, `DEPTH = 0x02`, `STENCIL = 0x04`, and `ALL = 0x07`.
- [ ] The adapter preserves all constants and string mappings, but removes the
  reference's explicit nullable-value equality/inequality overloads for the C#
  target. Other targets have equivalent value behavior.
