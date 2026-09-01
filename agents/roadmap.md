# Roadmap

OpenFL 9.5.2 is the fixed target. Flight evolves to serve this project. Implementation
proceeds leaf-to-core: packages with fewer cross-openfl dependencies first, so each
phase builds on a verified foundation.

## Phase 0 — Scaffolding

- Project structure: `haxelib.json`, `include.xml`, source root at `src/`
- flight-hx as a dependency
- Compatibility harness skeleton with capture and compare modes
- CI running the harness

**Gate:** harness can capture fixtures from real OpenFL 9.5.2 and compare against a
stub openfl-flight build (all red is expected; the machinery works).

## Phase 1 — Geometry

Package: `openfl.geom` (10 classes)

`Matrix`, `Point`, `Rectangle`, `Vector3D`, `ColorTransform`, `Transform`,
`Matrix3D`, `PerspectiveProjection`, `Orientation3D`, `Utils3D`.

Flight's `Geometry` module covers all of these and more. This is the cleanest
mapping and the proof that the adapter pattern works end-to-end.

**Gate:** harness fixtures for all geom classes pass green.

## Phase 2 — Events

Package: `openfl.events` (43 classes)

`Event`, `EventDispatcher`, `EventPhase`, then the full event type catalog:
`MouseEvent`, `KeyboardEvent`, `FocusEvent`, `TextEvent`, `TouchEvent`,
`GameInputEvent`, etc.

This is the hardest adaptation layer. The Flash event model (capture/target/bubble
phases, priority ordering, `stopPropagation`, `stopImmediatePropagation`,
`preventDefault`) must be implemented on top of Flight's signal system.

**Gate:** event dispatch ordering, propagation, and cancellation match OpenFL
behavior per the harness.

## Phase 3 — Pure types

Packages: `errors` (9), `security` (3), `system` (8), `globalization` (6),
`permissions` (1), `profiler` (1), `external` (1), `sensors` (3)

Mostly enums, exception classes, and lightweight types with minimal or no Flight
dependency. These can be copied nearly verbatim from OpenFL since they carry
little internal logic.

**Gate:** harness green for all leaf packages.

## Phase 4 — Mid-tier packages

Packages: `filters` (13), `ui` (9), `printing` (3)

These depend on geom and events (already done) and display types (stubs may be
needed). `filters` maps to Flight's `Bitmap` filter operations and `Effects`.

**Gate:** harness green for mid-tier packages.

## Phase 5 — Utilities and I/O

Packages: `utils` (24), `media` (9), `net` (25), `filesystem` (3), `desktop` (14)

`utils` is cross-cutting and has 21 internal files in OpenFL — significant
reimplementation. `ByteArray`, `Timer`, `Dictionary`, and the typed arrays are the
high-complexity classes. `net` covers `URLLoader`, `URLRequest`, `Socket`,
`SharedObject`.

**Gate:** harness green for utilities and I/O.

## Phase 6 — Text

Package: `openfl.text` (19 classes, 10 internal files in OpenFL)

`TextField`, `TextFormat`, `Font`, `TextFieldType`, `TextFieldAutoSize`,
`TextLineMetrics`, `StaticText`, etc. Depends on display, events, and geom.

Flight has text input, layout, shaping, and segmentation packages. The mapping
from OpenFL's simpler text model to Flight's more granular system needs careful
design.

**Gate:** harness green for text.

## Phase 7 — Display and Display3D

Packages: `display` (86 classes, 61 internal files), `display3D` (19 classes,
22 internal files)

The core and the heaviest rewrite. Every preceding phase feeds into this.

Key classes: `DisplayObject`, `InteractiveObject`, `DisplayObjectContainer`,
`Sprite`, `MovieClip`, `Bitmap`, `BitmapData`, `Graphics`, `Shape`, `Stage`,
`Loader`, `SimpleButton`, `Tilemap`, `Video`.

`display3D`: `Context3D`, `Program3D`, `VertexBuffer3D`, `IndexBuffer3D`,
`Texture`, etc.

This phase is likely to surface the most Flight gaps and drive the most
flight-hx evolution.

**Gate:** harness green for display. Full suite green across all packages.

## Ordering rationale

The sequence is dictated by the dependency graph: display depends on events
which depends on geom. Building upward means each new layer's dependencies are
already verified, and the harness catches regressions in lower layers as upper
layers exercise them in combination.

Events before pure types (phase 2 before 3) because the event system is the
highest-risk adaptation and the longest lead-time item. Starting it early
surfaces Flight signal-model gaps while the pure types (low risk, quick wins)
can be parallelized alongside.
