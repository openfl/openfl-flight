package openfl.filters;

#if !flash
import flight.Effects as FlightEffects;

/** Applies a horizontal and vertical blur to display or bitmap content. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:final class BlurFilter extends BitmapFilter
{
	public var blurX(get, set):Float;
	public var blurY(get, set):Float;
	public var quality(get, set):Int;

	@:noCompletion private var __blurX:Float;
	@:noCompletion private var __blurY:Float;
	@:noCompletion private var __horizontalPasses:Int;
	@:noCompletion private var __quality:Int;
	@:noCompletion private var __verticalPasses:Int;

	public function new(blurX:Float = 4, blurY:Float = 4, quality:Int = 1)
	{
		super();
		this.blurX = blurX;
		this.blurY = blurY;
		this.quality = quality;
		__needSecondBitmapData = true;
		__preserveObject = false;
		__renderDirty = true;
		__syncFlightEffect();
	}

	public override function clone():BitmapFilter
	{
		return new BlurFilter(__blurX, __blurY, __quality);
	}

	@:noCompletion private override function __syncFlightEffect():Void
	{
		__flightEffect = FlightEffects.createBlurEffect({blurX: __blurX, blurY: __blurY});
	}

	@:noCompletion private inline function __padFor(value:Float):Int
	{
		if (value <= 0) return 0;
		var passes = __quality > 0 ? __quality : 1;
		#if (lime || harness_compare)
		var reach = value * passes * 3.0;
		#else
		var reach = value;
		#end
		return Std.int(Math.ceil(reach)) + 2;
	}

	@:noCompletion private inline function get_blurX():Float return __blurX;
	@:noCompletion private function set_blurX(value:Float):Float
	{
		if (value != __blurX)
		{
			__blurX = value;
			__renderDirty = true;
			var padding = __padFor(value);
			__leftExtension = padding;
			__rightExtension = padding;
			__syncFlightEffect();
		}
		return value;
	}
	@:noCompletion private inline function get_blurY():Float return __blurY;
	@:noCompletion private function set_blurY(value:Float):Float
	{
		if (value != __blurY)
		{
			__blurY = value;
			__renderDirty = true;
			var padding = __padFor(value);
			__topExtension = padding;
			__bottomExtension = padding;
			__syncFlightEffect();
		}
		return value;
	}
	@:noCompletion private inline function get_quality():Int return __quality;
	@:noCompletion private function set_quality(value:Int):Int
	{
		__horizontalPasses = __blurX <= 0 ? 0 : Math.round(__blurX * (value / 4)) + 1;
		__verticalPasses = __blurY <= 0 ? 0 : Math.round(__blurY * (value / 4)) + 1;
		__numShaderPasses = __horizontalPasses + __verticalPasses;
		if (value != __quality) __renderDirty = true;
		__quality = value;
		set_blurX(__blurX);
		set_blurY(__blurY);
		__syncFlightEffect();
		return __quality;
	}
}
#else
typedef BlurFilter = flash.filters.BlurFilter;
#end
