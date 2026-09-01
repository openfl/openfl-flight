package openfl.display;

#if !flash
import flight.Effects as FlightEffects;
import flight.types.RenderEffect;
import haxe.crypto.Md5;
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
	@:noCompletion private var __flightEffect:RenderEffect;
	@:noCompletion private var __flightShaderKey:String;
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

	@:noCompletion private function __clearUseArray():Void
	{
		for (parameter in __paramBool) parameter.__useArray = false;
		for (parameter in __paramFloat) parameter.__useArray = false;
		for (parameter in __paramInt) parameter.__useArray = false;
	}

	@:noCompletion private function __disable():Void {}
	@:noCompletion private function __disableGL():Void {}
	@:noCompletion private function __enable():Void {}
	@:noCompletion private function __enableGL():Void {}

	@:noCompletion private function __getFlightEffect():RenderEffect
	{
		__init();
		__syncFlightEffect();
		return __flightEffect;
	}

	@:noCompletion private function __init():Void
	{
		if (__data == null) __data = new ShaderData(null);

		if (__glFragmentSource != null && __glVertexSource != null && (program == null || __glSourceDirty))
		{
			__initGL();
		}
	}

	@:noCompletion private function __initGL():Void
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;
			program = null;
			glProgram = null;

			__inputBitmapData = [];
			__paramBool = [];
			__paramFloat = [];
			__paramInt = [];

			__processGLData(__glVertexSource, "attribute");
			__processGLData(__glVertexSource, "uniform");
			__processGLData(__glFragmentSource, "uniform");
		}

		__syncFlightEffect();
	}

	@:noCompletion private function __processGLData(source:String, storageType:String):Void
	{
		if (source == null) return;

		var lastMatch = 0;
		var regex = storageType == "uniform"
			? ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/
			: ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;

		while (regex.matchSub(source, lastMatch))
		{
			var position = regex.matchedPos();
			lastMatch = position.pos + position.len;
			var type = regex.matched(1);
			var name = regex.matched(2);
			if (StringTools.startsWith(name, "gl_")) continue;

			var isUniform = storageType == "uniform";
			if (StringTools.startsWith(type, "sampler"))
			{
				var input = new ShaderInput<BitmapData>();
				input.name = name;
				input.__isUniform = isUniform;
				__inputBitmapData.push(input);

				switch (name)
				{
					case "openfl_Texture": __texture = input;
					case "bitmap": __bitmap = input;
					default:
				}

				Reflect.setField(__data, name, input);
				if (__isGenerated) Reflect.setField(this, name, input);
			}
			else if (!Reflect.hasField(__data, name) || Reflect.field(__data, name) == null)
			{
				var parameterType:ShaderParameterType = switch (type)
				{
					case "bool": BOOL;
					case "double", "float": FLOAT;
					case "int", "uint": INT;
					case "bvec2": BOOL2;
					case "bvec3": BOOL3;
					case "bvec4": BOOL4;
					case "ivec2", "uvec2": INT2;
					case "ivec3", "uvec3": INT3;
					case "ivec4", "uvec4": INT4;
					case "vec2", "dvec2": FLOAT2;
					case "vec3", "dvec3": FLOAT3;
					case "vec4", "dvec4": FLOAT4;
					case "mat2", "mat2x2": MATRIX2X2;
					case "mat2x3": MATRIX2X3;
					case "mat2x4": MATRIX2X4;
					case "mat3x2": MATRIX3X2;
					case "mat3", "mat3x3": MATRIX3X3;
					case "mat3x4": MATRIX3X4;
					case "mat4x2": MATRIX4X2;
					case "mat4x3": MATRIX4X3;
					case "mat4", "mat4x4": MATRIX4X4;
					default: null;
				};

				var length = switch (parameterType)
				{
					case BOOL2, INT2, FLOAT2: 2;
					case BOOL3, INT3, FLOAT3: 3;
					case BOOL4, INT4, FLOAT4, MATRIX2X2: 4;
					case MATRIX3X3: 9;
					case MATRIX4X4: 16;
					default: 1;
				};
				var arrayLength = switch (parameterType)
				{
					case MATRIX2X2: 2;
					case MATRIX3X3: 3;
					case MATRIX4X4: 4;
					default: 1;
				};

				switch (parameterType)
				{
					case BOOL, BOOL2, BOOL3, BOOL4:
						var parameter = new ShaderParameter<Bool>();
						__configureParameter(parameter, name, parameterType, length, arrayLength, isUniform);
						parameter.__isBool = true;
						__paramBool.push(parameter);
						if (name == "openfl_HasColorTransform") __hasColorTransform = parameter;
						Reflect.setField(__data, name, parameter);
						if (__isGenerated) Reflect.setField(this, name, parameter);

					case INT, INT2, INT3, INT4:
						var parameter = new ShaderParameter<Int>();
						__configureParameter(parameter, name, parameterType, length, arrayLength, isUniform);
						parameter.__isInt = true;
						__paramInt.push(parameter);
						Reflect.setField(__data, name, parameter);
						if (__isGenerated) Reflect.setField(this, name, parameter);

					default:
						var parameter = new ShaderParameter<Float>();
						__configureParameter(parameter, name, parameterType, length, arrayLength, isUniform);
						parameter.__isFloat = true;
						__paramFloat.push(parameter);
						if (StringTools.startsWith(name, "openfl_"))
						{
							switch (name)
							{
								case "openfl_Alpha": __alpha = parameter;
								case "openfl_ColorMultiplier": __colorMultiplier = parameter;
								case "openfl_ColorOffset": __colorOffset = parameter;
								case "openfl_Matrix": __matrix = parameter;
								case "openfl_Position": __position = parameter;
								case "openfl_TextureCoord": __textureCoord = parameter;
								case "openfl_TextureSize": __textureSize = parameter;
								default:
							}
						}
						Reflect.setField(__data, name, parameter);
						if (__isGenerated) Reflect.setField(this, name, parameter);
				}
			}
		}
	}

	@:noCompletion private function __configureParameter(parameter:Dynamic, name:String, type:ShaderParameterType, length:Int,
		arrayLength:Int, isUniform:Bool):Void
	{
		parameter.name = name;
		parameter.type = type;
		parameter.__arrayLength = arrayLength;
		parameter.__isUniform = isUniform;
		parameter.__length = length;
	}

	@:noCompletion private function __syncFlightEffect():Void
	{
		if (__glFragmentSource == null)
		{
			__flightEffect = null;
			__flightShaderKey = null;
			return;
		}

		__flightShaderKey = "openfl.shader." + Md5.encode((__glVertexSource == null ? "" : __glVertexSource) + "\u0000" + __glFragmentSource);
		var uniforms:Dynamic = {};
		for (parameter in __paramBool) __setFlightUniform(uniforms, parameter.name, cast parameter.value);
		for (parameter in __paramFloat) __setFlightUniform(uniforms, parameter.name, cast parameter.value);
		for (parameter in __paramInt) __setFlightUniform(uniforms, parameter.name, cast parameter.value);

		var options:Dynamic = {shaderKey: __flightShaderKey};
		if (Reflect.fields(uniforms).length > 0) Reflect.setField(options, "uniforms", uniforms);
		__flightEffect = cast FlightEffects.createCustomShaderEffect(cast options);
	}

	@:noCompletion private function __setFlightUniform(uniforms:Dynamic, name:String, value:Array<Dynamic>):Void
	{
		if (name == null || value == null || value.length == 0) return;
		var converted:Array<Float> = [];
		for (item in value)
		{
			converted.push(Std.isOfType(item, Bool) ? (item ? 1 : 0) : cast item);
		}
		Reflect.setField(uniforms, name, converted.length == 1 ? converted[0] : converted);
	}

	@:noCompletion private function __update():Void {}
	@:noCompletion private function __updateFromBuffer(shaderBuffer:Dynamic, bufferOffset:Int):Void {}
	@:noCompletion private function __updateGL():Void {}
	@:noCompletion private function __updateGLFromBuffer(shaderBuffer:Dynamic, bufferOffset:Int):Void {}

	@:noCompletion private function get_data():ShaderData
	{
		if (__glSourceDirty || __data == null) __init();
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
		if (value != __glFragmentSource) __glSourceDirty = true;
		return __glFragmentSource = value;
	}

	@:noCompletion private function get_glVertexSource():String
	{
		return __glVertexSource;
	}

	@:noCompletion private function set_glVertexSource(value:String):String
	{
		if (value != __glVertexSource) __glSourceDirty = true;
		return __glVertexSource = value;
	}
}
#else
typedef Shader = flash.display.Shader;
#end
