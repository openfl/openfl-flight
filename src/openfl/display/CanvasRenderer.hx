package openfl.display;

#if !flash
import openfl.geom.Matrix;
#if lime
import lime.graphics.Canvas2DRenderContext;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:allow(openfl.display)
@:allow(openfl.text)
class CanvasRenderer extends DisplayObjectRenderer
{
	@SuppressWarnings("checkstyle:Dynamic")
	public var context:#if lime Canvas2DRenderContext #else Dynamic #end;

	@:noCompletion private var __isDOM:Bool;
	@:noCompletion private var __tempMatrix:Matrix;

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function new(context:#if lime Canvas2DRenderContext #else Dynamic #end)
	{
		super();
		this.context = context;
		__tempMatrix = new Matrix();
		#if lime
		__type = CANVAS;
		#end
	}

	@SuppressWarnings("checkstyle:Dynamic")
	public function applySmoothing(context:#if lime Canvas2DRenderContext #else Dynamic #end, value:Bool):Void
	{
		// TODO (Flight): configure canvas image smoothing.
	}

	@SuppressWarnings("checkstyle:Dynamic")
	public function setTransform(transform:Matrix, context:#if lime Canvas2DRenderContext #else Dynamic #end = null):Void
	{
		// TODO (Flight): apply the transform to the canvas backend.
	}

	@:noCompletion private function __renderDrawable(object:IBitmapDrawable):Void {}
	@:noCompletion private function __renderDrawableMask(object:IBitmapDrawable):Void {}

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function __setBlendModeContext(context:#if lime Canvas2DRenderContext #else Dynamic #end, value:BlendMode):Void {}
}
#else
typedef CanvasRenderer = flash.display.CanvasRenderer;
#end
