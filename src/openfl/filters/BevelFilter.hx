package openfl.filters;

#if !flash
import flight.Effects as FlightEffects;

/**
	Applies a highlight and shadow around display-object edges.

	@see `openfl.display.DisplayObject.filters`
	@see `openfl.display.BitmapData.applyFilter`
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:final class BevelFilter extends BitmapFilter
{
	public var blurX(get, set):Float;
	public var blurY(get, set):Float;
	public var distance(get, set):Float;
	public var angle(get, set):Float;
	public var highlightColor(get, set):UInt;
	public var highlightAlpha(get, set):Float;
	public var shadowColor(get, set):UInt;
	public var shadowAlpha(get, set):Float;
	public var quality(get, set):Int;
	public var strength(get, set):Float;
	public var type(get, set):String;
	public var knockout(get, set):Bool;

	@:noCompletion private var __angle:Float = 0;
	@:noCompletion private var __blurX:Float = 0;
	@:noCompletion private var __blurY:Float = 0;
	@:noCompletion private var __distance:Float = 0;
	@:noCompletion private var __highlightAlpha:Float = 0;
	@:noCompletion private var __highlightColor:UInt = 0;
	@:noCompletion private var __knockout:Bool = false;
	@:noCompletion private var __quality:Int = 0;
	@:noCompletion private var __shadowAlpha:Float = 0;
	@:noCompletion private var __shadowColor:UInt = 0;
	@:noCompletion private var __strength:Float = 0;
	@:noCompletion private var __type:String;

	public function new(distance:Float = 4.0, angle:Float = 45, highlightColor:UInt = 0xFFFFFF, highlightAlpha:Float = 1.0, shadowColor:UInt = 0x000000,
			shadowAlpha:Float = 1.0, blurX:Float = 4.0, blurY:Float = 4.0, strength:Float = 1, quality:Int = 1, type:String = "inner", knockout:Bool = false)
	{
		super();
		this.distance = distance;
		this.angle = angle;
		this.highlightColor = highlightColor;
		this.highlightAlpha = highlightAlpha;
		this.shadowColor = shadowColor;
		this.shadowAlpha = shadowAlpha;
		this.blurX = blurX;
		this.blurY = blurY;
		this.quality = quality;
		this.strength = strength;
		this.knockout = knockout;
		this.type = type;
		__needSecondBitmapData = true;
		__preserveObject = true;
		__renderDirty = true;
		__syncFlightEffect();
	}

	public override function clone():BitmapFilter
	{
		return new BevelFilter(__distance, __angle, __highlightColor, __highlightAlpha, __shadowColor, __shadowAlpha, __blurX, __blurY, __strength, __quality,
			__type, __knockout);
	}

	@:noCompletion private override function __syncFlightEffect():Void
	{
		__flightEffect = FlightEffects.createBevelEffect({
			distance: __distance,
			angle: __angle,
			highlightColor: BitmapFilter.__flightColor(cast __highlightColor),
			highlightAlpha: __highlightAlpha,
			shadowColor: BitmapFilter.__flightColor(cast __shadowColor),
			shadowAlpha: __shadowAlpha,
			blurX: __blurX,
			blurY: __blurY,
			strength: __strength,
			quality: __quality,
			bevelType: __type,
			sourceMode: __knockout ? "knockout" : "draw"
		});
	}

	@:noCompletion private inline function get_blurX():Float return __blurX;
	@:noCompletion private function set_blurX(value:Float):Float
	{
		__blurX = Math.max(0, Math.min(255, value));
		__syncFlightEffect();
		return __blurX;
	}

	@:noCompletion private inline function get_blurY():Float return __blurY;
	@:noCompletion private function set_blurY(value:Float):Float
	{
		__blurY = Math.max(0, Math.min(255, value));
		__syncFlightEffect();
		return __blurY;
	}

	@:noCompletion private inline function get_distance():Float return __distance;
	@:noCompletion private function set_distance(value:Float):Float { __distance = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_angle():Float return __angle;
	@:noCompletion private function set_angle(value:Float):Float { __angle = value; __syncFlightEffect(); return value; }
	@:noCompletion private inline function get_highlightColor():UInt return __highlightColor;
	@:noCompletion private function set_highlightColor(value:UInt):UInt
	{
		__highlightColor = value > 0xFFFFFF ? 0xFFFFFF : value;
		__syncFlightEffect();
		return __highlightColor;
	}

	@:noCompletion private inline function get_highlightAlpha():Float return __highlightAlpha;
	@:noCompletion private function set_highlightAlpha(value:Float):Float
	{
		__highlightAlpha = Math.max(0, Math.min(1, value));
		__syncFlightEffect();
		return __highlightAlpha;
	}

	@:noCompletion private inline function get_shadowColor():UInt return __shadowColor;
	@:noCompletion private function set_shadowColor(value:UInt):UInt
	{
		__shadowColor = value > 0xFFFFFF ? 0xFFFFFF : value;
		__syncFlightEffect();
		return __shadowColor;
	}

	@:noCompletion private inline function get_shadowAlpha():Float return __shadowAlpha;
	@:noCompletion private function set_shadowAlpha(value:Float):Float
	{
		__shadowAlpha = Math.max(0, Math.min(1, value));
		__syncFlightEffect();
		return __shadowAlpha;
	}

	@:noCompletion private inline function get_quality():Int return __quality;
	@:noCompletion private function set_quality(value:Int):Int
	{
		__quality = Std.int(Math.max(1, Math.min(15, value)));
		__syncFlightEffect();
		return __quality;
	}

	@:noCompletion private inline function get_strength():Float return __strength;
	@:noCompletion private function set_strength(value:Float):Float
	{
		__strength = Math.max(1, Math.min(255, value));
		__syncFlightEffect();
		return __strength;
	}

	@:noCompletion private inline function get_type():String return __type;
	@:noCompletion private function set_type(value:String):String
	{
		__type = value == "inner" || value == "outer" ? value : "full";
		__syncFlightEffect();
		return __type;
	}

	@:noCompletion private inline function get_knockout():Bool return __knockout;
	@:noCompletion private function set_knockout(value:Bool):Bool { __knockout = value; __syncFlightEffect(); return value; }
}
#else
typedef BevelFilter = flash.filters.BevelFilter;
#end
