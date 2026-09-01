package openfl.utils;

#if !lime
@SuppressWarnings("checkstyle:FieldDocComment")
@:allow(openfl.utils.Promise)
class Future<T>
{
	public var error(default, null):Dynamic;
	public var isComplete(default, null):Bool;
	public var isError(default, null):Bool;
	public var value(default, null):T;

	@:noCompletion private var __completeListeners:Array<T->Void>;
	@:noCompletion private var __errorListeners:Array<Dynamic->Void>;
	@:noCompletion private var __progressListeners:Array<Int->Int->Void>;

	private function new() {}

	public function onComplete(listener:T->Void):Future<T>
	{
		if (isComplete)
		{
			listener(value);
		}
		else if (!isError)
		{
			if (__completeListeners == null) __completeListeners = [];
			__completeListeners.push(listener);
		}
		return this;
	}

	public function onError(listener:Dynamic->Void):Future<T>
	{
		if (isError)
		{
			listener(error);
		}
		else if (!isComplete)
		{
			if (__errorListeners == null) __errorListeners = [];
			__errorListeners.push(listener);
		}
		return this;
	}

	public function onProgress(listener:Int->Int->Void):Future<T>
	{
		if (!isComplete && !isError)
		{
			if (__progressListeners == null) __progressListeners = [];
			__progressListeners.push(listener);
		}
		return this;
	}

	public function ready(waitTime:Int = -1):Future<T>
	{
		return this;
	}

	public function result(waitTime:Int = -1):Null<T>
	{
		return value;
	}

	public function then<U>(next:T->Future<U>):Future<U>
	{
		return new Future<U>();
	}

	public static function withError(error:Dynamic):Future<Dynamic>
	{
		var result = new Future<Dynamic>();
		result.error = error;
		result.isError = true;
		return result;
	}

	public static function withValue<T>(value:T):Future<T>
	{
		var result = new Future<T>();
		result.value = value;
		result.isComplete = true;
		return result;
	}
}
#else
typedef Future<T> = lime.app.Future<T>;
#end
