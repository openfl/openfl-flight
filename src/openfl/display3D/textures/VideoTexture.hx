package openfl.display3D.textures;

#if !flash
import openfl.display3D.Context3D;
import openfl.net.NetStream;

/** A texture populated from a video stream. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display3D.Context3D)
@:final class VideoTexture extends TextureBase
{
	public var videoHeight(default, null):Int;
	public var videoWidth(default, null):Int;

	@:noCompletion private var __netStream:NetStream;

	@:noCompletion private function new(context:Context3D)
	{
		super(context);
		videoHeight = 0;
		videoWidth = 0;
	}

	public function attachNetStream(netStream:NetStream):Void
	{
		__netStream = netStream;
		// TODO: Bind decoded Flight video frames to this GPU texture.
	}

	public override function dispose():Void
	{
		__netStream = null;
		super.dispose();
	}
}
#else
typedef VideoTexture = flash.display3D.textures.VideoTexture;
#end
