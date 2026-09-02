package openfl.display3D;

#if !flash
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display3D.textures.CubeTexture;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.display3D.textures.TextureBase;
import openfl.display3D.textures.VideoTexture;
import openfl.events.EventDispatcher;
import openfl.geom.Matrix3D;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

/**
	Provides the Stage3D API surface while GPU resource management and rendering
	are implemented by Flight.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display3D.textures.CubeTexture)
@:access(openfl.display3D.textures.RectangleTexture)
@:access(openfl.display3D.textures.TextureBase)
@:access(openfl.display3D.textures.Texture)
@:access(openfl.display3D.textures.VideoTexture)
@:access(openfl.display3D.IndexBuffer3D)
@:access(openfl.display3D.Program3D)
@:access(openfl.display3D.VertexBuffer3D)
@:final class Context3D extends EventDispatcher
{
	public static var supportsVideoTexture(default, null):Bool = #if (js && html5) true #else false #end;

	public var backBufferHeight(default, null):Int = 0;
	public var backBufferWidth(default, null):Int = 0;
	public var driverInfo(default, null):String = "OpenGL (Direct blitting)";
	public var enableErrorChecking(get, set):Bool;
	public var maxBackBufferHeight(default, null):Int;
	public var maxBackBufferWidth(default, null):Int;
	public var profile(default, null):Context3DProfile = STANDARD;
	public var totalGPUMemory(get, never):Int;

	@:noCompletion private var __enableErrorChecking:Bool;
	@SuppressWarnings("checkstyle:Dynamic") @:noCompletion private var gl:Dynamic;

	@:noCompletion private function new(stage:Dynamic, contextState:Dynamic = null, stage3D:Dynamic = null)
	{
		super();
		maxBackBufferHeight = 0;
		maxBackBufferWidth = 0;
	}

	public function clear(red:Float = 0, green:Float = 0, blue:Float = 0, alpha:Float = 1, depth:Float = 1, stencil:UInt = 0,
			mask:UInt = Context3DClearMask.ALL):Void
	{
		// Flight audit — blocked on GL draw seam: public render-pass lifecycle
		// calls do not expose the active render state needed to clear attachments.
	}

	public function configureBackBuffer(width:Int, height:Int, antiAlias:Int, enableDepthAndStencil:Bool = true, wantsBestResolution:Bool = false,
			wantsBestResolutionOnBrowserZoom:Bool = false):Void
	{
		backBufferWidth = width;
		backBufferHeight = height;
		// Flight audit — implementable now: retain OpenFL's observable dimensions.
		// Allocating/configuring the GPU attachment remains blocked on the GL draw seam.
	}

	public function createCubeTexture(size:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool, streamingLevels:Int = 0):CubeTexture
	{
		return new CubeTexture(this, size, format, optimizeForRenderToTexture, streamingLevels);
	}

	public function createIndexBuffer(numIndices:Int, bufferUsage:Context3DBufferUsage = STATIC_DRAW):IndexBuffer3D
	{
		return new IndexBuffer3D(this, numIndices, bufferUsage);
	}

	public function createProgram(format:Context3DProgramFormat = AGAL):Program3D
	{
		return new Program3D(this, format);
	}

	public function createRectangleTexture(width:Int, height:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool):RectangleTexture
	{
		return new RectangleTexture(this, width, height, format, optimizeForRenderToTexture);
	}

	public function createTexture(width:Int, height:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool, streamingLevels:Int = 0):Texture
	{
		return new Texture(this, width, height, format, optimizeForRenderToTexture, streamingLevels);
	}

	public function createVertexBuffer(numVertices:Int, data32PerVertex:Int, bufferUsage:Context3DBufferUsage = STATIC_DRAW):VertexBuffer3D
	{
		return new VertexBuffer3D(this, numVertices, data32PerVertex, bufferUsage);
	}

	public function createVideoTexture():VideoTexture
	{
		return new VideoTexture(this);
	}

	public function dispose(recreate:Bool = true):Void
	{
		// Flight audit — adapter stub: no public Flight render-state handle or
		// per-context resource ownership exists yet, so only local bridge state clears.
		gl = null;
	}

	public function drawToBitmapData(destination:BitmapData, srcRect:Rectangle = null, destPoint:Point = null):Void
	{
		// Flight audit — blocked on texture bridges: Flight exposes no public
		// render-target readback conversion into an OpenFL BitmapData.
	}

	public function drawTriangles(indexBuffer:IndexBuffer3D, firstIndex:Int = 0, numTriangles:Int = -1):Void
	{
		// Flight audit — blocked on GL draw seam: indexed Context3D geometry needs
		// arbitrary program and buffer binding, not only a fullscreen-pass helper.
	}

	public function present():Void
	{
		// Flight audit — blocked on GL draw seam: Flight can present a render target,
		// but Context3D cannot publicly acquire or retain the corresponding target.
	}

	public function setBlendFactors(sourceFactor:Context3DBlendFactor, destinationFactor:Context3DBlendFactor):Void
	{
		// Flight audit — blocked on GL draw seam: no public Context3D-compatible
		// blend-state mutation is available for the active render state.
	}

	public function setColorMask(red:Bool, green:Bool, blue:Bool, alpha:Bool):Void
	{
		// Flight audit — blocked on GL draw seam: no public color-write-mask command
		// is available for the active render state.
	}

	public function setCulling(triangleFaceToCull:Context3DTriangleFace):Void
	{
		// Flight audit — blocked on GL draw seam: no public face-culling command is
		// available for the active render state.
	}

	public function setDepthTest(depthMask:Bool, passCompareMode:Context3DCompareMode):Void
	{
		// Flight audit — blocked on GL draw seam: no public depth-write or
		// comparison-state command is available for the active render state.
	}

	public function setProgram(program:Program3D):Void
	{
		// Flight audit — blocked on GL draw seam: Program3D has no public Flight
		// shader-program bridge that can be bound to an active render state.
	}

	public function setProgramConstantsFromByteArray(programType:Context3DProgramType, firstRegister:Int, numRegisters:Int, data:ByteArray,
			byteArrayOffset:UInt):Void
	{
		// Flight audit — blocked on GL draw seam: AGAL register buffers cannot be
		// uploaded or bound through the public Flight rendering surface.
	}

	public function setProgramConstantsFromMatrix(programType:Context3DProgramType, firstRegister:Int, matrix:Matrix3D, transposedMatrix:Bool = false):Void
	{
		// Flight audit — blocked on GL draw seam: matrix register data cannot be
		// uploaded or bound through the public Flight rendering surface.
	}

	public function setProgramConstantsFromVector(programType:Context3DProgramType, firstRegister:Int, data:Vector<Float>, numRegisters:Int = -1):Void
	{
		// Flight audit — blocked on GL draw seam: vector register data cannot be
		// uploaded or bound through the public Flight rendering surface.
	}

	public function setRenderToBackBuffer():Void
	{
		// Flight audit — blocked on GL draw seam: Context3D has no public Flight
		// render-state/back-buffer binding bridge.
	}

	public function setRenderToTexture(texture:TextureBase, enableDepthAndStencil:Bool = false, antiAlias:Int = 0, surfaceSelector:Int = 0):Void
	{
		// Flight audit — blocked on texture bridges: Context3D textures are Flight
		// sampled textures, with no public conversion to a Flight render target.
	}

	public function setSamplerStateAt(sampler:Int, wrap:Context3DWrapMode, filter:Context3DTextureFilter, mipfilter:Context3DMipFilter):Void
	{
		// Flight audit — blocked on GL draw seam: Flight can create typed samplers,
		// but exposes no per-slot sampler binding on the active render state.
	}

	public function setScissorRectangle(rectangle:Rectangle):Void
	{
		// Flight audit — blocked on GL draw seam: no public scissor-state command is
		// available for the active render state.
	}

	public function setStencilActions(triangleFace:Context3DTriangleFace = FRONT_AND_BACK, compareMode:Context3DCompareMode = ALWAYS,
			actionOnBothPass:Context3DStencilAction = KEEP, actionOnDepthFail:Context3DStencilAction = KEEP,
			actionOnDepthPassStencilFail:Context3DStencilAction = KEEP):Void
	{
		// Flight audit — blocked on GL draw seam: no public per-face stencil-action
		// command is available for the active render state.
	}

	public function setStencilReferenceValue(referenceValue:UInt, readMask:UInt = 0xFF, writeMask:UInt = 0xFF):Void
	{
		// Flight audit — blocked on GL draw seam: no public stencil reference/mask
		// command is available for the active render state.
	}

	public function setTextureAt(sampler:Int, texture:TextureBase):Void
	{
		// Flight audit — blocked on GL draw seam: Flight textures can be resolved
		// only after an active state is available, and no texture-slot binding exists.
	}

	public function setVertexBufferAt(index:Int, buffer:VertexBuffer3D, bufferOffset:Int = 0, format:Context3DVertexBufferFormat = FLOAT_4):Void
	{
		// Flight audit — blocked on GL draw seam: VertexBuffer3D has no public Flight
		// buffer/layout bridge that can be bound to an active render state.
	}

	@:noCompletion private function get_enableErrorChecking():Bool
	{
		return __enableErrorChecking;
	}

	@:noCompletion private function set_enableErrorChecking(value:Bool):Bool
	{
		return __enableErrorChecking = value;
	}

	@:noCompletion private function get_totalGPUMemory():Int
	{
		return 0;
	}
}
#else
typedef Context3D = flash.display3D.Context3D;
#end
