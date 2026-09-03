package openfl.net;

#if !flash
import flight.Dialog as FlightDialog;
import flight.FileSystem as FlightFileSystem;
import flight._internal._UInt8Array as FlightUInt8Array;
import flight.types.FileDialogFilter as FlightFileDialogFilter;
import flight.types.FileDialogHandle as FlightFileDialogHandle;
import flight.types.FileStat as FlightFileStat;
import flight.types.HasDialogFileOpen as FlightDialogOpenHost;
import flight.types.HasDialogFileSave as FlightDialogSaveHost;
import flight.types.HasStorageFileSystem as FlightFileSystemHost;
import flight.types.Host as FlightHost;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.utils.ByteArray;
import openfl.utils.ByteArray.ByteArrayData;
#if (js && html5)
import flight.HostWeb as FlightHostWeb;
#elseif (clay && sys)
import flight.hostClay.HostClay as FlightHostClay;
#elseif (lime && sys)
import flight.hostLime.HostLime as FlightHostLime;
import lime.app.Application as LimeApplication;
#end

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

	@:noCompletion private static var __host:FlightHost;
	@:noCompletion private static var __hostResolved:Bool;

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
		var dialogHost:FlightDialogOpenHost = cast __getHost();
		FlightDialog.showOpenFileDialog(dialogHost, {multiple: false, filters: __toFlightFilters(typeFilter)}).then(function(result:Dynamic):Dynamic
		{
			if (generation != __operationGeneration) return result;
			var outcome = result == null ? null : Reflect.field(result, "outcome");
			var handles = __openDialogHandles(result);
			if (outcome == "cancelled" || (outcome == null && handles.length == 0))
			{
				dispatchEvent(new Event(Event.CANCEL));
			}
			else if ((outcome == "selected" || outcome == null) && handles.length > 0)
			{
				__selectHandle(handles[0], generation);
			}
			else
			{
				__dispatchIOError(outcome == null ? "Unable to open a file dialog" : outcome);
			}
			return result;
		}, function(error:Dynamic):Dynamic
		{
			if (generation == __operationGeneration) __dispatchIOError(error);
			return cast {outcome: "file-open-failed"};
		});
		return true;
	}

	public function cancel():Void
	{
		__operationGeneration++;
	}

	public function download(request:URLRequest, defaultFileName:String = null):Void
	{
		// Flight cannot yet compose a cancellable network request with a save
		// dialog and streamed filesystem destination; see agents/flight-gaps.md.
		__dispatchIOError("FileReference download is not available through Flight");
	}

	public function load():Void
	{
		if (__flightHandle == null) return;
		var generation = ++__operationGeneration;
		var fileSystemHost:FlightFileSystemHost = cast __getHost();
		if (fileSystemHost == null) return;
		FlightFileSystem.readDialogHandleBinaryFile(fileSystemHost, __flightHandle).then(function(bytes:FlightUInt8Array):FlightUInt8Array
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
		var host = __getHost();
		var dialogHost:FlightDialogSaveHost = cast host;
		var fileSystemHost:FlightFileSystemHost = cast host;
		var options:Dynamic = {defaultName: defaultFileName};
		// The maintained Lime host consumes this compatibility field; the
		// generated Dialog contract consumes defaultName above.
		Reflect.setField(options, "defaultPath", defaultFileName);
		FlightDialog.showSaveFileDialog(dialogHost, cast options).then(function(result:Dynamic):Dynamic
		{
			if (generation != __operationGeneration) return result;
			var outcome = result == null ? null : Reflect.field(result, "outcome");
			var handle = __saveDialogHandle(result);
			if (outcome == "cancelled" || (outcome == null && handle == null))
			{
				dispatchEvent(new Event(Event.CANCEL));
				return result;
			}
			if ((outcome != "selected" && outcome != null) || handle == null)
			{
				__dispatchIOError(outcome == null ? "Unable to open a save dialog" : outcome);
				return result;
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
				__finishWrite(FlightFileSystem.writeDialogHandleBinaryFile(fileSystemHost, handle, bytes), generation);
			}
			else
			{
				__finishWrite(FlightFileSystem.writeDialogHandleTextFile(fileSystemHost, handle, Std.string(data)), generation);
			}
			return result;
		}, function(error:Dynamic):Dynamic
		{
			if (generation == __operationGeneration) __dispatchIOError(error);
			return cast {outcome: "file-save-failed"};
		});
	}

	public function upload(request:URLRequest, uploadDataFieldName:String = "Filedata", testUpload:Bool = false):Void
	{
		// Flight cannot yet expose this API's cancellable multipart upload
		// lifecycle; report the unsupported operation instead of silently
		// starting a partial transfer. See agents/flight-gaps.md.
		__dispatchIOError("FileReference upload is not available through Flight");
	}

	@:noCompletion private function __dispatchIOError(error:Any):Void
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
		return __getHost() != null;
	}

	@:noCompletion private static function __getHost():FlightHost
	{
		if (__host != null || __hostResolved) return __host;

		#if (js && html5)
		__host = cast FlightHostWeb.webHost;
		__hostResolved = true;
		#elseif (clay && sys)
		__host = cast FlightHostClay.createClayHost();
		__hostResolved = true;
		#elseif (lime && sys)
		if (LimeApplication.current != null)
		{
			__host = cast FlightHostLime.createLimeHost(LimeApplication.current);
			__hostResolved = true;
		}
		#else
		__hostResolved = true;
		#end

		return __host;
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

		var fileSystemHost:FlightFileSystemHost = cast __getHost();
		if (fileSystemHost == null)
		{
			dispatchEvent(new Event(Event.SELECT));
			return;
		}

		FlightFileSystem.statFile(fileSystemHost, handle.path).then(function(stat:FlightFileStat):FlightFileStat
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
			var accept:Dynamic = {};
			Reflect.setField(accept, "", extensions);
			var item:Dynamic = {name: filter.description == null ? "" : filter.description, accept: accept};
			// The maintained native Flight host consumes this compatibility field;
			// the generated Dialog contract consumes accept above.
			Reflect.setField(item, "extensions", extensions);
			result.push(cast item);
		}
		return result;
	}

	@:noCompletion private static function __openDialogHandles(result:Dynamic):Array<FlightFileDialogHandle>
	{
		if (result == null) return [];
		if (Std.isOfType(result, Array)) return cast result;
		if (Reflect.hasField(result, "kind")) return [cast result];
		var handles:Array<FlightFileDialogHandle> = cast Reflect.field(result, "handles");
		return handles == null ? [] : handles;
	}

	@:noCompletion private static function __saveDialogHandle(result:Dynamic):FlightFileDialogHandle
	{
		if (result == null) return null;
		if (Reflect.hasField(result, "kind")) return cast result;
		return cast Reflect.field(result, "handle");
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
