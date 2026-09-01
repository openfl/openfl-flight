# openfl-flight — Codebase Map

openfl-flight provides the OpenFL 9.5.2 public API with Flight (flight-hx) as the
sole implementation substrate. Application code sees OpenFL classes, methods, and
behavior unchanged; internally everything delegates to Flight's free-function API.

Read [agents/intentions.md](agents/intentions.md) for why this project exists and
what success means. Read [agents/architecture.md](agents/architecture.md) for the
adapter pattern and the three adaptation layers. Read
[agents/roadmap.md](agents/roadmap.md) for the phased implementation plan.

## Design posture

These principles are the inverse of Flight's own posture — Flight favors explicit
data and free functions; openfl-flight wraps that in OpenFL's OOP surface. Both
are deliberate.

- **OpenFL's API is the spec.** Every public class, method, field, enum, and typedef
  in OpenFL 9.5.2 exists here with the same fully-qualified name and the same
  signature. No renaming, no "improved" signatures, no new public API.

- **Flight is the implementation.** Method bodies call flight-hx. Internal state is
  Flight handles, Flight nodes, Flight geometry. Where Flight's free-function style
  and OpenFL's OOP style diverge, the wrapper bridges them — allocating return values,
  managing mutable instance state, routing event dispatch.

- **OpenFL's behavior is correct by definition.** When a question arises about what a
  method should do, the answer is whatever OpenFL 9.5.2 does. The compatibility
  harness captures that behavior as fixture data; the fixtures are the truth.

- **Gaps are Flight's to close.** If implementing an OpenFL behavior requires
  something Flight doesn't provide, that is a requirement on flight-hx, not a reason
  to carry OpenFL internal code or write a workaround. File it, describe what's
  needed, and move on to work that isn't blocked.

- **No OpenFL internals.** The `openfl._internal` package is not carried over. It
  contains renderers, platform shims, and backend logic that Flight replaces. If an
  internal utility is needed, identify what Flight should provide instead.

## Ground rules

### Language and tooling

- Haxe. Source lives under `src/openfl/`, mirroring OpenFL's package layout.
- Standard haxelib: `haxelib.json` at the root, `classPath` pointing to `src/`.
- flight-hx is a haxelib dependency.
- OpenFL 9.5.2 is a dev/test dependency only, used by the harness capture mode.
  It is never a runtime dependency of openfl-flight itself.

### Commits

- Single-line commit messages. No body. No `Co-Authored-By` trailer.
- Keep commits granular: one class or one logical change per commit.
- Stay on your working branch — do not create or switch branches.

### Implementation pattern

When implementing a class:

1. Copy the `.hx` file from OpenFL 9.5.2 `src/openfl/` into `src/openfl/` at the
   same relative path.
2. Keep every public signature exactly as-is: class name, `extends`/`implements`,
   public fields, public methods with their exact parameter names and types, enums,
   typedefs, metadata.
3. Remove all `openfl._internal` imports and the code that depends on them.
4. Replace internal state with Flight equivalents (Flight handles, typed values).
5. Replace method bodies with calls to the corresponding flight-hx API.
6. Write or extend harness scenarios covering the class's public methods.
7. Run the harness in compare mode against the captured fixtures.
8. Iterate until green.

Private and `@:noCompletion` members may be changed freely — they are not part of
the public contract. Protected members (`private` in Haxe with `@:access`) should
be preserved where subclasses in the OpenFL ecosystem might rely on them; use
judgment.

### What to preserve verbatim from OpenFL source

- Package declarations
- Import lists (adjust only to remove `openfl._internal` and add `flight.*`)
- Class/interface/enum/typedef declarations and their metadata
- Public field declarations (name, type, default value)
- Public method signatures (name, parameters, return type, metadata)
- Doc comments on public members (these are API documentation)
- Conditional compilation flags (`#if`, `@:meta`) that affect the public API

### What to replace

- Method bodies (the implementation)
- Private fields (internal state)
- `openfl._internal` imports and all code paths through them
- Renderer-specific logic
- Platform-specific workarounds that Flight's abstractions handle

## Compatibility harness

The harness is a Haxe project with two compilation modes:

### Capture mode

Compiles against real OpenFL 9.5.2. Runs test scenarios that exercise public API
methods and captures observable results — property values, return values, exception
behavior, event dispatch sequences, callback orderings — as JSON fixture files.

Fixtures are committed to the repository and regenerated only when re-pinning to a
new OpenFL version. They are the behavioral specification.

### Compare mode

Compiles against openfl-flight. Runs the same test scenarios and asserts that results
match the fixture data.

### Scenario authoring

A scenario is a function that:
1. Sets up objects using the public API
2. Performs operations
3. Returns a structured result (property reads, return values, event logs)

Scenarios must be deterministic — no random values, no timing dependencies, no
render-dependent state. State capture only; render parity is a later phase.

Scenarios import `openfl.*` — the harness build system controls which library
provides that package. The scenario source itself is library-agnostic.

## Checkpoints

### After editing any source file

Build: verify the project compiles.

### After implementing a class

Run the harness compare mode for that package. All scenarios for the class should
be green before moving on.

### After touching the event system

Run the full events harness suite, then run display-related scenarios that exercise
event dispatch through the display list (capture/bubble propagation depends on
parent-child relationships).

### After touching geometry classes

Run geom suite, then spot-check display scenarios that use transforms — geometry
is load-bearing for display positioning.

### Before handoff

Full harness green across all implemented packages. Build clean. No uncommitted
changes to source files.

## Package map

OpenFL packages and their primary Flight counterparts:

| OpenFL package       | Flight module(s)                      | Adaptation complexity |
|----------------------|---------------------------------------|-----------------------|
| `openfl.geom`        | `flight.Geometry`                     | Low — direct mapping  |
| `openfl.events`      | `flight.Interaction`, `flight.Input`  | High — model mismatch |
| `openfl.display`     | `flight.Scene2D`, `flight.Render`     | High — structural     |
| `openfl.display3D`   | `flight.Scene3D`, 3D renderers        | High — structural     |
| `openfl.text`        | `flight.TextInput`, `flight.TextLayout` | Medium              |
| `openfl.filters`     | `flight.Bitmap`, `flight.Effects`     | Medium                |
| `openfl.media`       | `flight.Audio`                        | Medium                |
| `openfl.net`         | `flight.Net`, `flight.Loader`         | Medium                |
| `openfl.utils`       | Various, some Flight, some native     | Medium — cross-cutting|
| `openfl.errors`      | Native Haxe exceptions                | Trivial               |
| `openfl.system`      | `flight.Application` (partial)        | Low                   |
| `openfl.ui`          | `flight.Input`                        | Low                   |
| `openfl.sensors`     | `flight.Input` (partial)              | Low                   |
| `openfl.desktop`     | `flight.Application` (partial)        | Low–Medium            |
| `openfl.printing`    | Platform-specific                     | Low                   |
| `openfl.security`    | Minimal logic                         | Trivial               |
| `openfl.globalization` | Minimal logic                       | Trivial               |
| `openfl.filesystem`  | Platform-specific                     | Low                   |
| `openfl.profiler`    | Minimal logic                         | Trivial               |
| `openfl.permissions` | Minimal logic                         | Trivial               |
| `openfl.external`    | Platform-specific                     | Low                   |

Where a cell says "partial" or "various," the mapping is not yet fully characterized.
Those packages should be investigated against flight-hx's current API before
implementation begins.

## Agent roles

### Builder

Your job is to implement openfl-flight classes. For each class:

1. Read the OpenFL 9.5.2 source for the class.
2. Read the corresponding Flight module API (via flight-hx source or `agents/packages/` records).
3. Copy the OpenFL class, gut the internals, reimplement with Flight calls.
4. Author harness scenarios if they don't exist for this class yet.
5. Run the harness. Iterate until green.

You own the implementation and the scenarios. Commit each class as you complete it.
When you hit a Flight gap — something OpenFL does that Flight can't — stop, describe
the gap clearly in your status, and move to a class that isn't blocked.

### Reviewer

Your job is to verify parity and adapter correctness.

- **API surface check:** Does the openfl-flight class have every public member that
  OpenFL 9.5.2 has? Same names, same types, same metadata? Missing or renamed members
  are defects.
- **Behavioral check:** Are the harness scenarios comprehensive enough? Do they cover
  edge cases (null inputs, empty collections, boundary values, error conditions)?
  Missing scenarios are gaps in verification.
- **Adapter correctness:** Does the Flight delegation look right? Is state kept in
  sync between the OOP wrapper and the Flight handle? Are allocations correct (OpenFL
  methods that return new objects must not return shared references)?
- **No OpenFL internals:** No `openfl._internal` imports, no copied internal logic,
  no workarounds for things Flight should provide.

### Integrator

Your job is to merge work across packages and maintain cross-package consistency.

- Run the full harness after merging. A regression in package A caused by a change in
  package B is your responsibility to catch.
- Verify that Flight dependency versions are consistent.
- Ensure the harness fixture data is current (captured from OpenFL 9.5.2).
- Track which packages are complete, in progress, or blocked on Flight gaps.

### Auditor

Your job is to independently verify parity claims.

- Run the harness from scratch against a fresh OpenFL 9.5.2 capture.
- Compare fixture data to committed fixtures — they should be identical (reproducible).
- Spot-check implemented classes against OpenFL source for signature drift.
- Verify that Flight gaps filed by builders are real (not misunderstandings of
  Flight's API).
- Report findings; do not fix them directly.

## Flight conventions that apply here

openfl-flight follows [Flight's agent conventions](https://github.com/flighthq/flight/blob/main/AGENTS.md)
with these adaptations:

- **Class structure:** Flight uses free functions and static facades. openfl-flight
  uses OOP class hierarchies (because OpenFL's API demands it). The OOP surface is
  not a deviation — it is the project's purpose.
- **Naming:** OpenFL's names win. Flight uses `createMatrix`; openfl-flight uses
  `new Matrix()`. Flight uses `get*`/`has*`/`is*` prefixes; OpenFL uses whatever
  Flash used. The public API is Flash's naming, period.
- **Source style:** Haxe conventions, not TypeScript. No `npm run fix`. Haxe
  formatting follows the existing OpenFL style (which is broadly standard Haxe).
- **Commits:** Same rule: single-line, no body, no trailers.
- **Testing:** The compatibility harness replaces unit tests as the primary
  verification. Unit tests are written only when adapter logic is complex enough
  to warrant isolated testing (e.g., event propagation internals).

## Reference material

- OpenFL 9.5.2 source: `https://github.com/openfl/openfl/tree/9.5.2`
- flight-hx source: `https://github.com/flighthq/flight-hx`
- Flight AGENTS.md (golden reference for agent behavior): `https://github.com/flighthq/flight/blob/main/AGENTS.md`
- Architecture records: [agents/](agents/index.md)
