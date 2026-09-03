package openfl.filters;

#if !flash
import flight.Effects as FlightEffects;

/** Applies an inner or outer glow to display or bitmap content. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:final class GlowFilter extends BitmapFilter
{
	public var alpha(get, set):Float;
	public var blurX(get, set):Float;
	public var blurY(get, set):Float;
	public var color(get, set):Int;
	public var inner(get, set):Bool;
	public var knockout(get, set):Bool;
	public var quality(get, set):Int;
	public var strength(get, set):Float;

	@:noCompletion private var __alpha:Float;
	@:noCompletion private var __blurX:Float;
	@:noCompletion private var __blurY:Float;
	@:noCompletion private var __color:Int;
	@:noCompletion private var __horizontalPasses:Int;
	@:noCompletion private var __inner:Bool;
	@:noCompletion private var __knockout:Bool;
	@:noCompletion private var __quality:Int;
	@:noCompletion private var __strength:Float;
	@:noCompletion private var __verticalPasses:Int;

	public function new(color:Int = 0xFF0000, alpha:Float = 1, blurX:Float = 6, blurY:Float = 6, strength:Float = 2, quality:Int = 1, inner:Bool = false,
			knockout:Bool = false)
	{
		super();
		__color = color;
		__alpha = alpha;
		__blurX = blurX;
		__blurY = blurY;
		__strength = strength;
		__inner = inner;
		__knockout = knockout;
		__quality = quality;
		__updateSize();
		__needSecondBitmapData = true;
		__preserveObject = true;
		__renderDirty = true;
		__syncFlightEffect();
	}

	public override function clone():BitmapFilter
	{
		return new GlowFilter(__color, __alpha, __blurX, __blurY, __strength, __quality, __inner, __knockout);
	}

	@:noCompletion private override function __syncFlightEffect():Void
	{
		var options = {
			color: BitmapFilter.__flightColor(__color),
			alpha: __alpha,
			blurX: __blurX,
			blurY: __blurY,
			strength: __strength,
			quality: (__quality : Float),
			sourceMode: __knockout ? "knockout" : "draw"
		};
		if (__inner)
			__flightEffect = cast FlightEffects.createInnerGlowEffect(options);
		else
			__flightEffect = cast FlightEffects.createOuterGlowEffect(options);
	}

	@:noCompletion private inline function get_alpha():Float return __alpha;
	@:noCompletion private function set_alpha(value:Float):Float { __alpha = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_blurX():Float return __blurX;
	@:noCompletion private function set_blurX(value:Float):Float { __blurX = value; __renderDirty = true; __updateSize(); __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_blurY():Float return __blurY;
	@:noCompletion private function set_blurY(value:Float):Float { __blurY = value; __renderDirty = true; __updateSize(); __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_color():Int return __color;
	@:noCompletion private function set_color(value:Int):Int { __color = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_inner():Bool return __inner;
	@:noCompletion private function set_inner(value:Bool):Bool { if (value != __inner) __calculateNumShaderPasses(); __inner = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_knockout():Bool return __knockout;
	@:noCompletion private function set_knockout(value:Bool):Bool { if (value != __knockout) __calculateNumShaderPasses(); __knockout = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_quality():Int return __quality;
	@:noCompletion private function set_quality(value:Int):Int { if (value != __quality) __calculateNumShaderPasses(); __quality = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_strength():Float return __strength;
	@:noCompletion private function set_strength(value:Float):Float { __strength = value; __syncFlightEffect(); return value; }

	@:noCompletion private function __updateSize():Void
	{
		__leftExtension = __blurX > 0 ? Math.ceil(__blurX * 1.5) : 0;
		__rightExtension = __leftExtension;
		__topExtension = __blurY > 0 ? Math.ceil(__blurY * 1.5) : 0;
		__bottomExtension = __topExtension;
		__calculateNumShaderPasses();
	}

	@:noCompletion private function __calculateNumShaderPasses():Void
	{
		__horizontalPasses = __blurX <= 0 ? 0 : Math.round(__blurX * (__quality / 4)) + 1;
		__verticalPasses = __blurY <= 0 ? 0 : Math.round(__blurY * (__quality / 4)) + 1;
		__numShaderPasses = __horizontalPasses + __verticalPasses + (__inner ? 2 : 1);
	}
}
#else
typedef GlowFilter = flash.filters.GlowFilter;
#end
