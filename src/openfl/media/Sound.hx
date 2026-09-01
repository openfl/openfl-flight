package openfl.media;

#if !flash
import flight.Audio as FlightAudio;
import flight.types.AudioResource as FlightAudioResource;
import flight.types.AudioResourceReference as FlightAudioResourceReference;
import flight._internal._UInt8Array as FlightUInt8Array;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import openfl.utils.Future;
#if lime
import lime.media.AudioBuffer;
#end

/**
	Loads and plays audio. The public OpenFL API is available while decoding,
	streaming, and playback await Flight audio support.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.media.SoundMixer)
@:access(openfl.media.SoundChannel)
class Sound extends EventDispatcher
{
	public var bytesLoaded(default, null):Int;
	public var bytesTotal(default, null):Int;
	public var id3(get, never):ID3Info;
	public var isBuffering(default, null):Bool;
	public var length(get, never):Float;
	public var url(default, null):String;

	@:noCompletion private var __buffer:Dynamic;
	@:noCompletion private var __flightResource:FlightAudioResource;
	@:noCompletion private var __flightResourceReference:FlightAudioResourceReference;
	@:noCompletion private var __urlLoading:Bool = false;

	#if (js && html5)
	public var sampleRate(get, never):Int;
	#end

	#if lime_openal
	public var sampleRate(get, never):Int;
	#end

	public function new(stream:URLRequest = null, context:SoundLoaderContext = null)
	{
		super(this);
		bytesLoaded = 0;
		bytesTotal = 0;
		isBuffering = false;
		url = null;

		if (stream != null) load(stream, context);
	}

	public function close():Void
	{
		__buffer = null;
		__flightResource = null;
		__flightResourceReference = null;
		__urlLoading = false;
		// TODO: Cancel decoding and active playback through Flight audio.
	}

	#if lime
	public static function fromAudioBuffer(buffer:AudioBuffer):Sound
	{
		var sound = new Sound();
		sound.__buffer = buffer;
		return sound;
	}
	#end

	public static function fromFile(path:String):Sound
	{
		// TODO: Decode local audio through Flight.
		return null;
	}

	public function load(stream:URLRequest, context:SoundLoaderContext = null):Void
	{
		url = stream == null ? null : stream.url;
		__flightResourceReference = stream == null ? null : FlightAudio.createExternalAudioResourceReference(stream.url);
		__flightResource = null;
		__urlLoading = true;
		bytesLoaded = 0;
		bytesTotal = 0;
		isBuffering = false;
		dispatchEvent(new Event(Event.OPEN));
	}

	public function loadCompressedDataFromByteArray(bytes:ByteArray, bytesLength:Int):Void
	{
		if (bytes == null) return;
		var length = Std.int(Math.min(bytes.length, Math.max(0, bytesLength)));
		var data = new FlightUInt8Array(length);
		for (i in 0...length) data[i] = bytes[i];
		__flightResourceReference = FlightAudio.createEmbeddedAudioResourceReference(data, FlightAudio.detectAudioMimeType(data));
		__flightResource = null;
	}

	public static function loadFromFile(path:String):Future<Sound>
	{
		return cast Future.withError("Flight audio loading is not implemented");
	}

	public static function loadFromFiles(paths:Array<String>):Future<Sound>
	{
		return cast Future.withError("Flight audio loading is not implemented");
	}

	public function loadPCMFromByteArray(bytes:ByteArray, samples:Int, format:String = "float", stereo:Bool = true, sampleRate:Float = 44100):Void
	{
		// TODO: Upload PCM audio through Flight.
	}

	public function play(startTime:Float = 0.0, loops:Int = 0, sndTransform:SoundTransform = null):SoundChannel
	{
		// TODO: Start playback through Flight audio.
		return new SoundChannel(this, null, sndTransform, __urlLoading ? 0 : startTime);
	}

	#if (js && html5)
	@:noCompletion private function get_sampleRate():Int
	{
		return 44100;
	}
	#end

	#if lime_openal
	@:noCompletion private function get_sampleRate():Int
	{
		return 44100;
	}
	#end

	@:noCompletion private function get_id3():ID3Info
	{
		return new ID3Info();
	}

	@:noCompletion private function get_length():Float
	{
		return __flightResource == null ? 0 : FlightAudio.getAudioResourceDuration(__flightResource) * 1000;
	}
}
#else
typedef Sound = flash.media.Sound;
#end
