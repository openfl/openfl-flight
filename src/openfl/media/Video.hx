package openfl.media;

#if !flash
import flight.Scene2D as FlightScene2D;
import flight.Texture as FlightTexture;
import flight.Video as FlightVideo;
import flight.types.Sprite as FlightSpriteData;
import flight.types.Texture as FlightTextureData;
import flight.types.VideoResource as FlightVideoResource;
import openfl.display.DisplayObject;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
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
@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)
class Video extends DisplayObject
{
	public var deblocking:Int;
	public var smoothing:Bool;
	public var videoHeight(get, never):Int;
	public var videoWidth(get, never):Int;

	@:noCompletion private var __height:Float;
	@:noCompletion private var __flightResource:FlightVideoResource;
	@:noCompletion private var __flightTexture:FlightTextureData;
	@:noCompletion private var __stream:NetStream;
	@:noCompletion private var __width:Float;

	public function new(width:Int = 320, height:Int = 240):Void
	{
		super();
		__width = width;
		__height = height;
		smoothing = false;
		deblocking = 0;
		__flightResource = FlightVideo.createVideoResource();
		__flightTexture = FlightTexture.createVideoTexture(__flightResource);
		var sprite:FlightSpriteData = FlightScene2D.createSprite({data: {texture: __flightTexture}});
		__flightNode = sprite;
		__syncFlightNode();
	}

	public function attachNetStream(netStream:NetStream):Void
	{
		__stream = netStream;
		#if (js && html5)
		var resource = netStream == null || netStream.__video == null
			? FlightVideo.createVideoResource()
			: FlightVideo.createVideoResource(cast netStream.__video);
		FlightVideo.disposeVideoResource(__flightResource);
		__flightResource = resource;
		FlightTexture.setVideoTextureSource(__flightTexture, resource);
		#end
	}

	public function clear():Void
	{
		FlightTexture.resetVideoTextureFrame(__flightTexture);
	}

	public override function hitTestPoint(x:Float, y:Float, shapeFlag:Bool = false):Bool
	{
		return stage != null && __hitTest(x, y, shapeFlag);
	}

	@:noCompletion private function get_videoHeight():Int
	{
		return __flightResource == null ? 0 : Std.int(FlightVideo.getVideoResourceHeight(__flightResource));
	}

	@:noCompletion private function get_videoWidth():Int
	{
		return __flightResource == null ? 0 : Std.int(FlightVideo.getVideoResourceWidth(__flightResource));
	}

	@:noCompletion private override function __getBounds(rect:Rectangle, matrix:Matrix):Void
	{
		var bounds = new Rectangle(0, 0, __width, __height);
		bounds.__transform(bounds, matrix);
		rect.__expand(bounds.x, bounds.y, bounds.width, bounds.height);
	}

	@:noCompletion private override function __hasBoundsContent():Bool
	{
		return __width > 0 && __height > 0;
	}

	@:noCompletion private override function __hitTest(x:Float, y:Float, shapeFlag:Bool):Bool
	{
		if (!visible) return false;
		var matrix = __getWorldTransform();
		matrix.invert();
		var px = matrix.__transformX(x, y);
		var py = matrix.__transformY(x, y);
		return px > 0 && py > 0 && px <= __width && py <= __height;
	}

	@:noCompletion private override function get_height():Float
	{
		return __height * scaleY;
	}

	@:noCompletion private override function set_height(value:Float):Float
	{
		scaleY = 1;
		return __height = value;
	}

	@:noCompletion private override function get_width():Float
	{
		return __width * scaleX;
	}

	@:noCompletion private override function set_width(value:Float):Float
	{
		scaleX = 1;
		return __width = value;
	}
}
#else
typedef Video = flash.media.Video;
#end
