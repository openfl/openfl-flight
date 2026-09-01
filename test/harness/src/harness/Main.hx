package harness;

class Main {
	public static function main():Void {
		#if harness_capture
		capture();
		#elseif harness_compare
		compare();
		#else
		throw "Compile with either harness_capture or harness_compare";
		#end
	}

	private static function capture():Void {
		for (scenario in Scenarios.all()) {
			FixtureStore.write(scenario.name, scenario.run());
			Sys.println('CAPTURED ${scenario.name}');
		}
	}

	private static function compare():Void {
		var failures = 0;

		for (scenario in Scenarios.all()) {
			try {
				var expected = FixtureStore.read(scenario.name);
				var actual = scenario.run();
				JsonAssert.equals(expected, actual);
				Sys.println('PASS ${scenario.name}');
			} catch (error:Dynamic) {
				failures++;
				Sys.println('FAIL ${scenario.name}: ${Std.string(error)}');
			}
		}

		if (failures > 0) {
			Sys.println('$failures scenario(s) failed');
			Sys.exit(1);
		}

		Sys.println('All ${Scenarios.all().length} scenario(s) passed');
	}
}
