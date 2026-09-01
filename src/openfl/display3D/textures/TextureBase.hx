package openfl.display3D.textures;

#if !flash
import flight.types.TextureLike as FlightTexture;
import openfl.display3D.Context3D;
import openfl.events.EventDispatcher;

/** Base class for textures created by a Context3D. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display3D.Context3D)
class TextureBase extends EventDispatcher
{
	@:noCompletion private var __context:Context3D;
	@:noCompletion private var __flightTexture:FlightTexture;
	@:noCompletion private var __height:Int;
	@:noCompletion private var __optimizeForRenderToTexture:Bool;
	@:noCompletion private var __streamingLevels:Int;
	@:noCompletion private var __width:Int;

	@:noCompletion private function new(context:Context3D)
	{
		super();
		__context = context;
	}

	public function dispose():Void
	{
		__flightTexture = null;
	}
}
#else
typedef TextureBase = flash.display3D.textures.TextureBase;
#end
