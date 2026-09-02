package harness.scenarios;

import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.display.Timeline;

class TimelineScenario
{
	public static function run():Dynamic
	{
		var emptyTimeline = new ScenarioTimeline();
		var directSprite = new Sprite();
		emptyTimeline.initializeSprite(directSprite);

		var spriteTimeline = new ScenarioTimeline();
		var sprite = Sprite.fromTimeline(spriteTimeline);

		var movieClipTimeline = new ScenarioTimeline();
		var movieClip = MovieClip.fromTimeline(movieClipTimeline);

		var nullSprite:Sprite = null;
		var nullSpriteThrows = false;
		try
		{
			nullSprite = Sprite.fromTimeline(null);
		}
		catch (_:Dynamic)
		{
			nullSpriteThrows = true;
		}
		var nullMovieClip = MovieClip.fromTimeline(null);

		return {
			emptyTimeline: {
				exists: emptyTimeline != null,
				frameRate: emptyTimeline.frameRate,
				scenesAreNull: emptyTimeline.scenes == null,
				scriptsAreNull: emptyTimeline.scripts == null
			},
			directSpriteInitialization: {
				initializeCalls: emptyTimeline.initializeSpriteCalls,
				name: directSprite.name,
				isSprite: Std.isOfType(directSprite, Sprite)
			},
			spriteFactory: {
				initializeCalls: spriteTimeline.initializeSpriteCalls,
				name: sprite.name,
				isSprite: Std.isOfType(sprite, Sprite)
			},
			movieClipFactory: {
				attachCalls: movieClipTimeline.attachMovieClipCalls,
				name: movieClip.name,
				isMovieClip: Std.isOfType(movieClip, MovieClip),
				currentFrame: movieClip.currentFrame,
				currentSceneIsNull: movieClip.currentScene == null,
				framesLoaded: movieClip.framesLoaded,
				isPlaying: movieClip.isPlaying,
				totalFrames: movieClip.totalFrames
			},
			nullFactories: {
				spriteThrows: nullSpriteThrows,
				spriteIsNull: nullSprite == null,
				movieClipIsValid: Std.isOfType(nullMovieClip, MovieClip),
				movieClipFramesLoaded: nullMovieClip.framesLoaded,
				movieClipTotalFrames: nullMovieClip.totalFrames
			}
		};
	}
}

private class ScenarioTimeline extends Timeline
{
	public var attachMovieClipCalls(default, null):Int = 0;
	public var initializeSpriteCalls(default, null):Int = 0;

	public function new()
	{
		super();
	}

	public override function attachMovieClip(movieClip:MovieClip):Void
	{
		attachMovieClipCalls++;
		movieClip.name = "timeline-movie-clip";
	}

	public override function initializeSprite(sprite:Sprite):Void
	{
		initializeSpriteCalls++;
		sprite.name = "timeline-sprite";
	}
}
