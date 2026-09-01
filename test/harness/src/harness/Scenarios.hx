package harness;

import harness.scenarios.PointScenario;

class Scenarios {
	public static function all():Array<Scenario> {
		return [
			{
				name: "geom/point",
				run: PointScenario.run
			}
		];
	}
}
