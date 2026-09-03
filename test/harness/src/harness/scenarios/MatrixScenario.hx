package harness.scenarios;

import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Vector3D;

class MatrixScenario {
	public static function run():Dynamic {
		var m = new Matrix();
		var custom = new Matrix(2, 0.5, -0.5, 2, 10, 20);

		var translated = new Matrix();
		translated.translate(30, 40);

		var scaled = new Matrix();
		scaled.scale(2, 3);

		var rotated = new Matrix();
		rotated.rotate(Math.PI / 4);

		var concated = new Matrix(2, 0, 0, 2, 0, 0);
		concated.concat(new Matrix(1, 0, 0, 1, 10, 20));

		var inverted = new Matrix(2, 0.5, -0.5, 2, 10, 20);
		inverted.invert();

		var invertId = new Matrix();
		invertId.invert();

		var boxed = new Matrix();
		boxed.createBox(2, 3, Math.PI / 6, 10, 20);

		var gradBox = new Matrix();
		gradBox.createGradientBox(100, 50, Math.PI / 3, 5, 10);

		var identReset = new Matrix(2, 3, 4, 5, 6, 7);
		identReset.identity();

		var setToM = new Matrix();
		setToM.setTo(1.5, 2.5, 3.5, 4.5, 5.5, 6.5);

		var copyM = new Matrix();
		copyM.copyFrom(custom);

		var transformSrc = new Matrix(2, 1, -1, 2, 10, 20);
		var tp = transformSrc.transformPoint(new Point(3, 4));
		var dtp = transformSrc.deltaTransformPoint(new Point(3, 4));

		var scaleRotate = new Matrix();
		scaleRotate.scale(2, 3);
		scaleRotate.rotate(Math.PI / 4);
		scaleRotate.translate(100, 200);

		var columns = new Matrix(1, 2, 3, 4, 5, 6);
		var column = new Vector3D();
		columns.copyColumnTo(1, column);
		columns.copyColumnFrom(0, new Vector3D(7, 8, 9));

		var rows = new Matrix(1, 2, 3, 4, 5, 6);
		var row = new Vector3D();
		rows.copyRowTo(1, row);
		rows.copyRowFrom(0, new Vector3D(7, 8, 9));

		return {
			identity: mat(m),
			custom: mat(custom),
			translate: mat(translated),
			scale: mat(scaled),
			rotate: roundMat(rotated),
			concat: mat(concated),
			invert: roundMat(inverted),
			invertIdentity: mat(invertId),
			createBox: roundMat(boxed),
			createGradientBox: roundMat(gradBox),
			identityReset: mat(identReset),
			setTo: mat(setToM),
			copyFrom: mat(copyM),
			transformPoint: roundCoords(tp),
			deltaTransformPoint: roundCoords(dtp),
			transformVsDelta: {
				transformHasTranslation: tp.x != dtp.x || tp.y != dtp.y
			},
			composeScaleRotateTranslate: roundMat(scaleRotate),
			copyColumns: {read: vector(column), written: mat(columns)},
			copyRows: {read: vector(row), written: mat(rows)},
			stringFormat: custom.toString(),
			clone: {
				values: mat(custom.clone()),
				notSame: custom.clone() != custom
			},
			equals: {
				same: custom.equals(new Matrix(2, 0.5, -0.5, 2, 10, 20)),
				different: custom.equals(m)
			}
		};
	}

	private static function vector(v:Vector3D):Dynamic {
		return {x: v.x, y: v.y, z: v.z, w: v.w};
	}

	private static function mat(m:Matrix):Dynamic {
		return {
			a: m.a,
			b: m.b,
			c: m.c,
			d: m.d,
			tx: m.tx,
			ty: m.ty
		};
	}

	private static function roundMat(m:Matrix):Dynamic {
		return {
			a: round(m.a),
			b: round(m.b),
			c: round(m.c),
			d: round(m.d),
			tx: round(m.tx),
			ty: round(m.ty)
		};
	}

	private static function roundCoords(p:Point):Dynamic {
		return {
			x: round(p.x),
			y: round(p.y)
		};
	}

	private static function round(v:Float):Float {
		return Math.round(v * 100000) / 100000;
	}
}
