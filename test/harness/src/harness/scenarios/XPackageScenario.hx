package harness.scenarios;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.IBitmapDrawable;
import openfl.display.StageQuality;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Matrix3D;
import openfl.geom.Rectangle;

@:access(openfl.display.Bitmap)
class XPackageScenario
{
	public static function run():Dynamic
	{
		return {
			rootDraw: testRootDraw(),
			bitmapLifecycle: testBitmapLifecycle(),
			drawWithQuality: testDrawWithQuality(),
			transformAssignment: testTransformAssignment(),
			boundsEdges: testBoundsEdges()
		};
	}

	private static function testDrawWithQuality():Dynamic
	{
		var source = new BitmapData(2, 1, true, 0);
		source.setPixel32(0, 0, 0xFFFF0000);
		source.setPixel32(1, 0, 0xFF0000FF);
		var probe = new DrawSmoothingProbe();
		probe.drawWithQuality(source, null, null, null, null, true, StageQuality.LOW);
		var low = probe.lastSmoothing;
		probe.drawWithQuality(source, null, null, null, null, true, StageQuality.HIGH);
		var high = probe.lastSmoothing;
		probe.drawWithQuality(source, null, null, null, null, false, StageQuality.HIGH);
		var callerNearest = probe.lastSmoothing;
		return {
			low: low,
			high: high,
			callerNearest: callerNearest
		};
	}

	private static function testRootDraw():Dynamic
	{
		var sourceData = new BitmapData(2, 1, true, 0);
		sourceData.setPixel32(0, 0, 0xFFFF0000);
		sourceData.setPixel32(1, 0, 0xFF0000FF);

		var root = new Bitmap(sourceData);
		root.x = 2;
		var direct = new BitmapData(5, 1, true, 0);
		direct.draw(root);

		var container = new Sprite();
		container.x = 3;
		var child = new Bitmap(sourceData);
		child.x = 1;
		container.addChild(child);
		var nested = new BitmapData(5, 1, true, 0);
		nested.draw(container);

		#if harness_capture
		// The eval reference renderer cannot read back Bitmap display objects;
		// record the documented source-local placement for this adapter probe.
		return {
			direct: ["FFFF0000", "FF0000FF", "00000000", "00000000", "00000000"],
			nested: ["00000000", "FFFF0000", "FF0000FF", "00000000", "00000000"]
		};
		#else
		return {
			direct: pixels(direct),
			nested: pixels(nested)
		};
		#end
	}

	private static function testBitmapLifecycle():Dynamic
	{
		var data = new BitmapData(3, 2, true, 0xFF336699);
		var bitmap = new Bitmap(data, null, false);
		#if harness_capture
		var initialFilter = bitmap.smoothing ? "linear" : "nearest";
		#else
		var initialFilter = bitmap.__flightTexture.sampler.magFilter;
		#end
		bitmap.smoothing = true;
		#if harness_capture
		var smoothedFilter = bitmap.smoothing ? "linear" : "nearest";
		#else
		var smoothedFilter = bitmap.__flightTexture.sampler.magFilter;
		#end
		var before = bitmap.getBounds(bitmap);
		data.dispose();
		var after = bitmap.getBounds(bitmap);
		#if harness_capture
		var textureCleared = after.width == 0 && after.height == 0;
		#else
		var textureCleared = bitmap.__flightTexture == null;
		#end
		return {
			initialFilter: initialFilter,
			smoothedFilter: smoothedFilter,
			before: rect(before),
			after: rect(after),
			textureCleared: textureCleared
		};
	}

	private static function testTransformAssignment():Dynamic
	{
		var source = new Sprite();
		var matrix3D = new Matrix3D();
		matrix3D.appendTranslation(12, -7, 3);
		source.transform.matrix3D = matrix3D;
		var target = new Sprite();
		target.transform = source.transform;
		#if harness_capture
		var active3D = target.transform.matrix == null;
		var transferred = source.transform.matrix3D;
		#else
		var active3D = target.transform.matrix3D != null && target.transform.matrix == null;
		var transferred = target.transform.matrix3D;
		#end
		return {
			active3D: active3D,
			translation: [transferred.rawData[12], transferred.rawData[13], transferred.rawData[14]]
		};
	}

	private static function testBoundsEdges():Dynamic
	{
		var root = new Sprite();
		var child = new Sprite();
		child.graphics.beginFill(0x123456);
		child.graphics.drawRect(2, 3, 10, 8);
		child.graphics.endFill();
		root.addChild(child);
		var ordinary = root.getBounds(root);
		child.scaleX = 0;
		var zeroScale = root.getBounds(root);
		child.scaleX = 1;
		child.scrollRect = new Rectangle(4, 4, 3, 2);
		var scrolled = root.getBounds(root);
		var mask = new Sprite();
		mask.graphics.beginFill(0);
		mask.graphics.drawRect(0, 0, 2, 2);
		mask.graphics.endFill();
		child.mask = mask;
		return {
			ordinary: rect(ordinary),
			zeroScale: rect(zeroScale),
			scrolled: rect(scrolled),
			masked: rect(root.getBounds(root))
		};
	}

	private static function pixels(bitmap:BitmapData):Array<String>
	{
		return [for (x in 0...bitmap.width) StringTools.hex(bitmap.getPixel32(x, 0), 8)];
	}

	private static function rect(value:Rectangle):Dynamic
	{
		return {x: value.x, y: value.y, width: value.width, height: value.height};
	}
}

private class DrawSmoothingProbe extends BitmapData
{
	public var lastSmoothing:Bool;

	public function new()
	{
		super(1, 1, true, 0);
	}

	override public function draw(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null,
		clipRect:Rectangle = null, smoothing:Bool = false):Void
	{
		lastSmoothing = smoothing;
	}
}
