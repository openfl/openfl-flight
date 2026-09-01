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
		// TODO: Clear Flight GPU render targets.
	}

	public function configureBackBuffer(width:Int, height:Int, antiAlias:Int, enableDepthAndStencil:Bool = true, wantsBestResolution:Bool = false,
			wantsBestResolutionOnBrowserZoom:Bool = false):Void
	{
		backBufferWidth = width;
		backBufferHeight = height;
		// TODO: Configure the Flight GPU back buffer.
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
		// TODO: Release all Flight GPU resources owned by this context.
	}

	public function drawToBitmapData(destination:BitmapData, srcRect:Rectangle = null, destPoint:Point = null):Void
	{
		// TODO: Read pixels from the Flight GPU render target.
	}

	public function drawTriangles(indexBuffer:IndexBuffer3D, firstIndex:Int = 0, numTriangles:Int = -1):Void
	{
		// TODO: Submit indexed geometry to Flight GPU rendering.
	}

	public function present():Void
	{
		// TODO: Present the Flight GPU back buffer.
	}

	public function setBlendFactors(sourceFactor:Context3DBlendFactor, destinationFactor:Context3DBlendFactor):Void
	{
		// TODO: Configure Flight GPU blend state.
	}

	public function setColorMask(red:Bool, green:Bool, blue:Bool, alpha:Bool):Void
	{
		// TODO: Configure the Flight GPU color mask.
	}

	public function setCulling(triangleFaceToCull:Context3DTriangleFace):Void
	{
		// TODO: Configure Flight GPU culling.
	}

	public function setDepthTest(depthMask:Bool, passCompareMode:Context3DCompareMode):Void
	{
		// TODO: Configure Flight GPU depth testing.
	}

	public function setProgram(program:Program3D):Void
	{
		// TODO: Bind a Flight GPU shader program.
	}

	public function setProgramConstantsFromByteArray(programType:Context3DProgramType, firstRegister:Int, numRegisters:Int, data:ByteArray,
			byteArrayOffset:UInt):Void
	{
		// TODO: Upload shader constants through Flight GPU buffers.
	}

	public function setProgramConstantsFromMatrix(programType:Context3DProgramType, firstRegister:Int, matrix:Matrix3D, transposedMatrix:Bool = false):Void
	{
		// TODO: Upload matrix constants through Flight GPU buffers.
	}

	public function setProgramConstantsFromVector(programType:Context3DProgramType, firstRegister:Int, data:Vector<Float>, numRegisters:Int = -1):Void
	{
		// TODO: Upload vector constants through Flight GPU buffers.
	}

	public function setRenderToBackBuffer():Void
	{
		// TODO: Bind the Flight GPU back buffer.
	}

	public function setRenderToTexture(texture:TextureBase, enableDepthAndStencil:Bool = false, antiAlias:Int = 0, surfaceSelector:Int = 0):Void
	{
		// TODO: Bind a Flight GPU texture render target.
	}

	public function setSamplerStateAt(sampler:Int, wrap:Context3DWrapMode, filter:Context3DTextureFilter, mipfilter:Context3DMipFilter):Void
	{
		// TODO: Configure a Flight GPU sampler.
	}

	public function setScissorRectangle(rectangle:Rectangle):Void
	{
		// TODO: Configure the Flight GPU scissor rectangle.
	}

	public function setStencilActions(triangleFace:Context3DTriangleFace = FRONT_AND_BACK, compareMode:Context3DCompareMode = ALWAYS,
			actionOnBothPass:Context3DStencilAction = KEEP, actionOnDepthFail:Context3DStencilAction = KEEP,
			actionOnDepthPassStencilFail:Context3DStencilAction = KEEP):Void
	{
		// TODO: Configure Flight GPU stencil actions.
	}

	public function setStencilReferenceValue(referenceValue:UInt, readMask:UInt = 0xFF, writeMask:UInt = 0xFF):Void
	{
		// TODO: Configure the Flight GPU stencil reference.
	}

	public function setTextureAt(sampler:Int, texture:TextureBase):Void
	{
		// TODO: Bind a Flight GPU texture.
	}

	public function setVertexBufferAt(index:Int, buffer:VertexBuffer3D, bufferOffset:Int = 0, format:Context3DVertexBufferFormat = FLOAT_4):Void
	{
		// TODO: Bind a Flight GPU vertex buffer.
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
