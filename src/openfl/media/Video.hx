package openfl.media;

#if !flash
import openfl.display.DisplayObject;
import openfl.net.NetStream;

/**
	A display-list surface for video playback. Frame decoding and rendering are
	left as a Flight integration point.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.net.NetStream)
class Video extends DisplayObject
{
	public var deblocking:Int;
	public var smoothing:Bool;
	public var videoHeight(get, never):Int;
	public var videoWidth(get, never):Int;

	@:noCompletion private var __height:Float;
	@:noCompletion private var __stream:NetStream;
	@:noCompletion private var __width:Float;

	public function new(width:Int = 320, height:Int = 240):Void
	{
		super();
		__width = width;
		__height = height;
		smoothing = false;
		deblocking = 0;
	}

	public function attachNetStream(netStream:NetStream):Void
	{
		__stream = netStream;
		// TODO: Attach decoded Flight video frames to this display surface.
	}

	public function clear():Void
	{
		// TODO: Clear the Flight-backed video surface.
	}

	@:noCompletion private function get_videoHeight():Int
	{
		return 0;
	}

	@:noCompletion private function get_videoWidth():Int
	{
		return 0;
	}

	@:noCompletion private override function get_height():Float
	{
		return __height;
	}

	@:noCompletion private override function set_height(value:Float):Float
	{
		return __height = value;
	}

	@:noCompletion private override function get_width():Float
	{
		return __width;
	}

	@:noCompletion private override function set_width(value:Float):Float
	{
		return __width = value;
	}
}
#else
typedef Video = flash.media.Video;
#end
