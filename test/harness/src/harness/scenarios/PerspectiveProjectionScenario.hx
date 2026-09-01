package harness.scenarios;

import openfl.geom.Matrix3D;
import openfl.geom.PerspectiveProjection;
import openfl.geom.Point;

class PerspectiveProjectionScenario {
	public static function run():Dynamic {
		var pp = new PerspectiveProjection();

		var defaultFov = pp.fieldOfView;
		var defaultFocal = pp.focalLength;
		var defaultCenter = pp.projectionCenter;

		var m = pp.toMatrix3D();

		pp.fieldOfView = 90;
		var wideFov = pp.fieldOfView;
		var wideFocal = pp.focalLength;
		var wideMatrix = pp.toMatrix3D();

		pp.fieldOfView = 30;
		var narrowFov = pp.fieldOfView;
		var narrowFocal = pp.focalLength;

		pp.projectionCenter = new Point(100, 200);

		return {
			defaults: {
				fieldOfView: round(defaultFov),
				focalLength: round(defaultFocal),
				projectionCenter: coords(defaultCenter)
			},
			defaultMatrix: roundRawData(m),
			wideFov: {
				fieldOfView: round(wideFov),
				focalLength: round(wideFocal),
				matrix: roundRawData(wideMatrix)
			},
			narrowFov: {
				fieldOfView: round(narrowFov),
				focalLength: round(narrowFocal)
			},
			projectionCenter: coords(pp.projectionCenter)
		};
	}

	private static function coords(p:Point):Dynamic {
		return {
			x: p.x,
			y: p.y
		};
	}

	private static function roundRawData(m:Matrix3D):Array<Float> {
		var result:Array<Float> = [];
		for (i in 0...16) {
			result.push(round(m.rawData[i]));
		}
		return result;
	}

	private static function round(v:Float):Float {
		return Math.round(v * 100000) / 100000;
	}
}
