# OpenFL event bridge over Flight

Status: design research, not an implementation specification yet. Every behavior marked **fixture required** should be captured from OpenFL 9.5.2 before the adapter freezes it.

## Source snapshot

The OpenFL reference is tag `9.5.2`:

- [`Event.hx`](https://github.com/openfl/openfl/blob/9.5.2/src/openfl/events/Event.hx)
- [`EventDispatcher.hx`](https://github.com/openfl/openfl/blob/9.5.2/src/openfl/events/EventDispatcher.hx)
- [`DisplayObject.hx`](https://github.com/openfl/openfl/blob/9.5.2/src/openfl/display/DisplayObject.hx)

The Flight reference is current `flight-hx` commit `50daaadaac1f3382891d04ca8562695d84ae94ab`:

- [`Signals.hx`](https://github.com/flighthq/flight-hx/blob/50daaadaac1f3382891d04ca8562695d84ae94ab/generated/flight/Signals.hx) and [`_Signals.hx`](https://github.com/flighthq/flight-hx/blob/50daaadaac1f3382891d04ca8562695d84ae94ab/generated/flight/_Signals.hx)
- [`Input.hx`](https://github.com/flighthq/flight-hx/blob/50daaadaac1f3382891d04ca8562695d84ae94ab/generated/flight/Input.hx) and [`_Input.hx`](https://github.com/flighthq/flight-hx/blob/50daaadaac1f3382891d04ca8562695d84ae94ab/generated/flight/_Input.hx)
- [`Interaction.hx`](https://github.com/flighthq/flight-hx/blob/50daaadaac1f3382891d04ca8562695d84ae94ab/generated/flight/Interaction.hx) and [`_Interaction.hx`](https://github.com/flighthq/flight-hx/blob/50daaadaac1f3382891d04ca8562695d84ae94ab/generated/flight/_Interaction.hx)

Flight's checked-in Haxe is generated. The adapter should depend on public `flight.*` facades and `flight.types.*`, not generated `_Flight` implementation classes. Pin the Flight commit or release used by the compatibility package; these APIs are still moving.

## Decision

Use Flight for signals, host-input normalization, hit testing, pointer state/capture, focus primitives, and graph access. Keep OpenFL's event object and its three-phase router in the compatibility layer.

Do not expose Flight `Interaction` bubbling as OpenFL event propagation. It has no capture phase and its cancellation operation combines two OpenFL operations that must remain distinct. Native input should enter the compatibility layer exactly once after Flight resolves the interaction target; from that point, the OpenFL router owns listener invocation.

The desired boundary is:

```text
host input
  -> Flight InputManager
  -> Flight InteractionManager (hit target, pointer/focus state)
  -> one-shot OpenFL ingress bridge
  -> new OpenFL Event subclass
  -> OpenFL capture / target / bubble router
  -> per-dispatcher Flight signal buckets
```

Programmatic `dispatchEvent()` starts at the OpenFL router and does not pass through `InputManager` or `InteractionManager`.

## What OpenFL 9.5.2 does

### Event state

`Event` owns these public values:

- immutable-after-construction `type`, `bubbles`, and `cancelable` properties;
- a stable `target` during one dispatch;
- a `currentTarget` that changes for each dispatcher;
- `eventPhase`, one of capture, at-target, or bubble;
- separate internal flags for propagation stopped, immediate propagation stopped, and default prevented.

`preventDefault()` changes state only when `cancelable` is true. `dispatchEvent()` conventionally returns false when the default was prevented. Neither propagation stop method prevents the default action.

`stopPropagation()` allows the other listeners on the current node to finish, then prevents traversal to later nodes. `stopImmediatePropagation()` also stops the remaining listeners on the current node.

### Listener registration

An OpenFL listener identity is `(type, callback, useCapture)`. Consequences:

- adding the same identity twice is a no-op, even if the second priority differs;
- changing priority requires remove then add;
- the same callback registered once for capture and once for non-capture is two registrations;
- capture listeners never run at the target; non-capture listeners run at target and during bubble;
- priority is descending, with stable insertion order for ties;
- null listener add/remove is a no-op in the 9.5.2 source;
- callback equality uses `Reflect.compareMethods`, with an extra equality fallback on HashLink.

OpenFL keeps a dispatch iterator per event type and creates/copies iterators for nested or mutating dispatch. This is materially different from iterating one live array.

Weak listener references are implemented only on JS/HTML5 when `WeakRef` exists. Other non-Flash targets retain a strong callback even when `useWeakReference` is true. A collected weak callback is removed lazily during dispatch.

### Display-list route

For `DisplayObject.dispatchEvent()` the source:

1. Recomputes `stageX`/`stageY` for a supplied `MouseEvent` or `TouchEvent` from the dispatching object's local coordinates.
2. Sets `event.target` to the dispatching object.
3. Builds the ancestor stack before capture and visits root down to the target's parent.
4. Visits the target at `AT_TARGET`, using only non-capture registrations.
5. When `event.bubbles` is true, visits parents from the target upward.

Generic `EventDispatcher` has only the at-target step. Its optional aggregate target becomes `event.target` and `currentTarget` is still the dispatcher performing the listener call.

The display list also has a separate static subscription registry for broadcast types: `activate`, `deactivate`, `enterFrame`, `exitFrame`, `frameConstructed`, and `render`. These are not ordinary tree propagation.

### Source-versus-documentation traps

The exact 9.5.2 source appears to disagree with its documentation in several places. These are compatibility decisions, not cleanup opportunities:

- The public documentation says redispatch clones an already-targeted event, but both public dispatch implementations overwrite `target` and do not call `clone()`.
- `willTrigger()` is implemented as local `hasEventListener()` in `EventDispatcher`; `DisplayObject` does not override it to search ancestors.
- The capture loop calls each ancestor even after the event cancellation flag is set. The return value from the per-node capture helper is ignored.
- The bubble recursion ignores ancestor return values, so `preventDefault()` called only by a bubble ancestor may not affect the outer `dispatchEvent()` return value.
- Listener mutation comments and the `DispatchIterator` implementation need a fixture to establish whether a future listener removed during dispatch still runs.

Do not silently implement the documented behavior in these cases. First capture native OpenFL 9.5.2 results and record whether the project follows source parity or deliberately fixes the discrepancy.

The adapter deliberately follows the documented `willTrigger()` behavior: for
a display object, it searches the object and its ancestors even though the
9.5.2 implementation only checks the receiver. The compatibility scenario
records this as an explicit project decision rather than claiming source parity.

## What Flight currently provides

### Signals

`Signal<T>` is a structural value with a nullable `SignalData<T>` and an `emit` function. `connectSignal()` lazily creates live `slots`, `priorities`, and `repeat` arrays. It inserts by descending floating-point priority and preserves insertion order for equal priorities. `{ once: true }` stores a non-repeating slot.

`disconnectSignal()` removes every strictly identical slot. `clearSignal()` drops all state. Flight does not itself reject duplicate slots and has no weak-slot mode.

`cancelSignal()` sets the current signal data's `cancelled` flag. The emit loop checks the flag after each slot and breaks. The flag is reset at the beginning of every emission.

Important limitations for an OpenFL adapter:

- add/remove operates on the array being iterated, so mutation behavior depends on the insertion/removal index;
- cancellation means “stop remaining slots now”; it cannot mean only “stop traversal after this node”;
- nested emission resets the same signal's cancellation flag;
- a connection has no returned handle, so an adapter must retain the exact wrapper slot used for disconnect;
- Flight priorities are `Float`; OpenFL accepts signed `Int`.

### Input

`InputManager` exposes signals for keyboard, pointer, relative pointer, wheel, text, and gamepad input. Host attachment helpers normalize native events into Flight data objects. `connectInputToInteraction()` forwards the relevant input signals into an `InteractionManager`.

The DOM attachment helpers default `preventDefault` to true and call it before emitting the Flight signal. Conversely, when configured false, the normalized data does not retain a DOM event that an OpenFL listener could prevent later. Dynamic OpenFL `preventDefault()` therefore cannot currently be reflected back to the browser's native event. This requires an explicit runtime policy or a Flight ingress change.

Input payloads are scratch objects reused between emissions. A bridge must synchronously copy every field it needs; application code must never retain a Flight payload as the backing store for an OpenFL event.

### Interaction

`InteractionManager` provides graph/spatial hit testing, pointer capture, pointer state, click/double-click/release-outside generation, hover/roll transitions, cursor resolution, and optional focus integration. It exposes a fixed set of per-node signals:

`onClick`, `onContextMenu`, `onDoubleClick`, `onFocusIn`, `onFocusOut`, `onKeyDown`, `onKeyUp`, `onPointerCancel`, `onPointerDown`, `onPointerMove`, `onPointerOut`, `onPointerOver`, `onPointerRollOut`, `onPointerRollOver`, `onPointerUp`, `onReleaseOutside`, and `onWheel`.

`connectInteractionSignal()` tracks a user's slot by manager, target, and signal name and prevents duplicate tracked connections. It forwards priority and once options to the underlying signal.

Normal interaction emission begins at the hit target and walks `getNodeParent()` toward the manager root. It updates payload `target`/`currentTarget`, emits one node signal, then stops the parent walk if that node's signal was cancelled. This is bubble-only. Roll-over and roll-out transitions also use direct per-node emission.

There is no arbitrary event type, phase field, `preventDefault`, weak listener, capture traversal, or distinction between propagation stop and immediate stop. Keyboard interaction events target `manager.root`, and `KeyboardEventData` has no target/currentTarget fields. A separate Flight focus manager is needed to obtain the focused node expected by OpenFL keyboard dispatch.

Interaction also reuses module-level pointer and keyboard payload objects. Copy them before invoking any OpenFL application callback, including before a callback can synchronously cause nested Flight input.

## Adapter model

### Per-dispatcher buckets

Each OpenFL dispatcher owns a map keyed by event type:

```haxe
private typedef EventBucket = {
    var capture:Signal<Event->Void>;
    var normal:Signal<Event->Void>;
    var registrations:Array<ListenerRegistration>;
}

private typedef ListenerRegistration = {
    var callback:Dynamic->Void;       // or a weak indirection
    var wrapper:Event->Void;          // exact Flight slot identity
    var useCapture:Bool;
    var priority:Int;
    var active:Bool;
}
```

Two signals are required because OpenFL capture and non-capture registrations are separate identities and are emitted in different phases. Arbitrary OpenFL event type strings create buckets lazily; they do not need a matching `InteractionSignalName`.

### Public API mapping

| OpenFL operation | Flight operation | Compatibility work around it |
| --- | --- | --- |
| `addEventListener(type, callback, capture, priority, weak)` | `createSignal()` when the bucket is new, then `connectSignal(selectedSignal, wrapper, {priority})` | Deduplicate by OpenFL callback identity first; retain wrapper identity; implement target-specific weak indirection. Do not use Flight `once`. |
| `removeEventListener(type, callback, capture)` | `disconnectSignal(selectedSignal, storedWrapper)` | Find only the matching OpenFL registration; mark it inactive before physical removal so an active dispatch can skip it safely. |
| `hasEventListener(type)` | Registry/bucket count, optionally checked against `hasSignalSlots()` | Purge collected weak registrations first where practical. The registry, not raw slot count, is authoritative. |
| `willTrigger(type)` | No direct Flight equivalent | Match the captured 9.5.2 fixture: likely local-only for exact source parity, or explicitly walk Flight parents if the project chooses documented semantics. |
| `dispatchEvent(event)` | `emitSignal()` once per node and phase | The OpenFL router sets target/currentTarget/phase and chooses capture or normal signal. Return the captured OpenFL default-prevention result. |
| internal listener cleanup | `disconnectSignal()`/`clearSignal()` | Remove wrapper records, weak tombstones, and node lifecycle references together. |

Listener wrappers invoke the original callback, then inspect the OpenFL event. If `stopImmediatePropagation()` was called, the wrapper calls `cancelSignal()` on the signal currently being emitted. A mere `stopPropagation()` must not call `cancelSignal()`, because remaining listeners on the current node still run. The graph router checks the propagation-stopped flag only between nodes.

Exception routing also belongs in the wrapper. When Stage uncaught-error handling is enabled, it should catch and route non-`UncaughtErrorEvent` exceptions through the Stage handler as OpenFL does; otherwise it should allow the exception to escape.

### Signal mutation requirement

Raw Flight signals are not sufficient for exact OpenFL mutation and reentrancy parity. The production requirement is a Flight snapshot-dispatch primitive with explicit connection records and one dispatch frame per nested emission. It must ensure that a connection added during an outer emission is excluded from that frame but available to a nested emission, that a removed pending connection is suppressed safely, and that cancellation belongs to one dispatch frame rather than shared signal data.

Do not copy OpenFL's `DispatchIterator`, reach into Flight `SignalData`, or ship an adapter-owned replacement signal as a workaround. If the ordinary Flight signal cannot pass the mutation fixtures, event listener delivery is blocked on this Flight addition. A temporary prototype may model the required semantics only to make the upstream contract and fixtures concrete.

### Tree router

The router uses the Flight node corresponding to each `DisplayObject` and `flight.Node.getNodeParent()` for ancestry. It must map every Flight node back to the stable public `DisplayObject` wrapper used for `target` and `currentTarget`. Non-display `EventDispatcher` instances do not require a Flight node.

The intended three-phase algorithm is:

```text
target := dispatching DisplayObject
capture ancestors := snapshot target.parent through root

for root -> target.parent:
    phase := CAPTURING_PHASE
    currentTarget := ancestor wrapper
    emit ancestor.capture
    stop route between nodes if propagation stopped

phase := AT_TARGET
currentTarget := target wrapper
emit target.normal

if event.bubbles and route is not stopped:
    for target.parent -> root:
        phase := BUBBLING_PHASE
        currentTarget := ancestor wrapper
        emit ancestor.normal
        stop route between nodes if propagation stopped
```

That is the documented behavior. The exact 9.5.2 capture-cancellation and bubble-parent mutation quirks described earlier may require changes. In particular, OpenFL snapshots the full ancestor chain before capture, but the bubble recursion reads/caches parent links incrementally. A single full-route snapshot is simpler but may differ if a listener reparents a node. **Fixture required.**

Do not ask Flight's `emitInteractionSignal()` to perform this loop: it would invoke the wrong phase, and `cancelSignal()` would conflate immediate cancellation with propagation cancellation.

### Native interaction ingress

The compatibility layer should receive one interaction record containing at least:

- interaction name;
- resolved original Flight target;
- world/stage position and button, pointer, wheel, and modifier fields;
- focused target and related target for keyboard/focus events;
- a native-default-prevention capability when the host supports it.

Convert it synchronously into a new OpenFL event subclass, then call the OpenFL router. Likely mappings include pointer down/move/up to mouse or touch events, click/double-click/context menu/wheel to `MouseEvent`, key signals to `KeyboardEvent`, and focus signals to `FocusEvent`. Exact touch-to-mouse synthesis, pointer cancel behavior, wheel scaling, key codes, related objects, and click gating by `doubleClickEnabled` all need fixtures.

Current Flight has no public “resolved interaction observer” that runs exactly once before its own bubble loop. A root interaction slot sees ordinary bubbled signals only after Flight traversal and misses direct roll-over/out emissions; hidden slots on every node receive duplicates for bubbled signals. The preferred Flight-side addition is therefore an ingress/observer hook immediately after target resolution and before per-node signal fan-out. An interim root-plus-direct-node scheme is possible but should not become the compatibility contract.

OpenFL application listeners should never be connected directly with `connectInteractionSignal()`. There should be only internal bridge slots. Otherwise Flight may invoke user code before OpenFL capture, user cancellation acquires Flight semantics, and programmatic events take a different path from native events.

### Defaults and interaction state

`preventDefault()` has two layers:

- Always update the OpenFL event's default-prevented flag when it is cancelable. This controls the public API and `dispatchEvent()` result.
- Only call a host-native prevent function when the ingress record supplies one and the OpenFL listener calls `preventDefault()` before the native event's deadline.

Flight Input currently prevents by attachment policy before dispatch, so the second layer needs an upstream change if dynamic browser behavior is required.

Flight's click, double-click, release-outside, hover, pointer capture, and focus state are useful inputs, but their behavior is not automatically OpenFL-compatible. Gate or adapt them for OpenFL properties such as `doubleClickEnabled`, focus ownership, `mouseEnabled`/`mouseChildren`, hit areas, masks, and stage membership.

### Broadcast and lifecycle events

Retain an OpenFL-side broadcast registry keyed by event type. Register a `DisplayObject` when its first listener for a broadcast type is added, and remove it when its last listener is removed or its weak registration expires. Stage/frame code emits to this registry directly. Flight graph traversal is not involved.

The adapter also needs deterministic cleanup when a DisplayObject wrapper or Flight node is disposed. Clear signal buckets, disconnect hidden ingress slots, remove broadcast entries, and remove both directions of the node-wrapper map.

## Parity harness requirements

Capture structured traces from upstream OpenFL 9.5.2 and compare them to the adapter. Each trace should record listener label, event type, target identity, currentTarget identity, phase, default-prevented state, and final dispatch return value.

Minimum scenario matrix:

1. Local dispatcher: no listeners, one listener, aggregate target, arbitrary event names, null listener, and null event behavior.
2. Registration identity: duplicate add, capture plus normal, priority change without remove, remove then re-add, bound method identity, and equal-priority insertion order.
3. Three-node display graph: capture/target/bubble order for bubbling and non-bubbling events, including target capture registration not firing at target.
4. Cancellation at every phase: `stopPropagation`, `stopImmediatePropagation`, and `preventDefault` on cancelable and non-cancelable events, with multiple same-node listeners.
5. Return values: default prevention at capture, target, and each bubble ancestor.
6. Mutation: add higher/lower/equal-priority listener during dispatch; remove self, prior, next, and last listener; clear last listener; remove and re-add.
7. Reentrancy: nested dispatch of the same type on the same dispatcher, a different event type, and redispatch of the same Event instance.
8. Graph mutation: reparent/remove the target or an ancestor during capture, target, and bubble.
9. Weak listeners: supported JS `WeakRef`, unavailable `WeakRef`, collected callback cleanup, and explicit remove before collection.
10. `hasEventListener()` and `willTrigger()` on target, parent, and root.
11. Exception behavior with Stage uncaught-error events disabled and enabled.
12. Mouse/touch stage and local coordinates at every currentTarget, plus retained-event values after dispatch.
13. Native interaction conversion: mouse, touch, pen, wheel modes, keyboard modifiers/codes/repeat, focus related target, pointer capture, release outside, roll transitions, click, and double click.
14. Broadcast events with objects on stage, off stage, removed during broadcast, and weak-only listeners.

Mutation, cancellation in capture, bubble-only default prevention, redispatch, and `willTrigger()` should be implemented as early fixtures. They decide the router and signal abstraction; discovering them after event subclasses are built would force a structural rewrite.

## Suggested implementation order

1. Port `Event`, `EventPhase`, `IEventDispatcher`, callback identity, and local at-target dispatch.
2. Resolve the signal mutation strategy and pass local ordering/reentrancy fixtures.
3. Add Flight-node/wrapper identity mapping and the capture/target/bubble router.
4. Add broadcast registration and Stage exception routing.
5. Add the one-shot Flight interaction ingress API or an explicitly temporary bridge.
6. Convert pointer, keyboard, focus, text, and wheel payloads into their OpenFL subclasses one family at a time.
7. Integrate default actions and lifecycle cleanup only after cancellation and retained-payload tests pass.

This order keeps the OpenFL contract independent of native input and prevents Flight's current bubble-only semantics from becoming an accidental public API.
