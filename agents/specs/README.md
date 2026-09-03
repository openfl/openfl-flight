# Behavioral Specs

YAML specifications of every observable OpenFL 9.5.2 behavior. Each entry
has a stable ID, a prose description, and provenance into the OpenFL source.

These specs describe **what OpenFL does** — they carry no implementation
status, no tracking of whether openfl-flight handles a behavior, and no
Flight gap references. Conformance is derived mechanically: a spec entry
has a scenario, the scenario has a fixture captured from real OpenFL, and
the compare-mode harness reports pass or fail.

## Schema

```yaml
# One file per OpenFL package (or logical group).
package: events

entries:
  - id: events.ED.listener-identity
    section: EventDispatcher core > Listener registration
    behavior: >
      Listener identity is (type, callback, useCapture). Adding the same
      identity twice is a no-op, even when the second call supplies a
      different priority or weak-reference flag.
    source:                    # OpenFL 9.5.2 file(s) and member(s) this was inferred from
      - events/EventDispatcher.hx:addEventListener
    scenarios:                 # fixture-path:result-key references
      - events/dispatcher:listenerIdentity
    notes:                     # optional — target conditions, quirks, edge cases
```

## Removed fields

The following fields are **no longer part of the schema** and should be
stripped from all spec files:

- `status` — was `covered | missing | flight-gap | deviation`. Conformance
  is now derived: has scenario + scenario passes = conformant.
- `gap` — was a flight-gaps.md entry name. Flight gaps are tracked in
  `agents/flight-gaps.md`, not in the behavioral spec.

If a behavior is an intentional project deviation from OpenFL 9.5.2, note
it in `notes:` with the rationale. The spec still describes what OpenFL
does; the deviation is openfl-flight's choice, not the spec's.

## Source provenance

Format: `<relative-path>:<member>` — the path under OpenFL's `src/openfl/`
and the class member (method, property, field) the behavior was inferred
from. Multiple sources are common (a behavior may span a public method and
an internal helper).

```yaml
source:
  - display/DisplayObject.hx:addChild
  - display/DisplayObjectContainer.hx:__addChild
```

For target-conditional behaviors, include a `notes:` field naming which
`#if` conditions apply (e.g., `notes: html5 only — #if html5 branch`).

## ID convention

`<package>.<class-abbrev>.<behavior-slug>`

Class abbreviations:
- ED = EventDispatcher
- DO = DisplayObject
- DOC = DisplayObjectContainer
- IO = InteractiveObject
- STG = Stage
- GFX = Graphics
- BMD = BitmapData
- BMP = Bitmap
- SB = SimpleButton
- TF = TextField
- TE = TextEngine (internal)
- MTX = Matrix
- M3D = Matrix3D
- PT = Point
- RCT = Rectangle
- V3D = Vector3D
- TFM = Transform
- CT = ColorTransform
- PP = PerspectiveProjection
- O3D = Orientation3D
- U3D = Utils3D
- BA = ByteArray
- TMR = Timer
- SND = Sound
- SC = SoundChannel
- SM = SoundMixer
- UL = URLLoader
- UR = URLRequest
- SOK = Socket
- SO = SharedObject
- FR = FileReference
- C3D = Context3D
- S3D = Stage3D
- NW = NativeWindow
- NA = NativeApplication
- NP = NativeProcess
- CB = Clipboard
- FL = File
- FS = FileStream
- BF = BevelFilter
- Bevel = BevelFilter (alt)
- Blur = BlurFilter
- CM = ColorMatrixFilter
- Conv = ConvolutionFilter
- DM = DisplacementMapFilter
- DS = DropShadowFilter
- Glow = GlowFilter
- Gradient = GradientBevelFilter / GradientGlowFilter
- Shader = ShaderFilter
- Const = FilterConstant (enums)
- Keyboard = Keyboard
- KeyLocation = KeyLocation
- Mouse = Mouse
- GI = GameInput
- GID = GameInputDevice
- GIC = GameInputControl
- Multitouch = Multitouch
- MTMode = MultitouchInputMode

Slugs are lowercase-kebab-case, descriptive of the specific behavior.

## Scenario references

Format: `<fixture-path>:<result-key>` — the fixture JSON path under
`test/fixtures/` (without `.json`) and the dot-path to the result key
that exercises this behavior. The coverage script matches these against
the fixture files and scenario source.

## Coverage tools

- `agents/specs/coverage.sh` — parses all YAML spec files, reports
  scenario mapping coverage and broken refs.
- `agents/specs/api-surface.sh` — parses OpenFL 9.5.2 source, extracts
  public API members, cross-references against spec `source:` fields to
  flag public members with no behavioral entry and spec entries whose
  source location no longer exists.
