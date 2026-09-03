package harness.scenarios;

import openfl.display.BitmapDataChannel;
import openfl.display.BlendMode;
import openfl.display.CapsStyle;
import openfl.display.FocusDirection;
import openfl.display.GradientType;
import openfl.display.GraphicsPathCommand;
import openfl.display.GraphicsPathWinding;
import openfl.display.InterpolationMethod;
import openfl.display.JPEGEncoderOptions;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.NativeWindowDisplayState;
import openfl.display.NativeWindowSystemChrome;
import openfl.display.NativeWindowType;
import openfl.display.PNGEncoderOptions;
import openfl.display.PixelSnapping;
import openfl.display.ShaderParameterType;
import openfl.display.ShaderPrecision;
import openfl.display.SpreadMethod;
import openfl.display.StageAlign;
import openfl.display.StageDisplayState;
import openfl.display.StageOrientation;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import openfl.display.TriangleCulling;

class DisplayValueScenario
{
	public static function run():Dynamic
	{
		var jpeg = new JPEGEncoderOptions();
		var png = new PNGEncoderOptions();
		var encoderDefaults = {jpegQuality: jpeg.quality, pngFastCompression: png.fastCompression};
		jpeg.quality = -17;
		png.fastCompression = true;

		return {
			constants: {
				bitmapDataChannel: [BitmapDataChannel.RED, BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA],
				blendMode: strings([
					BlendMode.ADD, BlendMode.ALPHA, BlendMode.DARKEN, BlendMode.DIFFERENCE, BlendMode.ERASE,
					BlendMode.HARDLIGHT, BlendMode.INVERT, BlendMode.LAYER, BlendMode.LIGHTEN, BlendMode.MULTIPLY,
					BlendMode.NORMAL, BlendMode.OVERLAY, BlendMode.SCREEN, BlendMode.SHADER, BlendMode.SUBTRACT
				]),
				capsStyle: strings([CapsStyle.NONE, CapsStyle.ROUND, CapsStyle.SQUARE]),
				focusDirection: strings([FocusDirection.BOTTOM, FocusDirection.NONE, FocusDirection.TOP]),
				gradientType: strings([GradientType.LINEAR, GradientType.RADIAL]),
				graphicsPathCommand: [
					GraphicsPathCommand.NO_OP, GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO,
					GraphicsPathCommand.CURVE_TO, GraphicsPathCommand.WIDE_MOVE_TO, GraphicsPathCommand.WIDE_LINE_TO,
					GraphicsPathCommand.CUBIC_CURVE_TO
				],
				graphicsPathWinding: strings([GraphicsPathWinding.EVEN_ODD, GraphicsPathWinding.NON_ZERO]),
				interpolationMethod: strings([InterpolationMethod.LINEAR_RGB, InterpolationMethod.RGB]),
				jointStyle: strings([JointStyle.BEVEL, JointStyle.MITER, JointStyle.ROUND]),
				lineScaleMode: strings([LineScaleMode.HORIZONTAL, LineScaleMode.NONE, LineScaleMode.NORMAL, LineScaleMode.VERTICAL]),
				nativeWindowDisplayState: strings([
					NativeWindowDisplayState.NORMAL, NativeWindowDisplayState.MAXIMIZED, NativeWindowDisplayState.MINIMIZED
				]),
				nativeWindowSystemChrome: strings([
					NativeWindowSystemChrome.ALTERNATE, NativeWindowSystemChrome.NONE, NativeWindowSystemChrome.STANDARD
				]),
				nativeWindowType: strings([NativeWindowType.LIGHTWEIGHT, NativeWindowType.NORMAL, NativeWindowType.UTILITY]),
				pixelSnapping: strings([PixelSnapping.ALWAYS, PixelSnapping.AUTO, PixelSnapping.NEVER]),
				shaderParameterType: strings([
					ShaderParameterType.BOOL, ShaderParameterType.BOOL2, ShaderParameterType.BOOL3, ShaderParameterType.BOOL4,
					ShaderParameterType.FLOAT, ShaderParameterType.FLOAT2, ShaderParameterType.FLOAT3, ShaderParameterType.FLOAT4,
					ShaderParameterType.INT, ShaderParameterType.INT2, ShaderParameterType.INT3, ShaderParameterType.INT4,
					ShaderParameterType.MATRIX2X2, ShaderParameterType.MATRIX2X3, ShaderParameterType.MATRIX2X4,
					ShaderParameterType.MATRIX3X2, ShaderParameterType.MATRIX3X3, ShaderParameterType.MATRIX3X4,
					ShaderParameterType.MATRIX4X2, ShaderParameterType.MATRIX4X3, ShaderParameterType.MATRIX4X4
				]),
				shaderPrecision: strings([ShaderPrecision.FAST, ShaderPrecision.FULL]),
				spreadMethod: strings([SpreadMethod.PAD, SpreadMethod.REFLECT, SpreadMethod.REPEAT]),
				stageAlign: strings([
					StageAlign.BOTTOM, StageAlign.BOTTOM_LEFT, StageAlign.BOTTOM_RIGHT, StageAlign.LEFT,
					StageAlign.RIGHT, StageAlign.TOP, StageAlign.TOP_LEFT, StageAlign.TOP_RIGHT
				]),
				stageDisplayState: strings([
					StageDisplayState.FULL_SCREEN, StageDisplayState.FULL_SCREEN_INTERACTIVE, StageDisplayState.NORMAL
				]),
				stageOrientation: strings([
					StageOrientation.DEFAULT, StageOrientation.ROTATED_LEFT, StageOrientation.ROTATED_RIGHT,
					StageOrientation.UNKNOWN, StageOrientation.UPSIDE_DOWN
				]),
				stageQuality: strings([StageQuality.BEST, StageQuality.HIGH, StageQuality.LOW, StageQuality.MEDIUM]),
				stageScaleMode: strings([
					StageScaleMode.EXACT_FIT, StageScaleMode.NO_BORDER, StageScaleMode.NO_SCALE, StageScaleMode.SHOW_ALL
				]),
				triangleCulling: strings([TriangleCulling.NEGATIVE, TriangleCulling.NONE, TriangleCulling.POSITIVE])
			},
			conversions: testConversions(),
			encoders: {
				defaults: encoderDefaults,
				mutated: {jpegQuality: jpeg.quality, pngFastCompression: png.fastCompression},
				constructorValues: {
					jpegQuality: new JPEGEncoderOptions(101).quality,
					pngFastCompression: new PNGEncoderOptions(true).fastCompression
				}
			}
		};
	}

	private static function testConversions():Dynamic
	{
		var blendUnknown:BlendMode = "unknown";
		var capsUnknown:CapsStyle = "unknown";
		var focusUnknown:FocusDirection = "unknown";
		var gradientUnknown:GradientType = "unknown";
		var windingUnknown:GraphicsPathWinding = "unknown";
		var interpolationUnknown:InterpolationMethod = "unknown";
		var jointUnknown:JointStyle = "unknown";
		var lineScaleUnknown:LineScaleMode = "unknown";
		var windowStateUnknown:NativeWindowDisplayState = "unknown";
		var windowChromeUnknown:NativeWindowSystemChrome = "unknown";
		var windowTypeUnknown:NativeWindowType = "unknown";
		var pixelUnknown:PixelSnapping = "unknown";
		var parameterUnknown:ShaderParameterType = "unknown";
		var precisionUnknown:ShaderPrecision = "unknown";
		var spreadUnknown:SpreadMethod = "unknown";
		var alignUnknown:StageAlign = "unknown";
		var displayStateUnknown:StageDisplayState = "unknown";
		var orientationUnknown:StageOrientation = "invalid";
		var qualityUnknown:StageQuality = "unknown";
		var scaleUnknown:StageScaleMode = "unknown";
		var cullingUnknown:TriangleCulling = "unknown";
		var unusualAlign:StageAlign = "bottom-and-right";
		var upperBlend:BlendMode = "ADD";
		var upperCaps:CapsStyle = "ROUND";

		return {
			unknownStringsBecomeNull: [
				blendUnknown == null, capsUnknown == null, focusUnknown == null, gradientUnknown == null,
				windingUnknown == null, interpolationUnknown == null, jointUnknown == null, lineScaleUnknown == null,
				windowStateUnknown == null, windowChromeUnknown == null, windowTypeUnknown == null, pixelUnknown == null,
				parameterUnknown == null, precisionUnknown == null, spreadUnknown == null, alignUnknown == null,
				displayStateUnknown == null, orientationUnknown == null, qualityUnknown == null, scaleUnknown == null,
				cullingUnknown == null
			],
			caseSensitive: {
				blend: stringValue(upperBlend),
				caps: stringValue(upperCaps)
			},
			stageAlignNormalizesCharacters: Std.string(unusualAlign)
		};
	}

	private static function strings(values:Array<Dynamic>):Array<String>
	{
		return [for (value in values) Std.string(value)];
	}

	private static function stringValue(value:Dynamic):Dynamic
	{
		return value == null ? null : Std.string(value);
	}
}
