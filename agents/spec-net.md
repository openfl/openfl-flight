# `openfl.net` behavioral specification

Reference: the non-Flash branch of `src/openfl/net/` in the OpenFL 9.5.2
distribution. On Flash, most types alias the native `flash.net` class and
inherit Flash Player/AIR behavior.

Status describes `src/openfl/net/`:

- `[x]` implements the executable OpenFL 9.5.2 contract.
- `[ ]` is missing, divergent, or unclear.
- `[!]` is blocked by the cited public Flight gap in `agents/flight-gaps.md`.

Declarations commented out or enclosed in `#if false` are documented as
Flash-only/absent, not treated as portable 9.5.2 methods. This matters for much
of `NetConnection` and server/Data Generation Mode `NetStream`.

## URL requests and loading

### `URLRequest`

- `[x]` `new(url = null)` stores a non-null URL, initializes `method` to
  `GET`, `requestHeaders` to a fresh empty array, `contentType` to null,
  `followRedirects`, `manageCookies`, and `userAgent` from
  `URLRequestDefaults`, and `withCredentials` to false. `idleTimeout` comes
  from a positive default; otherwise it is the `lime-default-timeout` define or
  `30000` ms.
- `[x]` `url`, `method`, `data`, `contentType`, `requestHeaders`,
  `followRedirects`, `manageCookies`, `withCredentials`, `idleTimeout`, and
  `userAgent` are mutable data properties with no validation in this class.
- `[x]` Consumers interpret `data` by method: GET appends encoded variables to
  the query; other methods send data in the body. `URLVariables`/dynamic data is
  form encoded, string data is sent as text, and byte data is binary when the
  backend accepts it. `contentType` becomes `Content-Type`; request headers are
  forwarded subject to host/browser restrictions.
- `[x]` `URLRequestMethod` constants are the strings `DELETE`, `GET`, `HEAD`,
  `OPTIONS`, `POST`, and `PUT`.
- `[x]` `URLRequestDefaults.followRedirects = true`, `idleTimeout = 0`,
  `manageCookies = true`, and `userAgent = null` are mutable static defaults
  copied only when a request is constructed; later default changes do not
  mutate existing requests.
- `[ ]` `authenticate` and `cacheResponse` occur in the broader AIR API but are
  not declared by non-Flash OpenFL 9.5.2. `digest` and `useRedirectedURL` are
  likewise compiled out. The adapter intentionally does not add them.
- `[x]` `URLRequestHeader.new(name = "", value = "")` stores its two mutable
  strings without validation. Header restrictions are enforced, if at all, by
  the transport.

### `URLLoader`

- `[x]` `new(request = null)` initializes byte counters to `0`, `dataFormat`
  to `TEXT`, and `data` to null; a non-null request starts loading immediately.
- `[x]` `dataFormat` accepts `TEXT`, `BINARY`, or `VARIABLES`. Completion data
  is respectively `String`, `ByteArray`, or a decoded `URLVariables`; changing
  the format while a request is pending affects completion decoding.
- `[x]` `load(request)` synchronously dispatches `Event.OPEN`, transfers the
  request method/body/content type/headers/redirect, timeout, cookie credential,
  and user-agent options, and dispatches backend `ProgressEvent.PROGRESS`
  notifications while downloading.
- `[x]` The actual 9.5.2 success tail is `HTTP_RESPONSE_STATUS -> HTTP_STATUS ->
  COMPLETE`, after any progress events. Both status events are emitted only
  once the complete response is available, not at connection/open time;
  `HTTP_RESPONSE_STATUS` carries response URL and response headers, while
  `HTTP_STATUS` carries only the numeric status.
- `[x]` The current Flight path preserves that final status order. Flight does
  not expose status/headers before the completed body; see **URLLoader/URLStream
  cancellation, chunks, and early response metadata**.
- `[x]` Transport/decode failure dispatches `IOErrorEvent.IO_ERROR`. The 9.5.2
  Neko path special-cases numeric error `403` as `SecurityErrorEvent`; the
  current adapter treats HTTP response 403 as `securityError` on all targets
  and other unsuccessful statuses as `ioError`. A successful response stores
  `data` before `complete`; an unsuccessful response may store decoded data
  before its error event in the current adapter.
- `[x]` Although progress event objects carry byte counts, the executable
  9.5.2 handlers never assign those values to the public `bytesLoaded` and
  `bytesTotal` fields; they remain zero. The current adapter preserves this
  quirk. Missing/unknown content length appears as a zero event total.
- `[!]` `close()` cancels Lime's HTTP request in 9.5.2. The current method
  invalidates callbacks, so no later progress/completion/error is observed, but
  cannot abort the Flight transport. Calling it with no active load is a no-op
  rather than the documented invalid-stream exception. See **URLLoader/URLStream
  cancellation, chunks, and early response metadata**.
- `[!]` Flight's public default HTTP backend is available on the web host;
  native operation depends on a maintained Lime/Clay host installing a backend.
  See the same gap entry.
- `[x]` `URLLoaderDataFormat` string values are `BINARY = "binary"`, `TEXT =
  "text"`, and `VARIABLES = "variables"` (legacy integer values 0, 1, 2).

### `URLStream`

- `[x]` `new()` creates an empty stream whose intended byte order is
  `Endian.BIG_ENDIAN`. `objectEncoding` is a mutable field and otherwise has
  the target's default null/zero initialization until assigned.
- `[x]` `load(request)` starts a binary request. Portable 9.5.2 listens only to
  its internal loader's `progress`, `complete`, `ioError`, and `securityError`;
  it does **not** forward `open`, `httpStatus`, or `httpResponseStatus`, despite
  those events appearing in the API prose. The adapter matches this event
  surface.
- `[x]` On success, the complete response becomes the internal `ByteArray`, a
  final progress event is dispatched, then `Event.COMPLETE`. `bytesAvailable`
  is `data.length - data.position` or zero with no data.
- `[!]` The documentation promises incremental readable chunks, but 9.5.2's
  internal URLLoader normally has no `data` until completion. Flight progress
  has counts but no chunk and likewise cannot make bytes readable early. See
  **URLLoader/URLStream cancellation, chunks, and early response metadata**.
- `[x]` `connected` always returns `false` in portable 9.5.2 and in the adapter;
  it is not a loading-state property.
- `[x]` `readBoolean`, `readByte`, `readBytes`, `readDouble`, `readFloat`,
  `readInt`, `readMultiByte`, `readShort`, `readUnsignedByte`,
  `readUnsignedInt`, `readUnsignedShort`, `readUTF`, and `readUTFBytes` delegate
  exactly to the current internal ByteArray, consuming its position and throwing
  `EOFError` for insufficient data. Calling while data is null fails by null
  access rather than a purpose-built IOError.
- `[x]` `readObject()` returns null unconditionally in the executable portable
  9.5.2 source; the adapter retains that stub. The `objectEncoding` value is
  copied to loaded data but not used by this method.
- `[x]` `endian` reads/writes the internal ByteArray. Before the first `load`,
  the 9.5.2 getter and setter dereference null; the adapter setter safely
  remembers the value but the getter retains the null-data quirk. During/after
  load, byte-order changes affect all numeric reads.
- `[!]` `close()` removes listeners and clears readable data in 9.5.2; the
  adapter also suppresses stale callbacks but cannot abort Flight transport.

### `URLVariables`

- `[x]` `new(source = null)` creates an empty dynamic object and calls
  `decode(source)` for non-null input. Fields are accessible dynamically and by
  string array access.
- `[x]` `decode(source)` first deletes every existing field, splits on `&`,
  URL-decodes names and values, maps a segment without `=` to an empty string,
  ignores a segment beginning with `=`, and treats only the first `=` as the
  separator. Duplicate names overwrite earlier values; they do not create an
  array. `+` behavior follows `StringTools.urlDecode`.
- `[x]` `toString()` enumerates fields in runtime reflection order (not a
  promised stable order), URL-encodes each name and `Std.string(value)`, joins
  pairs with `&`, and emits empty objects as `""`. A field whose name contains
  `[]` and whose value is an array uses the source's unusual
  `&amp;field=` separator between encoded elements.

## Stream and datagram sockets

### `Socket`

- `[x]` `new(host = null, port = 0)` initializes input/output ByteArrays,
  `endian = BIG_ENDIAN`, `objectEncoding = ByteArray.defaultObjectEncoding`,
  and `timeout = 20000` ms. A non-null host immediately calls `connect`.
- `[x]` `connect(host, port)` validates port range, replaces any previous
  connection/buffers, begins nonblocking connection, and later dispatches
  `Event.CONNECT`; invalid host/failed or timed-out connection dispatches
  `IOErrorEvent.IO_ERROR`. HTML5 uses Flight's WebSocket-shaped transport;
  native sys targets retain a raw Haxe TCP socket.
- `[x]` `connected` reflects established transport state. `localAddress`,
  `localPort`, `remoteAddress`, and `remotePort` come from the connected
  endpoint and return their platform defaults when unavailable. `timeout`
  governs connection establishment, not individual reads.
- `[x]` Incoming bytes append to the input buffer and dispatch
  `ProgressEvent.SOCKET_DATA` with `bytesLoaded` equal to the newly received
  count. `bytesAvailable` is unread input length; data remains until consumed.
  Remote close dispatches `Event.CLOSE`; I/O failure dispatches `ioError`.
- `[x]` All `readBoolean/readByte/readBytes/readDouble/readFloat/readInt/
  readMultiByte/readObject/readShort/readUnsignedByte/readUnsignedInt/
  readUnsignedShort/readUTF/readUTFBytes` methods delegate to the input
  ByteArray. They share its position, endian, EOF, character-set, and object
  encoding semantics.
- `[x]` `writeBoolean`, `writeByte`, `writeBytes`, `writeDouble`, `writeFloat`,
  `writeInt`, `writeMultiByte`, `writeObject`, `writeShort`, `writeUnsignedInt`,
  `writeUTF`, and `writeUTFBytes` append to the output ByteArray without sending
  immediately. `bytesPending` is that queued byte count. `flush()` sends all
  queued bytes and clears the queue; it is a no-op when nothing is queued and
  fails according to the underlying invalid socket otherwise.
- `[x]` Changing `endian` updates both existing input and output buffers.
  `objectEncoding` is consulted by `readObject/writeObject`; see the AMF gap in
  the utils specification.
- `[x]` `close()` closes and cleans the transport and polling. Calling close on
  an invalid/already closed native socket may throw `IOError`, matching the
  9.5.2 implementation's platform-dependent path.
- `[!]` A native raw TCP Flight binding is not exposed, so sys targets retain
  `sys.net.Socket`; browsers necessarily use WebSocket framing. See **Raw TCP
  flight-hx binding on native hosts**.

### `XMLSocket`

- `[x]` `new(host = null, port = 80)` creates an internal Socket, registers
  forwarding listeners, initializes `connected = false`, and optionally begins
  connecting. `timeout` is copied to the Socket when connecting.
- `[x]` The internal `connect`, `close`, `ioError`, `securityError`, and
  `socketData` lifecycle is forwarded. Connect sets `connected = true`; close
  sets it false.
- `[x]` `send(object)` writes `Std.string(object)` followed by one null byte and
  flushes. Incoming UTF-8 text is accumulated across packets, split at null
  delimiters, and each complete message dispatches `DataEvent.DATA`; delimiters
  are not included and an incomplete tail is retained.
- `[!]` On HTML5 this framing travels over WebSocket, not a traditional raw TCP
  XMLSocket server. See **XMLSocket servers on HTML5**.

### `DatagramSocket`

- `[!]` The class exists only for non-HTML5 sys builds. `isSupported` is true
  there and false/absent on unsupported targets. Flight has no UDP capability,
  so the adapter retains `sys.net.UdpSocket`; see **UDP datagram sockets**.
- `[x]` `new()` creates a nonblocking unbound, unconnected UDP socket.
  `bind(localPort = 0, localAddress = "0.0.0.0")` synchronously validates the
  0..65535 port, binds, fills `localAddress/localPort`, and sets `bound`. An
  unresolved address throws `ArgumentError`; bind failure follows the 9.5.2
  close/error path.
- `[x]` `connect(remoteAddress, remotePort)` establishes the UDP peer filter
  (and implicit binding where supported); it does not establish a reliable
  stream. `connected`, `remoteAddress`, and `remotePort` query the socket peer.
  The 9.5.2 code accidentally validates `localPort` rather than the supplied
  remote port before connecting; the adapter retains this quirk.
- `[x]` `receive()` enables polling and returns immediately. Each datagram
  dispatches `DatagramSocketDataEvent.DATA` with source/destination address and
  port plus a ByteArray containing exactly that packet. Delivery order and loss
  are UDP-defined; no retransmission or segmentation is supplied.
- `[x]` `send(bytes, offset = 0, length = 0, address = null, port = 0)` sends the
  remaining bytes when length is zero. Bounds/port errors throw `RangeError`.
  A connected socket requires null destination; an unconnected socket requires
  an address/port. Conflicting use throws `IllegalOperationError` or
  `ArgumentError`; transport failures become `IOError`.
- `[x]` `close()` stops receive polling, unbinds/disconnects, sets `bound`
  false, and dispatches `Event.CLOSE`; repeated underlying close errors are
  swallowed.

### `ServerSocket` and `SecureSocket`

- `[x]` `ServerSocket` is non-HTML5 only. It begins unbound/not listening;
  `bind(port = 0, address = "0.0.0.0")` validates and records the chosen local
  endpoint, `listen(backlog = 0)` begins nonblocking accepts (zero requests the
  platform maximum), and `close()` clears bound/listening state. Each accepted
  TCP client dispatches `ServerSocketConnectEvent.CONNECT` carrying an already
  connected OpenFL Socket. Invalid state/range/address produces the documented
  `IOError`, `RangeError`, or `ArgumentError` paths.
- `[x]` `SecureSocket` extends Socket using a native sys TLS socket.
  `isSupported` reports platform TLS support; `connect` performs certificate
  validation before `Event.CONNECT`, otherwise emits `ioError`.
  `serverCertificate` converts the peer certificate's subject, issuer, and
  validity dates and throws on an invalid socket; `serverCertificateStatus` is
  `UNKNOWN`, then `TRUSTED` or `INVALID`. The public
  `addBinaryChainBuildingCertificate` declaration follows the platform's
  supported/no-op or `ArgumentError` behavior.

## Local files

### `FileReference`

- `[x]` A new reference has null `creationDate`, `creator`, `data`,
  `modificationDate`, `name`, `type`, and `extension`, with numeric `size` at
  its target default. Selection populates available name (`without directory`),
  dates, byte size, and dot-prefixed `type`; `extension` returns the suffix
  without a dot or null. Browser metadata may not provide creation separately,
  so 9.5.2 uses modification time for both.
- `[ ]` `browse(typeFilter = null)` clears prior selected data/path, converts
  `FileFilter` patterns, opens a single-select host dialog, returns true when
  that operation is accepted, then dispatches `Event.SELECT` or `Event.CANCEL`.
  Unsupported 9.5.2 targets return false; the current no-host path returns true
  without an event, a divergence that remains unclear.
- `[x]` `load()` reads the selected file into `data` as a ByteArray and
  dispatches `Event.COMPLETE`, or `IOErrorEvent.IO_ERROR` on an asynchronous
  browser/host failure. Despite the API prose, portable 9.5.2 does not dispatch
  `open` or `progress` for local load; the adapter matches this lifecycle.
- `[x]` `save(data, defaultFileName = null)` ignores null data. ByteArray is
  written verbatim; all other data is `Std.string` UTF-8. The dialog dispatches
  cancel, or `select` after the user chooses a destination, followed by
  `complete` after the write. Host failure dispatches `ioError` in the adapter.
- `[!]` `download(request, defaultFileName = null)` in 9.5.2 combines binary
  URLLoader and save-dialog lifecycles, forwarding `open/progress/ioError` and
  dispatching `select/cancel/complete`. The adapter immediately dispatches
  `ioError`; Flight cannot compose a cancellable request with a streamed save
  destination. See **FileReference network transfers and cancellation**.
- `[!]` `upload(request, uploadDataFieldName = "Filedata", testUpload = false)`
  in 9.5.2 reads the selected file, rewrites the request as multipart POST,
  forwards open/progress/response/error, maps HTTP 200 to complete, and emits
  `DataEvent.UPLOAD_COMPLETE_DATA` with the response. The adapter immediately
  emits `ioError`; Flight lacks this multipart/cancellation workflow. `testUpload`
  is ignored by portable 9.5.2.
- `[!]` `cancel()` does not itself dispatch `cancel`. Portable 9.5.2 calls the
  active URLLoader's close; the adapter invalidates pending dialog/filesystem
  completions but cannot cancel the host operation. See the same gap.
- `[x]` `FileFilter.new(description, extension, macType = null)` simply stores
  its three mutable strings. Extension syntax can contain semicolon-separated
  patterns such as `*.png;*.jpg`; `macType` is legacy metadata.

### `FileReferenceList`

- `[x]` `new()` has no selection. `browse(typeFilter = null)` replaces
  `fileList` with a fresh array, opens a multi-select dialog, returns true when
  accepted, and dispatches cancel or one select after all references and
  available metadata are ready. Every selected item is a separate FileReference;
  callers must upload/load them individually.
- `[ ]` Unsupported-target return behavior has the same no-host true/no-event
  divergence as single-file browse. Host statistic failures dispatch `ioError`
  in the adapter rather than selecting references with partial metadata.

## Shared objects

- `[x]` `getLocal(name, localPath = null, secure = false)` validates that name
  is nonempty and excludes space and `~ % & \\ ; : \" ' , < > ? #`; failure
  throws Error #2134. It caches identity by `localPath + "/" + name`, so repeated
  calls return the same instance, loads persisted fields into dynamic `data`,
  and initializes `client = this`, `fps = 0`, and `objectEncoding` from the
  current static `defaultObjectEncoding`. `secure` is ignored.
- `[x]` `data` is an ordinary dynamic object. Direct field reads/writes are
  retained until `clear` or process/object loss. `setProperty(name, value =
  null)` sets a field; `setDirty(name)` is a no-op because the local format
  serializes the entire object.
- `[x]` `size` is the encoded byte count of current data, or zero if
  serialization fails. The portable implementation uses Haxe serialization,
  regardless of the public `objectEncoding` value.
- `[x]` `flush(minDiskSpace = 0)` returns `FLUSHED` for empty data or a
  successful local write. `minDiskSpace` is ignored. The Flight adapter returns
  `PENDING` if host persistence rejects/fails while retaining a process-local
  copy; 9.5.2's native file path normally reports `FLUSHED`.
- `[!]` There is no quota prompt and no later `NetStatusEvent` resolving a
  pending flush; see **SharedObject quota prompts and remote synchronization**.
- `[x]` `clear()` replaces `data` with a fresh empty object and deletes the
  persisted value. Existing external references to the previous data object do
  not become the new store. `close()` is a no-op.
- `[!]` Non-strict `getRemote()` returns null; `connect`, `send`, and `setDirty`
  are no-op stubs. Portable 9.5.2 provides no remote synchronization, and Flight
  has no replacement. The documented `netStatus`, `asyncError`, and `sync`
  lifecycles therefore never occur for this implementation.
- `[x]` `SharedObjectFlushStatus` values are `FLUSHED = "flushed"` and `PENDING
  = "pending"` (legacy 0 and 1). `ObjectEncoding.defaultObjectEncoding` is
  mutable and defaults to `HXSF` off Flash.

## `NetConnection`, `NetStream`, and companions

### `NetConnection`

- `[x]` The portable class exposes only `new()` and `connect(command, p1..p5)`.
  `connect(null)` synchronously dispatches a non-bubbling, cancelable
  `NetStatusEvent.NET_STATUS` whose `info.code` is
  `"NetConnection.Connect.Success"`; any non-null command throws the string
  `Error: Can only connect in "HTTP streaming" mode`. Optional arguments are
  ignored.
- `[x]` The executable portable surface has no `close`, `call`, `client`,
  `connected`, `connectedProxyType`, `defaultObjectEncoding`, `objectEncoding`,
  `proxyType`, `uri`, or `usingTLS`; these are commented declarations and exist
  only through the Flash typedef. The current source intentionally matches this
  limited 9.5.2 surface.
- `[x]` `Responder.new(result, status = null)` stores the callbacks privately
  for a Flash-style `NetConnection.call`, but the portable NetConnection has no
  call method and never invokes them.

### `NetStream`

- `[x]` `new(connection, peerID = null)` stores the connection and a default
  SoundTransform. On HTML5 it creates an anonymous, inline/cross-origin video
  element and attaches media callbacks; other targets create no decoder.
  `peerID` is ignored.
- `[x]` Portable public state consists of mutable/default fields `bufferTime`,
  `checkPolicyFile`, and `client`; read-only-by-convention fields `audioCodec`,
  `bufferLength`, `bytesLoaded`, `bytesTotal`, `currentFPS`, `decodedFrames`,
  `liveDelay`, `objectEncoding`, `time`, and the source's misspelled
  `videoCode`; plus get/set `soundTransform` and `speed`. Unassigned numeric
  fields remain zero, not the richer values promised by the Flash prose.
- `[x]` `play(url, p1..p5)` is functional only on HTML5: it applies global times
  local volume, assigns a string to video `src` or another value to `srcObject`,
  and calls play. Extra arguments are ignored. Other targets do nothing.
- `[!]` Cross-target decoding/frame delivery is unavailable; see **Cross-target
  NetStream video source**.
- `[x]` `pause()` pauses, `resume()` plays, and `togglePause()` switches the
  element state on HTML5; all are no-ops elsewhere. `seek(seconds)` clamps to
  `[0, duration]`, dispatches `NetStream.SeekStart.Notify`, assigns currentTime,
  and the later seeking callback dispatches `NetStream.Seek.Complete`.
- `[x]` `close()` pauses, clears `src`, marks closed, and resets `time` to zero
  on HTML5, but preserves the element/current frame object. `dispose()` calls
  close then releases the element, causing attached video to go blank.
- `[x]` `requestVideoStatus()` asynchronously invokes `client.onPlayStatus`
  with `NetStream.Play.pause` or `.playing` when an HTML element exists.
- `[x]` `soundTransform` getter returns a clone; assigning non-null copies only
  pan and volume and immediately updates HTML media volume. Pan is not applied.
  `speed` gets/sets HTML `playbackRate`, or reads `1` and discards writes on
  other targets.
- `[x]` HTML callbacks dispatch NetStatusEvent codes to both the connection and
  stream: playing -> `NetStream.Play.Start`; ended -> `NetStream.Play.Stop`
  then `NetStream.Play.Complete`; media error -> `NetStream.Play.Stop`;
  seeking completion -> `NetStream.Seek.Complete`. The same callbacks attempt
  `client.onPlayStatus` notifications for loadstart, waiting, stalled, canplay,
  canplaythrough, durationchange, pause, playing, seeking, timeupdate, error,
  and complete. `loadedmetadata` calls `client.onMetaData` with width, height,
  and duration. Missing handlers and exceptions are swallowed.
- `[ ]` `appendBytes`, `appendBytesAction`, `publish`, attach camera/audio,
  server streaming, and related status codes are all enclosed in `#if false` in
  non-Flash 9.5.2. They are Flash-only and absent from the adapter. There is no
  portable `audioCodec`/`videoCodec` discovery; note that 9.5.2 spells the
  latter field `videoCode`.

### Encoding and small value contracts

- `[x]` `ObjectEncoding` integer values are `AMF0=0`, `AMF3=3`, `HXSF=10`,
  `LARGE_HXSF=11`, `JSON=12`, `LARGE_JSON=13`; `DEFAULT` is AMF3 on Flash and
  HXSF elsewhere. `dynamicPropertyWriter` is a mutable static hook, though the
  current ByteArray AMF implementation cannot consume it.
- `[x]` `IDynamicPropertyOutput.writeDynamicProperty(name,value)` is the sink
  contract used by `IDynamicPropertyWriter.writeDynamicProperties(obj,output)`;
  the interfaces impose no ordering or storage themselves.
- `[x]` `IPVersion` values are `IPV4 = "IPv4"` and `IPV6 = "IPv6"` (legacy 0,
  1). These are selectors only; socket address-family validation remains a
  transport concern.
