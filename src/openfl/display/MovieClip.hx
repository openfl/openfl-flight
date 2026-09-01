package openfl.display;

#if !flash
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
@:access(openfl.display.Timeline)
class MovieClip extends Sprite #if (openfl_dynamic && haxe_ver < "4.0.0") implements Dynamic<DisplayObject> #end
{
	/**
		Specifies the number of the frame in which the playhead is located in the
		timeline of the MovieClip instance. If the movie clip has multiple scenes,
		this value is the frame number in the current scene.
	**/
	public var currentFrame(get, never):Int;
	/**
		The label at the current frame in the timeline of the MovieClip instance.
		If the current frame has no label, `currentLabel` is
		`null`.
	**/
	public var currentFrameLabel(get, never):String;
	/**
		The current label in which the playhead is located in the timeline of the
		MovieClip instance. If the current frame has no label,
		`currentLabel` is set to the name of the previous frame that
		includes a label. If the current frame and previous frames do not include
		a label, `currentLabel` returns `null`.
	**/
	public var currentLabel(get, never):String;
	/**
		Returns an array of FrameLabel objects from the current scene. If the
		MovieClip instance does not use scenes, the array includes all frame
		labels from the entire MovieClip instance.
	**/
	public var currentLabels(get, never):Array<FrameLabel>;
	/**
		The current scene in which the playhead is located in the timeline of
		the MovieClip instance.
	**/
	public var currentScene(get, never):Scene;
	/**
		A Boolean value that indicates whether a movie clip is enabled. The
		default value of `enabled` is `true`. If
		`enabled` is set to `false`, the movie clip's Over,
		Down, and Up frames are disabled. The movie clip continues to receive
		events (for example, `mouseDown`, `mouseUp`,
		`keyDown`, and `keyUp`).

		The `enabled` property governs only the button-like
		properties of a movie clip. You can change the `enabled`
		property at any time; the modified movie clip is immediately enabled or
		disabled. If `enabled` is set to `false`, the object
		is not included in automatic tab ordering.
	**/
	public var enabled(get, set):Bool;
	/**
		The number of frames that are loaded from a streaming SWF file. You can
		use the `framesLoaded` property to determine whether the
		contents of a specific frame and all the frames before it loaded and are
		available locally in the browser. You can also use it to monitor the
		downloading of large SWF files. For example, you might want to display a
		message to users indicating that the SWF file is loading until a specified
		frame in the SWF file finishes loading.

		If the movie clip contains multiple scenes, the
		`framesLoaded` property returns the number of frames loaded for
		_all_ scenes in the movie clip.
	**/
	public var framesLoaded(get, never):Int;
	/**
		A Boolean value that indicates whether a movie clip is curently playing.
	**/
	public var isPlaying(get, never):Bool;
	/**
		An array of Scene objects, each listing the name, the number of frames,
		and the frame labels for a scene in the MovieClip instance.
	**/
	public var scenes(get, never):Array<Scene>;
	/**
		The total number of frames in the MovieClip instance.

		If the movie clip contains multiple frames, the
		`totalFrames` property returns the total number of frames in
		_all_ scenes in the movie clip.
	**/
	public var totalFrames(get, never):Int;

	@:noCompletion private var __enabled:Bool;
	@:noCompletion private var __scene:Scene;
	@:noCompletion private var __timeline:Timeline;

	/**
		Creates a new MovieClip instance. After creating the MovieClip, call the
		`addChild()` or `addChildAt()` method of a display
		object container that is onstage.
	**/
	public function new()
	{
		super();
		__enabled = true;
	}

	/**
		Adds a new FrameScript to this MovieClip.

		The FrameScript will be executed automatically when the
		MovieClip enters the specified frame.

		This is only functional if this MovieClip has an attached
		Timeline.

		@param index A zero-based index referencing a frame
		@param method A method to be called entering the requested frame.
	**/
	public function addFrameScript(index:Int, method:Void->Void):Void
	{
		if (__timeline != null) __timeline.__addFrameScript(index, method);
	}

	/**
		Attaches a Timeline to this MovieClip.

		MovieClips that contain a Timeline can play(), stop() and can
		include FrameScripts.

		@param timeline A Timeline object
	**/
	public function attachTimeline(timeline:Timeline):Void
	{
		__timeline = timeline;
		if (timeline != null)
		{
			timeline.__attachMovieClip(this);
			play();
		}
	}

	/**
		Creates a new MovieClip based upon a Timeline instance.

		@param timeline A Timeline object
		@return A new Sprite
	**/
	public static function fromTimeline(timeline:Timeline):MovieClip
	{
		var movieClip = new MovieClip();
		movieClip.attachTimeline(timeline);
		return movieClip;
	}

	/**
		Starts playing the SWF file at the specified frame. This happens after all
		remaining actions in the frame have finished executing. To specify a scene
		as well as a frame, specify a value for the `scene` parameter.

		@param frame A number representing the frame number, or a string
					 representing the label of the frame, to which the playhead is
					 sent. If you specify a number, it is relative to the scene
					 you specify. If you do not specify a scene, the current scene
					 determines the global frame number to play. If you do specify
					 a scene, the playhead jumps to the frame number in the
					 specified scene.
		@param scene The name of the scene to play. This parameter is optional.

		@see [Controlling movie clip playback](https://books.openfl.org/openfl-developers-guide/working-with-movie-clips/controlling-movie-clip-playback.html)
	**/
	public function gotoAndPlay(frame:#if (haxe_ver >= "3.4.2") Any #else Dynamic #end, scene:String = null):Void
	{
		if (__timeline != null) __timeline.__gotoAndPlay(frame, scene);
	}

	/**
		Brings the playhead to the specified frame of the movie clip and stops it
		there. This happens after all remaining actions in the frame have finished
		executing. If you want to specify a scene in addition to a frame, specify
		a `scene` parameter.

		@param frame A number representing the frame number, or a string
					 representing the label of the frame, to which the playhead is
					 sent. If you specify a number, it is relative to the scene
					 you specify. If you do not specify a scene, the current scene
					 determines the global frame number at which to go to and
					 stop. If you do specify a scene, the playhead goes to the
					 frame number in the specified scene and stops.
		@param scene The name of the scene. This parameter is optional.
		@throws ArgumentError If the `scene` or `frame`
							  specified are not found in this movie clip.

		@see [Controlling movie clip playback](https://books.openfl.org/openfl-developers-guide/working-with-movie-clips/controlling-movie-clip-playback.html)
	**/
	public function gotoAndStop(frame:#if (haxe_ver >= "3.4.2") Any #else Dynamic #end, scene:String = null):Void
	{
		if (__timeline != null) __timeline.__gotoAndStop(frame, scene);
	}

	/**
		Sends the playhead to the next frame and stops it. This happens after all
		remaining actions in the frame have finished executing.

		@see [Controlling movie clip playback](https://books.openfl.org/openfl-developers-guide/working-with-movie-clips/controlling-movie-clip-playback.html)
	**/
	public function nextFrame():Void if (__timeline != null) __timeline.__nextFrame();
	public function nextScene():Void if (__timeline != null) __timeline.__nextScene();
	/**
		Moves the playhead in the timeline of the movie clip.

		@see [Controlling movie clip playback](https://books.openfl.org/openfl-developers-guide/working-with-movie-clips/controlling-movie-clip-playback.html)
	**/
	public function play():Void if (__timeline != null) __timeline.__play();
	/**
		Sends the playhead to the previous frame and stops it. This happens after
		all remaining actions in the frame have finished executing.

		@see [Controlling movie clip playback](https://books.openfl.org/openfl-developers-guide/working-with-movie-clips/controlling-movie-clip-playback.html)
	**/
	public function prevFrame():Void if (__timeline != null) __timeline.__prevFrame();
	public function prevScene():Void if (__timeline != null) __timeline.__prevScene();
	/**
		Stops the playhead in the movie clip.

		@see [Controlling movie clip playback](https://books.openfl.org/openfl-developers-guide/working-with-movie-clips/controlling-movie-clip-playback.html)
	**/
	public function stop():Void if (__timeline != null) __timeline.__stop();

	@:noCompletion private override function __enterFrame(deltaTime:Int):Void
	{
		if (__timeline != null) __timeline.__enterFrame(deltaTime);
		super.__enterFrame(deltaTime);
	}

	@:noCompletion private override function __stopAllMovieClips():Void
	{
		super.__stopAllMovieClips();
		stop();
	}

	@:noCompletion private function get_currentFrame():Int return __timeline == null ? 1 : __timeline.__currentFrame;
	@:noCompletion private function get_currentFrameLabel():String return __timeline == null ? null : __timeline.__currentFrameLabel;
	@:noCompletion private function get_currentLabel():String return __timeline == null ? null : __timeline.__currentLabel;
	@:noCompletion private function get_currentLabels():Array<FrameLabel> return __timeline == null ? [] : __timeline.__currentLabels.copy();

	@:noCompletion private function get_currentScene():Scene
	{
		if (__timeline != null) return __timeline.__currentScene;
		if (__scene == null) __scene = new Scene("", [], 1);
		return __scene;
	}

	@:noCompletion private function get_enabled():Bool return __enabled;
	@:noCompletion private function set_enabled(value:Bool):Bool return __enabled = value;
	@:noCompletion private function get_framesLoaded():Int return __timeline == null ? 1 : __timeline.__framesLoaded;
	@:noCompletion private function get_isPlaying():Bool return __timeline != null && __timeline.__isPlaying;
	@:noCompletion private function get_scenes():Array<Scene> return __timeline == null ? [currentScene] : __timeline.scenes.copy();
	@:noCompletion private function get_totalFrames():Int return __timeline == null ? 1 : __timeline.__totalFrames;
}
#else
typedef MovieClip = flash.display.MovieClip;
typedef MovieClip2 = flash.display.MovieClip.MovieClip2;
#end
