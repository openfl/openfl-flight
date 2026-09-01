package harness.scenarios;

import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;

class DisplayTransformScenario {
	public static function run():Dynamic {
		var parent = new Sprite();
		var child = new Sprite();
		parent.x = 100;
		child.x = 50;
		parent.addChild(child);
		var translated = child.localToGlobal(new Point(0, 0));

		var rotationParent = new Sprite();
		var rotationChild = new Sprite();
		rotationParent.x = 20;
		rotationParent.y = 30;
		rotationParent.rotation = 45;
		rotationChild.x = 10;
		rotationParent.addChild(rotationChild);
		var rotated = rotationChild.localToGlobal(new Point(0, 0));
		var inverted = rotationChild.globalToLocal(rotated);

		var matrixSprite = new Sprite();
		matrixSprite.transform.matrix = new Matrix(0, 2, -3, 0, 12, 34);
		var matrix = matrixSprite.transform.matrix;

		var colorParent = new Sprite();
		var colorChild = new Sprite();
		colorParent.transform.colorTransform = new ColorTransform(0.5, 0.75, 1, 0.8, 10, 20, 30, 40);
		colorChild.transform.colorTransform = new ColorTransform(0.25, 0.5, 0.75, 0.5, 2, 4, 6, 8);
		colorParent.addChild(colorChild);
		var concatenated = colorChild.transform.concatenatedColorTransform;

		return {
			translated: point(translated),
			rotated: point(rotated),
			inverted: point(inverted),
			matrix: {
				a: number(matrix.a),
				b: number(matrix.b),
				c: number(matrix.c),
				d: number(matrix.d),
				tx: number(matrix.tx),
				ty: number(matrix.ty),
				x: number(matrixSprite.x),
				y: number(matrixSprite.y),
				rotation: number(matrixSprite.rotation),
				scaleX: number(matrixSprite.scaleX),
				scaleY: number(matrixSprite.scaleY)
			},
			concatenatedColor: color(concatenated)
		};
	}

	private static function point(value:Point):Dynamic {
		return {x: number(value.x), y: number(value.y)};
	}

	private static function color(value:ColorTransform):Dynamic {
		return {
			redMultiplier: number(value.redMultiplier),
			greenMultiplier: number(value.greenMultiplier),
			blueMultiplier: number(value.blueMultiplier),
			alphaMultiplier: number(value.alphaMultiplier),
			redOffset: number(value.redOffset),
			greenOffset: number(value.greenOffset),
			blueOffset: number(value.blueOffset),
			alphaOffset: number(value.alphaOffset)
		};
	}

	private static function number(value:Float):Float {
		return Math.round(value * 1000000) / 1000000;
	}
}
