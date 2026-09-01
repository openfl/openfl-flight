package openfl.display;

#if !flash
import openfl.Vector;
import openfl.display3D.textures.TextureBase;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Future;
import openfl.utils.Object;
#if lime
import lime.graphics.Image;
#else
private typedef Image = Dynamic;
#end
#if (js && html5)
import js.html.CanvasElement;
#else
private typedef CanvasElement = Dynamic;
#end

/**
	Provides the OpenFL bitmap API while platform pixel storage, codecs, filters,
	and rendering are implemented through Flight.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class BitmapData implements IBitmapDrawable
{
	public var height(default, null):Int;
	@SuppressWarnings("checkstyle:Dynamic")
	public var image(default, null):#if lime Image #else Dynamic #end;
	@:beta public var readable(default, null):Bool;
	public var rect(default, null):Rectangle;
	public var transparent(default, null):Bool;
	public var width(default, null):Int;

	@:noCompletion private var __pixels:Array<UInt>;

	public function new(width:Int, height:Int, transparent:Bool = true, fillColor:UInt = 0xFFFFFFFF)
	{
		this.width = width < 0 ? 0 : width;
		this.height = height < 0 ? 0 : height;
		this.transparent = transparent;
		readable = true;
		rect = new Rectangle(0, 0, this.width, this.height);
		__pixels = [];
		var color = transparent ? fillColor : (0xFF000000 | (fillColor & 0xFFFFFF));
		for (i in 0...(this.width * this.height)) __pixels[i] = color;
		// TODO: Allocate and synchronize Flight bitmap storage.
	}

	public function applyFilter(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter):Void
	{
		// TODO: Apply bitmap filters through Flight.
	}

	public function clone():BitmapData
	{
		var result = new BitmapData(width, height, transparent, 0);
		result.__pixels = __pixels.copy();
		result.image = image;
		return result;
	}

	public function colorTransform(rect:Rectangle, colorTransform:ColorTransform):Void
	{
		// TODO: Apply color transforms through Flight bitmap services.
	}

	public function compare(otherBitmapData:BitmapData):Dynamic
	{
		if (otherBitmapData == null) return -1;
		if (width != otherBitmapData.width) return -3;
		if (height != otherBitmapData.height) return -4;
		for (i in 0...__pixels.length) if (__pixels[i] != otherBitmapData.__pixels[i]) return -1;
		return 0;
	}

	public function copyChannel(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, sourceChannel:BitmapDataChannel,
			destChannel:BitmapDataChannel):Void
	{
		// TODO: Copy bitmap channels through Flight.
	}

	public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null,
			alphaPoint:Point = null, mergeAlpha:Bool = false):Void
	{
		// TODO: Copy bitmap regions through Flight.
	}

	public function dispose():Void
	{
		image = null;
		__pixels = [];
		readable = false;
		// TODO: Release Flight bitmap resources.
	}

	public function draw(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null,
			clipRect:Rectangle = null, smoothing:Bool = false):Void
	{
		// TODO: Render bitmap draw operations through Flight.
	}

	public function drawWithQuality(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null,
			clipRect:Rectangle = null, smoothing:Bool = false, quality:StageQuality = null):Void
	{
		// TODO: Render quality-controlled bitmap draws through Flight.
	}

	public function encode(rect:Rectangle, compressor:Object, byteArray:ByteArray = null):ByteArray
	{
		// TODO: Encode bitmap pixels through Flight codecs.
		return byteArray == null ? new ByteArray() : byteArray;
	}

	public function fillRect(rect:Rectangle, color:Int):Void
	{
		if (rect == null) return;
		var left = Std.int(Math.max(0, rect.x));
		var top = Std.int(Math.max(0, rect.y));
		var right = Std.int(Math.min(width, rect.x + rect.width));
		var bottom = Std.int(Math.min(height, rect.y + rect.height));
		for (y in top...bottom) for (x in left...right) __pixels[y * width + x] = color;
	}

	public function floodFill(x:Int, y:Int, color:Int):Void
	{
		// TODO: Flood-fill pixels through Flight bitmap services.
	}

	public static function fromBase64(base64:String, type:String):BitmapData
	{
		// TODO: Decode base64 bitmap data through Flight codecs.
		return null;
	}

	public static function fromBytes(bytes:ByteArray, rawAlpha:ByteArray = null):BitmapData
	{
		// TODO: Decode bitmap bytes through Flight codecs.
		return null;
	}

	public static function fromCanvas(canvas:CanvasElement, transparent:Bool = true):BitmapData
	{
		// TODO: Import canvas pixels through Flight.
		return null;
	}

	public static function fromFile(path:String):BitmapData
	{
		// TODO: Decode bitmap files through Flight codecs.
		return null;
	}

	public static function fromImage(image:Image, transparent:Bool = true):BitmapData
	{
		// TODO: Import platform images through Flight.
		return null;
	}

	public static function fromTexture(texture:TextureBase):BitmapData
	{
		// TODO: Read Flight GPU texture pixels.
		return null;
	}

	public function generateFilterRect(sourceRect:Rectangle, filter:BitmapFilter):Rectangle
	{
		return sourceRect == null ? null : sourceRect.clone();
	}

	public function getColorBoundsRect(mask:Int, color:Int, findColor:Bool = true):Rectangle
	{
		// TODO: Query color bounds through Flight bitmap services.
		return new Rectangle();
	}

	public function getPixel(x:Int, y:Int):Int
	{
		return getPixel32(x, y) & 0xFFFFFF;
	}

	public function getPixel32(x:Int, y:Int):Int
	{
		if (!readable || x < 0 || y < 0 || x >= width || y >= height) return 0;
		return __pixels[y * width + x];
	}

	public function getPixels(rect:Rectangle):ByteArray
	{
		// TODO: Export bitmap regions through Flight.
		return new ByteArray();
	}

	public function getVector(rect:Rectangle):Vector<UInt>
	{
		var result = new Vector<UInt>();
		if (rect == null) return result;
		var left = Std.int(Math.max(0, rect.x));
		var top = Std.int(Math.max(0, rect.y));
		var right = Std.int(Math.min(width, rect.x + rect.width));
		var bottom = Std.int(Math.min(height, rect.y + rect.height));
		for (y in top...bottom) for (x in left...right) result.push(__pixels[y * width + x]);
		return result;
	}

	public function histogram(hRect:Rectangle = null):Array<Array<Int>>
	{
		var result = [for (_ in 0...4) [for (_ in 0...256) 0]];
		// TODO: Compute bitmap histograms through Flight.
		return result;
	}

	public function hitTest(firstPoint:Point, firstAlphaThreshold:Int, secondObject:Object, secondBitmapDataPoint:Point = null,
			secondAlphaThreshold:Int = 1):Bool
	{
		// TODO: Perform bitmap hit testing through Flight.
		return false;
	}

	public static function loadFromBase64(base64:String, type:String):Future<BitmapData>
	{
		return cast Future.withError("Flight bitmap decoding is not implemented");
	}

	public static function loadFromBytes(bytes:ByteArray, rawAlpha:ByteArray = null):Future<BitmapData>
	{
		return cast Future.withError("Flight bitmap decoding is not implemented");
	}

	public static function loadFromFile(path:String):Future<BitmapData>
	{
		return cast Future.withError("Flight bitmap decoding is not implemented");
	}

	public function lock():Void {}

	public function merge(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redMultiplier:UInt, greenMultiplier:UInt,
			blueMultiplier:UInt, alphaMultiplier:UInt):Void
	{
		// TODO: Merge bitmap regions through Flight.
	}

	public function noise(randomSeed:Int, low:Int = 0, high:Int = 255, channelOptions:Int = 7, grayScale:Bool = false):Void
	{
		// TODO: Generate bitmap noise through Flight.
	}

	public function paletteMap(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redArray:Array<Int> = null,
			greenArray:Array<Int> = null, blueArray:Array<Int> = null, alphaArray:Array<Int> = null):Void
	{
		// TODO: Apply bitmap palettes through Flight.
	}

	public function perlinNoise(baseX:Float, baseY:Float, numOctaves:UInt, randomSeed:Int, stitch:Bool, fractalNoise:Bool,
			channelOptions:UInt = 7, grayScale:Bool = false, offsets:Array<Point> = null):Void
	{
		// TODO: Generate Perlin noise through Flight.
	}

	public function scroll(x:Int, y:Int):Void
	{
		// TODO: Scroll bitmap pixels through Flight.
	}

	public function setPixel(x:Int, y:Int, color:Int):Void
	{
		if (!readable || x < 0 || y < 0 || x >= width || y >= height) return;
		var alpha = __pixels[y * width + x] & 0xFF000000;
		__pixels[y * width + x] = alpha | (color & 0xFFFFFF);
	}

	public function setPixel32(x:Int, y:Int, color:Int):Void
	{
		if (!readable || x < 0 || y < 0 || x >= width || y >= height) return;
		__pixels[y * width + x] = transparent ? color : (0xFF000000 | (color & 0xFFFFFF));
	}

	public function setPixels(rect:Rectangle, byteArray:ByteArray):Void
	{
		// TODO: Import bitmap bytes through Flight.
	}

	public function setVector(rect:Rectangle, inputVector:Vector<UInt>):Void
	{
		if (rect == null || inputVector == null) return;
		var index = 0;
		var left = Std.int(Math.max(0, rect.x));
		var top = Std.int(Math.max(0, rect.y));
		var right = Std.int(Math.min(width, rect.x + rect.width));
		var bottom = Std.int(Math.min(height, rect.y + rect.height));
		for (y in top...bottom) for (x in left...right)
		{
			if (index >= inputVector.length) return;
			setPixel32(x, y, inputVector[index++]);
		}
	}

	public function threshold(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, operation:String, threshold:Int,
			color:Int = 0x00000000, mask:Int = 0xFFFFFFFF, copySource:Bool = false):Int
	{
		// TODO: Apply bitmap thresholds through Flight.
		return 0;
	}

	public function unlock(changeRect:Rectangle = null):Void {}
}
#else
typedef BitmapData = flash.display.BitmapData;
#end
