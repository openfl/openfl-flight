package harness;

import harness.scenarios.CertificateStatusScenario;
import harness.scenarios.DateTimeFormatterScenario;
import harness.scenarios.ErrorScenario;
import harness.scenarios.ErrorSubclassesScenario;
import harness.scenarios.ExternalInterfaceScenario;
import harness.scenarios.LocaleIDScenario;
import harness.scenarios.PermissionStatusScenario;
import harness.scenarios.PointScenario;
import harness.scenarios.TelemetryScenario;

class Scenarios {
	public static function all():Array<Scenario> {
		return [
			{
				name: "geom/point",
				run: PointScenario.run
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
			}
		];
	}
}
