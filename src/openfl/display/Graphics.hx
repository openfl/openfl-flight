package openfl.display;

#if !flash
import flight.Geometry as FlightGeometry;
import flight.Interaction as FlightInteraction;
import flight.Node as FlightNode;
import flight.Path as FlightPath;
import flight.Shape as FlightShape;
import flight.Texture as FlightTexture;
import flight.types.Path as FlightPathData;
import flight.types.Shape as FlightShapeData;
import flight.types.Texture2D as FlightTextureData;
import haxe.ds.ObjectMap;
import openfl.Vector;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

private typedef GraphicsBitmapPaint =
{
	var bitmapData:BitmapData;
	var matrix:Matrix;
	var repeat:Bool;
	var smooth:Bool;
}

/**
	Records the OpenFL vector drawing API. Command tessellation and rendering
	are Flight integration points.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.display.GraphicsPath)
@:final class Graphics
{
	@:noCompletion private var __bitmapPaints:ObjectMap<{}, GraphicsBitmapPaint>;
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
		__bitmapPaints = new ObjectMap();
		FlightShape.registerDefaultShapeBoundsCommands();
		FlightInteraction.registerDefaultHitTests();
		FlightInteraction.registerShapeHitTest();
		__flightPath = FlightPath.createPath();
		__flightShape = FlightShape.createShape();
		FlightNode.addNodeChildAt(owner.__flightNode, __flightShape, 0);
	}

	public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void
	{
		var texture = __createBitmapTexture(bitmap, matrix, repeat, smooth);
		if (texture == null) return;
		if (__fillActive) FlightPath.appendPathClose(__flightPath);
		__fillActive = true;
		var paint = __bitmapPaints.get(cast texture);
		FlightShape.appendShapeBeginTextureFill(__flightShape, texture, cast paint.matrix);
		__invalidate();
	}

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
		// Flight custom shaders are render effects, not Shape paint commands.
	}

	public function clear():Void
	{
		__positionX = 0;
		__positionY = 0;
		__fillActive = false;
		__flightPath = FlightPath.createPath();
		__lineBounds = null;
		__strokePadding = 0;
		__bitmapPaints = new ObjectMap();
		FlightShape.clearShapeCommands(__flightShape);
		__invalidate();
	}

	public function copyFrom(sourceGraphics:Graphics):Void
	{
		if (sourceGraphics == null) return;
		FlightPath.copyPath(sourceGraphics.__flightPath, __flightPath);
		FlightShape.copyShapeCommands(__flightShape, sourceGraphics.__flightShape);
		__bitmapPaints = new ObjectMap();
		for (texture in sourceGraphics.__bitmapPaints.keys())
		{
			var paint = sourceGraphics.__bitmapPaints.get(texture);
			__bitmapPaints.set(texture, {
				bitmapData: paint.bitmapData,
				matrix: paint.matrix == null ? null : paint.matrix.clone(),
				repeat: paint.repeat,
				smooth: paint.smooth
			});
		}
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
		if (graphicsData == null) return;
		for (item in graphicsData)
		{
			if ((item is GraphicsSolidFill))
			{
				var fill:GraphicsSolidFill = cast item;
				beginFill(fill.color, fill.alpha);
			}
			else if ((item is GraphicsGradientFill))
			{
				var fill:GraphicsGradientFill = cast item;
				beginGradientFill(fill.type, fill.colors, fill.alphas, fill.ratios, fill.matrix, fill.spreadMethod, fill.interpolationMethod,
					fill.focalPointRatio);
			}
			else if ((item is GraphicsBitmapFill))
			{
				var fill:GraphicsBitmapFill = cast item;
				beginBitmapFill(fill.bitmapData, fill.matrix, fill.repeat, fill.smooth);
			}
			else if ((item is GraphicsStroke))
			{
				var stroke:GraphicsStroke = cast item;
				var thickness:Null<Float> = Math.isNaN(stroke.thickness) ? null : stroke.thickness;
				if ((stroke.fill is GraphicsSolidFill))
				{
					var fill:GraphicsSolidFill = cast stroke.fill;
					lineStyle(thickness, fill.color, fill.alpha, stroke.pixelHinting, stroke.scaleMode, stroke.caps, stroke.joints, stroke.miterLimit);
				}
				else
				{
					lineStyle(thickness, 0, 1, stroke.pixelHinting, stroke.scaleMode, stroke.caps, stroke.joints, stroke.miterLimit);
				}
			}
			else if ((item is GraphicsPath))
			{
				var path:GraphicsPath = cast item;
				drawPath(path.commands, path.data, path.winding);
			}
			else if ((item is GraphicsTrianglePath))
			{
				var path:GraphicsTrianglePath = cast item;
				drawTriangles(path.vertices, path.indices, path.uvtData, path.culling);
			}
			else if ((item is GraphicsQuadPath))
			{
				var path:GraphicsQuadPath = cast item;
				drawQuads(path.rects, path.indices, path.transforms);
			}
			else if ((item is GraphicsEndFill))
			{
				endFill();
			}
		}
	}

	public function drawPath(commands:Vector<Int>, data:Vector<Float>, winding:GraphicsPathWinding = GraphicsPathWinding.EVEN_ODD):Void
	{
		if (commands == null || data == null) return;
		var dataIndex = 0;
		for (command in commands)
		{
			switch (command)
			{
				case GraphicsPathCommand.MOVE_TO:
					FlightPath.appendPathMoveTo(__flightPath, data[dataIndex], data[dataIndex + 1]);
					dataIndex += 2;
				case GraphicsPathCommand.LINE_TO:
					FlightPath.appendPathLineTo(__flightPath, data[dataIndex], data[dataIndex + 1]);
					dataIndex += 2;
				case GraphicsPathCommand.CURVE_TO:
					FlightPath.appendPathCurveTo(__flightPath, data[dataIndex], data[dataIndex + 1], data[dataIndex + 2], data[dataIndex + 3]);
					dataIndex += 4;
				case GraphicsPathCommand.CUBIC_CURVE_TO:
					FlightPath.appendPathCubicCurveTo(__flightPath, data[dataIndex], data[dataIndex + 1], data[dataIndex + 2], data[dataIndex + 3],
						data[dataIndex + 4], data[dataIndex + 5]);
					dataIndex += 6;
				case GraphicsPathCommand.WIDE_MOVE_TO:
					FlightPath.appendPathMoveTo(__flightPath, data[dataIndex + 2], data[dataIndex + 3]);
					dataIndex += 4;
				case GraphicsPathCommand.WIDE_LINE_TO:
					FlightPath.appendPathLineTo(__flightPath, data[dataIndex + 2], data[dataIndex + 3]);
					dataIndex += 4;
				default:
			}
		}
		FlightShape.appendShapePath(__flightShape, __colorsToFloat(commands), __vectorToArray(data), cast winding);
		__invalidate();
	}

	public function drawQuads(rects:Vector<Float>, indices:Vector<Int> = null, transforms:Vector<Float> = null):Void
	{
		if (rects == null) return;
		var hasIndices = indices != null;
		var length = hasIndices ? indices.length : Math.floor(rects.length / 4);
		if (length == 0) return;
		var transformABCD = transforms != null && transforms.length >= length * 4;
		var transformXY = transforms != null && (transforms.length >= length * 6 || (!transformABCD && transforms.length >= length * 2));

		for (i in 0...length)
		{
			var rectIndex = (hasIndices ? indices[i] : i) * 4;
			if (rectIndex < 0 || rectIndex + 3 >= rects.length) continue;
			var width = rects[rectIndex + 2];
			var height = rects[rectIndex + 3];
			if (width <= 0 || height <= 0) continue;

			var a = 1.0;
			var b = 0.0;
			var c = 0.0;
			var d = 1.0;
			var tx = 0.0;
			var ty = 0.0;
			if (transformABCD)
			{
				var transformIndex = i * (transformXY ? 6 : 4);
				a = transforms[transformIndex];
				b = transforms[transformIndex + 1];
				c = transforms[transformIndex + 2];
				d = transforms[transformIndex + 3];
				if (transformXY)
				{
					tx = transforms[transformIndex + 4];
					ty = transforms[transformIndex + 5];
				}
			}
			else if (transformXY)
			{
				var transformIndex = i * 2;
				tx = transforms[transformIndex];
				ty = transforms[transformIndex + 1];
			}

			var points = [tx, ty, a * width + tx, b * width + ty, a * width + c * height + tx, b * width + d * height + ty,
				c * height + tx, d * height + ty];
			FlightPath.appendPathMoveTo(__flightPath, points[0], points[1]);
			FlightShape.appendShapeMoveTo(__flightShape, points[0], points[1]);
			for (point in 1...4)
			{
				FlightPath.appendPathLineTo(__flightPath, points[point * 2], points[point * 2 + 1]);
				FlightShape.appendShapeLineTo(__flightShape, points[point * 2], points[point * 2 + 1]);
			}
			FlightPath.appendPathLineTo(__flightPath, points[0], points[1]);
			FlightPath.appendPathClose(__flightPath);
			FlightShape.appendShapeLineTo(__flightShape, points[0], points[1]);
		}
		__invalidate();
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
		var texture = __createBitmapTexture(bitmap, matrix, repeat, smooth);
		if (texture == null) return;
		var paint = __bitmapPaints.get(cast texture);
		FlightShape.appendShapeLineTextureStyle(__flightShape, texture, cast paint.matrix);
		__invalidate();
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
		if (blendMode == null) blendMode = BlendMode.NORMAL;
		__flightShape.blendMode = switch (blendMode)
		{
			case BlendMode.ADD: "Add";
			case BlendMode.DARKEN: "Darken";
			case BlendMode.DIFFERENCE: "Difference";
			case BlendMode.HARDLIGHT: "HardLight";
			case BlendMode.LIGHTEN: "Lighten";
			case BlendMode.MULTIPLY: "Multiply";
			case BlendMode.OVERLAY: "Overlay";
			case BlendMode.SCREEN: "Screen";
			default: "Normal";
		};
		FlightNode.invalidateNodeAppearance(__flightShape);
	}

	public function readGraphicsData(recurse:Bool = true):Vector<IGraphicsData>
	{
		var result = new Vector<IGraphicsData>();
		var path:GraphicsPath = null;
		var commands:Array<Dynamic> = cast __flightShape.data.commands;
		var index = 0;
		var flushPath = function():Void
		{
			if (path != null)
			{
				result.push(path);
				path = null;
			}
		};

		while (index < commands.length)
		{
			var name:String = cast commands[index++];
			var count = Std.int(commands[index++]);
			var values = commands.slice(index, index + count);
			index += count;
			var geometry = name == "moveTo" || name == "lineTo" || name == "curveTo" || name == "cubicCurveTo" || name == "drawCircle"
				|| name == "drawEllipse" || name == "drawRectangle" || name == "drawRoundRectangle";
			if (geometry)
			{
				if (path == null) path = new GraphicsPath();
			}
			else
			{
				flushPath();
			}

			switch (name)
			{
				case "beginFill":
					result.push(new GraphicsSolidFill(Std.int(values[0]), values[1]));
				case "beginGradientFill":
					var colors:Array<Float> = cast values[1];
					var ratios:Array<Float> = cast values[3];
					result.push(new GraphicsGradientFill(cast values[0], [for (value in colors) Std.int(value)], cast values[2],
						[for (value in ratios) Std.int(value)], __matrix(values[4]), cast values[5], cast values[6], values[7]));
				case "beginTextureFill":
					var paint = __bitmapPaints.get(cast values[0]);
					if (paint != null)
					{
						result.push(new GraphicsBitmapFill(paint.bitmapData, paint.matrix == null ? null : paint.matrix.clone(), paint.repeat, paint.smooth));
					}
				case "lineStyle":
					var stroke = new GraphicsStroke(values[0], values[3], cast values[4], cast values[5], cast values[6], values[7]);
					stroke.fill = new GraphicsSolidFill(Std.int(values[1]), values[2]);
					result.push(stroke);
				case "endFill":
					result.push(new GraphicsEndFill());
				case "moveTo":
					path.moveTo(values[0], values[1]);
				case "lineTo":
					path.lineTo(values[0], values[1]);
				case "curveTo":
					path.curveTo(values[0], values[1], values[2], values[3]);
				case "cubicCurveTo":
					path.cubicCurveTo(values[0], values[1], values[2], values[3], values[4], values[5]);
				case "drawCircle":
					path.__drawCircle(values[0], values[1], values[2]);
				case "drawEllipse":
					path.__drawEllipse(values[0], values[1], values[2], values[3]);
				case "drawRectangle":
					path.__drawRect(values[0], values[1], values[2], values[3]);
				case "drawRoundRectangle":
					path.__drawRoundRect(values[0], values[1], values[2], values[3], values[4], values[5]);
				default:
			}
		}
		flushPath();
		return result;
	}

	@:noCompletion private static function __matrix(value:Dynamic):Matrix
	{
		return value == null ? null : new Matrix(value.a, value.b, value.c, value.d, value.tx, value.ty);
	}

	@:noCompletion private function __createBitmapTexture(bitmap:BitmapData, matrix:Matrix, repeat:Bool, smooth:Bool):FlightTextureData
	{
		if (bitmap == null || bitmap.__flightBitmap == null) return null;
		var sampler = FlightTexture.createSampler({
			magFilter: smooth ? cast "linear" : cast "nearest",
			minFilter: smooth ? cast "linear" : cast "nearest",
			mipmaps: false,
			wrapU: repeat ? cast "repeat" : cast "clamp-to-edge",
			wrapV: repeat ? cast "repeat" : cast "clamp-to-edge"
		});
		var texture = FlightTexture.createTexture2D({source: bitmap.__flightBitmap, sampler: sampler});
		__bitmapPaints.set(cast texture, {
			bitmapData: bitmap,
			matrix: matrix == null ? null : matrix.clone(),
			repeat: repeat,
			smooth: smooth
		});
		return texture;
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
