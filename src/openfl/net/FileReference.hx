package openfl.net;

#if !flash
import openfl.events.EventDispatcher;
import openfl.utils.ByteArray;

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
	@:noCompletion private var __modificationDate:Date;
	@:noCompletion private var __name:String;
	@:noCompletion private var __path:String;
	@:noCompletion private var __size:Float;
	@:noCompletion private var __type:String;

	public function new()
	{
		super();
		__size = 0;
	}

	public function browse(typeFilter:Array<FileFilter> = null):Bool
	{
		__data = null;
		data = null;
		__path = null;
		// TODO: Open the native file picker through Flight.
		return false;
	}

	public function cancel():Void
	{
		// TODO: Cancel the active Flight file transfer.
	}

	public function download(request:URLRequest, defaultFileName:String = null):Void
	{
		// TODO: Select a destination and download through Flight.
	}

	public function load():Void
	{
		// TODO: Read the selected file through Flight.
	}

	public function save(data:Dynamic, defaultFileName:String = null):Void
	{
		// TODO: Select a destination and save through Flight.
	}

	public function upload(request:URLRequest, uploadDataFieldName:String = "Filedata", testUpload:Bool = false):Void
	{
		// TODO: Upload the selected file through Flight networking.
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
