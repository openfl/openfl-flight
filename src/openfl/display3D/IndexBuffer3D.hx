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
		// Flight gap: GL draw seam.
		// Flight's public API owns indices as part of a managed MeshGeometry and
		// cannot allocate the independently bindable buffer required by Context3D.
	}

	public function dispose():Void
	{
		// Flight gap: GL draw seam.
		// There is no public raw GPU buffer to release until allocation is exposed.
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:Int, startOffset:Int, count:Int):Void
	{
		// Flight gap: GL draw seam.
		// Flight exposes no public raw index-buffer byte upload or partial update.
	}

	public function uploadFromTypedArray(data:ArrayBufferView, byteLength:Int = -1):Void
	{
		// Flight gap: GL draw seam.
		// Flight exposes no public raw index-buffer typed upload or partial update.
	}

	public function uploadFromVector(data:Vector<UInt>, startOffset:Int, count:Int):Void
	{
		// Flight gap: GL draw seam.
		// Flight exposes no public raw index-buffer vector upload or partial update.
	}
}
#else
typedef IndexBuffer3D = flash.display3D.IndexBuffer3D;
#end
