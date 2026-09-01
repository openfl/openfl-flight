package openfl.display;

#if !flash
import openfl.events.EventDispatcher;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
#if lime
import lime.graphics.RenderContext;
import lime.graphics.RenderContextType;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:allow(openfl.display)
@:allow(openfl.text)
class DisplayObjectRenderer extends EventDispatcher
{
	@:noCompletion private var __allowSmoothing:Bool;
	@:noCompletion private var __blendMode:BlendMode;
	@:noCompletion private var __cleared:Bool;
	@SuppressWarnings("checkstyle:Dynamic") @:noCompletion private var __context:#if lime RenderContext #else Dynamic #end;
	@:noCompletion private var __overrideBlendMode:BlendMode;
	@:noCompletion private var __pixelRatio:Float;
	@:noCompletion private var __roundPixels:Bool;
	@:noCompletion private var __stage:Stage;
	@:noCompletion private var __tempColorTransform:ColorTransform;
	@:noCompletion private var __transparent:Bool;
	@SuppressWarnings("checkstyle:Dynamic") @:noCompletion private var __type:#if lime RenderContextType #else Dynamic #end;
	@:noCompletion private var __worldAlpha:Float;
	@:noCompletion private var __worldColorTransform:ColorTransform;
	@:noCompletion private var __worldTransform:Matrix;

	@:noCompletion private function new()
	{
		super();
		__allowSmoothing = true;
		__pixelRatio = 1;
		__worldAlpha = 1;
		__blendMode = NORMAL;
	}

	@:noCompletion private function __clear():Void
	{
		// TODO (Flight): clear the active renderer.
	}

	@:noCompletion private function __getAlpha(value:Float):Float
	{
		return value * __worldAlpha;
	}

	@:noCompletion private function __getColorTransform(value:ColorTransform):ColorTransform
	{
		return __worldColorTransform == null ? value : __worldColorTransform;
	}

	@:noCompletion private function __popMask():Void {}
	@:noCompletion private function __popMaskObject(object:DisplayObject, handleScrollRect:Bool = true):Void {}
	@:noCompletion private function __popMaskRect():Void {}
	@:noCompletion private function __pushMask(mask:DisplayObject):Void {}
	@:noCompletion private function __pushMaskObject(object:DisplayObject, handleScrollRect:Bool = true):Void {}
	@:noCompletion private function __pushMaskRect(rect:Rectangle, transform:Matrix):Void {}

	@:noCompletion private function __render(object:IBitmapDrawable):Void
	{
		// TODO (Flight): dispatch the drawable to a Flight renderer.
	}

	@:noCompletion private function __renderEvent(displayObject:DisplayObject):Void
	{
		// TODO (Flight): dispatch custom render events.
	}

	@:noCompletion private function __resize(width:Int, height:Int):Void {}
	@:noCompletion private function __setBlendMode(value:BlendMode):Void
	{
		__blendMode = value;
	}

	@:noCompletion private function __shouldCacheHardware(displayObject:DisplayObject, value:Null<Bool>):Null<Bool>
	{
		return value;
	}

	@:noCompletion private function __shouldCacheHardware_DisplayObject(displayObject:DisplayObject, value:Null<Bool>):Null<Bool>
	{
		return value;
	}

	@:noCompletion private function __updateCacheBitmap(displayObject:DisplayObject, force:Bool):Bool
	{
		return false;
	}
}
#else
typedef DisplayObjectRenderer = flash.display.DisplayObjectRenderer;
#end
