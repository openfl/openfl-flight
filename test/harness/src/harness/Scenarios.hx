package harness;

import harness.scenarios.BitmapDataScenario;
import harness.scenarios.ByteArrayScenario;
import harness.scenarios.CertificateStatusScenario;
import harness.scenarios.ColorTransformScenario;
import harness.scenarios.DateTimeFormatterScenario;
import harness.scenarios.DictionaryScenario;
import harness.scenarios.DisplayContainerScenario;
import harness.scenarios.DisplayObjectScenario;
import harness.scenarios.ErrorScenario;
import harness.scenarios.ErrorSubclassesScenario;
import harness.scenarios.EventConstructionScenario;
import harness.scenarios.EventDispatcherCaptureScenario;
import harness.scenarios.EventDispatcherScenario;
import harness.scenarios.EventSubclassesScenario;
import harness.scenarios.ExternalInterfaceScenario;
import harness.scenarios.FilterScenario;
import harness.scenarios.LocaleIDScenario;
import harness.scenarios.Matrix3DScenario;
import harness.scenarios.MatrixScenario;
import harness.scenarios.PermissionStatusScenario;
import harness.scenarios.PointScenario;
import harness.scenarios.RectangleScenario;
import harness.scenarios.SystemScenario;
import harness.scenarios.TelemetryScenario;
import harness.scenarios.TextFieldScenario;
import harness.scenarios.TextFormatScenario;
import harness.scenarios.Utils3DScenario;
import harness.scenarios.Vector3DScenario;

class Scenarios {
	public static function all():Array<Scenario> {
		return [
			{
				name: "geom/point",
				run: PointScenario.run
			},
			{
				name: "geom/rectangle",
				run: RectangleScenario.run
			},
			{
				name: "geom/matrix",
				run: MatrixScenario.run
			},
			{
				name: "geom/vector3d",
				run: Vector3DScenario.run
			},
			{
				name: "geom/color-transform",
				run: ColorTransformScenario.run
			},
			{
				name: "geom/matrix3d",
				run: Matrix3DScenario.run
			},
			{
				name: "geom/utils3d",
				run: Utils3DScenario.run
			},
			{
				name: "errors/error",
				run: ErrorScenario.run
			},
			{
				name: "errors/subclasses",
				run: ErrorSubclassesScenario.run
			},
			{
				name: "events/construction",
				run: EventConstructionScenario.run
			},
			{
				name: "events/dispatcher",
				run: EventDispatcherScenario.run
			},
			{
				name: "events/dispatcher-capture",
				run: EventDispatcherCaptureScenario.run
			},
			{
				name: "events/subclasses",
				run: EventSubclassesScenario.run
			},
			{
				name: "globalization/date-time-formatter",
				run: DateTimeFormatterScenario.run
			},
			{
				name: "globalization/locale-id",
				run: LocaleIDScenario.run
			},
			{
				name: "external/external-interface",
				run: ExternalInterfaceScenario.run
			},
			{
				name: "permissions/permission-status",
				run: PermissionStatusScenario.run
			},
			{
				name: "profiler/telemetry",
				run: TelemetryScenario.run
			},
			{
				name: "security/certificate-status",
				run: CertificateStatusScenario.run
			},
			{
				name: "display/display-object",
				run: DisplayObjectScenario.run
			},
			{
				name: "display/container",
				run: DisplayContainerScenario.run
			},
			{
				name: "display/bitmap-data",
				run: BitmapDataScenario.run
			},
			{
				name: "filters/properties",
				run: FilterScenario.run
			},
			{
				name: "text/text-field",
				run: TextFieldScenario.run
			},
			{
				name: "text/text-format",
				run: TextFormatScenario.run
			},
			{
				name: "system/capabilities",
				run: SystemScenario.run
			},
			{
				name: "utils/byte-array",
				run: ByteArrayScenario.run
			},
			{
				name: "utils/dictionary",
				run: DictionaryScenario.run
			}
		];
	}
}
