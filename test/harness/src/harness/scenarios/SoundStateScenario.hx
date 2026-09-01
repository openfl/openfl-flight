package harness.scenarios;

import openfl.media.Sound;
import openfl.media.SoundMixer;
import openfl.media.SoundTransform;

class SoundStateScenario {
	public static function run():Dynamic {
		var defaultTransform = new SoundTransform();
		var explicitTransform = new SoundTransform(0.6, -0.25);
		explicitTransform.leftToLeft = 0.1;
		explicitTransform.leftToRight = 0.2;
		explicitTransform.rightToLeft = 0.3;
		explicitTransform.rightToRight = 0.4;
		var transformClone = explicitTransform.clone();

		var originalMixerTransform = SoundMixer.soundTransform;
		var mixerInput = new SoundTransform(0.8, 0.15);
		SoundMixer.soundTransform = mixerInput;
		mixerInput.volume = 0.2;
		var mixerStored = SoundMixer.soundTransform;

		var sound = new Sound();
		var channelInput = new SoundTransform(0.7, -0.4);
		var channel = sound.play(250, 2, channelInput);
		var channelIsNull = channel == null;
		var channelDefaults:Dynamic = null;
		var channelMutation:Dynamic = null;
		if (channel != null) {
			var firstTransform = channel.soundTransform;
			firstTransform.volume = 0.1;
			channelDefaults = {
				leftPeak: channel.leftPeak,
				rightPeak: channel.rightPeak,
				position: channel.position,
				volume: channel.soundTransform.volume,
				pan: channel.soundTransform.pan,
				getterReturnsCopy: channel.soundTransform != channel.soundTransform
			};

			channel.position = 475;
			var replacement = new SoundTransform(0.35, 0.9);
			replacement.leftToLeft = 0.8;
			channel.soundTransform = replacement;
			var replaced = channel.soundTransform;
			channel.soundTransform = null;
			channel.stop();
			var positionAfterStop = channel.position;
			var setAfterStop = channel.position = 900;
			channelMutation = {
				volume: replaced.volume,
				pan: replaced.pan,
				leftToLeft: replaced.leftToLeft,
				positionAfterStop: positionAfterStop,
				setAfterStop: setAfterStop,
				positionAfterSetStopped: channel.position
			};
		}

		var stopAllChannel = sound.play();
		SoundMixer.stopAll();
		var stopAllPosition = stopAllChannel == null ? -1 : stopAllChannel.position;
		SoundMixer.soundTransform = originalMixerTransform;

		return {
			transform: {
				defaults: transformState(defaultTransform),
				explicit: transformState(explicitTransform),
				clone: transformState(transformClone),
				cloneDistinct: transformClone != explicitTransform
			},
			mixer: {
				bufferTime: SoundMixer.bufferTime,
				inaccessible: SoundMixer.areSoundsInaccessible(),
				setterCopies: mixerStored != mixerInput,
				storedVolumeAfterInputMutation: mixerStored.volume,
				getterIdentityStable: mixerStored == SoundMixer.soundTransform
			},
			channel: {
				isNull: channelIsNull,
				defaults: channelDefaults,
				mutation: channelMutation,
				stopAllPosition: stopAllPosition
			}
		};
	}

	private static function transformState(value:SoundTransform):Dynamic return {
		volume: value.volume,
		pan: value.pan,
		leftToLeft: value.leftToLeft,
		leftToRight: value.leftToRight,
		rightToLeft: value.rightToLeft,
		rightToRight: value.rightToRight
	};
}
