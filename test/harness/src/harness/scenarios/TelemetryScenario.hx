package harness.scenarios;

import openfl.profiler.Telemetry;

class TelemetryScenario {
	public static function run():Dynamic {
		var connected:Dynamic = null;
		var connectedReadable = succeeds(function() {
			connected = Telemetry.connected;
		});
		var spanMarker:Dynamic = null;
		var spanMarkerReadable = succeeds(function() {
			spanMarker = Telemetry.spanMarker;
		});
		var metricSucceeded = succeeds(function() {
			Telemetry.sendMetric("org.openfl.test.metric", 42);
		});
		var spanMetricSucceeded = succeeds(function() {
			Telemetry.sendSpanMetric("org.openfl.test.span", spanMarker, {value: 42});
		});

		return {
			connected: connected,
			connectedReadable: connectedReadable,
			connectedIsBool: Type.typeof(connected) == TBool,
			spanMarker: spanMarker,
			spanMarkerReadable: spanMarkerReadable,
			spanMarkerIsNumber: Type.typeof(spanMarker) == TInt || Type.typeof(spanMarker) == TFloat,
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
