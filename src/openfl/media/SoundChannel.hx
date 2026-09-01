package openfl.media;

#if !flash
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
	@:noCompletion private var __position:Float;
	@:noCompletion private var __sound:Sound;
	@:noCompletion private var __soundTransform:SoundTransform;

	@:noCompletion private function new(sound:Sound, audioSource:Dynamic = null, soundTransform:SoundTransform = null):Void
	{
		super(this);
		__sound = sound;
		__position = 0;
		__isValid = true;
		leftPeak = 0;
		rightPeak = 0;
		__soundTransform = soundTransform == null ? new SoundTransform() : soundTransform.clone();
		SoundMixer.__registerSoundChannel(this);
		// TODO: Bind this channel to a Flight audio source.
	}

	public function stop():Void
	{
		if (!__isValid) return;
		__isValid = false;
		SoundMixer.__unregisterSoundChannel(this);
		// TODO: Stop and release the Flight audio source.
	}

	@:noCompletion private function __startSampleData():Void
	{
		// TODO: Stream generated sample data through Flight audio.
	}

	@:noCompletion private function __updateTransform():Void
	{
		// TODO: Apply the combined channel and mixer transforms through Flight.
	}

	@:noCompletion private function get_position():Float
	{
		return __position;
	}

	@:noCompletion private function set_position(value:Float):Float
	{
		return __position = value;
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
}
#else
typedef SoundChannel = flash.media.SoundChannel;
#end
