# `openfl.utils` behavioral specification

Reference: `src/openfl/utils/` in the OpenFL 9.5.2 distribution, plus the timer
helper methods on `openfl.Lib`. On Flash, applicable types alias native Flash
types.

Status describes `src/openfl/utils/`:

- `[x]` implements the executable OpenFL 9.5.2 contract.
- `[ ]` is missing, divergent, or unclear.
- `[!]` is blocked by the cited public Flight gap in `agents/flight-gaps.md`.

## `ByteArray`

### Storage and construction

- `[x]` `new(length = 0)` allocates exactly that logical length, zero-fills
  new bytes, sets `position = 0`, copies `ByteArray.defaultEndian`, and copies
  `ByteArray.defaultObjectEncoding`. Capacity may exceed public length during
  later growth and is not observable through the API.
- `[x]` `length` is logical byte count. Increasing it preserves existing bytes
  and exposes zero-filled new bytes; decreasing it truncates and clamps
  `position` down to the new length. Writes at or beyond the end grow length to
  cover the written range.
- `[x]` `position` is the next read/write offset and may be assigned directly.
  `bytesAvailable` is `length - position`; ordinary reads advance it and writes
  advance it to just after the data written.
- `[x]` Integer array access reads a byte by zero-based index and writing masks
  to the low eight bits, automatically growing through `index + 1`. It does not
  move `position`.
- `[x]` `clear()` makes length and position zero. It does not reset endian or
  object encoding.
- `[x]` `fromBytes`/`fromBytesData` and, on supported JS/Lime targets,
  `fromArrayBuffer`/`fromLimeBytes` wrap or copy the supplied data into a
  ByteArray with position zero. `fromFile` reads synchronously where Lime can;
  `loadFromBytes` and `loadFromFile` return Futures and fail/return null on
  targets where the underlying operation is unavailable.
- `[x]` `defaultEndian` is lazily the host/Lime system endianness unless
  `openfl_big_endian` forces big-endian; it is little-endian on non-Lime
  portable builds. Assigning it affects subsequently constructed arrays only.
  `defaultObjectEncoding` defaults to `ObjectEncoding.DEFAULT` (HXSF off
  Flash), likewise copied at construction.

### Primitive reads

- `[x]` Every read starts at `position`, advances by its byte width only when
  successful, and throws `EOFError` if insufficient bytes exist.
- `[x]` `readBoolean()` consumes one byte and returns false only for zero.
  `readByte()` sign-extends an 8-bit value to -128..127;
  `readUnsignedByte()` returns 0..255.
- `[x]` `readShort()` sign-extends 16 bits; `readUnsignedShort()` returns
  0..65535. `readInt()` reads a signed 32-bit bit pattern;
  `readUnsignedInt()` reads the same 32-bit pattern through Haxe's target
  integer representation. `readInt64()` returns `haxe.Int64`. All honor
  `endian`.
- `[x]` `readFloat()` and `readDouble()` decode IEEE-754 32-bit and 64-bit
  values in the selected byte order.
- `[x]` `readBytes(destination, offset = 0, length = 0)` copies `length` bytes
  from the current position, or all remaining bytes when length is zero. It
  grows the destination to `offset + length`, leaves destination position
  unchanged, and advances source position. Insufficient source data throws
  `EOFError`.
- `[x]` `readUTF()` reads an endian-sensitive unsigned 16-bit byte length then
  that many UTF-8 bytes. `readUTFBytes(length)` reads exactly the supplied raw
  byte count. Invalid/truncated input follows `haxe.io.Bytes.getString`
  decoding/EOF behavior. Internal `readLargeUTF()` uses a 32-bit length.
- `[x]` `readMultiByte(length, charSet)` ignores `charSet` and behaves as
  `readUTFBytes(length)`; portable 9.5.2 has the same limitation.

### Primitive writes

- `[x]` `writeBoolean` writes one byte `1` or `0`; `writeByte` writes the low 8
  bits; `writeShort` writes the low 16; `writeInt`/`writeUnsignedInt` write the
  32-bit bit pattern; and `writeInt64` writes high/low halves in selected byte
  order. All grow length and advance position.
- `[x]` `writeFloat`/`writeDouble` write IEEE-754 bit patterns in selected
  endian order.
- `[x]` `writeBytes(source, offset = 0, length = 0)` writes the requested slice
  at current position; zero length means all bytes after offset. Source
  position is ignored and unchanged. Runtime byte-blit bounds behavior applies
  to an invalid offset/length.
- `[x]` `writeUTF(value)` UTF-8 encodes the string, writes a 16-bit byte length,
  and throws `RangeError` above 65535 bytes. `writeUTFBytes(value)` writes no
  prefix. Internal `writeLargeUTF` uses a 32-bit length.
- `[x]` `writeMultiByte(value, charSet)` ignores `charSet` and writes UTF-8,
  matching portable 9.5.2.
- `[x]` `toString()` decodes the entire logical byte sequence, independent of
  current position, using the underlying Bytes string conversion. Portable
  code does not implement the documented system-code-page/BOM matrix.

### Object formats

- `[x]` `objectEncoding` selects the wire format. `HXSF` and `LARGE_HXSF` use
  Haxe `Serializer`/`Unserializer` with 16-bit and 32-bit byte-length prefixes;
  `JSON` and `LARGE_JSON` use JSON with the same prefix choices. Serialization
  writes at current position; deserialization consumes one complete value.
- `[!]` In OpenFL 9.5.2, `AMF0` and `AMF3` use internal AMF readers/writers.
  The adapter's `writeObject` emits nothing and `readObject` returns null for
  both without advancing position. Flight exposes no selectable AMF serializer;
  see **Object wire formats**.
- `[x]` Unknown object encoding values make `writeObject` a no-op and
  `readObject` return null.

### Compression and atomics

- `[x]` `compress(algorithm = ZLIB)` replaces the entire logical array with
  compressed bytes, independent of position, and sets position to the new end.
  `uncompress(algorithm = ZLIB)` replaces the entire array with decoded bytes
  and sets position to zero. `deflate()` and `inflate()` select raw RFC 1951
  framing; ZLIB selects RFC 1950 framing.
- `[x]` ZLIB and raw deflate encode through Haxe and decode through Flight while
  preserving those in-place length/position rules.
- `[!]` LZMA compression/decompression is a deterministic no-op in the adapter
  (`compress` preserves data/position; `uncompress` preserves data but resets
  position to zero). OpenFL 9.5.2 delegates real LZMA to Lime. See **Byte
  compression encoders and LZMA**.
- `[ ]` Invalid compressed input is documented to throw `IOError`. The Flight
  decoder failure surface and adapter do not consistently translate every
  invalid stream into that OpenFL error.
- `[!]` `shareable`, `atomicCompareAndSwapIntAt`, and
  `atomicCompareAndSwapLength` are Flash 11.4-only declarations. They operate
  on shared memory atomically on Flash and are deliberately absent off Flash;
  see **Shareable ByteArray atomics**.
- `[!]` UTF uses Haxe Bytes because the refreshed generated Flight facade has
  no public codec binding; observable UTF-8 behavior is present, but see
  **Public flight-hx UTF-8 byte codec binding** for the substrate limitation.
- `[x]` `CompressionAlgorithm` values are `DEFLATE = "deflate"`, `LZMA =
  "lzma"`, and `ZLIB = "zlib"` (legacy integer values 0, 1, 2).

## Data interfaces

- `[x]` `IDataInput` requires read-only `bytesAvailable`, mutable `endian` and
  `objectEncoding`, and the complete read family: boolean, signed/unsigned
  integers, float/double, bytes, multibyte, UTF/UTFBytes, and object. Implementors
  must consume sequential input and signal insufficient data; the interface
  supplies no implementation.
- `[x]` `IDataOutput` requires mutable `endian` and `objectEncoding` and the
  matching write family. `writeBytes` reads a source slice; other methods encode
  a value according to byte order/format.
- `[x]` `IExternalizable` requires `writeExternal(output)` and
  `readExternal(input)`. Object serializers call user code to define field order
  and encoding; read must mirror write. The interface itself adds no framing.

## Timers and scheduled callbacks

### `Timer`

- `[x]` `new(delay, repeatCount = 0)` begins stopped with `currentCount = 0`.
  Negative or NaN delay throws `openfl.errors.Error`; the implementation does
  not reject positive infinity despite documentation saying finite. Zero is
  accepted; values below 20 ms are only discouraged, not clamped.
- `[x]` `start()` starts only if not already running; repeated calls while
  running do nothing and do not reset phase/count. `stop()` cancels future
  ticks, sets `running = false`, and preserves `currentCount`. Starting again
  continues the remaining repetitions.
- `[x]` `reset()` stops if necessary and returns `currentCount` to zero.
- `[x]` Every tick increments count before dispatching `TimerEvent.TIMER`.
  With positive `repeatCount`, the final tick first stops the Timer, dispatches
  `TIMER`, then dispatches `TIMER_COMPLETE`. Repeat count zero runs indefinitely.
- `[x]` Changing `delay` while running stops and restarts the underlying host
  interval while preserving count. The setter performs no validation. Changing
  `repeatCount` to a nonzero value less than or equal to current count stops
  immediately without a completion event; other values are stored verbatim.
- `[x]` A TimerEvent whose `updateAfterEvent()` flag was set requests a stage
  render after that individual dispatch when a current stage exists.

### `Lib.setTimeout` / `setInterval`

- `[x]` These are static `openfl.Lib` helpers, included here because they are
  the package's scheduling convention. Each increments a process-local UInt ID,
  stores a Haxe Timer, and invokes `closure` via `Reflect.callMethod` with the
  supplied `args` array or no arguments when null.
- `[x]` `setTimeout` runs once after the delay and removes its ID before calling
  the closure. `setInterval` runs until cleared. `clearTimeout(id)` and
  `clearInterval(id)` are behaviorally identical: if the ID exists they stop
  and remove it; unknown/already-fired IDs are no-ops.
- `[x]` Callback exceptions propagate normally unless a current Stage has
  enabled uncaught-error events, in which case they are routed through the
  stage error handler.

## `Dictionary`

- `[x]` `new(weakKeys = false)` chooses a backing map from the compile-time key
  type: strings and integers use value maps, object keys use identity maps,
  enums use enum identity/value rules, floats use a sorted exact-equality map,
  and classes are keyed by fully qualified class name. Object lookup therefore
  does not coerce through `toString`.
- `[x]` `set`/array assignment replaces an existing mapping and returns the
  assigned value; `get`/array access returns its value or null; `exists`
  distinguishes absent from present-null; `remove` (the Haxe equivalent of
  ActionScript `delete`) returns whether a mapping existed.
- `[x]` `iterator()` yields keys, `each()` yields values, and
  `keyValueIterator()` yields pairs. Order is unspecified (float keys happen to
  be sorted by the implementation and must not be generalized to other key
  types); iterator mutation guarantees come from the backing Haxe map.
- `[x]` Non-Flash OpenFL 9.5.2 ignores `weakKeys`; object keys are strongly held
  and are not removed by GC. Only the Flash typedef supplies true weak-key
  semantics. The adapter matches this target distinction.

## Asset registry

### `Assets`

- `[x]` `cache` is a replaceable global `IAssetCache`, initially an enabled
  `AssetCache`. On the 9.5.2 Lime tools path, synchronous bitmap/font/sound
  getters consult it only when `useCache` and `cache.enabled` are true, reject
  invalid disposed cached bitmap data where detectable, then cache a
  successfully resolved asset.
- `[ ]` The adapter also consults a manually populated bitmap/font/sound cache
  without Lime, while stock 9.5.2 compiles those cache checks only into its Lime
  tools path and otherwise returns its ordinary fallback.
- `[x]` `exists(id,type = null)`, `isLocal(id,type = null,useCache = true)`, and
  `list(type = null)` query the Lime registry on a Lime build.
- `[ ]` Without Lime, 9.5.2 returns false from `exists`/`isLocal` and an empty
  list. The adapter instead has a registered-library resolver supporting
  `library:symbol` IDs (and the default library when unqualified).
- `[x]` `getBitmapData` returns a cached/resolved BitmapData or null;
  platform-dependent instances may share backing image data. `getBytes`
  returns the binary ByteArray or null. `getText` and `getPath` return a string
  or null.
- `[x]` `getFont` returns cached/resolved font, but returns a newly constructed
  empty Font when no font resolves. `getSound` returns cached/resolved Sound or
  null. `getMusic` attempts a streaming-friendly Vorbis path where compiled,
  otherwise aliases `getSound`.
- `[!]` Flight has no progressively buffered music source, so `getMusic` uses a
  decoded Sound. See **OpenFL asset registry and streaming music**.
- `[x]` `getMovieClip("library:symbol")` resolves an AssetLibrary, requires a
  local `MOVIE_CLIP`, and returns the clip; missing library/symbol or an
  async-only symbol logs and returns null.
- `[x]` `loadBitmapData`, `loadBytes`, `loadFont`, `loadLibrary`, `loadMusic`,
  `loadMovieClip`, `loadSound`, and `loadText` return Futures. They complete
  from cache immediately where applicable, otherwise forward backend complete,
  error, and progress; fallback targets return an already completed sync getter
  (except unsupported library loading, which is an error Future).
- `[x]` On Lime, `registerLibrary(name,library)` installs/replaces a library;
  `getLibrary`/`hasLibrary` inspect it; `unloadLibrary` unloads and removes it.
  Library change propagation dispatches `Event.CHANGE`. `registerBinding` and
  `unregisterBinding` map generated class names to an AssetLibrary;
  `initBinding` binds a current/future Sprite constructor or logs when absent.
- `[ ]` Without Lime, 9.5.2's library register/get/has/unload paths are
  no-ops/null/false. The adapter deliberately makes those operations functional
  with an in-process map, expanding the executable no-Lime contract.
- `[x]` Static `addEventListener`, `removeEventListener`, `hasEventListener`, and
  `dispatchEvent` delegate to one private global EventDispatcher. Adding a
  listener also hooks Lime's change signal once.

### `AssetCache` / `IAssetCache`

- `[x]` A new cache has `enabled = true` and separate public maps for bitmap
  data, fonts, and sounds. Toggling enabled does not clear or prevent direct
  cache method use; `Assets` decides whether to consult it.
- `[x]` `getBitmapData`/`getFont`/`getSound`,
  `hasBitmapData`/`hasFont`/`hasSound`,
  `setBitmapData`/`setFont`/`setSound`, and
  `removeBitmapData`/`removeFont`/`removeSound` are direct ID map operations;
  remove returns whether an item existed. `clear()` replaces all three maps;
  `clear(prefix)` removes every key beginning with that exact case-sensitive
  prefix. Cached objects are not cloned or disposed.
- `[x]` `IAssetCache` is exactly this property/method contract and does not
  prescribe eviction, ownership, or thread safety.

### `AssetLibrary`, `AssetManifest`, and `AssetType`

- `[x]` With Lime, AssetLibrary wraps or proxies a Lime library.
  `exists/getAsset/getAudioBuffer/getBytes/getFont/getImage/getPath/getText/
  isLocal/list`, their async `load*` counterparts, `load()`, and `unload()`
  forward to the proxy or superclass. `getMovieClip` returns null and
  `loadMovieClip` is an immediately completed null Future unless a subclass
  provides authored symbols. `bind` returns false in the base class.
- `[x]` `fromBundle`, `fromBytes`, `fromFile`, and `fromManifest` synchronously
  create/wrap a library where Lime supports it, else return null. Matching
  `loadFromBytes`, `loadFromFile`, and `loadFromManifest` return Futures;
  invalid manifest loading is an error Future. On no-Lime builds these factories
  return null (or completed-null Futures), `bind` returns false, and movie-clip
  access returns null.
- `[ ]` Most other AssetLibrary query/load/unload methods are not declared at
  all by no-Lime 9.5.2 because they are inherited from Lime inside compile
  guards. The adapter adds `exists`, `getPath`, `isLocal`, `list`, and `unload`
  stubs so the no-Lime asset registry has a usable surface.
- `[x]` AssetManifest `addBitmapData`, `addBytes`, `addFont`, `addSound`, and
  `addText` append preload entries, defaulting ID to path/name or the first sound
  path. `fromBytes`, `fromFile`, `parse`, and asynchronous load variants delegate
  to Lime and return null off Lime. In stock no-Lime 9.5.2, the private asset
  array is never initialized, so calling `add*` there fails; the unchanged
  adapter preserves that quirk.
- `[x]` `AssetType` string values are `BINARY`, `FONT`, `IMAGE`, `MOVIE_CLIP`,
  `MUSIC`, `SOUND`, `TEMPLATE`, and `TEXT`. MUSIC and SOUND currently behave
  alike. `AssetBundle` aliases Lime's bundle when available and `Dynamic`
  otherwise.

## `AGALMiniAssembler`

- `[x]` `new(debugging = false)` initializes shared opcode/sampler maps once,
  records whether to log detailed assembly, leaves `verbose` at false, and
  exposes the last `agalcode` and `error`.
- `[x]` `assemble(mode, source, version = 1, ignoreLimits = false)` accepts only
  exact lowercase `"vertex"` or `"fragment"`; invalid mode records an error.
  It starts output with AGAL version/program headers, strips `//` comments,
  ignores blank/unrecognized lines with warnings, assembles recognized lines,
  and returns little-endian ByteArray bytecode.
- `[x]` Supported opcodes are `mov add sub mul div rcp min max frc sqt rsq pow
  log exp nrm sin cos crs dp3 dp4 abs neg sat m33 m44 m34 kil tex sge slt sgn
  seq sne`; version 2 adds `ddx ddy ife ine ifg ifl els eif`. It validates
  operand count, stage restrictions, nesting (maximum 4), register access and
  ranges, destination masks, source swizzles, matrix operands, relative vertex
  addressing/offset 0..255, and a maximum 4096 opcodes. Any fatal error appends
  source line context and clears `agalcode` to length zero.
- `[x]` Registers are `va`, `vc`, `vt`, `vo/op`, `vi/i/v/fi`, `fc`, `ft`, `fs`,
  `fo/oc`, `fd/od`, and `iid`, with version-specific index limits. Fragment
  relative addressing and relative destinations are rejected.
- `[x]` Texture options encode type (`rgba`, `compressed/dxt1`,
  `compressedalpha/dxt5`, `video`), dimension (`2d`, `3d`, `cube`), mip mode,
  nearest/linear/anisotropic filters, centroid/single/ignoresampler, wrap/clamp
  variants, and numeric LOD bias (stored in eighths). Unknown option text is
  parsed as a numeric bias.
- `[!]` `assemble2(context3D,version,vertexSource,fragmentSource)` assembles both
  programs, creates Program3D, calls upload, and returns it. The assembler and
  resource shell work, but executing that program is blocked by **Raw Context3D
  command model**.

## Remaining public utility types

- `[x]` `Endian.BIG_ENDIAN = "bigEndian"` means most-significant byte first;
  `LITTLE_ENDIAN = "littleEndian"` means least-significant byte first (legacy
  integer values 0 and 1). The constants do not themselves change host order.
- `[x]` `Function` aliases `haxe.Constraints.Function` (Dynamic on legacy Haxe).
  It adds no invocation semantics.
- `[x]` `Namespace` exposes read-only `prefix` and `uri`. No args produces two
  empty strings; one Namespace copies it; one QName produces null prefix and
  its URI; another single value becomes URI with null prefix. With two args,
  prefix is stringified and becomes null if nonempty/invalid XML name, while a
  QName second arg contributes its URI; otherwise the URI is stringified.
- `[x]` `QName` exposes read-only `uri` and `localName`. No args produces empty
  strings; one QName copies it; another single value becomes local name with an
  empty URI. With two args, Namespace contributes URI (null stays null), QName
  contributes localName, and other values stringify.
- `[x]` `Object` is a Dynamic-compatible abstract. `new()` creates `{}`;
  `hasOwnProperty` uses Reflect fields; `isPrototypeOf(theClass)` walks the
  runtime class/superclass chain; `propertyIsEnumerable` returns true only for
  an owned field whose value implements the target Iterable marker;
  `toString/toLocaleString` return `Std.string` (null stays null); and `valueOf`
  returns itself. Field/array access uses reflection and named children of a
  DisplayObjectContainer as a fallback; iteration yields array values or
  reflected field/named-child keys.
- `[x]` `ObjectPool` (or its Lime alias) tracks `activeObjects`,
  `inactiveObjects`, and optional maximum/preallocated `size`. `add` cleans and
  admits a unique inactive object; `get` reuses inactive then calls dynamic
  `create` if below capacity; `release` decrements active and cleans/caches or
  removes above capacity; `remove` forgets either state; `clear` empties all.
  Setting size shrinks inactive objects first or calls `create` to prefill.
- `[x]` `PerspectiveMatrix3D` extends Matrix3D; `new(v = null)` forwards the
  optional 16-element raw vector to `Matrix3D`. `lookAtLH` and `lookAtRH`
  overwrite it with the corresponding normalized camera basis and eye dot
  products. `orthoLH`, `orthoRH`, `orthoOffCenterLH`, `orthoOffCenterRH`,
  `perspectiveFieldOfViewLH`, `perspectiveFieldOfViewRH`, `perspectiveLH`,
  `perspectiveRH`, `perspectiveOffCenterLH`, and `perspectiveOffCenterRH`
  overwrite all 16 elements with their named projection formulas. The 9.5.2
  `orthoRH` implementation contains `1 / (zNear - zNear)`, producing an
  infinite depth coefficient; the unchanged adapter preserves this observable
  defect.
- `[ ]` Without Lime, stock 9.5.2 `Future` is a minimal shell: `withValue` and
  `withError` set terminal fields; `onComplete`, `onError`, and `onProgress` do
  nothing; `ready` returns itself; `result` returns value; and `then` returns a
  new unresolved Future. The adapter improves immediate and queued listener
  delivery for Promise use but retains the unresolved `then`; with Lime, both
  versions alias the full Lime Future.
- `[x]` `Promise` owns a read-only Future. `complete` wins unless already
  errored, `error` wins unless already completed, both synchronously notify the
  appropriate listeners, and `progress` notifies only while pending.
  `completeWith` forwards another Future's complete/error/progress. Methods
  return the same Promise; `isComplete/isError` mirror the Future.
