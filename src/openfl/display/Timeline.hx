package openfl.display;

import openfl.errors.ArgumentError;

/**
	Provides support for MovieClip animations (or a single frame Sprite) when
	this class is overridden.

	For example, the OpenFL SWF library provides a Timeline generated from SWF
	assets. However, any editor that may provide UI or display elements could
	be used to generate assets for OpenFL timelines.

	To implement a custom Timeline, please override this class. Each Timeline
	can set their original animation frame rate, and can also provide Scenes or
	FrameScripts. OpenFL will automatically execute FrameScripts and request frame
	updates.

	There are currently three internal methods which should not be called by the user,
	which can be overridden to implement a new type of Timeline:

	   attachMovieClip();
	   enterFrame();
	   initializeSprite();
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Timeline
{
	/**
		The original frame rate for this Timeline.
	**/
	public var frameRate:Null<Float>;

	/**
		An Array of Scenes contained within this Timeline.

		Scenes are assumed to occur in order, so if the first Scene
		contains 10 frames, then the beginning of the second Scene will
		be treated as frame 11 when setting FrameScripts or implementing
		enterFrame().
	**/
	public var scenes:Array<Scene>;

	/**
		An optional array of frame scripts to be executed.
	**/
	public var scripts:Array<FrameScript>;

	@:noCompletion private var __currentFrame:Int;
	@:noCompletion private var __currentFrameLabel:String;
	@:noCompletion private var __currentLabel:String;
	@:noCompletion private var __currentLabels:Array<FrameLabel>;
	@:noCompletion private var __currentScene:Scene;
	@:noCompletion private var __currentSceneIndex:Int;
	@:noCompletion private var __currentSceneStart:Int;
	@:noCompletion private var __frameScripts:Map<Int, MovieClip->Void>;
	@:noCompletion private var __framesLoaded:Int;
	@:noCompletion private var __frameTime:Int;
	@:noCompletion private var __isPlaying:Bool;
	@:noCompletion private var __lastFrameScriptEval:Int;
	@:noCompletion private var __lastFrameUpdate:Int;
	@:noCompletion private var __scope:MovieClip;
	@:noCompletion private var __sceneStarts:Array<Int>;
	@:noCompletion private var __timeElapsed:Int;
	@:noCompletion private var __totalFrames:Int;

	private function new()
	{
		__framesLoaded = 1;
		__totalFrames = 1;
		__currentLabels = [];
		__currentSceneIndex = -1;
		__currentSceneStart = 1;
		__sceneStarts = [];

		__currentFrame = 1;

		__lastFrameScriptEval = -1;
		__lastFrameUpdate = -1;
	}

	/**
		OpenFL will call this method automatically.

		If you are making your own Timeline type, please override this method
		and implement the first frame initialization for a MovieClip.

		OpenFL will expect to use one Timeline instance per MovieClip.

		Please initialize the first frame in this method. Afterward enterFrame()
		will be called automatically when it is time to enter a different frame.
	**/
	@:noCompletion public function attachMovieClip(movieClip:MovieClip):Void {}

	/**
		OpenFL will call this method automatically for MovieClips with
		attached timelines.

		Please update your attached MovieClip instance to the requested frame
		when this method is called.
	**/
	@:noCompletion public function enterFrame(frame:Int):Void {}

	/**
		OpenFL will call this method automatically.

		If you are making your own Timeline type, please override this method
		and implement the initialization of a Sprite.

		Sprites do not use frame scripts, or enter multiple frames. In other
		words, they will be similar to the first frame of a MovieClip.

		enterFrame() will not be called, and this Timeline object might be
		re-used again.
	**/
	@:noCompletion public function initializeSprite(sprite:Sprite):Void {}

	@:noCompletion private function __addFrameScript(index:Int, method:Void->Void):Void
	{
		if (index < 0) return;

		var frame = index + 1;

		if (method != null)
		{
			if (__frameScripts == null)
			{
				__frameScripts = new Map();
			}

			__frameScripts.set(frame, function(scope)
			{
				method();
			});
		}
		else if (__frameScripts != null)
		{
			__frameScripts.remove(frame);
		}
	}

	@:noCompletion private function __attachMovieClip(movieClip:MovieClip):Void
	{
		__scope = movieClip;

		__totalFrames = 0;
		__framesLoaded = 0;
		__currentLabels = [];
		__currentScene = null;
		__currentSceneIndex = -1;
		__currentSceneStart = 1;
		__sceneStarts = [];

		if (scenes != null && scenes.length > 0)
		{
			for (scene in scenes)
			{
				__sceneStarts.push(__totalFrames + 1);
				__totalFrames += scene.numFrames;
				__framesLoaded += scene.numFrames;
			}

			__setCurrentScene(0);
		}

		if (scripts != null && scripts.length > 0)
		{
			__frameScripts = new Map();
			for (script in scripts)
			{
				if (__frameScripts.exists(script.frame))
				{
					__frameScripts.set(script.frame, __mergeFrameScripts(__frameScripts.get(script.frame), script.script));
				}
				else
				{
					__frameScripts.set(script.frame, script.script);
				}
			}
		}

		__updateFrameLabel();
		attachMovieClip(movieClip);
	}

	@:noCompletion private function __enterFrame(deltaTime:Int):Void
	{
		if (__isPlaying)
		{
			var nextFrame = __getNextFrame(deltaTime);

			if (__lastFrameScriptEval == nextFrame)
			{
				return;
			}

			if (__frameScripts != null)
			{
				if (nextFrame < __currentFrame)
				{
					if (!__evaluateFrameScripts(__totalFrames))
					{
						return;
					}

					__currentFrame = 1;
				}

				if (!__evaluateFrameScripts(nextFrame))
				{
					return;
				}
			}
			else
			{
				__currentFrame = nextFrame;
			}
		}

		__updateSymbol(__currentFrame);
	}

	@:noCompletion private function __evaluateFrameScripts(advanceToFrame:Int):Bool
	{
		if (__frameScripts == null) return true;

		for (frame in __currentFrame...advanceToFrame + 1)
		{
			if (frame == __lastFrameScriptEval) continue;

			__lastFrameScriptEval = frame;
			__currentFrame = frame;

			if (__frameScripts.exists(frame))
			{
				__updateSymbol(frame);
				var script = __frameScripts.get(frame);
				script(__scope);

				if (__currentFrame != frame)
				{
					return false;
				}
			}

			if (!__isPlaying)
			{
				return false;
			}
		}

		return true;
	}

	@:noCompletion private function __getNextFrame(deltaTime:Int):Int
	{
		var nextFrame:Int = 0;

		if (frameRate != null)
		{
			__timeElapsed += deltaTime;
			nextFrame = __currentFrame + Math.floor(__timeElapsed / __frameTime);
			if (nextFrame < 1) nextFrame = 1;
			if (nextFrame > __totalFrames) nextFrame = Math.floor((nextFrame - 1) % __totalFrames) + 1;
			__timeElapsed = (__timeElapsed % __frameTime);
		}
		else
		{
			nextFrame = __currentFrame + 1;
			if (nextFrame > __totalFrames) nextFrame = 1;
		}

		return nextFrame;
	}

	@:noCompletion private function __goto(frame:Int):Void
	{
		if (frame < 1) frame = 1;
		else if (frame > __totalFrames) frame = __totalFrames;

		__lastFrameScriptEval = -1;
		__currentFrame = frame;

		__updateSymbol(__currentFrame);
		__evaluateFrameScripts(__currentFrame);
	}

	@:noCompletion private function __gotoAndPlay(frame:#if (haxe_ver >= "3.4.2") Any #else Dynamic #end, scene:String = null):Void
	{
		__play();
		__goto(__resolveFrameReference(frame, scene));
	}

	@:noCompletion private function __gotoAndStop(frame:#if (haxe_ver >= "3.4.2") Any #else Dynamic #end, scene:String = null):Void
	{
		__stop();
		__goto(__resolveFrameReference(frame, scene));
	}

	@:noCompletion private function __nextFrame():Void
	{
		__stop();
		__goto(__currentFrame + 1);
	}

	@:noCompletion private function __nextScene():Void
	{
		__stop();
		if (__currentSceneIndex < 0 || __currentSceneIndex + 1 >= __sceneStarts.length) return;
		__goto(__sceneStarts[__currentSceneIndex + 1]);
	}

	@:noCompletion private function __play():Void
	{
		if (__isPlaying || __totalFrames < 2) return;

		__isPlaying = true;

		if (frameRate != null)
		{
			__frameTime = Std.int(1000 / frameRate);
			__timeElapsed = 0;
		}
	}

	@:noCompletion private function __prevFrame():Void
	{
		__stop();
		__goto(__currentFrame - 1);
	}

	@:noCompletion private function __prevScene():Void
	{
		__stop();
		if (__currentSceneIndex <= 0) return;
		__goto(__sceneStarts[__currentSceneIndex - 1]);
	}

	@:noCompletion private function __stop():Void
	{
		__isPlaying = false;
	}

	@:noCompletion private function __resolveFrameReference(frame:#if (haxe_ver >= "3.4.2") Any #else Dynamic #end, sceneName:String = null):Int
	{
		var sceneIndex = __resolveSceneIndex(sceneName);
		var scene = sceneIndex < 0 ? null : scenes[sceneIndex];
		var sceneStart = sceneIndex < 0 ? 1 : __sceneStarts[sceneIndex];

		if ((frame is Int))
		{
			var localFrame:Int = cast frame;
			if (scene != null)
			{
				if (localFrame < 1) localFrame = 1;
				else if (localFrame > scene.numFrames) localFrame = scene.numFrames;
			}
			return sceneStart + localFrame - 1;
		}
		else if ((frame is String))
		{
			var label:String = cast frame;
			var labels = scene == null ? __currentLabels : scene.labels;

			if (labels != null) for (frameLabel in labels)
			{
				if (frameLabel.name == label)
				{
					return sceneStart + frameLabel.frame - 1;
				}
			}

			throw new ArgumentError("Error #2109: Frame label " + label + " not found in scene.");
		}
		else
		{
			throw "Invalid type for frame " + Type.getClassName(frame);
		}
	}

	@:noCompletion private function __resolveSceneIndex(sceneName:String):Int
	{
		if (scenes == null || scenes.length == 0)
		{
			if (sceneName != null) throw new ArgumentError("Error #2108: Scene " + sceneName + " was not found.");
			return -1;
		}

		if (sceneName == null) return __currentSceneIndex < 0 ? 0 : __currentSceneIndex;

		for (index in 0...scenes.length)
		{
			if (scenes[index].name == sceneName) return index;
		}

		throw new ArgumentError("Error #2108: Scene " + sceneName + " was not found.");
	}

	@:noCompletion private function __getCurrentFrame():Int
	{
		return __currentSceneIndex < 0 ? __currentFrame : __currentFrame - __currentSceneStart + 1;
	}

	@:noCompletion private static function __mergeFrameScripts(first:MovieClip->Void, second:MovieClip->Void):MovieClip->Void
	{
		return function(clip:MovieClip):Void
		{
			first(clip);
			second(clip);
		};
	}

	@:noCompletion private function __setCurrentScene(index:Int):Void
	{
		__currentSceneIndex = index;
		__currentScene = scenes[index];
		__currentSceneStart = __sceneStarts[index];
		__currentLabels = __currentScene.labels == null ? [] : __currentScene.labels.copy();
		__currentLabels.sort(function(a:FrameLabel, b:FrameLabel):Int return a.frame - b.frame);
	}

	@:noCompletion private function __updateScene():Void
	{
		if (scenes == null || scenes.length == 0) return;

		var sceneIndex = 0;
		for (index in 0...__sceneStarts.length)
		{
			if (__currentFrame < __sceneStarts[index]) break;
			sceneIndex = index;
		}

		if (sceneIndex != __currentSceneIndex) __setCurrentScene(sceneIndex);
	}

	@:noCompletion private function __updateFrameLabel():Void
	{
		__currentLabel = null;
		__currentFrameLabel = null;
		if (__currentLabels.length == 0) return;

		var currentFrame = __getCurrentFrame();
		var low = 0;
		var high = __currentLabels.length - 1;
		var match = -1;
		while (low <= high)
		{
			var middle = (low + high) >> 1;
			if (__currentLabels[middle].frame <= currentFrame)
			{
				match = middle;
				low = middle + 1;
			}
			else high = middle - 1;
		}

		if (match >= 0)
		{
			var label = __currentLabels[match];
			__currentLabel = label.name;
			if (label.frame == currentFrame) __currentFrameLabel = label.name;
		}
	}

	@:noCompletion private function __updateSymbol(targetFrame:Int):Void
	{
		if (__currentFrame != __lastFrameUpdate)
		{
			__updateScene();
			__updateFrameLabel();
			enterFrame(targetFrame);
			__lastFrameUpdate = __currentFrame;
		}
	}
}
