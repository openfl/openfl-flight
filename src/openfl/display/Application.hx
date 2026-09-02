package openfl.display;

import flight.types.ApplicationWindow as FlightApplicationWindow;
import flight.types.Host as FlightHost;
import flight.types.WindowBackend as FlightWindowBackend;
import flight.types.WindowOptions as FlightWindowOptions;
#if (js && html5)
import flight.HostWeb as FlightHostWeb;
#elseif (clay && sys)
import flight.hostClay.HostClay as FlightHostClay;
#elseif (lime && sys)
import flight.hostLime.HostLime as FlightHostLime;
#end
import openfl.events.Event;
#if lime
import lime.app.Application as LimeApplication;
import lime.ui.WindowAttributes;
#end
#if ((sys || air) && (!flash_doc_gen || air_doc_gen))
import openfl.desktop.NativeApplication;
#end
#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
import openfl.display.NativeWindow;
import openfl.display.NativeWindowInitOptions;
import openfl.events.InvokeEvent;
#end

/**
	The Application class is a Lime Application instance that uses
	OpenFL Window by default when a new window is created.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
@:access(openfl.display.LoaderInfo)
@:access(openfl.display.Window)
#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
@:access(openfl.display.NativeWindowInitOptions)
#end
@SuppressWarnings("checkstyle:FieldDocComment")
class Application #if lime extends LimeApplication #end
{
	@:noCompletion private static var __flightHost:FlightHost;

	#if lime
	public static var current(get, never):Application;

	private static function get_current()
	{
		return cast(LimeApplication.current, Application);
	}
	#else
	public static var current:Application;

	public var window:Window;

	@SuppressWarnings("checkstyle:Dynamic")
	public function createWindow(attributes:Dynamic):Window
	{
		var created = new Window(this, attributes);
		if (window == null) window = created;
		return created;
	}
	#end

	public function new()
	{
		#if lime
		super();
		#else
		if (current == null) current = this;
		#end

		// TODO (Flight): connect the application to Flight's display root.
	}

	@:noCompletion private static function __getFlightHost(application:Application):FlightHost
	{
		if (__flightHost != null) return __flightHost;

		#if (js && html5)
		__flightHost = cast FlightHostWeb.webHost;
		#elseif (clay && sys)
		var host:Dynamic = FlightHostClay.createClayHost();
		host.window = __createFallbackWindowBackend();
		__flightHost = cast host;
		#elseif (lime && sys)
		__flightHost = cast FlightHostLime.createLimeHost(application);
		#else
		__flightHost = cast {window: __createFallbackWindowBackend()};
		#end

		return __flightHost;
	}

	@:noCompletion private static inline function __hasFlightWindowHost():Bool
	{
		#if ((js && html5) || (lime && sys))
		return true;
		#else
		return false;
		#end
	}

	@:noCompletion private static function __createFallbackWindowBackend():FlightWindowBackend
	{
		return {
			open: function(_window:FlightApplicationWindow, _options:FlightWindowOptions):Bool return true,
			close: function(_window:FlightApplicationWindow):Void {},
			focus: function(_window:FlightApplicationWindow):Void {},
			show: function(_window:FlightApplicationWindow):Void {},
			hide: function(_window:FlightApplicationWindow):Void {},
			setPosition: function(_window:FlightApplicationWindow, _x:Float, _y:Float):Void {},
			setSize: function(_window:FlightApplicationWindow, _width:Float, _height:Float):Void {},
			setTitle: function(_window:FlightApplicationWindow, _title:String):Void {},
			setFullscreen: function(_window:FlightApplicationWindow, _fullscreen:Bool):Void {},
			setParent: function(_window:FlightApplicationWindow, _parent:Null<FlightApplicationWindow>):Void {},
			setMinimumSize: function(_window:FlightApplicationWindow, _width:Float, _height:Float):Void {},
			setMaximumSize: function(_window:FlightApplicationWindow, _width:Float, _height:Float):Void {},
			minimize: function(_window:FlightApplicationWindow):Void {},
			maximize: function(_window:FlightApplicationWindow):Void {},
			restore: function(_window:FlightApplicationWindow):Void {}
		};
	}

	#if lime
	public override function createWindow(attributes:WindowAttributes):Window
	{
		var window = new Window(this, attributes);

		__windows.push(window);
		__windowByID.set(window.id, window);

		window.onClose.add(__onWindowClose.bind(window), false, -10000);

		if (__window == null)
		{
			__window = window;

			window.onActivate.add(onWindowActivate);
			window.onRenderContextLost.add(onRenderContextLost);
			window.onRenderContextRestored.add(onRenderContextRestored);
			window.onDeactivate.add(onWindowDeactivate);
			window.onDropFile.add(onWindowDropFile);
			window.onEnter.add(onWindowEnter);
			window.onExpose.add(onWindowExpose);
			window.onFocusIn.add(onWindowFocusIn);
			window.onFocusOut.add(onWindowFocusOut);
			window.onFullscreen.add(onWindowFullscreen);
			window.onKeyDown.add(onKeyDown);
			window.onKeyUp.add(onKeyUp);
			window.onLeave.add(onWindowLeave);
			window.onMinimize.add(onWindowMinimize);
			window.onMouseDown.add(onMouseDown);
			window.onMouseMove.add(onMouseMove);
			window.onMouseMoveRelative.add(onMouseMoveRelative);
			window.onMouseUp.add(onMouseUp);
			window.onMouseWheel.add(onMouseWheel);
			window.onMove.add(onWindowMove);
			window.onRender.add(render);
			window.onResize.add(onWindowResize);
			window.onRestore.add(onWindowRestore);
			window.onTextEdit.add(onTextEdit);
			window.onTextInput.add(onTextInput);

			onWindowCreate();

			#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
			var initOptions = new NativeWindowInitOptions();
			initOptions.__window = cast __window;
			new NativeWindow(initOptions);
			#end
		}

		onCreateWindow.dispatch(window);

		return window;
	}

	@:noCompletion override public function exec():Int
	{
		#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
		// wait for the first update to dispatch invoke event
		// to ensure that the document class constructor has completed
		onUpdate.add(function(delta:Int):Void
		{
			if (NativeApplication.nativeApplication.hasEventListener(InvokeEvent.INVOKE))
			{
				var args = Sys.args();
				var cwd = new openfl.filesystem.File(Sys.getCwd());
				var invokeEvent = new openfl.events.InvokeEvent(InvokeEvent.INVOKE, false, false, cwd, args);
				NativeApplication.nativeApplication.dispatchEvent(invokeEvent);
			}
		}, true);
		#end

		return super.exec();
	}
	#end

	#if (lime >= "8.1.0")
	@:noCompletion override private function __checkForAllWindowsClosed():Void
	{
		if (__windows.length > 0)
		{
			return;
		}
		#if ((sys || air) && (!flash_doc_gen || air_doc_gen))
		if (!NativeApplication.nativeApplication.autoExit)
		{
			return;
		}
		#end
		#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
		var exitingEvent = new Event(Event.EXITING, false, true);
		var result = NativeApplication.nativeApplication.dispatchEvent(exitingEvent);
		if (!result)
		{
			return;
		}
		#end
		super.__checkForAllWindowsClosed();
	}

	@:noCompletion override private function __onModuleExit(code:Int):Void
	{
		if (onExit.canceled)
		{
			return;
		}
		// TODO (Flight): clear the Flight application singleton.
		super.__onModuleExit(code);
	}
	#end
}
