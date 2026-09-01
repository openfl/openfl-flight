package openfl.display3D.textures;

#if !flash
import flight.Texture as FlightTexture;
import haxe.io.ArrayBufferView;
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.utils.ByteArray;

/** A non-power-of-two rectangular texture resource. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:final class RectangleTexture extends TextureBase
{
	@:noCompletion private function new(context:Context3D, width:Int, height:Int, format:String, optimizeForRenderToTexture:Bool)
	{
		super(context);
		__width = width;
		__height = height;
		__optimizeForRenderToTexture = optimizeForRenderToTexture;
		__flightTexture = FlightTexture.createTexture2D();
	}

	public function uploadFromBitmapData(source:BitmapData):Void
	{
		FlightTexture.setTextureSource(__flightTexture, source.__flightBitmap);
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:UInt):Void
	{
		// TODO: Upload rectangular texture bytes through Flight GPU services.
	}

	public function uploadFromTypedArray(data:ArrayBufferView):Void
	{
		// TODO: Upload typed rectangular texture data through Flight GPU services.
	}
}
#else
typedef RectangleTexture = flash.display3D.textures.RectangleTexture;
#end
