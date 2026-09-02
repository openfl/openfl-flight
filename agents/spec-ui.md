# `openfl.ui` behavioral specification (OpenFL 9.5.2)

This is a complete source-level behavioral reference for the requested OpenFL 9.5.2 UI types. The pinned sources are under `/tmp/tmp.OcIrt2boMR/openfl/src/openfl/ui/`; executable non-Flash source wins over Flash/API prose. `[x]` means the adapter preserves the contract, `[ ]` means it is absent or different, and `[!]` means the contract is blocked by the named Flight gap.

## `Keyboard`

- [x] Top-row digit constants `NUMBER_0` through `NUMBER_9` are contiguous key codes `48..57`; alphabet constants `A` through `Z` are `65..90`; and `NUMPAD_0` through `NUMPAD_9` are `96..105`.
- [x] Numpad operator constants are `NUMPAD_MULTIPLY=106`, `NUMPAD_ADD=107`, `NUMPAD_ENTER=108`, `NUMPAD_SUBTRACT=109`, `NUMPAD_DECIMAL=110`, and `NUMPAD_DIVIDE=111`. Function keys `F1` through `F15` are contiguous `112..126`.
- [x] Control/navigation codes are `BACKSPACE=8`, `TAB=9`, `ENTER=13`, `COMMAND=15`, `SHIFT=16`, `CONTROL=17`, `ALTERNATE=18`, `BREAK=19`, `CAPS_LOCK=20`, `NUMPAD=21`, `ESCAPE=27`, `SPACE=32`, `PAGE_UP=33`, `PAGE_DOWN=34`, `END=35`, `HOME=36`, `LEFT=37`, `UP=38`, `RIGHT=39`, `DOWN=40`, `INSERT=45`, `DELETE=46`, and `NUMLOCK=144`.
- [x] Punctuation constants are `SEMICOLON=186`, `EQUAL=187`, `COMMA=188`, `MINUS=189`, `PERIOD=190`, `SLASH=191`, `BACKQUOTE=192`, `LEFTBRACKET=219`, `BACKSLASH=220`, `RIGHTBRACKET=221`, and `QUOTE=222`.
- [x] Read-only static `capsLock` and `numLock` are declared but never assigned by the 9.5.2 implementation, so each has the target-default false value and does not track actual keyboard state.
- [x] `isAccessible()` always returns false; it does not inspect the host or permissions.

## `KeyLocation`

- [x] The constants are `STANDARD=0`, `LEFT=1`, `RIGHT=2`, and `NUM_PAD=3`.

## `Mouse` and `MouseCursor`

- [x] Public cursor constants are the exact strings `ARROW="arrow"`, `AUTO="auto"`, `BUTTON="button"`, `HAND="hand"`, and `IBEAM="ibeam"`. The abstract accepts arbitrary strings; assigning an unknown cursor does not throw.
- [x] `Mouse.cursor` begins as `AUTO`. Setting null coerces it to `AUTO`; every other value, including an unknown string, is retained and returned by the getter.
- [x] On Lime windows, `ARROW` maps to host `arrow`, `BUTTON` to `pointer`, `HAND` to `move`, and `IBEAM` to `text`. Setting `AUTO` or an unknown value changes stored state but makes no host cursor assignment, leaving the previous host cursor in place.
- [x] `hide()` sets a single static hidden flag and assigns null cursor to every application window. Repeated calls do not stack. While hidden, changing `cursor` only changes stored state. `show()` clears the flag and reapplies the stored cursor mapping; repeated show calls are harmless.
- [x] `supportsCursor` and `supportsNativeCursor` are read-only compile-time values: true for every non-mobile build and false for mobile, independent of the actual window/backend.
- [x] `registerCursor` and `unregisterCursor` are inside `#if false` in 9.5.2 and are not part of the compiled non-Flash API. Extra private cursor names and string conversions do not expand the public MouseCursor constants.

## `GameInput`

- [x] `isSupported` is a read-only static initialized to true unconditionally. `numDevices` is the current size of one process-global device list, initially zero. There is no capability probe.
- [x] Every `new GameInput()` creates an independent EventDispatcher and appends it permanently to the global list of GameInput instances; there is no dispose/removal API.
- [ ] Upstream device tracking is wired from Stage's Lime gamepad callbacks and can populate the global device list even before any GameInput instance is constructed; non-Lime builds have no corresponding source callback path. The adapter initializes and attaches its Flight input manager only from `new GameInput()`, but extends attachment to supported HTML5, Clay, and Lime hosts, so both initialization timing and target coverage differ.
- [x] `getDeviceAt(index)` returns the device at a valid zero-based index and null for negative or out-of-range indices.
- [x] Overridden `addEventListener` first registers the listener normally. When the type is `GameInputEvent.DEVICE_ADDED`, it immediately dispatches one bubbling, non-cancelable DEVICE_ADDED event for every device already present. Dispatch is through the GameInput dispatcher, so all already-registered listeners of that dispatcher receive the replay too—not just the newly added listener. Other event types have ordinary EventDispatcher behavior, including capture, priority, and weak-reference arguments.
- [x] A host connect creates a `GameInputDevice`, appends it, updates `numDevices`, then sends a bubbling/non-cancelable DEVICE_ADDED event through every extant GameInput instance. Disconnect removes the matching device first, updates the count, and then broadcasts DEVICE_REMOVED with that removed device.
- [ ] In OpenFL, an axis/button update for an unknown host id creates the device silently; DEVICE_ADDED is dispatched only by the later connect callback. The adapter's first axis/button update routes through `__getDevice` and immediately dispatches DEVICE_ADDED, changing event order/count.
- [x] Axis and button callbacks ignore values while the device is disabled. When enabled, they lazily create missing controls, update the control value even when unchanged, and dispatch a plain `Event.CHANGE` from that control (non-bubbling, non-cancelable).
- [ ] OpenFL stores the host axis value verbatim, but normalizes a button-down callback to exactly 1 and button-up to exactly 0. The adapter stores Flight's value from both button signals; ordinary digital backends agree, but analog/noncanonical signal values differ.

## `GameInputDevice`

- [x] `MAX_BUFFER_SIZE` is the compile-time constant `32000`. A device retains its constructor id and name as read-only strings and begins `enabled=false` and `sampleInterval=0`. GameInputDevice itself has no event-dispatch API.
- [x] Construction precreates six controls `AXIS_0` through `AXIS_5` with range `[-1,1]`, followed by fifteen `BUTTON_0` through `BUTTON_14` with range `[0,1]`. Thus `numControls` initially reports 21 and grows if host updates create higher-index controls.
- [x] `getControlAt(i)` returns a control for a valid zero-based index and null for negative/out-of-range indices. Control ordering is the initial six axes, initial fifteen buttons, then controls in lazy-creation order.
- [x] `sampleInterval` and `enabled` are unrestricted direct fields. Toggling them has no immediate side effect in the OpenFL class; enabled gates only subsequent host input updates.
- [x] `startCachingSamples(numSamples,controls)` and `stopCachingSamples()` are empty. `getCachedSamples(data,append=false)` always returns zero and neither clears nor appends to the supplied ByteArray. The adapter preserves this literal 9.5.2 no-data contract; **Native gamepad attachment and sample history** blocks implementing the richer documented API, not source parity here.
- [ ] The adapter creates devices through Flight host bridges, but its id/name derivation can expose the same host identifier for both rather than preserving OpenFL's separate Lime id and name values.

## `GameInputControl`

- [x] Controls have no public constructor. Their read-only `device`, `id`, `minValue`, and `maxValue` are set when the owning device creates them. Axis ranges are `[-1,1]`; button ranges are `[0,1]`.
- [x] Read-only `value` starts at zero and changes only through internal host callbacks when the owning device is enabled. Values are stored verbatim rather than clamped to min/max.
- [x] Each control is an EventDispatcher. A host value update assigns the new value even if unchanged and then dispatches `Event.CHANGE`; the event carries no separate old/new values.

## `Multitouch`

- [x] `inputMode` starts as `MultitouchInputMode.TOUCH_POINT` and is a freely writable static; assigning NONE/GESTURE does not itself enable, disable, or synthesize events.
- [ ] In OpenFL 9.5.2, read-only `maxTouchPoints` is initialized once to 2 and never changed. The adapter starts at 2 but raises it to the greatest simultaneously observed touch count, so later reads can differ.
- [x] `supportedGestures` is a read-only static left null, and `supportsGestureEvents` is a read-only false. Neither is populated dynamically.
- [ ] On JavaScript, `supportsTouchEvents` tests whether `ontouchstart` exists on the browser document. On non-JS it is compile-time false on macOS and true on every other target. The adapter instead asks Flight for dynamic touch capability where available, so host/backend results can differ from those exact platform rules.
- [x] OpenFL itself exposes no gesture recognition through these statics, and the adapter preserves those null/false values. Flight's **Touch maximums and gesture recognition** gap blocks the richer documented capability, not this literal 9.5.2 source contract.

## `MultitouchInputMode`

- [x] On non-JavaScript targets the abstract values are `GESTURE=0`, `NONE=1`, and `TOUCH_POINT=2`; exact string conversions are `"gesture"`, `"none"`, and `"touchPoint"`, with an unknown input string converting to null. OpenFL-JS exposes those three strings directly.
