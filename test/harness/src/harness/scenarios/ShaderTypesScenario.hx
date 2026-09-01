package harness.scenarios;

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Shader;
import openfl.display.ShaderData;
import openfl.display.ShaderInput;
import openfl.display.ShaderJob;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;
import openfl.display.ShaderPrecision;
import openfl.events.Event;
import openfl.filters.ShaderFilter;
import openfl.utils.ByteArray;

class ShaderTypesScenario {
	public static function run():Dynamic {
		return {
			shader: captureShader(),
			input: captureInput(),
			parameter: captureParameter(),
			job: captureJob(),
			filter: captureFilter(),
			parameterTypes: captureParameterTypes(),
			precision: capturePrecision()
		};
	}

	private static function captureShader():Dynamic {
		var code = new ByteArray();
		code.writeByte(0x2A);
		var shader = new Shader(code);
		var initialData = shader.data;
		var initial = {
			byteCodeSameReference: Reflect.field(shader, "byteCode") == code,
			dataSameReference: shader.data == initialData,
			dataFields: sortedFields(initialData),
			fragmentSource: shader.glFragmentSource,
			vertexSource: shader.glVertexSource,
			precisionHint: shader.precisionHint,
			programIsNull: shader.program == null,
			glProgramIsNull: shader.glProgram == null
		};

		shader.glVertexSource = "attribute vec2 position;\nuniform mat4 matrix;\nuniform bool enabled;";
		var beforeBoth = sortedFields(shader.data);
		shader.glFragmentSource = "uniform sampler2D bitmap;\nuniform vec4 tint;\nuniform int mode;";
		var reflected = shader.data;
		var position:ShaderParameter<Float> = Reflect.field(reflected, "position");
		var matrix:ShaderParameter<Float> = Reflect.field(reflected, "matrix");
		var enabled:ShaderParameter<Bool> = Reflect.field(reflected, "enabled");
		var bitmap:ShaderInput<BitmapData> = Reflect.field(reflected, "bitmap");
		var tint:ShaderParameter<Float> = Reflect.field(reflected, "tint");
		var mode:ShaderParameter<Int> = Reflect.field(reflected, "mode");

		position.value = [1, 2];
		matrix.value = [for (i in 0...16) i + 0.5];
		enabled.value = [true];
		bitmap.input = new BitmapData(3, 4);
		bitmap.width = 17;
		bitmap.height = 19;
		tint.value = [-1, 0.25, 2, 0.75];
		mode.value = [-7];

		var custom = new ShaderData(code);
		Reflect.setField(custom, "marker", "custom");
		shader.data = custom;
		var customRoundtrip = shader.data == custom && Reflect.field(shader.data, "marker") == "custom";
		shader.data = null;
		var recreated = shader.data;

		return {
			initial: initial,
			beforeBoth: beforeBoth,
			reflectedFields: sortedFields(reflected),
			position: captureParameterValue(position),
			matrix: captureParameterValue(matrix),
			enabled: captureParameterValue(enabled),
			bitmap: captureInputValue(bitmap),
			tint: captureParameterValue(tint),
			mode: captureParameterValue(mode),
			sourceChange: captureSourceChange(),
			customRoundtrip: customRoundtrip,
			recreatedIsNotCustom: recreated != custom,
			recreatedFields: sortedFields(recreated)
		};
	}

	private static function captureSourceChange():Dynamic {
		var shader = new Shader();
		shader.glVertexSource = "attribute vec2 position;";
		shader.glFragmentSource = "uniform vec4 first;";
		var firstData = shader.data;
		var first = Reflect.field(firstData, "first");
		shader.glFragmentSource = "uniform float second;";
		var secondData = shader.data;
		var second = Reflect.field(secondData, "second");
		shader.glFragmentSource = shader.glFragmentSource;
		return {
			dataSameReference: secondData == firstData && shader.data == secondData,
			firstSameReference: Reflect.field(secondData, "first") == first,
			fields: sortedFields(secondData),
			second: captureParameterValue(second)
		};
	}

	private static function captureInput():Dynamic {
		var input = new ShaderInput<BitmapData>();
		var defaults = captureInputValue(input);
		var bitmap = new BitmapData(2, 5);
		input.input = bitmap;
		input.width = -3;
		input.height = 70000;
		return {
			defaults: defaults,
			mutated: captureInputValue(input),
			inputSameReference: input.input == bitmap
		};
	}

	private static function captureParameter():Dynamic {
		var parameter = new ShaderParameter<Float>();
		var defaults = captureParameterValue(parameter);
		var values = [-1.5, 0, 2.25];
		parameter.name = "manual";
		parameter.value = values;
		return {
			defaults: defaults,
			mutated: captureParameterValue(parameter),
			valueSameReference: parameter.value == values
		};
	}

	private static function captureJob():Dynamic {
		var shader = new Shader();
		var target = new ByteArray();
		var completeCount = 0;
		var job = new ShaderJob(shader, target, 7, 8);
		job.addEventListener(Event.COMPLETE, function(_) completeCount++);
		var constructed = captureJobValue(job);
		job.shader = shader;
		job.target = target;
		job.width = -4;
		job.height = 90000;
		var mutated = captureJobValue(job);
		job.cancel();
		job.start();
		job.start(true);
		return {
			constructed: constructed,
			mutated: mutated,
			shaderSameReference: job.shader == shader,
			targetSameReference: job.target == target,
			completeCount: completeCount,
			progressAfterCalls: job.progress
		};
	}

	private static function captureFilter():Dynamic {
		var shader = new Shader();
		var filter = new ShaderFilter(shader);
		var defaults = captureFilterValue(filter, shader);
		filter.bottomExtension = -4;
		filter.leftExtension = 7;
		filter.rightExtension = 11;
		filter.topExtension = 999;
		filter.blendMode = BlendMode.MULTIPLY;
		filter.invalidate();
		var clone:ShaderFilter = cast filter.clone();
		return {
			defaults: defaults,
			mutated: captureFilterValue(filter, shader),
			clone: captureFilterValue(clone, shader),
			cloneIsDistinct: clone != filter
		};
	}

	private static function captureParameterTypes():Array<Dynamic> {
		var values:Array<ShaderParameterType> = [
			ShaderParameterType.BOOL,
			ShaderParameterType.BOOL2,
			ShaderParameterType.BOOL3,
			ShaderParameterType.BOOL4,
			ShaderParameterType.FLOAT,
			ShaderParameterType.FLOAT2,
			ShaderParameterType.FLOAT3,
			ShaderParameterType.FLOAT4,
			ShaderParameterType.INT,
			ShaderParameterType.INT2,
			ShaderParameterType.INT3,
			ShaderParameterType.INT4,
			ShaderParameterType.MATRIX2X2,
			ShaderParameterType.MATRIX2X3,
			ShaderParameterType.MATRIX2X4,
			ShaderParameterType.MATRIX3X2,
			ShaderParameterType.MATRIX3X3,
			ShaderParameterType.MATRIX3X4,
			ShaderParameterType.MATRIX4X2,
			ShaderParameterType.MATRIX4X3,
			ShaderParameterType.MATRIX4X4
		];
		return [for (value in values) {value: (cast value : Int), text: Std.string(value)}];
	}

	private static function capturePrecision():Array<Dynamic> {
		var values = [ShaderPrecision.FAST, ShaderPrecision.FULL];
		return [for (value in values) {value: (cast value : Int), text: Std.string(value)}];
	}

	private static function captureInputValue(input:ShaderInput<BitmapData>):Dynamic {
		return {
			channels: input.channels,
			filter: input.filter,
			height: input.height,
			index: input.index,
			inputIsNull: input.input == null,
			inputWidth: input.input == null ? null : input.input.width,
			inputHeight: input.input == null ? null : input.input.height,
			mipFilter: input.mipFilter,
			name: input.name,
			width: input.width,
			wrap: input.wrap
		};
	}

	private static function captureParameterValue(parameter:Dynamic):Dynamic {
		return {
			index: parameter.index,
			name: parameter.name,
			typeIsNull: parameter.type == null,
			type: parameter.type,
			value: parameter.value
		};
	}

	private static function captureJobValue(job:ShaderJob):Dynamic {
		return {
			height: job.height,
			progress: job.progress,
			shaderIsNull: job.shader == null,
			targetIsNull: job.target == null,
			width: job.width
		};
	}

	private static function captureFilterValue(filter:ShaderFilter, shader:Shader):Dynamic {
		return {
			blendMode: filter.blendMode,
			bottomExtension: filter.bottomExtension,
			leftExtension: filter.leftExtension,
			rightExtension: filter.rightExtension,
			shaderSameReference: filter.shader == shader,
			topExtension: filter.topExtension
		};
	}

	private static function sortedFields(value:Dynamic):Array<String> {
		var fields = Reflect.fields(value);
		fields.sort(Reflect.compare);
		return fields;
	}
}
