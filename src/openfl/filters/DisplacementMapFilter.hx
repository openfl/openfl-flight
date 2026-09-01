package openfl.filters;

#if !flash
import flight.Bitmap as FlightBitmap;
import flight.types.BitmapRegion as FlightBitmapRegion;
import openfl.display.BitmapData;
import openfl.geom.Point;

/** Uses bitmap channels to displace pixels in display or bitmap content. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.BitmapData)
@:final class DisplacementMapFilter extends BitmapFilter
{
	public var alpha(get, set):Float;
	public var color(get, set):Int;
	public var componentX(get, set):Int;
	public var componentY(get, set):Int;
	public var mapBitmap(get, set):BitmapData;
	public var mapPoint(get, set):Point;
	public var mode(get, set):DisplacementMapFilterMode;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;

	@:noCompletion private var __alpha:Float;
	@:noCompletion private var __color:Int;
	@:noCompletion private var __componentX:Int;
	@:noCompletion private var __componentY:Int;
	@:noCompletion private var __flightMapRegion:FlightBitmapRegion;
	@:noCompletion private var __mapBitmap:BitmapData;
	@:noCompletion private var __mapPoint:Point;
	@:noCompletion private var __mode:DisplacementMapFilterMode;
	@:noCompletion private var __scaleX:Float;
	@:noCompletion private var __scaleY:Float;

	public function new(mapBitmap:BitmapData = null, mapPoint:Point = null, componentX:Int = 0, componentY:Int = 0, scaleX:Float = 0.0, scaleY:Float = 0.0,
			mode:DisplacementMapFilterMode = WRAP, color:Int = 0, alpha:Float = 0.0)
	{
		super();
		__mapBitmap = mapBitmap;
		__mapPoint = mapPoint != null ? mapPoint : new Point();
		__componentX = componentX;
		__componentY = componentY;
		__scaleX = scaleX;
		__scaleY = scaleY;
		__mode = mode;
		__color = color;
		__alpha = alpha;
		__needSecondBitmapData = true;
		__preserveObject = false;
		__renderDirty = true;
		__numShaderPasses = 1;
		__syncFlightMap();
	}

	public override function clone():BitmapFilter
	{
		return new DisplacementMapFilter(__mapBitmap, __mapPoint.clone(), __componentX, __componentY, __scaleX, __scaleY, __mode, __color, __alpha);
	}

	@:noCompletion private function __syncFlightMap():Void
	{
		if (__mapBitmap == null)
		{
			__flightMapRegion = null;
			return;
		}
		var x = __mapPoint == null ? 0 : __mapPoint.x;
		var y = __mapPoint == null ? 0 : __mapPoint.y;
		__flightMapRegion = FlightBitmap.createBitmapRegion(__mapBitmap.__flightBitmap, x, y);
	}

	@:noCompletion private inline function get_alpha():Float return __alpha;
	@:noCompletion private function set_alpha(value:Float):Float { __alpha = value; return value; }
	@:noCompletion private inline function get_color():Int return __color;
	@:noCompletion private function set_color(value:Int):Int { __color = value; return value; }
	@:noCompletion private inline function get_componentX():Int return __componentX;
	@:noCompletion private function set_componentX(value:Int):Int { __componentX = value; return value; }
	@:noCompletion private inline function get_componentY():Int return __componentY;
	@:noCompletion private function set_componentY(value:Int):Int { __componentY = value; return value; }
	@:noCompletion private inline function get_mapBitmap():BitmapData return __mapBitmap;
	@:noCompletion private function set_mapBitmap(value:BitmapData):BitmapData { __mapBitmap = value; __syncFlightMap(); return value; }
	@:noCompletion private inline function get_mapPoint():Point return __mapPoint;
	@:noCompletion private function set_mapPoint(value:Point):Point { __mapPoint = value; __syncFlightMap(); return value; }
	@:noCompletion private inline function get_mode():DisplacementMapFilterMode return __mode;
	@:noCompletion private function set_mode(value:DisplacementMapFilterMode):DisplacementMapFilterMode { __mode = value; return value; }
	@:noCompletion private inline function get_scaleX():Float return __scaleX;
	@:noCompletion private function set_scaleX(value:Float):Float { __scaleX = value; return value; }
	@:noCompletion private inline function get_scaleY():Float return __scaleY;
	@:noCompletion private function set_scaleY(value:Float):Float { __scaleY = value; return value; }
}
#else
typedef DisplacementMapFilter = flash.filters.DisplacementMapFilter;
#end
