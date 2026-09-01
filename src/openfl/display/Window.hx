package openfl.display;

#if lime
import lime.app.Application;
import lime.ui.Window as LimeWindow;
import lime.ui.WindowAttributes;
#end

/**
	The Window class is a Lime Window instance that automatically
	initializes an OpenFL stage for the current window.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.LoaderInfo)
@:access(openfl.display.Stage)
@SuppressWarnings("checkstyle:FieldDocComment")
class Window #if lime extends LimeWindow #end
{
	#if !lime
	public var application:Application;
	@SuppressWarnings("checkstyle:Dynamic") public var context:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var cursor:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var display:Dynamic;
	public var frameRate:Float;
	public var fullscreen:Bool;
	public var height:Int;
	public var scale:Float;
	public var stage:Stage;
	public var textInputEnabled:Bool;
	public var width:Int;
	public var x:Int;
	public var y:Int;
	public var title:String;
	public var visible:Bool;
	public var minimized:Bool;
	public var maximized:Bool;
	public var id:Int;
	@SuppressWarnings("checkstyle:Dynamic") public var onActivate:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onDeactivate:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onFocusIn:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onFocusOut:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onMove:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onResize:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onMinimize:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onMaximize:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onRestore:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onClose:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onRenderContextLost:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onRenderContextRestored:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onDropFile:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onEnter:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onExpose:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onFullscreen:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onKeyDown:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onKeyUp:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onLeave:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onMouseDown:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onMouseMove:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onMouseMoveRelative:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onMouseUp:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onMouseWheel:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onRender:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onTextEdit:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var onTextInput:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var __attributes:Dynamic;

	public function focus():Void {}
	public function move(x:Int, y:Int):Void {}
	public function resize(width:Int, height:Int):Void {}
	#end

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function new(application:Application, attributes:#if lime WindowAttributes #else Dynamic #end)
	{
		#if lime
		super(application, attributes);
		#end

		#if (!flash && !macro)
		#if commonjs
		if (Reflect.hasField(attributes, "stage"))
		{
			stage = Reflect.field(attributes, "stage");
			stage.window = this;
			Reflect.deleteField(attributes, "stage");
		}
		else
		#end
		stage = new Stage(this, Reflect.hasField(attributes.context, "background") ? attributes.context.background : 0xFFFFFF);

		if (Reflect.hasField(attributes, "parameters"))
		{
			try
			{
				stage.loaderInfo.parameters = attributes.parameters;
			}
			catch (e:Dynamic) {}
		}

		stage.__setLogicalSize(attributes.width, attributes.height);

		if (Reflect.hasField(attributes, "resizable") && !attributes.resizable)
		{
			stage.scaleMode = StageScaleMode.SHOW_ALL;
		}

		#if lime
		application.addModule(stage);
		#end
		#else
		// TODO (Flight): attach the Flash display root when that backend exists.
		stage = null;
		#end
	}

	#if lime override #end
	public function close():Void
	{
		#if lime
		super.close();
		if (onClose.canceled)
		{
			return;
		}
		#end
		if (stage == null)
		{
			return;
		}
		#if (!flash && lime)
		application.removeModule(stage);
		#end
		stage = null;
	}
}
