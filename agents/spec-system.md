# `openfl.system` behavior specification

Reference: OpenFL 9.5.2 under
`../haxelib/openfl/9,5,2/src/openfl/system/`. Adapter:
`src/openfl/system/`. This records non-Flash source behavior, including target
conditionals and deliberate stubs.

Legend:

- [x] The adapter preserves the observable OpenFL 9.5.2 behavior.
- [ ] The adapter is missing, divergent, or exports behavior beyond the
  reference implementation.
- [!] The behavior is blocked by a confirmed entry in `agents/flight-gaps.md`;
  the exact gap title is shown in bold.

## `ApplicationDomain`

- [x] `currentDomain` is one eagerly initialized singleton. During its own
  construction the static slot is still null, so its `parentDomain` is null.
- [x] `new(parentDomain = null)` stores a non-null argument verbatim; an omitted
  or explicit null argument instead stores `currentDomain`. Thus every ordinary
  child domain defaults to the singleton parent.
- [x] `getDefinition(name)` delegates directly to `Type.resolveClass(name)` and
  returns its class or null. `hasDefinition(name)` is exactly the corresponding
  null check. Neither method searches or isolates definitions by domain, and
  the parent is not consulted.
- [x] The class is final. The commented AIR members (`domainMemory`,
  `getQualifiedDefinitionNames`, `MIN_DOMAIN_MEMORY_LENGTH`) are not public
  members of the compiled 9.5.2 class.

## `LoaderContext`

- [x] The constructor stores `checkPolicyFile` (default false),
  `applicationDomain` (default null), and `securityDomain` (default null), then
  initializes `allowCodeImport` and `allowLoadBytesCodeExecution` to true.
  These five fields remain directly mutable records.
- [x] AIR image-decoding parameters, requested content parent, and uncaught
  error listener options are inside disabled source blocks and do not exist on
  the non-Flash public type.
- [x] `ImageDecodingPolicy` is an AIR/sys-only nullable integer abstract with
  `ON_DEMAND = "onDemand"` (integer 0) and `ON_LOAD = "onLoad"` (1); unknown
  strings map to null. `LoaderContext` itself exposes no field of that type in
  this source version.

## `SecurityDomain` and `Security`

- [x] `SecurityDomain.currentDomain` is one eagerly created instance. Its
  constructor is private and it exposes no other state or behavior.
- [x] `Security.LOCAL_TRUSTED`, `LOCAL_WITH_FILE`, `LOCAL_WITH_NETWORK`, and
  `REMOTE` are respectively `"localTrusted"`, `"localWithFile"`,
  `"localWithNetwork"`, and `"remote"`.
- [x] `exactSettings` and hidden `disableAVM1Loading` are uninitialized static
  Booleans (observable default false). Read-only `sandboxType` is uninitialized
  and therefore null.
- [x] `allowDomain` and `allowInsecureDomain` accept up to five optional dynamic
  arguments and do nothing. `loadPolicyFile(url)` also does nothing. The
  disabled `pageDomain` and `showSettings` blocks produce no public members.

## `System`

### Memory and runtime state

- [x] `totalMemory` reports the target runtime's current heap/GC usage on Neko,
  C++, HashLink, or supporting HTML5 browsers and otherwise zero.
  `totalMemoryNumber` uses 64-bit C++/HashLink memory APIs and otherwise returns
  `totalMemory` as a Float.
- [x] `gc()` requests a full collection on C++/Neko and a major collection on
  HashLink; it is a no-op on other targets.
- [x] `useCodePage` is mutable static state initialized to false. Hidden
  `vmVersion` always returns `"1.0.0"`; hidden `disposeXML(node)` is a no-op.
  `ime`, `privateMemory`, and `freeMemory` are disabled and absent.

### Process, application loop, and clipboard

- [ ] Reference `exit(code)` forwards the numeric status to Lime
  `System.exit`. The adapter asks the current Flight host to quit and discards
  the code; without a supported host it is a no-op.
- [ ] In non-strict builds reference `pause()` and `resume()` only call the
  OpenFL `notImplemented` hook. The adapter pauses/resumes the authoritative
  Flight Application loop on sys builds. This is an intentional extension; the
  required Flight handle is recorded as resolved in `agents/flight-gaps.md`.
- [x] `setClipboard(string)` is void and writes the supplied string to the
  platform clipboard. The adapter routes the write through Flight when a web,
  Clay, or active Lime host exists and otherwise does nothing, matching the
  reference's best-effort target behavior.

## `Capabilities`

### Fixed/compile-time values

- [x] These values are unchanged by the adapter:

  - `avHardwareDisable = true`; `hasAudio = true`; `hasTLS = true`.
  - `hasAccessibility`, `hasAudioEncoder`, `hasEmbeddedVideo`, `hasIME`,
    `hasMP3`, `hasScreenBroadcast`, `hasScreenPlayback`, `hasStreamingAudio`,
    `hasStreamingVideo`, and `isEmbeddedInAcrobat` are false.
  - `hasPrinting` and `hasVideoEncoder` are true only for HTML5.
  - `isDebugger` follows the `debug` define; `localFileReadDisable` follows
    `web`; `supports32BitProcesses` follows `sys`.
  - `maxLevelIDC = 0`, `pixelAspectRatio = 1`, and `screenColor = "color"`.
  - `playerType` is `"PlugIn"` for web, `"Desktop"` for sys, otherwise
    `"StandAlone"`; `hasMultiChannelAudio(type)` always returns false.

### Locale and platform descriptions

- [x] `language` lowercases the current locale language and accepts only `cs`,
  `da`, `nl`, `en`, `fi`, `fr`, `de`, `hu`, `it`, `ja`, `ko`, `nb`, `pl`,
  `pt`, `ru`, `es`, `sv`, and `tr`. Chinese becomes `zh-TW` when the locale
  includes `TW` or `Hant`, otherwise `zh-CN`; another known language becomes
  `xu`; absence falls back to `en`. The adapter obtains locale through Flight
  but preserves this mapping.
- [ ] Reference `cpuArchitecture` is compile-time `ARM` only on a real mobile
  device and `x86` otherwise. The adapter first maps Flight architecture text
  to `ARM`, `PowerPC`, `SPARC`, or `x86`, then uses the reference fallback.
- [ ] Reference `manufacturer` is `OpenFL Macintosh`, `OpenFL Linux`, or
  `"OpenFL " + Lime platformName` (and null without Lime). Adapter derives it
  from Flight OS data, returning `OpenFL` when no name exists and normalizing
  Mac only.
- [ ] Reference `os` reports iOS/tvOS device model, `Mac OS <version>`, Linux
  plus `uname -r` when available, or Lime's platform label; it is null without
  Lime. Adapter combines Flight `osName`/`osVersion`, normalizes Mac, and returns
  an empty string when unavailable.
- [x] `version` starts with target code `WIN`, `MAC`, `LNX`, `IOS`, `TVO`,
  `AND`, `QNX`, `MOZ`, `WEB`, or fallback `OFL`, then appends the OpenFL define
  with dots changed to commas and final `,0` when present. The adapter also
  normalizes a bare Haxe define value `1` to `9.5.2`, a build-system correction
  that otherwise leaves the public format unchanged.

### Screen, process, touch, and server report

- [ ] Reference desktop/web `screenDPI` is `72 * window.scale`; mobile selects
  the closest of 120, 160, 240, 320, 480, 640, 800, or 960 to the active display
  DPI. Adapter prefers Flight device density, then screen DPI, then 72 times a
  reported scale/pixel ratio.
- [ ] Reference `screenResolutionX/Y` use active display mode times window scale,
  then stage dimensions, and return zero without Lime/Stage. Adapter prefers
  Flight physical metrics, derives physical size from logical metrics and
  scale, and finally returns deterministic 800 by 600 without host metrics.
- [ ] Reference `supports64BitProcesses` is true when `desktop` is defined and
  false otherwise. Adapter uses Flight pointer width when known and otherwise
  returns true for any desktop or sys build.
- [ ] Reference `touchscreenType` is the constant `FINGER` on every target.
  Adapter reports `STYLUS` for a Flight stylus, otherwise `FINGER` for a touch
  platform and `NONE` for a non-touch platform.
- [ ] Reference `serverString` is the empty string. Adapter constructs a stable
  ampersand-delimited capability report containing audio/video/accessibility,
  printing/debug, version/manufacturer/resolution/DPI/color/aspect, OS/locale,
  player type, local-file/TLS, and `WD=f` fields with values URL-encoded.

## `TouchscreenType`

- [x] On ordinary Haxe targets this is a nullable integer abstract with
  `FINGER = 0`, `NONE = 1`, and `STYLUS = 2`; their string forms are
  `"finger"`, `"none"`, and `"stylus"`. Unknown strings map to null.
  `openfljs` uses those strings directly.
