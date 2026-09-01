# openfl.geom — Package Record

Status: implemented, pending compile verification

## Flight mapping

All 10 classes implemented using flight-hx Geometry and Materials modules.

| Class | Flight backing | Notes |
|-------|---------------|-------|
| Point | Geometry vector2 ops | Direct mapping |
| Rectangle | Geometry rectangle ops | Direct mapping |
| Matrix | Geometry matrix ops | Direct mapping |
| Vector3D | Geometry vector3/4 ops | Direct mapping |
| ColorTransform | Materials color ops | Direct mapping |
| Transform | Geometry + display node | Linked to DisplayObject private contract |
| Matrix3D | Geometry matrix4 ops | Decomposition remapping needed (see below) |
| PerspectiveProjection | Direct rawData updates | No Flight equivalent for focal projection |
| Orientation3D | Enum/constants | Verbatim |
| Utils3D | Geometry projection ops | Direct mapping |

## Flight gaps found

### 1. Inverse matrix determinant threshold

Flight's `inverseMatrix4` rejects determinants below 1e-6. OpenFL uses 1e-11.
The openfl-flight Matrix3D preserves the OpenFL precheck, but the underlying
Flight call may still reject matrices that OpenFL would invert successfully.

**Requirement on flight-hx:** configurable or lower determinant threshold.

### 2. Negative-scale decomposition axis

Flight assigns reflections (negative scale from decomposition) to the X axis.
OpenFL assigns them to the Z axis. Builder2 wrote compatible remapping in the
Matrix3D adapter, so this is handled — but it's adapter logic that ideally
wouldn't be needed if Flight matched the convention.

### 3. Focal projection builder

Flight has no equivalent to OpenFL's perspective projection from fieldOfView /
focalLength. PerspectiveProjection retains direct rawData manipulation from
the pinned source.

**Requirement on flight-hx:** perspective projection builder matching OpenFL's
fieldOfView/focalLength model.
