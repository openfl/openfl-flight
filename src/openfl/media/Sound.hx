package openfl.media;

#if !flash
import flight.Audio as FlightAudio;
import flight.Media as FlightMedia;
import flight.types.AudioResource as FlightAudioResource;
import flight.types.AudioResourceReference as FlightAudioResourceReference;
import flight.types.HasNetHttp as FlightNetHost;
import flight._internal._Float32Array as FlightFloat32Array;
import flight._internal._UInt8Array as FlightUInt8Array;
import haxe.io.Bytes;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.utils.Future;
#if lime
import lime.media.AudioBuffer;
#end
#if (js && html5)
import flight.HostWeb as FlightHostWeb;
#elseif (clay && sys)
import flight.hostClay.HostClay as FlightHostClay;
#elseif (lime && sys)
import flight.hostLime.HostLime as FlightHostLime;
import lime.app.Application as LimeApplication;
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
	@:noCompletion private var __loadGeneration:Int = 0;
	@:noCompletion private var __pendingChannels:Array<Dynamic> = [];
	@:noCompletion private var __urlLoading:Bool = false;
	@:noCompletion private static var __netHost:FlightNetHost;
	@:noCompletion private static var __netHostResolved:Bool;

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
		__loadGeneration++;
		__buffer = null;
		var channels = SoundMixer.__soundChannels.copy();
		for (channel in channels)
		{
			if (channel.__sound == this) channel.stop();
		}
		if (__flightResource != null) FlightAudio.disposeAudioResource(__flightResource);
		__flightResource = null;
		__flightResourceReference = null;
		__pendingChannels = [];
		__urlLoading = false;
	}

	#if lime
	public static function fromAudioBuffer(buffer:AudioBuffer):Sound
	{
		var sound = new Sound();
		sound.__buffer = buffer;
		if (buffer != null && buffer.data != null)
		{
			var bytes:Bytes = cast buffer.data.buffer;
			sound.__flightResource = __createFlightPCMResource(bytes, buffer.bitsPerSample, buffer.channels, buffer.sampleRate);
		}
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
		var generation = ++__loadGeneration;
		url = stream == null ? null : stream.url;
		__flightResourceReference = stream == null ? null : FlightAudio.createExternalAudioResourceReference(stream.url);
		__flightResource = null;
		__urlLoading = true;
		bytesLoaded = 0;
		bytesTotal = 0;
		isBuffering = false;
		dispatchEvent(new Event(Event.OPEN));

		var audioContext = SoundMixer.__getFlightAudioContext();
		var host = __getNetHost();
		if (stream == null || audioContext == null || host == null) return;
		FlightAudio.loadAudioResourceFromUrl(host, audioContext, stream.url).then(function(resource:FlightAudioResource):FlightAudioResource
		{
			__defer(function():Void __completeFlightLoad(generation, resource));
			return resource;
		}, function(error:Dynamic):FlightAudioResource
		{
			__defer(function():Void __failFlightLoad(generation, Std.string(error)));
			return cast null;
		});
	}

	public function loadCompressedDataFromByteArray(bytes:ByteArray, bytesLength:Int):Void
	{
		if (bytes == null || bytesLength <= 0)
		{
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			return;
		}

		var generation = ++__loadGeneration;
		var data = new FlightUInt8Array(bytesLength);
		for (i in 0...bytesLength) data[i] = bytes[bytes.position + i];
		__flightResourceReference = FlightAudio.createEmbeddedAudioResourceReference(data, FlightAudio.detectAudioMimeType(data));
		__flightResource = null;
		__urlLoading = true;

		var audioContext = SoundMixer.__getFlightAudioContext();
		if (audioContext == null)
		{
			__failFlightLoad(generation, "Audio playback is unavailable");
			return;
		}
		FlightAudio.loadAudioResourceFromBytes(audioContext, data, FlightAudio.detectAudioMimeType(data)).then(function(resource:FlightAudioResource):FlightAudioResource
		{
			__completeFlightLoad(generation, resource);
			return resource;
		}, function(error:Dynamic):FlightAudioResource
		{
			__failFlightLoad(generation, Std.string(error));
			return cast null;
		});
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
		if (bytes == null)
		{
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			return;
		}

		var bitsPerSample = format == "float" ? 32 : 16;
		var channels = stereo ? 2 : 1;
		var bytesLength = Std.int(samples * channels * (bitsPerSample / 8));
		var source = Bytes.alloc(bytesLength);
		var bytesPerSample = Std.int(bitsPerSample / 8);
		for (sample in 0...Std.int(bytesLength / bytesPerSample))
		{
			for (byte in 0...bytesPerSample)
			{
				source.set(sample * bytesPerSample + byte, bytes[bytes.position + sample * bytesPerSample + byte]);
			}
		}

		__loadGeneration++;
		__flightResourceReference = null;
		__flightResource = __createFlightPCMResource(source, bitsPerSample, channels, sampleRate);
		__urlLoading = false;
		dispatchEvent(new Event(Event.OPEN));
		dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytes.length, bytes.length));
		dispatchEvent(new Event(Event.COMPLETE));
	}

	public function play(startTime:Float = 0.0, loops:Int = 0, sndTransform:SoundTransform = null):SoundChannel
	{
		if (SoundMixer.__soundChannels.length >= SoundMixer.MAX_ACTIVE_CHANNELS) return null;

		var channelPosition = __urlLoading ? 0 : startTime;
		var flightChannel = __flightResource == null ? null : __playFlightResource(__flightResource, startTime, loops, sndTransform);
		var channel = new SoundChannel(this, flightChannel, sndTransform, channelPosition);
		if (__urlLoading)
		{
			// OpenFL 9.5.2 retains only the most recently requested source while a
			// URL load is pending. Earlier logical channels remain registered, but
			// are never bound to that load's eventual resource.
			__pendingChannels = [{channel: channel, loops: loops, startTime: startTime}];
		}
		return channel;
	}

	@:noCompletion private function __playFlightResource(resource:FlightAudioResource, startTime:Float, loops:Int,
			sndTransform:SoundTransform):Dynamic
	{
		var audioDevice = SoundMixer.__getFlightAudioDevice();
		if (audioDevice == null) return null;
		var transform = sndTransform == null ? new SoundTransform() : sndTransform;
		return FlightMedia.playAudioResource(audioDevice, resource, {
			currentTime: startTime,
			gain: SoundMixer.__soundTransform.volume * transform.volume,
			loops: loops > 1 ? loops - 1 : 0
		});
	}

	@:noCompletion private function __completeFlightLoad(generation:Int, resource:FlightAudioResource):Void
	{
		if (generation != __loadGeneration) return;
		__flightResource = resource;
		__urlLoading = false;
		var byteSize = Std.int(FlightAudio.getAudioResourceByteSize(resource));
		// The portable 9.5.2 properties stay at zero even though the completion
		// progress event reports the decoded resource size.
		dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, byteSize, byteSize));
		dispatchEvent(new Event(Event.COMPLETE));

		var pending = __pendingChannels;
		__pendingChannels = [];
		for (item in pending)
		{
			var channel:SoundChannel = item.channel;
			channel.__bindFlightChannel(__playFlightResource(resource, item.startTime, item.loops, channel.soundTransform));
		}
	}

	@:noCompletion private function __failFlightLoad(generation:Int, message:String):Void
	{
		if (generation != __loadGeneration) return;
		__urlLoading = false;
		__pendingChannels = [];
		dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, message));
	}

	@:noCompletion private static function __createFlightPCMResource(bytes:Bytes, bitsPerSample:Int, channels:Int, sampleRate:Float):FlightAudioResource
	{
		if (bytes == null || channels <= 0 || bitsPerSample <= 0) return FlightAudio.createAudioResource();
		var bytesPerSample = Std.int(bitsPerSample / 8);
		var frameCount = Std.int(bytes.length / (bytesPerSample * channels));
		var output:Array<FlightFloat32Array> = [];
		for (channel in 0...channels) output.push(new FlightFloat32Array(frameCount));
		for (frame in 0...frameCount)
		{
			for (channel in 0...channels)
			{
				var at = (frame * channels + channel) * bytesPerSample;
				output[channel][frame] = switch (bitsPerSample)
				{
					case 8: (bytes.get(at) - 128) / 128;
					case 32: bytes.getFloat(at);
					default:
						var sample = bytes.get(at) | (bytes.get(at + 1) << 8);
						(sample >= 0x8000 ? sample - 0x10000 : sample) / 32768;
				};
			}
		}
		return FlightAudio.createAudioResourceFromSamples(output, sampleRate);
	}

	@:noCompletion private static function __defer(callback:Void->Void):Void
	{
		#if (clay || lime || js)
		callback();
		#else
		haxe.Timer.delay(callback, 0);
		#end
	}

	@:noCompletion private static function __getNetHost():FlightNetHost
	{
		if (__netHost != null || __netHostResolved) return __netHost;

		#if (js && html5)
		__netHost = cast FlightHostWeb.webHostNet;
		__netHostResolved = true;
		#elseif (clay && sys)
		__netHost = cast FlightHostClay.createClayHost();
		__netHostResolved = true;
		#elseif (lime && sys)
		if (LimeApplication.current != null)
		{
			__netHost = cast FlightHostLime.createLimeHost(LimeApplication.current);
			__netHostResolved = true;
		}
		#else
		__netHostResolved = true;
		#end

		return __netHost;
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
