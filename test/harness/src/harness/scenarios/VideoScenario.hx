package harness.scenarios;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.Window;
import openfl.media.Video;
import openfl.net.NetStream;

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
		var stage = createStage(640, 480);
		if (Lib.current != null && Lib.current.parent == stage) stage.removeChild(Lib.current);
		stage.addChild(parent);
		video.x = 10;
		video.y = 20;
		parent.addChild(video);
		var parentBounds = video.getBounds(parent);
		var containerBounds = parent.getBounds(parent);
		var stagedHits = {
			origin: video.hitTestPoint(10, 20),
			inside: video.hitTestPoint(11, 21),
			bottomRight: video.hitTestPoint(110, 140),
			outside: video.hitTestPoint(111, 141)
		};
		var stream = new NetStream(null);
		video.attachNetStream(stream);
		video.clear();
		video.attachNetStream(null);

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
				containerBounds: {x: containerBounds.x, y: containerBounds.y, width: containerBounds.width, height: containerBounds.height},
				containerWidth: parent.width,
				containerHeight: parent.height,
				stageIsSet: video.stage == stage,
				videoWidth: video.videoWidth,
				videoHeight: video.videoHeight
			},
			stagedHits: stagedHits,
			zeroSize: {width: zero.width, height: zero.height}
		};
	}

	private static function createStage(width:Int, height:Int):Stage {
		var window:Dynamic = Type.createEmptyInstance(Window);
		#if harness_capture
		Reflect.setField(window, "__width", width);
		Reflect.setField(window, "__height", height);
		Reflect.setField(window, "__scale", 1);
		Reflect.setField(window, "__fullscreen", false);
		#else
		window.width = width;
		window.height = height;
		window.scale = 1;
		window.fullscreen = false;
		#end
		return new Stage(cast window, 0xFFFFFF);
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
