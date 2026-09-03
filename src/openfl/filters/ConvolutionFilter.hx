package openfl.filters;

#if !flash
import flight.Effects as FlightEffects;

/** Applies a matrix convolution to display or bitmap content. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class ConvolutionFilter extends BitmapFilter
{
	public var alpha:Float;
	public var bias:Float;
	public var clamp:Bool;
	public var color:Int;
	public var divisor:Float;
	public var matrix(get, set):Array<Float>;
	public var matrixX:Int;
	public var matrixY:Int;
	public var preserveAlpha:Bool;

	@:noCompletion private var __matrix:Array<Float>;

	public function new(matrixX:Int = 0, matrixY:Int = 0, matrix:Array<Float> = null, divisor:Float = 1.0, bias:Float = 0.0, preserveAlpha:Bool = true,
			clamp:Bool = true, color:Int = 0, alpha:Float = 0.0)
	{
		super();
		this.matrixX = matrixX;
		this.matrixY = matrixY;
		__matrix = matrix;
		this.divisor = divisor;
		this.bias = bias;
		this.preserveAlpha = preserveAlpha;
		this.clamp = clamp;
		this.color = color;
		this.alpha = alpha;
		__numShaderPasses = 1;
		__syncFlightEffect();
	}

	public override function clone():BitmapFilter
	{
		return new ConvolutionFilter(matrixX, matrixY, __matrix, divisor, bias, preserveAlpha, clamp, color, alpha);
	}

	@:noCompletion private override function __syncFlightEffect():Void
	{
		if (__matrix == null || __matrix.length < 9)
		{
			__flightEffect = null;
			return;
		}
		__flightEffect = FlightEffects.createConvolutionEffect({
			matrixX: 3,
			matrixY: 3,
			matrix: __matrix.slice(0, 9),
			divisor: divisor,
			bias: bias,
			preserveAlpha: preserveAlpha,
			clamp: clamp,
			color: BitmapFilter.__flightColor(color)
		});
	}

	@:noCompletion private inline function get_matrix():Array<Float> return __matrix;
	@:noCompletion private function set_matrix(value:Array<Float>):Array<Float>
	{
		if (value == null) value = [0, 0, 0, 0, 1, 0, 0, 0, 0];
		if (value.length != 9) throw "Only a 3x3 matrix is supported";
		__matrix = value;
		__syncFlightEffect();
		return value;
	}
}
#else
typedef ConvolutionFilter = flash.filters.ConvolutionFilter;
#end
