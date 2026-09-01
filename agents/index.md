# agents/

Architecture records, plans, and project direction for openfl-flight.

Status lives in each document, not here. This index points to where things are;
each file declares its own state.

## Project foundation

- [Intentions](intentions.md) — why this project exists and what success looks like
- [Architecture](architecture.md) — the adapter pattern, the three adaptation layers, package structure
- [Roadmap](roadmap.md) — phased implementation plan from leaf packages to display core

## Compatibility harness

- (planned) `harness.md` — capture/compare architecture, fixture format, scenario authoring

## Package-level records

As implementation proceeds, each package gets an architecture record documenting
its Flight mapping, open questions, and parity status.

- (planned) `packages/geom.md` — geometry adapter: OpenFL ↔ Flight mapping
- [Event model bridge](packages/events.md) — OpenFL event flow over Flight signals and interaction input
- (planned) `packages/display.md` — display list adapter, scene node wrapping
