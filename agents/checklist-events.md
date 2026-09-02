# Events and display dispatch behavioral checklist

Audited against the OpenFL 9.5.2 sources in `openfl/events`,
`DisplayObject.hx`, `DisplayObjectContainer.hx`, `InteractiveObject.hx`, and
`Stage.hx`. Status describes the current openfl-flight implementation, not the
public documentation alone.

- `[x]` handled by the current adapter
- `[ ]` missing, divergent, or still needs a compatibility capture
- `[!]` blocked on a named Flight capability

The main distinction is between programmatic `DisplayObject.dispatchEvent()`
and native input routed by `Stage`. OpenFL uses related but observably different
routers for those paths. The current core programmatic router is close to the
9.5.2 source; the native Stage router is only a small subset.

## 1. EventDispatcher core

### Listener registration and removal

- [x] Listener identity is `(type, callback, useCapture)`. Adding the same
  identity twice is a no-op, even when the second call supplies a different
  priority or weak-reference flag.
- [x] Capture and non-capture registrations are distinct. The same callback may
  be registered once for each, and removal must use the matching
  `useCapture` value.
- [x] Priority is descending signed `Int`; equal-priority listeners retain
  insertion order. Changing priority requires remove then add.
- [x] Capture listeners run only in `CAPTURING_PHASE`; they do not run on the
  target. Non-capture listeners run at the target and during bubbling. A plain
  `EventDispatcher` dispatch starts at `AT_TARGET`, so its capture listeners do
  not run.
- [x] Adding or removing a null listener is a no-op.
- [x] `removeEventListener` ignores priority and removes at most the one
  registration matching callback plus capture flag. Removing the final listener
  also removes the type bucket.
- [x] `hasEventListener` is local and true for either capture or non-capture
  registrations.
- [x] Weak callbacks are weak only on JS/HTML5 when JavaScript `WeakRef` exists.
  Other non-Flash targets retain a strong callback. A collected callback is
  removed lazily while dispatching; before that cleanup the type bucket can
  still make `hasEventListener` true.
- [ ] OpenFL 9.5.2 source implements `willTrigger(type)` as local
  `hasEventListener(type)`, despite documentation promising an ancestor search.
  The adapter deliberately searches DisplayObject ancestors (and an aggregate
  DisplayObject target), as recorded by `events/dispatcher-capture`. This is a
  documented project decision, not strict source parity, and should not be
  described as the upstream implementation.

### Mutation and reentrancy

- [x] Adding a listener while an iterator for that type is active snapshots the
  active frame first. The new listener is excluded from that phase, but it is
  available to a later phase or a nested dispatch that starts afterward.
- [x] Removing a not-yet-visited listener during dispatch suppresses it in the
  active frame. Removing an already-visited listener adjusts the live iterator
  so the following listener is not skipped. This source behavior disagrees with
  the prose comment that a removed listener still receives the current action.
- [x] A nested dispatch of the same type gets a separate iterator. It observes
  the then-current live registry without corrupting the outer iterator. The
  existing mutation fixture records the sequence `a(abc)c`.
- [x] Duplicate detection still applies during dispatch. Remove then re-add
  creates a new registration at its priority position and does not restore it to
  the active snapshot.
- [!] Replacing the adapter-owned `DispatchIterator` with Flight signals while
  retaining these guarantees is blocked on a mutation-safe, per-emission Flight
  signal frame. Raw Flight signal arrays have index-dependent mutation and a
  shared cancellation flag; see `agents/flight-upstream.md`, “Signals:
  mutation-safe iteration during emit.”

### Targeting, phases, cancellation, and return values

- [x] A generic dispatcher uses its optional aggregate object as `event.target`;
  `event.currentTarget` remains the dispatcher actually invoking the listener.
  Without an aggregate, both are the dispatcher at target phase.
- [x] Programmatic display dispatch snapshots the ancestor chain before capture,
  visits root to immediate parent, visits only non-capture listeners at the
  target, then (when `bubbles`) recurses immediate parent to root.
- [x] Reparenting during capture does not change that capture stack. Bubbling is
  less static: each node caches its immediate parent before invoking its own
  listeners, then calls that cached parent, whose next parent is resolved when
  that node is entered. The adapter follows the same incremental recursion;
  phase-by-phase graph mutation still deserves a fixture.
- [x] Capture occurs even when `bubbles == false`; that flag suppresses only the
  upward bubbling phase.
- [x] `target` is stable for the normal route. `currentTarget` changes only when
  a dispatcher invokes listeners, and `eventPhase` is capture, target, or bubble
  for that invocation. These values are not reset after dispatch.
- [x] `stopPropagation()` lets all listeners on the current node finish and
  prevents the later bubble route. In the programmatic DisplayObject capture
  loop, however, the per-node cancellation result is ignored: later capture
  ancestors and the target still run, after which bubbling is suppressed. This
  is an OpenFL 9.5.2 source quirk captured by the harness.
- [x] `stopImmediatePropagation()` sets both cancellation flags and stops the
  remaining listeners on the current node. The flags persist for the Event
  instance; reusing a stopped Event does not reset them.
- [x] `preventDefault()` changes state only when `cancelable` is true and does
  not stop propagation. A target/capture prevention makes the outer dispatch
  result false.
- [x] A bubble ancestor's `preventDefault()` updates the Event, but the
  DisplayObject bubble recursion ignores the ancestor's return value. The
  original target dispatch can therefore return true even though the Event is
  default-prevented afterward. This source trap still needs a dedicated fixture.
- [x] Public redispatch does not clone an already-targeted Event despite the API
  documentation. Both generic and DisplayObject dispatch overwrite `target` and
  reuse the same instance; cancellation/default state also carries into the new
  dispatch. `events/redispatch` records this decision.
- [x] Programmatically dispatching a MouseEvent or TouchEvent from a
  DisplayObject recomputes `stageX`/`stageY` from that object's local coordinates
  before routing.
- [ ] `DisplayObject.dispatchEvent(null)` returns false in the adapter, while the
  9.5.2 source dereferences null and fails. Generic `EventDispatcher` still
  fails before its private null guard. Null-event behavior needs an explicit
  compatibility capture if it matters.
- [!] When Stage uncaught-error handling is enabled, OpenFL catches listener
  failures (except an `UncaughtErrorEvent` loop) and forwards them through the
  Stage error handler. The adapter lets them escape. A public Flight application
  error boundary is absent; see `agents/flight-gaps.md`, “Application
  event-error boundary.”

### Native Stage router difference

- [ ] OpenFL's `Stage.__dispatchStack` uses a stack ordered root through target,
  assigns `target` from the last element, and checks propagation cancellation
  between every capture and bubble node. The adapter has no equivalent Stage
  router.
- [ ] Current native mouse and keyboard handlers call
  `target.dispatchEvent(event)` instead. That selects the programmatic router,
  including its capture-cancellation quirk, rather than the stricter
  `Stage.__dispatchStack` behavior.

## 2. Mouse event dispatch

### Hit testing and target selection

- [x] OpenFL walks child arrays from highest index to zero, so visually frontmost
  children are considered first. The adapter's `getObjectsUnderPoint` collection
  also descends from highest index and returns front-to-back results.
- [x] Basic `mouseEnabled`/`mouseChildren` targeting is represented: a disabled
  leaf can fall back to an enabled ancestor, and `mouseChildren == false` makes
  the enabled container the target. If both container flags disable interaction,
  the hit falls through. The cross-package display/events fixture covers the
  expected flag combinations, although it does not invoke the native Stage
  handler itself.
- [ ] OpenFL performs those checks during one recursive hit walk, including
  masks, scroll rectangles, Sprite `hitArea`, visibility, and non-interactive
  descendants. The adapter first calls `getObjectsUnderPoint` and resolves flags
  afterward; its collection bypasses parts of the OpenFL interactive hit path.
  Nested masks/hit areas and overlapping disabled branches need captures.
- [x] If no interactive display object is hit, Stage is the fallback target and
  the stack is `[stage]`.
- [ ] OpenFL transforms window coordinates through Stage's inverse display
  matrix before hit testing (scale mode, alignment, DPI). The adapter only
  multiplies incoming coordinates by `window.scale`, so scaled/aligned stages
  can select the wrong target.

### Raw mouse fields and route

- [x] For a raw Stage mouse event, `localX`/`localY` are computed once in the
  selected target's coordinate space. They remain target-local while ancestors
  receive the event; `currentTarget` does not cause coordinate recomputation.
- [ ] The adapter supplies `localX`, `localY`, `stageX`, `stageY`, and primary
  `buttonDown`, but drops modifier keys, command/control distinctions,
  and `clickCount`.
- [ ] Only mouse down, move, and up are wired by the current Stage. Wheel,
  relative motion, leave, context-menu/default handling, pending move
  coalescing, cursor resolution, and release-outside behavior are absent.
- [!] OpenFL can cancel the originating Lime signal after a cancelable event is
  default-prevented. Flight DOM input currently decides `preventDefault` before
  emitting and exposes no deferred native-default callback; see
  `agents/flight-upstream.md`, “Input: dynamic preventDefault support.”

### Click and double-click synthesis

- [!] OpenFL remembers the down target separately for left, middle, and right
  buttons. Up on the same target generates `CLICK`, `MIDDLE_CLICK`, or
  `RIGHT_CLICK`; left up elsewhere dispatches `RELEASE_OUTSIDE` to the original
  down target. The adapter generates none of these. Flight Interaction owns this
  state but lacks the required one-shot pre-bubble ingress hook.
- [!] Left double-click requires `target.doubleClickEnabled`, the same target as
  the previous click, and elapsed time strictly below 500 ms. There is no
  coordinate-distance threshold. A successful double-click clears the stored
  target/time; a non-enabled target also clears them. Flight has no per-node
  equivalent for `doubleClickEnabled`, and resolved interaction ingress remains
  unavailable.
- [ ] On Lime 8.1+, raw down/up events may receive `window.clickCount`; synthesized
  click/double-click events in this source are created with `clickCount == 0`.
  The adapter has no corresponding raw count.
- [ ] OpenFL dispatch order is the original down/up/move event first, then any
  synthesized click, then hover-transition events. This sequencing is absent.

### Over/out and roll transitions

- [!] When the hit target changes, OpenFL dispatches bubbling `MOUSE_OUT` on the
  old stack, direct non-bubbling `ROLL_OUT` on departed stack members, direct
  non-bubbling `ROLL_OVER` on newly entered members, then bubbling `MOUSE_OVER`
  on the new stack. The explicit source comment requires `MOUSE_OVER` after
  `ROLL_OVER`. None of this state or dispatch exists in the adapter; Flight's
  direct roll signals cannot be observed exactly once through its current
  bubble-only API.
- [ ] Source semantics distinguish the transitions: `MOUSE_OVER`/`MOUSE_OUT`
  propagate through the Stage stack; `ROLL_OVER`/`ROLL_OUT` target each changed
  object directly with `bubbles == false`. The adapter implements neither path.
- [ ] Generated over/out events leave `relatedObject` null in the 9.5.2 source.
  Roll-event `localX`/`localY` are computed in the old/new leaf target's space
  even when the roll event targets an ancestor. These surprising details need
  fixtures before a future bridge is implemented.
- [ ] OpenFL rechecks an existing hover target on pending mouse processing when
  it is transformed, removed, hidden, disabled, or placed below an ancestor
  whose `mouseChildren` becomes false. The adapter retains no hover target to
  invalidate.

## 3. Keyboard and text input dispatch

- [x] OpenFL targets keyboard input at `Stage.focus` when non-null and at Stage
  otherwise. There is no separate `focusManager` field in the 9.5.2 Stage
  source. The adapter uses the same focus-or-Stage choice.
- [x] `KEY_DOWN` and `KEY_UP` are constructed with `bubbles == true` and
  `cancelable == true` in this source, despite an adjacent source comment about
  Flash Player events. Character code, converted key code, and key location are
  derived before routing.
- [ ] The adapter does not reproduce OpenFL's macOS control/command folding and
  routes through public DisplayObject dispatch rather than the Stage stack.
- [ ] When a keyboard event is default-prevented, OpenFL cancels the matching
  Lime `onKeyDown` or `onKeyUp` signal. The adapter ignores the dispatch result,
  so host default behavior continues (in addition to the Flight browser blocker
  described above).
- [ ] On `KEY_UP`, Space or Enter synthesizes a mouse `CLICK` for a focused
  Sprite when `buttonMode` is true and `focusRect == true`. The adapter omits
  this keyboard activation path.
- [ ] After an unprevented `KEY_DOWN`, OpenFL generates bubbling/cancelable
  `COPY`, `CUT`, `PASTE`, or `SELECT_ALL` events for the matching Ctrl/Command
  shortcut on a focused non-TextField. The adapter omits these events.
- [!] `TEXT_INPUT` is not synthesized inside `__onKey`; OpenFL receives the
  platform's separate text-input callback, constructs
  `TextEvent(TEXT_INPUT, true, true, text)`, routes it to focus or Stage, and
  cancels the platform callback when prevented. The current Window exposes a
  text-input signal but Stage does not register or route it. The intended Flight
  architecture also lacks Stage ownership of a host-local `InputManager`; see
  `agents/flight-gaps.md`, “TextField and StageText host input ownership.”

## 4. Focus and tab behavior

- [x] Programmatically changing `Stage.focus` dispatches
  `FOCUS_OUT` on the old object before `FOCUS_IN` on the new object. Both bubble,
  neither is cancelable, and both use the full display route in the normal case.
- [x] The old object's `FOCUS_OUT.relatedObject` is the new focus; the new
  object's `FOCUS_IN.relatedObject` is the old focus. Clearing focus supplies
  null to the old object.
- [ ] OpenFL routes those focus events through `Stage.__dispatchStack`; the
  adapter calls public `dispatchEvent`. Listener order is the same without
  cancellation, but capture-phase stop behavior differs as described above.
- [ ] Mouse-down focus changes first send a bubbling/cancelable
  `MOUSE_FOCUS_CHANGE` to the old focus with the proposed target as
  `relatedObject`. Only if it is not prevented does OpenFL apply the target's
  `mouseEnabled && tabEnabled` focus eligibility. Current mouse dispatch never
  changes focus and omits this veto event.
- [ ] Tab focus changes first send bubbling/cancelable `KEY_FOCUS_CHANGE` on the
  old focus with the proposed next object and Shift state. Preventing it retains
  focus and cancels the platform Tab. This path is absent.
- [ ] OpenFL gathers tab candidates depth-first in child-index order. A container
  contributes itself when `tabEnabled`, then descends only when `tabChildren` is
  true. `MovieClip.enabled == false` suppresses that subtree's candidate logic.
  Current `DisplayObjectContainer` has no recursive `__tabTest`, so Stage's
  candidate list is effectively empty.
- [ ] Candidates are sorted by ascending `tabIndex`. If any nonnegative index
  exists, all `-1` candidates are discarded. Forward/Shift-Tab traversal wraps,
  tries siblings when the current focus is outside the candidate list, and
  avoids selecting the current object again. None of this traversal is present.
- [x] `tabIndex` state and validation exist: `-1` means unspecified and values
  below `-1` throw. `tabEnabled` defaults false for a plain InteractiveObject;
  class overrides may opt in.
- [ ] `ACTIVATE`/`DEACTIVATE` are independent broadcast events, not substitutes
  for object `FOCUS_IN`/`FOCUS_OUT`. OpenFL broadcasts them on window focus in
  and focus out (and deactivates on close/module exit). The adapter registers
  broadcast listeners but does not wire Stage to Window focus/close signals, so
  automatic activation events do not fire.
- [ ] OpenFL caches focus around mobile/window focus loss and may restore it on
  focus-in. The adapter has no cached-focus state.

## 5. Frame and render broadcasts

- [x] `ACTIVATE`, `DEACTIVATE`, `ENTER_FRAME`, `FRAME_CONSTRUCTED`, `EXIT_FRAME`,
  and `RENDER` listeners place their DisplayObject into a static type registry;
  removing the final listener removes that object from the registry.
- [x] Broadcast order is registry insertion order (the order objects first gain
  a listener), not display-list walk order. Reordering or reparenting the display
  list does not reorder the registry. Detached objects with `stage == null` are
  eligible too.
- [ ] OpenFL iterates the live registry and invokes the private local dispatcher
  with one shared Event. The adapter iterates `dispatchers.copy()`, creates a new
  Event per object, and calls public `dispatchEvent()`. Removal/addition during a
  broadcast, Event identity/target retention, and mutation leakage therefore
  differ.
- [ ] Calling public dispatch also introduces ancestor capture listeners in the
  adapter. OpenFL's private broadcast dispatch is local-only; broadcast events
  have neither capture nor bubble traversal.
- [x] Per rendered frame, source order is `ENTER_FRAME`, then
  `FRAME_CONSTRUCTED`, then `EXIT_FRAME`, followed by the recursive internal
  `__enterFrame(deltaTime)` timeline advance. The adapter uses the same order.
- [x] `invalidate()` coalesces in a Boolean. One `RENDER` broadcast clears it;
  callers must invalidate again for another event.
- [ ] OpenFL sends `RENDER` immediately before renderer update/draw only when the
  Stage is invalidated and that frame is actually eligible to render. The
  adapter sends it from `__advanceFrame` before render-state preparation, even
  if preparation later cancels the render.
- [!] Automatic beta `RenderEvent` callbacks for individual custom-rendered
  objects require a per-node Flight render-lifecycle bridge. This is distinct
  from the standard Stage `Event.RENDER` broadcast; see `agents/flight-gaps.md`,
  “Custom render-event lifecycle.”

## 6. Display-list lifecycle events

- [x] Adding a child sets `parent` and, when connecting a detached subtree to a
  Stage, sets the Stage reference before any event. It then dispatches bubbling
  `ADDED` on the root child, followed by non-bubbling `ADDED_TO_STAGE` on that
  child.
- [x] `ADDED` participates in capture, target, and bubble routing.
  `ADDED_TO_STAGE` has `bubbles == false`, but its explicit display dispatch
  still runs capture before the target.
- [x] `ADDED_TO_STAGE` then visits descendants depth-first in child-index order,
  dispatching a target event on each descendant before recursing into its
  children. A detached subtree receives no `ADDED_TO_STAGE` until connected to
  Stage.
- [x] Removal first dispatches bubbling `REMOVED` while `parent` and `stage`
  still point to the old tree. If staged, it then dispatches
  `REMOVED_FROM_STAGE` on the root and descendants while those references are
  still intact; Stage and parent references are cleared only afterward.
- [x] Reparenting through `addChild` first invokes the old parent's full removal
  sequence. Even a move between two containers on the same Stage therefore
  produces `REMOVED`, `REMOVED_FROM_STAGE`, `ADDED`, and `ADDED_TO_STAGE` in
  that order. Reindexing a child already in the same parent produces none of
  these events.
- [ ] OpenFL reuses one Event while recursively dispatching to descendants and
  overwrites its target per direct child. The adapter creates a fresh base Event
  for every child. Event identity, final target/currentTarget, default state,
  and stop-propagation leakage across siblings therefore differ.
- [ ] Both implementations traverse live child arrays and retain precomputed
  add/remove decisions across callbacks. A listener that removes, reparents, or
  inserts children during `ADDED_TO_STAGE`/`REMOVED_FROM_STAGE` can change which
  later descendants are visited or cause the outer operation to continue with
  stale assumptions. Exact mutation cases need reference captures before this
  behavior is frozen.
- [ ] OpenFL clears Stage focus when the directly removed child owns it before
  finishing `REMOVED_FROM_STAGE`. The adapter removal path does not clear
  focus. Descendant-focus behavior is unclear in the 9.5.2 source and should be
  captured.

## 7. Event.clone() contract

### Cross-cutting rules

- [x] The adapter's event subclass clone bodies match the OpenFL 9.5.2 source;
  `RenderEvent` uses an equivalent public-field ColorTransform copy instead of
  the upstream private helper.
- [x] Contrary to the common expectation that dispatch metadata is cleared,
  OpenFL 9.5.2 `Event.clone()` explicitly copies `target`, `currentTarget`, and
  `eventPhase`. Most subclass overrides do the same. Public redispatch then
  overwrites target/currentTarget as listeners are invoked.
- [ ] The requested “clone should not preserve target/currentTarget” contract
  conflicts with the inspected 9.5.2 source and current captured MouseEvent
  behavior. Any policy change requires a direct post-dispatch clone fixture;
  it should not be made from documentation alone.
- [x] Cancellation flags, default-prevented state, and `updateAfterEvent` flags
  are not copied; the clone keeps fresh constructor/default internal state.
- [x] In the non-pooled eval capture, an untouched Event's internal
  default-prevented flag can remain null rather than an explicit false; the
  existing propagation fixture records that source edge and the adapter matches.
- [x] Payload copies are generally shallow: arrays, ByteArrays, Rectangles,
  devices, sockets, and dynamic objects are passed by reference. `RenderEvent`
  is the notable deep-copy case for its matrix and color transform.
- [x] Six direct-return overrides omit dispatch metadata:
  `DNSResolverEvent`, `DatagramSocketDataEvent`, `DeviceRotationEvent`,
  `GeolocationEvent`, `ScreenMouseEvent`, and `ServerSocketConnectEvent`.
  Their payload is copied, but the
  new event starts with null target/currentTarget and `AT_TARGET` phase.
- [x] `FileListEvent`, `InvokeEvent`, and `OutputProgressEvent` do not override
  clone at all. Inherited `Event.clone()` returns a base `Event`, so their
  concrete type and subclass payload are lost. The adapter preserves this
  upstream source behavior.
- [x] `RenderEvent.clone()` assumes non-null `objectMatrix` and
  `objectColorTransform`; cloning a default-constructed instance fails while
  dereferencing them. The adapter has the same edge behavior.

### Clone inventory

Every row below is source-matched (`[x]`). “Metadata” means
`target`/`currentTarget`/`eventPhase`; base fields `type`, `bubbles`, and
`cancelable` are copied unless noted.

| Status | Class | Subclass payload copied | Metadata / notable omissions |
| --- | --- | --- | --- |
| [x] | `Event` | none | copied |
| [x] | `AccelerometerEvent` | timestamp, acceleration X/Y/Z | copied |
| [x] | `ActivityEvent` | activating | copied |
| [x] | `AsyncErrorEvent` | text, error | copied |
| [x] | `ContextMenuEvent` | mouseTarget, contextMenuOwner | copied |
| [x] | `DNSResolverEvent` | host, resourceRecords | omitted |
| [x] | `DataEvent` | data | copied |
| [x] | `DatagramSocketDataEvent` | source/destination addresses and ports, data | omitted |
| [x] | `DeviceRotationEvent` | timestamp, roll, pitch, yaw, quaternion | omitted |
| [x] | `ErrorEvent` | text, errorID | copied |
| [x] | `FileListEvent` | none: inherited clone loses `files` and subtype | copied by base clone |
| [x] | `FocusEvent` | relatedObject, shiftKey, keyCode | copied |
| [x] | `FullScreenEvent` | fullScreen, interactive | copied |
| [x] | `GameInputEvent` | device | copied |
| [x] | `GeolocationEvent` | latitude, longitude, altitude, accuracies, speed, heading, timestamp | omitted |
| [x] | `HTTPStatusEvent` | status, redirected | copied; responseURL and responseHeaders are not copied |
| [x] | `IOErrorEvent` | text, errorID | copied |
| [x] | `InvokeEvent` | none: inherited clone loses currentDirectory, arguments, reason, and subtype | copied by base clone |
| [x] | `KeyboardEvent` | charCode, keyCode, keyLocation, ctrl/alt/shift/control/command | copied |
| [x] | `MouseEvent` | local coordinates, relatedObject, modifiers, buttonDown, delta, clickCount | copied; stageX/stageY, inaccessible flag, and update flag are not copied |
| [x] | `NativeProcessExitEvent` | exitCode | copied |
| [x] | `NativeWindowBoundsEvent` | beforeBounds, afterBounds | copied; Rectangle references are shallow |
| [x] | `NativeWindowDisplayStateEvent` | beforeDisplayState, afterDisplayState | copied |
| [x] | `NetStatusEvent` | info | copied; dynamic info is shallow |
| [x] | `OutputProgressEvent` | none: inherited clone loses bytesPending, bytesTotal, and subtype | copied by base clone |
| [x] | `PermissionEvent` | status | copied |
| [x] | `ProgressEvent` | bytesLoaded, bytesTotal | copied |
| [x] | `RenderEvent` | objectMatrix, objectColorTransform, allowSmoothing | copied; matrix/color are deep, renderer and update flag are not copied |
| [x] | `SampleDataEvent` | data, position | copied; ByteArray is shallow |
| [x] | `ScreenMouseEvent` | screen coordinates, modifiers, buttonDown | omitted |
| [x] | `SecurityErrorEvent` | text, errorID | copied |
| [x] | `ServerSocketConnectEvent` | socket | omitted |
| [x] | `StageOrientationEvent` | beforeOrientation, afterOrientation | copied |
| [x] | `TextEvent` | text | copied |
| [x] | `TimerEvent` | no subclass payload | copied |
| [x] | `TouchEvent` | touch ID/primary flag, local coordinates, size, pressure, relatedObject, modifiers | copied; stageX/stageY and update flag are not copied |
| [x] | `UncaughtErrorEvent` | error | copied |
| [x] | `VideoTextureEvent` | status, colorSpace | copied |

## 8. Priority captures and implementation order

- [x] Existing harness coverage is strong for local registration, priorities,
  capture/target/bubble phases, cancellation, mutation/reentrancy, redispatch,
  basic focus changes, lifecycle events, and subclass construction/cloning.
- [ ] Add native Stage input fixtures before implementing its missing router:
  overlapping/disabled hit branches, masks and hit areas, raw coordinate and
  modifier fields, click/release-outside/double-click, hover transition order,
  keyboard default cancellation, text input, and tab focus vetoes.
- [ ] Add broadcast fixtures for registration order, removal/addition during
  broadcast, ancestor capture exclusion, shared Event identity, and detached
  objects.
- [ ] Add lifecycle mutation fixtures for child insertion/removal/reparenting
  during recursive added/removed stage events and for focus inside a removed
  subtree.
- [ ] Add clone fixtures after dispatch for base Event, one metadata-preserving
  subclass, one metadata-omitting subclass, each no-override subclass, and
  HTTP/Mouse/Touch omitted fields.
- [!] Implement native pointer/hover/click conversion only after Flight exposes
  a resolved-interaction ingress hook that runs once before its own bubbling.
  Implement host-native cancellation only after Flight exposes a deferred
  default-prevention decision. These are the two architectural blockers; the
  remaining unchecked items are adapter work or fixture decisions.
