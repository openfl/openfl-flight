# Behavioral Specs

YAML specifications of every observable OpenFL 9.5.2 behavior. Each entry
has a stable ID, a prose description, and an implementation status.

## Schema

```yaml
# One file per OpenFL package (or logical group).
# Top-level key is the package/group name.
package: events

entries:
  - id: events.ED.listener-identity
    section: EventDispatcher core > Listener registration
    behavior: >
      Listener identity is (type, callback, useCapture). Adding the same
      identity twice is a no-op, even when the second call supplies a
      different priority or weak-reference flag.
    status: covered          # covered | missing | flight-gap | deviation
    gap:                     # flight-gaps.md entry name, when status is flight-gap
    scenarios:               # filled by coverage script or manually
      - events/dispatcher:listenerIdentity
    notes:                   # optional — project decisions, quirks
```

## Status values

- **covered**: our implementation handles this behavior
- **missing**: not implemented, divergent, or needs a scenario capture
- **flight-gap**: blocked on a named Flight capability (cite in `gap:`)
- **deviation**: intentional project decision differing from OpenFL 9.5.2
  (explain in `notes:`)

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

## Coverage script

`agents/specs/coverage.sh` parses all YAML spec files, collects IDs and
their scenario references, cross-references against fixture files and
scenario source, and reports coverage.
