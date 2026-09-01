package openfl.media;

#if !flash
import flight.Media as FlightMedia;
import flight.Signals as FlightSignals;
import flight.types.AudioChannel as FlightAudioChannel;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/** Controls one sound playback instance. **/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.media.Sound)
@:access(openfl.media.SoundMixer)
@:final @:keep class SoundChannel extends EventDispatcher
{
	public var leftPeak(default, null):Float;
	public var position(get, set):Float;
	public var rightPeak(default, null):Float;
	public var soundTransform(get, set):SoundTransform;

	@:noCompletion private var __isValid:Bool;
	@:noCompletion private var __flightChannel:FlightAudioChannel;
	@:noCompletion private var __position:Float;
	@:noCompletion private var __sound:Sound;
	@:noCompletion private var __soundTransform:SoundTransform;

	@:noCompletion private function new(sound:Sound, audioSource:FlightAudioChannel = null, soundTransform:SoundTransform = null, position:Float = 0):Void
	{
		super(this);
		__sound = sound;
		__position = position;
		__flightChannel = audioSource;
		__isValid = true;
		leftPeak = 1;
		rightPeak = 1;
		__soundTransform = soundTransform == null ? new SoundTransform() : soundTransform.clone();
		SoundMixer.__registerSoundChannel(this);
		__bindFlightChannel(__flightChannel);
	}

	public function stop():Void
	{
		if (!__isValid) return;
		__isValid = false;
		SoundMixer.__unregisterSoundChannel(this);
		if (__flightChannel != null) FlightMedia.stopAudioChannel(__flightChannel);
		__flightChannel = null;
	}

	@:noCompletion private function __startSampleData():Void
	{
	}

	@:noCompletion private function __bindFlightChannel(channel:FlightAudioChannel):Void
	{
		if (channel == null) return;
		if (!__isValid)
		{
			FlightMedia.stopAudioChannel(channel);
			return;
		}
		__flightChannel = channel;
		FlightSignals.connectSignal(channel.onComplete, __flight_onComplete);
		__updateTransform();
	}

	@:noCompletion private function __updateTransform():Void
	{
		if (__flightChannel != null)
		{
			FlightMedia.setAudioChannelGain(__flightChannel, SoundMixer.__soundTransform.volume * __soundTransform.volume);
		}
	}

	@:noCompletion private function get_position():Float
	{
		if (!__isValid) return 0;
		if (__flightChannel != null) return FlightMedia.getAudioChannelCurrentTime(__flightChannel);
		return __position;
	}

	@:noCompletion private function set_position(value:Float):Float
	{
		if (!__isValid) return 0;
		__position = value;
		if (__flightChannel != null) FlightMedia.setAudioChannelCurrentTime(__flightChannel, value);
		return value;
	}

	@:noCompletion private function get_soundTransform():SoundTransform
	{
		return __soundTransform.clone();
	}

	@:noCompletion private function set_soundTransform(value:SoundTransform):SoundTransform
	{
		if (value != null) __soundTransform = value.clone();
		__updateTransform();
		return value;
	}

	@:noCompletion private function __flight_onComplete():Void
	{
		if (!__isValid) return;
		__isValid = false;
		__flightChannel = null;
		SoundMixer.__unregisterSoundChannel(this);
		dispatchEvent(new Event(Event.SOUND_COMPLETE));
	}
}
#else
typedef SoundChannel = flash.media.SoundChannel;
#end
