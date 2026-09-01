# Architecture

## The adapter pattern

Every openfl-flight class is an OOP wrapper around Flight's free-function API. The public
surface is OpenFL's; the internal state and logic is Flight's.

```
┌─────────────────────────────────────────────┐
│  Application code                           │
│  (imports openfl.geom.Matrix, etc.)         │
├─────────────────────────────────────────────┤
│  openfl-flight public classes               │
│  (same signatures as OpenFL 9.5.2)          │
│  ┌───────────────────────────────────────┐  │
│  │  Internal state: Flight handles       │  │
│  │  Method bodies: Flight API calls      │  │
│  └───────────────────────────────────────┘  │
├─────────────────────────────────────────────┤
│  flight-hx                                  │
│  (free functions, static facades)           │
├─────────────────────────────────────────────┤
│  Lime                                       │
│  (windowing, input, audio, GL context)      │
└─────────────────────────────────────────────┘
```

## Concrete example: openfl.geom.Matrix

OpenFL's `Matrix` is a class with instance fields (`a`, `b`, `c`, `d`, `tx`, `ty`) and
mutation methods (`translate`, `scale`, `rotate`, `concat`, `invert`, `identity`,
`transformPoint`, etc.).

Flight's `Geometry` module exposes `createMatrix`, `multiplyMatrix`, `invertMatrix`,
`transformPoint`, etc. as static functions with explicit `out` parameters.

The openfl-flight `Matrix` class:
- Holds a Flight matrix value internally (or its own `a/b/c/d/tx/ty` fields that sync
  to/from Flight's representation as needed)
- Exposes the same public fields and methods as OpenFL 9.5.2
- Routes method bodies to `flight.Geometry.*` calls
- Returns the same types the OpenFL signature declares

The public contract is OpenFL's. The work is Flight's.

## Three adaptation layers

### 1. Geometry (straightforward)

Flight's `Geometry` module is a superset of `openfl.geom`. Mapping is direct:
`Matrix`, `Point`, `Rectangle`, `Vector3D`, `ColorTransform`, `Transform` each wrap
the corresponding Flight operations. The main consideration is that Flight uses
out-parameters while OpenFL returns new objects — the wrapper allocates and returns.

### 2. Events (complex)

OpenFL implements the Flash event model: `EventDispatcher`, `addEventListener`,
`removeEventListener`, `dispatchEvent`, with capture and bubble phases propagating
through the display list. Flight uses `InteractionManager` and a signal-based system.

The openfl-flight `EventDispatcher` must implement the full Flash event model —
listener registration, event propagation with capture/target/bubble phases, priority
ordering, weak references — on top of Flight's signal infrastructure. This is the
layer most likely to harbor subtle parity differences.

### 3. Display list (structural)

OpenFL's display hierarchy is a deep class chain:
`DisplayObject` > `InteractiveObject` > `DisplayObjectContainer` > `Sprite` > `MovieClip`

Flight uses a flat node graph with free functions (`createSprite`, `createDisplayObject`,
`createScene2D`) and a node-based scene tree.

Each openfl-flight display class holds a Flight scene node internally. `addChild`,
`removeChild`, `getChildAt`, `contains`, and the rest of the container API map to
Flight scene graph operations. Property accessors (`x`, `y`, `scaleX`, `rotation`,
`alpha`, `visible`, `transform`, etc.) read from and write to the Flight node.

Flight's existing Lime host integration (`hostLime`) is a significant advantage here —
the `Stage` class can delegate window management, input routing, and render-loop
orchestration to Flight's Lime layer rather than reimplementing it.

## What is NOT copied from OpenFL

The `openfl._internal` package is not carried over. That package contains:

- Renderer implementations (Cairo, Canvas, DOM, OpenGL) — replaced by Flight's renderers
- Backend-specific context logic — replaced by Flight's host layer
- Platform shims and workarounds — not needed with Flight's abstractions
- Macro utilities — evaluated case by case; most are build-system glue

If an `_internal` utility serves a purpose that Flight doesn't cover, the correct
response is to identify what Flight needs to provide, not to copy the OpenFL internal.

## Package structure

openfl-flight mirrors OpenFL's package layout exactly:

```
src/
  openfl/
    display/       ← 86 public classes (the big one)
    events/        ← 43 classes
    geom/          ← 10 classes
    text/          ← 19 classes
    net/           ← 25 classes
    utils/         ← 24 classes
    filters/       ← 13 classes
    media/         ← 9 classes
    errors/        ← 9 classes
    ui/            ← 9 classes
    system/        ← 8 classes
    display3D/     ← 19 classes
    desktop/       ← 14 classes
    sensors/       ← 3 classes
    printing/      ← 3 classes
    filesystem/    ← 3 classes
    security/      ← 3 classes
    profiler/      ← 1 class
    globalization/ ← 6 classes
    permissions/   ← 1 class
    external/      ← 1 class
    Assets.hx
    Lib.hx
    Memory.hx
    Vector.hx
```

Every `.hx` file in this tree corresponds to a file in OpenFL 9.5.2. The package
names, class names, and file paths are identical.
