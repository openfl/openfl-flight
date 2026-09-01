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
	@:noCompletion private var __quality:Int;

	public function new(blurX:Float = 4, blurY:Float = 4, quality:Int = 1)
	{
		super();
		__blurX = blurX;
		__blurY = blurY;
		__quality = quality;
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

	@:noCompletion private inline function get_blurX():Float return __blurX;
	@:noCompletion private function set_blurX(value:Float):Float { __blurX = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_blurY():Float return __blurY;
	@:noCompletion private function set_blurY(value:Float):Float { __blurY = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_quality():Int return __quality;
	@:noCompletion private function set_quality(value:Int):Int { __quality = value; __syncFlightEffect(); return value; }
}
#else
typedef BlurFilter = flash.filters.BlurFilter;
#end
