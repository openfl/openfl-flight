package harness.scenarios;

import openfl.Vector;
import openfl.geom.Matrix3D;
import openfl.geom.Orientation3D;
import openfl.geom.Vector3D;

class Matrix3DScenario {
	public static function run():Dynamic {
		var identity = new Matrix3D();

		var custom = new Matrix3D(Vector.ofArray([
			2.0, 0.0, 0.0, 0.0,
			0.0, 3.0, 0.0, 0.0,
			0.0, 0.0, 4.0, 0.0,
			10.0, 20.0, 30.0, 1.0
		]));

		var appended = identity.clone();
		appended.append(custom);

		var prepended = identity.clone();
		prepended.prepend(custom);

		var translateAppend = new Matrix3D();
		translateAppend.appendTranslation(10, 20, 30);

		var translatePrepend = new Matrix3D();
		translatePrepend.prependTranslation(10, 20, 30);

		var rotateAppend = new Matrix3D();
		rotateAppend.appendRotation(45, Vector3D.Y_AXIS);

		var rotatePrepend = new Matrix3D();
		rotatePrepend.prependRotation(90, Vector3D.Z_AXIS);

		var rotatePivot = new Matrix3D();
		rotatePivot.appendRotation(90, Vector3D.Z_AXIS, new Vector3D(10, 0, 0));

		var scaleAppend = new Matrix3D();
		scaleAppend.appendScale(2, 3, 4);

		var scalePrepend = new Matrix3D();
		scalePrepend.prependScale(0.5, 0.5, 0.5);

		var inverted = custom.clone();
		var invertResult = inverted.invert();

		var transposed = custom.clone();
		transposed.transpose();

		var transformSrc = new Matrix3D();
		transformSrc.appendTranslation(10, 20, 30);
		transformSrc.appendScale(2, 2, 2);
		var tv = transformSrc.transformVector(new Vector3D(1, 2, 3));
		var dtv = transformSrc.deltaTransformVector(new Vector3D(1, 2, 3));

		var decomposeM = new Matrix3D();
		decomposeM.appendScale(2, 3, 4);
		decomposeM.appendRotation(30, Vector3D.Y_AXIS);
		decomposeM.appendTranslation(10, 20, 30);

		var euler = decomposeM.decompose(EULER_ANGLES);
		var axisAngle = decomposeM.decompose(AXIS_ANGLE);
		var quaternion = decomposeM.decompose(QUATERNION);

		var recomposeM = new Matrix3D();
		var recomposeResult = recomposeM.recompose(euler, EULER_ANGLES);

		var posGet = custom.position;
		var posSet = custom.clone();
		posSet.position = new Vector3D(99, 88, 77);

		return {
			identity: rawData(identity),
			custom: rawData(custom),
			determinant: round(custom.determinant),
			identityDeterminant: identity.determinant,
			append: rawData(appended),
			prepend: rawData(prepended),
			appendTranslation: rawData(translateAppend),
			prependTranslation: rawData(translatePrepend),
			appendRotation: roundRawData(rotateAppend),
			prependRotation: roundRawData(rotatePrepend),
			rotatePivot: roundRawData(rotatePivot),
			appendScale: rawData(scaleAppend),
			prependScale: rawData(scalePrepend),
			invert: {
				result: invertResult,
				data: roundRawData(inverted)
			},
			transpose: rawData(transposed),
			transformVector: roundVec(tv),
			deltaTransformVector: roundVec(dtv),
			transformVsDelta: {
				transformHasTranslation: tv.x != dtv.x || tv.y != dtv.y || tv.z != dtv.z
			},
			decomposeEuler: roundVecArray(euler),
			decomposeAxisAngle: roundVecArray(axisAngle),
			decomposeQuaternion: roundVecArray(quaternion),
			recompose: {
				result: recomposeResult,
				data: roundRawData(recomposeM)
			},
			position: {
				get: vec(posGet),
				set: rawData(posSet)
			},
			clone: {
				values: rawData(custom.clone()),
				notSame: custom.clone() != custom
			}
		};
	}

	private static function rawData(m:Matrix3D):Array<Float> {
		var result:Array<Float> = [];
		for (i in 0...16) {
			result.push(m.rawData[i]);
		}
		return result;
	}

	private static function roundRawData(m:Matrix3D):Array<Float> {
		var result:Array<Float> = [];
		for (i in 0...16) {
			result.push(round(m.rawData[i]));
		}
		return result;
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
			w: round(v.w)
		};
	}

	private static function roundVecArray(arr:Vector<Vector3D>):Array<Dynamic> {
		var result:Array<Dynamic> = [];
		for (i in 0...arr.length) {
			result.push(roundVec(arr[i]));
		}
		return result;
	}

	private static function round(v:Float):Float {
		return Math.round(v * 100000) / 100000;
	}
}
