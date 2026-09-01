package openfl.display;

#if !flash
import flight.Geometry as FlightGeometry;
import flight.Interaction as FlightInteraction;
import flight.Node as FlightNode;
import flight.Path as FlightPath;
import flight.Shape as FlightShape;
import flight.types.Path as FlightPathData;
import flight.types.Shape as FlightShapeData;
import openfl.Vector;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

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
	@:noCompletion private var __fillActive:Bool;
	@:noCompletion private var __flightPath:FlightPathData;
	@:noCompletion private var __flightShape:FlightShapeData;
	@:noCompletion private var __lineBounds:Rectangle;
	@:noCompletion private var __strokePadding:Float;

	@:noCompletion private function new(owner:DisplayObject)
	{
		__owner = owner;
		__positionX = 0;
		__positionY = 0;
		__fillActive = false;
		__strokePadding = 0;
		FlightShape.registerDefaultShapeBoundsCommands();
		FlightInteraction.registerDefaultHitTests();
		FlightInteraction.registerShapeHitTest();
		__flightPath = FlightPath.createPath();
		__flightShape = FlightShape.createShape();
		FlightNode.addNodeChildAt(owner.__flightNode, __flightShape, 0);
	}

	public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void {}

	public function beginFill(color:Int = 0, alpha:Float = 1):Void
	{
		if (__fillActive) FlightPath.appendPathClose(__flightPath);
		__fillActive = true;
		FlightShape.appendShapeBeginFill(__flightShape, color & 0xFFFFFF, alpha);
		__invalidate();
	}

	public function beginGradientFill(type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null,
			spreadMethod:SpreadMethod = SpreadMethod.PAD, interpolationMethod:InterpolationMethod = InterpolationMethod.RGB,
			focalPointRatio:Float = 0):Void
	{
		if (__fillActive) FlightPath.appendPathClose(__flightPath);
		__fillActive = true;
		FlightShape.appendShapeBeginGradientFill(__flightShape, cast type, __colorsToFloat(colors), alphas, __colorsToFloat(ratios), cast matrix,
			cast spreadMethod, cast interpolationMethod, focalPointRatio);
		__invalidate();
	}

	public function beginShaderFill(shader:Shader, matrix:Matrix = null):Void
	{
		// TODO: Record Flight shader fill state.
	}

	public function clear():Void
	{
		__positionX = 0;
		__positionY = 0;
		__fillActive = false;
		__flightPath = FlightPath.createPath();
		__lineBounds = null;
		__strokePadding = 0;
		FlightShape.clearShapeCommands(__flightShape);
		__invalidate();
	}

	public function copyFrom(sourceGraphics:Graphics):Void
	{
		if (sourceGraphics == null) return;
		FlightPath.copyPath(sourceGraphics.__flightPath, __flightPath);
		FlightShape.copyShapeCommands(__flightShape, sourceGraphics.__flightShape);
		__positionX = sourceGraphics.__positionX;
		__positionY = sourceGraphics.__positionY;
		__fillActive = sourceGraphics.__fillActive;
		__lineBounds = sourceGraphics.__lineBounds == null ? null : sourceGraphics.__lineBounds.clone();
		__strokePadding = sourceGraphics.__strokePadding;
		__invalidate();
	}

	public function cubicCurveTo(controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float):Void
	{
		FlightPath.appendPathCubicCurveTo(__flightPath, controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
		__positionX = anchorX;
		__positionY = anchorY;
		FlightShape.appendShapeCubicCurveTo(__flightShape, controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
		__invalidate();
	}

	public function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float):Void
	{
		FlightPath.appendPathCurveTo(__flightPath, controlX, controlY, anchorX, anchorY);
		__positionX = anchorX;
		__positionY = anchorY;
		FlightShape.appendShapeCurveTo(__flightShape, controlX, controlY, anchorX, anchorY);
		__invalidate();
	}

	public function drawCircle(x:Float, y:Float, radius:Float):Void
	{
		FlightPath.appendPathCircle(__flightPath, x, y, radius);
		FlightShape.appendShapeCircle(__flightShape, x, y, radius);
		__invalidate();
	}

	public function drawEllipse(x:Float, y:Float, width:Float, height:Float):Void
	{
		FlightPath.appendPathEllipse(__flightPath, x + width / 2, y + height / 2, width / 2, height / 2);
		FlightShape.appendShapeEllipse(__flightShape, x, y, width, height);
		__invalidate();
	}

	public function drawGraphicsData(graphicsData:Vector<IGraphicsData>):Void
	{
		// TODO: Translate graphics data into Flight vector commands.
	}

	public function drawPath(commands:Vector<Int>, data:Vector<Float>, winding:GraphicsPathWinding = GraphicsPathWinding.EVEN_ODD):Void
	{
		if (commands == null || data == null) return;
		FlightShape.appendShapePath(__flightShape, __colorsToFloat(commands), __vectorToArray(data), cast winding);
		__invalidate();
	}

	public function drawQuads(rects:Vector<Float>, indices:Vector<Int> = null, transforms:Vector<Float> = null):Void
	{
		// TODO: Record Flight quadrilateral commands.
	}

	public function drawRect(x:Float, y:Float, width:Float, height:Float):Void
	{
		if (width == 0 && height == 0) return;
		FlightPath.appendPathRectangle(__flightPath, x, y, width, height);
		FlightShape.appendShapeRectangle(__flightShape, x, y, width, height);
		__invalidate();
	}

	public function drawRoundRect(x:Float, y:Float, width:Float, height:Float, ellipseWidth:Float, ellipseHeight:Null<Float> = null):Void
	{
		FlightPath.appendPathRoundRectangle(__flightPath, x, y, width, height, ellipseWidth / 2);
		FlightShape.appendShapeRoundRectangle(__flightShape, x, y, width, height, ellipseWidth, ellipseHeight == null ? ellipseWidth : ellipseHeight);
		__invalidate();
	}

	public function drawRoundRectComplex(x:Float, y:Float, width:Float, height:Float, topLeftRadius:Float, topRightRadius:Float,
			bottomLeftRadius:Float, bottomRightRadius:Float):Void
	{
		FlightPath.appendPathRoundRectangle(__flightPath, x, y, width, height,
			cast [topLeftRadius, topRightRadius, bottomRightRadius, bottomLeftRadius]);
		FlightShape.appendShapeRoundRectangleVarying(__flightShape, x, y, width, height, topLeftRadius, topRightRadius, bottomLeftRadius,
			bottomRightRadius);
		__invalidate();
	}

	public function drawTriangles(vertices:Vector<Float>, indices:Vector<Int> = null, uvtData:Vector<Float> = null,
			culling:TriangleCulling = TriangleCulling.NONE):Void
	{
		if (vertices == null) return;
		FlightShape.appendShapeDrawTriangles(__flightShape, __vectorToArray(vertices), __colorsToFloat(indices), __vectorToArray(uvtData), cast culling);
		__invalidate();
	}

	public function endFill():Void
	{
		if (__fillActive) FlightPath.appendPathClose(__flightPath);
		__fillActive = false;
		FlightShape.appendShapeEndFill(__flightShape);
		__invalidate();
	}

	public function lineBitmapStyle(bitmap:BitmapData, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void
	{
		// TODO: Record Flight bitmap stroke state.
	}

	public function lineGradientStyle(type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null,
			spreadMethod:SpreadMethod = SpreadMethod.PAD, interpolationMethod:InterpolationMethod = InterpolationMethod.RGB,
			focalPointRatio:Float = 0):Void
	{
		FlightShape.appendShapeLineGradientStyle(__flightShape, cast type, __colorsToFloat(colors), alphas, __colorsToFloat(ratios), cast matrix,
			cast spreadMethod, cast interpolationMethod, focalPointRatio);
		__invalidate();
	}

	public function lineStyle(thickness:Null<Float> = null, color:Int = 0, alpha:Float = 1, pixelHinting:Bool = false,
			scaleMode:LineScaleMode = LineScaleMode.NORMAL, caps:CapsStyle = null, joints:JointStyle = null, miterLimit:Float = 3):Void
	{
		if (caps == null) caps = CapsStyle.ROUND;
		if (joints == null) joints = JointStyle.ROUND;
		if (thickness != null)
		{
			var padding = joints == JointStyle.MITER ? Math.ceil(thickness) : Math.ceil(thickness / 2);
			if (padding > __strokePadding) __strokePadding = padding;
		}
		FlightShape.appendShapeLineStyle(__flightShape, thickness, color & 0xFFFFFF, alpha, pixelHinting, cast scaleMode, cast caps, cast joints,
			miterLimit);
		__invalidate();
	}

	public function lineTo(x:Float, y:Float):Void
	{
		if (__strokePadding > 0)
		{
			__inflateLineBounds(__positionX - __strokePadding, __positionY - __strokePadding);
			__inflateLineBounds(__positionX + __strokePadding, __positionY + __strokePadding);
			__inflateLineBounds(x - __strokePadding, y - __strokePadding);
			__inflateLineBounds(x + __strokePadding * 2, y + __strokePadding);
		}
		FlightPath.appendPathLineTo(__flightPath, x, y);
		__positionX = x;
		__positionY = y;
		FlightShape.appendShapeLineTo(__flightShape, x, y);
		__invalidate();
	}

	public function moveTo(x:Float, y:Float):Void
	{
		FlightPath.appendPathMoveTo(__flightPath, x, y);
		__positionX = x;
		__positionY = y;
		FlightShape.appendShapeMoveTo(__flightShape, x, y);
		__invalidate();
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

	@:noCompletion private function __getBounds(rect:Rectangle, matrix:Matrix, includeStroke:Bool = true):Void
	{
		var bounds = FlightGeometry.createRectangle();
		if (!FlightPath.getPathBounds(__flightPath, bounds)) return;
		if (includeStroke && __strokePadding > 0)
		{
			bounds.x -= __strokePadding;
			bounds.y -= __strokePadding;
			bounds.width += __strokePadding * 2;
			bounds.height += __strokePadding * 2;
		}
		var transformed = DisplayObject.__transformRectangle(new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height), matrix);
		rect.copyFrom(transformed);
		if (includeStroke && __lineBounds != null)
		{
			var transformedLine = DisplayObject.__transformRectangle(__lineBounds, matrix);
			rect.copyFrom(rect.union(transformedLine));
		}
	}

	@:noCompletion private function __hitTest(x:Float, y:Float, shapeFlag:Bool):Bool
	{
		return FlightInteraction.hitTestNodeRegion(__flightShape, x, y, shapeFlag);
	}

	@:noCompletion private function __invalidate():Void
	{
		__owner.__setRenderDirty();
	}

	@:noCompletion private function __inflateLineBounds(x:Float, y:Float):Void
	{
		if (__lineBounds == null)
		{
			__lineBounds = new Rectangle(x, y, 0, 0);
		}
		else
		{
			var minX = Math.min(__lineBounds.x, x);
			var minY = Math.min(__lineBounds.y, y);
			var maxX = Math.max(__lineBounds.right, x);
			var maxY = Math.max(__lineBounds.bottom, y);
			__lineBounds.setTo(minX, minY, maxX - minX, maxY - minY);
		}
	}

	@:noCompletion private static function __colorsToFloat(values:Dynamic):Array<Float>
	{
		if (values == null) return null;
		var result:Array<Float> = [];
		for (i in 0...values.length) result.push(values[i]);
		return result;
	}

	@:noCompletion private static function __vectorToArray(values:Vector<Float>):Array<Float>
	{
		if (values == null) return null;
		return [for (i in 0...values.length) values[i]];
	}
}
#else
typedef Graphics = flash.display.Graphics;
#end
