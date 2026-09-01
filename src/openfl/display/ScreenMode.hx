package openfl.display;

#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
import flight.types.ScreenMode as FlightScreenMode;

/**
	The ScreenMode object provides information about the width, height and refresh rate of a Screen.
**/
class ScreenMode
{
	/**
		The screen height of the ScreenMode in pixels.
	**/
	public var height(get, null):Int;

	/**
		The screen refresh rate of the ScreenMode in hertz.
	**/
	public var refreshRate(get, null):Int;

	/**
		The screen width of the ScreenMode in pixels.
	 */
	public var width(get, null):Int;

	private function get_height():Int
	{
		return Std.int(__flightMode.height);
	}

	private function get_refreshRate():Int
	{
		return Std.int(__flightMode.refreshRate);
	}

	private function get_width():Int
	{
		return Std.int(__flightMode.width);
	}

	@:noCompletion private var __flightMode:FlightScreenMode;

	private function new(displayMode:FlightScreenMode)
	{
		__flightMode = displayMode;
	}
}
#else
#if air
typedef ScreenMode = flash.display.ScreenMode;
#end
#end
