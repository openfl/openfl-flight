package openfl.display;

#if !flash
import openfl.display3D.Context3D;
import openfl.display3D.Program3D;
import openfl.utils.ByteArray;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.ShaderInput)
@:access(openfl.display.ShaderParameter)
class Shader
{
	public var byteCode(null, default):ByteArray;
	public var data(get, set):ShaderData;
	public var glFragmentSource(get, set):String;
	@SuppressWarnings("checkstyle:Dynamic") public var glProgram(default, null):Dynamic;
	public var glVertexSource(get, set):String;
	public var precisionHint:ShaderPrecision;
	public var program:Program3D;

	@:noCompletion private var __alpha:ShaderParameter<Float>;
	@:noCompletion private var __bitmap:ShaderInput<BitmapData>;
	@:noCompletion private var __colorMultiplier:ShaderParameter<Float>;
	@:noCompletion private var __colorOffset:ShaderParameter<Float>;
	@:noCompletion private var __context:Context3D;
	@:noCompletion private var __data:ShaderData;
	@:noCompletion private var __glFragmentSource:String;
	@:noCompletion private var __glSourceDirty:Bool;
	@:noCompletion private var __glVertexSource:String;
	@:noCompletion private var __hasColorTransform:ShaderParameter<Bool>;
	@:noCompletion private var __inputBitmapData:Array<ShaderInput<BitmapData>>;
	@:noCompletion private var __isGenerated:Bool;
	@:noCompletion private var __matrix:ShaderParameter<Float>;
	@:noCompletion private var __numPasses:Int;
	@:noCompletion private var __paramBool:Array<ShaderParameter<Bool>>;
	@:noCompletion private var __paramFloat:Array<ShaderParameter<Float>>;
	@:noCompletion private var __paramInt:Array<ShaderParameter<Int>>;
	@:noCompletion private var __position:ShaderParameter<Float>;
	@:noCompletion private var __textureCoord:ShaderParameter<Float>;
	@:noCompletion private var __texture:ShaderInput<BitmapData>;
	@:noCompletion private var __textureSize:ShaderParameter<Float>;

	public function new(code:ByteArray = null)
	{
		byteCode = code;
		precisionHint = FULL;
		__data = new ShaderData(code);
		__glSourceDirty = true;
		__inputBitmapData = [];
		__paramBool = [];
		__paramFloat = [];
		__paramInt = [];
		__numPasses = 1;
	}

	@:noCompletion private function __clearUseArray():Void {}
	@:noCompletion private function __disable():Void {}
	@:noCompletion private function __disableGL():Void {}
	@:noCompletion private function __enable():Void {}
	@:noCompletion private function __enableGL():Void {}
	@:noCompletion private function __init():Void
	{
		// TODO (Flight): compile and bind shader programs.
		__glSourceDirty = false;
	}
	@:noCompletion private function __initGL():Void
	{
		__init();
	}
	@:noCompletion private function __processGLData(source:String, storageType:String):Void {}
	@:noCompletion private function __update():Void {}
	@:noCompletion private function __updateFromBuffer(shaderBuffer:Dynamic, bufferOffset:Int):Void {}
	@:noCompletion private function __updateGL():Void {}
	@:noCompletion private function __updateGLFromBuffer(shaderBuffer:Dynamic, bufferOffset:Int):Void {}

	@:noCompletion private function get_data():ShaderData
	{
		if (__data == null) __data = new ShaderData(byteCode);
		return __data;
	}

	@:noCompletion private function set_data(value:ShaderData):ShaderData
	{
		return __data = value;
	}

	@:noCompletion private function get_glFragmentSource():String
	{
		return __glFragmentSource;
	}

	@:noCompletion private function set_glFragmentSource(value:String):String
	{
		__glSourceDirty = true;
		return __glFragmentSource = value;
	}

	@:noCompletion private function get_glVertexSource():String
	{
		return __glVertexSource;
	}

	@:noCompletion private function set_glVertexSource(value:String):String
	{
		__glSourceDirty = true;
		return __glVertexSource = value;
	}
}
#else
typedef Shader = flash.display.Shader;
#end
