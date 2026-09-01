package openfl.display;

#if !flash
import openfl.geom.Matrix;
#if lime
import lime.graphics.cairo.Cairo;
import lime.graphics.CairoRenderContext;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:allow(openfl.display)
class CairoRenderer extends DisplayObjectRenderer
{
	@SuppressWarnings("checkstyle:Dynamic")
	public var cairo:#if lime CairoRenderContext #else Dynamic #end;

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function new(cairo:#if lime Cairo #else Dynamic #end)
	{
		super();
		this.cairo = cast cairo;
		#if lime
		__type = CAIRO;
		#end
	}

	@SuppressWarnings("checkstyle:Dynamic")
	public function applyMatrix(transform:Matrix, cairo:#if lime Cairo #else Dynamic #end = null):Void
	{
		// TODO (Flight): apply the transform to the Cairo backend.
	}

	@:noCompletion private function __renderDrawable(object:IBitmapDrawable):Void {}
	@:noCompletion private function __renderDrawableMask(object:IBitmapDrawable):Void {}

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function __setBlendModeCairo(cairo:#if lime Cairo #else Dynamic #end, value:BlendMode):Void {}
}
#else
typedef CairoRenderer = flash.display.CairoRenderer;
#end
