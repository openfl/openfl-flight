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
		// Flight gap: texture bridge.
		// The public texture API exposes no ATF decoder or compressed-data upload.
	}

	public function uploadFromBitmapData(source:BitmapData, miplevel:UInt = 0, generateMipmap:Bool = false):Void
	{
		if (source == null) return;
		var width = __width >> miplevel;
		var height = __height >> miplevel;
		if (width == 0 && height == 0) return;
		if (width == 0) width = 1;
		if (height == 0) height = 1;
		if (source.width != width || source.height != height)
		{
			var resized = new BitmapData(width, height, true, 0);
			resized.draw(source);
			source = resized;
		}
		if (miplevel == 0) FlightTexture.setTextureSource(__flightTexture, source.__flightBitmap);
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:UInt, miplevel:UInt = 0):Void
	{
		// Flight gap: texture bridge.
		// Only TextureSource objects can be attached publicly; raw bytes and
		// arbitrary mip-level uploads are not exposed.
	}

	public function uploadFromTypedArray(data:ArrayBufferView, miplevel:UInt = 0):Void
	{
		// Flight gap: texture bridge.
		// Only TextureSource objects can be attached publicly; typed pixels and
		// arbitrary mip-level uploads are not exposed.
	}
}
#else
typedef Texture = flash.display3D.textures.Texture;
#end
