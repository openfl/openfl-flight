package harness.scenarios;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.Window;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class DisplayGeomIntegrationScenario
{
	public static function run():Dynamic
	{
		var stage = createStage(800, 600);
		return {
			bounds: testBounds(stage),
			coordinateRoundTrip: testCoordinateRoundTrip(stage),
			shapeHitTest: testShapeHitTest(stage),
			matrixAssignment: testMatrixAssignment(),
			concatenatedMatrix: testConcatenatedMatrix(stage)
		};
	}

	private static function testBounds(stage:Stage):Dynamic
	{
		var parent = new Sprite();
		parent.x = 120;
		parent.y = 80;
		parent.rotation = 30;
		parent.scaleX = 1.5;
		parent.scaleY = 0.75;
		var child = filledRect(-10, -5, 40, 20);
		child.x = 25;
		child.y = -12;
		child.rotation = -20;
		child.scaleX = 0.8;
		child.scaleY = 1.2;
		stage.addChild(parent);
		parent.addChild(child);

		return {
			self: rectangle(child.getBounds(child)),
			parent: rectangle(child.getBounds(parent)),
			stage: rectangle(child.getBounds(stage)),
			parentOnStage: rectangle(parent.getBounds(stage))
		};
	}

	private static function testCoordinateRoundTrip(stage:Stage):Dynamic
	{
		var parent = new Sprite();
		parent.transform.matrix = matrixFrom(25, 1.4, 0.65, 90, 45);
		var child = new Sprite();
		child.transform.matrix = matrixFrom(-37, 0.8, 1.25, 18, -11);
		stage.addChild(parent);
		parent.addChild(child);
		var local = new Point(7.25, -3.5);
		var global = child.localToGlobal(local);
		var restored = child.globalToLocal(global);

		return {
			local: point(local),
			global: point(global),
			restored: point(restored),
			delta: point(new Point(restored.x - local.x, restored.y - local.y))
		};
	}

	private static function testShapeHitTest(stage:Stage):Dynamic
	{
		var shape = new Sprite();
		shape.graphics.beginFill(0x336699);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.drawRect(30, 30, 10, 10);
		shape.graphics.endFill();
		shape.x = 350;
		shape.y = 220;
		stage.addChild(shape);
		var center = shape.localToGlobal(new Point(5, 5));
		var corner = shape.localToGlobal(new Point(20, 20));
		var outside = shape.localToGlobal(new Point(50, 50));

		return {
			center: hitPair(shape, center),
			corner: hitPair(shape, corner),
			outside: hitPair(shape, outside)
		};
	}

	private static function testMatrixAssignment():Dynamic
	{
		var sprite = new Sprite();
		sprite.transform.matrix = new Matrix(0, 2, -3, 0, 45, -30);
		return {
			matrix: matrix(sprite.transform.matrix),
			x: number(sprite.x),
			y: number(sprite.y),
			rotation: number(sprite.rotation),
			scaleX: number(sprite.scaleX),
			scaleY: number(sprite.scaleY)
		};
	}

	private static function testConcatenatedMatrix(stage:Stage):Dynamic
	{
		var root = new Sprite();
		var parent = new Sprite();
		var child = new Sprite();
		root.transform.matrix = matrixFrom(12, 1.1, 0.9, 30, 40);
		parent.transform.matrix = matrixFrom(-23, 0.75, 1.3, -14, 22);
		child.transform.matrix = matrixFrom(41, 1.2, 0.6, 8, -9);
		stage.addChild(root);
		root.addChild(parent);
		parent.addChild(child);
		var concatenated = child.transform.concatenatedMatrix;
		var local = new Point(3, 4);
		var viaMatrix = concatenated.transformPoint(local);
		var viaDisplay = child.localToGlobal(local);

		return {
			matrix: matrix(concatenated),
			viaMatrix: point(viaMatrix),
			viaDisplay: point(viaDisplay),
			matchesDisplayConversion: close(viaMatrix.x, viaDisplay.x) && close(viaMatrix.y, viaDisplay.y)
		};
	}

	private static function hitPair(shape:Sprite, point:Point):Dynamic
	{
		return {
			bounds: shape.hitTestPoint(point.x, point.y, false),
			shape: shape.hitTestPoint(point.x, point.y, true)
		};
	}

	private static function filledRect(x:Float, y:Float, width:Float, height:Float):Sprite
	{
		var sprite = new Sprite();
		sprite.graphics.beginFill(0x8844CC);
		sprite.graphics.drawRect(x, y, width, height);
		sprite.graphics.endFill();
		return sprite;
	}

	private static function matrixFrom(rotation:Float, scaleX:Float, scaleY:Float, tx:Float, ty:Float):Matrix
	{
		var radians = rotation * Math.PI / 180;
		return new Matrix(Math.cos(radians) * scaleX, Math.sin(radians) * scaleX, -Math.sin(radians) * scaleY,
			Math.cos(radians) * scaleY, tx, ty);
	}

	private static function createStage(width:Int, height:Int):Stage
	{
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", width);
		Reflect.setField(window, "__height", height);
		Reflect.setField(window, "__scale", 1.0);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = width;
		window.height = height;
		window.scale = 1.0;
		window.fullscreen = false;
		#end
		var stage = new Stage(cast window, 0);
		if (Lib.current != null && Lib.current.parent == stage) stage.removeChild(Lib.current);
		return stage;
	}

	private static function rectangle(value:Rectangle):Dynamic
	{
		return {x: number(value.x), y: number(value.y), width: number(value.width), height: number(value.height)};
	}

	private static function matrix(value:Matrix):Dynamic
	{
		return {a: number(value.a), b: number(value.b), c: number(value.c), d: number(value.d), tx: number(value.tx), ty: number(value.ty)};
	}

	private static function point(value:Point):Dynamic
	{
		return {x: number(value.x), y: number(value.y)};
	}

	private static function close(left:Float, right:Float):Bool
	{
		return Math.abs(left - right) < 0.000001;
	}

	private static function number(value:Float):Float
	{
		return Math.round(value * 1000000) / 1000000;
	}
}
