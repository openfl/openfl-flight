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
		// TODO: Allocate a Flight GPU vertex buffer.
	}

	public function dispose():Void
	{
		// TODO: Release the Flight GPU vertex buffer.
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:Int, startVertex:Int, numVertices:Int):Void
	{
		// TODO: Upload vertex bytes through Flight GPU buffers.
	}

	public function uploadFromTypedArray(data:ArrayBufferView, byteLength:Int = -1):Void
	{
		// TODO: Upload typed vertex data through Flight GPU buffers.
	}

	public function uploadFromVector(data:Vector<Float>, startVertex:Int, numVertices:Int):Void
	{
		// TODO: Upload vector vertex data through Flight GPU buffers.
	}
}
#else
typedef VertexBuffer3D = flash.display3D.VertexBuffer3D;
#end
