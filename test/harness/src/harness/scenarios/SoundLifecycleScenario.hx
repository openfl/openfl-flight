package harness.scenarios;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.media.ID3Info;
import openfl.media.Sound;
import openfl.media.SoundTransform;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

class SoundLifecycleScenario {
	public static function run():Dynamic {
		var sound = new Sound();
		var firstID3 = sound.id3;
		var secondID3 = sound.id3;
		var defaults = {
			bytesLoaded: sound.bytesLoaded,
			bytesTotal: sound.bytesTotal,
			isBuffering: sound.isBuffering,
			length: sound.length,
			urlIsNull: sound.url == null,
			id3: id3State(firstID3),
			id3IsFresh: firstID3 != secondID3
		};

		var events:Array<String> = [];
		sound.addEventListener(Event.OPEN, function(_):Void events.push("open"));
		sound.addEventListener(ProgressEvent.PROGRESS, function(_):Void events.push("progress"));
		sound.addEventListener(Event.COMPLETE, function(_):Void events.push("complete"));
		sound.addEventListener(IOErrorEvent.IO_ERROR, function(_):Void events.push("ioError"));
		sound.load(new URLRequest("fixture-audio.mp3"));
		var afterLoad = {
			url: sound.url,
			bytesLoaded: sound.bytesLoaded,
			bytesTotal: sound.bytesTotal,
			isBuffering: sound.isBuffering,
			events: events.copy()
		};

		var supplied = new SoundTransform(0.45, -0.3);
		var channel = sound.play(125, 3, supplied);
		supplied.volume = 0.1;
		var relationship = {
			channelIsNull: channel == null,
			position: channel == null ? -1 : channel.position,
			volume: channel == null ? -1 : channel.soundTransform.volume,
			pan: channel == null ? -2 : channel.soundTransform.pan,
			inputWasCopied: channel == null ? false : channel.soundTransform.volume != supplied.volume
		};
		if (channel != null) channel.stop();

		sound.close();
		var afterClose = {
			url: sound.url,
			bytesLoaded: sound.bytesLoaded,
			bytesTotal: sound.bytesTotal,
			isBuffering: sound.isBuffering,
			length: sound.length,
			events: events
		};

		var pcmBytes = new ByteArray();
		for (sample in [0.0, 0.25, -0.25, 0.5]) pcmBytes.writeFloat(sample);
		pcmBytes.position = 0;
		var pcmSound = new Sound();
		var pcmEvents:Array<String> = [];
		pcmSound.addEventListener(Event.OPEN, function(_):Void pcmEvents.push("open"));
		pcmSound.addEventListener(ProgressEvent.PROGRESS, function(_):Void pcmEvents.push("progress"));
		pcmSound.addEventListener(Event.COMPLETE, function(_):Void pcmEvents.push("complete"));
		pcmSound.addEventListener(IOErrorEvent.IO_ERROR, function(_):Void pcmEvents.push("ioError"));
		pcmSound.loadPCMFromByteArray(pcmBytes, 4, "float", false, 4);
		var pcm = {
			bytesPosition: pcmBytes.position,
			events: pcmEvents
		};

		var compressedSound = new Sound();
		var compressedEvents:Array<String> = [];
		compressedSound.addEventListener(IOErrorEvent.IO_ERROR, function(_):Void compressedEvents.push("ioError"));
		compressedSound.loadCompressedDataFromByteArray(new ByteArray(), 0);

		return {
			defaults: defaults,
			afterLoad: afterLoad,
			relationship: relationship,
			afterClose: afterClose,
			pcm: pcm,
			compressedGuardEvents: compressedEvents
		};
	}

	private static function id3State(value:ID3Info):Dynamic return {
		album: value.album,
		artist: value.artist,
		comment: value.comment,
		genre: value.genre,
		songName: value.songName,
		track: value.track,
		year: value.year
	};
}
