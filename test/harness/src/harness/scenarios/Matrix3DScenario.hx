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

		var copyColumns = custom.clone();
		var copiedColumn = new Vector3D();
		copyColumns.copyColumnTo(3, copiedColumn);
		copyColumns.copyColumnFrom(1, new Vector3D(5, 6, 7, 8));
		var copyRows = custom.clone();
		var copiedRow = new Vector3D();
		copyRows.copyRowTo(2, copiedRow);
		copyRows.copyRowFrom(1, new Vector3D(9, 8, 7, 6));

		var rawSource = Vector.ofArray([99.0, 98, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 97]);
		var rawFrom = new Matrix3D();
		rawFrom.copyRawDataFrom(rawSource, 2, true);
		var rawTo = Vector.ofArray([50.0, 51, 52]);
		custom.copyRawDataTo(rawTo, 2, true);

		var tripleOut = Vector.ofArray([99.0]);
		transformSrc.transformVectors(Vector.ofArray([1.0, 2, 3, -1, -2, -3, 42]), tripleOut);

		var outputParts = Vector.ofArray([new Vector3D(101, 102, 103), new Vector3D(201, 202, 203), new Vector3D(301, 302, 303)]);
		var output0 = outputParts[0];
		var output1 = outputParts[1];
		var output2 = outputParts[2];
		var decomposedOutput = decomposeM.decomposeToOutput(EULER_ANGLES, outputParts);

		var reflected = new Matrix3D(Vector.ofArray([
			1.0, 0, 0, 0,
			0, 2, 0, 0,
			0, 0, -3, 0,
			4, 5, 6, 1
		]));
		var reflectedParts = reflected.decompose();

		var pointed = new Matrix3D();
		pointed.pointAt(new Vector3D(2, 3, 4), new Vector3D(0, 1, 0), new Vector3D(0, 0, 1));

		var copiedFrom = new Matrix3D();
		var copiedFromOld = copiedFrom.rawData;
		var malformedSource = new Matrix3D();
		malformedSource.rawData = Vector.ofArray([2.0, 3, 4]);
		copiedFrom.copyFrom(malformedSource);
		var copiedTo = new Matrix3D();
		var copiedToOld = copiedTo.rawData;
		malformedSource.copyToMatrix3D(copiedTo);
		var malformedClone = malformedSource.clone();

		var identityReference = custom.clone();
		var oldIdentityData = identityReference.rawData;
		identityReference.identity();

		var recomposeReference = new Matrix3D();
		var oldRecomposeData = recomposeReference.rawData;
		var recomposeReferenceResult = recomposeReference.recompose(euler);

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
			copyColumnsRows: {
				columnRead: vec(copiedColumn),
				columnWritten: rawData(copyColumns),
				rowRead: vec(copiedRow),
				rowWritten: rawData(copyRows)
			},
			copyRawData: {
				from: rawData(rawFrom),
				to: vectorData(rawTo)
			},
			createHelpers: {
				create2D: roundRawData(Matrix3D.create2D(10, 20, 2, 30)),
				createABCD: rawData(Matrix3D.createABCD(1, 2, 3, 4, 5, 6)),
				createOrtho: roundRawData(Matrix3D.createOrtho(-2, 6, -4, 8, 1, 101))
			},
			transformVectorTriples: vectorData(tripleOut),
			interpolateElements: roundRawData(Matrix3D.interpolate(identity, custom, 0.25)),
			decomposeOutputAliasing: {
				returnedInput: decomposedOutput == outputParts,
				reused: [decomposedOutput[0] == output0, decomposedOutput[1] == output1, decomposedOutput[2] == output2],
				values: roundVecArray(decomposedOutput)
			},
			reflectionNegativeZ: roundVecArray(reflectedParts),
			pointAtSourceQuirk: roundRawData(pointed),
			copyRawDataReferences: {
				copyFromLength: copiedFrom.rawData.length,
				copyFromReplaced: copiedFrom.rawData != copiedFromOld,
				copyFromShares: copiedFrom.rawData == malformedSource.rawData,
				copyToLength: copiedTo.rawData.length,
				copyToReplaced: copiedTo.rawData != copiedToOld,
				copyToShares: copiedTo.rawData == malformedSource.rawData,
				malformedClone: rawData(malformedClone)
			},
			identityRawDataReference: {
				replaced: identityReference.rawData != oldIdentityData,
				oldFirst: oldIdentityData[0],
				matrix: rawData(identityReference)
			},
			recomposeRawDataReference: {
				result: recomposeReferenceResult,
				replaced: recomposeReference.rawData != oldRecomposeData,
				oldFirst: oldRecomposeData[0],
				matrix: roundRawData(recomposeReference)
			},
			clone: {
				values: rawData(custom.clone()),
				notSame: custom.clone() != custom,
				rawDataNotShared: custom.clone().rawData != custom.rawData
			}
		};
	}

	private static function vectorData(values:Vector<Float>):Array<Float> {
		var result:Array<Float> = [];
		for (value in values) result.push(round(value));
		return result;
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
