# `openfl.media` behavioral specification

Reference: the non-Flash branch of `src/openfl/media/` in the OpenFL 9.5.2
distribution. On the Flash target these types are aliases to the corresponding
`flash.media` types, so Flash Player or AIR behavior supersedes the portable
behavior below.

Status describes the current `src/openfl/media/` implementation:

- `[x]` implements the OpenFL 9.5.2 observable contract.
- `[ ]` is missing, divergent, or not sufficiently established.
- `[!]` cannot be completed faithfully with the current public Flight surface;
  the named entry in `agents/flight-gaps.md` is the blocker.

The 9.5.2 source, rather than the broader Flash API documentation embedded in
that source, is normative here. In particular, declarations inside `#if false`
are not part of the portable API.

## `Sound`

- `[x]` `new(stream = null, context = null)` initializes `bytesLoaded` and
  `bytesTotal` to `0`, `isBuffering` to `false`, and `url` to `null`. A non-null
  request immediately calls `load(stream, context)`; a null request remains an
  empty sound that may be populated later.
- `[x]` `load(stream, context = null)` records `stream.url` literally (9.5.2
  does not normalize it to an absolute/final redirect URL) and marks a URL load
  in progress. `context.bufferTime` and `context.checkPolicyFile` are retained
  API inputs but are not consulted by the 9.5.2 portable loader.
- `[ ]` With Lime, `load` synchronously dispatches `Event.OPEN` before starting
  the backend future. Without Lime, 9.5.2 starts no future and dispatches no
  event; the adapter dispatches `open` on every target and then remains pending
  when it cannot resolve an HTTP/audio host.
- `[x]` A successful URL load dispatches any backend progress notifications,
  then a final `ProgressEvent.PROGRESS` whose loaded and total byte counts are
  equal, then `Event.COMPLETE`. A decode/load failure dispatches
  `IOErrorEvent.IO_ERROR`. Despite the class documentation, the portable 9.5.2
  implementation never populates ID3 data and never dispatches `Event.ID3`.
  Thus its actual success lifecycle is `open -> progress* -> complete`, not
  `open -> progress -> id3 -> complete`.
- `[ ]` The current loader leaves an opened load pending when no Flight HTTP or
  audio context host can be resolved, rather than completing or producing an
  IO error. On supported hosts it preserves the success/error lifecycle.
- `[ ]` `bytesLoaded`/`bytesTotal` begin at zero. 9.5.2 reports backend progress
  in events but never assigns those properties, including at completion, so
  they remain zero. The adapter instead assigns both to the final decoded
  resource byte size. `isBuffering` remains `false` throughout in both
  implementations.
- `[x]` `id3` returns a newly constructed, empty `ID3Info` on every access.
  Mutating one returned object does not persist to the next access.
- `[x]` `length` is the decoded duration in milliseconds, or `0` without a
  decoded resource. 9.5.2 derives it from PCM/sample metadata (or an encoded
  Vorbis/Howler duration); the Flight adapter reads resource duration.
- `[x]` `url` is null before loading and otherwise the request string assigned
  by `load`. `isURLInaccessible` is only a commented Flash declaration and is
  not available on the non-Flash 9.5.2 surface.
- `[ ]` `sampleRate` exists only under the HTML5 WebAudio or `lime_openal`
  compile conditions. 9.5.2 exposes the active WebAudio rate on HTML5 and
  `44100` for OpenAL; the adapter always reports `44100`, so it diverges when
  the browser context uses another rate.
- `[ ]` `close()` in 9.5.2 disposes an already decoded buffer and stops channels
  registered against it, but does not actually cancel the outstanding
  `AudioBuffer.loadFromFile` future. The adapter safely invalidates outstanding
  callbacks and disposes its Flight resource, but does not stop channels that
  already reference that resource.
- `[!]` True transport cancellation is unavailable; see **URLLoader/URLStream
  cancellation, chunks, and early response metadata**. The generation guard
  ensures that a closed load cannot later dispatch stale completion/error
  callbacks.
- `[!]` `fromFile(path)` is synchronous: 9.5.2 returns a decoded local `Sound`,
  throws `IOError` when decoding fails, and returns `null` where synchronous
  loading is unsupported. The adapter returns `null`; Flight decoding is
  promise-based. See **Synchronous audio file factories**.
- `[ ]` `fromAudioBuffer(buffer)` (available with Lime) returns a sound backed
  by that exact buffer. The current adapter additionally constructs a Flight
  PCM resource when `buffer.data` is resident, but lazy/encoded Lime buffers do
  not become playable Flight resources.
- `[ ]` `loadFromFile(path)` and `loadFromFiles(paths)` are asynchronous static
  factories returning a `Future<Sound>` that completes after Lime selects and
  decodes the file (or one supported alternative path). The current methods
  always return an error future even though Flight has asynchronous resource
  loading primitives.
- `[ ]` `loadCompressedDataFromByteArray(bytes, bytesLength)` reads exactly
  `bytesLength` bytes beginning at `bytes.position`, decodes them as compressed
  audio, and on success dispatches `open -> progress(complete counts) ->
  complete`; null/non-positive/undecodable input dispatches `ioError`. Neither
  implementation advances the source position as part of its explicit copy.
  The adapter additionally requires an active Flight audio context to decode,
  while 9.5.2 can construct the Lime buffer without an output context.
- `[ ]` `loadPCMFromByteArray(bytes, samples, format = "float", stereo = true,
  sampleRate = 44100)` uses `samples * channels * bytesPerSample` bytes beginning
  at the current position without advancing it. `"float"` selects 32-bit
  samples; every other format is treated as signed 16-bit `"short"`. `stereo`
  selects two channels, otherwise one. 9.5.2 passes the bytes through without
  consulting `ByteArray.endian`; the adapter normalizes each sample according
  to it, which diverges for big-endian input. On success both install the PCM
  buffer and synchronously send `open -> progress -> complete`; null input
  sends `ioError`.
- `[x]` `play(startTime = 0, loops = 0, sndTransform = null)` returns `null`
  after 32 active channels. Otherwise it returns a registered `SoundChannel`,
  clones/defaults the transform, seeks in milliseconds, applies global times
  local volume, and starts now or after a pending URL load.
- `[ ]` The documented `loops` value is the number of extra plays. The
  executable 9.5.2 path only assigns Lime's repeat count for values greater
  than one, using `loops - 1`; therefore `0` and `1` both play once, and `2`
  plays twice. Flight treats every positive value as an extra-play count, so
  the adapter plays twice for `1` and three times for `2`.
- `[ ]` During a URL load, 9.5.2 retains only the most recently requested
  pending channel/source; earlier calls return channels that never start. The
  adapter queues and starts every pending channel after load completion.
- `[!]` Native Lime playback may create logical channels but remain silent;
  see **Native Lime audio device backend**. Per-channel/global pan is also not
  forwarded; see **Per-channel audio pan binding and peak metering**.
- `[!]` Playing an empty `Sound` can drive `SampleDataEvent.SAMPLE_DATA` in the
  WebAudio/OpenAL 9.5.2 paths. The current `__startSampleData` is a no-op; see
  **Dynamic PCM sample streaming**.
- `[ ]` `extract(target, length, startPosition = -1)` is described by the Flash
  documentation as appending 44.1 kHz stereo 32-bit float pairs and returning
  the number of sample frames written, but is compiled out with `#if false` in
  portable 9.5.2. It is available only through the Flash typedef and is not
  supplied by the current non-Flash adapter.

## `SoundChannel`

- `[x]` Channels are created only by `Sound.play`; construction initializes
  `leftPeak` and `rightPeak` to the literal value `1`, installs a cloned/default
  transform, registers with `SoundMixer`, and starts a supplied source.
- `[x]` `position` is milliseconds. While valid, the getter reports source
  current time plus its initial offset and the setter seeks relative to that
  offset; after stop/completion both getter and setter return `0`. The Flight
  adapter exposes the channel's absolute current time and seeks directly, which
  yields the same public playhead for ordinary playback.
- `[x]` `soundTransform` getters return a clone, so callers must assign the
  modified value back. A non-null setter copies the supplied volume and pan;
  null is ignored. Volume updates immediately and is multiplied by the global
  mixer volume.
- `[!]` Pan updates are retained but not applied to Flight channels; peak
  metering is also absent. The constant `leftPeak == rightPeak == 1` matches the
  9.5.2 portable placeholder, not real peak levels. See **Per-channel audio pan
  binding and peak metering**.
- `[x]` `stop()` is idempotent, unregisters and disposes/stops the channel, and
  does not dispatch `Event.SOUND_COMPLETE`.
- `[x]` Natural exhaustion unregisters the channel and dispatches one
  `Event.SOUND_COMPLETE` from the channel. Explicit stop and failed load do not.

## `SoundMixer`

- `[x]` `bufferTime` is a mutable static integer whose portable default is `0`;
  the 9.5.2 implementation stores no relationship between it and playback.
- `[x]` `soundTransform` is global. It begins as `(volume=1, pan=0)` or volume
  zero under `mute`/`mute_sound`; assignment clones the value and immediately
  refreshes every registered channel. The getter exposes the stored object
  itself rather than a clone. Assigning null faults when the setter attempts to
  clone it.
- `[x]` Global volume composes multiplicatively with channel volume.
- `[!]` Global pan cannot be applied on the current Flight channel facade; see
  **Per-channel audio pan binding and peak metering**.
- `[x]` `stopAll()` walks the live channel list backwards and calls `stop()` on
  every channel. It does not dispatch completion events.
- `[x]` `areSoundsInaccessible()` always returns `false` in portable 9.5.2 and
  in the current adapter.
- `[ ]` `computeSpectrum(outputArray, FFTMode = false, stretchFactor = 0)` would
  write 512 native-endian floats (256 left then 256 right), either waveform
  samples or FFT magnitudes, on Flash. It is compiled out in portable 9.5.2 and
  absent from the adapter. Flight also exposes no mixer-level capture/spectrum
  facility.
- `[ ]` `audioPlaybackMode` is a Flash/AIR API concept, but 9.5.2 declares no
  non-Flash `SoundMixer.audioPlaybackMode` property. The adapter intentionally
  does not add one.

## `SoundTransform`

- `[x]` `new(vol = 1, panning = 0)` assigns those values verbatim and sets
  `leftToLeft`, `leftToRight`, `rightToLeft`, and `rightToRight` all to `0`.
- `[x]` `volume`, `pan`, and all four matrix fields are ordinary mutable
  `Float`s. Despite the documented ranges (`volume` 0..1, `pan` -1..1), this
  class performs no clamping. Sound playback clamps the sum of mixer and
  channel pan, but does not clamp volume.
- `[x]` The private compatibility `clone()` used by the media classes constructs
  `new SoundTransform(volume, pan)` and therefore does not preserve custom
  matrix fields. Portable 9.5.2 does not use the four matrix fields in audio
  routing; the adapter matches that behavior.

## `Video`

- `[x]` `new(width = 320, height = 240)` creates a non-interactive display
  object with logical bounds `(0,0,width,height)`, `smoothing = false`, and
  `deblocking = 0`. Although the prose says zero dimensions fall back to the
  defaults, the 9.5.2 code stores zero verbatim; the adapter does likewise.
- `[x]` Setting inherited `width` or `height` resets the corresponding scale to
  `1` and changes the logical video surface dimension. Reading returns logical
  size times scale. These changes do not dispatch `Event.RESIZE`; 9.5.2 has no
  Video-specific resize event path.
- `[x]` `deblocking` is a mutable integer (documented values 0 through 5) and
  `smoothing` is a mutable boolean. Portable 9.5.2 stores both; its HTML texture
  renderer uses the display smoothing state but does not implement codec
  deblocking.
- `[ ]` The Flight video sprite retains both properties but currently does not
  propagate either to texture sampling/decoding, so scaled video smoothing is
  not established.
- `[x]` `attachNetStream(stream)` replaces the association; passing null
  detaches it. On HTML5, 9.5.2 begins the attached element playing, while the
  current adapter connects its HTML video element to a Flight video resource
  and texture (playback is driven by `NetStream.play`).
- `[!]` `videoWidth`/`videoHeight` report the attached stream's intrinsic pixel
  size, or `0` before metadata/no stream. That works for the HTML video resource;
  other targets remain zero. See **Cross-target NetStream video source**.
- `[ ]` `clear()` is an empty stub in portable 9.5.2: it does not close or
  detach the stream and does not actually erase the current frame. The adapter
  resets its Flight texture, so it does erase the displayed frame.
- `[x]` Bounds and hit tests use the logical rectangular surface, transformations,
  and visibility. Because Video is not an `InteractiveObject`, it is not itself
  an interactive event target.
- `[ ]` `attachCamera` is compiled out in non-Flash 9.5.2 and remains absent.

## Value and context types

- `[x]` `SoundLoaderContext.new(bufferTime = 1000, checkPolicyFile = false)`
  stores both values verbatim. `bufferTime` is milliseconds. Portable Sound
  ignores both settings, so no policy-file event or delayed buffering behavior
  follows from them.
- `[x]` `ID3Info.new()` leaves its mutable string fields `album`, `artist`,
  `comment`, `genre`, `songName`, `track`, and `year` null. Additional dynamic
  tag names are not declared on the Haxe class.
- `[x]` `AudioPlaybackMode` has string values `AMBIENT = "ambient"`, `MEDIA =
  "media"`, and `VOICE = "voice"` (integer-backed 0, 1, 2 on legacy targets).
  It is only a value type here; no portable mixer property consumes it.
- `[x]` `CameraPosition` has `BACK = "back"`, `FRONT = "front"`, and `UNKNOWN
  = "unknown"` (integer-backed 0, 1, 2 on legacy targets). The media package in
  this source snapshot contains no portable Camera class using it.
