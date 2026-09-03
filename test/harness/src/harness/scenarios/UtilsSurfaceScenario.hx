package harness.scenarios;

import haxe.io.Bytes;
import openfl.Lib;
import openfl.Vector;
import openfl.display.MovieClip;
import openfl.net.ObjectEncoding;
import openfl.utils.AGALMiniAssembler;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetManifest;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import openfl.utils.ByteArray;
import openfl.utils.Function;
import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;
import openfl.utils.Namespace;
import openfl.utils.Object as OpenFLObject;
import openfl.utils.PerspectiveMatrix3D;
import openfl.utils.Promise;
import openfl.utils.QName;

class UtilsSurfaceScenario
{
	public static function run():Dynamic
	{
		return {
			byteFactories: testByteFactories(),
			byteStrings: testByteStrings(),
			dataInterfaces: testDataInterfaces(),
			libHelpers: testLibHelpers(),
			assetLookup: testAssetLookup(),
			assetManifest: testAssetManifest(),
			agal: testAGAL(),
			functionAlias: testFunctionAlias(),
			namespace: testNamespace(),
			qname: testQName(),
			object: testObject(),
			perspective: testPerspective(),
			promise: testPromise()
		};
	}

	private static function testByteFactories():Dynamic
	{
		var source = Bytes.ofString("abc");
		var fromBytes = ByteArray.fromBytes(source);
		var fromData = ByteArray.fromBytesData(source.getData());
		return {
			fromBytesLength: fromBytes.length,
			fromBytesPosition: fromBytes.position,
			fromDataLength: fromData.length,
			fromDataPosition: fromData.position
		};
	}

	private static function testByteStrings():Dynamic
	{
		var bytes = new ByteArray();
		bytes.writeMultiByte("hé", "ignored");
		var position = bytes.position;
		var textBytes = new ByteArray();
		for (value in [104, 195, 169]) textBytes.writeByte(value);
		textBytes.position = 1;
		var completeText = textBytes.toString();
		var unknown = new ByteArray();
		unknown.objectEncoding = cast 999;
		unknown.writeObject({value: 1});
		var afterUnknownLength = unknown.length;
		unknown.position = 0;
		var unknownRead = unknown.readObject();
		return {
			positionAfterWrite: position,
			completeText: completeText,
			unknownWriteLength: afterUnknownLength,
			unknownReadIsNull: unknownRead == null,
			unknownReadPosition: unknown.position
		};
	}

	private static function testDataInterfaces():Dynamic
	{
		var bytes = new ByteArray();
		var output:IDataOutput = cast bytes;
		output.writeInt(0x12345678);
		bytes.position = 0;
		var input:IDataInput = cast bytes;
		var externalizable = new ExternalizableProbe(17);
		var externalBytes = new ByteArray();
		externalizable.writeExternal(cast externalBytes);
		externalBytes.position = 0;
		var decoded = new ExternalizableProbe();
		decoded.readExternal(cast externalBytes);
		return {
			bytesAvailable: input.bytesAvailable,
			value: input.readInt(),
			endianMatches: input.endian == output.endian,
			externalizedValue: decoded.value
		};
	}

	private static function testLibHelpers():Dynamic
	{
		var interval = Lib.setInterval(function():Void {}, 1000000);
		var timeout = Lib.setTimeout(function():Void {}, 1000000);
		Lib.clearInterval(interval);
		Lib.clearTimeout(timeout);
		return {
			attachIsMovieClip: Std.isOfType(Lib.attach("unused"), openfl.display.MovieClip),
			definition: Lib.getQualifiedClassName(Lib.getDefinitionByName("openfl.display.Sprite")),
			intervalIsPositive: interval > 0,
			timeoutFollowsInterval: timeout == interval + 1
		};
	}

	private static function testAssetManifest():Dynamic
	{
		var manifest = new AssetManifest();
		manifest.addBitmapData("image.png", "image");
		manifest.addBytes("data.bin");
		manifest.addFont("font.ttf", "font");
		manifest.addSound(["sound.ogg", "sound.mp3"], "sound");
		manifest.addText("copy.txt", "copy");
		var assets:Array<Dynamic> = cast Reflect.field(manifest, "assets");
		return {
			count: assets == null ? -1 : assets.length,
			firstID: assets == null ? null : Reflect.field(assets[0], "id"),
			secondDefaultID: assets == null ? null : Reflect.field(assets[1], "id"),
			soundPathCount: assets == null ? -1 : (cast Reflect.field(assets[3], "pathGroup") : Array<String>).length,
			lastType: assets == null ? null : Std.string(Reflect.field(assets[4], "type"))
		};
	}

	private static function testAssetLookup():Dynamic
	{
		var library = new MovieClipLibrary();
		Assets.registerLibrary("surface-movie", library);
		var first = Assets.getMovieClip("surface-movie:clip");
		var second = Assets.getMovieClip("surface-movie:clip");
		Assets.unloadLibrary("surface-movie");
		return {
			firstIsMovieClip: Std.isOfType(first, MovieClip),
			returnsFreshClips: first != second
		};
	}

	private static function testAGAL():Dynamic
	{
		var assembler = new AGALMiniAssembler(true);
		var code = assembler.assemble("vertex", "mov op, va0\n", 1);
		return {
			verbose: assembler.verbose,
			length: code.length,
			position: code.position,
			endian: code.endian,
			error: assembler.error
		};
	}

	private static function testFunctionAlias():Dynamic
	{
		var functionValue:Function = function(value:Int):Int return value + 1;
		return {callResult: Reflect.callMethod(functionValue, functionValue, [4])};
	}

	private static function testNamespace():Dynamic
	{
		var empty = new Namespace();
		var named = new Namespace("valid", "urn:test");
		var invalid = new Namespace("not valid", "urn:invalid");
		var copied = new Namespace(named);
		var fromQName = new Namespace(new QName("urn:q", "item"));
		return {
			emptyPrefix: empty.prefix,
			emptyURI: empty.uri,
			namedPrefix: named.prefix,
			namedURI: named.uri,
			invalidPrefixIsNull: invalid.prefix == null,
			copyPrefix: copied.prefix,
			fromQNamePrefixIsNull: fromQName.prefix == null,
			fromQNameURI: fromQName.uri
		};
	}

	private static function testQName():Dynamic
	{
		var empty = new QName();
		var named = new QName(new Namespace("p", "urn:test"), "item");
		var copied = new QName(named);
		var local = new QName("only");
		return {
			emptyURI: empty.uri,
			emptyLocal: empty.localName,
			namedURI: named.uri,
			namedLocal: named.localName,
			copiedLocal: copied.localName,
			localURI: local.uri,
			localName: local.localName
		};
	}

	private static function testObject():Dynamic
	{
		var value = new OpenFLObject();
		value["answer"] = 42;
		var fields = [for (field in value) field];
		fields.sort(Reflect.compare);
		return {
			hasAnswer: value.hasOwnProperty("answer"),
			answer: value["answer"],
			fields: fields,
			valueIdentity: value.valueOf() == value,
			missingEnumerable: value.propertyIsEnumerable("missing")
		};
	}

	private static function testPerspective():Dynamic
	{
		var raw = Vector.ofArray([for (index in 0...16) index * 1.0]);
		var matrix = new PerspectiveMatrix3D(raw);
		var constructorRaw = matrix.rawData.copy();
		matrix.perspectiveLH(4, 2, 1, 11);
		return {
			constructorFirst: constructorRaw[0],
			constructorLast: constructorRaw[15],
			projection: [matrix.rawData[0], matrix.rawData[5], matrix.rawData[10], matrix.rawData[14], matrix.rawData[15]]
		};
	}

	private static function testPromise():Dynamic
	{
		var completed:Array<String> = [];
		var progress:Array<String> = [];
		var promise = new Promise<String>();
		promise.future.onComplete(function(value):Void completed.push(value));
		promise.future.onProgress(function(value, total):Void progress.push(value + "/" + total));
		var progressIdentity = promise.progress(1, 2) == promise;
		var completeIdentity = promise.complete("done") == promise;
		promise.progress(2, 2);
		promise.error("late");
		return {
			completed: completed,
			progress: progress,
			progressIdentity: progressIdentity,
			completeIdentity: completeIdentity,
			isComplete: promise.isComplete,
			isError: promise.isError,
			result: promise.future.result()
		};
	}
}

private class ExternalizableProbe implements openfl.utils.IExternalizable
{
	public var value:Int;

	public function new(value:Int = 0)
	{
		this.value = value;
	}

	public function readExternal(input:IDataInput):Void
	{
		value = input.readInt();
	}

	public function writeExternal(output:IDataOutput):Void
	{
		output.writeInt(value);
	}
}

private class MovieClipLibrary extends AssetLibrary
{
	public function new()
	{
		super();
	}

	public override function getMovieClip(id:String):MovieClip
	{
		return id == "clip" ? new MovieClip() : null;
	}

	public override function exists(id:String, type:String):Bool
	{
		return id == "clip" && type == cast(AssetType.MOVIE_CLIP, String);
	}

	public override function isLocal(id:String, type:String):Bool
	{
		return id == "clip" && type == cast(AssetType.MOVIE_CLIP, String);
	}

	public override function unload():Void {}
}
