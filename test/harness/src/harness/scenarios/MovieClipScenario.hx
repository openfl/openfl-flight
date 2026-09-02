package harness.scenarios;

import openfl.display.MovieClip;

class MovieClipScenario {
	public static function run():Dynamic {
		var clip = new MovieClip();
		var firstScene = clip.currentScene;
		var firstLabels = clip.currentLabels;
		var firstScenes = clip.scenes;
		var initial = captureFrameState(clip);

		clip.gotoAndStop(1);
		var afterGotoAndStop = captureFrameState(clip);
		clip.gotoAndPlay(1);
		var afterGotoAndPlay = captureFrameState(clip);
		clip.nextFrame();
		var afterNextAtEnd = captureFrameState(clip);
		clip.prevFrame();
		var afterPreviousAtStart = captureFrameState(clip);

		clip.play();
		var playingAfterPlay = clip.isPlaying;
		clip.gotoAndPlay(10);
		clip.gotoAndPlay("missing");
		clip.gotoAndStop(10);
		clip.gotoAndStop("missing");
		clip.nextFrame();
		clip.prevFrame();
		clip.nextScene();
		clip.prevScene();
		clip.stop();
		clip.addFrameScript(0, function():Void {});

		clip.enabled = false;
		var disabled = clip.enabled;
		clip.enabled = true;

		return {
			initial: initial,
			navigation: {
				afterGotoAndStop: afterGotoAndStop,
				afterGotoAndPlay: afterGotoAndPlay,
				afterNextAtEnd: afterNextAtEnd,
				afterPreviousAtStart: afterPreviousAtStart
			},
			defaults: {
				currentFrame: clip.currentFrame,
				currentFrameLabel: clip.currentFrameLabel,
				currentLabel: clip.currentLabel,
				currentLabelsLength: firstLabels.length,
				currentSceneName: firstScene.name,
				currentSceneFrames: firstScene.numFrames,
				currentSceneLabelsLength: firstScene.labels.length,
				framesLoaded: clip.framesLoaded,
				isPlaying: clip.isPlaying,
				totalFrames: clip.totalFrames,
				scenesLength: firstScenes.length,
				sceneIsCurrentScene: firstScenes[0] == firstScene,
				enabled: clip.enabled
			},
			mutation: {
				playingAfterPlay: playingAfterPlay,
				disabled: disabled,
				frameAfterNoOps: clip.currentFrame
			},
			copies: {
				labelsAreDistinct: firstLabels != clip.currentLabels,
				scenesAreDistinct: firstScenes != clip.scenes,
				currentSceneIsStable: firstScene == clip.currentScene
			}
		};
	}

	private static function captureFrameState(clip:MovieClip):Dynamic {
		return {
			currentFrame: clip.currentFrame,
			currentFrameLabel: clip.currentFrameLabel,
			currentLabel: clip.currentLabel,
			framesLoaded: clip.framesLoaded,
			isPlaying: clip.isPlaying,
			totalFrames: clip.totalFrames
		};
	}
}
