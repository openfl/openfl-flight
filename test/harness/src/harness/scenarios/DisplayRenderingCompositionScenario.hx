package harness.scenarios;

import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.Window;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class DisplayRenderingCompositionScenario {
	public static function run():Dynamic {
		return {
			bitmapDraw: testBitmapDraw(),
			cacheAsBitmap: testCacheAsBitmap(),
			scrollRect: testScrollRect(),
			opaqueBackground: testOpaqueBackground(),
			filters: testFilters()
		};
	}

	private static function testBitmapDraw():Dynamic {
		var source = filledSprite("draw-source", 1, 1, 3, 2);
		var direct = new BitmapData(6, 5, true, 0);
		direct.draw(source);

		source.cacheAsBitmap = true;
		source.opaqueBackground = 0x123456;
		var cached = new BitmapData(6, 5, true, 0);
		cached.draw(source);

		return {
			direct: pixels(direct),
			cached: pixels(cached)
		};
	}

	private static function testCacheAsBitmap():Dynamic {
		var source = filledSprite("cache-source", 5, 7, 40, 20);
		var initialBounds = source.getBounds(source);
		var initial = source.cacheAsBitmap;
		source.cacheAsBitmap = true;
		var manual = source.cacheAsBitmap;
		source.cacheAsBitmap = false;
		source.filters = [new BlurFilter(4, 6, 2)];
		var filterForced = source.cacheAsBitmap;
		source.cacheAsBitmap = false;
		var explicitFalseWithFilter = source.cacheAsBitmap;
		var filteredBounds = source.getBounds(source);
		source.filters = [];

		return {
			initial: initial,
			manual: manual,
			filterForced: filterForced,
			explicitFalseWithFilter: explicitFalseWithFilter,
			afterFilterClear: source.cacheAsBitmap,
			initialBounds: rect(initialBounds),
			filteredBounds: rect(filteredBounds)
		};
	}

	private static function testScrollRect():Dynamic {
		var stage = createStage(320, 240);
		if (Lib.current != null && Lib.current.parent == stage) stage.removeChild(Lib.current);
		var viewport = new Sprite();
		viewport.name = "viewport";
		viewport.x = 100;
		viewport.y = 50;
		var content = filledSprite("content", 0, 0, 80, 40);
		viewport.addChild(content);
		stage.addChild(viewport);

		var beforeBounds = viewport.getBounds(stage);
		var beforeOrigin = viewport.localToGlobal(new Point());
		var assignedRect = new Rectangle(20, 10, 30, 20);
		viewport.scrollRect = assignedRect;
		assignedRect.x = 99;
		var firstRead = viewport.scrollRect;
		firstRead.y = 88;
		var secondRead = viewport.scrollRect;

		var clipped = {
			bounds: rect(viewport.getBounds(stage)),
			origin: point(viewport.localToGlobal(new Point())),
			scrollOrigin: point(viewport.localToGlobal(new Point(20, 10))),
			insideNames: names(stage.getObjectsUnderPoint(new Point(105, 55))),
			outsideNames: names(stage.getObjectsUnderPoint(new Point(135, 55))),
			beforeWindowNames: names(stage.getObjectsUnderPoint(new Point(85, 45))),
			insideHit: viewport.hitTestPoint(105, 55),
			outsideHit: viewport.hitTestPoint(135, 55)
		};

		viewport.scrollRect = null;
		return {
			beforeBounds: rect(beforeBounds),
			beforeOrigin: point(beforeOrigin),
			assignedClone: rect(secondRead),
			clipped: clipped,
			cleared: viewport.scrollRect == null,
			clearedOrigin: point(viewport.localToGlobal(new Point())),
			clearedNames: names(stage.getObjectsUnderPoint(new Point(135, 55)))
		};
	}

	private static function testOpaqueBackground():Dynamic {
		var source = filledSprite("opaque-source", 0, 0, 10, 10);
		var initialIsNull = source.opaqueBackground == null;
		source.cacheAsBitmap = true;
		source.opaqueBackground = 0x123456;
		var assigned = source.opaqueBackground;
		source.opaqueBackground = 0;
		var black = source.opaqueBackground;
		source.opaqueBackground = null;
		return {
			initialIsNull: initialIsNull,
			assigned: assigned,
			black: black,
			clearedIsNull: source.opaqueBackground == null,
			cacheAsBitmap: source.cacheAsBitmap
		};
	}

	private static function testFilters():Dynamic {
		var source = filledSprite("filter-source", 0, 0, 20, 10);
		var blur = new BlurFilter(4, 6, 2);
		var matrix = [
			1.0, 0.0, 0.0, 0.0, 10.0,
			0.0, 1.0, 0.0, 0.0, 20.0,
			0.0, 0.0, 1.0, 0.0, 30.0,
			0.0, 0.0, 0.0, 1.0, 0.0
		];
		var color = new ColorMatrixFilter(matrix);
		var assigned:Array<BitmapFilter> = [blur, color];
		source.filters = assigned;
		blur.blurX = 99;
		matrix[0] = 9;
		assigned.pop();

		var firstRead = source.filters;
		var firstBlur:BlurFilter = cast firstRead[0];
		var firstColor:ColorMatrixFilter = cast firstRead[1];
		firstBlur.blurY = 77;
		firstRead.pop();
		var secondRead = source.filters;
		var secondBlur:BlurFilter = cast secondRead[0];
		var secondColor:ColorMatrixFilter = cast secondRead[1];
		var cacheForcedBeforeClear = source.cacheAsBitmap;
		source.filters = null;

		return {
			inputCountAfterMutation: assigned.length,
			firstReadCountAfterMutation: firstRead.length,
			secondReadCount: secondRead.length,
			blurX: secondBlur.blurX,
			blurY: secondBlur.blurY,
			colorMatrix0: secondColor.matrix[0],
			firstColorMatrix0: firstColor.matrix[0],
			cacheForcedBeforeClear: cacheForcedBeforeClear,
			afterClearCount: source.filters.length,
			afterClearCache: source.cacheAsBitmap
		};
	}

	private static function filledSprite(name:String, x:Float, y:Float, width:Float, height:Float):Sprite {
		var sprite = new Sprite();
		sprite.name = name;
		sprite.graphics.beginFill(0x336699);
		sprite.graphics.drawRect(x, y, width, height);
		sprite.graphics.endFill();
		return sprite;
	}

	private static function createStage(width:Int, height:Int):Stage {
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", width);
		Reflect.setField(window, "__height", height);
		Reflect.setField(window, "__scale", 1);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = width;
		window.height = height;
		window.scale = 1;
		window.fullscreen = false;
		#end
		return new Stage(cast window, 0xFFFFFF);
	}

	private static function names(objects:Array<DisplayObject>):Array<String> {
		return [for (object in objects) object.name];
	}

	private static function pixels(bitmapData:BitmapData):Array<Int> {
		var result:Array<Int> = [];
		for (y in 0...bitmapData.height) {
			for (x in 0...bitmapData.width) result.push(bitmapData.getPixel32(x, y));
		}
		return result;
	}

	private static function point(value:Point):Dynamic {
		return {x: number(value.x), y: number(value.y)};
	}

	private static function rect(value:Rectangle):Dynamic {
		return {
			x: number(value.x),
			y: number(value.y),
			width: number(value.width),
			height: number(value.height)
		};
	}

	private static function number(value:Float):Float {
		return Math.round(value * 1000000) / 1000000;
	}
}
