package openfl.display3D;

#if !flash
import openfl.utils.ByteArray;

/** Represents a vertex/fragment shader pair owned by a Context3D. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display3D.Context3D)
@:final class Program3D
{
	@:noCompletion private var __context:Context3D;
	@:noCompletion private var __format:Context3DProgramFormat;

	@:noCompletion private function new(context3D:Context3D, format:Context3DProgramFormat)
	{
		__context = context3D;
		__format = format;
	}

	public function dispose():Void
	{
		// Flight gap: GL draw seam.
		// Program3D has no Flight program handle because raw program creation,
		// binding, and disposal are not part of the public rendering API.
	}

	public function getAttributeIndex(name:String):Int
	{
		if (__format == AGAL && StringTools.startsWith(name, "va"))
		{
			var index = Std.parseInt(name.substring(2));
			return index == null ? -1 : index;
		}
		return -1;
	}

	public function getConstantIndex(name:String):Int
	{
		if (__format == AGAL && (StringTools.startsWith(name, "vc") || StringTools.startsWith(name, "fc")))
		{
			var index = Std.parseInt(name.substring(2));
			return index == null ? -1 : index;
		}
		return -1;
	}

	public function upload(vertexProgram:ByteArray, fragmentProgram:ByteArray):Void
	{
		// Flight gap: AGAL and GL draw seam.
		// Flight has neither an AGAL compiler nor a public raw shader-program API.
	}

	public function uploadSources(vertexSource:String, fragmentSource:String):Void
	{
		// Flight gap: GL draw seam.
		// Custom Flight materials select registered shader keys; they cannot compile
		// and bind the arbitrary vertex/fragment sources required by Program3D.
	}
}
#else
typedef Program3D = flash.display3D.Program3D;
#end
