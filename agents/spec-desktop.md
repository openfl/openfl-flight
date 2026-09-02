# `openfl.desktop` and native-window behavior specification

Reference: OpenFL 9.5.2 under
`../haxelib/openfl/9,5,2/src/openfl/desktop/`, plus the native-window types
under `openfl/display/`. Adapter: `src/openfl/desktop/` and the corresponding
`src/openfl/display/` files. This describes the source that actually compiles on
non-Flash targets; it does not fill omissions with the larger Adobe AIR API.

Legend:

- [x] The adapter preserves the observable OpenFL 9.5.2 behavior.
- [ ] The adapter is missing, divergent, or exports a non-reference extension.
- [!] The behavior is blocked by a confirmed entry in `agents/flight-gaps.md`;
  the exact gap title is shown in bold.

## Actual package boundary

- [x] The non-Flash `openfl.desktop` package contains exactly `Clipboard`,
  `ClipboardFormats`, `ClipboardTransferMode`, `DockIcon`, `Icon`,
  `InteractiveIcon`, `InvokeEventReason`, `NativeApplication`, `NativeProcess`,
  `NativeProcessStartupInfo`, `NotificationType`, `SystemIdleMode`,
  `SystemTrayIcon`, and `Updater`. The native-window classes are in
  `openfl.display`, not `openfl.desktop`.
- [x] `NativeMenu`, `NativeMenuItem`, `NativeDragManager`, `DragManager`, and
  `NativeDragOptions` do not exist anywhere in the OpenFL 9.5.2 source tree.
  The adapter does not invent them. The same is true of AIR's `StorageVolume`
  and `StorageVolumeInfo` names.
- [x] Desktop-only AIR compatibility types are compile-gated by `sys` and the
  AIR documentation condition. On Flash/AIR they become typedefs to the Flash
  classes; on unsupported non-Flash configurations they are absent rather than
  runtime stubs.

## `NativeApplication`

### Singleton, capabilities, and window lists

- [x] `nativeApplication` lazily constructs one private instance and returns
  that same identity thereafter.
- [x] `supportsDefaultApplication`, `supportsDockIcon`, `supportsMenu`,
  `supportsStartAtLogin`, and `supportsSystemTrayIcon` are always `false` in the
  9.5.2 non-Flash source and in the adapter.
- [x] `activeWindow` returns the private active-window slot. A `NativeWindow`
  focus-in sets the slot before application/window `ACTIVATE` dispatch; focus-out
  clears it before application `DEACTIVATE`, but only if that window still owns
  the slot.
- [x] `openedWindows` returns a fresh array copy. Window construction appends
  the window; final close removes it. Mutating the returned array cannot alter
  application state.
- [x] `autoExit` is a mutable field initialized to `true`. The Flight adapter
  quits on its all-windows-closed signal and also after the last adapter window
  completes closing; setting it to `false` suppresses those paths.
- [x] `icon` is read-only and `null`; `isCompiledAOT` is always `false`.
- [ ] `applicationID` reads `Lib.application.meta["packageName"]` in the 9.5.2
  source. The adapter always returns `null`.
- [ ] Reference `startAtLogin` is an ordinary mutable Boolean field (therefore
  default `false`, but a write is observable even though the support flag is
  false). The adapter getter always returns `false` and ignores writes while
  `supportsStartAtLogin` is false.

### Adapter-only AIR surface

- [!] `applicationDescriptor`, `publisherID`, `runtimeVersion`, and
  `runtimePatchLevel` are not public members of the actual 9.5.2 class. The
  adapter adds deterministic values `null`, `null`, `null`, and `0`; Flight has
  no corresponding metadata. Blocked by **Desktop application metadata and
  shell capabilities**.
- [ ] `idleThreshold` is an adapter-only property initialized to 300 seconds.
  Its setter accepts 5 through 86400 inclusive and otherwise throws
  `ArgumentError`; the reference has no such member or idle timer.
- [!] `menu` is an adapter-only mutable `Dynamic` initialized to `null`; there
  is no `NativeMenu` type or host conversion. Blocked by **Desktop application
  metadata and shell capabilities**.
- [!] `systemIdleMode` is adapter-only state initialized to `NORMAL`. It accepts
  only `NORMAL` and `KEEP_AWAKE`, throwing `ArgumentError` otherwise; the web
  host also acquires/releases Flight's display-sleep lock. Other targets retain
  state without a host effect. The missing cross-host contract belongs to
  **Desktop application metadata and shell capabilities**.

### Commands and lifecycle events

- [ ] Reference `exit(code = 0)` calls Lime `System.exit(code)`. The adapter
  requests host application quit when supported, ignores `code`, and otherwise
  does nothing.
- [x] `isSetAsDefaultApplication(extension)` always returns `false`;
  `setAsDefaultApplication` and `removeAsDefaultApplication` are no-ops.
- [!] Adapter-only `getDefaultApplication(extension)` returns `null`.
  Implementing all four association operations is blocked by **Desktop
  application metadata and shell capabilities**.
- [ ] Adapter-only `activate(window = null)` asks the supported host to focus
  the application, then calls `window.activate()` when supplied. The reference
  has no application-level `activate` method.
- [!] Adapter-only `clear`, `copy`, `cut`, `paste`, and `selectAll` always return
  `false`; there is no focused edit-command router. Blocked by **Desktop
  application metadata and shell capabilities**.
- [ ] The reference class itself does not connect host lifecycle signals. Its
  windows cause application `ACTIVATE` and `DEACTIVATE`; the adapter additionally
  dispatches `ACTIVATE` from Flight's app activation signal, so a host/window
  activation may be observable through more than one ingress.
- [ ] The adapter dispatches a non-bubbling, cancelable `EXITING` on Flight quit
  request and cancels that Flight signal when `preventDefault()` makes dispatch
  return false. This is useful AIR behavior but is not present in the actual
  9.5.2 `NativeApplication.exit()` source, whose direct call exits immediately.
- [x] Listeners for `INVOKE`, `IDLE`, `PRESENT`, `USER_PRESENT`, and
  `NETWORK_CHANGE` can be registered through inherited `EventDispatcher`, but
  neither implementation automatically emits those events. There is likewise
  no automatic `EXITING` event in the reference source.

## `NativeWindowInitOptions`

- [x] `new()` performs no work beyond field initializers. Defaults are
  `maximizable = true`, `minimizable = true`, `owner = null`,
  `renderMode = null`, `resizable = true`, `systemChrome = STANDARD`,
  `transparent = false`, and `type = NORMAL`.
- [x] All fields are mutable option records. The private `__window` slot lets
  OpenFL wrap its initial application window; no validation or normalization is
  performed by the options object itself.

## `NativeWindow`

### Availability and construction

- [ ] Reference `isSupported` is true only for a `sys && desktop` build. The
  adapter reports true for every configuration in which this sys-gated class
  compiles. `supportsMenu` and `supportsTransparency` are false in both.
- [ ] The reference constructor dereferences `initOptions`, so `new
  NativeWindow(null)` fails. The adapter substitutes a new default options
  object.
- [ ] A reference-created secondary window begins hidden at 400 by 228 pixels
  on current Lime, uses software rendering, takes `resizable` and borderless
  chrome from the options, and records ownership. The adapter opens a hidden
  Flight application window with the same size and resizable/chrome intent,
  additionally passes requested transparency, and creates a compatibility
  `Window`/`Stage` shell when it is not wrapping an existing `Window`.
- [ ] Reference `type` remains its private default `NORMAL` even when another
  option value was supplied. The adapter returns the supplied option type.
- [x] Construction installs the stage's `nativeWindow`, appends to
  `NativeApplication.openedWindows`, records the child in its owner's private
  list, snapshots initial bounds/state, and connects host activation, focus,
  move, resize, minimize, maximize, restore, and close notifications.

### Properties and closed-window rule

- [x] `closed` is the only property that remains freely queryable after close.
  Every other property getter/setter and every public operation checks the
  closed flag and throws `openfl.errors.Error` with error ID 3200 and message
  `Cannot perform operation on closed window.`
- [x] `stage` and immutable `type`, `systemChrome`, `maximizable`,
  `minimizable`, `owner`, `renderMode`, and `resizable` expose the captured
  window/options values. `listOwnedWindows()` returns a defensive vector copy.
- [x] `x`, `y`, `width`, and `height` read host state. Writes truncate with
  `Std.int`, request the corresponding host move/resize, and return the host's
  resulting value.
- [x] `bounds` returns a new `Rectangle`. Assignment performs position before
  size, truncates all four components, and returns a new rectangle of the
  resulting host state.
- [x] `title` reads/writes the host title. `visible` reads host visibility and
  shows or hides through Flight; the current reference delegates to Lime.
- [x] `displayState` chooses `MINIMIZED` first, then `MAXIMIZED`, otherwise
  `NORMAL`. It is read-only; state changes use the methods below.
- [x] `active` is maintained by focus/activation callbacks. The adapter also
  treats Flight's current `focused` flag as active.
- [x] `transparent` always returns `false` in both implementations, regardless
  of `NativeWindowInitOptions.transparent`.
- [x] `minSize` and `maxSize` return new `Point` values and setters truncate and
  forward both components. In the reference these members exist only with Lime
  8.1 or newer; the adapter exposes them unconditionally within the class gate.

### Operations and event order

- [ ] `activate()` makes the window visible and asks the host to focus it. The
  reference waits for the host focus callback before changing active state;
  the adapter calls its focus-in handler synchronously after the request.
- [x] `minimize()`, `maximize()`, and `restore()` issue host state changes. The
  adapter explicitly restores the opposite extreme before minimizing or
  maximizing; `restore()` returns to normal.
- [x] A first focus-in sets `active` and application `activeWindow`, then
  dispatches window `ACTIVATE` followed by application `ACTIVATE`. Repeated
  activation while active is ignored. Focus-out clears state, dispatches
  application `DEACTIVATE` when this was the active window, then dispatches the
  window's `DEACTIVATE`; repeated deactivation is ignored.
- [x] Host move/resize events carry `NativeWindowBoundsEvent.MOVE` or `.RESIZE`
  with the saved old rectangle and current new rectangle, then update the saved
  coordinates/dimensions. The adapter also updates its compatibility Window and
  Stage logical size on resize.
- [x] Minimize/maximize/restore callbacks dispatch only
  `NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE`, using the previously
  observed state and respectively `MINIMIZED`, `MAXIMIZED`, or `NORMAL`. The
  9.5.2 source does not dispatch the AIR `DISPLAY_STATE_CHANGING` event.
- [x] Programmatic `close()` sets a skip flag before requesting close, so it
  does not dispatch cancellable `CLOSING`. A user/host close request dispatches
  non-bubbling, cancelable `CLOSING`; prevention cancels the host request.
- [x] On accepted close, owned children are popped and closed in reverse
  ownership order, the window becomes closed, it is removed from owner and
  application lists, and `CLOSE` is dispatched last. The adapter additionally
  unregisters/disposes the Flight handle and applies `autoExit` after the last
  window.

### AIR window operations not in 9.5.2

- [x] The actual class has no `alwaysInFront`, `menu`, `orderToFront`,
  `orderToBack`, `orderInFrontOf`, `orderInBackOf`, `startMove`, `startResize`,
  or `globalToScreen` member. Mentions of `startMove`/`startResize` in comments
  do not create methods. The adapter correctly does not claim these APIs.
- [x] There are consequently no automatic `MOVING`, `RESIZING`,
  `DISPLAY_STATE_CHANGING`, or menu/select behaviors to specify for the actual
  9.5.2 non-Flash surface.

## Clipboard

- [x] `generalClipboard` is a lazy singleton flagged as the system clipboard;
  `Clipboard` cannot be directly constructed publicly.
- [!] The reference synchronously maps all three supported formats to Lime's
  one text slot. The adapter shadows its own writes so `getData()` and
  `hasFormat()` remain synchronous, but cannot observe external host changes.
  Blocked by **Synchronous desktop clipboard reads**.
- [x] `formats` is a newly allocated array ordered HTML, rich text, text and
  includes each format for which `hasFormat` is true.
- [!] `clear()` clears all three local values and the host clipboard.
  `clearData()` clears just one format for a local clipboard, but any supported
  format clears the entire system clipboard. Flight has the same whole-clipboard
  limitation recorded in **Synchronous desktop clipboard reads**.
- [x] `getData(format, transferMode = null)` treats null transfer mode as
  `ORIGINAL_PREFERRED`, but otherwise ignores transfer mode. Unsupported formats
  return `null`. `setData` ignores `serializable`; supported text-like formats
  return true and unsupported formats return false.
- [ ] The reference `setDataHandler` calls `notImplemented()` and returns false.
  The adapter accepts a non-null handler for any supported format, reports that
  format present, resolves it once on first `getData`, and routes the result
  through `setData`. A null handler or unsupported format returns false.
- [ ] Adapter-only `supportsFilePromise` is always false; the actual 9.5.2
  `Clipboard` has no such public member.

## `NativeProcess` and startup records

- [!] The reference sys/Haxe-4 implementation reports `isSupported = true`,
  launches `sys.io.Process`, exposes working standard pipes, polls output/error
  on worker threads, and delivers progress, IO-error, and exit events on
  `ENTER_FRAME`. The adapter reports false and `start(info)` is a no-op. Blocked
  by **Native child-process flight-hx binding**.
- [x] A newly constructed adapter process has `running == false` and stable
  `standardInput`, `standardOutput`, and `standardError` wrapper identities.
  `closeInput()` and `exit(force = false)` do nothing when no process is active;
  `force` is ignored even by the reference implementation.
- [x] Reading/writing the wrappers before a process is active throws `Error`
  ID 3212. With process support absent they never become usable in the adapter.
- [x] `NativeProcessStartupInfo.new()` leaves its public `arguments`,
  `executable`, and `workingDirectory` fields at null. Reference `start` copies
  arguments in order, temporarily applies `workingDirectory`, then restores the
  caller's current directory.
- [!] Reference process object IO supports AMF0/AMF3/HXSF/JSON. The unreachable
  adapter wrappers retain HXSF/JSON but not AMF. This narrower serialization
  issue is also covered by **Object wire formats**.

## Icons and updater

- [x] `Icon` is an `EventDispatcher`; `new()` creates a directly mutable empty
  `bitmaps:Array<BitmapData>`. The implementation does not clone the array or
  synchronize it to a host icon.
- [x] `InteractiveIcon` is publicly constructible despite documentation to the
  contrary. Its read-only `width` and `height` are both permanently zero.
- [x] `DockIcon` is publicly constructible. `bounce(priority = INFORMATIONAL)`
  always throws `IllegalOperationError("Not supported")`; it has no menu member.
- [x] `SystemTrayIcon.MAX_TIP_LENGTH` is 63. Construction succeeds and
  `tooltip` is an unconstrained public string field; no truncation, icon host,
  click behavior, or menu surface is implemented.
- [x] `Updater.isSupported` is false. `new()` succeeds and `update(airFile,
  version)` always throws `IllegalOperationError("Not supported")`.

## Desktop value types

- [x] Non-`openfljs` builds use nullable integer-backed abstracts with string
  conversions; `openfljs` uses the strings directly. Unknown strings convert to
  null. Values are:

  - `ClipboardFormats`: `HTML_FORMAT = "air:html"`,
    `RICH_TEXT_FORMAT = "air:rtf"`, `TEXT_FORMAT = "air:text"`.
  - `ClipboardTransferMode`: `CLONE_ONLY = "cloneOnly"`,
    `CLONE_PREFERRED = "clonePreferred"`, `ORIGINAL_ONLY = "originalOnly"`,
    `ORIGINAL_PREFERRED = "originalPreferred"`.
  - `InvokeEventReason`: `LOGIN = "login"`, `NOTIFICATION = "notification"`,
    `OPEN_URL = "openURL"`, `STANDARD = "standard"`.
  - `NotificationType`: `CRITICAL = "critical"`,
    `INFORMATIONAL = "informational"`.
  - `SystemIdleMode`: `KEEP_AWAKE = "keepAwake"`, `NORMAL = "normal"`.
- [x] Native-window abstracts have these string conversions:
  `NativeWindowDisplayState` is `normal`, `maximized`, `minimized` (integer
  values 0, 1, 2 respectively); `NativeWindowSystemChrome` is `alternate`,
  `none`, `standard` (0, 1, 2); and `NativeWindowType` is `lightweight`,
  `normal`, `utility` (0, 1, 2).
