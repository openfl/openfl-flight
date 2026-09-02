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
		var projection = new Matrix3D(Vector.ofArray([
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 1.0,
			0.0, 0.0, 0.0, 0.0
		]));
		var knownProjected = Utils3D.projectVector(projection, new Vector3D(10, 20, 5));
		var knownVerts = Vector.ofArray([
			10.0, 20.0, 5.0,
			-6.0, 3.0, 3.0
		]);
		var knownProjectedVerts = new Vector<Float>();
		var knownUVTs = Vector.ofArray([
			0.0, 0.0, 0.0,
			1.0, 1.0, 0.0
		]);
		Utils3D.projectVectors(projection, knownVerts, knownProjectedVerts, knownUVTs);

		var pointTowardsMethod = Reflect.field(Utils3D, "pointTowards");
		var pointTowardsResult:Dynamic = null;
		if (pointTowardsMethod != null) {
			pointTowardsResult = Reflect.callMethod(Utils3D, pointTowardsMethod, [1.0, new Matrix3D(), new Vector3D(0, 0, -10)]);
		}

		return {
			projectVector: roundVec(projected),
			projectVectorIsVector3D: Std.isOfType(projected, Vector3D),
			projectVectors: {
				length: projVerts.length,
				values: roundArray(projVerts),
				uvts: roundArray(uvts)
			},
			identityProjection: roundVec(identityProj),
			knownProjection: {
				projectVector: roundVec(knownProjected),
				projectVectorIsVector3D: Std.isOfType(knownProjected, Vector3D),
				projectVectors: roundArray(knownProjectedVerts),
				uvts: roundArray(knownUVTs)
			},
			pointTowards: {
				available: pointTowardsMethod != null,
				resultIsMatrix3D: Std.isOfType(pointTowardsResult, Matrix3D)
			}
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
