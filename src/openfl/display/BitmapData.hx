package openfl.display;

#if !flash
import flight.Bitmap as FlightBitmap;
import flight._internal._UInt8ClampedArray as FlightUInt8ClampedArray;
import flight.types.Bitmap as FlightBitmapHandle;
import openfl.Vector;
import openfl.display3D.Context3D;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.display3D.textures.TextureBase;
import openfl.errors.Error;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.utils.Future;
import openfl.utils.Object;
#if lime
import lime.graphics.Image;
import lime.graphics.cairo.CairoImageSurface;
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

	@:noCompletion private var __blendMode:BlendMode;
	@:noCompletion private var __bitmap:FlightBitmapHandle;
	@:noCompletion private var __drawableType:Dynamic;
	@:noCompletion private var __flightBitmap(get, never):FlightBitmapHandle;
	@:noCompletion private var __isMask:Bool;
	@:noCompletion private var __isValid:Bool;
	@:noCompletion private var __mask:DisplayObject;
	@:noCompletion private var __renderable:Bool;
	@:noCompletion private var __renderTransform:Matrix;
	@:noCompletion private var __scrollRect:Rectangle;
	@:noCompletion private var __transform:Matrix;
	@:noCompletion private var __worldAlpha:Float;
	@:noCompletion private var __worldColorTransform:ColorTransform;
	@:noCompletion private var __worldTransform:Matrix;

	public function new(width:Int, height:Int, transparent:Bool = true, fillColor:UInt = 0xFFFFFFFF)
	{
		this.width = width < 0 ? 0 : width;
		this.height = height < 0 ? 0 : height;
		this.transparent = transparent;
		readable = true;
		__isValid = true;
		__renderable = true;
		rect = new Rectangle(0, 0, this.width, this.height);
		var color:Int = cast fillColor;
		if (!transparent) color = 0xFF000000 | (color & 0xFFFFFF);
		__bitmap = FlightBitmap.createBitmap(this.width, this.height, __argbToFlight(color, true));
	}

	public function applyFilter(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter):Void
	{
		if (!readable || __bitmap == null || sourceBitmapData == null || !sourceBitmapData.readable || sourceBitmapData.__bitmap == null
			|| sourceRect == null || destPoint == null || filter == null) return;
		var regionWidth = Std.int(Math.max(0, sourceRect.width));
		var regionHeight = Std.int(Math.max(0, sourceRect.height));
		if (regionWidth == 0 || regionHeight == 0) return;
		var sourceBitmap = __toStraightBitmap(sourceBitmapData);
		var source = FlightBitmap.createBitmapRegion(sourceBitmap, sourceRect.x, sourceRect.y, regionWidth, regionHeight);
		var output = new FlightUInt8ClampedArray(regionWidth * regionHeight * 4);

		if (Std.isOfType(filter, ColorMatrixFilter))
		{
			var matrix = (cast filter : ColorMatrixFilter).matrix;
			FlightBitmap.colorMatrixBitmap(output, source, matrix);
			// Flight rounds matrix results while OpenFL truncates them. Retain the
			// Flight pass, then normalize that adapter-level numeric difference.
			for (offsetY in 0...regionHeight) for (offsetX in 0...regionWidth)
			{
				var sourceX = Std.int(sourceRect.x) + offsetX;
				var sourceY = Std.int(sourceRect.y) + offsetY;
				if (sourceX < 0 || sourceY < 0 || sourceX >= sourceBitmapData.width || sourceY >= sourceBitmapData.height) continue;
				var sourceColor = Std.int(FlightBitmap.getBitmapPixel(sourceBitmap, sourceX, sourceY));
				var red = (sourceColor >>> 24) & 0xFF;
				var green = (sourceColor >>> 16) & 0xFF;
				var blue = (sourceColor >>> 8) & 0xFF;
				var alpha = sourceColor & 0xFF;
				var outputOffset = (offsetY * regionWidth + offsetX) * 4;
				if (alpha == 0)
				{
					for (channel in 0...4) output[outputOffset + channel] = 0;
				}
				else
				{
					output[outputOffset] = __colorMatrixComponent(matrix, 0, red, green, blue, alpha);
					output[outputOffset + 1] = __colorMatrixComponent(matrix, 5, red, green, blue, alpha);
					output[outputOffset + 2] = __colorMatrixComponent(matrix, 10, red, green, blue, alpha);
					output[outputOffset + 3] = __colorMatrixComponent(matrix, 15, red, green, blue, alpha);
				}
			}
		}
		else
		{
			// Other OpenFL filter families require separate parameter/edge-mode
			// adapters before their Flight bitmap primitives can be used safely.
			return;
		}

		var destinationBitmap = __toStraightBitmap(this);
		FlightBitmap.writeBitmapPixels(FlightBitmap.createBitmapRegion(destinationBitmap, destPoint.x, destPoint.y, regionWidth, regionHeight), output);
		__writeStraightRegion(destinationBitmap, Std.int(destPoint.x), Std.int(destPoint.y), regionWidth, regionHeight);
	}

	public function clone():BitmapData
	{
		if (!readable || __bitmap == null) return null;
		var result = __fromFlightBitmap(FlightBitmap.cloneBitmap(__bitmap), transparent);
		result.image = image;
		return result;
	}

	public function colorTransform(rect:Rectangle, colorTransform:ColorTransform):Void
	{
		if (!readable || __bitmap == null || rect == null || colorTransform == null) return;
		var clipped = __clipRectangle(rect);
		if (clipped == null) return;

		var regionWidth = Std.int(clipped.width);
		var regionHeight = Std.int(clipped.height);
		var source = FlightBitmap.createBitmap(regionWidth, regionHeight, 0);
		var destination = FlightBitmap.createBitmap(regionWidth, regionHeight, 0);
		for (y in 0...regionHeight)
		{
			for (x in 0...regionWidth)
			{
				FlightBitmap.setBitmapPixel(source, x, y, __argbToFlight(getPixel32(Std.int(clipped.x) + x, Std.int(clipped.y) + y), false));
			}
		}

		FlightBitmap.applyBitmapColorScaleBias(FlightBitmap.createBitmapRegion(destination), FlightBitmap.createBitmapRegion(source), {
			redScale: colorTransform.redMultiplier,
			greenScale: colorTransform.greenMultiplier,
			blueScale: colorTransform.blueMultiplier,
			alphaScale: colorTransform.alphaMultiplier,
			redBias: colorTransform.redOffset / 255,
			greenBias: colorTransform.greenOffset / 255,
			blueBias: colorTransform.blueOffset / 255,
			alphaBias: colorTransform.alphaOffset / 255
		});

		for (y in 0...regionHeight)
		{
			for (x in 0...regionWidth)
			{
				setPixel32(Std.int(clipped.x) + x, Std.int(clipped.y) + y,
					__flightToArgb(Std.int(FlightBitmap.getBitmapPixel(destination, x, y)), false));
			}
		}
	}

	public function compare(otherBitmapData:BitmapData):Dynamic
	{
		if (otherBitmapData == this) return 0;
		if (otherBitmapData == null) return -1;
		if (!readable || !otherBitmapData.readable || __bitmap == null || otherBitmapData.__bitmap == null) return -2;
		if (width != otherBitmapData.width) return -3;
		if (height != otherBitmapData.height) return -4;

		var source = __toStraightBitmap(this);
		var other = __toStraightBitmap(otherBitmapData);
		if (FlightBitmap.compareBitmap(source, other) == null) return 0;

		var result = new BitmapData(width, height, transparent || otherBitmapData.transparent, 0);
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				var sourcePixel = getPixel32(x, y);
				var otherPixel = otherBitmapData.getPixel32(x, y);
				if (sourcePixel == otherPixel) continue;

				var red = Std.int(Math.abs(((sourcePixel >>> 16) & 0xFF) - ((otherPixel >>> 16) & 0xFF)));
				var green = Std.int(Math.abs(((sourcePixel >>> 8) & 0xFF) - ((otherPixel >>> 8) & 0xFF)));
				var blue = Std.int(Math.abs((sourcePixel & 0xFF) - (otherPixel & 0xFF)));
				if (red == 0 && green == 0 && blue == 0)
				{
					var alpha = Std.int(Math.abs(((sourcePixel >>> 24) & 0xFF) - ((otherPixel >>> 24) & 0xFF)));
					result.setPixel32(x, y, (alpha << 24) | 0xFFFFFF);
				}
				else
				{
					result.setPixel32(x, y, 0xFF000000 | (red << 16) | (green << 8) | blue);
				}
			}
		}
		return result;
	}

	public function copyChannel(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, sourceChannel:BitmapDataChannel,
			destChannel:BitmapDataChannel):Void
	{
		if (!readable || __bitmap == null || sourceBitmapData == null || !sourceBitmapData.readable || sourceBitmapData.__bitmap == null
			|| sourceRect == null || destPoint == null) return;
		var regionWidth = Std.int(Math.max(0, sourceRect.width));
		var regionHeight = Std.int(Math.max(0, sourceRect.height));
		if (regionWidth == 0 || regionHeight == 0) return;
		var source = FlightBitmap.createBitmapRegion(__toStraightBitmap(sourceBitmapData), Std.int(sourceRect.x), Std.int(sourceRect.y), regionWidth,
			regionHeight);
		var destinationBitmap = __toStraightBitmap(this);
		var destination = FlightBitmap.createBitmapRegion(destinationBitmap, Std.int(destPoint.x), Std.int(destPoint.y), regionWidth, regionHeight);
		FlightBitmap.copyBitmapChannel(destination, __flightChannel(destChannel), source, __flightChannel(sourceChannel));
		__writeStraightRegion(destinationBitmap, Std.int(destPoint.x), Std.int(destPoint.y), regionWidth, regionHeight);
	}

	public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null,
			alphaPoint:Point = null, mergeAlpha:Bool = false):Void
	{
		if (!readable || __bitmap == null || sourceBitmapData == null || !sourceBitmapData.readable || sourceBitmapData.__bitmap == null
			|| sourceRect == null || destPoint == null) return;
		var regionWidth = Std.int(Math.max(0, sourceRect.width));
		var regionHeight = Std.int(Math.max(0, sourceRect.height));
		if (regionWidth == 0 || regionHeight == 0) return;
		var sourceX = Std.int(sourceRect.x);
		var sourceY = Std.int(sourceRect.y);
		var destinationX = Std.int(destPoint.x);
		var destinationY = Std.int(destPoint.y);
		if (!mergeAlpha && alphaBitmapData == null)
		{
			var source = FlightBitmap.createBitmapRegion(sourceBitmapData.__bitmap, sourceX, sourceY, regionWidth, regionHeight);
			var destination = FlightBitmap.createBitmapRegion(__bitmap, destinationX, destinationY, regionWidth, regionHeight);
			FlightBitmap.copyBitmapPixels(destination, source, false);
			return;
		}

		var sourceBitmap = __toStraightBitmap(sourceBitmapData);
		if (alphaBitmapData != null && alphaBitmapData.readable && alphaBitmapData.__bitmap != null)
		{
			var alphaX = alphaPoint == null ? 0 : Std.int(alphaPoint.x);
			var alphaY = alphaPoint == null ? 0 : Std.int(alphaPoint.y);
			for (y in 0...regionHeight)
			{
				for (x in 0...regionWidth)
				{
					var bitmapX = sourceX + x;
					var bitmapY = sourceY + y;
					if (bitmapX < 0 || bitmapY < 0 || bitmapX >= sourceBitmapData.width || bitmapY >= sourceBitmapData.height) continue;
					var sourcePixel = sourceBitmapData.getPixel32(bitmapX, bitmapY);
					var maskAlpha = (alphaBitmapData.getPixel32(alphaX + x, alphaY + y) >>> 24) & 0xFF;
					var sourceAlpha = (sourcePixel >>> 24) & 0xFF;
					var combinedAlpha = Std.int(Math.round(sourceAlpha * maskAlpha / 255));
					FlightBitmap.setBitmapPixel(sourceBitmap, bitmapX, bitmapY, __argbToFlight((combinedAlpha << 24) | (sourcePixel & 0xFFFFFF), false));
				}
			}
		}

		var destinationBitmap = __toStraightBitmap(this);
		var source = FlightBitmap.createBitmapRegion(sourceBitmap, sourceX, sourceY, regionWidth, regionHeight);
		var destination = FlightBitmap.createBitmapRegion(destinationBitmap, destinationX, destinationY, regionWidth, regionHeight);
		FlightBitmap.copyBitmapPixels(destination, source, mergeAlpha);
		__writeStraightRegion(destinationBitmap, destinationX, destinationY, regionWidth, regionHeight);
	}

	public function dispose():Void
	{
		image = null;
		__bitmap = cast null;
		width = 0;
		height = 0;
		rect = null;
		__isValid = false;
		readable = false;
	}

	@:beta public function disposeImage():Void
	{
		image = null;
		readable = false;
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
		if (!readable || __bitmap == null || rect == null) return;
		var clipped = __clipRectangle(rect);
		if (clipped == null) return;
		if (!transparent) color = 0xFF000000 | (color & 0xFFFFFF);
		FlightBitmap.fillBitmapRectangle(FlightBitmap.createBitmapRegion(__bitmap, clipped.x, clipped.y, clipped.width, clipped.height),
			__argbToFlight(color, true));
	}

	public function floodFill(x:Int, y:Int, color:Int):Void
	{
		if (!readable || __bitmap == null || x < 0 || y < 0 || x >= width || y >= height) return;
		if (!transparent) color = 0xFF000000 | (color & 0xFFFFFF);
		FlightBitmap.floodFillBitmap(__bitmap, x, y, __argbToFlight(color, true));
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
		if (!readable || __bitmap == null) return new Rectangle(0, 0, width, height);
		var bitmap = __toStraightBitmap(this);
		var bounds = FlightBitmap.getBitmapColorBoundsRectangle(FlightBitmap.createBitmapRegion(bitmap), __argbToFlight(mask, false),
			__argbToFlight(color, false), findColor);
		return bounds == null ? new Rectangle() : new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
	}

	@:dox(hide) public function getIndexBuffer(context:Context3D, scale9Grid:Rectangle = null):IndexBuffer3D
	{
		// TODO (Flight): expose a Flight-backed index buffer.
		return null;
	}

	@SuppressWarnings("checkstyle:Dynamic")
	@:dox(hide) public function getSurface():#if lime CairoImageSurface #else Dynamic #end
	{
		// TODO (Flight): expose a Flight-backed Cairo surface.
		return null;
	}

	@:dox(hide) public function getTexture(context:Context3D):TextureBase
	{
		// TODO (Flight): expose a Flight-backed texture.
		return null;
	}

	@:dox(hide) public function getVertexBuffer(context:Context3D, scale9Grid:Rectangle = null, targetObject:DisplayObject = null):VertexBuffer3D
	{
		// TODO (Flight): expose a Flight-backed vertex buffer.
		return null;
	}

	public function getPixel(x:Int, y:Int):Int
	{
		if (!readable || __bitmap == null || x < 0 || y < 0 || x >= width || y >= height) return 0;
		var rgb = Std.int(FlightBitmap.getBitmapPixelRgb(__bitmap, x, y));
		var alpha = Std.int(FlightBitmap.getBitmapPixel(__bitmap, x, y)) & 0xFF;
		return __unpremultiplyRgb(rgb, alpha);
	}

	public function getPixel32(x:Int, y:Int):Int
	{
		if (!readable || __bitmap == null || x < 0 || y < 0 || x >= width || y >= height) return 0;
		return __flightToArgb(Std.int(FlightBitmap.getBitmapPixel(__bitmap, x, y)), true);
	}

	public function getPixels(rect:Rectangle):ByteArray
	{
		if (!readable || __bitmap == null) return null;
		if (rect == null) rect = this.rect;
		var regionWidth = Std.int(Math.max(0, rect.width));
		var regionHeight = Std.int(Math.max(0, rect.height));
		var pixels = new FlightUInt8ClampedArray(regionWidth * regionHeight * 4);
		FlightBitmap.extractBitmapPixels(pixels,
			FlightBitmap.createBitmapRegion(__toStraightBitmap(this), rect.x, rect.y, regionWidth, regionHeight));
		var result = new ByteArray();
		result.endian = Endian.BIG_ENDIAN;
		for (index in 0...(regionWidth * regionHeight))
		{
			var offset = index * 4;
			result.writeByte(pixels[offset + 3]);
			result.writeByte(pixels[offset]);
			result.writeByte(pixels[offset + 1]);
			result.writeByte(pixels[offset + 2]);
		}
		result.position = 0;
		return result;
	}

	public function getVector(rect:Rectangle):Vector<UInt>
	{
		var result = new Vector<UInt>();
		if (rect == null) return result;
		var left = Std.int(Math.max(0, rect.x));
		var top = Std.int(Math.max(0, rect.y));
		var right = Std.int(Math.min(width, rect.x + rect.width));
		var bottom = Std.int(Math.min(height, rect.y + rect.height));
		for (y in top...bottom) for (x in left...right) result.push(getPixel32(x, y));
		return result;
	}

	public function histogram(hRect:Rectangle = null):Array<Array<Int>>
	{
		if (!readable || __bitmap == null) return [for (_ in 0...4) [for (_ in 0...256) 0]];
		var source = hRect == null ? rect : hRect;
		var histogram = FlightBitmap.getBitmapHistogram(FlightBitmap.createBitmapRegion(__toStraightBitmap(this), source.x, source.y,
			source.width, source.height));
		return [
			[for (value in histogram.red) Std.int(value)],
			[for (value in histogram.green) Std.int(value)],
			[for (value in histogram.blue) Std.int(value)],
			[for (value in histogram.alpha) Std.int(value)]
		];
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
		if (!readable || __bitmap == null || sourceBitmapData == null || !sourceBitmapData.readable || sourceBitmapData.__bitmap == null
			|| sourceRect == null || destPoint == null) return;
		var regionWidth = Std.int(Math.max(0, sourceRect.width));
		var regionHeight = Std.int(Math.max(0, sourceRect.height));
		if (regionWidth == 0 || regionHeight == 0) return;
		var sourceBitmap = __toStraightBitmap(sourceBitmapData);
		var destinationBitmap = __toStraightBitmap(this);
		var originalDestination = FlightBitmap.cloneBitmap(destinationBitmap);
		var source = FlightBitmap.createBitmapRegion(sourceBitmap, sourceRect.x, sourceRect.y, regionWidth, regionHeight);
		var destination = FlightBitmap.createBitmapRegion(destinationBitmap, destPoint.x, destPoint.y, regionWidth, regionHeight);
		FlightBitmap.mergeBitmap(destination, source, redMultiplier / 256, greenMultiplier / 256, blueMultiplier / 256, alphaMultiplier / 256);

		// Flight rounds blended channels; OpenFL truncates the 8.8 fixed-point
		// result. Correct that adapter-level difference before storing the pixels.
		for (offsetY in 0...regionHeight) for (offsetX in 0...regionWidth)
		{
			var sourceX = Std.int(sourceRect.x) + offsetX;
			var sourceY = Std.int(sourceRect.y) + offsetY;
			var destinationX = Std.int(destPoint.x) + offsetX;
			var destinationY = Std.int(destPoint.y) + offsetY;
			if (sourceX < 0 || sourceY < 0 || sourceX >= sourceBitmapData.width || sourceY >= sourceBitmapData.height
				|| destinationX < 0 || destinationY < 0 || destinationX >= width || destinationY >= height) continue;
			var sourceColor = Std.int(FlightBitmap.getBitmapPixel(sourceBitmap, sourceX, sourceY));
			var destinationColor = Std.int(FlightBitmap.getBitmapPixel(originalDestination, destinationX, destinationY));
			var mergedColor = (__mergeComponent((sourceColor >>> 24) & 0xFF, (destinationColor >>> 24) & 0xFF, redMultiplier) << 24)
				| (__mergeComponent((sourceColor >>> 16) & 0xFF, (destinationColor >>> 16) & 0xFF, greenMultiplier) << 16)
				| (__mergeComponent((sourceColor >>> 8) & 0xFF, (destinationColor >>> 8) & 0xFF, blueMultiplier) << 8)
				| __mergeComponent(sourceColor & 0xFF, destinationColor & 0xFF, alphaMultiplier);
			FlightBitmap.setBitmapPixel(destinationBitmap, destinationX, destinationY, mergedColor);
		}
		__writeStraightRegion(destinationBitmap, Std.int(destPoint.x), Std.int(destPoint.y), regionWidth, regionHeight);
	}

	public function noise(randomSeed:Int, low:Int = 0, high:Int = 255, channelOptions:Int = 7, grayScale:Bool = false):Void
	{
		if (!readable || __bitmap == null || width == 0 || height == 0) return;
		var output = FlightBitmap.createBitmap(width, height, 0);
		FlightBitmap.fillBitmapNoise(FlightBitmap.createBitmapRegion(output), randomSeed, low, high, grayScale);
		if (!grayScale)
		{
			var alphaNoise = FlightBitmap.createBitmap(width, height, 0);
			if ((channelOptions & 8) != 0)
				FlightBitmap.fillBitmapNoise(FlightBitmap.createBitmapRegion(alphaNoise), randomSeed ^ 0x6D2B79F5, low, high, true);
			for (y in 0...height) for (x in 0...width)
			{
				var color = Std.int(FlightBitmap.getBitmapPixel(output, x, y));
				var red = (channelOptions & 1) == 0 ? 0 : (color >>> 24) & 0xFF;
				var green = (channelOptions & 2) == 0 ? 0 : (color >>> 16) & 0xFF;
				var blue = (channelOptions & 4) == 0 ? 0 : (color >>> 8) & 0xFF;
				var alpha = (channelOptions & 8) == 0 ? 0xFF : (Std.int(FlightBitmap.getBitmapPixel(alphaNoise, x, y)) >>> 24) & 0xFF;
				FlightBitmap.setBitmapPixel(output, x, y, (red << 24) | (green << 16) | (blue << 8) | alpha);
			}
		}
		__writeStraightRegion(output, 0, 0, width, height);
	}

	public function paletteMap(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redArray:Array<Int> = null,
			greenArray:Array<Int> = null, blueArray:Array<Int> = null, alphaArray:Array<Int> = null):Void
	{
		if (!readable || __bitmap == null || sourceBitmapData == null || !sourceBitmapData.readable || sourceBitmapData.__bitmap == null
			|| sourceRect == null || destPoint == null) return;
		var regionWidth = Std.int(Math.max(0, sourceRect.width));
		var regionHeight = Std.int(Math.max(0, sourceRect.height));
		if (regionWidth == 0 || regionHeight == 0) return;
		var sourceBitmap = __toStraightBitmap(sourceBitmapData);
		var destinationBitmap = __toStraightBitmap(this);
		var redMap:Array<Float> = redArray == null ? null : [for (value in redArray) (value >>> 16) & 0xFF];
		var greenMap:Array<Float> = greenArray == null ? null : [for (value in greenArray) (value >>> 8) & 0xFF];
		var blueMap:Array<Float> = blueArray == null ? null : [for (value in blueArray) value & 0xFF];
		var alphaMap:Array<Float> = alphaArray == null ? null : [for (value in alphaArray) (value >>> 24) & 0xFF];
		var source = FlightBitmap.createBitmapRegion(sourceBitmap, sourceRect.x, sourceRect.y, regionWidth, regionHeight);
		var destination = FlightBitmap.createBitmapRegion(destinationBitmap, destPoint.x, destPoint.y, regionWidth, regionHeight);
		FlightBitmap.applyBitmapPaletteMap(destination, source, redMap, greenMap, blueMap, alphaMap);
		__writeStraightRegion(destinationBitmap, Std.int(destPoint.x), Std.int(destPoint.y), regionWidth, regionHeight);
		// Flight maps channels independently. OpenFL's additional cross-channel
		// effects from summing full 32-bit table entries cannot be represented.
	}

	public function perlinNoise(baseX:Float, baseY:Float, numOctaves:UInt, randomSeed:Int, stitch:Bool, fractalNoise:Bool,
			channelOptions:UInt = 7, grayScale:Bool = false, offsets:Array<Point> = null):Void
	{
		if (!readable || __bitmap == null || width == 0 || height == 0) return;
		var output = FlightBitmap.createBitmap(width, height, 0);
		var flightChannels:UInt = grayScale ? 7 : channelOptions & 7;
		FlightBitmap.fillBitmapPerlinNoise(FlightBitmap.createBitmapRegion(output), baseX, baseY, numOctaves, randomSeed, grayScale, stitch,
			flightChannels);
		__writeStraightRegion(output, 0, 0, width, height);
		// OpenFL 9.5.2 ignores `fractalNoise`, alpha channel selection, and
		// octave offsets in its Perlin implementation; the adapter does likewise.
	}

	public function scroll(x:Int, y:Int):Void
	{
		if (!readable || __bitmap == null || (x == 0 && y == 0)) return;
		var sourceBitmap = FlightBitmap.cloneBitmap(__bitmap);
		var source = FlightBitmap.createBitmapRegion(sourceBitmap, 0, 0, width, height);
		var destination = FlightBitmap.createBitmapRegion(__bitmap, x, y, width, height);
		FlightBitmap.copyBitmapPixels(destination, source, false);
	}

	public function setPixel(x:Int, y:Int, color:Int):Void
	{
		if (!readable || __bitmap == null || x < 0 || y < 0 || x >= width || y >= height) return;
		var alpha = Std.int(FlightBitmap.getBitmapPixel(__bitmap, x, y)) & 0xFF;
		FlightBitmap.setBitmapPixelRgb(__bitmap, x, y, __premultiplyRgb(color, alpha));
	}

	public function setPixel32(x:Int, y:Int, color:Int):Void
	{
		if (!readable || __bitmap == null || x < 0 || y < 0 || x >= width || y >= height) return;
		if (!transparent) color = 0xFF000000 | (color & 0xFFFFFF);
		FlightBitmap.setBitmapPixel(__bitmap, x, y, __argbToFlight(color, true));
	}

	public function setPixels(rect:Rectangle, byteArray:ByteArray):Void
	{
		if (!readable || __bitmap == null || rect == null) return;
		var regionWidth = Std.int(Math.max(0, rect.width));
		var regionHeight = Std.int(Math.max(0, rect.height));
		var length = regionWidth * regionHeight * 4;
		if (byteArray.bytesAvailable < length) throw new Error("End of file was encountered.", 2030);
		if (length == 0) return;

		var pixels = new FlightUInt8ClampedArray(length);
		var position = byteArray.position;
		for (index in 0...(regionWidth * regionHeight))
		{
			var color = byteArray.readUnsignedInt();
			var offset = index * 4;
			pixels[offset] = (color >>> 16) & 0xFF;
			pixels[offset + 1] = (color >>> 8) & 0xFF;
			pixels[offset + 2] = color & 0xFF;
			pixels[offset + 3] = (color >>> 24) & 0xFF;
		}
		byteArray.position = position;
		var destinationBitmap = __toStraightBitmap(this);
		FlightBitmap.writeBitmapPixels(FlightBitmap.createBitmapRegion(destinationBitmap, rect.x, rect.y, regionWidth, regionHeight), pixels);
		__writeStraightRegion(destinationBitmap, Std.int(rect.x), Std.int(rect.y), regionWidth, regionHeight);
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
		if (!readable || __bitmap == null || sourceBitmapData == null || !sourceBitmapData.readable || sourceBitmapData.__bitmap == null
			|| sourceRect == null || destPoint == null) return 0;
		if (operation != "<" && operation != "<=" && operation != ">" && operation != ">=" && operation != "==" && operation != "!=") return 0;
		var regionWidth = Std.int(Math.max(0, sourceRect.width));
		var regionHeight = Std.int(Math.max(0, sourceRect.height));
		if (regionWidth == 0 || regionHeight == 0) return 0;

		// Threshold compares packed ARGB values. Encode those values directly as
		// Flight pixels so the packed numeric ordering remains ARGB, not RGBA.
		var sourceBitmap = FlightBitmap.createBitmap(sourceBitmapData.width, sourceBitmapData.height, 0);
		for (y in 0...sourceBitmapData.height) for (x in 0...sourceBitmapData.width)
			FlightBitmap.setBitmapPixel(sourceBitmap, x, y, sourceBitmapData.getPixel32(x, y));
		var destinationBitmap = FlightBitmap.createBitmap(width, height, 0);
		for (y in 0...height) for (x in 0...width) FlightBitmap.setBitmapPixel(destinationBitmap, x, y, getPixel32(x, y));

		var source = FlightBitmap.createBitmapRegion(sourceBitmap, sourceRect.x, sourceRect.y, regionWidth, regionHeight);
		var destination = FlightBitmap.createBitmapRegion(destinationBitmap, destPoint.x, destPoint.y, regionWidth, regionHeight);
		var changed = FlightBitmap.applyBitmapThreshold(destination, source, operation, threshold, color, mask, copySource);
		for (offsetY in 0...regionHeight) for (offsetX in 0...regionWidth)
		{
			var bitmapX = Std.int(destPoint.x) + offsetX;
			var bitmapY = Std.int(destPoint.y) + offsetY;
			if (bitmapX < 0 || bitmapY < 0 || bitmapX >= width || bitmapY >= height) continue;
			setPixel32(bitmapX, bitmapY, Std.int(FlightBitmap.getBitmapPixel(destinationBitmap, bitmapX, bitmapY)));
		}
		return Std.int(changed);
	}

	public function unlock(changeRect:Rectangle = null):Void {}

	@:noCompletion private static function __argbToFlight(color:Int, premultiply:Bool):Int
	{
		var alpha = (color >>> 24) & 0xFF;
		var red = (color >>> 16) & 0xFF;
		var green = (color >>> 8) & 0xFF;
		var blue = color & 0xFF;
		if (premultiply && alpha != 0xFF)
		{
			red = __premultiplyComponent(red, alpha);
			green = __premultiplyComponent(green, alpha);
			blue = __premultiplyComponent(blue, alpha);
		}
		return (red << 24) | (green << 16) | (blue << 8) | alpha;
	}

	@:noCompletion private function __clipRectangle(value:Rectangle):Rectangle
	{
		var left = Std.int(Math.max(0, value.x));
		var top = Std.int(Math.max(0, value.y));
		var right = Std.int(Math.min(width, value.x + value.width));
		var bottom = Std.int(Math.min(height, value.y + value.height));
		return right <= left || bottom <= top ? null : new Rectangle(left, top, right - left, bottom - top);
	}

	@:noCompletion private static function __flightChannel(channel:BitmapDataChannel):Float
	{
		return switch (channel)
		{
			case BitmapDataChannel.RED: FlightBitmap.ImageChannel.Red;
			case BitmapDataChannel.GREEN: FlightBitmap.ImageChannel.Green;
			case BitmapDataChannel.BLUE: FlightBitmap.ImageChannel.Blue;
			case BitmapDataChannel.ALPHA: FlightBitmap.ImageChannel.Alpha;
			default: FlightBitmap.ImageChannel.Red;
		};
	}

	@:noCompletion private static function __flightToArgb(color:Int, unpremultiply:Bool):Int
	{
		var red = (color >>> 24) & 0xFF;
		var green = (color >>> 16) & 0xFF;
		var blue = (color >>> 8) & 0xFF;
		var alpha = color & 0xFF;
		if (unpremultiply && alpha != 0 && alpha != 0xFF)
		{
			red = __unpremultiplyComponent(red, alpha);
			green = __unpremultiplyComponent(green, alpha);
			blue = __unpremultiplyComponent(blue, alpha);
		}
		return (alpha << 24) | (red << 16) | (green << 8) | blue;
	}

	@:noCompletion private inline function get___flightBitmap():FlightBitmapHandle
	{
		return __bitmap;
	}

	@:noCompletion private static function __toStraightBitmap(value:BitmapData):FlightBitmapHandle
	{
		var result = FlightBitmap.createBitmap(value.width, value.height, 0);
		for (y in 0...value.height)
		{
			for (x in 0...value.width)
			{
				FlightBitmap.setBitmapPixel(result, x, y, __argbToFlight(value.getPixel32(x, y), false));
			}
		}
		return result;
	}

	@:noCompletion private function __writeStraightRegion(bitmap:FlightBitmapHandle, x:Int, y:Int, width:Int, height:Int):Void
	{
		for (offsetY in 0...height)
		{
			for (offsetX in 0...width)
			{
				var bitmapX = x + offsetX;
				var bitmapY = y + offsetY;
				if (bitmapX < 0 || bitmapY < 0 || bitmapX >= this.width || bitmapY >= this.height) continue;
				setPixel32(bitmapX, bitmapY, __flightToArgb(Std.int(FlightBitmap.getBitmapPixel(bitmap, bitmapX, bitmapY)), false));
			}
		}
	}

	@:noCompletion private static function __fromFlightBitmap(bitmap:FlightBitmapHandle, transparent:Bool):BitmapData
	{
		var result = new BitmapData(Std.int(bitmap.width), Std.int(bitmap.height), transparent, 0);
		result.__bitmap = bitmap;
		return result;
	}

	@:noCompletion private static function __premultiplyComponent(component:Int, alpha:Int):Int
	{
		if (alpha == 0) return 0;
		if (alpha == 0xFF) return component;
		var alpha16 = Std.int(Math.ceil(alpha * (65536 / 255)));
		return (component * alpha16) >> 16;
	}

	@:noCompletion private static inline function __mergeComponent(source:Int, destination:Int, multiplier:UInt):Int
	{
		return Std.int(((source * multiplier) + (destination * (256 - multiplier))) / 256);
	}

	@:noCompletion private static inline function __colorMatrixComponent(matrix:Array<Float>, offset:Int, red:Int, green:Int, blue:Int, alpha:Int):Int
	{
		return Std.int(Math.max(0, Math.min(255,
			matrix[offset] * red + matrix[offset + 1] * green + matrix[offset + 2] * blue + matrix[offset + 3] * alpha + matrix[offset + 4])));
	}

	@:noCompletion private static function __premultiplyRgb(color:Int, alpha:Int):Int
	{
		return (__premultiplyComponent((color >>> 16) & 0xFF, alpha) << 16)
			| (__premultiplyComponent((color >>> 8) & 0xFF, alpha) << 8)
			| __premultiplyComponent(color & 0xFF, alpha);
	}

	@:noCompletion private static function __unpremultiplyComponent(component:Int, alpha:Int):Int
	{
		return Std.int(Math.min(255, Math.round(component * 255 / alpha)));
	}

	@:noCompletion private static function __unpremultiplyRgb(color:Int, alpha:Int):Int
	{
		if (alpha == 0) return 0;
		if (alpha == 0xFF) return color & 0xFFFFFF;
		return (__unpremultiplyComponent((color >>> 16) & 0xFF, alpha) << 16)
			| (__unpremultiplyComponent((color >>> 8) & 0xFF, alpha) << 8)
			| __unpremultiplyComponent(color & 0xFF, alpha);
	}

	@:noCompletion private function __getBounds(rect:Rectangle, matrix:Matrix):Void {}
	@:noCompletion private function __update(transformOnly:Bool, updateChildren:Bool):Void {}
	@:noCompletion private function __updateTransforms(overrideTransform:Matrix = null):Void {}

	@:noCompletion private static function __toFlightColor(color:UInt):UInt
	{
		return ((color & 0xFFFFFF) << 8) | (color >>> 24);
	}
}
#else
typedef BitmapData = flash.display.BitmapData;
#end
