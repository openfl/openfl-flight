package harness.scenarios;

import openfl.geom.Matrix3D;
import openfl.geom.PerspectiveProjection;
import openfl.geom.Point;

class PerspectiveProjectionScenario {
	public static function run():Dynamic {
		var pp = new PerspectiveProjection();
		pp.focalLength = 250;
		pp.projectionCenter = new Point(200, 150);

		var m = pp.toMatrix3D();

		pp.focalLength = 500;
		var wideMatrix = pp.toMatrix3D();

		pp.focalLength = 100;
		var narrowMatrix = pp.toMatrix3D();

		return {
			focalLength250: {
				focalLength: pp.focalLength,
				projectionCenter: coords(pp.projectionCenter),
				matrix: m != null ? roundRawData(m) : null
			},
			focalLength500: {
				matrix: wideMatrix != null ? roundRawData(wideMatrix) : null
			},
			focalLength100: {
				matrix: narrowMatrix != null ? roundRawData(narrowMatrix) : null
			}
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
