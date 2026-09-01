package harness.scenarios;

import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.GraphicsBitmapFill;
import openfl.display.GraphicsEndFill;
import openfl.display.GraphicsGradientFill;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsPathCommand;
import openfl.display.GraphicsPathWinding;
import openfl.display.GraphicsQuadPath;
import openfl.display.GraphicsSolidFill;
import openfl.display.GraphicsStroke;
import openfl.display.GraphicsTrianglePath;
import openfl.display.IGraphicsData;
import openfl.display.IGraphicsFill;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.SpreadMethod;
import openfl.display.TriangleCulling;
import openfl.geom.Matrix;

class GraphicsDataScenario {
	public static function run():Dynamic {
		return {
			defaults: captureDefaults(),
			values: captureValues(),
			mutations: captureMutations(),
			pathMethods: capturePathMethods(),
			commands: {
				noOp: GraphicsPathCommand.NO_OP,
				moveTo: GraphicsPathCommand.MOVE_TO,
				lineTo: GraphicsPathCommand.LINE_TO,
				curveTo: GraphicsPathCommand.CURVE_TO,
				wideMoveTo: GraphicsPathCommand.WIDE_MOVE_TO,
				wideLineTo: GraphicsPathCommand.WIDE_LINE_TO,
				cubicCurveTo: GraphicsPathCommand.CUBIC_CURVE_TO
			}
		};
	}

	private static function captureDefaults():Dynamic {
		var bitmap = new GraphicsBitmapFill();
		var gradient = new GraphicsGradientFill();
		var path = new GraphicsPath();
		var quad = new GraphicsQuadPath();
		var solid = new GraphicsSolidFill();
		var stroke = new GraphicsStroke();
		var triangle = new GraphicsTrianglePath();
		var end = new GraphicsEndFill();
		var data:Array<IGraphicsData> = [bitmap, gradient, path, quad, solid, stroke, triangle, end];
		var fills:Array<IGraphicsFill> = [bitmap, gradient, solid, end];

		return {
			bitmap: captureBitmap(bitmap),
			gradient: captureGradient(gradient),
			path: capturePath(path),
			quad: captureQuad(quad),
			solid: captureSolid(solid),
			stroke: captureStroke(stroke),
			triangle: captureTriangle(triangle),
			interfaceDataCount: data.length,
			interfaceFillCount: fills.length
		};
	}

	private static function captureValues():Dynamic {
		var bitmapData = new BitmapData(2, 3, false, 0x123456);
		var bitmapMatrix = new Matrix(1, 2, 3, 4, 5, 6);
		var bitmap = new GraphicsBitmapFill(bitmapData, bitmapMatrix, false, true);

		var colors = [0x123456, 0xABCDEF];
		var alphas = [0.25, 0.75];
		var ratios = [10, 240];
		var gradientMatrix = new Matrix(2, 0, 0, 3, 4, 5);
		var gradient = new GraphicsGradientFill(GradientType.RADIAL, colors, alphas, ratios, gradientMatrix, SpreadMethod.REFLECT,
			InterpolationMethod.LINEAR_RGB, -0.75);

		var commands = Vector.ofArray([GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO]);
		var pathData = Vector.ofArray([1.0, 2, 3, 4]);
		var path = new GraphicsPath(commands, pathData, GraphicsPathWinding.NON_ZERO);
		var rects = Vector.ofArray([1.0, 2, 30, 40, 5, 6, 70, 80]);
		var quadIndices = Vector.ofArray([1, 0]);
		var transforms = Vector.ofArray([2.0, 3, 4, 5]);
		var quad = new GraphicsQuadPath(rects, quadIndices, transforms);
		var solid = new GraphicsSolidFill(0x234567, 0.4);
		var stroke = new GraphicsStroke(5.5, true, LineScaleMode.HORIZONTAL, CapsStyle.SQUARE, JointStyle.MITER, 7, solid);
		var vertices = Vector.ofArray([0.0, 0, 10, 0, 0, 10]);
		var triangleIndices = Vector.ofArray([0, 1, 2]);
		var uvt = Vector.ofArray([0.0, 0, 1, 0, 0, 1]);
		var triangle = new GraphicsTrianglePath(vertices, triangleIndices, uvt, TriangleCulling.POSITIVE);

		return {
			bitmap: captureBitmap(bitmap),
			bitmapReferences: {bitmap: bitmap.bitmapData == bitmapData, matrix: bitmap.matrix == bitmapMatrix},
			gradient: captureGradient(gradient),
			gradientReferences: {
				colors: gradient.colors == colors,
				alphas: gradient.alphas == alphas,
				ratios: gradient.ratios == ratios,
				matrix: gradient.matrix == gradientMatrix
			},
			path: capturePath(path),
			pathReferences: {commands: path.commands == commands, data: path.data == pathData},
			quad: captureQuad(quad),
			quadReferences: {rects: quad.rects == rects, indices: quad.indices == quadIndices, transforms: quad.transforms == transforms},
			solid: captureSolid(solid),
			stroke: captureStroke(stroke),
			strokeFillSameReference: stroke.fill == solid,
			triangle: captureTriangle(triangle),
			triangleReferences: {vertices: triangle.vertices == vertices, indices: triangle.indices == triangleIndices, uvt: triangle.uvtData == uvt}
		};
	}

	private static function captureMutations():Dynamic {
		var bitmap = new GraphicsBitmapFill();
		bitmap.bitmapData = new BitmapData(4, 5);
		bitmap.matrix = new Matrix(2, 1, 0, 3, -4, 6);
		bitmap.repeat = false;
		bitmap.smooth = true;

		var gradient = new GraphicsGradientFill();
		gradient.type = GradientType.RADIAL;
		gradient.colors = [1, 2, 3];
		gradient.alphas = [-1, 0.5, 2];
		gradient.ratios = [-10, 128, 300];
		gradient.matrix = new Matrix();
		gradient.spreadMethod = SpreadMethod.REPEAT;
		gradient.interpolationMethod = InterpolationMethod.LINEAR_RGB;
		gradient.focalPointRatio = 2;

		var solid = new GraphicsSolidFill();
		solid.color = 0xFEDCBA;
		solid.alpha = -0.25;

		var stroke = new GraphicsStroke();
		stroke.thickness = -10;
		stroke.pixelHinting = true;
		stroke.scaleMode = LineScaleMode.NONE;
		stroke.caps = CapsStyle.ROUND;
		stroke.joints = JointStyle.BEVEL;
		stroke.miterLimit = 300;
		stroke.fill = solid;

		var triangle = new GraphicsTrianglePath();
		triangle.vertices = Vector.ofArray([1.0, 2, 3, 4, 5, 6]);
		triangle.indices = Vector.ofArray([2, 1, 0]);
		triangle.uvtData = Vector.ofArray([0.1, 0.2, 0.3, 0.4, 0.5, 0.6]);
		triangle.culling = TriangleCulling.NEGATIVE;

		return {
			bitmap: captureBitmap(bitmap),
			gradient: captureGradient(gradient),
			solid: captureSolid(solid),
			stroke: captureStroke(stroke),
			triangle: captureTriangle(triangle)
		};
	}

	private static function capturePathMethods():Dynamic {
		var path = new GraphicsPath();
		path.moveTo(1, 2);
		path.lineTo(3, 4);
		path.curveTo(5, 6, 7, 8);
		path.cubicCurveTo(9, 10, 11, 12, 13, 14);
		path.wideMoveTo(15, 16);
		path.wideLineTo(17, 18);
		return capturePath(path);
	}

	private static function captureBitmap(value:GraphicsBitmapFill):Dynamic {
		return {
			bitmapWidth: value.bitmapData == null ? null : value.bitmapData.width,
			bitmapHeight: value.bitmapData == null ? null : value.bitmapData.height,
			matrix: captureMatrix(value.matrix),
			repeat: value.repeat,
			smooth: value.smooth
		};
	}

	private static function captureGradient(value:GraphicsGradientFill):Dynamic {
		return {
			type: value.type,
			colors: value.colors,
			alphas: value.alphas,
			ratios: value.ratios,
			matrix: captureMatrix(value.matrix),
			spreadMethod: value.spreadMethod,
			interpolationMethod: value.interpolationMethod,
			focalPointRatio: value.focalPointRatio
		};
	}

	private static function capturePath(value:GraphicsPath):Dynamic {
		return {commands: vectorInts(value.commands), data: vectorFloats(value.data), winding: value.winding};
	}

	private static function captureQuad(value:GraphicsQuadPath):Dynamic {
		return {rects: vectorFloats(value.rects), indices: vectorInts(value.indices), transforms: vectorFloats(value.transforms)};
	}

	private static function captureSolid(value:GraphicsSolidFill):Dynamic return {color: value.color, alpha: value.alpha};

	private static function captureStroke(value:GraphicsStroke):Dynamic {
		return {
			thicknessIsNaN: Math.isNaN(value.thickness),
			thickness: Math.isNaN(value.thickness) ? null : value.thickness,
			pixelHinting: value.pixelHinting,
			scaleMode: value.scaleMode,
			caps: value.caps,
			joints: value.joints,
			miterLimit: value.miterLimit,
			fillIsNull: value.fill == null,
			fill: Std.isOfType(value.fill, GraphicsSolidFill) ? captureSolid(cast value.fill) : null
		};
	}

	private static function captureTriangle(value:GraphicsTrianglePath):Dynamic {
		return {
			vertices: vectorFloats(value.vertices),
			indices: vectorInts(value.indices),
			uvtData: vectorFloats(value.uvtData),
			culling: value.culling
		};
	}

	private static function captureMatrix(value:Matrix):Dynamic {
		return value == null ? null : {a: value.a, b: value.b, c: value.c, d: value.d, tx: value.tx, ty: value.ty};
	}

	private static function vectorInts(value:Vector<Int>):Array<Int> return value == null ? null : [for (item in value) item];
	private static function vectorFloats(value:Vector<Float>):Array<Float> return value == null ? null : [for (item in value) item];
}
