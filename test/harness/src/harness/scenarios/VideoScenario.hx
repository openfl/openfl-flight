package harness.scenarios;

import openfl.display.Sprite;
import openfl.media.Video;

class VideoScenario {
	public static function run():Dynamic {
		var video = new Video();
		var defaults = state(video);
		var hitDefaults = {
			origin: video.hitTestPoint(0, 0),
			inside: video.hitTestPoint(1, 1),
			bottomRight: video.hitTestPoint(320, 240),
			outside: video.hitTestPoint(321, 241)
		};

		video.scaleX = 2;
		video.scaleY = 3;
		var scaledWidth = video.width;
		var scaledHeight = video.height;
		video.width = 100;
		video.height = 120;
		video.smoothing = true;
		video.deblocking = 4;

		var parent = new Sprite();
		video.x = 10;
		video.y = 20;
		parent.addChild(video);
		var parentBounds = video.getBounds(parent);
		video.clear();

		var zero = new Video(0, 0);
		return {
			defaults: defaults,
			hitDefaults: hitDefaults,
			mutation: {
				scaledWidth: scaledWidth,
				scaledHeight: scaledHeight,
				width: video.width,
				height: video.height,
				scaleX: video.scaleX,
				scaleY: video.scaleY,
				smoothing: video.smoothing,
				deblocking: video.deblocking,
				parentIsSet: video.parent == parent,
				bounds: {x: parentBounds.x, y: parentBounds.y, width: parentBounds.width, height: parentBounds.height},
				videoWidth: video.videoWidth,
				videoHeight: video.videoHeight
			},
			zeroSize: {width: zero.width, height: zero.height}
		};
	}

	private static function state(video:Video):Dynamic {
		var bounds = video.getBounds(video);
		return {
			width: video.width,
			height: video.height,
			videoWidth: video.videoWidth,
			videoHeight: video.videoHeight,
			smoothing: video.smoothing,
			deblocking: video.deblocking,
			parentIsNull: video.parent == null,
			bounds: {x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height}
		};
	}
}
