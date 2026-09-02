package harness.scenarios;

import openfl.media.Sound;
import openfl.media.SoundLoaderContext;
import openfl.media.SoundMixer;
import openfl.media.SoundTransform;

class SoundScenario {
	public static function run():Dynamic {
		return {
			soundDefaults: testSoundDefaults(),
			transform: testTransform(),
			mixer: testMixer(),
			loaderContext: testLoaderContext()
		};
	}

	private static function testSoundDefaults():Dynamic {
		var sound = new Sound();
		return {
			bytesLoaded: sound.bytesLoaded,
			bytesTotal: sound.bytesTotal,
			length: sound.length,
			isBuffering: sound.isBuffering,
			url: sound.url,
			id3IsNull: sound.id3 == null
		};
	}

	private static function testTransform():Dynamic {
		var defaults = new SoundTransform();
		var assigned = new SoundTransform();
		assigned.volume = 0.75;
		assigned.pan = -0.25;
		assigned.leftToLeft = 0.1;
		assigned.leftToRight = 0.2;
		assigned.rightToLeft = 0.3;
		assigned.rightToRight = 0.4;

		return {
			defaults: transformState(defaults),
			assigned: transformState(assigned)
		};
	}

	private static function testMixer():Dynamic {
		var original = SoundMixer.soundTransform;
		var assigned = new SoundTransform(0.65, 0.35);
		assigned.leftToLeft = 0.15;
		assigned.leftToRight = 0.25;
		assigned.rightToLeft = 0.35;
		assigned.rightToRight = 0.45;
		SoundMixer.soundTransform = assigned;
		var stored = SoundMixer.soundTransform;
		var secondRead = SoundMixer.soundTransform;
		SoundMixer.soundTransform = original;

		return {
			stored: transformState(stored),
			setterCopiesInput: stored != assigned,
			getterReturnsCopy: secondRead != stored
		};
	}

	private static function testLoaderContext():Dynamic {
		var defaults = new SoundLoaderContext();
		var assigned = new SoundLoaderContext(2500, true);
		assigned.bufferTime = 1750;
		assigned.checkPolicyFile = false;

		return {
			defaults: {
				bufferTime: defaults.bufferTime,
				checkPolicyFile: defaults.checkPolicyFile
			},
			assigned: {
				bufferTime: assigned.bufferTime,
				checkPolicyFile: assigned.checkPolicyFile
			}
		};
	}

	private static function transformState(value:SoundTransform):Dynamic {
		return {
			volume: value.volume,
			pan: value.pan,
			leftToLeft: value.leftToLeft,
			leftToRight: value.leftToRight,
			rightToLeft: value.rightToLeft,
			rightToRight: value.rightToRight
		};
	}
}
