package harness.scenarios;

import openfl.profiler.Telemetry;

class TelemetryScenario {
	public static function run():Dynamic {
		var metricSucceeded = succeeds(function() {
			Telemetry.sendMetric("org.openfl.test.metric", 42);
		});
		var spanMetricSucceeded = succeeds(function() {
			Telemetry.sendSpanMetric("org.openfl.test.span", Telemetry.spanMarker, {value: 42});
		});

		return {
			connected: Telemetry.connected,
			spanMarker: Telemetry.spanMarker,
			registerCommandHandler: Telemetry.registerCommandHandler("org.openfl.test", function(_) return null),
			unregisterCommandHandler: Telemetry.unregisterCommandHandler("org.openfl.test"),
			metricSucceeded: metricSucceeded,
			spanMetricSucceeded: spanMetricSucceeded
		};
	}

	private static function succeeds(operation:Void->Void):Bool {
		try {
			operation();
			return true;
		} catch (_:Dynamic) {
			return false;
		}
	}
}
