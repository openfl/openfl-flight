package harness.scenarios;

import openfl.Lib;
import openfl.display.Application;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Matrix3D;
import openfl.geom.PerspectiveProjection;

class TransformScenario {
	public static function run():Dynamic {
		return {
			matrixSync: testMatrixSync(),
			rotationMatrixSync: testRotationMatrixSync(),
			scaleMatrixSync: testScaleMatrixSync(),
			matrixMutualExclusion: testMatrixMutualExclusion(),
			concatenatedMatrix: testConcatenatedMatrix(),
			concatenatedColorTransform: testConcatenatedColorTransform(),
			colorTransformAccess: testColorTransformAccess(),
			perspectiveProjectionDefaults: testPerspectiveProjectionDefaults(),
			pixelBoundsDefaults: testPixelBoundsDefaults()
		};
	}

	private static function testMatrixSync():Dynamic {
		var sprite = new Sprite();
		sprite.x = 100;
		sprite.y = 50;
		var fromProperties = sprite.transform.matrix;
		sprite.transform.matrix = new Matrix(1, 0, 0, 1, 200, 75);
		return {
			matrixTX: fromProperties.tx,
			matrixTY: fromProperties.ty,
			spriteX: sprite.x,
			spriteY: sprite.y
		};
	}

	private static function testRotationMatrixSync():Dynamic {
		var sprite = new Sprite();
		sprite.rotation = 45;
		var fromProperty = sprite.transform.matrix;
		var radians = Math.PI / 6;
		sprite.transform.matrix = new Matrix(Math.cos(radians), Math.sin(radians), -Math.sin(radians), Math.cos(radians));
		return {
			matrixA: fromProperty.a,
			matrixB: fromProperty.b,
			matrixC: fromProperty.c,
			matrixD: fromProperty.d,
			spriteRotation: sprite.rotation
		};
	}

	private static function testScaleMatrixSync():Dynamic {
		var sprite = new Sprite();
		sprite.scaleX = 2;
		var fromProperty = sprite.transform.matrix;
		sprite.transform.matrix = new Matrix(3, 0, 0, 4);
		return {
			matrixA: fromProperty.a,
			scaleX: sprite.scaleX,
			scaleY: sprite.scaleY
		};
	}

	private static function testConcatenatedMatrix():Dynamic {
		var root = new Sprite();
		var parent = new Sprite();
		var child = new Sprite();
		root.transform.matrix = new Matrix(2, 0, 0, 3, 10, 20);
		parent.x = 4;
		parent.y = 5;
		child.x = 6;
		child.y = 7;
		root.addChild(parent);
		parent.addChild(child);
		var matrix = child.transform.concatenatedMatrix;
		return {
			tx: matrix.tx,
			ty: matrix.ty
		};
	}

	private static function testMatrixMutualExclusion():Dynamic {
		var sprite = new Sprite();
		var assigned3D = new Matrix3D();
		assigned3D.appendTranslation(12, -7, 3);
		sprite.transform.matrix3D = assigned3D;
		var read3D = sprite.transform.matrix3D;
		var matrixAfter3D = sprite.transform.matrix;
		sprite.transform.matrix = new Matrix(2, 0, 0, 3, 4, 5);
		return {
			matrixIsNullAfterMatrix3D: matrixAfter3D == null,
			matrix3DReadBackIsSameReference: read3D == assigned3D,
			matrix3DTranslation: [read3D.rawData[12], read3D.rawData[13], read3D.rawData[14]],
			matrix3DIsNullAfterMatrix: sprite.transform.matrix3D == null,
			matrixAfterMatrix3D: {
				a: sprite.transform.matrix.a,
				d: sprite.transform.matrix.d,
				tx: sprite.transform.matrix.tx,
				ty: sprite.transform.matrix.ty
			}
		};
	}

	private static function testConcatenatedColorTransform():Dynamic {
		var root = new Sprite();
		var parent = new Sprite();
		var child = new Sprite();
		root.transform.colorTransform = new ColorTransform(0.5, 0.6, 0.7, 0.8, 10, 20, 30, 40);
		parent.transform.colorTransform = new ColorTransform(0.4, 0.5, 0.6, 0.7, 5, 6, 7, 8);
		child.transform.colorTransform = new ColorTransform(0.25, 0.3, 0.35, 0.4, 1, 2, 3, 4);
		root.addChild(parent);
		parent.addChild(child);
		return colorValues(child.transform.concatenatedColorTransform);
	}

	private static function testColorTransformAccess():Dynamic {
		var sprite = new Sprite();
		var value = new ColorTransform(0.5, 0.6, 0.7, 0.8, 10, 20, 30, 40);
		sprite.transform.colorTransform = value;
		var readBack = sprite.transform.colorTransform;
		return {
			sameReference: readBack == value,
			redMultiplier: readBack.redMultiplier,
			greenMultiplier: readBack.greenMultiplier,
			blueMultiplier: readBack.blueMultiplier,
			alphaMultiplier: readBack.alphaMultiplier,
			redOffset: readBack.redOffset,
			greenOffset: readBack.greenOffset,
			blueOffset: readBack.blueOffset,
			alphaOffset: readBack.alphaOffset,
			displayAlpha: sprite.alpha
		};
	}

	private static function testPerspectiveProjectionDefaults():Dynamic {
		if (Lib.current.stage == null) {
			new Application().createWindow(cast {
				width: 0,
				height: 0,
				context: {background: 0}
			});
		}
		var projection = new PerspectiveProjection();
		return {
			fieldOfView: projection.fieldOfView,
			focalLength: projection.focalLength,
			projectionCenter: {
				x: projection.projectionCenter.x,
				y: projection.projectionCenter.y
			}
		};
	}

	private static function testPixelBoundsDefaults():Dynamic {
		var bounds = new Sprite().transform.pixelBounds;
		return {
			x: bounds.x,
			y: bounds.y,
			width: bounds.width,
			height: bounds.height,
			isEmpty: bounds.isEmpty()
		};
	}

	private static function colorValues(value:ColorTransform):Dynamic {
		return {
			redMultiplier: value.redMultiplier,
			greenMultiplier: value.greenMultiplier,
			blueMultiplier: value.blueMultiplier,
			alphaMultiplier: value.alphaMultiplier,
			redOffset: value.redOffset,
			greenOffset: value.greenOffset,
			blueOffset: value.blueOffset,
			alphaOffset: value.alphaOffset
		};
	}
}
