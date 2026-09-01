package openfl.display;

#if !flash
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
@:access(openfl.display.Graphics)
class Shape extends DisplayObject
{
	/**
		Specifies the Graphics object belonging to this Shape object, where vector
		drawing commands can occur.
	**/
	public var graphics(get, never):Graphics;

	/**
		Creates a new Shape object.
	**/
	public function new()
	{
		super();
	}

	@:noCompletion private function get_graphics():Graphics
	{
		if (__graphics == null) __graphics = new Graphics(this);
		return __graphics;
	}
}
#else
typedef Shape = flash.display.Shape;
#end
