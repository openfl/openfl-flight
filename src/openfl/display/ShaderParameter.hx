package openfl.display;

#if !flash
import openfl.display3D.Context3D;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
#if (!js && !display)
@:generic
#end
@:final class ShaderParameter<T>
{
	@SuppressWarnings("checkstyle:Dynamic") public var index(default, null):Dynamic;
	@:noCompletion @:dox(hide) @SuppressWarnings("checkstyle:FieldDocComment") public var name(default, set):String;
	public var type(default, null):ShaderParameterType;
	public var value:Array<T>;

	@:noCompletion private var __arrayLength:Int;
	@:noCompletion private var __isBool:Bool;
	@:noCompletion private var __isFloat:Bool;
	@:noCompletion private var __isInt:Bool;
	@:noCompletion private var __isUniform:Bool;
	@:noCompletion private var __length:Int;
	@:noCompletion private var __uniformMatrix:Dynamic;
	@:noCompletion private var __useArray:Bool;

	public function new()
	{
		index = 0;
	}

	@:noCompletion private function __disableGL(context:Context3D):Void
	{
		// TODO (Flight): disable the parameter in the active shader.
	}

	@:noCompletion private function __updateGL(context:Context3D, overrideValue:Array<T> = null):Void
	{
		// TODO (Flight): upload the parameter to the active shader.
	}

	@:noCompletion private function __updateGLFromBuffer(context:Context3D, buffer:Dynamic, position:Int, length:Int, bufferOffset:Int):Void
	{
		// TODO (Flight): upload a buffered parameter.
	}

	@:noCompletion private function set_name(value:String):String
	{
		return name = value;
	}
}
#else
typedef ShaderParameter<T> = flash.display.ShaderParameter<T>;
#end
