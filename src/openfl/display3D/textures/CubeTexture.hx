package openfl.display3D.textures;

#if !flash
import flight.Texture as FlightTexture;
import haxe.io.ArrayBufferView;
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DTextureFormat;
import openfl.utils.ByteArray;

/** A six-sided cube-map texture resource. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:final class CubeTexture extends TextureBase
{
	@:noCompletion private var __size:Int;

	@:noCompletion private function new(context:Context3D, size:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool, streamingLevels:Int)
	{
		super(context);
		__size = size;
		__width = size;
		__height = size;
		__optimizeForRenderToTexture = optimizeForRenderToTexture;
		__streamingLevels = streamingLevels;
		__flightTexture = FlightTexture.createCubeTexture({
			sampler: FlightTexture.createSampler({mipmaps: streamingLevels > 0})
		});
	}

	public function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:UInt, async:Bool = false):Void
	{
		// Flight gap: texture bridge.
		// The public cube-texture API exposes no ATF decoder or compressed-data upload.
	}

	public function uploadFromBitmapData(source:BitmapData, side:UInt, miplevel:UInt = 0, generateMipmap:Bool = false):Void
	{
		if (miplevel == 0) FlightTexture.setCubeTextureFace(cast __flightTexture, side, source.__flightBitmap);
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:UInt, side:UInt, miplevel:UInt = 0):Void
	{
		// Flight gap: texture bridge.
		// Cube faces accept TextureSource objects publicly; raw bytes and
		// arbitrary mip-level uploads are not exposed.
	}

	public function uploadFromTypedArray(data:ArrayBufferView, side:UInt, miplevel:UInt = 0):Void
	{
		// Flight gap: texture bridge.
		// Cube faces accept TextureSource objects publicly; typed pixels and
		// arbitrary mip-level uploads are not exposed.
	}
}
#else
typedef CubeTexture = flash.display3D.textures.CubeTexture;
#end
