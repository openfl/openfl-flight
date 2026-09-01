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
		// TODO: Release the Flight GPU shader program.
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
		// TODO: Compile and upload AGAL shaders through Flight GPU services.
	}

	public function uploadSources(vertexSource:String, fragmentSource:String):Void
	{
		// TODO: Compile and upload shader sources through Flight GPU services.
	}
}
#else
typedef Program3D = flash.display3D.Program3D;
#end
