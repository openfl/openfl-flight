package openfl.display;

#if !flash
import openfl.display3D.Context3D;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
#if lime
import lime.graphics.WebGLRenderContext;
import lime.math.Matrix4;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:allow(openfl.display)
@:allow(openfl.display3D)
class OpenGLRenderer extends DisplayObjectRenderer
{
	@SuppressWarnings("checkstyle:Dynamic")
	public var gl:#if lime WebGLRenderContext #else Dynamic #end;

	@:noCompletion private var __context3D:Context3D;
	@:noCompletion private var __currentRenderTarget:BitmapData;
	@:noCompletion private var __currentShader:Shader;
	@:noCompletion private var __defaultRenderTarget:BitmapData;
	@:noCompletion private var __displayHeight:Int;
	@:noCompletion private var __displayWidth:Int;
	@:noCompletion private var __flipped:Bool;
	@:noCompletion private var __height:Int;
	@:noCompletion private var __offsetX:Int;
	@:noCompletion private var __offsetY:Int;
	@:noCompletion private var __upscaled:Bool;
	@:noCompletion private var __width:Int;

	@:noCompletion private function new(context:Context3D, defaultRenderTarget:BitmapData = null)
	{
		super();
		__context3D = context;
		__defaultRenderTarget = defaultRenderTarget;
		#if lime
		__type = OPENGL;
		#end
	}

	public function applyAlpha(alpha:Float):Void {}
	public function applyBitmapData(bitmapData:BitmapData, smooth:Bool, repeat:Bool = false):Void {}
	public function applyColorTransform(colorTransform:ColorTransform):Void {}
	public function applyHasColorTransform(enabled:Bool):Void {}
	public function applyMatrix(matrix:Array<Float>):Void {}

	@SuppressWarnings("checkstyle:Dynamic")
	public function getMatrix(transform:Matrix):#if lime Matrix4 #else Dynamic #end
	{
		// TODO (Flight): translate OpenFL matrices for the Flight graphics backend.
		return null;
	}

	public function setShader(shader:Shader):Void
	{
		__currentShader = shader;
	}

	public function setViewport():Void {}
	public function updateShader():Void {}
	public function useAlphaArray():Void {}
	public function useColorTransformArray():Void {}

	@:noCompletion private function __cleanup():Void {}
	@:noCompletion private function __clearShader():Void
	{
		__currentShader = null;
	}
	@:noCompletion private function __copyShader(other:OpenGLRenderer):Void
	{
		__currentShader = other.__currentShader;
	}
	@:noCompletion private function __getMatrix(transform:Matrix, pixelSnapping:PixelSnapping):Array<Float>
	{
		return [transform.a, transform.b, 0, transform.c, transform.d, 0, transform.tx, transform.ty, 1];
	}
	@:noCompletion private function __initShader(shader:Shader):Shader return shader;
	@:noCompletion private function __initDisplayShader(shader:Shader):Shader return shader;
	@:noCompletion private function __initGraphicsShader(shader:Shader):Shader return shader;
	@:noCompletion private function __renderDrawable(object:IBitmapDrawable):Void {}
	@:noCompletion private function __renderDrawableMask(object:IBitmapDrawable):Void {}
	@:noCompletion private function __renderFilterPass(source:BitmapData, shader:Shader, smooth:Bool, clear:Bool = true):Void {}
	@:noCompletion private function __resumeClipAndMask(childRenderer:OpenGLRenderer):Void {}
	@:noCompletion private function __scissorRect(clipRect:openfl.geom.Rectangle = null):Void {}
	@:noCompletion private function __setRenderTarget(renderTarget:BitmapData):Void
	{
		__currentRenderTarget = renderTarget;
	}
	@:noCompletion private function __suspendClipAndMask():Void {}
}
#else
typedef OpenGLRenderer = flash.display.OpenGLRenderer;
#end
