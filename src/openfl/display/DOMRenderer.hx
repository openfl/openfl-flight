package openfl.display;

#if !flash
import openfl.geom.Rectangle;
#if lime
import lime.graphics.DOMRenderContext;
#end
#if (js && html5)
import js.html.Element;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:allow(openfl.display)
class DOMRenderer extends DisplayObjectRenderer
{
	@SuppressWarnings("checkstyle:Dynamic")
	public var element:#if lime DOMRenderContext #else Dynamic #end;

	@:noCompletion private var __canvasRenderer:CanvasRenderer;
	@:noCompletion private var __clipRects:Array<Rectangle>;
	@:noCompletion private var __currentClipRect:Rectangle;
	@:noCompletion private var __numClipRects:Int;
	@:noCompletion private var __transformOriginProperty:String;
	@:noCompletion private var __transformProperty:String;
	@:noCompletion private var __vendorPrefix:String;
	@:noCompletion private var __z:Int;

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function new(element:#if lime DOMRenderContext #else Dynamic #end)
	{
		super();
		this.element = element;
		__clipRects = [];
		#if lime
		__type = DOM;
		#end
	}

	public function applyStyle(parent:DisplayObject, childElement:#if (js && html5 && !display) Element #else Dynamic #end):Void
	{
		// TODO (Flight): apply display properties to the DOM element.
	}

	public function clearStyle(childElement:#if (js && html5 && !display) Element #else Dynamic #end):Void
	{
		// TODO (Flight): clear display properties from the DOM element.
	}

	@:noCompletion private function __applyStyle(displayObject:DisplayObject, setTransform:Bool, setAlpha:Bool, setClip:Bool):Void {}
	#if (js && html5)
	@:noCompletion private function __initializeElement(displayObject:DisplayObject, element:Element):Void {}
	#end
	@:noCompletion private function __renderDrawable(object:IBitmapDrawable):Void {}
	@:noCompletion private function __renderDrawableClear(object:IBitmapDrawable):Void {}
	@:noCompletion private function __updateClip(displayObject:DisplayObject):Void {}
}
#else
typedef DOMRenderer = flash.display.DOMRenderer;
#end
