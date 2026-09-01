package harness.scenarios;

import openfl.Vector;
import openfl.geom.Matrix3D;
import openfl.geom.Utils3D;
import openfl.geom.Vector3D;

class Utils3DScenario {
	public static function run():Dynamic {
		var perspective = new Matrix3D();
		perspective.appendTranslation(0, 0, 100);

		var projected = Utils3D.projectVector(perspective, new Vector3D(10, 20, 30));

		var verts = Vector.ofArray([
			10.0, 20.0, 30.0,
			-5.0, 15.0, 40.0,
			0.0, 0.0, 50.0
		]);
		var projVerts = new Vector<Float>();
		var uvts = Vector.ofArray([
			0.0, 0.0, 0.0,
			0.5, 0.5, 0.0,
			1.0, 1.0, 0.0
		]);
		Utils3D.projectVectors(perspective, verts, projVerts, uvts);

		var identityProj = Utils3D.projectVector(new Matrix3D(), new Vector3D(10, 20, 30));

		return {
			projectVector: roundVec(projected),
			projectVectors: {
				length: projVerts.length,
				values: roundArray(projVerts)
			},
			identityProjection: roundVec(identityProj)
		};
	}

	private static function roundVec(v:Vector3D):Dynamic {
		return {
			x: round(v.x),
			y: round(v.y),
			z: round(v.z),
			w: round(v.w)
		};
	}

	private static function roundArray(v:Vector<Float>):Array<Float> {
		var result:Array<Float> = [];
		for (i in 0...v.length) {
			result.push(round(v[i]));
		}
		return result;
	}

	private static function round(v:Float):Float {
		return Math.round(v * 100000) / 100000;
	}
}
