package openfl.display;

#if !flash
import openfl.Vector;
import openfl.geom.Matrix;

/**
	Records the OpenFL vector drawing API. Command tessellation and rendering
	are Flight integration points.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
@:final class Graphics
{
	@:noCompletion private var __owner:DisplayObject;
	@:noCompletion private var __positionX:Float;
	@:noCompletion private var __positionY:Float;

	@:noCompletion private function new(owner:DisplayObject)
	{
		__owner = owner;
		__positionX = 0;
		__positionY = 0;
		// TODO: Create a Flight vector command buffer.
	}

	public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void {}

	public function beginFill(color:Int = 0, alpha:Float = 1):Void {}

	public function beginGradientFill(type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null,
			spreadMethod:SpreadMethod = SpreadMethod.PAD, interpolationMethod:InterpolationMethod = InterpolationMethod.RGB,
			focalPointRatio:Float = 0):Void
	{
		// TODO: Record Flight gradient fill state.
	}

	public function beginShaderFill(shader:Shader, matrix:Matrix = null):Void
	{
		// TODO: Record Flight shader fill state.
	}

	public function clear():Void
	{
		__positionX = 0;
		__positionY = 0;
		// TODO: Clear the Flight vector command buffer.
	}

	public function copyFrom(sourceGraphics:Graphics):Void
	{
		// TODO: Copy Flight vector commands.
	}

	public function cubicCurveTo(controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float):Void
	{
		__positionX = anchorX;
		__positionY = anchorY;
		// TODO: Record a Flight cubic curve command.
	}

	public function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float):Void
	{
		__positionX = anchorX;
		__positionY = anchorY;
		// TODO: Record a Flight quadratic curve command.
	}

	public function drawCircle(x:Float, y:Float, radius:Float):Void
	{
		// TODO: Record a Flight circle command.
	}

	public function drawEllipse(x:Float, y:Float, width:Float, height:Float):Void
	{
		// TODO: Record a Flight ellipse command.
	}

	public function drawGraphicsData(graphicsData:Vector<IGraphicsData>):Void
	{
		// TODO: Translate graphics data into Flight vector commands.
	}

	public function drawPath(commands:Vector<Int>, data:Vector<Float>, winding:GraphicsPathWinding = GraphicsPathWinding.EVEN_ODD):Void
	{
		// TODO: Record a Flight path command sequence.
	}

	public function drawQuads(rects:Vector<Float>, indices:Vector<Int> = null, transforms:Vector<Float> = null):Void
	{
		// TODO: Record Flight quadrilateral commands.
	}

	public function drawRect(x:Float, y:Float, width:Float, height:Float):Void
	{
		// TODO: Record a Flight rectangle command.
	}

	public function drawRoundRect(x:Float, y:Float, width:Float, height:Float, ellipseWidth:Float, ellipseHeight:Null<Float> = null):Void
	{
		// TODO: Record a Flight rounded rectangle command.
	}

	public function drawRoundRectComplex(x:Float, y:Float, width:Float, height:Float, topLeftRadius:Float, topRightRadius:Float,
			bottomLeftRadius:Float, bottomRightRadius:Float):Void
	{
		// TODO: Record a Flight complex rounded rectangle command.
	}

	public function drawTriangles(vertices:Vector<Float>, indices:Vector<Int> = null, uvtData:Vector<Float> = null,
			culling:TriangleCulling = TriangleCulling.NONE):Void
	{
		// TODO: Record Flight triangle geometry.
	}

	public function endFill():Void {}

	public function lineBitmapStyle(bitmap:BitmapData, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void
	{
		// TODO: Record Flight bitmap stroke state.
	}

	public function lineGradientStyle(type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null,
			spreadMethod:SpreadMethod = SpreadMethod.PAD, interpolationMethod:InterpolationMethod = InterpolationMethod.RGB,
			focalPointRatio:Float = 0):Void
	{
		// TODO: Record Flight gradient stroke state.
	}

	public function lineStyle(thickness:Null<Float> = null, color:Int = 0, alpha:Float = 1, pixelHinting:Bool = false,
			scaleMode:LineScaleMode = LineScaleMode.NORMAL, caps:CapsStyle = null, joints:JointStyle = null, miterLimit:Float = 3):Void
	{
		// TODO: Record Flight line style state.
	}

	public function lineTo(x:Float, y:Float):Void
	{
		__positionX = x;
		__positionY = y;
		// TODO: Record a Flight line command.
	}

	public function moveTo(x:Float, y:Float):Void
	{
		__positionX = x;
		__positionY = y;
		// TODO: Record a Flight move command.
	}

	@SuppressWarnings("checkstyle:FieldDocComment")
	@:dox(hide) @:noCompletion public function overrideBlendMode(blendMode:BlendMode):Void
	{
		// TODO (Flight): override the active vector blend mode.
	}

	public function readGraphicsData(recurse:Bool = true):Vector<IGraphicsData>
	{
		// TODO: Reconstruct graphics data from the Flight command buffer.
		return new Vector<IGraphicsData>();
	}

	@:noCompletion private function __getBounds(rect:openfl.geom.Rectangle, matrix:Matrix):Void
	{
		// TODO: Compute bounds from the Flight command buffer.
	}
}
#else
typedef Graphics = flash.display.Graphics;
#end
