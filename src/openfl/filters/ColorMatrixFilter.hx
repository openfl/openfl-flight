package openfl.filters;

#if !flash
import flight.Adjustments as FlightAdjustments;
import flight.types.Adjustment;
import flight.types.ColorMatrixAdjustment;

/** Applies a 4-by-5 color transform matrix to display or bitmap content. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:final class ColorMatrixFilter extends BitmapFilter
{
	public var matrix(get, set):Array<Float>;

	@:noCompletion private var __flightAdjustment:ColorMatrixAdjustment;
	@:noCompletion private var __matrix:Array<Float>;

	public function new(matrix:Array<Float> = null)
	{
		super();
		this.matrix = matrix;
		__numShaderPasses = 1;
		__needSecondBitmapData = false;
	}

	public override function clone():BitmapFilter
	{
		return new ColorMatrixFilter(__matrix);
	}

	@:noCompletion private override function __getFlightColorAdjustment():Adjustment
	{
		return __flightAdjustment;
	}

	@:noCompletion private function get_matrix():Array<Float>
	{
		return __matrix.copy();
	}

	@:noCompletion private function set_matrix(value:Array<Float>):Array<Float>
	{
		if (value == null)
		{
			value = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
		}
		__matrix = value;
		__flightAdjustment = __matrix.length == 20 ? FlightAdjustments.createColorMatrixAdjustment(__matrix) : null;
		return value;
	}
}
#else
typedef ColorMatrixFilter = flash.filters.ColorMatrixFilter;
#end
