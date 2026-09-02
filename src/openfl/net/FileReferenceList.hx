package openfl.net;

#if !flash
#if (desktop || js)
import flight.Dialog as FlightDialog;
import flight.FileSystem as FlightFileSystem;
import flight.types.FileDialogHandle as FlightFileDialogHandle;
import flight.types.HasDialogFileOpen as FlightDialogOpenHost;
import flight.types.HasStorageFileSystem as FlightFileSystemHost;
import flight.types.FileStat as FlightFileStat;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
/**
	The FileReferenceList class provides a means to let users select one or
	more files for uploading. A FileReferenceList object represents a group of
	one or more local files on the user's disk as an array of FileReference
	objects. For detailed information and important considerations about
	FileReference objects and the FileReference class, which you use with
	FileReferenceList, see the FileReference class.
	To work with the FileReferenceList class:

	* Instantiate the class: `var myFileRef = new FileReferenceList();`
	* Call the `FileReferenceList.browse()` method, which opens a dialog box
	that lets the user select one or more files for upload:
	`myFileRef.browse();`
	* After the `browse()` method is called successfully, the `fileList`
	property of the FileReferenceList object is populated with an array of
	FileReference objects.
	* Call `FileReference.upload()` on each element in the `fileList` array.

	The FileReferenceList class includes a `browse()` method and a `fileList`
	property for working with multiple files. While a call to
	`FileReferenceList.browse()` is executing, SWF file playback pauses in
	stand-alone and external versions of Flash Player and in AIR for Linux and
	Mac OS X 10.1 and earlier.

	@event cancel Dispatched when the user dismisses the file-browsing dialog
				  box. (This dialog box opens when you call the
				  `FileReferenceList.browse()`, `FileReference.browse()`, or
				  `FileReference.download()` methods.)
	@event select Dispatched when the user selects one or more files to upload
				  from the file-browsing dialog box. (This dialog box opens
				  when you call the `FileReferenceList.browse()`,
				  `FileReference.browse()`, or `FileReference.download()`
				  methods.) When the user selects a file and confirms the
				  operation (for example, by clicking Save), the
				  `FileReferenceList` object is populated with FileReference
				  objects that represent the files that the user selects.

	@see [Using the FileReferenceList class](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/using-the-filereference-class.html#filereferencelist-class)
	@see `openfl.net.FileReference`
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.net.FileReference)
class FileReferenceList extends EventDispatcher
{
	@:noCompletion private var __operationGeneration:Int = 0;

	/**
		An array of `FileReference` objects.
		When the `FileReferenceList.browse()` method is called and the user
		has selected one or more files from the dialog box that the `browse()`
		method opens, this property is populated with an array of
		FileReference objects, each of which represents the files the user
		selected. You can then use this array to upload each file with the
		`FileReference.upload()`method. You must upload one file at a time.

		The `fileList` property is populated anew each time browse() is called
		on that FileReferenceList object.

		The properties of `FileReference` objects are described in the
		FileReference class documentation.
	**/
	public var fileList(default, null):Array<FileReference>;

	/**
		Creates a new FileReferenceList object. A FileReferenceList object
		contains nothing until you call the `browse()` method on it and the
		user selects one or more files. When you call `browse()` on the
		FileReference object, the `fileList` property of the object is
		populated with an array of `FileReference` objects.
	**/
	public function new()
	{
		super();
	}

	/**
		Displays a file-browsing dialog box that lets the user select one or
		more local files to upload. The dialog box is native to the user's
		operating system.
		In Flash Player 10 and later, you can call this method successfully
		only in response to a user event (for example, in an event handler for
		a mouse click or keypress event). Otherwise, calling this method
		results in Flash Player throwing an Error.

		When you call this method and the user successfully selects files, the
		`fileList` property of this FileReferenceList object is populated with
		an array of FileReference objects, one for each file that the user
		selects. Each subsequent time that the FileReferenceList.browse()
		method is called, the `FileReferenceList.fileList` property is reset
		to the file(s) that the user selects in the dialog box.

		Using the `typeFilter` parameter, you can determine which files the
		dialog box displays.

		Only one `FileReference.browse()`, `FileReference.download()`, or
		`FileReferenceList.browse()` session can be performed at a time on a
		FileReferenceList object (because only one dialog box can be opened at
		a time).

		@return Returns `true` if the parameters are valid and the
				file-browsing dialog box opens.
		@throws ArgumentError         If the `typeFilter` array does not
									  contain correctly formatted FileFilter
									  objects, an exception is thrown. For
									  details on correct filter formatting,
									  see the FileFilter documentation.
		@throws Error                 If the method is not called in response
									  to a user action, such as a mouse event
									  or keypress event.
		@throws IllegalOperationError Thrown for the following reasons: 1)
									  Another FileReference or
									  FileReferenceList browse session is in
									  progress; only one file browsing session
									  may be performed at a time. 2) A setting
									  in the user's mms.cfg file prohibits
									  this operation.
		@event cancel Invoked when the user dismisses the dialog box by
					  clicking Cancel or by closing it.
		@event select Invoked when the user has successfully selected an item
					  for upload from the dialog box.
	**/
	public function browse(typeFilter:Array<FileFilter> = null):Bool
	{
		fileList = [];
		if (!FileReference.__hasDialogBackend()) return true;

		var generation = ++__operationGeneration;
		var host = FileReference.__getHost();
		var dialogHost:FlightDialogOpenHost = cast host;
		FlightDialog.showOpenFileDialog(dialogHost, {multiple: true, filters: FileReference.__toFlightFilters(typeFilter)}).then(function(result:Dynamic):Dynamic
		{
			if (generation != __operationGeneration) return result;
			var outcome = result == null ? null : Reflect.field(result, "outcome");
			var handles = FileReference.__openDialogHandles(result);
			if (outcome == "cancelled" || (outcome == null && handles.length == 0))
			{
				dispatchEvent(new Event(Event.CANCEL));
			}
			else if ((outcome == "selected" || outcome == null) && handles.length > 0)
			{
				__selectHandles(handles, cast host, generation);
			}
			else
			{
				__dispatchIOError(outcome == null ? "Unable to open a file dialog" : outcome);
			}
			return result;
		}, function(error:Dynamic):Dynamic
		{
			if (generation == __operationGeneration) __dispatchIOError(error);
			return null;
		});
		return true;
	}

	@:noCompletion private function __dispatchIOError(error:Dynamic):Void
	{
		dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, Std.string(error)));
	}

	@:noCompletion private function __selectHandles(handles:Array<FlightFileDialogHandle>, fileSystemHost:FlightFileSystemHost, generation:Int):Void
	{
		var remaining = handles.length;
		for (handle in handles)
		{
			var reference = new FileReference();
			reference.__flightHandle = handle;
			reference.__name = handle.name;
			reference.__path = handle.path;
			reference.__type = FileReference.__typeForName(handle.name);
			fileList.push(reference);

			if (handle.path == null || fileSystemHost == null)
			{
				if (--remaining == 0 && generation == __operationGeneration) dispatchEvent(new Event(Event.SELECT));
				continue;
			}

			FlightFileSystem.statFile(fileSystemHost, handle.path).then(function(stat:FlightFileStat):FlightFileStat
			{
				if (generation != __operationGeneration) return stat;
				if (stat != null)
				{
					reference.__creationDate = Date.fromTime(stat.createdTime);
					reference.__modificationDate = Date.fromTime(stat.modifiedTime);
					reference.__size = stat.size;
				}
				if (--remaining == 0) dispatchEvent(new Event(Event.SELECT));
				return stat;
			}, function(error:Dynamic):FlightFileStat
			{
				if (generation == __operationGeneration) __dispatchIOError(error);
				return null;
			});
		}
	}
}
#end
#else
typedef FileReferenceList = flash.net.FileReferenceList;
#end
