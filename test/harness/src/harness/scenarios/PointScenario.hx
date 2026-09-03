package harness.scenarios;

import openfl.geom.Point;

class PointScenario {
	public static function run():Dynamic {
		var point = new Point(3, 4);
		var added = point.add(new Point(-1, 2));
		var subtracted = point.subtract(new Point(1, 1));
		var normalized = point.clone();
		normalized.normalize(10);
		var offset = new Point(-2, 7);
		offset.offset(5, -3);
		var set = new Point();
		set.setTo(8, -6);
		var copied = new Point();
		copied.copyFrom(set);
		var first = new Point(2, 6);
		var second = new Point(10, -2);

		return {
			point: coordinates(point),
			length: point.length,
			add: coordinates(added),
			subtract: coordinates(subtracted),
			distanceFromOrigin: Point.distance(point, new Point()),
			distanceKnownPoints: Point.distance(new Point(1, 2), new Point(4, 6)),
			interpolate: {
				midpoint: coordinates(Point.interpolate(first, second, 0.5)),
				firstEndpoint: coordinates(Point.interpolate(first, second, 1)),
				secondEndpoint: coordinates(Point.interpolate(first, second, 0))
			},
			polar: coordinates(Point.polar(5, 0)),
			normalizeToTen: coordinates(normalized),
			offset: coordinates(offset),
			setTo: coordinates(set),
			copyFrom: coordinates(copied),
			stringFormat: point.toString(),
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
