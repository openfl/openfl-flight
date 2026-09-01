package harness.scenarios;

import openfl.geom.Vector3D;

class Vector3DScenario {
	public static function run():Dynamic {
		var v = new Vector3D(3, 4, 5, 1);
		var v2 = new Vector3D(-1, 2, 3);
		var zero = new Vector3D();

		var added = v.add(v2);
		var subtracted = v.subtract(v2);
		var cross = v.crossProduct(v2);
		var dot = v.dotProduct(v2);

		var normalized = v.clone();
		var origLen = normalized.normalize();

		var scaled = v.clone();
		scaled.scaleBy(2.5);

		var negated = v.clone();
		negated.negate();

		var incremented = v.clone();
		incremented.incrementBy(v2);

		var decremented = v.clone();
		decremented.decrementBy(v2);

		var projected = new Vector3D(10, 20, 30, 2);
		projected.project();

		var copyTarget = new Vector3D();
		copyTarget.copyFrom(v);

		var setTarget = new Vector3D(99, 99, 99);
		setTarget.setTo(1, 2, 3);

		var perpA = new Vector3D(1, 0, 0);
		var perpB = new Vector3D(0, 1, 0);
		var parallelA = new Vector3D(1, 0, 0);
		var parallelB = new Vector3D(2, 0, 0);
		var fortyFiveA = new Vector3D(1, 0, 0);
		var fortyFiveB = new Vector3D(1, 1, 0);

		return {
			construct: vec(v),
			constructDefault: vec(zero),
			length: round(v.length),
			lengthSquared: v.lengthSquared,
			zeroLength: zero.length,
			add: vec(added),
			subtract: vec(subtracted),
			crossProduct: vec(cross),
			dotProduct: dot,
			normalize: {
				result: roundVec(normalized),
				returnedLength: round(origLen),
				newLength: round(normalized.length)
			},
			scaleBy: vec(scaled),
			negate: vec(negated),
			incrementBy: vec(incremented),
			decrementBy: vec(decremented),
			project: vec(projected),
			copyFrom: vec(copyTarget),
			setTo: vec(setTarget),
			clone: {
				values: vec(v.clone()),
				notSame: v.clone() != v
			},
			equals: {
				sameXYZ: v.equals(new Vector3D(3, 4, 5, 99)),
				sameXYZW: v.equals(new Vector3D(3, 4, 5, 1), true),
				diffW: v.equals(new Vector3D(3, 4, 5, 99), true),
				different: v.equals(v2)
			},
			nearEquals: {
				within: v.nearEquals(new Vector3D(3.001, 4.001, 5.001), 0.01),
				outside: v.nearEquals(new Vector3D(3.1, 4.1, 5.1), 0.01),
				withW: v.nearEquals(new Vector3D(3, 4, 5, 1.001), 0.01, true),
				wOutside: v.nearEquals(new Vector3D(3, 4, 5, 2), 0.01, true)
			},
			angleBetween: {
				perpendicular: round(Vector3D.angleBetween(perpA, perpB)),
				parallel: round(Vector3D.angleBetween(parallelA, parallelB)),
				fortyFive: round(Vector3D.angleBetween(fortyFiveA, fortyFiveB))
			},
			distance: {
				normal: round(Vector3D.distance(v, v2)),
				same: Vector3D.distance(v, v.clone()),
				fromOrigin: round(Vector3D.distance(zero, new Vector3D(3, 4, 0)))
			},
			axes: {
				xAxis: vec(Vector3D.X_AXIS),
				yAxis: vec(Vector3D.Y_AXIS),
				zAxis: vec(Vector3D.Z_AXIS)
			}
		};
	}

	private static function vec(v:Vector3D):Dynamic {
		return {
			x: v.x,
			y: v.y,
			z: v.z,
			w: v.w
		};
	}

	private static function roundVec(v:Vector3D):Dynamic {
		return {
			x: round(v.x),
			y: round(v.y),
			z: round(v.z),
			w: v.w
		};
	}

	private static function round(v:Float):Float {
		return Math.round(v * 100000) / 100000;
	}
}
