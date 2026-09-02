package openfl.display3D;

#if !flash
import haxe.io.ArrayBufferView;
import openfl.Vector;
import openfl.utils.ByteArray;

/** Stores vertex attributes for a Context3D draw call. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display3D.Context3D)
class VertexBuffer3D
{
	@:noCompletion private var __context:Context3D;
	@:noCompletion private var __numVertices:Int;
	@:noCompletion private var __vertexSize:Int;

	@:noCompletion private function new(context3D:Context3D, numVertices:Int, dataPerVertex:Int, bufferUsage:String)
	{
		__context = context3D;
		__numVertices = numVertices;
		__vertexSize = dataPerVertex;
		// Flight gap: GL draw seam.
		// Flight's public API owns buffers as part of a managed MeshGeometry and
		// cannot allocate the independently bindable buffer required by Context3D.
	}

	public function dispose():Void
	{
		// Flight gap: GL draw seam.
		// There is no public raw GPU buffer to release until allocation is exposed.
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:Int, startVertex:Int, numVertices:Int):Void
	{
		// Flight gap: GL draw seam.
		// Flight exposes no public raw vertex-buffer byte upload or partial update.
	}

	public function uploadFromTypedArray(data:ArrayBufferView, byteLength:Int = -1):Void
	{
		// Flight gap: GL draw seam.
		// Flight exposes no public raw vertex-buffer typed upload or partial update.
	}

	public function uploadFromVector(data:Vector<Float>, startVertex:Int, numVertices:Int):Void
	{
		// Flight gap: GL draw seam.
		// Flight exposes no public raw vertex-buffer vector upload or partial update.
	}
}
#else
typedef VertexBuffer3D = flash.display3D.VertexBuffer3D;
#end
