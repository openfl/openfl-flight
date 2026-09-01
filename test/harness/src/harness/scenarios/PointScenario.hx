package harness.scenarios;

import openfl.geom.Point;

class PointScenario {
	public static function run():Dynamic {
		var point = new Point(3, 4);
		var added = point.add(new Point(-1, 2));
		var subtracted = point.subtract(new Point(1, 1));
		var normalized = point.clone();
		normalized.normalize(10);

		return {
			point: coordinates(point),
			add: coordinates(added),
			subtract: coordinates(subtracted),
			distanceFromOrigin: Point.distance(point, new Point()),
			normalizeToTen: coordinates(normalized),
			equals: {
				same: point.equals(new Point(3, 4)),
				different: point.equals(new Point(4, 3))
			}
		};
	}

	private static function coordinates(point:Point):Dynamic {
		return {
			x: point.x,
			y: point.y
		};
	}
}
