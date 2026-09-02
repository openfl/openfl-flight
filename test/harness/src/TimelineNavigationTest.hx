import openfl.display.FrameLabel;
import openfl.display.FrameScript;
import openfl.display.MovieClip;
import openfl.display.Scene;
import openfl.display.Timeline;

class TimelineNavigationTest
{
	public static function main():Void
	{
		var timeline = new NavigationTimeline();
		var clip = MovieClip.fromTimeline(timeline);
		assertState(clip, "intro", 1, "start", "start", "start,middle");

		clip.gotoAndStop(2);
		assertState(clip, "intro", 2, "middle", "middle", "start,middle");
		assertEquals(2, timeline.lastEnteredFrame(), "intro frame 2 uses global frame 2");

		clip.nextScene();
		assertState(clip, "outro", 1, "end", "end", "end,last");
		assertEquals(3, timeline.lastEnteredFrame(), "nextScene enters first global frame of outro");

		clip.gotoAndStop("last");
		assertState(clip, "outro", 3, "last", "last", "end,last");
		assertEquals(5, timeline.lastEnteredFrame(), "scene label resolves to global frame");

		clip.prevScene();
		assertState(clip, "intro", 1, "start", "start", "start,middle");

		clip.gotoAndPlay(2, "outro");
		assertState(clip, "outro", 2, "end", null, "end,last");
		assertEquals(true, clip.isPlaying, "gotoAndPlay starts playback");
		assertEquals(4, timeline.lastEnteredFrame(), "explicit scene frame is scene-relative");
		clip.stop();

		clip.gotoAndStop("middle", "intro");
		assertState(clip, "intro", 2, "middle", "middle", "start,middle");
		clip.nextFrame();
		assertState(clip, "outro", 1, "end", "end", "end,last");
		clip.prevFrame();
		assertState(clip, "intro", 2, "middle", "middle", "start,middle");

		timeline.scriptCalls = [];
		clip.gotoAndStop(1, "intro");
		assertEquals("first,second", timeline.scriptCalls.join(","), "same-frame scripts retain declaration order");

		Sys.println("PASS display/timeline-navigation");
	}

	private static function assertState(clip:MovieClip, scene:String, frame:Int, label:String, frameLabel:String, labels:String):Void
	{
		assertEquals(scene, clip.currentScene.name, "currentScene");
		assertEquals(frame, clip.currentFrame, "currentFrame");
		assertEquals(label, clip.currentLabel, "currentLabel");
		assertEquals(frameLabel, clip.currentFrameLabel, "currentFrameLabel");
		assertEquals(labels, [for (value in clip.currentLabels) value.name].join(","), "currentLabels");
	}

	private static function assertEquals(expected:Dynamic, actual:Dynamic, description:String):Void
	{
		if (expected != actual) throw '$description: expected $expected but got $actual';
	}
}

private class NavigationTimeline extends Timeline
{
	public var enteredFrames:Array<Int> = [];
	public var scriptCalls:Array<String> = [];

	public function new()
	{
		super();
		scenes = [
			new Scene("intro", [new FrameLabel("start", 1), new FrameLabel("middle", 2)], 2),
			new Scene("outro", [new FrameLabel("end", 1), new FrameLabel("last", 3)], 3)
		];
		scripts = [
			new FrameScript(function(_:MovieClip):Void scriptCalls.push("first"), 1),
			new FrameScript(function(_:MovieClip):Void scriptCalls.push("second"), 1)
		];
	}

	public override function enterFrame(frame:Int):Void
	{
		enteredFrames.push(frame);
	}

	public function lastEnteredFrame():Null<Int>
	{
		return enteredFrames.length == 0 ? null : enteredFrames[enteredFrames.length - 1];
	}
}
