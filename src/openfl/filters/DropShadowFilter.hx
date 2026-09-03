package openfl.filters;

#if !flash
import flight.Effects as FlightEffects;

/** Applies an inner or outer drop shadow to display or bitmap content. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:final class DropShadowFilter extends BitmapFilter
{
	public var alpha(get, set):Float;
	public var angle(get, set):Float;
	public var blurX(get, set):Float;
	public var blurY(get, set):Float;
	public var color(get, set):Int;
	public var distance(get, set):Float;
	public var hideObject(get, set):Bool;
	public var inner(get, set):Bool;
	public var knockout(get, set):Bool;
	public var quality(get, set):Int;
	public var strength(get, set):Float;

	@:noCompletion private var __alpha:Float;
	@:noCompletion private var __angle:Float;
	@:noCompletion private var __blurX:Float;
	@:noCompletion private var __blurY:Float;
	@:noCompletion private var __color:Int;
	@:noCompletion private var __distance:Float;
	@:noCompletion private var __hideObject:Bool;
	@:noCompletion private var __horizontalPasses:Int;
	@:noCompletion private var __inner:Bool;
	@:noCompletion private var __knockout:Bool;
	@:noCompletion private var __offsetX:Int;
	@:noCompletion private var __offsetY:Int;
	@:noCompletion private var __quality:Int;
	@:noCompletion private var __strength:Float;
	@:noCompletion private var __verticalPasses:Int;

	public function new(distance:Float = 4, angle:Float = 45, color:Int = 0, alpha:Float = 1, blurX:Float = 4, blurY:Float = 4, strength:Float = 1,
			quality:Int = 1, inner:Bool = false, knockout:Bool = false, hideObject:Bool = false)
	{
		super();
		__distance = distance;
		__angle = angle;
		__color = color;
		__alpha = alpha;
		__blurX = blurX;
		__blurY = blurY;
		__strength = strength;
		__quality = quality;
		__inner = inner;
		__knockout = knockout;
		__hideObject = hideObject;
		__updateSize();
		__needSecondBitmapData = true;
		__preserveObject = true;
		__renderDirty = true;
		__syncFlightEffect();
	}

	public override function clone():BitmapFilter
	{
		return new DropShadowFilter(__distance, __angle, __color, __alpha, __blurX, __blurY, __strength, __quality, __inner, __knockout, __hideObject);
	}

	@:noCompletion private override function __syncFlightEffect():Void
	{
		var sourceMode = __hideObject ? "hide" : (__knockout ? "knockout" : "draw");
		var options = {
			distance: __distance,
			angle: __angle,
			color: BitmapFilter.__flightColor(__color),
			alpha: __alpha,
			blurX: __blurX,
			blurY: __blurY,
			strength: __strength,
			quality: (__quality : Float),
			sourceMode: sourceMode
		};
		if (__inner)
			__flightEffect = cast FlightEffects.createInnerShadowEffect(options);
		else
			__flightEffect = cast FlightEffects.createDropShadowEffect(options);
	}

	@:noCompletion private inline function get_alpha():Float return __alpha;
	@:noCompletion private function set_alpha(value:Float):Float { __alpha = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_angle():Float return __angle;
	@:noCompletion private function set_angle(value:Float):Float { __angle = value; __renderDirty = true; __updateSize(); __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_blurX():Float return __blurX;
	@:noCompletion private function set_blurX(value:Float):Float { __blurX = value; __renderDirty = true; __updateSize(); __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_blurY():Float return __blurY;
	@:noCompletion private function set_blurY(value:Float):Float { __blurY = value; __renderDirty = true; __updateSize(); __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_color():Int return __color;
	@:noCompletion private function set_color(value:Int):Int { __color = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_distance():Float return __distance;
	@:noCompletion private function set_distance(value:Float):Float { __distance = value; __renderDirty = true; __updateSize(); __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_hideObject():Bool return __hideObject;
	@:noCompletion private function set_hideObject(value:Bool):Bool { __hideObject = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_inner():Bool return __inner;
	@:noCompletion private function set_inner(value:Bool):Bool { __inner = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_knockout():Bool return __knockout;
	@:noCompletion private function set_knockout(value:Bool):Bool { __knockout = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_quality():Int return __quality;
	@:noCompletion private function set_quality(value:Int):Int { __quality = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_strength():Float return __strength;
	@:noCompletion private function set_strength(value:Float):Float { __strength = value; __syncFlightEffect(); return value; }

	@:noCompletion private function __updateSize():Void
	{
		__offsetX = Std.int(__distance * Math.cos(__angle * Math.PI / 180));
		__offsetY = Std.int(__distance * Math.sin(__angle * Math.PI / 180));
		__topExtension = Math.ceil((__offsetY < 0 ? -__offsetY : 0) + __blurY);
		__bottomExtension = Math.ceil((__offsetY > 0 ? __offsetY : 0) + __blurY);
		__leftExtension = Math.ceil((__offsetX < 0 ? -__offsetX : 0) + __blurX);
		__rightExtension = Math.ceil((__offsetX > 0 ? __offsetX : 0) + __blurX);
		__horizontalPasses = __blurX <= 0 ? 0 : Math.round(__blurX * (__quality / 4)) + 1;
		__verticalPasses = __blurY <= 0 ? 0 : Math.round(__blurY * (__quality / 4)) + 1;
		__numShaderPasses = __horizontalPasses + __verticalPasses + (__inner ? 2 : 1);
	}
}
#else
typedef DropShadowFilter = flash.filters.DropShadowFilter;
#end
