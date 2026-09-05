package openfl.display;

#if !flash
import flight.Bitmap as FlightBitmap;
import flight.Sdk.*;
import flight._internal._UInt8ClampedArray as FlightUInt8ClampedArray;
import flight._internal._UInt8Array as FlightUInt8Array;
import flight.types.Bitmap as FlightBitmapHandle;
#if (lime_cairo && !js)
import flight._internal.backend.NativeScratchCanvas;
#end
import openfl.Vector;
import openfl.display.BlendMode as OpenFLBlendMode;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.TextureBase;
import openfl.display._internal.PerlinNoise;
import openfl.errors.Error;
import openfl.filters.BitmapFilter;
import openfl.filters.BevelFilter;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.DisplacementMapFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
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
@:access(openfl.display3D.textures.TextureBase)
@:access(openfl.display.Application)
@:access(openfl.display.Bitmap)
@:access(openfl.display.DisplayObject)
@:access(openfl.display.Window)
@:access(openfl.filters.BitmapFilter)
class BitmapData implements IBitmapDrawable
{
	public var height(default, null):Int;
	@SuppressWarnings("checkstyle:Dynamic")
	public var image(default, null):#if lime Image #else Dynamic #end;
	@:beta public var readable(default, null):Bool;
	public var rect(default, null):Rectangle;
	public var transparent(default, null):Bool;
	public var width(default, null):Int;

	@:noCompletion private var __asset:Bool;
	@:noCompletion private var __blendMode:BlendMode;
	@:noCompletion private var __bitmap:FlightBitmapHandle;
	@:noCompletion private var __bitmapUsers:Array<Bitmap>;
	@:noCompletion private var __drawableType:Any;
	@:noCompletion private var __flightBitmap(get, never):FlightBitmapHandle;
	@:noCompletion private var __isMask:Bool;
	@:noCompletion private var __isValid:Bool;
	@:noCompletion private var __mask:DisplayObject;
	@:noCompletion private var __renderable:Bool;
	@:noCompletion private var __renderTransform:Matrix;
	@:noCompletion private var __scrollRect:Rectangle;
	@:noCompletion private var __texture:TextureBase;
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
		__bitmapUsers = [];
		__renderable = true;
		rect = new Rectangle(0, 0, this.width, this.height);
		var color:Int = cast fillColor;
		if (!transparent) color = 0xFF000000 | (color & 0xFFFFFF);
		__bitmap = FlightBitmap.createBitmap(this.width, this.height, __argbToFlight(color, true));
		__bitmap.alphaType = cast "premultiplied";
	}

	public function applyFilter(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter):Void
	{
		if (!readable || __bitmap == null || sourceBitmapData == null || !sourceBitmapData.readable || sourceBitmapData.__bitmap == null) return;

		var filtered = filter.__needSecondBitmapData ? new BitmapData(width, height, true, 0) : this;
		var original:BitmapData = null;
		if (filter.__preserveObject)
		{
			original = new BitmapData(width, height, true, 0);
			original.copyPixels(this, rect, destPoint);
		}
		var lastBitmap:BitmapData = sourceBitmapData;

		if (Std.isOfType(filter, BlurFilter))
		{
			var blur:BlurFilter = cast filter;
			__applyBoxBlur(filtered, sourceBitmapData, sourceRect, destPoint, blur.blurX, blur.blurY, blur.quality);
			lastBitmap = filtered;
		}
		else if (Std.isOfType(filter, BevelFilter))
		{
			var bevel:BevelFilter = cast filter;
			__applyBoxBlur(filtered, sourceBitmapData, sourceRect, destPoint, bevel.blurX, bevel.blurY, bevel.quality);
			lastBitmap = filtered;
		}
		else if (Std.isOfType(filter, ColorMatrixFilter))
		{
			__applyOpenFLColorMatrix(filtered, sourceBitmapData, sourceRect, destPoint, cast filter);
			lastBitmap = filtered;
		}
		else if (Std.isOfType(filter, DisplacementMapFilter))
		{
			__applyDisplacement(filtered, this, cast filter);
			lastBitmap = filtered;
		}
		else if (Std.isOfType(filter, DropShadowFilter))
		{
			var shadow:DropShadowFilter = cast filter;
			var radians = shadow.angle * Math.PI / 180;
			var point = new Point(destPoint.x + Std.int(shadow.distance * Math.cos(radians)), destPoint.y + Std.int(shadow.distance * Math.sin(radians)));
			__applyBoxBlur(filtered, sourceBitmapData, sourceRect, point, shadow.blurX, shadow.blurY, shadow.quality);
			__colorizeFilterBitmap(filtered, shadow.color, shadow.alpha);
			lastBitmap = filtered;
		}
		else if (Std.isOfType(filter, GlowFilter))
		{
			var glow:GlowFilter = cast filter;
			__applyBoxBlur(filtered, sourceBitmapData, sourceRect, destPoint, glow.blurX, glow.blurY, glow.quality);
			__colorizeFilterBitmap(filtered, glow.color, glow.alpha);
			lastBitmap = filtered;
		}

		if (original != null)
		{
			lastBitmap.draw(original, null, null);
		}

		if (filter.__needSecondBitmapData && lastBitmap == filtered)
		{
			__bitmap = FlightBitmap.cloneBitmap(filtered.__bitmap);
		}
	}

	@:noCompletion private static function __applyBoxBlur(destination:BitmapData, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point,
		blurX:Float, blurY:Float, quality:Int):Void
	{
		var regionWidth = Std.int(Math.max(0, sourceRect.width));
		var regionHeight = Std.int(Math.max(0, sourceRect.height));
		if (regionWidth == 0 || regionHeight == 0) return;

		var sourcePixels:Array<Int> = [];
		for (y in 0...regionHeight)
		{
			for (x in 0...regionWidth)
			{
				var sourceX = Std.int(sourceRect.x) + x;
				var sourceY = Std.int(sourceRect.y) + y;
				var pixel = sourceX < 0 || sourceY < 0 || sourceX >= sourceBitmapData.width || sourceY >= sourceBitmapData.height ? 0
					: Std.int(FlightBitmap.getBitmapPixel(sourceBitmapData.__bitmap, sourceX, sourceY));
				sourcePixels.push(pixel);
			}
		}
		var passes = Std.int(Math.max(1, Math.min(3, quality)));
		var pixels:Array<Int> = [];
		for (y in 0...regionHeight)
		{
			for (x in 0...regionWidth)
			{
				var pixel = sourcePixels[y * regionWidth + x];
				pixels.push((pixel >>> 24) & 0xFF);
				pixels.push((pixel >>> 16) & 0xFF);
				pixels.push((pixel >>> 8) & 0xFF);
				pixels.push(pixel & 0xFF);
			}
		}

		for (_ in 0...passes)
		{
			pixels = __flashBoxBlur(pixels, regionWidth, regionHeight, blurX, true);
			pixels = __flashBoxBlur(pixels, regionWidth, regionHeight, blurY, false);
		}
		for (y in 0...regionHeight)
		{
			var destinationY = Std.int(destPoint.y) + y;
			if (destinationY < 0 || destinationY >= destination.height) continue;
			for (x in 0...regionWidth)
			{
				var destinationX = Std.int(destPoint.x) + x;
				if (destinationX < 0 || destinationX >= destination.width) continue;
				var offset = (y * regionWidth + x) * 4;
				FlightBitmap.setBitmapPixel(destination.__bitmap, destinationX, destinationY, (pixels[offset] << 24) | (pixels[offset + 1] << 16)
					| (pixels[offset + 2] << 8) | pixels[offset + 3]);
			}
		}
	}

	@:noCompletion private static function __flashBoxBlur(source:Array<Int>, width:Int, height:Int, fullSize:Float, horizontal:Bool):Array<Int>
	{
		// Flash treats blurX/blurY as the full box width. Its fractional edge
		// weight and each completed pass are truncated to 8-bit precision.
		fullSize = Math.min(fullSize, 255);
		if (fullSize <= 1) return source.copy();
		var halfWidth = fullSize * 0.5;
		var interior = Std.int(Math.floor(halfWidth - 0.5));
		var fraction = Math.floor((halfWidth - (interior + 0.5)) * 255) / 255;
		var destination:Array<Int> = [];
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				for (channel in 0...4)
				{
					var sum:Float = source[(y * width + x) * 4 + channel];
					for (position in 1...interior + 1)
					{
						sum += __blurSample(source, width, height, x, y, position, horizontal, channel);
						sum += __blurSample(source, width, height, x, y, -position, horizontal, channel);
					}
					var edge = interior + 1;
					sum += __blurSample(source, width, height, x, y, edge, horizontal, channel) * fraction;
					sum += __blurSample(source, width, height, x, y, -edge, horizontal, channel) * fraction;
					destination.push(Std.int(Math.floor(sum / fullSize)));
				}
			}
		}
		return destination;
	}

	@:noCompletion private static inline function __blurSample(source:Array<Int>, width:Int, height:Int, x:Int, y:Int, offset:Int, horizontal:Bool,
		channel:Int):Int
	{
		var sampleX = horizontal ? Std.int(Math.max(0, Math.min(width - 1, x + offset))) : x;
		var sampleY = horizontal ? y : Std.int(Math.max(0, Math.min(height - 1, y + offset)));
		return source[(sampleY * width + sampleX) * 4 + channel];
	}

	@:noCompletion private static function __applyOpenFLColorMatrix(destination:BitmapData, source:BitmapData, sourceRect:Rectangle, destPoint:Point,
		filter:ColorMatrixFilter):Void
	{
		var matrix = filter.matrix;
		var offsetX = Std.int(destPoint.x - sourceRect.x);
		var offsetY = Std.int(destPoint.y - sourceRect.y);
		for (row in Std.int(sourceRect.y)...Std.int(sourceRect.height))
		{
			for (column in Std.int(sourceRect.x)...Std.int(sourceRect.width))
			{
				var color = source.getPixel32(column, row);
				var alpha = (color >>> 24) & 0xFF;
				var transformed = 0;
				if (alpha != 0)
				{
					var red = (color >>> 16) & 0xFF;
					var green = (color >>> 8) & 0xFF;
					var blue = color & 0xFF;
					transformed = (__colorMatrixComponent(matrix, 15, red, green, blue, alpha) << 24)
						| (__colorMatrixComponent(matrix, 0, red, green, blue, alpha) << 16)
						| (__colorMatrixComponent(matrix, 5, red, green, blue, alpha) << 8)
						| __colorMatrixComponent(matrix, 10, red, green, blue, alpha);
				}
				destination.setPixel32(column + offsetY, row + offsetX, transformed);
			}
		}
	}

	@:noCompletion private static function __applyDisplacement(destination:BitmapData, source:BitmapData, filter:DisplacementMapFilter):Void
	{
		if (filter.mapBitmap == null) return;
		if (__isNeutralDisplacementMap(filter))
		{
			destination.__bitmap = FlightBitmap.cloneBitmap(source.__bitmap);
			return;
		}
		var sourceBitmap = __toStraightBitmap(source);
		var mapBitmap = __toStraightBitmap(filter.mapBitmap);
		var output = new FlightUInt8ClampedArray(source.width * source.height * 4);
		FlightBitmap.displaceBitmap(output, FlightBitmap.createBitmapRegion(sourceBitmap), {
			map: FlightBitmap.createBitmapRegion(mapBitmap, filter.mapPoint == null ? 0 : filter.mapPoint.x, filter.mapPoint == null ? 0 : filter.mapPoint.y),
			componentX: __flightChannel(filter.componentX),
			componentY: __flightChannel(filter.componentY),
			scaleX: filter.scaleX,
			scaleY: filter.scaleY,
			mode: cast Std.string(filter.mode),
			fillColor: __argbToFlight((Std.int(filter.alpha * 255) << 24) | (filter.color & 0xFFFFFF), false)
		});
		var bitmap = __toStraightBitmap(destination);
		FlightBitmap.writeBitmapPixels(FlightBitmap.createBitmapRegion(bitmap), output);
		destination.__writeStraightRegion(bitmap, 0, 0, source.width, source.height);
	}

	@:noCompletion private static function __isNeutralDisplacementMap(filter:DisplacementMapFilter):Bool
	{
		if (filter.componentX == 0 || filter.componentY == 0) return false;
		for (y in 0...filter.mapBitmap.height)
		{
			for (x in 0...filter.mapBitmap.width)
			{
				var pixel = filter.mapBitmap.getPixel32(x, y);
				if (__bitmapChannel(pixel, filter.componentX) != 0x80 || __bitmapChannel(pixel, filter.componentY) != 0x80) return false;
			}
		}
		return true;
	}

	@:noCompletion private static inline function __bitmapChannel(pixel:Int, channel:Int):Int
	{
		return switch (channel)
		{
			case BitmapDataChannel.RED: (pixel >>> 16) & 0xFF;
			case BitmapDataChannel.GREEN: (pixel >>> 8) & 0xFF;
			case BitmapDataChannel.BLUE: pixel & 0xFF;
			case BitmapDataChannel.ALPHA: (pixel >>> 24) & 0xFF;
			default: -1;
		};
	}

	@:noCompletion private static function __colorizeFilterBitmap(bitmap:BitmapData, color:Int, alpha:Float):Void
	{
		bitmap.colorTransform(bitmap.rect, new ColorTransform(0, 0, 0, alpha, (color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF, 0));
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
				setPixel32(Std.int(clipped.x) + x, Std.int(clipped.y) + y, __flightToArgb(Std.int(FlightBitmap.getBitmapPixel(destination, x, y)), false));
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
					var alpha = ((sourcePixel >>> 24) & 0xFF) - ((otherPixel >>> 24) & 0xFF);
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

	public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null,
			mergeAlpha:Bool = false):Void
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
			var sourceHandle = sourceBitmapData == this ? FlightBitmap.cloneBitmap(sourceBitmapData.__bitmap) : sourceBitmapData.__bitmap;
			var source = FlightBitmap.createBitmapRegion(sourceHandle, sourceX, sourceY, regionWidth, regionHeight);
			var destination = FlightBitmap.createBitmapRegion(__bitmap, destinationX, destinationY, regionWidth, regionHeight);
			FlightBitmap.copyBitmapPixels(destination, source, false);
			return;
		}

		var sourceBitmap = __toStraightBitmap(sourceBitmapData);
		if (alphaBitmapData != null && alphaBitmapData.readable && alphaBitmapData.__bitmap != null)
		{
			var alphaX = alphaPoint == null ? 0 : Std.int(Math.max(0, alphaPoint.x));
			var alphaY = alphaPoint == null ? 0 : Std.int(Math.max(0, alphaPoint.y));
			var destinationBitmap = __toStraightBitmap(this);
			for (y in 0...regionHeight)
			{
				for (x in 0...regionWidth)
				{
					var bitmapX = sourceX + x;
					var bitmapY = sourceY + y;
					var writeX = destinationX + x;
					var writeY = destinationY + y;
					var maskX = alphaX + x;
					var maskY = alphaY + y;
					if (bitmapX < 0 || bitmapY < 0 || bitmapX >= sourceBitmapData.width || bitmapY >= sourceBitmapData.height || writeX < 0 || writeY < 0
						|| writeX >= width || writeY >= height || maskX >= alphaBitmapData.width || maskY >= alphaBitmapData.height) continue;
					var sourcePixel = sourceBitmapData.getPixel32(bitmapX, bitmapY);
					var maskAlpha = (alphaBitmapData.getPixel32(maskX, maskY) >>> 24) & 0xFF;
					var sourceAlpha = (sourcePixel >>> 24) & 0xFF;
					var combinedAlpha = Std.int(Math.round(sourceAlpha * maskAlpha / 255));
					FlightBitmap.setBitmapPixel(sourceBitmap, bitmapX, bitmapY, __argbToFlight((combinedAlpha << 24) | (sourcePixel & 0xFFFFFF), false));
					var sourceRegion = FlightBitmap.createBitmapRegion(sourceBitmap, bitmapX, bitmapY, 1, 1);
					var destinationRegion = FlightBitmap.createBitmapRegion(destinationBitmap, writeX, writeY, 1, 1);
					FlightBitmap.copyBitmapPixels(destinationRegion, sourceRegion, mergeAlpha);
				}
			}
			__writeStraightRegion(destinationBitmap, 0, 0, width, height);
			return;
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
		__texture = null;
		width = 0;
		height = 0;
		rect = null;
		__isValid = false;
		readable = false;
		for (bitmap in __bitmapUsers.copy()) bitmap.__syncBitmapData();
	}

	@:beta public function disposeImage():Void
	{
		image = null;
		readable = false;
	}

	public function draw(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null,
			clipRect:Rectangle = null, smoothing:Bool = false):Void
	{
		if (!readable || __bitmap == null || source == null) return;
		var sourceBitmapData:BitmapData;
		var bitmapMatrix = matrix;
		if (Std.isOfType(source, BitmapData))
		{
			sourceBitmapData = cast source;
		}
		else if (Std.isOfType(source, DisplayObject))
		{
			sourceBitmapData = __drawDisplayObject(cast source, matrix, smoothing);
			bitmapMatrix = null;
		}
		else
		{
			return;
		}
		if (sourceBitmapData == null || !sourceBitmapData.readable || sourceBitmapData.__bitmap == null) return;
		var inverse = bitmapMatrix == null ? new Matrix() : bitmapMatrix.clone();
		inverse.invert();
		var transformed = FlightBitmap.createBitmap(width, height, 0);
		FlightBitmap.transformBitmap(FlightBitmap.createBitmapRegion(transformed), FlightBitmap.createBitmapRegion(__toStraightBitmap(sourceBitmapData)),
			[inverse.a, inverse.b, inverse.c, inverse.d, inverse.tx, inverse.ty], "transparent", smoothing ? "bilinear" : "nearest");
		if (colorTransform != null)
		{
			var transformedBitmapData = new BitmapData(width, height, true, 0);
			transformedBitmapData.__writeStraightRegion(transformed, 0, 0, width, height);
			transformedBitmapData.colorTransform(transformedBitmapData.rect, colorTransform);
			transformed = __toStraightBitmap(transformedBitmapData);
		}

		var clipped = clipRect == null ? rect : __clipRectangle(clipRect);
		if (clipped == null) return;
		var destinationBitmap = __toStraightBitmap(this);
		var destination = FlightBitmap.createBitmapRegion(destinationBitmap, clipped.x, clipped.y, clipped.width, clipped.height);
		var transformedRegion = FlightBitmap.createBitmapRegion(transformed, clipped.x, clipped.y, clipped.width, clipped.height);
		FlightBitmap.compositeBitmapRegion(destination, transformedRegion, __flightBlendMode(blendMode));
		__writeStraightRegion(destinationBitmap, Std.int(clipped.x), Std.int(clipped.y), Std.int(clipped.width), Std.int(clipped.height));
	}

	public function drawWithQuality(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null,
			clipRect:Rectangle = null, smoothing:Bool = false, quality:StageQuality = null):Void
	{
		draw(source, matrix, colorTransform, blendMode, clipRect, quality != StageQuality.LOW ? smoothing : false);
	}

	public function encode(rect:Rectangle, compressor:Object, byteArray:ByteArray = null):ByteArray
	{
		if (!readable || __bitmap == null || rect == null) return null;
		var format:String;
		var quality = 0.9;
		if (Std.isOfType(compressor, PNGEncoderOptions))
		{
			format = "png";
		}
		else if (Std.isOfType(compressor, JPEGEncoderOptions))
		{
			format = "jpeg";
			quality = (cast compressor : JPEGEncoderOptions).quality / 100;
		}
		else
		{
			return null;
		}

		var source = __toStraightBitmap(this);
		if (!rect.equals(this.rect))
		{
			var regionWidth = Std.int(Math.max(0, Math.ceil(rect.width)));
			var regionHeight = Std.int(Math.max(0, Math.ceil(rect.height)));
			var cropped = FlightBitmap.createBitmap(regionWidth, regionHeight, 0);
			FlightBitmap.copyBitmapPixels(FlightBitmap.createBitmapRegion(cropped),
				FlightBitmap.createBitmapRegion(source, Math.round(rect.x), Math.round(rect.y), regionWidth, regionHeight), false);
			source = cropped;
		}

		var encoded:FlightUInt8Array = FlightBitmap.encodeBitmap(cast Application.__flightHost, source, format, quality);
		if (encoded == null) return null;
		if (byteArray == null) byteArray = new ByteArray();
		for (index in 0...encoded.length)
			byteArray.writeByte(encoded[index]);
		return byteArray;
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
		// TODO (blocked: async-only Flight ImageCodec): this synchronous OpenFL
		// factory cannot await Flight's Promise-based image decoder.
		return null;
	}

	public static function fromBytes(bytes:ByteArray, rawAlpha:ByteArray = null):BitmapData
	{
		// TODO (blocked: async-only Flight ImageCodec): decoding encoded bytes is
		// Promise-based, and Flight has no raw-alpha merge adapter.
		return null;
	}

	public static function fromCanvas(canvas:CanvasElement, transparent:Bool = true):BitmapData
	{
		#if (js && html5)
		if (canvas == null) return null;
		var bitmap = FlightBitmap.createBitmapFromCanvas(cast canvas);
		var result = new BitmapData(Std.int(bitmap.width), Std.int(bitmap.height), transparent, 0);
		result.__writeStraightRegion(bitmap, 0, 0, result.width, result.height);
		return result;
		#else
		return null;
		#end
	}

	public static function fromFile(path:String):BitmapData
	{
		// TODO (blocked: asynchronous resource pipeline): Flight exposes no
		// synchronous local-path read-and-decode operation for this factory.
		return null;
	}

	public static function fromImage(image:Image, transparent:Bool = true):BitmapData
	{
		#if lime
		if (image == null || image.buffer == null || image.width <= 0 || image.height <= 0) return null;
		var source = image.getPixels(new lime.math.Rectangle(0, 0, image.width, image.height), lime.graphics.PixelFormat.RGBA32);
		if (source == null) return null;

		var result = new BitmapData(image.width, image.height, transparent, 0);
		var straightPixels = new FlightUInt8ClampedArray(image.width * image.height * 4);
		for (i in 0...straightPixels.length)
		{
			straightPixels[i] = (!transparent && (i & 3) == 3) ? 0xFF : source.get(i);
		}
		var pixels = new FlightUInt8ClampedArray(straightPixels.length);
		FlightBitmap.premultiplyBitmapPixels(pixels, straightPixels, straightPixels.length);
		FlightBitmap.writeBitmapPixels(FlightBitmap.createBitmapRegion(result.__bitmap), pixels);
		result.image = image;
		return result;
		#else
		return null;
		#end
	}

	public static function fromTexture(texture:TextureBase):BitmapData
	{
		if (texture == null) return null;
		var result = new BitmapData(texture.__width, texture.__height, true, 0);
		result.readable = false;
		result.__bitmap = null;
		result.__texture = texture;
		result.image = null;
		return result;
	}

	public function generateFilterRect(sourceRect:Rectangle, filter:BitmapFilter):Rectangle
	{
		return sourceRect == null ? null : sourceRect.clone();
	}

	public function getColorBoundsRect(mask:Int, color:Int, findColor:Bool = true):Rectangle
	{
		if (!readable || __bitmap == null) return new Rectangle(0, 0, width, height);
		if (!transparent)
		{
			mask |= 0xFF000000;
			color |= 0xFF000000;
		}
		// Lime compares the masked pixel with the complete requested color. Flight
		// masks both operands, so handle impossible matches before delegating.
		if ((color & ~mask) != 0) return findColor ? new Rectangle() : new Rectangle(0, 0, width, height);
		var bitmap = __toStraightBitmap(this);
		var bounds = FlightBitmap.getBitmapColorBoundsRectangle(FlightBitmap.createBitmapRegion(bitmap), __argbToFlight(mask, false),
			__argbToFlight(color, false), findColor);
		return bounds == null ? new Rectangle() : new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
	}

	@:dox(hide) public function getIndexBuffer(context:Context3D, scale9Grid:Rectangle = null):IndexBuffer3D
	{
		// TODO (blocked: Stage3D geometry bridge): Flight exposes no public mesh
		// index-buffer abstraction matching OpenFL's cached quad/scale9 layout.
		return null;
	}

	@SuppressWarnings("checkstyle:Dynamic")
	@:dox(hide) public function getSurface():#if lime CairoImageSurface #else Dynamic #end
	{
		// TODO (blocked: raster-surface type bridge): Flight surfaces cannot be
		// converted to Lime's CairoImageSurface through a public API.
		return null;
	}

	@:dox(hide) public function getTexture(context:Context3D):TextureBase
	{
		if (!__isValid || context == null) return null;
		if (__texture != null && __texture.__context == context) return __texture;
		if (!readable || __bitmap == null) return null;

		var texture:RectangleTexture = context.createRectangleTexture(width, height, Context3DTextureFormat.BGRA, false);
		texture.uploadFromBitmapData(this);
		__texture = texture;
		return texture;
	}

	@:dox(hide) public function getVertexBuffer(context:Context3D, scale9Grid:Rectangle = null, targetObject:DisplayObject = null):VertexBuffer3D
	{
		// TODO (blocked: Stage3D geometry bridge): Flight exposes no public vertex
		// buffer/layout contract for OpenFL's quad and scale9 cache data.
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
		FlightBitmap.extractBitmapPixels(pixels, FlightBitmap.createBitmapRegion(__toStraightBitmap(this), rect.x, rect.y, regionWidth, regionHeight));
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
		for (y in top...bottom)
			for (x in left...right)
				result.push(getPixel32(x, y));
		return result;
	}

	public function histogram(hRect:Rectangle = null):Array<Array<Int>>
	{
		if (!readable || __bitmap == null) return [for (_ in 0...4) [for (_ in 0...256) 0]];
		var source = hRect == null ? rect : hRect;
		var histogram = FlightBitmap.getBitmapHistogram(FlightBitmap.createBitmapRegion(__toStraightBitmap(this), source.x, source.y, source.width,
			source.height));
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
		if (!readable || __bitmap == null || firstPoint == null || secondObject == null) return false;
		if (Std.isOfType(secondObject, Bitmap)) secondObject = (cast secondObject : Bitmap).bitmapData;

		if (Std.isOfType(secondObject, Point))
		{
			var point:Point = cast secondObject;
			var x = Std.int(point.x - firstPoint.x);
			var y = Std.int(point.y - firstPoint.y);
			return x >= 0 && y >= 0 && x < width && y < height && __alphaAt(x, y) > firstAlphaThreshold;
		}

		if (Std.isOfType(secondObject, Rectangle))
		{
			var second:Rectangle = cast secondObject;
			var left = Std.int(Math.max(0, second.x - firstPoint.x));
			var top = Std.int(Math.max(0, second.y - firstPoint.y));
			var right = Std.int(Math.min(width, second.x - firstPoint.x + second.width));
			var bottom = Std.int(Math.min(height, second.y - firstPoint.y + second.height));
			for (y in top...bottom)
				for (x in left...right)
					if (__alphaAt(x, y) > firstAlphaThreshold) return true;
			return false;
		}

		if (Std.isOfType(secondObject, BitmapData))
		{
			var second:BitmapData = cast secondObject;
			if (!second.readable || second.__bitmap == null) return false;
			var offsetX = secondBitmapDataPoint == null ? 0 : Math.round(secondBitmapDataPoint.x - firstPoint.x);
			var offsetY = secondBitmapDataPoint == null ? 0 : Math.round(secondBitmapDataPoint.y - firstPoint.y);
			var left = Std.int(Math.max(0, offsetX));
			var top = Std.int(Math.max(0, offsetY));
			var right = Std.int(Math.min(width, offsetX + second.width));
			var bottom = Std.int(Math.min(height, offsetY + second.height));
			for (y in top...bottom)
				for (x in left...right)
				{
					if (__alphaAt(x, y) > firstAlphaThreshold
						&& second.__alphaAt(x - offsetX, y - offsetY) > secondAlphaThreshold) return true;
				}
		}
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

	public function merge(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redMultiplier:UInt, greenMultiplier:UInt, blueMultiplier:UInt,
			alphaMultiplier:UInt):Void
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
		for (offsetY in 0...regionHeight)
			for (offsetX in 0...regionWidth)
			{
				var sourceX = Std.int(sourceRect.x) + offsetX;
				var sourceY = Std.int(sourceRect.y) + offsetY;
				var destinationX = Std.int(destPoint.x) + offsetX;
				var destinationY = Std.int(destPoint.y) + offsetY;
				if (sourceX < 0 || sourceY < 0 || sourceX >= sourceBitmapData.width || sourceY >= sourceBitmapData.height || destinationX < 0
					|| destinationY < 0 || destinationX >= width || destinationY >= height) continue;
				var sourceColor = Std.int(FlightBitmap.getBitmapPixel(sourceBitmap, sourceX, sourceY));
				var destinationColor = Std.int(FlightBitmap.getBitmapPixel(originalDestination, destinationX, destinationY));
				var mergedColor = (__mergeComponent((sourceColor >>> 24) & 0xFF, (destinationColor >>> 24) & 0xFF,
					redMultiplier) << 24) | (__mergeComponent((sourceColor >>> 16) & 0xFF, (destinationColor >>> 16) & 0xFF,
						greenMultiplier) << 16) | (__mergeComponent((sourceColor >>> 8) & 0xFF, (destinationColor >>> 8) & 0xFF,
							blueMultiplier) << 8) | __mergeComponent(sourceColor & 0xFF, destinationColor & 0xFF, alphaMultiplier);
				FlightBitmap.setBitmapPixel(destinationBitmap, destinationX, destinationY, mergedColor);
			}
		__writeStraightRegion(destinationBitmap, Std.int(destPoint.x), Std.int(destPoint.y), regionWidth, regionHeight);
	}

	public function noise(randomSeed:Int, low:Int = 0, high:Int = 255, channelOptions:Int = 7, grayScale:Bool = false):Void
	{
		if (!readable || __bitmap == null || width == 0 || height == 0) return;
		var rand = function():Int
		{
			randomSeed = randomSeed * 1103515245 + 12345;
			return Std.int(Math.abs(randomSeed / 65536)) % 32768;
		};
		rand();
		var range = high - low;
		for (y in 0...height) for (x in 0...width)
		{
			var red = 0;
			var green = 0;
			var blue = 0;
			var alpha = 255;
			if (grayScale)
			{
				red = low + (rand() % range);
				green = red;
				blue = red;
			}
			else
			{
				if ((channelOptions & 1) != 0) red = low + (rand() % range);
				if ((channelOptions & 2) != 0) green = low + (rand() % range);
				if ((channelOptions & 4) != 0) blue = low + (rand() % range);
				if ((channelOptions & 8) != 0) alpha = low + (rand() % range);
			}
			setPixel32(x, y, (alpha << 24) | (red << 16) | (green << 8) | blue);
		}
	}

	public function paletteMap(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redArray:Array<Int> = null, greenArray:Array<Int> = null,
			blueArray:Array<Int> = null, alphaArray:Array<Int> = null):Void
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

	public function perlinNoise(baseX:Float, baseY:Float, numOctaves:UInt, randomSeed:Int, stitch:Bool, fractalNoise:Bool, channelOptions:UInt = 7,
			grayScale:Bool = false, offsets:Array<Point> = null):Void
	{
		if (!readable || __bitmap == null || width == 0 || height == 0) return;
		var noise = new PerlinNoise(randomSeed, numOctaves, channelOptions, grayScale, 0.5, stitch, 0.15);
		noise.fill(this, baseX, baseY, 0);
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
		for (y in top...bottom)
			for (x in left...right)
			{
				if (index >= inputVector.length) return;
				setPixel32(x, y, inputVector[index++]);
			}
	}

	public function threshold(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, operation:String, threshold:Int, color:Int = 0x00000000,
			mask:Int = 0xFFFFFFFF, copySource:Bool = false):Int
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
		for (y in 0...sourceBitmapData.height)
			for (x in 0...sourceBitmapData.width)
				FlightBitmap.setBitmapPixel(sourceBitmap, x, y, sourceBitmapData.getPixel32(x, y));
		var destinationBitmap = FlightBitmap.createBitmap(width, height, 0);
		for (y in 0...height)
			for (x in 0...width)
				FlightBitmap.setBitmapPixel(destinationBitmap, x, y, getPixel32(x, y));

		var source = FlightBitmap.createBitmapRegion(sourceBitmap, sourceRect.x, sourceRect.y, regionWidth, regionHeight);
		var destination = FlightBitmap.createBitmapRegion(destinationBitmap, destPoint.x, destPoint.y, regionWidth, regionHeight);
		var changed = FlightBitmap.applyBitmapThreshold(destination, source, operation, threshold, color, mask, copySource);
		for (offsetY in 0...regionHeight)
			for (offsetX in 0...regionWidth)
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

	@:noCompletion private inline function __alphaAt(x:Int, y:Int):Int
	{
		return transparent ? (getPixel32(x, y) >>> 24) & 0xFF : 0xFF;
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

	@:noCompletion private static function __flightBlendMode(blendMode:OpenFLBlendMode):String
	{
		return switch (blendMode)
		{
			case OpenFLBlendMode.ADD: "Add";
			case OpenFLBlendMode.DARKEN: "Darken";
			case OpenFLBlendMode.DIFFERENCE: "Difference";
			case OpenFLBlendMode.ERASE: "DestinationOut";
			case OpenFLBlendMode.HARDLIGHT: "HardLight";
			case OpenFLBlendMode.INVERT: "Invert";
			case OpenFLBlendMode.LIGHTEN: "Lighten";
			case OpenFLBlendMode.MULTIPLY: "Multiply";
			case OpenFLBlendMode.OVERLAY: "Overlay";
			case OpenFLBlendMode.SCREEN: "Screen";
			case OpenFLBlendMode.SUBTRACT: "Subtract";
			default: "Normal";
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

	@:noCompletion private function __drawDisplayObject(source:DisplayObject, matrix:Matrix, smoothing:Bool):BitmapData
	{
		var flattened = FlightBitmap.createBitmap(width, height, 0);
		if (__drawBitmapDisplayTree(flattened, source, matrix == null ? new Matrix() : matrix, 1, smoothing, false))
		{
			var premultiplied = new FlightUInt8ClampedArray(flattened.data.length);
			FlightBitmap.premultiplyBitmapPixels(premultiplied, flattened.data, flattened.data.length);
			var result = new BitmapData(width, height, true, 0);
			FlightBitmap.writeBitmapPixels(FlightBitmap.createBitmapRegion(result.__bitmap), premultiplied);
			return result;
		}

		#if (lime_cairo && !js)
		if (source.__flightNode == null) return null;
		source.__syncFlightNode();
		var surfaceCreator = flight.Scene2DCairo.createCairoRenderSurfaceCreator();
		var canvas = new NativeScratchCanvas();
		canvas.width = width;
		canvas.height = height;
		var surface = createCanvasRenderSurface(surfaceCreator, cast canvas, {width: width, height: height});
		var resolvers = createCanvasTextureResolvers(surfaceCreator);
		var state = createCanvasRenderState(surface, scene2dCanvasPipeline, resolvers, {
			backgroundColor: 0x00000000,
			imageSmoothingEnabled: smoothing,
			pixelRatio: 1,
			renderTransform: cast (matrix == null ? new Matrix() : matrix),
			sceneGraphSyncPolicy: "always"
		});
		registerRenderer(state, SpriteKind, cast defaultCanvasSpriteRenderer);
		registerRenderer(state, ShapeKind, cast defaultCanvasShapeRenderer);
		registerRenderer(state, TextLabelKind, cast defaultCanvasTextLabelRenderer);
		registerRenderer(state, RichTextKind, cast defaultCanvasRichTextRenderer);
		registerCanvasShapeCommands(state, defaultCanvasShapeCommands);
		registerCanvasImageTextureResolver(resolvers);
		Window.__registerFlightCanvasBitmapResolver(resolvers);
		enableCanvasBlendMode(state);
		prepareScene2DRender(state, source.__flightNode);
		renderCanvasScene2D(state, source.__flightNode);

		var imageData:Dynamic = canvas.nativeContext().getImageData(0, 0, width, height);
		var premultiplied = new FlightUInt8ClampedArray(imageData.data.length);
		FlightBitmap.premultiplyBitmapPixels(premultiplied, imageData.data, imageData.data.length);
		var result = new BitmapData(width, height, true, 0);
		FlightBitmap.writeBitmapPixels(FlightBitmap.createBitmapRegion(result.__bitmap), premultiplied);
		destroyCanvasRenderState(state);
		destroyCanvasRenderSurface(surface);
		destroyCanvasTextureResolvers(resolvers);
		return result;
		#else
		return null;
		#end
	}

	@:noCompletion private function __drawBitmapDisplayTree(destination:FlightBitmapHandle, source:DisplayObject, parentMatrix:Matrix, parentAlpha:Float,
			smoothing:Bool, includeLocalTransform:Bool = true):Bool
	{
		if (source == null) return true;
		if (source.__graphics != null) return false;
		if (!source.__visible || source.__alpha <= 0) return true;
		var transform = parentMatrix.clone();
		if (includeLocalTransform)
		{
			transform = source.__transform.clone();
			transform.concat(parentMatrix);
		}
		var alpha = parentAlpha * source.__alpha;

		if (Std.isOfType(source, Bitmap))
		{
			var bitmap:Bitmap = cast source;
			if (bitmap.__bitmapData == null || bitmap.__bitmapData.__bitmap == null) return true;
			var inverse = transform.clone();
			inverse.invert();
			var transformed = FlightBitmap.createBitmap(width, height, 0);
			FlightBitmap.transformBitmap(FlightBitmap.createBitmapRegion(transformed),
				FlightBitmap.createBitmapRegion(__toStraightBitmap(bitmap.__bitmapData)),
				[inverse.a, inverse.b, inverse.c, inverse.d, inverse.tx, inverse.ty], "transparent", smoothing ? "bilinear" : "nearest");
			if (alpha < 1)
			{
				var faded = FlightBitmap.createBitmap(width, height, 0);
				FlightBitmap.applyBitmapColorScaleBias(FlightBitmap.createBitmapRegion(faded), FlightBitmap.createBitmapRegion(transformed), {
					redScale: 1.0,
					greenScale: 1.0,
					blueScale: 1.0,
					alphaScale: alpha,
					redBias: 0.0,
					greenBias: 0.0,
					blueBias: 0.0,
					alphaBias: 0.0
				});
				transformed = faded;
			}
			FlightBitmap.compositeBitmapRegion(FlightBitmap.createBitmapRegion(destination), FlightBitmap.createBitmapRegion(transformed),
				__flightBlendMode(source.__blendMode));
			return true;
		}

		if (source.__children != null)
		{
			for (child in source.__children)
			{
				if (!__drawBitmapDisplayTree(destination, child, transform, alpha, smoothing)) return false;
			}
		}
		return true;
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
		return Std.int(Math.max(0,
			Math.min(255, matrix[offset] * red + matrix[offset + 1] * green + matrix[offset + 2] * blue + matrix[offset + 3] * alpha + matrix[offset + 4])));
	}

	@:noCompletion private static function __premultiplyRgb(color:Int, alpha:Int):Int
	{
		return (__premultiplyComponent((color >>> 16) & 0xFF,
			alpha) << 16) | (__premultiplyComponent((color >>> 8) & 0xFF, alpha) << 8) | __premultiplyComponent(color & 0xFF, alpha);
	}

	@:noCompletion private static function __unpremultiplyComponent(component:Int, alpha:Int):Int
	{
		return Std.int(Math.min(255, Math.round(component * 255 / alpha)));
	}

	@:noCompletion private static function __unpremultiplyRgb(color:Int, alpha:Int):Int
	{
		if (alpha == 0) return 0;
		if (alpha == 0xFF) return color & 0xFFFFFF;
		return (__unpremultiplyComponent((color >>> 16) & 0xFF,
			alpha) << 16) | (__unpremultiplyComponent((color >>> 8) & 0xFF, alpha) << 8) | __unpremultiplyComponent(color & 0xFF, alpha);
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
