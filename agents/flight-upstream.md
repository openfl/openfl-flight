# Flight upstream requests

Requirements on flight-hx discovered during openfl-flight implementation. Each entry
describes what openfl-flight needs, why, and what the current workaround is (if any).

Status key: **open** — needed, not yet filed or addressed; **workaround** — openfl-flight
has adapter code that could be removed if Flight provides this; **filed** — communicated
upstream; **resolved** — available in flight-hx.

---

## Signals: mutation-safe iteration during emit

**Status:** open

Flight's `emitSignal` iterates the live slots array. Adding or removing a slot during
emission modifies the array being iterated, producing index-dependent behavior that
differs from OpenFL's `DispatchIterator` semantics. OpenFL guarantees: a listener added
during dispatch does not fire in the current emission; a listener removed during dispatch
is skipped even if it has not yet been visited; nested emission gets its own iteration
frame.

**What's needed:** a snapshot-dispatch mode or connection-record model that isolates each
emission frame from concurrent mutation. This is not OpenFL-specific — any consumer
using signals for event dispatch needs predictable mutation behavior.

**Current workaround:** openfl-flight will implement its own dispatch iteration over
Flight signal storage. If Flight provides this, the adapter code can be removed.

**Source:** agents/packages/events.md — "Signal mutation requirement"

---

## Geometry: inverse matrix determinant threshold

**Status:** workaround

Flight's `inverseMatrix4` rejects determinants below 1e-6. OpenFL uses 1e-11, accepting
near-singular matrices that Flight refuses. The openfl-flight Matrix3D preserves the
OpenFL precheck, but the underlying Flight call may still reject matrices that OpenFL
would invert successfully.

**What's needed:** either a configurable threshold parameter on `inverseMatrix4`, or a
lower default threshold matching the 1e-11 convention.

**Current workaround:** Matrix3D does its own determinant check before calling Flight.

**Source:** agents/packages/geom.md — "Inverse matrix determinant threshold"

---

## Geometry: perspective projection builder

**Status:** open

Flight has no equivalent to OpenFL's perspective projection from `fieldOfView` /
`focalLength`. OpenFL's `PerspectiveProjection` constructs a projection matrix from
these parameters directly; Flight requires manual `rawData` manipulation.

**What's needed:** a `createPerspectiveProjection(fieldOfView, focalLength, ...)` or
similar in the Geometry module.

**Current workaround:** PerspectiveProjection retains direct rawData manipulation from
the OpenFL 9.5.2 source.

**Source:** agents/packages/geom.md — "Focal projection builder"

---

## Geometry: negative-scale decomposition axis convention

**Status:** workaround

Flight assigns reflections (negative scale from matrix decomposition) to the X axis.
OpenFL assigns them to the Z axis. This affects `Matrix3D.decompose()` results.

**What's needed:** either a convention parameter on the decompose function, or alignment
with the Flash/OpenFL Z-axis convention.

**Current workaround:** Matrix3D adapter remaps the decomposition output.

**Source:** agents/packages/geom.md — "Negative-scale decomposition axis"

---

## Interaction: pre-dispatch ingress hook

**Status:** open

OpenFL needs to intercept resolved interaction events (hit target, pointer state)
*before* Flight's own per-node signal bubble loop runs, in order to construct OpenFL
event objects and run the three-phase OpenFL router instead of Flight's bubble-only
traversal.

**What's needed:** an observer/hook point in InteractionManager that fires exactly once
after target resolution and before per-node signal fan-out. Alternatively, a way to
disable Flight's own bubble traversal for specific interaction types so the OpenFL
router can own the full dispatch.

**Current workaround:** TBD — likely a root-level interaction slot, which sees events
only after Flight's own traversal (wrong ordering). Builder's events.md recommends
against this as a permanent solution.

**Source:** agents/packages/events.md — "Native interaction ingress"

---

## Input: dynamic preventDefault support

**Status:** open

Flight's DOM input attachment helpers call `preventDefault()` by attachment policy
(before dispatch), not dynamically based on listener behavior. OpenFL listeners
expect to call `event.preventDefault()` during dispatch and have it reflected back
to the browser's native event.

**What's needed:** a way to defer the native `preventDefault()` decision until after
OpenFL listeners have run, or a callback-based policy that the openfl-flight bridge
can control.

**Current workaround:** none yet — this affects browser-target behavior only.

**Source:** agents/packages/events.md — "Defaults and interaction state"

---

## Template for new entries

```markdown
## Component: short description

**Status:** open | workaround | filed | resolved

Description of what openfl-flight needs and why.

**What's needed:** specific Flight API change or addition.

**Current workaround:** what openfl-flight does instead (or "none").

**Source:** path to the architecture record or package doc where this was identified.
```
