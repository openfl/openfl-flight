package openfl.display;

#if !flash

/**
	Indicates the end of a graphics fill. Use a GraphicsEndFill object with the
	`Graphics.drawGraphicsData()` method.

	Drawing a GraphicsEndFill object is the equivalent of calling the
	`Graphics.endFill()` method.

	@see [Using graphics data classes](https://books.openfl.org/openfl-developers-guide/using-the-drawing-api/advanced-use-of-the-drawing-api/using-graphics-data-classes.html)
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:final class GraphicsEndFill implements IGraphicsData implements IGraphicsFill
{

	/**
		Creates an object to use with the `Graphics.drawGraphicsData()`
		method to end the fill, explicitly.
	**/
	public function new()
	{
	}
}
#else
typedef GraphicsEndFill = flash.display.GraphicsEndFill;
#end
