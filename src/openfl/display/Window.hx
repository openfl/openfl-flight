package openfl.display;

#if !flash
import flight.Application as FlightApplication;
import flight.Signals as FlightSignals;
import flight.types.ApplicationWindow as FlightApplicationWindow;
#end
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
@:access(openfl.display.DisplayObject)
@:access(openfl.display.Stage)
@SuppressWarnings("checkstyle:FieldDocComment")
class Window #if lime extends LimeWindow #end
{
	#if !lime
	public var application(default, null):Application;
	@SuppressWarnings("checkstyle:Dynamic") public var context:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var cursor:Dynamic;
	@SuppressWarnings("checkstyle:Dynamic") public var display:Dynamic;
	@:isVar public var frameRate(get, set):Float;
	@:isVar public var fullscreen(get, set):Bool;
	@:isVar public var height(get, set):Int;
	@:isVar public var scale(get, set):Float;
	public var stage(default, null):Stage;
	@:isVar public var textInputEnabled(get, set):Bool;
	@:isVar public var width(get, set):Int;
	@:isVar public var x(get, set):Int;
	@:isVar public var y(get, set):Int;
	@:isVar public var title(get, set):String;
	@:isVar public var visible(get, set):Bool;
	@:isVar public var minimized(get, set):Bool;
	@:isVar public var maximized(get, set):Bool;
	public var id(default, null):Int;
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

	@:noCompletion private var __frameRate:Float;
	@:noCompletion private var __fullscreen:Bool;
	@:noCompletion private var __height:Int;
	@:noCompletion private var __maximized:Bool;
	@:noCompletion private var __minimized:Bool;
	@:noCompletion private var __scale:Float;
	@:noCompletion private var __textInputEnabled:Bool;
	@:noCompletion private var __title:String;
	@:noCompletion private var __visible:Bool;
	@:noCompletion private var __width:Int;
	@:noCompletion private var __x:Int;
	@:noCompletion private var __y:Int;
	#end

	#if !flash
	@:noCompletion private var __flightWindow:FlightApplicationWindow;
	#end

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private function new(application:Application, attributes:#if lime WindowAttributes #else Dynamic #end)
	{
		var normalizedAttributes:Dynamic = attributes == null ? {} : attributes;
		#if lime
		super(application, attributes);
		#else
		this.application = application;
		__attributes = normalizedAttributes;
		context = Reflect.hasField(normalizedAttributes, "context") ? Reflect.field(normalizedAttributes, "context") : null;
		cursor = null;
		display = null;
		__frameRate = cast null;
		__fullscreen = false;
		__height = 0;
		__maximized = false;
		__minimized = false;
		__scale = 1;
		__textInputEnabled = false;
		__title = Reflect.hasField(normalizedAttributes, "title") ? Reflect.field(normalizedAttributes, "title") : "";
		__visible = true;
		__width = 0;
		__x = 0;
		__y = 0;
		id = -1;
		#end

		#if !flash
		__flightWindow = FlightApplication.createApplicationWindow();
		#if lime
		__flightWindow.title = title;
		__flightWindow.x = x;
		__flightWindow.y = y;
		__flightWindow.width = width;
		__flightWindow.height = height;
		__flightWindow.devicePixelRatio = scale;
		__flightWindow.fullscreen = fullscreen;
		__flightWindow.minimized = minimized;
		__flightWindow.maximized = maximized;
		__flightWindow.visible = visible;
		#else
		__flightWindow.title = Reflect.hasField(normalizedAttributes, "title") ? Reflect.field(normalizedAttributes, "title") : "";
		__flightWindow.resizable = Reflect.hasField(normalizedAttributes, "resizable") ? Reflect.field(normalizedAttributes, "resizable") : false;
		__flightWindow.minimized = Reflect.hasField(normalizedAttributes, "minimized") ? Reflect.field(normalizedAttributes, "minimized") : false;
		__flightWindow.maximized = Reflect.hasField(normalizedAttributes, "maximized") ? Reflect.field(normalizedAttributes, "maximized") : false;
		__flightWindow.visible = true;

		onActivate = __flightWindow.onActivate;
		onDeactivate = __flightWindow.onDeactivate;
		onFocusIn = __flightWindow.onFocusIn;
		onFocusOut = __flightWindow.onFocusOut;
		onMove = __flightWindow.onMove;
		onResize = __flightWindow.onResize;
		onMinimize = __flightWindow.onMinimize;
		onMaximize = __flightWindow.onMaximize;
		onRestore = __flightWindow.onRestore;
		onClose = __flightWindow.onClose;
		onRenderContextLost = __flightWindow.onRenderContextLost;
		onRenderContextRestored = __flightWindow.onRenderContextRestored;
		onDropFile = __flightWindow.onDropFile;
		onFullscreen = __flightWindow.onFullscreenChanged;
		onEnter = FlightSignals.createSignal();
		onExpose = FlightSignals.createSignal();
		onKeyDown = FlightSignals.createSignal();
		onKeyUp = FlightSignals.createSignal();
		onLeave = FlightSignals.createSignal();
		onMouseDown = FlightSignals.createSignal();
		onMouseMove = FlightSignals.createSignal();
		onMouseMoveRelative = FlightSignals.createSignal();
		onMouseUp = FlightSignals.createSignal();
		onMouseWheel = FlightSignals.createSignal();
		onRender = FlightSignals.createSignal();
		onTextEdit = FlightSignals.createSignal();
		onTextInput = FlightSignals.createSignal();

		var backend = FlightApplication.explainWindowBackend();
		if (backend.layer != "host-not-enabled")
		{
			FlightApplication.openWindow(__flightWindow, {
				title: __flightWindow.title,
				width: Reflect.hasField(normalizedAttributes, "width") ? Reflect.field(normalizedAttributes, "width") : 0,
				height: Reflect.hasField(normalizedAttributes, "height") ? Reflect.field(normalizedAttributes, "height") : 0,
				resizable: __flightWindow.resizable,
				minimized: __flightWindow.minimized,
				maximized: __flightWindow.maximized,
				visible: __flightWindow.visible
			});
		}
		#end
		#end

		#if (!flash && !macro)
		#if commonjs
		if (Reflect.hasField(normalizedAttributes, "stage"))
		{
			stage = Reflect.field(normalizedAttributes, "stage");
			stage.window = this;
			Reflect.deleteField(normalizedAttributes, "stage");
		}
		else
		#end
		var contextAttributes:Dynamic = Reflect.hasField(normalizedAttributes, "context") ? Reflect.field(normalizedAttributes, "context") : null;
		stage = new Stage(this,
			contextAttributes != null && Reflect.hasField(contextAttributes, "background") ? Reflect.field(contextAttributes, "background") : 0xFFFFFF);
		if (stage.loaderInfo == null) stage.__loaderInfo = LoaderInfo.create(null);

		if (Reflect.hasField(normalizedAttributes, "parameters"))
		{
			try
			{
				stage.loaderInfo.parameters = Reflect.field(normalizedAttributes, "parameters");
			}
			catch (e:Dynamic) {}
		}

		stage.__setLogicalSize(Reflect.hasField(normalizedAttributes, "width") ? Reflect.field(normalizedAttributes, "width") : 0,
			Reflect.hasField(normalizedAttributes, "height") ? Reflect.field(normalizedAttributes, "height") : 0);

		if (Reflect.hasField(normalizedAttributes, "resizable") && !Reflect.field(normalizedAttributes, "resizable"))
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
	public function focus():Void
	{
		#if lime
		super.focus();
		#end
		#if !flash
		if (__flightWindow != null) FlightApplication.focusWindow(__flightWindow);
		#end
	}

	#if lime override #end
	public function move(x:Int, y:Int):Void
	{
		#if lime
		super.move(x, y);
		#end
		#if !flash
		if (__flightWindow != null) FlightApplication.setWindowPosition(__flightWindow, x, y);
		#end
		#if !lime
		__x = x;
		__y = y;
		#end
	}

	#if lime override #end
	public function resize(width:Int, height:Int):Void
	{
		#if lime
		super.resize(width, height);
		#end
		#if !flash
		if (__flightWindow != null) FlightApplication.setWindowSize(__flightWindow, width, height);
		#end
		#if !lime
		__width = width;
		__height = height;
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
		#if !flash
		if (__flightWindow != null)
		{
			FlightApplication.closeWindow(__flightWindow);
			FlightApplication.disposeApplicationWindow(__flightWindow);
		}
		#end
		#if (!flash && lime)
		application.removeModule(stage);
		#end
		stage = null;
	}

	#if !lime
	@:noCompletion private function get_frameRate():Float return __flightWindow == null ? frameRate : __frameRate;
	@:noCompletion private function set_frameRate(value:Float):Float
	{
		frameRate = value;
		return __frameRate = value;
	}
	@:noCompletion private function get_fullscreen():Bool return __flightWindow == null ? fullscreen : __flightWindow.fullscreen;
	@:noCompletion private function set_fullscreen(value:Bool):Bool
	{
		fullscreen = value;
		__fullscreen = value;
		if (__flightWindow != null) FlightApplication.setWindowFullscreen(__flightWindow, value);
		return get_fullscreen();
	}
	@:noCompletion private function get_height():Int return __flightWindow == null ? height : Std.int(__flightWindow.height);
	@:noCompletion private function set_height(value:Int):Int
	{
		height = value;
		__height = value;
		if (__flightWindow != null) FlightApplication.setWindowSize(__flightWindow, get_width(), value);
		return get_height();
	}
	@:noCompletion private function get_scale():Float return __flightWindow == null ? scale : __flightWindow.devicePixelRatio;
	@:noCompletion private function set_scale(value:Float):Float
	{
		scale = value;
		__scale = value;
		if (__flightWindow != null) __flightWindow.devicePixelRatio = value;
		return value;
	}
	@:noCompletion private function get_textInputEnabled():Bool return __flightWindow == null ? textInputEnabled : __textInputEnabled;
	@:noCompletion private function set_textInputEnabled(value:Bool):Bool
	{
		textInputEnabled = value;
		return __textInputEnabled = value;
	}
	@:noCompletion private function get_width():Int return __flightWindow == null ? width : Std.int(__flightWindow.width);
	@:noCompletion private function set_width(value:Int):Int
	{
		width = value;
		__width = value;
		if (__flightWindow != null) FlightApplication.setWindowSize(__flightWindow, value, get_height());
		return get_width();
	}
	@:noCompletion private function get_x():Int return __flightWindow == null ? x : Std.int(__flightWindow.x);
	@:noCompletion private function set_x(value:Int):Int
	{
		x = value;
		move(value, y);
		return x;
	}
	@:noCompletion private function get_y():Int return __flightWindow == null ? y : Std.int(__flightWindow.y);
	@:noCompletion private function set_y(value:Int):Int
	{
		y = value;
		move(x, value);
		return y;
	}
	@:noCompletion private function get_title():String return __flightWindow == null ? title : __flightWindow.title;
	@:noCompletion private function set_title(value:String):String
	{
		title = value;
		__title = value;
		if (__flightWindow != null) FlightApplication.setWindowTitle(__flightWindow, value);
		return get_title();
	}
	@:noCompletion private function get_visible():Bool return __flightWindow == null ? visible : __flightWindow.visible;
	@:noCompletion private function set_visible(value:Bool):Bool
	{
		visible = value;
		__visible = value;
		if (__flightWindow != null)
		{
			if (value) FlightApplication.showWindow(__flightWindow); else FlightApplication.hideWindow(__flightWindow);
		}
		return get_visible();
	}
	@:noCompletion private function get_minimized():Bool return __flightWindow == null ? minimized : __flightWindow.minimized;
	@:noCompletion private function set_minimized(value:Bool):Bool
	{
		minimized = value;
		__minimized = value;
		if (value) __maximized = false;
		if (__flightWindow == null) return value;
		if (value)
		{
			__flightWindow.maximized = false;
			FlightApplication.minimizeWindow(__flightWindow);
		}
		else if (__flightWindow.minimized)
		{
			FlightApplication.restoreWindow(__flightWindow);
		}
		return __flightWindow.minimized;
	}
	@:noCompletion private function get_maximized():Bool return __flightWindow == null ? maximized : __flightWindow.maximized;
	@:noCompletion private function set_maximized(value:Bool):Bool
	{
		maximized = value;
		__maximized = value;
		if (value) __minimized = false;
		if (__flightWindow == null) return value;
		if (value)
		{
			__flightWindow.minimized = false;
			FlightApplication.maximizeWindow(__flightWindow);
		}
		else if (__flightWindow.maximized)
		{
			FlightApplication.restoreWindow(__flightWindow);
		}
		return __flightWindow.maximized;
	}
	#end
}
