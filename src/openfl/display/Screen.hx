package openfl.display;

#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
import flight.Screen as FlightScreen;
import flight.types.ScreenInfo as FlightScreenInfo;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;

/**
	The Screen class provides information about the display screens available to
	this application.

	Screens are independent desktop areas within a possibly larger "virtual
	desktop." The origin of the virtual desktop is the top-left corner of the
	operating-system-designated main screen. Thus, the coordinates for the
	bounds of an individual display screen may be negative. There may also be
	areas of the virtual desktop that are not within any of the display screens.

	The Screen class includes static class members for accessing the available
	screen objects and instance members for accessing the properties of an
	individual screen. Screen information should not be cached since it can be
	changed by a user at any time.

	Note that there is not necessarily a one-to-one correspondance between
	screens and the physical monitors attached to a computer. For example, two
	monitors may display the same screen.

	You cannot instantiate the Screen class directly. Calls to the
	`new Screen()` constructor throw an ArgumentError exception.
**/
@:access(openfl.display.ScreenMode)
class Screen extends EventDispatcher
{
	/**
		The bounds of this screen.

		The screen location is relative to the virtual desktop.

		On Linux systems that use certain window managers, this property returns
		the desktop bounds, not the screen's visible bounds.
	**/
	public var bounds(get, never):Rectangle;

	/**
		The array of the currently available screens.

		Modifying the returned array has no effect on the available screens.
	**/
	public static var screens(get, never):Array<Screen>;

	/**
		The primary display.
	**/
	public static var mainScreen(get, never):Screen;

	/**
		The current screen mode of the Screen object.
	**/
	public var mode(get, null):ScreenMode;

	/**
		The array of ScreenMode objects of the Screen object.
	**/
	public var modes(get, null):Array<ScreenMode>;

	/**
		The bounds of the area on this screen in which windows can be visible.

		The visibleBounds of a screen excludes the task bar (and other docked desk bars) on Windows,
		and excludes the menu bar and, depending on system settings, the dock on Mac OS X. On some Linux
		configurations, it is not possible to determine the visible bounds.

		In these cases, the visibleBounds property returns the same value as the screenBounds property.
	**/
	public var visibleBounds(get, null):Rectangle;

	/**
		The bounds of the area on this screen in which content will not be
		covered by notches, cut outs, rounded corners, or other obstructions.

		Supported on native targets for the Android, iOS, and macOS operating
		systems. On other targets, the rectangle will be equal to
		`visibleBounds`.

		Requires Lime 8.3 or newer.
	**/
	public var safeArea(get, null):Rectangle;

	@:noCompletion private var __flightScreen:FlightScreenInfo;
	@:noCompletion private var __screenAvailable:Bool;

	private function new(screen:FlightScreenInfo, available:Bool)
	{
		super();
		__flightScreen = screen;
		__screenAvailable = available;
	}

	/**
		Returns the (possibly empty) set of screens that intersect the provided
		rectangle.
	**/
	public static function getScreensForRectangle(rect:Rectangle):Array<Screen>
	{
		var result:Array<Screen> = [];
		for (screen in screens)
		{
			if (screen.bounds.intersects(rect))
			{
				result.push(screen);
			}
		}

		return result;
	}

	@:noCompletion private function get_modes():Array<ScreenMode>
	{
		__requireAvailable();
		var screenModes:Array<ScreenMode> = [];
		var flightModes = FlightScreen.getScreenModes(__flightScreen, []);
		for (flightMode in flightModes)
		{
			screenModes.push(new ScreenMode(flightMode));
		}

		return screenModes;
	}

	@:noCompletion private function get_visibleBounds():Rectangle
	{
		var currentMode = mode;
		return new Rectangle(0, 0, currentMode.width, currentMode.height);
	}

	@:noCompletion private function get_safeArea():Rectangle
	{
		return visibleBounds;
	}

	@:noCompletion private function get_mode():ScreenMode
	{
		__requireAvailable();
		return new ScreenMode(FlightScreen.getScreenCurrentMode(__flightScreen, FlightScreen.createScreenMode()));
	}

	@:noCompletion private function get_bounds():Rectangle
	{
		__requireAvailable();
		var bounds = FlightScreen.getScreenBounds(__flightScreen, {x: 0.0, y: 0.0, width: 0.0, height: 0.0});
		return new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
	}

	@:noCompletion private static function get_screens():Array<Screen>
	{
		var flightScreens = FlightScreen.getScreens([]);
		if (flightScreens.length == 0)
		{
			return [new Screen(FlightScreen.getPrimaryScreen(__emptyScreenInfo()), false)];
		}
		return [for (screen in flightScreens) new Screen(screen, true)];
	}

	@:noCompletion private static function get_mainScreen():Screen
	{
		var flightScreens = FlightScreen.getScreens([]);
		return new Screen(FlightScreen.getPrimaryScreen(__emptyScreenInfo()), flightScreens.length > 0);
	}

	@:noCompletion private function __requireAvailable():Void
	{
		if (!__screenAvailable) throw "Screen details are unavailable";
	}

	@:noCompletion private static function __emptyScreenInfo():FlightScreenInfo
	{
		return {
			id: 0,
			x: 0,
			y: 0,
			width: 0,
			height: 0,
			workWidth: 0,
			workHeight: 0,
			scaleFactor: 1,
			isPrimary: false,
			rotation: -1,
			orientation: cast "Landscape",
			refreshRate: -1,
			colorDepth: -1,
			pixelDepth: -1,
			physicalWidth: -1,
			physicalHeight: -1,
			isHdr: false,
			colorSpace: cast "srgb",
			maxLuminance: -1,
			depthPerComponent: -1,
			dpi: -1,
			label: "",
			internal: false,
			touchSupport: "unknown",
			monochrome: false
		};
	}
}
#else
#if air
typedef Screen = flash.display.Screen;
#end
#end
