package openfl.display;

#if !flash
import haxe.Timer;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DProfile;
import openfl.display3D.Context3DRenderMode;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Matrix3D;
import openfl.Vector;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:allow(openfl.display.Stage)
class Stage3D extends EventDispatcher
{
	@:noCompletion private static var __active:Bool;

	public var context3D(default, null):Context3D;
	public var visible:Bool;
	public var x(get, set):Float;
	public var y(get, set):Float;

	@:noCompletion private var __contextLost:Bool;
	@:noCompletion private var __contextRequested:Bool;
	@:noCompletion private var __height:Int;
	@:noCompletion private var __indexBuffer:IndexBuffer3D;
	@:noCompletion private var __projectionTransform:Matrix3D;
	@:noCompletion private var __renderTransform:Matrix3D;
	@:noCompletion private var __stage:Stage;
	@:noCompletion private var __vertexBuffer:VertexBuffer3D;
	@:noCompletion private var __width:Int;
	@:noCompletion private var __x:Float;
	@:noCompletion private var __y:Float;

	@:noCompletion private function new(stage:Stage)
	{
		super();
		__stage = stage;
		__projectionTransform = new Matrix3D();
		__renderTransform = new Matrix3D();
		__x = 0;
		__y = 0;
		visible = true;
	}

	public function requestContext3D(context3DRenderMode:Context3DRenderMode = AUTO, profile:Context3DProfile = BASELINE):Void
	{
		if (__contextLost)
		{
			__contextRequested = true;
			return;
		}

		if (context3D != null)
		{
			__contextRequested = true;
			Timer.delay(__dispatchCreate, 1);
		}
		else if (!__contextRequested)
		{
			__contextRequested = true;
			Timer.delay(__createContext, 1);
		}
	}

	public function requestContext3DMatchingProfiles(profiles:Vector<Context3DProfile>):Void
	{
		requestContext3D();
	}

	@:noCompletion private function __createContext():Void
	{
		// Flight gap: no public graphics-context seam can create and bind the
		// Context3D yet, so preserve OpenFL's asynchronous failure lifecycle.
		__dispatchError();
	}

	@:noCompletion private function __dispatchError():Void
	{
		__contextRequested = false;
		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Context3D not available"));
	}

	@:noCompletion private function __dispatchCreate():Void
	{
		if (__contextRequested)
		{
			__contextRequested = false;
			dispatchEvent(new Event(Event.CONTEXT3D_CREATE));
		}
	}

	@:noCompletion private function __lostContext():Void
	{
		__contextLost = true;
		context3D = null;
	}

	@:noCompletion private function __resize(width:Int, height:Int):Void
	{
		__width = width;
		__height = height;
	}

	@:noCompletion private function __restoreContext():Void
	{
		__contextLost = false;
		if (__contextRequested) __createContext();
	}

	@:noCompletion private function get_x():Float return __x;
	@:noCompletion private function set_x(value:Float):Float
	{
		__x = value;
		return value;
	}
	@:noCompletion private function get_y():Float return __y;
	@:noCompletion private function set_y(value:Float):Float
	{
		__y = value;
		return value;
	}
}
#else
typedef Stage3D = flash.display.Stage3D;
#end
