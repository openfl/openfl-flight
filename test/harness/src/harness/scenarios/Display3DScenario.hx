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
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.Program3D;
import openfl.display3D.VertexBuffer3D;
import openfl.display3D.textures.CubeTexture;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.display3D.textures.VideoTexture;
import openfl.events.ErrorEvent;
import openfl.events.Event;
#if harness_capture
import lime.graphics.RenderContextType;
#end

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
		var acquisition = captureAcquisition(stage, stage.stage3Ds[2]);
		var context = createContext(stage);
		var contextDefaults = captureContext(context);
		#if harness_capture
		Reflect.setField(context, "__enableErrorChecking", true);
		Reflect.setField(context, "backBufferWidth", 96);
		Reflect.setField(context, "backBufferHeight", 48);
		#else
		context.enableErrorChecking = true;
		context.configureBackBuffer(96, 48, 2, false, true, true);
		#end
		var resources = captureResources(context);

		return {
			stage3D: {
				count: stage.stage3Ds.length,
				distinct: first != second,
				defaults: defaults,
				values: captureStage3D(first)
			},
			context: {
				supportsVideoTexture: Context3D.supportsVideoTexture,
				defaults: contextDefaults,
				configured: captureContext(context),
				resources: resources
			},
			acquisition: acquisition,
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

	private static function captureAcquisition(stage:Stage, stage3D:Stage3D):Dynamic {
		var events:Array<String> = [];
		stage3D.addEventListener(Event.CONTEXT3D_CREATE, function(_) events.push(Event.CONTEXT3D_CREATE));
		stage3D.addEventListener(ErrorEvent.ERROR, function(event:ErrorEvent) events.push('${event.type}:${event.text}'));

		#if harness_capture
		var renderer:Dynamic = Type.createEmptyInstance(openfl.display.CairoRenderer);
		Reflect.setField(renderer, "__type", RenderContextType.CAIRO);
		Reflect.setField(stage, "__renderer", renderer);
		#end
		stage3D.requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.STANDARD);
		pumpUntil(function() return events.length == 1);
		var firstRequest = {
			contextIsNull: stage3D.context3D == null,
			events: events.copy()
		};
		stage3D.requestContext3DMatchingProfiles(new openfl.Vector<Context3DProfile>([
			Context3DProfile.STANDARD_EXTENDED,
			Context3DProfile.BASELINE
		]));
		pumpUntil(function() return events.length == 2);

		return {
			firstRequest: firstRequest,
			matchingProfiles: {
				contextIsNull: stage3D.context3D == null,
				events: events
			}
		};
	}

	private static function pumpUntil(done:Void->Bool):Void {
		var deadline = haxe.Timer.stamp() + 1;
		while (!done()) {
			if (haxe.Timer.stamp() >= deadline) throw "Stage3D request timed out";
			Sys.sleep(0.002);
			#if target.threaded
			sys.thread.Thread.current().events.progress();
			#end
			@:privateAccess haxe.MainLoop.tick();
		}
	}

	private static function captureContext(context:Context3D):Dynamic {
		return {
			backBufferHeight: context.backBufferHeight,
			backBufferWidth: context.backBufferWidth,
			driverInfoIsOpenGL: context.driverInfo != null && StringTools.startsWith(context.driverInfo, "OpenGL"),
			enableErrorChecking: context.enableErrorChecking,
			profile: Std.string(context.profile),
			totalGPUMemory: context.totalGPUMemory
		};
	}

	private static function captureResources(context:Context3D):Dynamic {
		var program:Program3D;
		var glslProgram:Program3D;
		var indexBuffer:IndexBuffer3D;
		var vertexBuffer:VertexBuffer3D;
		var texture:Texture;
		var cubeTexture:CubeTexture;
		var rectangleTexture:RectangleTexture;
		var videoTexture:VideoTexture;
		#if harness_capture
		// OpenFL's public factories require a live GL context. Construct typed shells
		// in capture mode so the headless oracle can still record public reads.
		program = Type.createEmptyInstance(Program3D);
		Reflect.setField(program, "__format", Context3DProgramFormat.AGAL);
		glslProgram = Type.createEmptyInstance(Program3D);
		Reflect.setField(glslProgram, "__format", Context3DProgramFormat.GLSL);
		Reflect.setField(glslProgram, "__glslAttribNames", []);
		Reflect.setField(glslProgram, "__glslUniformNames", []);
		indexBuffer = Type.createEmptyInstance(IndexBuffer3D);
		vertexBuffer = Type.createEmptyInstance(VertexBuffer3D);
		texture = Type.createEmptyInstance(Texture);
		cubeTexture = Type.createEmptyInstance(CubeTexture);
		rectangleTexture = Type.createEmptyInstance(RectangleTexture);
		videoTexture = Type.createEmptyInstance(VideoTexture);
		Reflect.setField(videoTexture, "videoHeight", 0);
		Reflect.setField(videoTexture, "videoWidth", 0);
		#else
		program = context.createProgram();
		glslProgram = context.createProgram(Context3DProgramFormat.GLSL);
		indexBuffer = context.createIndexBuffer(6, Context3DBufferUsage.DYNAMIC_DRAW);
		vertexBuffer = context.createVertexBuffer(4, 5, Context3DBufferUsage.STATIC_DRAW);
		texture = context.createTexture(8, 4, Context3DTextureFormat.BGRA, false, 1);
		cubeTexture = context.createCubeTexture(4, Context3DTextureFormat.BGRA, false, 0);
		rectangleTexture = context.createRectangleTexture(7, 3, Context3DTextureFormat.BGRA, false);
		videoTexture = context.createVideoTexture();
		#end

		return {
			program: {
				agalAttribute: program.getAttributeIndex("va3"),
				agalFragmentConstant: program.getConstantIndex("fc7"),
				agalVertexConstant: program.getConstantIndex("vc2"),
				glslMissingAttribute: glslProgram.getAttributeIndex("position"),
				glslMissingConstant: glslProgram.getConstantIndex("projection"),
				isProgram3D: Std.isOfType(program, Program3D)
			},
			buffers: {
				indexIsIndexBuffer3D: Std.isOfType(indexBuffer, IndexBuffer3D),
				vertexIsVertexBuffer3D: Std.isOfType(vertexBuffer, VertexBuffer3D)
			},
			textures: {
				cubeIsCubeTexture: Std.isOfType(cubeTexture, CubeTexture),
				rectangleIsRectangleTexture: Std.isOfType(rectangleTexture, RectangleTexture),
				textureIsTexture: Std.isOfType(texture, Texture),
				videoHeight: videoTexture.videoHeight,
				videoIsVideoTexture: Std.isOfType(videoTexture, VideoTexture),
				videoWidth: videoTexture.videoWidth
			}
		};
	}

	private static function createContext(stage:Stage):Context3D {
		#if harness_capture
		// The reference constructor dereferences a live WebGL context. Its public
		// defaults are initialized explicitly for this headless compatibility probe.
		var context:Context3D = Type.createEmptyInstance(Context3D);
		Reflect.setField(context, "backBufferHeight", 0);
		Reflect.setField(context, "backBufferWidth", 0);
		Reflect.setField(context, "driverInfo", "OpenGL (fixture)");
		Reflect.setField(context, "__enableErrorChecking", false);
		Reflect.setField(context, "profile", Context3DProfile.STANDARD);
		return context;
		#else
		return Type.createInstance(Context3D, [stage, null, null]);
		#end
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
