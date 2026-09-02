package openfl.display3D.textures;

#if !flash
import flight.Texture as FlightTexture;
import flight.Video as FlightVideo;
import flight.types.VideoResource as FlightVideoResource;
import openfl.display3D.Context3D;
import openfl.net.NetStream;

/** A texture populated from a video stream. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display3D.Context3D)
@:access(openfl.net.NetStream)
@:final class VideoTexture extends TextureBase
{
	public var videoHeight(default, null):Int;
	public var videoWidth(default, null):Int;

	@:noCompletion private var __flightResource:FlightVideoResource;
	@:noCompletion private var __netStream:NetStream;

	@:noCompletion private function new(context:Context3D)
	{
		super(context);
		videoHeight = 0;
		videoWidth = 0;
		__flightResource = FlightVideo.createVideoResource();
		__flightTexture = FlightTexture.createVideoTexture(__flightResource);
	}

	public function attachNetStream(netStream:NetStream):Void
	{
		__netStream = netStream;
		#if (js && html5)
		var resource = netStream == null || netStream.__video == null
			? FlightVideo.createVideoResource()
			: FlightVideo.createVideoResource(cast netStream.__video);
		FlightVideo.disposeVideoResource(__flightResource);
		__flightResource = resource;
		FlightTexture.setVideoTextureSource(__flightTexture, resource);
		videoHeight = Std.int(FlightVideo.getVideoResourceHeight(resource));
		videoWidth = Std.int(FlightVideo.getVideoResourceWidth(resource));
		#else
		// Flight gap: NetStream bridge.
		// Flight video textures are public, but NetStream exposes no decoded video
		// resource to attach on non-HTML5 targets.
		#end
	}

	public override function dispose():Void
	{
		__netStream = null;
		if (__flightTexture != null) FlightTexture.destroyVideoTexture(cast __flightTexture);
		if (__flightResource != null)
		{
			FlightVideo.disposeVideoResource(__flightResource);
			__flightResource = null;
		}
		super.dispose();
	}
}
#else
typedef VideoTexture = flash.display3D.textures.VideoTexture;
#end
