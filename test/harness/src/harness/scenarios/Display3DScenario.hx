package harness.scenarios;

import openfl.Lib;
import openfl.display.Stage;
import openfl.display.Stage3D;
import openfl.display.Window;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DBlendFactor;
import openfl.display3D.Context3DBufferUsage;
import openfl.display3D.Context3DClearMask;
import openfl.display3D.Context3DCompareMode;
import openfl.display3D.Context3DMipFilter;
import openfl.display3D.Context3DProfile;
import openfl.display3D.Context3DProgramFormat;
import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3DRenderMode;
import openfl.display3D.Context3DStencilAction;
import openfl.display3D.Context3DTextureFilter;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.Context3DTriangleFace;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.Context3DWrapMode;

class Display3DScenario {
	public static function run():Dynamic {
		var stage = createStage(320, 240);
		if (Lib.current != null && Lib.current.parent == stage) stage.removeChild(Lib.current);
		var first = stage.stage3Ds[0];
		var second = stage.stage3Ds[1];
		var defaults = captureStage3D(first);
		first.x = 12.5;
		first.y = -3.25;
		first.visible = false;

		return {
			stage3D: {
				count: stage.stage3Ds.length,
				distinct: first != second,
				defaults: defaults,
				values: captureStage3D(first)
			},
			context: {
				supportsVideoTexture: Context3D.supportsVideoTexture
			},
			clearMask: {
				all: Context3DClearMask.ALL,
				color: Context3DClearMask.COLOR,
				depth: Context3DClearMask.DEPTH,
				stencil: Context3DClearMask.STENCIL
			},
			constants: {
				blendFactor: [
					Std.string(Context3DBlendFactor.DESTINATION_ALPHA),
					Std.string(Context3DBlendFactor.DESTINATION_COLOR),
					Std.string(Context3DBlendFactor.ONE),
					Std.string(Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA),
					Std.string(Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR),
					Std.string(Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA),
					Std.string(Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR),
					Std.string(Context3DBlendFactor.SOURCE_ALPHA),
					Std.string(Context3DBlendFactor.SOURCE_COLOR),
					Std.string(Context3DBlendFactor.ZERO)
				],
				bufferUsage: [Std.string(Context3DBufferUsage.DYNAMIC_DRAW), Std.string(Context3DBufferUsage.STATIC_DRAW)],
				compareMode: [
					Std.string(Context3DCompareMode.ALWAYS),
					Std.string(Context3DCompareMode.EQUAL),
					Std.string(Context3DCompareMode.GREATER),
					Std.string(Context3DCompareMode.GREATER_EQUAL),
					Std.string(Context3DCompareMode.LESS),
					Std.string(Context3DCompareMode.LESS_EQUAL),
					Std.string(Context3DCompareMode.NEVER),
					Std.string(Context3DCompareMode.NOT_EQUAL)
				],
				mipFilter: [Std.string(Context3DMipFilter.MIPLINEAR), Std.string(Context3DMipFilter.MIPNEAREST), Std.string(Context3DMipFilter.MIPNONE)],
				profile: [
					Std.string(Context3DProfile.BASELINE),
					Std.string(Context3DProfile.BASELINE_CONSTRAINED),
					Std.string(Context3DProfile.BASELINE_EXTENDED),
					Std.string(Context3DProfile.STANDARD),
					Std.string(Context3DProfile.STANDARD_CONSTRAINED),
					Std.string(Context3DProfile.STANDARD_EXTENDED)
				],
				programFormat: [Std.string(Context3DProgramFormat.AGAL), Std.string(Context3DProgramFormat.GLSL)],
				programType: [Std.string(Context3DProgramType.FRAGMENT), Std.string(Context3DProgramType.VERTEX)],
				renderMode: [Std.string(Context3DRenderMode.AUTO), Std.string(Context3DRenderMode.SOFTWARE)],
				stencilAction: [
					Std.string(Context3DStencilAction.DECREMENT_SATURATE),
					Std.string(Context3DStencilAction.DECREMENT_WRAP),
					Std.string(Context3DStencilAction.INCREMENT_SATURATE),
					Std.string(Context3DStencilAction.INCREMENT_WRAP),
					Std.string(Context3DStencilAction.INVERT),
					Std.string(Context3DStencilAction.KEEP),
					Std.string(Context3DStencilAction.SET),
					Std.string(Context3DStencilAction.ZERO)
				],
				textureFilter: [
					Std.string(Context3DTextureFilter.ANISOTROPIC16X),
					Std.string(Context3DTextureFilter.ANISOTROPIC2X),
					Std.string(Context3DTextureFilter.ANISOTROPIC4X),
					Std.string(Context3DTextureFilter.ANISOTROPIC8X),
					Std.string(Context3DTextureFilter.LINEAR),
					Std.string(Context3DTextureFilter.NEAREST)
				],
				textureFormat: [
					Std.string(Context3DTextureFormat.BGR_PACKED),
					Std.string(Context3DTextureFormat.BGRA),
					Std.string(Context3DTextureFormat.BGRA_PACKED),
					Std.string(Context3DTextureFormat.COMPRESSED),
					Std.string(Context3DTextureFormat.COMPRESSED_ALPHA),
					Std.string(Context3DTextureFormat.RGBA_HALF_FLOAT)
				],
				triangleFace: [
					Std.string(Context3DTriangleFace.BACK),
					Std.string(Context3DTriangleFace.FRONT),
					Std.string(Context3DTriangleFace.FRONT_AND_BACK),
					Std.string(Context3DTriangleFace.NONE)
				],
				vertexBufferFormat: [
					Std.string(Context3DVertexBufferFormat.BYTES_4),
					Std.string(Context3DVertexBufferFormat.FLOAT_1),
					Std.string(Context3DVertexBufferFormat.FLOAT_2),
					Std.string(Context3DVertexBufferFormat.FLOAT_3),
					Std.string(Context3DVertexBufferFormat.FLOAT_4)
				],
				wrapMode: [
					Std.string(Context3DWrapMode.CLAMP),
					Std.string(Context3DWrapMode.CLAMP_U_REPEAT_V),
					Std.string(Context3DWrapMode.REPEAT),
					Std.string(Context3DWrapMode.REPEAT_U_CLAMP_V)
				]
			}
		};
	}

	private static function captureStage3D(stage3D:Stage3D):Dynamic {
		return {
			contextIsNull: stage3D.context3D == null,
			visible: stage3D.visible,
			x: stage3D.x,
			y: stage3D.y
		};
	}

	private static function createStage(width:Int, height:Int):Stage {
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", width);
		Reflect.setField(window, "__height", height);
		Reflect.setField(window, "__scale", 1);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = width;
		window.height = height;
		window.scale = 1;
		window.fullscreen = false;
		#end
		return new Stage(cast window, 0);
	}
}
