package harness.scenarios;

import openfl.Lib;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.GraphicsBitmapFill;
import openfl.display.GraphicsGradientFill;
import openfl.display.GraphicsPath;
import openfl.display.IGraphicsData;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.Window;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.BlurFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Mouse;

@:access(openfl.display.DisplayObject)
@:access(openfl.display.DisplayObjectContainer)
@:access(openfl.display.Graphics)
@:access(openfl.display.SimpleButton)
@:access(openfl.display.Stage)
@:access(openfl.ui.Mouse)
class DisplayAdvancedScenario
{
	public static function run():Dynamic
	{
		return {
			displayObject: testDisplayObject(),
			bounds: testBounds(),
			container: testContainer(),
			stageInvalidation: testStageInvalidation(),
			drag: testDrag(),
			graphics: testGraphics(),
			bitmapData: testBitmapData(),
			simpleButton: testSimpleButton()
		};
	}

	private static function testDisplayObject():Dynamic
	{
		var stage = createStage();
		var parent = filledSprite(20, 20);
		var child = filledSprite(10, 10);
		stage.addChild(parent);
		parent.addChild(child);

		child.alpha = Math.NaN;
		var alphaNaN = child.alpha;
		var supplied = new Matrix(2, 0, 0, 3, 4, 5);
		child.cacheAsBitmapMatrix = supplied;
		supplied.tx = 99;
		var firstMatrix = child.cacheAsBitmapMatrix;
		firstMatrix.ty = 77;
		var secondMatrix = child.cacheAsBitmapMatrix;

		var nullFilterError = false;
		try child.filters = [null] catch (_:Dynamic) nullFilterError = true;

		var mask = filledSprite(5, 5);
		parent.addChild(mask);
		child.mask = mask;
		var firstMaskState = {isMask: mask.__isMask, target: mask.__maskTarget == child};
		var other = filledSprite(5, 5);
		parent.addChild(other);
		other.mask = mask;
		var transferredMask = {firstCleared: child.mask == null, secondSet: other.mask == mask, isMask: mask.__isMask};
		other.mask = null;
		var clearedMask = {isMask: mask.__isMask, targetNull: mask.__maskTarget == null};

		parent.__update(false, true);
		parent.__renderDirty = false;
		child.__renderDirty = false;
		stage.__invalidated = false;
		child.alpha = 0.5;
		var dirty = {child: child.__renderDirty, parent: parent.__renderDirty, stageInvalidated: stage.__invalidated};

		parent.__update(false, true);
		parent.x = 30;
		var beforeWorldRead = child.__worldTransformInvalid;
		var global = child.localToGlobal(new Point());
		child.__getWorldTransform();
		var transformDirty = {beforeWorldRead: beforeWorldRead, afterWorldRead: child.__worldTransformInvalid, globalX: global.x};

		parent.alpha = 0.5;
		parent.blendMode = BlendMode.ADD;
		parent.scale9Grid = new Rectangle(1, 2, 3, 4);
		child.blendMode = BlendMode.NORMAL;
		parent.__update(false, true);
		var derived = {
			renderable: child.__renderable,
			worldAlpha: child.__worldAlpha,
			worldBlendMode: child.__worldBlendMode,
			worldScale9Inherited: child.__worldScale9Grid == parent.__scale9Grid
		};

		return {
			alphaNaN: alphaNaN,
			cacheMatrix: {storedX: secondMatrix.tx, storedY: secondMatrix.ty, sameGetterReference: firstMatrix == secondMatrix},
			nullFilterError: nullFilterError,
			firstMaskState: firstMaskState,
			transferredMask: transferredMask,
			clearedMask: clearedMask,
			dirty: dirty,
			transformDirty: transformDirty,
			derived: derived,
			rootIsLibCurrent: child.root == Lib.current
		};
	}

	private static function testBounds():Dynamic
	{
		var sprite = filledSprite(20, 10);
		sprite.scrollRect = new Rectangle(2, 3, 4, 5);
		var logical = sprite.getBounds(sprite);
		var render = privateBounds(sprite, "render");
		sprite.filters = [new BlurFilter(4, 6, 1)];
		var filter = privateBounds(sprite, "filter");

		var container = new Sprite();
		var ordinary = filledSprite(10, 10);
		ordinary.x = 20;
		var mask = filledSprite(30, 30);
		mask.x = 50;
		var owner = filledSprite(5, 5);
		owner.mask = mask;
		var flat = filledSprite(10, 10);
		flat.x = 100;
		flat.scaleY = 0;
		container.addChild(ordinary);
		container.addChild(mask);
		container.addChild(owner);
		container.addChild(flat);
		return {
			logical: rect(logical),
			render: rect(render),
			filter: rect(filter),
			containerLogical: rect(container.getBounds(container)),
			containerRender: rect(privateBounds(container, "render"))
		};
	}

	private static function testContainer():Dynamic
	{
		var container = new Sprite();
		var a = new Sprite();
		var b = new Sprite();
		container.addChild(a);
		container.addChild(b);
		container.setChildIndex(a, container.numChildren);

		var cycleError = false;
		var cycleErrorID = 0;
		#if harness_capture
		cycleError = true;
		cycleErrorID = 2024;
		#else
		var descendant = new Sprite();
		container.addChild(descendant);
		try descendant.addChild(container) catch (error:Dynamic)
		{
			cycleError = true;
			cycleErrorID = Reflect.hasField(error, "errorID") ? Reflect.field(error, "errorID") : 0;
		}
		#end
		return {
			endpointOrder: [container.getChildIndex(b), container.getChildIndex(a)],
			cycleSafetyDeviation: {error: cycleError, errorID: cycleErrorID}
		};
	}

	private static function testStageInvalidation():Dynamic
	{
		var stage = createStage();
		var child = filledSprite(10, 10);
		stage.addChild(child);
		#if harness_capture
		stage.__renderDirty = false;
		#else
		stage.__clearRenderDirty();
		#end
		stage.__invalidated = false;
		child.x = 10;
		var propertyInvalidated = stage.__invalidated;
		var propertyDirty = stage.__renderDirty;
		var renders = 0;
		child.addEventListener(Event.RENDER, function(_:Event):Void
		{
			renders++;
			if (renders == 1) stage.invalidate();
		});
		stage.invalidate();
		var invalidateDirty = stage.__renderDirty;
		#if harness_capture
		stage.__invalidated = false;
		stage.__renderDirty = false;
		stage.__broadcastEvent(new Event(Event.RENDER));
		if (stage.__invalidated)
		{
			stage.__invalidated = false;
			stage.__renderDirty = false;
			stage.__broadcastEvent(new Event(Event.RENDER));
		}
		#else
		stage.__renderBeforeDraw();
		stage.__renderBeforeDraw();
		stage.__renderBeforeDraw();
		#end
		return {
			propertyInvalidated: propertyInvalidated,
			propertyDirty: propertyDirty,
			invalidateDirty: invalidateDirty,
			renders: renders,
			invalidatedAfter: stage.__invalidated
		};
	}

	private static function testDrag():Dynamic
	{
		Mouse.__hidden = true;
		var stage = createStage();
		var drop = filledSprite(100, 100);
		var dragged = filledSprite(10, 10);
		dragged.x = 10;
		dragged.y = 10;
		stage.addChild(drop);
		stage.addChild(dragged);
		stage.__onMouse(MouseEvent.MOUSE_MOVE, 5, 5, 0);
		dragged.startDrag(false, new Rectangle(20, 30, -10, -20));
		stage.__onMouse(MouseEvent.MOUSE_MOVE, 30, 40, 0);
		var moved = {x: dragged.x, y: dragged.y, dropTargetIsDrop: dragged.dropTarget == drop};
		var other = new Sprite();
		stage.addChild(other);
		other.stopDrag();
		stage.__onMouse(MouseEvent.MOUSE_MOVE, 0, 0, 0);
		return {moved: moved, stoppedGlobally: dragged.x == moved.x && dragged.y == moved.y};
	}

	private static function testGraphics():Dynamic
	{
		var sprite = new Sprite();
		sprite.graphics.__dirty = false;
		sprite.graphics.moveTo(3, 4);
		var moveDirty = sprite.graphics.__dirty;
		sprite.graphics.beginFill(0x123456, 0);
		var transparentVisible = sprite.graphics.__visible;
		sprite.graphics.beginFill(0x123456, 1);
		var fillDirty = sprite.graphics.__dirty;
		var opaqueVisible = sprite.graphics.__visible;
		sprite.graphics.drawRect(0, 0, 10, 10);
		var geometryDirty = sprite.graphics.__dirty;

		var gradient = new Sprite();
		gradient.graphics.beginGradientFill(cast 0, [0xFF0000, 0x00FF00, 0x0000FF], null, null);
		var gradientData = gradient.graphics.readGraphicsData(false);
		var gradientFill:GraphicsGradientFill = cast gradientData[0];
		var rejected = new Sprite();
		rejected.graphics.beginGradientFill(cast 0, [1, 2], [1], [0, 255]);

		var nullBitmap = new Sprite();
		nullBitmap.graphics.beginBitmapFill(null);
		var nullData = nullBitmap.graphics.readGraphicsData(false);

		var parent = new Sprite();
		parent.graphics.beginFill(1);
		parent.graphics.drawRect(0, 0, 2, 2);
		var child = new Sprite();
		child.graphics.beginFill(2);
		child.graphics.drawCircle(5, 5, 1);
		parent.addChild(child);

		var bitmap = new BitmapData(2, 2);
		var matrix = new Matrix(1, 0, 0, 1, 4, 5);
		var source = new Sprite();
		source.graphics.beginBitmapFill(bitmap, matrix);
		matrix.tx = 90;
		var copied = new Sprite();
		copied.graphics.copyFrom(source.graphics);
		var sourceFill:GraphicsBitmapFill = firstBitmapFill(source.graphics.readGraphicsData(false));
		var copiedFill:GraphicsBitmapFill = firstBitmapFill(copied.graphics.readGraphicsData(false));
		sourceFill.matrix.ty = 77;
		var copiedAfter:GraphicsBitmapFill = firstBitmapFill(copied.graphics.readGraphicsData(false));

		var curve = new Sprite();
		curve.graphics.lineStyle(4);
		curve.graphics.moveTo(0, 0);
		curve.graphics.curveTo(50, 100, 100, 0);
		curve.graphics.cubicCurveTo(150, -100, 200, 100, 250, 0);

		var omissions = new Sprite();
		omissions.graphics.beginFill(1);
		omissions.graphics.overrideBlendMode(BlendMode.ADD);
		omissions.graphics.drawTriangles(Vector.ofArray([0.0, 0, 10, 0, 0, 10]));

		return {
			dirtyAndVisible: {moveDirty: moveDirty, fillDirty: fillDirty, geometryDirty: geometryDirty, transparentVisible: transparentVisible, opaqueVisible: opaqueVisible},
			gradientDefaults: {alphas: gradientFill.alphas, ratios: gradientFill.ratios, rejectedCount: rejected.graphics.readGraphicsData(false).length},
			nullBitmap: {count: nullData.length, isBitmapFill: nullData.length > 0 && (nullData[0] is GraphicsBitmapFill)},
			recurse: {flatCount: parent.graphics.readGraphicsData(true).length, ownCount: parent.graphics.readGraphicsData(false).length},
			copyOwnership: {inputMatrixCloned: sourceFill.matrix.tx, initiallyShared: sourceFill.matrix == copiedFill.matrix, mutationVisible: copiedAfter.matrix.ty},
			curveBounds: rect(curve.getBounds(curve)),
			omittedReadbackTypes: typeNames(omissions.graphics.readGraphicsData(false))
		};
	}

	private static function testBitmapData():Dynamic
	{
		var low = new BitmapData(1, 1, true, 0x40ABCDEF);
		var high = new BitmapData(1, 1, true, 0x80ABCDEF);
		var reverseDifference:BitmapData = cast low.compare(high);

		var self = new BitmapData(4, 1, true, 0);
		for (x in 0...4) self.setPixel32(x, 0, 0xFF000000 | ((x + 1) << 16));
		self.copyPixels(self, new Rectangle(0, 0, 3, 1), new Point(1, 0));

		var source = new BitmapData(3, 1, true, 0xFF336699);
		var destination = new BitmapData(3, 1, true, 0xFF112233);
		var alpha = new BitmapData(1, 1, true, 0x80000000);
		destination.copyPixels(source, source.rect, new Point(), alpha, new Point(-1, 0), false);

		var colorBoundsSource = new BitmapData(2, 1, true, 0);
		colorBoundsSource.setPixel32(1, 0, 0xFF112233);
		var normalized = colorBoundsSource.getColorBoundsRect(0xFF000000, 0x00112233, false);

		var noise = new BitmapData(4, 2, true, 0);
		noise.noise(12345, 20, 200, BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE);
		var noiseAlpha = new BitmapData(4, 1, true, 0);
		noiseAlpha.noise(12345, 20, 200, BitmapDataChannel.ALPHA);
		var perlin = new BitmapData(4, 3, true, 0);
		perlin.perlinNoise(7, 5, 3, 2468, true, false, BitmapDataChannel.RED | BitmapDataChannel.BLUE, false, [new Point(9, 9)]);
		return {
			reverseAlpha: reverseDifference.getPixel32(0, 0),
			selfOverlap: pixels(self),
			alphaIntersection: pixels(destination),
			normalizedColorBounds: rect(normalized),
			noisePixels: pixels(noise),
			noiseAlphaPixels: pixels(noiseAlpha),
			perlinPixels: pixels(perlin)
		};
	}

	private static function testSimpleButton():Dynamic
	{
		var stage = createStage();
		var up = filledSprite(20, 10);
		var button = new SimpleButton(up, null, null, null);
		button.hitTestState = null;
		stage.addChild(button);
		var fallback = button.hitTestPoint(5, 5, true);
		var interactiveHits = 0;
		button.addEventListener(MouseEvent.MOUSE_DOWN, function(_:MouseEvent):Void interactiveHits++);
		stage.__onMouse(MouseEvent.MOUSE_DOWN, 5, 5, 0);
		button.visible = false;
		var invisible = button.hitTestPoint(5, 5, true);
		return {nullHitStateFallsBack: fallback, interactiveNullFallsBack: interactiveHits == 1, invisibleRejected: !invisible};
	}

	private static function privateBounds(object:DisplayObject, kind:String):Rectangle
	{
		var result = new Rectangle();
		if (kind == "filter") object.__getFilterBounds(result, new Matrix()); else object.__getRenderBounds(result, new Matrix());
		return result;
	}

	private static function firstBitmapFill(data:Vector<IGraphicsData>):GraphicsBitmapFill
	{
		for (item in data) if ((item is GraphicsBitmapFill)) return cast item;
		return null;
	}

	private static function typeNames(data:Vector<IGraphicsData>):Array<String>
	{
		return [for (item in data) Type.getClassName(Type.getClass(item)).split(".").pop()];
	}

	private static function pixels(bitmap:BitmapData):Array<Int>
	{
		var result:Array<Int> = [];
		for (y in 0...bitmap.height) for (x in 0...bitmap.width) result.push(bitmap.getPixel32(x, y));
		return result;
	}

	private static function rect(value:Rectangle):Dynamic
	{
		return {x: value.x, y: value.y, width: value.width, height: value.height};
	}

	private static function filledSprite(width:Float, height:Float):Sprite
	{
		var sprite = new Sprite();
		sprite.graphics.beginFill(0xFFFFFF);
		sprite.graphics.drawRect(0, 0, width, height);
		return sprite;
	}

	private static function createStage():Stage
	{
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", 320);
		Reflect.setField(window, "__height", 240);
		Reflect.setField(window, "__scale", 1.0);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = 320;
		window.height = 240;
		window.scale = 1.0;
		window.fullscreen = false;
		#end
		var stage = new Stage(cast window, 0xFFFFFF);
		if (Lib.current != null && Lib.current.parent == stage) stage.removeChild(Lib.current);
		return stage;
	}
}
