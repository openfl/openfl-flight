package harness.scenarios;

import openfl.events.Event;
import openfl.media.AudioPlaybackMode;
import openfl.media.CameraPosition;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundMixer;
import openfl.media.Video;
import openfl.net.NetStream;

@:access(openfl.media.SoundChannel)
@:access(openfl.media.SoundMixer)
@:access(openfl.media.Video)
class MediaSurfaceScenario
{
	public static function run():Dynamic
	{
		return {
			soundSurface: testSoundSurface(),
			channelCompletion: testChannelCompletion(),
			mixerSurface: testMixerSurface(),
			videoSampling: testVideoSampling(),
			constants: testConstants()
		};
	}

	private static function testSoundSurface():Dynamic
	{
		var instanceFields = Type.getInstanceFields(Sound);
		var classFields = Type.getClassFields(Sound);
		return {
			hasClose: instanceFields.indexOf("close") >= 0,
			hasCompressedLoader: instanceFields.indexOf("loadCompressedDataFromByteArray") >= 0,
			hasPCMLoader: instanceFields.indexOf("loadPCMFromByteArray") >= 0,
			extractAbsent: instanceFields.indexOf("extract") == -1,
			hasFromFile: classFields.indexOf("fromFile") >= 0,
			hasLoadFromFile: classFields.indexOf("loadFromFile") >= 0,
			hasLoadFromFiles: classFields.indexOf("loadFromFiles") >= 0
		};
	}

	private static function testChannelCompletion():Dynamic
	{
		var sound = new Sound();
		var channel = sound.play();
		var events = 0;
		if (channel != null)
		{
			channel.addEventListener(Event.SOUND_COMPLETE, function(_):Void events++);
			#if harness_capture
			channel.audioSource_onComplete();
			#else
			channel.__flight_onComplete();
			#end
		}
		return {
			channelIsNull: channel == null,
			events: events,
			positionAfterComplete: channel == null ? -1 : channel.position
		};
	}

	private static function testMixerSurface():Dynamic
	{
		var fields = Type.getClassFields(SoundMixer);
		return {
			computeSpectrumAbsent: fields.indexOf("computeSpectrum") == -1,
			audioPlaybackModeAbsent: fields.indexOf("audioPlaybackMode") == -1
		};
	}

	private static function testVideoSampling():Dynamic
	{
		var video = new Video();
		var stream = new NetStream(null);
		video.attachNetStream(stream);
		video.smoothing = true;
		#if harness_capture
		var linear = video.smoothing ? "linear" : "nearest";
		#else
		var linear = video.__flightTexture.sampler.magFilter;
		#end
		video.smoothing = false;
		#if harness_capture
		var nearest = video.smoothing ? "linear" : "nearest";
		#else
		var nearest = video.__flightTexture.sampler.magFilter;
		#end
		video.clear();
		return {
			linear: linear,
			nearest: nearest,
			streamRetainedAfterClear: video.__stream == stream,
			attachCameraAbsent: Type.getInstanceFields(Video).indexOf("attachCamera") == -1
		};
	}

	private static function testConstants():Dynamic
	{
		return {
			audio: [Std.string(AudioPlaybackMode.AMBIENT), Std.string(AudioPlaybackMode.MEDIA), Std.string(AudioPlaybackMode.VOICE)],
			camera: [Std.string(CameraPosition.BACK), Std.string(CameraPosition.FRONT), Std.string(CameraPosition.UNKNOWN)]
		};
	}
}
