package harness.scenarios;

import openfl.Lib;
import openfl.display.Stage;
import openfl.display.Window;
import openfl.geom.Matrix3D;
import openfl.geom.PerspectiveProjection;
import openfl.geom.Point;

class PerspectiveProjectionScenario {
	public static function run():Dynamic {
		if (Lib.current.stage == null) {
			var window:Dynamic = Type.createEmptyInstance(Window);
			#if harness_capture
			Reflect.setField(window, "__width", 0);
			Reflect.setField(window, "__height", 0);
			Reflect.setField(window, "__scale", 1);
			#else
			window.width = 0;
			window.height = 0;
			window.scale = 1;
			#end
			new Stage(cast window, 0).addChild(Lib.current);
		}
		var pp = new PerspectiveProjection();
		pp.focalLength = 250;
		var center = new Point(200, 150);
		pp.projectionCenter = center;

		var m = pp.toMatrix3D();
		var matrix250 = roundRawData(m);
		m.rawData[1] = 123;

		pp.focalLength = 500;
		var wideMatrix = pp.toMatrix3D();
		var matrix500 = roundRawData(wideMatrix);

		pp.focalLength = 100;
		var narrowMatrix = pp.toMatrix3D();
		var matrix100 = roundRawData(narrowMatrix);

		var output = new Matrix3D();
		output.rawData[2] = 456;
		var outputResult = pp.toMatrix3DToOutput(output);
		var allocatedOutput = pp.toMatrix3DToOutput(null);

		var fieldProjection = new PerspectiveProjection();
		var storedFieldOfView = fieldProjection.fieldOfView = 60;

		return {
			focalLength250: {
				focalLength: 250,
				projectionCenter: coords(pp.projectionCenter),
				matrix: matrix250
			},
			focalLength500: {
				matrix: matrix500
			},
			focalLength100: {
				matrix: matrix100
			},
			fieldOfView: {
				setterResult: round(storedFieldOfView),
				stored: round(fieldProjection.fieldOfView),
				focalLength: round(fieldProjection.focalLength)
			},
			projectionCenterOwned: pp.projectionCenter == center,
			matrixOwnedReuse: m == wideMatrix && wideMatrix == narrowMatrix,
			matrixPartialWrite: {retainedIndex1: narrowMatrix.rawData[1], values: matrix100},
			matrixOutput: {
				providedReturned: outputResult == output,
				retainedIndex2: output.rawData[2],
				values: roundRawData(output),
				allocatedWhenNull: allocatedOutput != null
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
