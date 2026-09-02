# Remaining package behavior specification

Reference: OpenFL 9.5.2 under `../haxelib/openfl/9,5,2/src/openfl/`.
Adapter: `src/openfl/`. This specification covers the non-Flash public behavior
of `openfl.errors`, `openfl.sensors`, `openfl.printing`, `openfl.external`,
`openfl.filesystem`, `openfl.security`, `openfl.globalization`,
`openfl.profiler`, and `openfl.permissions`.

Legend:

- [x] The adapter preserves the observable OpenFL 9.5.2 behavior.
- [ ] The adapter is missing, divergent, or exports behavior beyond the
  reference implementation.
- [!] The behavior is blocked by a confirmed entry in `agents/flight-gaps.md`;
  the exact gap title is shown in bold.

## `openfl.errors`

The nine adapter files in this package are byte-for-byte identical to the
OpenFL 9.5.2 sources.

- [x] `Error` extends `haxe.Exception` on Haxe 4.1 and later. Its constructor
  accepts `message = ""` and `id = 0`, supplies the message to the superclass,
  stores the read-only `errorID`, and sets the mutable `name` to `"Error"`.
  On older Haxe it is a standalone class with the same three public values.
- [x] `Error.toString()` returns `message` whenever it is non-null, including
  when it is empty, and returns `"Error"` only for a null message.
  `getStackTrace()` returns `CallStack.toString(CallStack.exceptionStack())`;
  it does not preserve a construction-time stack snapshot.
- [x] `ArgumentError`, `IOError`, `IllegalOperationError`, `RangeError`,
  `SecurityError`, and `TypeError` accept `message = ""`, force `errorID = 0`,
  and replace `name` with their class name.
- [x] `PermissionError(message = "", id = 0)` preserves both arguments and
  sets `name = "PermissionError"`.
- [x] `EOFError(message = null, id = 0)` ignores both supplied arguments,
  forces message `"End of file was encountered"`, `name = "EOFError"`, and
  `errorID = 2030`.

## `openfl.sensors`

### `Accelerometer`

- [x] `isSupported` performs lazy one-time discovery. The reference selects
  the first Lime accelerometer and installs one static update callback; the
  adapter asks Flight once, creates and attaches one Flight sensor set, and
  connects its accelerometer signal. Subsequent reads reuse the cached result.
- [ ] The reference can discover any Lime accelerometer. The adapter currently
  supplies a real sensor host only on HTML5; native Lime and Clay hosts are
  represented by a fallback that reports no motion support.
- [x] Shared readings begin at `x = 0`, `y = 1`, `z = 0`. Each native/Flight
  reading replaces all three. A new instance initializes support, starts with
  `muted = false`, and requests the default 34 ms interval.
- [x] Overridden `addEventListener` first registers the listener and then calls
  the update routine for every event type, not only `AccelerometerEvent.UPDATE`.
  That routine immediately dispatches an `UPDATE` event containing
  `Timer.stamp()` in seconds and the current shared axes, even if hardware is
  unsupported.
- [x] `setRequestedUpdateInterval(interval)` stores the supplied integer,
  throws `ArgumentError` for a negative value, converts zero to 34, stops the
  old timer, and, when supported and not muted, creates a repeating timer that
  dispatches current readings. Changing `muted` restarts that timer.

### `DeviceRotation`

- [x] The 9.5.2 sys implementation reports `isSupported = false`, exposes
  read-only `muted = false`, throws `IllegalOperationError("Not supported")`
  from construction, and makes `setRequestedUpdateInterval(Float)` a no-op.
  The adapter's reachable native behavior remains the same because its only
  sensor-host fallback reports orientation unsupported.
- [ ] The reference is a plain class. The adapter extends `EventDispatcher`
  and contains an otherwise unreachable Flight-enabled path that attaches an
  orientation sensor, converts Euler values to a `[w, x, y, z]` quaternion,
  and dispatches `DeviceRotationEvent.UPDATE` using the reading timestamp or
  `Timer.stamp() * 1000`. Enabling a real host would therefore expand the
  public behavior beyond the reference stub.
- [!] **Sensor cadence and mobile location policy**: even on that extended
  path `setRequestedUpdateInterval` remains a no-op because Flight has no
  update-frequency control on `attachSensors`.

### `Geolocation`

- [x] The accuracy constants are exactly `"best"`, `"bestForNavigation"`,
  `"hundredMeters"`, `"kilometer"`, `"nearestTenMeters"`, and
  `"threeKilometers"`. Initial state is best accuracy, `locationAlways =
  false`, `pausesLocationUpdatesAutomatically = true`, `muted = false`, and
  `permissionStatus = UNKNOWN`.
- [ ] The 9.5.2 sys class is not an `EventDispatcher`, always reports
  unsupported, always throws `IllegalOperationError("Not supported")` on
  construction, and leaves permission and interval requests as no-ops. The
  adapter extends `EventDispatcher`, enables Flight geolocation where a host
  supports it, and begins a watch during successful construction.
- [ ] Flight positions dispatch `GeolocationEvent.UPDATE` with latitude,
  longitude, altitude, horizontal/vertical accuracy, speed, and heading, but
  the adapter replaces the host timestamp with `Timer.stamp() * 1000`.
- [ ] `requestPermission()` maps Flight reasons `granted` and `denied` to the
  corresponding status and all other reasons to `UNKNOWN`; a changed status
  dispatches `PermissionEvent.PERMISSION_STATUS`, denial sets `muted`, and the
  watch is restarted. These are useful extensions, not 9.5.2 stub behavior.
- [!] **Sensor cadence and mobile location policy**: requested positive update
  intervals become Flight `maximumAgeMs` cache tolerances, not event cadence;
  `locationAlways` and `pausesLocationUpdatesAutomatically` are ignored, and
  Flight cannot query or subscribe to OS permission state or distinguish
  always from while-in-use grants.

## `openfl.printing`

- [x] `PrintJobOptions` is a mutable record with `printAsBitmap`, initialized
  from a constructor argument that defaults to false.
- [x] `PrintJobOrientation` has `LANDSCAPE = "landscape"` and `PORTRAIT =
  "portrait"`; ordinary targets represent them as nullable integers 0 and 1
  with string conversions, while `openfljs` stores the strings directly.
- [x] `PrintJob` exposes mutable `orientation` and read-only `pageHeight`,
  `pageWidth`, `paperHeight`, and `paperWidth`. Construction does not initialize
  them explicitly, so the orientation is null and dimensions are zero.
- [ ] Reference `PrintJob.isSupported` is true for HTML5 and false elsewhere.
  The adapter reports false on every target because Flight has no printing
  host API.
- [ ] On reference HTML5, `start()` marks the job active, clears its page
  bitmap list, and returns true. `addPage()` then rasterizes either the supplied
  rectangle or `sprite.getBounds(sprite)` into a transparent, zero-filled
  bitmap using ceiling dimensions; options and frame number are ignored.
  The adapter always returns false and never captures a page.
- [ ] Reference `send()` is inert before a successful start. Afterwards on
  HTML5 it opens a 500 by 500 browser window, inserts print-only page breaks,
  appends PNG images for canvas-backed pages, and focuses/prints after 500 ms.
  It does not reset the started state. Adapter `send()` is always a no-op.

## `openfl.external.ExternalInterface`

- [x] `available` is true only for HTML5, and mutable
  `marshallExceptions` starts false. The adapter preserves these flags.
- [ ] On reference HTML5, `objectID` returns the active Lime application
  window element's ID when application, window, and element all exist;
  otherwise it is null. The adapter always returns null.
- [ ] On reference HTML5, `addCallback(name, closure)` assigns the closure to
  the window element property named by `name` when that element exists. The
  adapter is a no-op because no Flight browser-element registration exists.
- [x] `call(functionName, p1 ... p5)` returns null outside HTML5. On HTML5 it
  evaluates the requested JavaScript expression; unless the name matches a
  parenthesized expression, it rewrites the expression to bind the resolved
  function to its owner object. Evaluation errors and non-functions return
  null.
- [x] Invocation stops at the first null optional argument: null cannot be
  passed and followed by later arguments. It returns the JavaScript result,
  and invocation exceptions propagate regardless of `marshallExceptions`.

## `openfl.filesystem`

### `FileMode`

- [x] This enum contains `APPEND = "append"`, `READ = "read"`, `UPDATE =
  "update"`, and `WRITE = "write"`. Ordinary targets use nullable integer
  values 0 through 3 with string conversion; `openfljs` uses strings directly.

### `File`: identity, paths, and metadata

- [x] `File` extends `FileReference`. A null constructor path leaves an empty
  reference; a non-null path is assigned through `nativePath`. The inherited
  `creationDate`, `modificationDate`, `name`, `size`, `type`, and `extension`
  are refreshed lazily from filesystem metadata, while `icon` is always null.
- [!] Inherited `download`, `load`, `save`, and `upload` retain the
  `FileReference` transport behavior. Flight cannot abort an already-issued
  request, and the compatibility layer can only suppress its stale completion.
  That limitation is **FileReference network transfers and cancellation**.
  `File` replaces inherited `browse` and `cancel` as specified below.
- [x] `lineEnding` is CRLF on Windows and LF elsewhere; `separator` is
  backslash on Windows and slash elsewhere. `workingDirectory` is `Sys.getCwd()`
  with trailing separators removed.
- [!] **Filesystem metadata, locations, and synchronous contracts**:
  reference well-known directories come from Lime, while Flight may return no
  application, application-storage, desktop, documents, or user path. Adapter
  fallbacks use Lime when present and otherwise program/current/home paths, so
  they need not equal the 9.5.2 values. Flight also lacks the full metadata,
  permission, hidden-file, real-path, symlink, watch, backup, package, and
  downloaded-file contract.
- [ ] Reference `exists`/`isDirectory` query Haxe `FileSystem`. Reference
  `isHidden` uses Windows `attrib` output there and a leading dot elsewhere.
  The adapter uses Flight stat data and treats a leading dot as hidden on every
  target. It additionally exports `isSymbolicLink` and `spaceAvailable`, which
  are not public members of the supplied OpenFL 9.5.2 `File` source.
- [ ] Reference `nativePath` resolves `app:` and `app-storage:` prefixes,
  expands `%VAR%` on Windows, appends a separator to trailing drive colons,
  rejects unrooted non-Windows paths without a directory component, refreshes
  stats, and applies native separators. Its URL setter then strips five
  characters regardless of the recognized scheme. The adapter deliberately
  preserves schemes, strips their actual lengths, and makes `app:` read-only.
- [ ] Reference `url` emits `file://` plus a URL-encoded slash-normalized path;
  `parent` derives the directory and returns null at the filesystem root.
  Adapter outputs `app:`/`app-storage:` for its tracked virtual roots, an
  intentional extension tied to its corrected scheme handling.
- [!] **Filesystem metadata, locations, and synchronous contracts**:
  `getFileBytes`, `getFileText`, `saveBytes`, and `saveText` are immediate,
  throwing Haxe filesystem calls in the reference. The adapter implements them
  through Flight promises and can preserve that synchronous API only when the
  host promise settles immediately; a truly asynchronous response becomes an
  `IOError` rather than blocking.

### `File`: dialogs and path operations

- [x] Only one browse operation may be pending per `File`; another throws
  `IllegalOperationError("File Dialog is already open.")`. Directory, open,
  multiple-open, and save operations produce `SELECT`, `SELECT_MULTIPLE`, or
  `CANCEL`; a single selection replaces this object's path, while multiple
  selection leaves it unchanged and supplies newly constructed files.
- [x] `browse(typeFilter)` calls `browseForOpen("Open", typeFilter)` and always
  returns false, rather than reporting whether a dialog was shown.
- [!] **Native file-dialog option and result contract skew**: maintained Flight
  hosts and generated bindings disagree about `title`/`defaultPath` options
  and raw handles versus wrapped outcomes. The adapter sets optional fields
  reflectively and accepts both result forms, but cannot guarantee the exact
  native dialog contract.
- [ ] Reference `cancel()` unconditionally calls the current background
  worker's `cancel()` and dispatches `Event.CANCEL`, even when that access may
  fail because no worker exists; it does not cancel a file dialog. Adapter
  instead invalidates pending work generations and dispatches cancel only for
  a pending dialog, without cancelling already-issued host I/O.
- [x] `canonicalize()` removes `.` and paired `..` segments and walks existing
  directory listings to recover filesystem casing. It rewrites this object's
  path and does not guarantee symlink resolution.
- [x] `clone()` creates an empty `File`, reflectively copies all accessible
  instance fields/properties while swallowing individual failures, and does not
  copy event registrations or filesystem content.
- [ ] Reference `resolvePath(path)` simply concatenates this path, one native
  separator, and `path`. Adapter normalizes segments, retains known schemes,
  and returns already-absolute paths directly.
- [x] `getRelativePath(ref, useDotDot = false)` normalizes separators and
  returns the shared-tail relative path. It returns null when no common prefix
  exists or walking upward would be required while `useDotDot` is false.
- [x] `createTempFile()` and `createTempDirectory()` choose random nonexistent
  names under the system temporary directory but do not create either object.
  `getRootDirectories()` probes the hard-coded A-through-Z drive list; on
  non-Windows that is `A:/` through `Z:/`, not the Unix `/` root.

### `File`: filesystem mutation and events

- [x] Synchronous copy validates overwrite, recursively copies directories,
  creates missing destination parents, and maps failure to `IOError` 3003.
  Delete-directory optionally recurses; delete-file removes a file;
  create-directory recursively creates; directory listing throws `IOError`
  3007 for a non-directory and returns child `File` objects.
- [ ] Reference move is copy followed by deletion. Adapter first attempts a
  Flight rename and falls back to copy/delete. Adapter also adds explicit null,
  existence, destination, and read-only checks, so error timing/messages can
  differ from the reference.
- [ ] Reference `openWithDefaultApplication()` delegates to Lime
  `System.openFile`. Adapter prefers a Flight shell launch when available and
  has native command fallbacks, changing both availability and failure modes.
- [ ] Reference `copyToAsync`, delete async variants, listing async, and
  `moveToAsync` use `BackgroundWorker`, producing `COMPLETE`, result-specific
  events, or `IOErrorEvent`. Adapter's `__runAsync` executes the corresponding
  operation synchronously before dispatching; it is asynchronous in name only.
- [!] **Filesystem metadata, locations, and synchronous contracts**: Flight
  exposes promise-based file operations but not a general sync backend; the
  adapter's sync and nominally async compatibility layers therefore cannot
  reproduce reference blocking and worker scheduling on every host.

### `FileStream`

- [x] A new stream starts closed with big endian byte order,
  `objectEncoding = HXSF`, `position = 0`, `readAhead = POSITIVE_INFINITY`,
  `isWriting = false`, and `bytesAvailable = 0`. Closed or wrong-direction
  reads/writes throw `Error` with ID 2092.
- [x] `open(file, mode)` is synchronous. `READ` opens an existing input,
  `WRITE` creates parents and truncates, `APPEND` writes at the end, and
  `UPDATE` opens read/write at position zero. Invalid opens become `IOError`.
  `close()` closes without an event; reopening first closes the prior handle.
- [!] **Native filesystem streaming and read-ahead**: maintained native Flight
  hosts return no usable stream handles and Flight lacks seek, truncate, and
  random-access semantics. The adapter therefore loads a whole-file
  `ByteArray`, mutates it in memory, and flushes snapshots, rather than matching
  the reference's true file handle and cursor behavior.
- [x] `position` controls the byte cursor and `bytesAvailable` is remaining
  bytes. `endian` affects numeric methods. Boolean, signed/unsigned byte,
  short, int, float, double, UTF, UTF-bytes, byte-array, and multi-byte methods
  otherwise follow `IDataInput`/`IDataOutput` and `ByteArray` semantics;
  `length = 0` in byte-array methods means all remaining bytes.
- [ ] Reference `openAsync(READ)` uses a background worker and reads in
  4,096,000-byte pages governed by `readAhead`, dispatching progressive
  `ProgressEvent.PROGRESS` values before `COMPLETE`. Adapter loads the complete
  file first, dispatches one completed progress sample, then `COMPLETE`, so
  `readAhead` has no effective streaming role.
- [ ] Reference asynchronous writes stream to an output handle and report real
  pending/total progress. Adapter rewrites buffered snapshots and reports zero
  pending bytes; close waits for its queued flush and then dispatches `CLOSE`.
- [ ] `readMultiByte`/`writeMultiByte` ignore the requested character set on
  the adapter's buffered path and use UTF-8. `truncate()` resizes the in-memory
  buffer and rewrites it rather than truncating an open random-access handle.
- [!] **Object wire formats**: reference `readObject`/`writeObject` support the
  selected `ByteArray.objectEncoding`. Adapter supports its length-prefixed
  HXSF/JSON fallback but explicitly throws or no-ops for AMF0 and AMF3 because
  those wire codecs are unavailable.

## `openfl.security`

These three adapter files are byte-for-byte identical to OpenFL 9.5.2.

- [x] `CertificateStatus` contains `expired`, `invalid`, `invalidChain`,
  `notYetValid`, `principalMismatch`, `revoked`, `trusted`, `unknown`, and
  `untrustedSigners`. Ordinary targets use nullable integers 0 through 8 with
  string conversions; `openfljs` stores strings.
- [x] `X500DistinguishedName` has a private constructor and read-only common,
  country, locality, organizational-unit, organization, and state/province
  strings. `toString()` omits null fields and concatenates the rest in exactly
  `/CN=`, `/C=`, `/L=`, `/OU=`, `/O=`, `/S=` order, returning `""` when all
  are null.
- [x] `X509Certificate` has a private constructor and no methods. It is only a
  read-only record for encoded bytes, issuer/subject names and unique IDs,
  serial number, signature algorithm/parameters, subject key/algorithm,
  validity dates, and unsigned version; unpopulated fields retain null or zero
  target defaults.

## `openfl.globalization`

All six adapter files in this package are byte-for-byte identical to OpenFL
9.5.2.

### Enumeration values

- [x] `DateTimeNameContext`: `FORMAT = "format"` (0) and `STANDALONE =
  "standalone"` (1). `DateTimeNameStyle`: `FULL = "full"` (0),
  `LONG_ABBREVIATION = "longAbbreviation"` (1), and `SHORT_ABBREVIATION =
  "shortAbbreviation"` (2).
- [x] `DateTimeStyle`: `CUSTOM`, `LONG`, `MEDIUM`, `NONE`, and `SHORT` map to
  the lowercase strings and integers 0 through 4 in that order.
- [x] `LastOperationStatus` maps integers 0 through 16 respectively to
  `bufferOverflowError`, `errorCodeUnknown`, `illegalArgumentError`,
  `indexOutOfBoundsError`, `invalidAttrValue`, `invalidCharFound`,
  `memoryAllocationError`, `noError`, `numberOverflowError`, `parseError`,
  `patternSyntaxError`, `platformAPIFailed`, `truncatedCharFound`,
  `unexpectedToken`, `unsupportedError`, `usingDefaultWarning`, and
  `usingFallbackWarning`. Unknown string conversions return null. `openfljs`
  stores the strings directly for all these abstracts.

### `LocaleID`

- [x] `DEFAULT` is `"i-default"`. Constructing that literal keeps it as both
  `name` and language, uses empty region/script, sets RTL false, and reports
  `NO_ERROR`; it does not resolve the user's locale in the constructor.
- [x] Non-HTML normalization changes underscores to hyphens, lowercases the
  language, converts `root` to `und`, title-cases a four-letter script,
  uppercases a two/three-character region, and drops remaining variants.
  HTML5 instead constructs and maximizes `Intl.Locale`, retaining its base
  name, language, region, and script. Successful parsing reports `NO_ERROR`;
  exceptions report `ERROR_CODE_UNKNOWN`.
- [x] `getLanguage`, `getRegion`, `getScript`, `getVariant`, and
  `isRightToLeft` return cached values without changing status. Variant is
  always empty. RTL recognizes the fixed Avestan, Arabic, Aramaic, Southern
  Balochi, Bakhtiari, Sorani, Dhivehi, Persian, Gilaki, Hebrew, Kurdish,
  Mazanderani, N'Ko, Western Punjabi, Pashto, Sindhi, Uyghur, Urdu, and Yiddish
  language-code list.

### `DateTimeFormatter`

- [x] Non-HTML `getAvailableLocaleIDNames()` returns a fixed one-element
  `Vector("en-US")`; construction retains the requested locale but always sets
  actual locale `en-US` and `NO_ERROR`. HTML5 returns an empty available list
  and obtains its actual locale from `Intl.DateTimeFormat.resolvedOptions()`.
- [x] `getDateStyle`, `getTimeStyle`, and `getDateTimePattern` return stored
  values and set `NO_ERROR`. `getFirstWeekday()` returns zero with `NO_ERROR`
  natively; HTML5 returns zero with `PLATFORM_API_FAILED`.
- [x] `setDateTimeStyles` rejects `CUSTOM` in either argument with
  `ILLEGAL_ARGUMENT_ERROR` and otherwise stores both styles. Native patterns
  are English combinations of `EEEE, MMMM d, yyyy`, `MMMM d, yyyy`, or
  `M/d/yyyy` and `h:mm:ss a` or `h:mm a`; `NONE` omits its side. HTML5 resolves
  a pattern from `Intl` parts.
- [x] Native style formatting is English: long dates include full weekday and
  month, medium dates still use the full month, short dates are M/d/yyyy,
  short times omit seconds, and other time styles include them. The source's
  exact 12-hour quirk is preserved: only hours greater than 12 become PM, so
  noon is labeled AM and midnight prints hour 0.
- [x] `setDateTimePattern` rejects null or more than 255 characters with
  `PATTERN_SYNTAX_ERROR`, otherwise sets both styles to `CUSTOM` before
  tokenizing. Unknown letters are syntax errors. Native unsupported tokens are
  quarter, week/year, day/year, weekday occurrence, week/month, milliseconds,
  and all timezone forms; HTML5 supports `z` but rejects `Q`, `w`, `D`, `F`,
  `W`, `Z`, and `v`. The missing early return after `S` is preserved, so a later
  token may overwrite its `UNSUPPORTED_ERROR` status.
- [x] Native custom formatting supports quoted text and tokens for era, year,
  month, date, weekday, AM/PM, four hour systems, minute, and second. It
  preserves 9.5.2 quirks including adding one to the already one-based date,
  mapping hour-11 through a decremented 12-hour value, and mapping hour-24 as
  the actual hour plus one. Unsupported tokens contribute empty text.
- [x] Native month names are the 12 fixed English full names or their first
  three characters. Native weekdays are Sunday through Saturday, full or
  truncated to three characters for long abbreviation and two for short;
  context is ignored. HTML5 obtains localized arrays from `Intl`.
- [x] `format()` uses the custom pattern when either style is `CUSTOM` and
  otherwise uses styles. Native `formatUTC()` uses the stored pattern whenever
  it is non-null—even one generated by a style setter—while HTML5 delegates
  style dates to `Intl`. Successful formatting sets `NO_ERROR`.

## `openfl.profiler.Telemetry`

- [x] `connected` is true only for C++ or Neko builds with `hxtelemetry` and
  outside macro context. `spanMarker` is the read-only constant `0.0` rather
  than a clock sample.
- [x] `registerCommandHandler` and `unregisterCommandHandler` always return
  false. `sendMetric` and `sendSpanMetric` are no-ops. Hidden
  `TelemetryCommandName` values are `.event` and `.render`.
- [ ] In a telemetry-enabled build, reference Stage initialization constructs
  `HxTelemetry` from Lime application metadata and its internal timing/stack
  hooks use that instance. Adapter initialization is empty pending Flight
  application metadata, even though `connected` still reports true, so those
  internal Stage hooks can lack an initialized telemetry object.

## `openfl.permissions.PermissionStatus`

- [x] The adapter file is identical to OpenFL 9.5.2. `DENIED`, `GRANTED`,
  `ONLY_WHEN_IN_USE`, and `UNKNOWN` have strings `denied`, `granted`,
  `onlyWhenInUse`, and `unknown`; ordinary targets use nullable integers 0
  through 3 with string conversion and unknown strings map to null, while
  `openfljs` stores strings directly.
