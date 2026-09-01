package openfl.display3D.textures;

#if !flash
import flight.Texture as FlightTexture;
import haxe.io.ArrayBufferView;
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DTextureFormat;
import openfl.utils.ByteArray;

/** A two-dimensional texture resource. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:final class Texture extends TextureBase
{
	@:noCompletion private function new(context:Context3D, width:Int, height:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool,
			streamingLevels:Int)
	{
		super(context);
		__width = width;
		__height = height;
		__optimizeForRenderToTexture = optimizeForRenderToTexture;
		__streamingLevels = streamingLevels;
		__flightTexture = FlightTexture.createTexture2D({
			sampler: FlightTexture.createSampler({mipmaps: streamingLevels > 0})
		});
	}

	public function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:UInt, async:Bool = false):Void
	{
		// TODO: Upload compressed texture data through Flight GPU services.
	}

	public function uploadFromBitmapData(source:BitmapData, miplevel:UInt = 0, generateMipmap:Bool = false):Void
	{
		if (miplevel == 0) FlightTexture.setTextureSource(__flightTexture, source.__flightBitmap);
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:UInt, miplevel:UInt = 0):Void
	{
		// TODO: Upload texture bytes through Flight GPU services.
	}

	public function uploadFromTypedArray(data:ArrayBufferView, miplevel:UInt = 0):Void
	{
		// TODO: Upload typed texture data through Flight GPU services.
	}
}
#else
typedef Texture = flash.display3D.textures.Texture;
#end
