package openfl.display3D;

#if !flash
import haxe.io.ArrayBufferView;
import openfl.Vector;
import openfl.utils.ByteArray;

/** Stores triangle indices for a Context3D draw call. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display3D.Context3D)
@:final class IndexBuffer3D
{
	@:noCompletion private var __context:Context3D;
	@:noCompletion private var __numIndices:Int;

	@:noCompletion private function new(context3D:Context3D, numIndices:Int, bufferUsage:Context3DBufferUsage)
	{
		__context = context3D;
		__numIndices = numIndices;
		// TODO: Allocate a Flight GPU index buffer.
	}

	public function dispose():Void
	{
		// TODO: Release the Flight GPU index buffer.
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:Int, startOffset:Int, count:Int):Void
	{
		// TODO: Upload index bytes through Flight GPU buffers.
	}

	public function uploadFromTypedArray(data:ArrayBufferView, byteLength:Int = -1):Void
	{
		// TODO: Upload typed index data through Flight GPU buffers.
	}

	public function uploadFromVector(data:Vector<UInt>, startOffset:Int, count:Int):Void
	{
		// TODO: Upload vector index data through Flight GPU buffers.
	}
}
#else
typedef IndexBuffer3D = flash.display3D.IndexBuffer3D;
#end
