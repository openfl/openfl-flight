package openfl.net;

#if !flash
import flight.Dialog as FlightDialog;
import flight.FileSystem as FlightFileSystem;
import flight._internal._UInt8Array as FlightUInt8Array;
import flight.types.FileDialogFilter as FlightFileDialogFilter;
import flight.types.FileDialogHandle as FlightFileDialogHandle;
import flight.types.FileStat as FlightFileStat;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.utils.ByteArray;
import openfl.utils.ByteArray.ByteArrayData;

/**
	Represents a local file selected by the user for upload, download, loading,
	or saving. Native file dialogs and transfers require a Flight integration.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FileReference extends EventDispatcher
{
	public var creationDate(get, null):Date;
	public var creator(default, null):String;
	public var data(default, null):ByteArray;
	public var modificationDate(get, null):Date;
	public var name(get, null):String;
	public var size(get, null):Float;
	public var type(get, null):String;
	public var extension(get, null):String;

	@:noCompletion private var __creationDate:Date;
	@:noCompletion private var __data:ByteArray;
	@:noCompletion private var __flightHandle:FlightFileDialogHandle;
	@:noCompletion private var __modificationDate:Date;
	@:noCompletion private var __name:String;
	@:noCompletion private var __operationGeneration:Int = 0;
	@:noCompletion private var __path:String;
	@:noCompletion private var __size:Float;
	@:noCompletion private var __type:String;

	public function new()
	{
		super();
	}

	public function browse(typeFilter:Array<FileFilter> = null):Bool
	{
		__data = null;
		data = null;
		__flightHandle = null;
		__path = null;

		if (!__hasDialogBackend()) return true;
		var generation = ++__operationGeneration;
		FlightDialog.showOpenFileDialog({multiple: false, filters: __toFlightFilters(typeFilter)}).then(function(handles:Array<FlightFileDialogHandle>):Array<FlightFileDialogHandle>
		{
			if (generation != __operationGeneration) return handles;
			if (handles == null || handles.length == 0)
			{
				dispatchEvent(new Event(Event.CANCEL));
			}
			else
			{
				__selectHandle(handles[0], generation);
			}
			return handles;
		}, function(error:Dynamic):Array<FlightFileDialogHandle>
		{
			if (generation == __operationGeneration) __dispatchIOError(error);
			return [];
		});
		return true;
	}

	public function cancel():Void
	{
		__operationGeneration++;
	}

	public function download(request:URLRequest, defaultFileName:String = null):Void
	{
		// TODO: Select a destination and download through Flight.
	}

	public function load():Void
	{
		if (__flightHandle == null) return;
		var generation = ++__operationGeneration;
		FlightFileSystem.readDialogHandleBinaryFile(__flightHandle).then(function(bytes:FlightUInt8Array):FlightUInt8Array
		{
			if (generation != __operationGeneration) return bytes;
			if (bytes == null)
			{
				__dispatchIOError("Unable to read the selected file");
				return bytes;
			}
			var result = new ByteArray();
			for (index in 0...bytes.length) result.writeByte(bytes[index]);
			result.position = 0;
			__data = result;
			data = result;
			dispatchEvent(new Event(Event.COMPLETE));
			return bytes;
		}, function(error:Dynamic):FlightUInt8Array
		{
			if (generation == __operationGeneration) __dispatchIOError(error);
			return null;
		});
	}

	public function save(data:Dynamic, defaultFileName:String = null):Void
	{
		__data = null;
		__path = null;
		if (data == null || !__hasDialogBackend()) return;

		var generation = ++__operationGeneration;
		FlightDialog.showSaveFileDialog({defaultName: defaultFileName}).then(function(handle:FlightFileDialogHandle):FlightFileDialogHandle
		{
			if (generation != __operationGeneration) return handle;
			if (handle == null)
			{
				dispatchEvent(new Event(Event.CANCEL));
				return handle;
			}

			__flightHandle = handle;
			__name = handle.name;
			__path = handle.path;
			__type = __typeForName(handle.name);
			dispatchEvent(new Event(Event.SELECT));

			if (Std.isOfType(data, ByteArrayData))
			{
				var byteArray:ByteArray = cast data;
				__data = byteArray;
				var bytes = new FlightUInt8Array(byteArray.length);
				for (index in 0...byteArray.length) bytes[index] = byteArray[index];
				__finishWrite(FlightFileSystem.writeDialogHandleBinaryFile(handle, bytes), generation);
			}
			else
			{
				__finishWrite(FlightFileSystem.writeDialogHandleTextFile(handle, Std.string(data)), generation);
			}
			return handle;
		}, function(error:Dynamic):FlightFileDialogHandle
		{
			if (generation == __operationGeneration) __dispatchIOError(error);
			return null;
		});
	}

	public function upload(request:URLRequest, uploadDataFieldName:String = "Filedata", testUpload:Bool = false):Void
	{
		// TODO: Upload the selected file through Flight networking.
	}

	@:noCompletion private function __dispatchIOError(error:Dynamic):Void
	{
		dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, Std.string(error)));
	}

	@:noCompletion private function __finishWrite(promise:flight._internal._Promise<Bool>, generation:Int):Void
	{
		promise.then(function(success:Bool):Bool
		{
			if (generation != __operationGeneration) return success;
			if (success)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				__dispatchIOError("Unable to save the selected file");
			}
			return success;
		}, function(error:Dynamic):Bool
		{
			if (generation == __operationGeneration) __dispatchIOError(error);
			return false;
		});
	}

	@:noCompletion private static function __hasDialogBackend():Bool
	{
		try
		{
			return FlightDialog.explainDialogBackend().layer != "host-not-enabled";
		}
		catch (error:Dynamic)
		{
			return false;
		}
	}

	@:noCompletion private function __selectHandle(handle:FlightFileDialogHandle, generation:Int):Void
	{
		__flightHandle = handle;
		__name = handle.name;
		__path = handle.path;
		__type = __typeForName(handle.name);

		if (handle.path == null)
		{
			dispatchEvent(new Event(Event.SELECT));
			return;
		}

		FlightFileSystem.statFile(handle.path).then(function(stat:FlightFileStat):FlightFileStat
		{
			if (generation != __operationGeneration) return stat;
			if (stat != null)
			{
				__creationDate = Date.fromTime(stat.createdTime);
				__modificationDate = Date.fromTime(stat.modifiedTime);
				__size = stat.size;
			}
			dispatchEvent(new Event(Event.SELECT));
			return stat;
		}, function(error:Dynamic):FlightFileStat
		{
			if (generation == __operationGeneration) __dispatchIOError(error);
			return null;
		});
	}

	@:noCompletion private static function __toFlightFilters(filters:Array<FileFilter>):Array<FlightFileDialogFilter>
	{
		if (filters == null) return null;
		var result:Array<FlightFileDialogFilter> = [];
		for (filter in filters)
		{
			if (filter == null) continue;
			var extensions:Array<String> = [];
			if (filter.extension != null)
			{
				for (extension in filter.extension.split(";"))
				{
					extension = StringTools.trim(extension);
					if (extension == "*" || extension == "*.*")
					{
						extensions.push("*");
					}
					else
					{
						if (StringTools.startsWith(extension, "*.")) extension = extension.substr(2);
						else if (StringTools.startsWith(extension, ".")) extension = extension.substr(1);
						if (extension.length > 0) extensions.push(extension);
					}
				}
			}
			result.push({name: filter.description == null ? "" : filter.description, extensions: extensions});
		}
		return result;
	}

	@:noCompletion private static function __typeForName(name:String):String
	{
		if (name == null) return null;
		var index = name.lastIndexOf(".");
		return "." + (index > -1 ? name.substr(index + 1) : "");
	}

	@:noCompletion private function get_creationDate():Date
	{
		return __creationDate;
	}

	@:noCompletion private function get_modificationDate():Date
	{
		return __modificationDate;
	}

	@:noCompletion private function get_name():String
	{
		return __name;
	}

	@:noCompletion private function get_size():Float
	{
		return __size;
	}

	@:noCompletion private function get_type():String
	{
		return __type;
	}

	@:noCompletion private function get_extension():String
	{
		if (__name == null) return null;
		var index = __name.lastIndexOf(".");
		return index > -1 ? __name.substr(index + 1) : null;
	}
}
#else
typedef FileReference = flash.net.FileReference;
#end
