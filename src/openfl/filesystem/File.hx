package openfl.filesystem;

#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
import flight.App as FlightApp;
import flight.Dialog as FlightDialog;
import flight.FileSystem as FlightFileSystem;
import flight._internal._Promise as FlightPromise;
import flight._internal._UInt8Array as FlightUInt8Array;
import flight.types.FileDialogFilter as FlightFileDialogFilter;
import flight.types.FileDialogHandle as FlightFileDialogHandle;
import flight.types.FileEntry as FlightFileEntry;
import flight.types.FileStat as FlightFileStat;
import flight.types.FileSystemHostBackend as FlightFileSystemHostBackend;
import flight.types.FileSystemUsage as FlightFileSystemUsage;
import flight.types.HasAppPath as FlightAppPathHost;
import flight.types.HasDialogDirectoryOpen as FlightDirectoryDialogHost;
import flight.types.HasDialogFileOpen as FlightOpenDialogHost;
import flight.types.HasDialogFileSave as FlightSaveDialogHost;
import flight.types.HasStorageFileSystem as FlightFileSystemHost;
import flight.types.Host as FlightHost;
import haxe.io.Bytes;
import haxe.io.Path;
#if lime
import lime.system.BackgroundWorker;
import lime.system.System;
#end
import openfl.desktop.Icon;
import openfl.errors.IllegalOperationError;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.events.FileListEvent;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import sys.FileSystem as SysFileSystem;
import sys.io.File as SysFile;
#if windows
import sys.io.Process;
#end
#if clay
import flight.hostClay.HostClay as FlightHostClay;
#elseif lime
import flight.hostLime.HostLime as FlightHostLime;
import flight.hostLime.LimeFileSystem as FlightLimeFileSystem;
import lime.app.Application as LimeApplication;
#end

/**
	A File object represents a path to a file or directory. This can be an existing file
	or directory, or it can be one that does not yet exist; for instance, it can represent
	the path to a file or directory that you plan to create.

	The File class has a number of properties and methods for getting information about the
	file system and for performing operations, such as copying files and directories.

	You can use File objects along with the FileStream class to read and write files.

	The File class extends the FileReference class. The FileReference class represents a
	pointer to a file, but the File class adds properties and methods that are not exposed
	in Flash or HTML5.

	The File class includes static properties that let you reference commonly used directory
	locations. These static properties include:

	* File.applicationStorageDirectory—a storage directory unique to each installed	application
	* File.applicationDirectory—the read-only directory where the application is installed
	(along with any installed assets)
	* File.desktopDirectory—the user's desktop directory
	* File.documentsDirectory—the user's documents directory
	* File.userDirectory—the user directory

	These properties have meaningful values on different operating systems. For example,
	Mac OS, Linux, and Windows each have different native paths to the user's desktop directory.
	However, the File.desktopDirectory property points to the correct desktop directory path
	on each of these platforms. To write applications that work well across platforms, use these
	properties as the basis for referencing other files used by the application. Then use the
	resolvePath() method to refine the path. For example, this code points to the preferences.xml
	file in the application storage directory:

	```haxe
	var prefsFile:File = File.applicationStorageDirectory;
	prefsFile = prefsFile.resolvePath("preferences.xml");
	```

	If you use a literal native path in referencing a file, it will only work on one platform.
	For example, the following File object would only work on Windows:

	```haxe
	new File("C:\Documents and Settings\joe\My Documents\test.txt")
	```

	The application storage directory is particularly useful. It gives an application-specific
	storage directory for the OpenFL application. It is defined by the File.applicationStorageDirectory
	property.

	@see [Related: FileStream](https://api.openfl.org/openfl/filesystem/FileStream.html)

	@event cancel    			Dispatched when a pending asynchronous operation is canceled.
	@event complete  			Dispatched when an asynchronous operation is complete.
	@event directoryListing 	Dispatched when a directory list is available as a result of a
	call to the getDirectoryListingAsync() method.
	@event ioError  			Dispatched when an error occurs during an asynchronous file operation.
	@event securityError  		Dispatched when an operation violates a security constraint.
	@event select    			Dispatched when the user selects a file or directory from a file-
	or directory-browsing dialog box.
	@event selectMultiple  		Dispatched when the user selects files from the dialog box opened
	by a call to the browseForOpenMultiple() method.

	@see [Using the native file system API](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/using-the-native-file-system-api.html)
	@see [Native file system basics](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/native-file-system-basics.html)
	@see [Working with File objects in OpenFL](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-file-objects-in-openfl.html)
	@see [Getting file system information](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/getting-file-system-information.html)
	@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	@see [Working with files](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-files.html)
	@see `openfl.filesystem.FileStream`
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class File extends FileReference
{
	/**
		The folder containing the application's installed files.

		The url* property for this object uses the app URL scheme (not the file URL scheme). This
		means that the url string is specified starting with "app:" (not "file:"). Also, if you
		create a File object relative to the File.applicationDirectory directory (by using the
		resolvePath() method), the url property of the File object also uses the app URL scheme.
		*The url property is currently unsupported on all targets execpt AIR.

		Note: You cannot write to files or directories that have paths that use the app: URL scheme.
		Also, you cannot delete or create files or folders that have paths that use the app: URL
		scheme. Modifying content in the application directory is a bad practice, for security
		reasons, and is blocked by the operating system on some platforms. If you want to store
		application-specific data, consider using the application storage directory
		(File.applicationStorageDirectory). If you want any of the content in the application
		storage directory to have access to the application-privileged functionality (AIR APIs),
		you can expose that functionality by using a sandbox bridge.

		The applicationDirectory property provides a way to reference the application directory
		that works across platforms. If you set a File object to reference the application
		directory using the nativePath or url property, it will only work on the platform for
		which that path is valid.

		On Android, the nativePath property of a File object pointing to the application directory
		is an empty string. Use the url property to access application files.

		@see [Working with File objects in OpenFL](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-file-objects-in-openfl.html)
	**/
	public static var applicationDirectory(get, never):File;

	/**
		The application's private storage directory.

		Each application has a unique, persistent application storage directory, which is
		created when you first access File.applicationStorageDirectory. This directory is unique
		to each application and user. This directory is a convenient location to store user-specific
		or application-specific data.

		The url property* for this object uses the app-storage URL scheme (not the file URL scheme).
		This means that the url string is specified starting with "app-storage:" (not "file:").
		Also, if you create a File object relative to the File.applicationStoreDirectory directory
		(by using the resolvePath() method), the url of the File object also uses the app-storage
		URL scheme (as in the example).
		*The url property is currently unsupported on all targets execpt AIR.

		The applicationStorageDirectory property provides a way to reference the application
		storage directory that works across platforms. If you set a File object to reference the
		application storage directory using the nativePath or url property, it will only work on
		the platform for which that path is valid.

		The following code creates a File object pointing to the "images" subdirectory of the application storage directory.

		```haxe
		import openfl.filesystem.File;

		var tempFiles:File = File.applicationStorageDirectory;
		tempFiles = tempFiles.resolvePath("images/");
		trace(tempFiles.url); // app-storage:/images
		```

		@see [Working with File objects in OpenFL](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-file-objects-in-openfl.html)
	**/
	public static var applicationStorageDirectory(get, never):File;

	// Flight's public getFileSystemPath("cache") currently returns its absent
	// sentinel, so cacheDirectory remains unavailable on non-AIR targets.

	/**
		The user's desktop directory.

		The desktopDirectory property provides a way to reference the desktop directory that works across platforms. If you
		set a File object to reference the desktop directory using the nativePath or url property, it will only work on the
		platform for which that path is valid.

		If an operating system does not support a desktop directory, a suitable directory in the file system is used instead.

		The following code outputs a list of files and directories contained in the user's desktop directory.

		```haxe
		import openfl.filesystem.File;
		var desktop:File = File.desktopDirectory;

		var files:Array = desktop.getDirectoryListing();

		for (i in 0...files.length) {
			trace(files[i].nativePath);
		}
		```

		@see [Working with File objects in OpenFL](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-file-objects-in-openfl.html)
	**/
	public static var desktopDirectory(get, never):File;

	/**
		The user's documents directory.

		On Windows, this is the My Documents directory (for example, C:\Documents and Settings\userName\My
		Documents). On Mac OS, the default location is /Users/userName/Documents. On Linux, the default location
		is /home/userName/Documents (on an English system), and the property observes the xdg-user-dirs setting.

		The documentsDirectory property provides a way to reference the documents directory that works across
		platforms. If you set a File object to reference the documents directory using the nativePath or url
		property, it will only work on the platform for which that path is valid.

		If an operating system does not support a documents directory, a suitable directory in the file system
		is used instead.

		The following code uses the File.documentsDirectory property and the File.createDirectory() method to
		ensure that a directory named "OpenFL Test" exists in the user's documents directory.

		```haxe
		import openfl.filesystem.File;

		var directory:File = File.documentsDirectory;
		directory = directory.resolvePath("OpenFL Test");

		File.createDirectory(directory);
		trace(directory.exists); // true
		```

		@see [Working with File objects in OpenFL](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-file-objects-in-openfl.html)
	**/
	public static var documentsDirectory(get, never):File;

	/**
		The application's working directory.
	**/
	public static var workingDirectory(get, never):File;

	// Flight has no local-file downloaded provenance flag.

	/**
		Indicates whether the referenced file or directory exists.  The value is true if the File object points
		to an existing file or directory, false otherwise.

		The following code creates a temporary file, then deletes it and uses the File.exists property to check
		for the existence of the file.

		```haxe
		import openfl.filesystem.*;

		var temp:File = File.createTempFile();
		trace(temp.exists); // true
		temp.deleteFile();
		trace(temp.exists); // false
		```
	**/
	public var exists(get, never):Bool;

	/**
		An Icon object containing the icons defined for the file. An Icon object
		is an array of BitmapData objects corresponding to the various icon
		states. On Linux, the Icon object contains no icons. On Android, the
		`icon` property is `null`.
	**/
	public var icon(default, never):Icon = null;

	/**
		Indicates whether the reference is to a directory.  The value is true if the File object points to a directory; false otherwise.

		The following code creates an array of File objects pointing to files and directories in the user directory and then uses the
		isDirectory property to list only those File objects that point to directories (not to files).

		```haxe
		import openfl.filesystem.*;

		var userDirFiles:Array = File.userDirectory.getDirectoryListing();
		for (i in 0...userDirFiles.length) {
			if (userDirFiles[i].isDirectory) {
				trace(userDirFiles[i].nativePath);
			}
		}
		```

		@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	**/
	public var isDirectory(get, never):Bool;

	/**
		Indicates whether the referenced file or directory is "hidden." The value is true if the
		referenced file or directory is hidden, false otherwise.

		The following code creates an array of File objects pointing to files and directories in
		the user directory and then uses the isHidden property to list hidden files and directories.

		```haxe
		import openfl.filesystem.*;

		var userDirFiles:Array = File.userDirectory.getDirectoryListing();
		for (i in 0...userDirFiles.length) {
			if (userDirFiles[i].isHidden) {
				trace(userDirFiles[i].nativePath);
			}
		}
		```
	**/
	public var isHidden(get, never):Bool;

	/**
		The line-ending character sequence used by the host operating system.

		On Mac OS and Linux, this is the line-feed character (character code
		`0x0A` hexadecimal). On Windows, this is the carriage return character
		(character code `0x0D` hexadecimal) followed by the line-feed character
		(character code `0x0A` hexadecimal).

		@see [Getting file system information](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/getting-file-system-information.html)
	**/
	public static var lineEnding(get, never):String;

	/**
		The full path in the host operating system representation. On Mac OS and Linux, the forward
		slash (/) character is used as the path separator. However, in Windows, you can set the nativePath
		property by using the forward slash character or the backslash (\) character as the path separator,
		and AIR automatically replaces forward slashes with the appropriate backslash character.

		Before writing code to set the nativePath property directly, consider whether doing so may result
		in platform-specific code. For example, a native path such as "C:\\Documents and Settings\\bob\\Desktop"
		is only valid on Windows. It is far better to use the following static properties, which represent
		commonly used directories, and which are valid on all platforms:

			*File.applicationDirectory
			*File.applicationStorageDirectory
			*File.desktopDirectory
			*File.documentsDirectory
			*File.userDirectory

		You can use the resolvePath() method to get a path relative to these directories.

		@throws ArgumentError The syntax of the path is invalid.
		@throws SecurityError The caller is not in the application security sandbox.

		The following code shows the difference between the nativePath property and the url property of a File object.
		The comments show results on an example Windows computer.

		```haxe
		import openfl.filesystem.File;

		var docs:File = File.documentsDirectory;
		trace(docs.nativePath); // C:\Documents and Settings\turing\My Documents
		trace(docs.url); // file:///C:/Documents%20and%20Settings/turing/My%20Documents
		```
	**/
	public var nativePath(get, set):String;

	/**
		The directory that contains the file or directory referenced by this File object.

		If the file or directory does not exist, the parent property still returns the File object that points to the
		containing directory, even if that directory does not exist.

		This property is identical to the return value for resolvePath("..") except that the parent of a root directory
		is null.

		The following code uses the parent property to show the directory that contains a temporary file.

		```haxe
		import openfl.filesystem.File;

		var tempFile:File = File.createTempDirectory();
		trace(tempFile.parent.nativePath);
		tempFile.deleteFile();
		```

		@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	**/
	public var parent(get, never):File;

	// Flight exposes per-path asynchronous access checks, not AIR's static
	// permissionStatus or platform backup-exclusion metadata.

	/**
		The host operating system's path component separator character.

		On Mac OS and Linux, this is the forward slash (`/`) character. On
		Windows, it is the backslash (`\`) character.

		Note: When using the backslash character in a String literal, remember
		to type the character twice (as in `"directory\\file.ext"`). Each pair
		of backslashes in a String literal represent a single backslash in the
		String.

		@see [Getting file system information](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/getting-file-system-information.html)
	**/
	public static var separator(get, never):String;

	// Flight does not expose the host filesystem charset.
	public var url(get, set):String;

	/**
		The user's directory.

		On Windows, this is the parent of the My Documents directory (for example, C:\Documents and Settings\userName).
		On Mac OS, it is /Users/userName. On Linux, it is /home/userName.

		The userDirectory property provides a way to reference the user directory that works across platforms. If you
		set the nativePath or url property of a File object directly, it will only work on the platform for which that
		path is valid.

		If an operating system does not support a user directory, a suitable directory in the file system is used
		instead.

		The following code outputs a list of files and directories contained in the root level of the user directory:

		```haxe
		import openfl.filesystem.File;

		var files:Array = File.userDirectory.listDirectory();
		for (i in 0...files.length) {
			trace(files[i].nativePath);
		}
		```

		@see [Working with File objects in OpenFL](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-file-objects-in-openfl.html)
	**/
	public static var userDirectory(get, never):File;

	/**
	 * Reads the contents of a file as a `ByteArray`.
	 *
	 * @param path The path to the file.
	 * @return A `ByteArray` containing the file's contents.
	 */
	public static inline function getFileBytes(path:String):ByteArray
	{
		var source:FlightUInt8Array = __resolveFlight(FlightFileSystem.readBinaryFile(__getFlightFileSystemHost(), path), null);
		if (source == null) throw new Error("File does not exist.", 3003);
		return ByteArray.fromBytes(__flightBytes(source));
	}

	/**
	 * Reads the contents of a file as a `String`.
	 *
	 * @param path The path to the file.
	 * @return A `String` containing the file's contents.
	 */
	public static inline function getFileText(path:String):String
	{
		var result = __resolveFlight(FlightFileSystem.readTextFile(__getFlightFileSystemHost(), path), null);
		if (result == null) throw new Error("File does not exist.", 3003);
		return result;
	}

	/**
	 * Saves a `ByteArray` to a file.
	 *
	 * @param path The path where the file should be saved.
	 * @param bytes The `ByteArray` to write to the file.
	 */
	public static inline function saveBytes(path:String, bytes:ByteArray):Void
	{
		var sourceBytes:Bytes = bytes;
		var source = new FlightUInt8Array(sourceBytes);
		if (!__resolveFlight(FlightFileSystem.writeBinaryFile(__getFlightFileSystemHost(), path, source), false))
		{
			throw new Error("File could not be written.");
		}
	}

	/**
	 * Saves a `String` as a text file.
	 *
	 * @param path The path where the file should be saved.
	 * @param text The `String` content to write to the file.
	 */
	public static inline function saveText(path:String, text:String):Void
	{
		if (!__resolveFlight(FlightFileSystem.writeTextFile(__getFlightFileSystemHost(), path, text), false))
		{
			throw new Error("File could not be written.");
		}
	}

	@:noCompletion private static var __driveLetters:Array<String> =
		#if windows
		[
			"A:\\", "B:\\", "C:\\", "D:\\", "E:\\", "F:\\", "G:\\", "H:\\", "I:\\", "J:\\", "K:\\", "L:\\", "M:\\", "N:\\", "O:\\", "P:\\", "Q:\\", "R:\\",
			"S:\\", "T:\\", "U:\\", "V:\\", "W:\\", "X:\\", "Y:\\", "Z:\\"
		];
		#else
		[
			"A:/", "B:/", "C:/", "D:/", "E:/", "F:/", "G:/", "H:/", "I:/", "J:/", "K:/", "L:/", "M:/", "N:/", "O:/", "P:/", "Q:/", "R:/", "S:/", "T:/", "U:/",
			"V:/", "W:/", "X:/", "Y:/", "Z:/"
		];
		#end

	@:noCompletion private static var __flightFileSystemHost:FlightFileSystemHost;
	@:noCompletion private static var __flightHost:FlightHost;
	@:noCompletion private var __dialogPending:Bool = false;
	@:noCompletion private var __fileWorker:Dynamic;
	@:noCompletion private var __fileStatsDirty:Bool = false;
	@:noCompletion private var __fileOperationGeneration:Int = 0;
	@:noCompletion private var __readOnly:Bool = false;
	@:noCompletion private var __urlScheme:String = "file";

	/**
		The constructor function for the File class.

		If you pass a path argument, the File object points to the specified path, and the nativePath property and and url
		property are set to reflect that path.

		Although you can pass a path argument to specify a file path, consider whether doing so may result in platform-specific
		code. For example, a native path such as "C:\\Documents and Settings\\bob\\Desktop" or a URL such as
		"file:///C:/Documents%20and%20Settings/bob/Desktop" is only valid on Windows. It is far better to use the following
		static properties, which represent commonly used directories, and which are valid on all platforms:

			*File.applicationDirectory
			*File.applicationStorageDirectory
			*File.desktopDirectory
			*File.documentsDirectory
			*File.userDirectory

		You can then use the resolvePath() method to get a path relative to these directories. For example, the following code
		sets up a File object to point to the settings.xml file in the application storage directory:

		```haxe
		var file:File = File.applicationStorageDirectory.resolvePath("settings.xml");
		```

		@param path	The path to the file. You can specify the path by using either a URL or native path (platform-specific)
		notation.
		@throws ArgumentError The syntax of the path parameter is invalid.
	**/
	public function new(path:String = null)
	{
		super();

		if (path == null)
		{
			return;
		}

		nativePath = path;

		if (name.length == 0)
		{
			var dirs:Array<String> = Path.directory(__path).split(separator);
			name = dirs[dirs.length - 1];
		}
	}

	/**
		Displays a file-browsing dialog box that lets the user select a file to upload.
	**/
	override public function browse(typeFilter:Array<FileFilter> = null):Bool
	{
		browseForOpen("Open", typeFilter);
		return false;
	}

	/**
		Displays a directory chooser dialog box, in which the user can select a directory.  When the user selects the
		directory, the select event is dispatched. The target property of the select event is the File object pointing to
		the selected directory.

		The directory chooser dialog is not always displayed in front of windows that are "owned" by another window
		(windows that have a non-null owner property). To avoid window ordering issues, hide owned windows before calling
		this method.

		@param title The string that is displayed in the title bar of the dialog box.
		@event cancel Dispatched when the user clicks the Cancel button in the Open File dialog box.
		@event select Dispatched when the user selects a directory and closes the directory chooser dialog box.
		@throws IllegalOperationError A browse operation (browseForOpen(), browseForOpenMultiple(), browseForSave(),
		browseForDirectory()) is currently running.

		The following code uses the File.browseForDirectory() method to let the user select a directory. When the directory
		is selected, the code lists the contents of the selected directory in the trace() output.

		```haxe
		import openfl.filesystem.File;
		import openfl.events.Event;

		var directory:File = File.documentsDirectory;

		try
		{
			directory.browseForDirectory("Select Directory");
			directory.addEventListener(Event.SELECT, directorySelected);
		}
		catch (error:Dynamic)
		{
			trace("Failed: " + error);
		}

		function directorySelected(event:Event):Void
		{
			directory = cast(event.target, File);
			var files:Array = directory.getDirectoryListing();
			for(i in 0...files.length)
			{
				trace(files[i].name);
			}
		}
		```
	**/
	public function browseForDirectory(title:String):Void
	{
		__beginDialog();
		var host = __getFlightHost();
		if (host == null)
		{
			__dialogPending = false;
			return;
		}
		var generation = ++__fileOperationGeneration;
		var dialogHost:FlightDirectoryDialogHost = cast host;
		FlightDialog.showOpenDirectoryDialog(dialogHost).then(function(result:Dynamic):Dynamic
		{
			if (generation != __fileOperationGeneration) return result;
			var handle = __directoryDialogHandle(result);
			if (handle == null) __dispatchCancel(); else __dispatchSelect(handle.path);
			return result;
		}, function(error:Dynamic):Dynamic
		{
			if (generation == __fileOperationGeneration) __dispatchDialogError(error);
			return null;
		});
	}

	/**
		Displays the Open File dialog box, in which the user can select a file to open.

		When the user selects the file, the select event is dispatched. The target property of the select event is the File
		object pointing to the selected file.

		The Open File dialog is not always displayed in front of windows that are "owned" by another window (windows that
		have a non-null owner property). To avoid window ordering issues, hide owned windows before calling this method.

		@param title The string that is displayed in the title bar of the dialog box.
		@param typeFilter An array of FileFilter instances used to filter the files that are displayed in the dialog box.
		If you omit this parameter, all files are displayed. For more information, see the FileFilter class.
		@event cancel Dispatched when the user clicks the Cancel button in the Open File dialog box.
		@event select Dispatched when the user selects a directory and closes the directory chooser dialog box.
		@throws IllegalOperationError A browse operation (browseForOpen(), browseForOpenMultiple(), browseForSave(),
		browseForDirectory()) is currently running.
		@throws SecurityError The application does not have the necessary permissions.

		The following code uses the File.browseForOpen() method to let the user choose a text file. When the file is
		selected, the code reads the file data into a string.

		```haxe
		import openfl.filesystem.*;
		import openfl.events.Event;
		import openfl.net.FileFilter;

		var fileToOpen:File = new File();
		var txtFilter:FileFilter = new FileFilter("Text", "*.as;*.css;*.html;*.txt;*.xml");

		try
		{
			fileToOpen.browseForOpen("Open", [txtFilter]);
			fileToOpen.addEventListener(Event.SELECT, fileSelected);
		}
		catch (error:Dynamic)
		{
			trace("Failed: " + error);
		}

		function fileSelected(event:Event):Void
		{
			var stream:FileStream = new FileStream();
			stream.open(event.target, FileMode.READ);
			var fileData:String = stream.readUTFBytes(stream.bytesAvailable);
			trace(fileData);
		}
		```
	**/
	public function browseForOpen(title:String, typeFilter:Array<FileFilter> = null)
	{
		__beginOpenDialog(title, typeFilter, false);
	}

	/**
		Displays the Open File dialog box, in which the user can select one or more files to open.

		When the user selects the files, the selectMultiple event is dispatched. The target property of the select event
		is this File object. Unlike browseForOpen(), with the browseForOpenMultiple() method, this File object is not
		updated to reference any of the chosen files. Instead, the resulting selectMultiple event contains an array of
		the chosen files.

		The Open File dialog is not always displayed in front of windows that are "owned" by another window (windows that
		have a non-null owner property). To avoid window ordering issues, hide owned windows before calling this method.

		@param title The string that is displayed in the title bar of the dialog box.
		@param typeFilter An array of FileFilter instances used to filter the files that are displayed in the dialog box.
		If you omit this parameter, all files are displayed. For more information, see the FileFilter class.
		@event cancel Dispatched when the user clicks the Cancel button in the Open File dialog box.
		@event select Dispatched when the user selects a directory and closes the directory chooser dialog box.
		@throws IllegalOperationError A browse operation (browseForOpen(), browseForOpenMultiple(), browseForSave(),
		browseForDirectory()) is currently running.
		@throws SecurityError The application does not have the necessary permissions.

		The following code uses the File.browseForOpenMultiple() method to let the user choose multiple files. When the
		files are selected, the code outputs the paths for the selected files.

		```haxe
		import openfl.filesystem.*;
		import openfl.events.FileListEvent;

		var docsDir:File = File.documentsDirectory;
		try
		{
			docsDir.browseForOpenMultiple("Select Files");
			docsDir.addEventListener(FileListEvent.SELECT_MULTIPLE, filesSelected);
		}
		catch (error:Dynamic)
		{
			trace("Failed: " + error);
		}

		function filesSelected(event:FileListEvent):Void
		{
			for (i in 0...event.files.length)
			{
				trace(event.files[i].nativePath);
			}
		}
		```
	**/
	public function browseForOpenMultiple(title:String, typeFilter:Array<FileFilter> = null):Void
	{
		__beginOpenDialog(title, typeFilter, true);
	}

	/**
		Displays the Save File dialog box, in which the user can select a file destination.

		When the user selects the file, the select event is dispatched. The target property of the select event is the
		File object pointing to the selected Save destination.

		The Save File dialog is not always displayed in front of windows that are "owned" by another window (windows
		that have a non-null owner property). To avoid window ordering issues, hide owned windows before calling this
		method.

		@param title The string that is displayed in the title bar of the dialog box.
		If you omit this parameter, all files are displayed. For more information, see the FileFilter class.
		@event cancel Dispatched when the user clicks the Cancel button in the Open File dialog box.
		@event select Dispatched when the user selects a directory and closes the directory chooser dialog box.
		@throws IllegalOperationError A browse operation (browseForOpen(), browseForOpenMultiple(), browseForSave(),
		browseForDirectory()) is currently running.
		@throws SecurityError The application does not have the necessary permissions.

		The following code uses the File.browseForSave() method to let the user select a path for saving a file. When
		the files are selected, the code saves data to the selected file path.

		```haxe
		import openfl.filesystem.*;
		import openfl.events.Event;

		var docsDir:File = File.documentsDirectory;
		try
		{
			docsDir.browseForSave("Save As");
			docsDir.addEventListener(Event.SELECT, saveData);
		}
		catch (error:Dynamic)
		{
			trace("Failed: " + error);
		}

		function saveData(event:Event):Void
		{
			var newFile:File = cast(event.target, File);
			var str:String = "Hello.";
			if (!newFile.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(newFile, FileMode.WRITE);
				stream.writeUTFBytes(str);
				stream.close();
			}
		}
		```
	**/
	public function browseForSave(title:String):Void
	{
		__beginDialog();
		var host = __getFlightHost();
		if (host == null)
		{
			__dialogPending = false;
			return;
		}
		var generation = ++__fileOperationGeneration;
		var options:Dynamic = {defaultName: name};
		Reflect.setField(options, "title", title);
		Reflect.setField(options, "defaultPath", __path);
		var dialogHost:FlightSaveDialogHost = cast host;
		FlightDialog.showSaveFileDialog(dialogHost, cast options).then(function(result:Dynamic):Dynamic
		{
			if (generation != __fileOperationGeneration) return result;
			var handle = __saveDialogHandle(result);
			if (handle == null) __dispatchCancel(); else __dispatchSelect(handle.path);
			return result;
		}, function(error:Dynamic):Dynamic
		{
			if (generation == __fileOperationGeneration) __dispatchDialogError(error);
			return null;
		});
	}

	/**
		Cancels any pending asynchronous operation.
	**/
	override public function cancel():Void
	{
		__fileWorker.cancel();
		dispatchEvent(new Event(Event.CANCEL));
	}

	/**
		Canonicalizes the File path.

		If the File object represents an existing file or directory, canonicalization adjusts the path so that it
		matches the case of the actual file or directory name. If the File object is a symbolic link,
		canonicalization adjusts the path so that it matches the file or directory that the link points to,
		regardless of whether the file or directory that is pointed to exists. On case sensitive file systems (such
		as Linux), when multiple files exist with names differing only in case, the canonicalize() method adjusts
		the path to match the first file found (in an order determined by the file system).

		The following code shows how to use the canonicalize() method to find the correct capitalization of a
		directory name. Before running this example, create a directory named _OpenFL Test_ on the desktop of your computer.

		```haxe
		import openfl.filesystem.*;

		var path:File = File.desktopDirectory.resolvePath("openfl test");
		trace(path.nativePath);
		path.canonicalize();
		trace(path.nativePath); // ...\OpenFL Test
		```
	**/
	public function canonicalize():Void
	{
		var segs:Array<String> = __path.split(separator);

		var cPath:String = __driveLetters[__driveLetters.indexOf(segs[0].toUpperCase() + separator)];
		var start:Int = 1;
		if (cPath == null)
		{
			// fall back to unix paths
			var firstSeg = segs[1];
			if (firstSeg == "." || firstSeg == "..")
			{
				cPath = separator;
			}
			else
			{
				cPath = separator + firstSeg + separator;
			}
			start = 2;
		}

		var i = segs.length - 1;
		var dotDotStack = 0;
		while (i >= start)
		{
			var seg = segs[i];
			if (seg == ".")
			{
				segs.splice(i, 1);
			}
			else
			{
				var isDotDot = seg == "..";
				if (dotDotStack > 0 && !isDotDot)
				{
					segs.splice(i, 1);
					dotDotStack--;
				}
				else if (isDotDot)
				{
					segs.splice(i, 1);
					dotDotStack++;
				}
			}
			i--;
		}

		for (i in start...segs.length)
		{
			cPath += __canonicalize(cPath, segs[i]) + separator;
		}

		__path = Path.removeTrailingSlashes(cPath);
	}

	/**
		Returns a copy of this File object. Event registrations are not copied.

		Note: This method does not copy the file itself. It simply makes a copy of the instance of the Haxe
		File object. To copy a file, use the copyTo() method.
	**/
	public function clone():File
	{
		var fileClass:Class<File> = File;

		var fileClone:Dynamic = Type.createEmptyInstance(fileClass);

		var fields:Array<String> = Type.getInstanceFields(fileClass);
		for (field in fields)
		{
			try
			{
				Reflect.setProperty(fileClone, field, Reflect.getProperty(this, field));
			}
			catch (e:Dynamic) {}
		}
		return fileClone;
	}

	/**
		Copies the file or directory at the location specified by this File object to the location
		specified by the newLocation parameter. The copy process creates any required parent directories
		(if possible). When overwriting files using copyTo(), the file attributes are also overwritten.

		@param newLocation The target location of the new file. Note that this File object specifies the
		resulting (copied) file or directory, not the path to the containing directory.
		@param overwrite If false, the copy fails if the file specified by the target parameter already
		exists. If true, the operation overwrites existing file or directory of the same name.
		@throws IOError The source does not exist; or the source could not be copied to the target; or
		the source and destination refer to the same file or folder and overwrite is set to true. On
		Windows, you cannot copy a file that is open or a directory that contains a file that is open.
		@throws SecurityError The application does not have the necessary permissions.

		The following code shows how to use the copyTo() method to copy a file. Before running this code,
		create a test1.txt file in the AIR Test subdirectory of the documents directory on your computer.
		The resulting copied file is named test2.txt, and it is also in the OpenFL Test subdirectory. When
		you set the overwrite parameter to true, the operation overwrites any existing test2.txt file.

		```haxe
		import openfl.filesystem.File;
		import openfl.events.Event;

		var sourceFile:FileReference = File.documentsDirectory;
		sourceFile = sourceFile.resolvePath("OpenFL Test/test1.txt");
		var destination:FileReference = File.documentsDirectory;
		destination = destination.resolvePath("OpenFL Test/test2.txt");

		if (sourceFile.copyTo(destination, true)) {
			trace("Done.");
		}
		```

		The following code shows how to use the copyTo() method to copy a file. Before running this code,
		create a test1.txt file in the OpenFL Test subdirectory of the home directory on your computer. The
		resulting copied file is named test2.txt. The try and catch statements show how to respond to errors.

		```haxe
		import openfl.filesystem.File;

		var sourceFile:File = File.documentsDirectory;
		sourceFile = sourceFile.resolvePath("OpenFL Test/test1.txt");
		var destination:File = File.documentsDirectory;
		destination = destination.resolvePath("OpenFL Test/test2.txt");

		try
		{
			sourceFile.copyTo(destination, true);
		}
		catch (error:Dynamic)
		{
			trace("Error: " + error);
		}
		```

		@see [Working with files](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-files.html)
	**/
	public function copyTo(newLocation:FileReference, overwrite:Bool = false):Void
	{
		if (newLocation == null) throw new ArgumentError("One of the parameters is invalid.");
		var target:File = Std.isOfType(newLocation, File) ? cast newLocation : new File(newLocation.__path);
		target.__ensureWritable();
		if (!overwrite && target.exists)
		{
			throw new Error("Overwrite is false.");
		}
		if (!exists) throw new Error("File or directory does not exist.", 3003);

		if (isDirectory)
		{
			target.createDirectory();
			for (file in getDirectoryListing())
			{
				file.copyTo(target.resolvePath(file.name), overwrite);
			}
		}
		else
		{
			var parent = target.parent;
			if (parent != null && !parent.exists) parent.createDirectory();
			if (!__resolveFlight(FlightFileSystem.copyFile(__getFlightFileSystemHost(), __path, target.__path), false))
			{
				throw new Error("File or directory does not exist.", 3003);
			}
		}
	}

	/**
		Begins copying the file or directory at the location specified by this File object to the
		location specified by the destination parameter.

		Upon completion, either a complete event (successful) or an ioError event (unsuccessful) is dispatched.
		The copy process creates any required parent directories (if possible).

		@param newLocation The target location of the new file. Note that this File object specifies the
		resulting (copied) file or directory, not the path to the containing directory.
		@param overwrite If false, the copy fails if the file specified by the target parameter already
		exists. If true, the operation overwrites existing file or directory of the same name.
		@event complete Dispatched when the file or directory has been successfully copied.
		@event ioError The source does not exist; or the source could not be copied to the target; or the source
		and destination refer to the same file or folder and overwrite is set to true. On Windows, you cannot
		copy a file that is open or a directory that contains a
		file that is open.
		@throws SecurityError The application does not have the necessary permissions to write to the destination.

		The following code shows how to use the copyToAsync() method to copy a file. Before running this code,
		be sure to create a test1.txt file in the OpenFL Test subdirectory of the documents directory on your computer.
		The resulting copied file is named test2.txt, and it is also in the _OpenFL Test_ subdirectory. When you set the
		overwrite parameter to true, the operation overwrites any existing test2.txt file.

		```haxe
		import openfl.filesystem.File;
		import openfl.events.Event;

		var sourceFile:File = File.documentsDirectory;
		sourceFile = sourceFile.resolvePath("OpenFL Test/test1.txt");
		var destination:File = File.documentsDirectory;
		destination = destination.resolvePath("OpenFL Test/test2.txt");

		sourceFile.copyToAsync(destination, true);
		sourceFile.addEventListener(Event.COMPLETE, fileCopiedHandler);

		function fileCopiedHandler(event:Event):Void {
			trace("Done.");
		}
		```

		@see [Working with files](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-files.html)
	**/
	public function copyToAsync(newLocation:FileReference, overwrite:Bool = false):Void
	{
		__runAsync(function():Void copyTo(newLocation, overwrite));
	}

	/**
		Creates the specified directory and any necessary parent directories. If the directory already exists,
		no action is taken.

		@throws	IOError The directory did not exist and could not be created.
		@throws SecurityError The application does not have the necessary permissions.

		The following code moves a file named test.txt on the desktop to the OpenFL Test subdirectory of the
		documents directory. The call to the createDirectory() method ensures that the _OpenFL Test_ directory
		exists before the file is moved.

		```haxe
		import openfl.filesystem.*;

		var source:File = File.desktopDirectory.resolvePath("test.txt");
		var target:File = File.documentsDirectory.resolvePath("OpenFL Test/test.txt");
		var targetParent:File = target.parent;
		targetParent.createDirectory();
		source.moveTo(target, true);
		```

		@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	**/
	public function createDirectory():Void
	{
		__ensureWritable();
		if (!__resolveFlight(FlightFileSystem.makeDirectory(__getFlightFileSystemHost(), __path), false))
		{
			throw new Error("Directory could not be created.");
		}
	}

	/**
		Deletes the directory.

		@param deleteDirectoryContents Specifies whether or not to delete a directory that contains files or
		subdirectories. When false, if the directory contains files or directories, a call to this method throws
		an exception.
		@throws	IOError The directory does not exist, or the directory could not be deleted. On Windows, you
		cannot delete a directory that contains a file that is open.
		@throws SecurityError The application does not have the necessary permissions to delete the directory.

		The following code creates an empty directory and then uses the deleteDirectory() method to delete the directory.

		```haxe
		import openfl.filesystem.File;

		var directory:File = File.documentsDirectory.resolvePath("Empty Junk Directory/");
		File.createDirectory(directory);
		trace(directory.exists); // true
		directory.deleteDirectory();
		trace(directory.exists); // false
		```

		@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	**/
	public function deleteDirectory(deleteDirectoryContents:Bool = false):Void
	{
		__ensureWritable();
		if (!__resolveFlight(FlightFileSystem.removeDirectory(__getFlightFileSystemHost(), __path, deleteDirectoryContents), false))
		{
			throw new Error("Folder is not empty.", 3010);
		}
	}

	/**
		Deletes the directory asynchronously.

		@param deleteDirectoryContents Specifies whether or not to delete a directory that contains files or
		subdirectories. When false, if the directory contains files or directories, a call to this method throws
		an exception.
		@event complete Dispatched when the directory has been deleted successfully.
		@event ioError The directory does not exist or could not be deleted. On Windows, you cannot delete a
		directory that contains a file that is open.
		@throws SecurityError The application does not have the necessary permissions to delete the directory.

		@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	**/
	public function deleteDirectoryAsync(deleteDirectoryContents:Bool = false):Void
	{
		__runAsync(function():Void deleteDirectory(deleteDirectoryContents));
	}

	/**
		Deletes the file.

		@throws	IOError The file does not exist, or could not be deleted. On Windows, you
		cannot delete a file that is currently open.
		@throws SecurityError The application does not have the necessary permissions to delete the file.

		The following code creates a temporary file and then calls the deleteFile() method to delete it.

		```haxe
		import openfl.filesystem.*;

		var file:File = File.createTempFile();
		trace(file.exists); // true
		file.deleteFile();
		trace(file.exists); // false
		```

		@see [Working with files](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-files.html)
	**/
	public function deleteFile():Void
	{
		__ensureWritable();
		if (!__resolveFlight(FlightFileSystem.removeFile(__getFlightFileSystemHost(), __path), false))
		{
			throw new Error("File does not exist.", 3003);
		}
	}

	/**
		Deletes the file asynchronously.

		@event complete Dispatched when the file has been deleted successfully.
		@event ioError The file does not exist or could not be deleted. On Windows, you cannot delete a
		a file that is currently open.
		@throws SecurityError The application does not have the necessary permissions to delete the file.

		@see [Working with files](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-files.html)
	**/
	public function deleteFileAsync():Void
	{
		__runAsync(deleteFile);
	}

	/**
		Returns an array of File objects corresponding to files and directories in the directory
		represented by this File object. This method does not explore the contents of subdirectories.

		The following code shows how to use the getDirectoryListing() method to enumerate the contents of the
		user directory.

		```haxe
		import openfl.filesystem.File;

		var directory:File = File.userDirectory;
		var list:Array = directory.getDirectoryListing();
		for (i in 0...list.length) {
			trace(list[i].nativePath);
		}
		```

		@returns Array An array of File objects.

		@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	**/
	public function getDirectoryListing():Array<File>
	{
		if (!isDirectory)
		{
			throw new Error("Not a directory.", 3007);
		}

		var entries = __resolveFlight(FlightFileSystem.readDirectory(__getFlightFileSystemHost(), __path), []);
		return [for (entry in entries) __fileFromEntry(entry)];
	}

	/**
		Asynchronously retrieves an array of File objects corresponding to the contents of the
		directory represented by this File object.

		@event ioError You do not have adequate permissions to read this directory, or the directory does
		not exist.
		@event directoryListing The directory contents have been enumerated successfully. The contents
		event includes a files property, which is the resulting array of File objects.

		The following code shows how to use the getDirectoryListingAsync() method to enumerate the contents
		of the user directory.

		```haxe
		import openfl.filesystem.File;
		import openfl.events.FileListEvent;

		var directory:File = File.userDirectory;
		directory.getDirectoryListingAsync();
		directory.addEventListener(FileListEvent.DIRECTORY_LISTING, directoryListingHandler);

		function directoryListingHandler(event:FileListEvent):Void {
			var list:Array = event.files;
			for (i in 0...list.length) {
				trace(list[i].nativePath);
			}
		}
		```

		@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	**/
	public function getDirectoryListingAsync():Void
	{
		if (!isDirectory)
		{
			throw new Error("Not a directory.", 3007);
		}

		#if lime
		__fileWorker = new BackgroundWorker();
		__fileWorker.onError.add(function(e:Dynamic):Void
		{
			__fileWorker = null;
			throw e;
		});
		__fileWorker.onComplete.add(function(event:FileListEvent):Void
		{
			__fileWorker = null;
			dispatchEvent(event);
		});
		__fileWorker.doWork.add(function(m:Dynamic)
		{
			var fileNames:Array<String> = null;
			try
			{
				fileNames = SysFileSystem.readDirectory(__path);
			}
			catch (e:Dynamic)
			{
				var ioErrorEvent = __createIoErrorEvent(e);
				if (ioErrorEvent != null) __fileWorker.sendComplete(ioErrorEvent);
				else __fileWorker.sendError(e);
				return;
			}
			var files:Array<File> = [];
			for (fileName in fileNames)
			{
				files.push(new File(__path == separator ? separator + fileName : __path + separator + fileName));
			}
			__fileWorker.sendComplete(new FileListEvent(FileListEvent.DIRECTORY_LISTING, files));
		});
		__fileWorker.run();
		#else
		var generation = ++__fileOperationGeneration;
		FlightFileSystem.readDirectory(__getFlightFileSystemHost(), __path).then(function(entries:Array<FlightFileEntry>):Array<FlightFileEntry>
		{
			if (generation == __fileOperationGeneration)
			{
				dispatchEvent(new FileListEvent(FileListEvent.DIRECTORY_LISTING, [for (entry in entries) __fileFromEntry(entry)]));
			}
			return entries;
		}, function(error:Dynamic):Array<FlightFileEntry>
		{
			if (generation == __fileOperationGeneration) __dispatchFileIOError(error);
			return [];
		});
		#end
	}

	/**
		Finds the relative path between two File paths.

		The relative path is the list of components that can be appended to (resolved against) this reference
		in order to locate the second (parameter) reference. The relative path is returned using the "/"
		separator character.

		Optionally, relative paths may include ".." references, but such paths will not cross conspicuous volume
		boundaries.

		@param ref A File object against which the path is given.
		@param useDotDot  Specifies whether the resulting relative path can use ".." components.
		@returns String The relative path between this file (or directory) and the ref file (or directory), if possible; otherwise null.
		@throws	ArgumentError The reference is null.
		@throws SecurityError The caller is not in the application security sandbox.
	**/
	public function getRelativePath(ref:FileReference, useDotDot:Bool = false):String
	{
		// Flight currently has normalize/join helpers but no relative-path query,
		// so retain OpenFL's component comparison until that primitive exists.

		function breakPath(path:String):Array<String>
		{
			var dirs:Array<String> = [];
			var lastBreak:Int = 0;

			for (i in 0...path.length)
			{
				var char:String = path.charAt(i);

				if (path.charAt(i) == "\\" || char == "/")
				{
					dirs.push(path.substring(lastBreak, i));
					lastBreak = i + 1;
				}
			}

			if (path.length != lastBreak)
			{
				dirs.push(path.substring(lastBreak, path.length));
			}
			return dirs;
		}

		var thisPath:Array<String> = breakPath(__path);
		var refPath:Array<String> = breakPath(ref.__path);

		var relatives:Array<String> = [];

		if (thisPath.length >= refPath.length)
		{
			for (j in 0...thisPath.length)
			{
				if (useDotDot)
				{
					var thisSeg:String = thisPath[j];
					var refSeg:String = refPath[j];

					if (thisSeg == refSeg)
					{
						continue;
					}
					if (j == 0)
					{
						break;
					}

					relatives.unshift("..");

					if (refSeg != null)
					{
						relatives.push(refSeg);
					}
				}
			}
		}
		else
		{
			for (j in 0...refPath.length)
			{
				var thisSeg:String = thisPath[j];
				var refSeg:String = refPath[j];

				if (thisSeg == refSeg)
				{
					if (thisPath.length == 1)
					{
						if (useDotDot)
						{
							relatives.push("..");
						}
						else
						{
							break;
						}
					}
					continue;
				}

				if (j == 0)
				{
					break;
				}

				relatives.push(refSeg);
			}
		}

		var relativePath:String = "";

		for (k in 0...relatives.length)
		{
			relativePath += relatives[k] + (k != relatives.length - 1 || refPath.length == 1 ? separator : "");
		}

		return relativePath == "" && ref.__path != __path ? null : relativePath;
	}

	/**
		Moves the file or directory at the location specified by this File object to the
		location specified by the destination parameter.

		To rename a file, set the destination parameter to point to a path that is in the
		file's directory, but with a different filename.

		The move process creates any required parent directories (if possible).

		@param newLocation The target location for the move. This object specifies the path to the
		resulting (moved) file or directory, not the path to the containing directory.
		@param overwrite If false, the move fails if the target file already exists. If true, the
		operation overwrites any existing file or directory of the same name.
		@throws	IOError  The source does not exist; or the destination exists and overwrite is set to
		false; or the source file or directory could not be moved to the target location; or the source
		and destination refer to the same file or folder and overwrite is set to true. On Windows, you
		cannot move a file that is open or a directory that contains a file that is open.
		@throws SecurityError The application does not have the necessary permissions to move the file.

		The following code shows how to use the moveTo() method to rename a file. The original filename
		is test1.txt and the resulting filename is test2.txt. Since both the source and destination File
		object point to the same directory (the Apollo Test subdirectory of the user's documents directory),
		the moveTo() method renames the file, rather than moving it to a new directory. Before running this
		code, create a test1.txt file in the OpenFL Test subdirectory of the documents directory on your
		computer. When you set the overwrite parameter to true, the operation overwrites any existing test2.txt
		file.

		```haxe
		import openfl.filesystem.File;
		import openfl.events.Event;

		var sourceFile:File = File.documentsDirectory;
		sourceFile = sourceFile.resolvePath("OpenFL Test/test1.txt");
		var destination:File = File.documentsDirectory;
		destination = destination.resolvePath("Apollo Test/test2.txt");

		try
		{
			sourceFile.moveTo(destination, true);
		}
		catch (error:Dynamic)
		{
			trace("Error: " + error);
		}
		```

		@see [Working with files](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-files.html)
	**/
	public function moveTo(newLocation:FileReference, overwrite:Bool = false):Void
	{
		if (!overwrite && SysFileSystem.exists(newLocation.__path))
		{
			throw new Error("Overwrite is set to false");
		}
		copyTo(newLocation, overwrite);
		if (isDirectory)
		{
			deleteDirectory(true);
		}
		else
		{
			deleteFile();
		}
	}

	/**
			Begins moving the file or directory at the location specified by this File object to
			the location specified by the newLocation parameter.

			To rename a file, set the destination parameter to point to a path that is in the file's directory, but
			with a different filename.

			The move process creates any required parent directories (if possible).

			@param newLocation The target location for the move. This object specifies the path to the
			resulting (moved) file or directory, not the path to the containing directory.
			@param overwrite If false, the move fails if the target file already exists. If true, the
			operation overwrites any existing file or directory of the same name.
			@event complete Dispatched when the file or directory has been successfully moved.
			@event ioError The source does not exist; or the destination exists and overwrite is false; or
			the source could not be moved to the target; or the source and destination refer to the same file
			or folder and overwrite is set to true. On Windows, you cannot move a file that is open or a directory
			that contains a file that is open.
			@throws SecurityError The application does not have the necessary permissions to move the file.

			The following code shows how to use the moveToAsync() method to rename a file. The original filename
			is test1.txt and the resulting name is test2.txt. Since both the source and destination File object
			point to the same directory (the _OpenFL Test_ subdirectory of the user's documents directory), the
			moveToAsync() method renames the file, rather than moving it to a new directory. Before running this
			code, create a test1.txt file in the _OpenFL Test_ subdirectory of the documents directory on your
			computer. When you set overwrite parameter to true, the operation overwrites any existing test2.txt file.

			```haxe
			import openfl.filesystem.File;
			import openfl.events.Event;

			var sourceFile:File = File.documentsDirectory;
			sourceFile = sourceFile.resolvePath("OpenFL Test/test1.txt");
			var destination:File = File.documentsDirectory;
			destination = destination.resolvePath("OpenFL Test/test2.txt");

			sourceFile.moveToAsync(destination, true);
			sourceFile.addEventListener(Event.COMPLETE, fileMoveCompleteHandler);

			function fileMoveCompleteHandler(event:Event):Void
			{
				trace("Done.")
			}
		```

		@see [Working with files](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-files.html)
	**/
	public function moveToAsync(newLocation:FileReference, overwrite:Bool = false):Void
	{
		__runAsync(function():Void moveTo(newLocation, overwrite));
	}

	/**
		Opens the file in the application registered by the operating system to open this file type.
	**/
	public function openWithDefaultApplication():Void
	{
		#if lime
		System.openFile(__path);
		#end
	}

	/**
		Creates a new File object with a path relative to this File object's path, based on the path
		parameter (a string).

		You can use a relative path or absolute path as the path parameter.

		If you specify a relative path, the given path is "appended" to the path of the File object. However, use
		of ".." in the path can return a resulting path that is not a child of the File object. The resulting
		reference need not refer to an actual file system location.

		If you specify an absolute file reference, the method returns the File object pointing to that path. The
		absolute file reference should use valid native path syntax for the user's operating system (such as
		"C:\\test" on Windows). Do not use a URL (such as "file:///c:/test") as the path parameter.

		All resulting paths are normalized as follows:

			Any "." element is ignored.
			Any ".." element consumes its parent entry.
			No ".." reference that reaches the file system root or the application-persistent storage root passes
			that node; it is ignored.

		You should always use the forward slash (/) character as the path separator. On Windows, you can also use
		the backslash (\) character, but you should not. Using the backslash character can lead to applications
		that do not work on other platforms.

		Filenames and directory names are case-sensitive on Linux.

		@param path The path to append to this File object's path (if the path parameter is a relative path); or
		the path to return (if the path parameter is an absolute path).
		@returns File A new File object pointing to the resulting path.
	**/
	public function resolvePath(path:String):File
	{
		var directoryPath:String = Path.removeTrailingSlashes(__path);
		var result = new File('$directoryPath$separator$path');
		result.__urlScheme = __urlScheme;
		return result;
	}

	/**
		Returns a reference to a new temporary directory. This is a new directory in the system's
		temporary directory path.

		This method lets you identify a new, unique directory, without having to query the system to
		see that the directory is new and unique.

		You may want to delete the temporary directory before closing the application, since on some
		devices it is not deleted automatically.

		The following code uses the createTempFile() method to obtain a reference to a new temporary
		directory.

		```haxe
		import openfl.File;

		var temp:File = File.createTempDirectory();
		trace(temp.nativePath);
		```

		Each time you run this code, a new (unique) file is created.

		@returns File A File object referencing the new temporary directory.

		@see [Working with directories](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-directories.html)
	**/
	public static function createTempDirectory():File
	{
		return new File(__getTempPath(true));
	}

	/**
		Returns a reference to a new temporary file. This is a new file in the system's temporary
		directory path.

		This method lets you identify a new, unique file, without having to query the system to see that
		the file is new and unique.

		You may want to delete the temporary file before closing the application, since it is not deleted
		automatically.

		The following code uses the createTempFile() method to obtain a reference to a new temporary file.

		```haxe
		import openfl.File;

		var temp:File = File.createTempFile();
		trace(temp.nativePath);
		```

		@returns File A File object referencing the new temporary file;

		@see [Working with files](https://books.openfl.org/openfl-developers-guide/working-with-the-file-system/working-with-files.html)
	**/
	public static function createTempFile():File
	{
		return new File(__getTempPath(false));
	}

	/**
		Returns an array of File objects, listing the file system root directories.

		For example, on Windows this is a list of volumes such as the C: drive and the D: drive. An empty
		drive, such as a CD or DVD drive in which no disc is inserted, is not included in this array. On Mac
		OS and Linux, this method always returns the unique root directory for the machine (the "/" directory)

		On file systems for which the root is not readable, such as the Android file system, the properties of
		the returned File object do not always reflect the true value. For example, on Android, the
		spaceAvailable property reports 0.

		The following code outputs a list of root directories:

		```haxe
		import flash.filesystem.File;
		var rootDirs:Array = File.getRootDirectories();

		for (i in 0...rootDirs.length) {
			trace(rootDirs[i].nativePath);
		}
		```

		@returns Array An array of File objects, listing the root directories.
	**/
	public static function getRootDirectories():Array<File>
	{
		var rootDirs:Array<File> = [];
		for (letter in __driveLetters)
		{
			if (new File(letter).exists)
			{
				rootDirs.push(new File(letter));
			}
		}
		return rootDirs;
	}

	@:noCompletion private function __beginDialog():Void
	{
		if (__dialogPending) throw new IllegalOperationError("File Dialog is already open.");
		__dialogPending = true;
	}

	@:noCompletion private function __beginOpenDialog(title:String, typeFilter:Array<FileFilter>, multiple:Bool):Void
	{
		__beginDialog();
		var host = __getFlightHost();
		if (host == null)
		{
			__dialogPending = false;
			return;
		}
		var generation = ++__fileOperationGeneration;
		var options:Dynamic = {filters: __toFlightFilters(typeFilter), multiple: multiple};
		Reflect.setField(options, "title", title);
		Reflect.setField(options, "defaultPath", __path);
		var dialogHost:FlightOpenDialogHost = cast host;
		FlightDialog.showOpenFileDialog(dialogHost, cast options).then(function(result:Dynamic):Dynamic
		{
			if (generation != __fileOperationGeneration) return result;
			var handles = __openDialogHandles(result);
			if (handles.length == 0)
			{
				__dispatchCancel();
			}
			else if (multiple)
			{
				__dispatchSelectMultiple([for (handle in handles) handle.path]);
			}
			else
			{
				__dispatchSelect(handles[0].path);
			}
			return result;
		}, function(error:Dynamic):Dynamic
		{
			if (generation == __fileOperationGeneration) __dispatchDialogError(error);
			return null;
		});
	}

	@:noCompletion private static function __directoryDialogHandle(result:Dynamic):FlightFileDialogHandle
	{
		if (result == null) return null;
		if (Std.isOfType(result, Array))
		{
			var handles:Array<FlightFileDialogHandle> = cast result;
			return handles.length == 0 ? null : handles[0];
		}
		if (Reflect.hasField(result, "kind")) return cast result;
		return cast Reflect.field(result, "handle");
	}

	@:noCompletion private function __ensureWritable():Void
	{
		if (__readOnly) throw new Error("The application directory is read-only.");
	}

	@:noCompletion private function __fileFromEntry(entry:FlightFileEntry):File
	{
		var result = new File(entry.path);
		result.__urlScheme = __urlScheme;
		result.__readOnly = __readOnly;
		return result;
	}

	@:noCompletion private static function __flightStat(path:String):FlightFileStat
	{
		if (path == null || path == "") return null;
		return __resolveFlight(FlightFileSystem.statFile(__getFlightFileSystemHost(), path), null);
	}

	@:noCompletion private static function __getFlightFileSystemHost():FlightFileSystemHost
	{
		var host = __getFlightHost();
		if (host != null) return cast host;
		if (__flightFileSystemHost != null) return __flightFileSystemHost;
		#if lime
		__flightFileSystemHost = cast {storage: {fileSystem: FlightLimeFileSystem.createLimeFileSystemBackend()}};
		#end
		if (__flightFileSystemHost == null)
		{
			// Headless and interpreter builds have no Lime/Clay application from
			// which to obtain a host. Install a system host at the Flight boundary
			// so the adapter still uses the public FileSystem facade exclusively.
			__flightFileSystemHost = cast {storage: {fileSystem: __createSystemFileSystemBackend()}};
		}
		return __flightFileSystemHost;
	}

	@:noCompletion private static function __createSystemFileSystemBackend():FlightFileSystemHostBackend
	{
		var backend:Dynamic = {};
		backend.readTextFile = function(path:String):FlightPromise<Dynamic>
			return __flightDone(try SysFile.getContent(path) catch (_:Dynamic) null);
		backend.writeTextFile = function(path:String, data:String):FlightPromise<Dynamic>
			return __flightDone(try
			{
				SysFile.saveContent(path, data);
				true;
			}
			catch (_:Dynamic) false);
		backend.readBinaryFile = function(path:String):FlightPromise<Dynamic>
			return __flightDone(try (new FlightUInt8Array(SysFile.getBytes(path)) : Dynamic) catch (_:Dynamic) null);
		backend.readBinaryFileRange = function(path:String, offset:Float, length:Float):FlightPromise<Dynamic>
			return __flightDone(try
			{
				var bytes = SysFile.getBytes(path);
				var start = Std.int(offset);
				var count = start >= bytes.length ? 0 : Std.int(Math.min(length, bytes.length - start));
				(new FlightUInt8Array(bytes.sub(start, count)) : Dynamic);
			}
			catch (_:Dynamic) null);
		backend.writeBinaryFile = function(path:String, data:FlightUInt8Array):FlightPromise<Dynamic>
			return __flightDone(try
			{
				SysFile.saveBytes(path, __flightBytes(data));
				true;
			}
			catch (_:Dynamic) false);
		backend.fileExists = function(path:String):FlightPromise<Dynamic>
			return __flightDone(try SysFileSystem.exists(path) && !SysFileSystem.isDirectory(path) catch (_:Dynamic) false);
		backend.directoryExists = function(path:String):FlightPromise<Dynamic>
			return __flightDone(try SysFileSystem.exists(path) && SysFileSystem.isDirectory(path) catch (_:Dynamic) false);
		backend.removeFile = function(path:String):FlightPromise<Dynamic>
			return __flightDone(try
			{
				SysFileSystem.deleteFile(path);
				true;
			}
			catch (_:Dynamic) false);
		backend.removeDirectory = function(path:String, recursive:Null<Bool>):FlightPromise<Dynamic>
			return __flightDone(try
			{
				if (recursive == true) __removeSystemTree(path); else SysFileSystem.deleteDirectory(path);
				true;
			}
			catch (_:Dynamic) false);
		backend.makeDirectory = function(path:String):FlightPromise<Dynamic>
			return __flightDone(try
			{
				if (!SysFileSystem.exists(path)) SysFileSystem.createDirectory(path);
				SysFileSystem.isDirectory(path);
			}
			catch (_:Dynamic) false);
		backend.readDirectory = function(path:String):FlightPromise<Dynamic>
			return __flightDone(try __systemDirectoryEntries(path) catch (_:Dynamic) ([] : Array<Dynamic>));
		backend.statFile = function(path:String):FlightPromise<Dynamic>
			return __flightDone(try
			{
				var stat = SysFileSystem.stat(path);
				({
					size: (stat.size : Float),
					isDirectory: SysFileSystem.isDirectory(path),
					modifiedTime: stat.mtime.getTime(),
					createdTime: stat.ctime.getTime(),
					isSymlink: false
				} : Dynamic);
			}
			catch (_:Dynamic) null);
		backend.rename = function(from:String, to:String):FlightPromise<Dynamic>
			return __flightDone(try
			{
				SysFileSystem.rename(from, to);
				true;
			}
			catch (_:Dynamic) false);
		backend.copy = function(from:String, to:String):FlightPromise<Dynamic>
			return __flightDone(try
			{
				SysFile.copy(from, to);
				true;
			}
			catch (_:Dynamic) false);
		backend.appendTextFile = function(path:String, data:String):FlightPromise<Dynamic>
			return __flightDone(try
			{
				var output = SysFile.append(path, false);
				output.writeString(data);
				output.close();
				true;
			}
			catch (_:Dynamic) false);
		backend.canAccessFile = function(path:String, mode:String):FlightPromise<Dynamic>
			return __flightDone(__canAccessSystemFile(path, mode));
		backend.getFileSystemUsage = function():FlightPromise<Dynamic> return __flightDone(null);
		return cast backend;
	}

	@:noCompletion private static function __canAccessSystemFile(path:String, mode:String):Bool
	{
		if (!SysFileSystem.exists(path) || SysFileSystem.isDirectory(path)) return false;
		return try
		{
			if (mode == "readable")
			{
				var input = SysFile.read(path, true);
				input.close();
				true;
			}
			else if (mode == "writable")
			{
				var output = SysFile.append(path, false);
				output.close();
				true;
			}
			else false;
		}
		catch (_:Dynamic) false;
	}

	@:noCompletion private static inline function __flightBytes(data:FlightUInt8Array):Bytes
	{
		var bytes = Bytes.alloc(data.length);
		for (index in 0...data.length) bytes.set(index, data[index]);
		return bytes;
	}

	@:noCompletion private static inline function __flightDone(value:Dynamic):FlightPromise<Dynamic>
	{
		return FlightPromise.resolve(value);
	}

	@:noCompletion private static function __removeSystemTree(path:String):Void
	{
		for (name in SysFileSystem.readDirectory(path))
		{
			var child = Path.join([path, name]);
			if (SysFileSystem.isDirectory(child)) __removeSystemTree(child); else SysFileSystem.deleteFile(child);
		}
		SysFileSystem.deleteDirectory(path);
	}

	@:noCompletion private static function __systemDirectoryEntries(path:String):Array<Dynamic>
	{
		return [for (name in SysFileSystem.readDirectory(path))
		{
			var child = Path.join([path, name]);
			{name: name, path: child, isDirectory: SysFileSystem.isDirectory(child)};
		}];
	}

	@:noCompletion private static function __getFlightHost():FlightHost
	{
		if (__flightHost != null) return __flightHost;
		#if clay
		__flightHost = FlightHostClay.createClayHost();
		#elseif lime
		if (LimeApplication.current != null) __flightHost = FlightHostLime.createLimeHost(LimeApplication.current);
		#end
		return __flightHost;
	}

	@:noCompletion private static function __openDialogHandles(result:Dynamic):Array<FlightFileDialogHandle>
	{
		if (result == null) return [];
		if (Std.isOfType(result, Array)) return cast result;
		var handles:Array<FlightFileDialogHandle> = cast Reflect.field(result, "handles");
		return handles == null ? [] : handles;
	}

	@:noCompletion private static function __resolveFlight<T>(promise:Dynamic, fallback:T):T
	{
		var settled = false;
		var result = fallback;
		var failure:Dynamic = null;
		promise.then(function(value:T):T
		{
			settled = true;
			result = value;
			return value;
		}, function(error:Dynamic):T
		{
			settled = true;
			failure = error;
			return fallback;
		});
		if (failure != null) throw failure;
		if (!settled) throw new IllegalOperationError("The Flight filesystem backend cannot satisfy this synchronous operation.");
		return result;
	}

	@:noCompletion private function __runAsync(operation:Void->Void):Void
	{
		#if lime
		__fileWorker = new BackgroundWorker();
		__fileWorker.onError.add(function(e:Dynamic):Void
		{
			__fileWorker = null;
			throw e;
		});
		__fileWorker.onComplete.add(function(event:Event):Void
		{
			__fileWorker = null;
			dispatchEvent(event);
		});
		__fileWorker.doWork.add(function(m:Dynamic)
		{
			try
			{
				operation();
			}
			catch (e:Dynamic)
			{
				var ioErrorEvent = __createIoErrorEvent(e);
				if (ioErrorEvent != null) __fileWorker.sendComplete(ioErrorEvent);
				else __fileWorker.sendError(e);
				return;
			}
			__fileWorker.sendComplete(new Event(Event.COMPLETE));
		});
		__fileWorker.run();
		#else
		var generation = ++__fileOperationGeneration;
		try
		{
			operation();
			if (generation == __fileOperationGeneration) dispatchEvent(new Event(Event.COMPLETE));
		}
		catch (error:Dynamic)
		{
			if (generation == __fileOperationGeneration) __dispatchFileIOError(error);
		}
		#end
	}

	@:noCompletion private static function __saveDialogHandle(result:Dynamic):FlightFileDialogHandle
	{
		if (result == null) return null;
		if (Reflect.hasField(result, "kind")) return cast result;
		return cast Reflect.field(result, "handle");
	}

	@:noCompletion private static function __toFlightFilters(filters:Array<FileFilter>):Array<FlightFileDialogFilter>
	{
		if (filters == null) return null;
		var result:Array<FlightFileDialogFilter> = [];
		for (filter in filters)
		{
			if (filter == null) continue;
			var extensions:Array<String> = [];
			if (filter.extension != null) for (extension in filter.extension.split(";"))
			{
				extension = StringTools.trim(extension);
				if (extension == "*" || extension == "*.*") extensions.push("*");
				else
				{
					if (StringTools.startsWith(extension, "*.")) extension = extension.substr(2);
					else if (StringTools.startsWith(extension, ".")) extension = extension.substr(1);
					if (extension != "") extensions.push(extension);
				}
			}
			var accept:Dynamic = {};
			Reflect.setField(accept, "", extensions);
			var item:Dynamic = {name: filter.description == null ? "" : filter.description, accept: accept};
			// The maintained native Flight host consumes this compatibility field;
			// the public Dialog contract consumes accept above.
			Reflect.setField(item, "extensions", extensions);
			result.push(cast item);
		}
		return result;
	}

	@:noCompletion private function __canonicalize(cpath:String, seg:String):String
	{
		var items:Array<String> = null;
		try
		{
			var entries = __resolveFlight(FlightFileSystem.readDirectory(__getFlightFileSystemHost(), Path.directory(cpath)), []);
			items = [for (entry in entries) entry.name];
		}
		catch (e:Dynamic) {}
		if (items == null)
		{
			// if the directory doesn't exist, or if something goes wrong, like
			// we don't have permission to read it, use the original name.
			return seg;
		}

		// we're using toLowerCase() for comparisons only.
		// we'll return the original casing if the file doesn't exist.
		var segLower = seg.toLowerCase();
		for (item in items)
		{
			#if (windows || mac || ios)
			if (item.toLowerCase() == segLower)
			{
				// generally, file systems on Windows and macOS are not
				// case-sensitive, but file systems on Linux are.
				// technically, Windows and macOS file systems (or, sometimes,
				// individual directories) can be configured to be
				// case-sensitive, but that's rare.
				// ideally, we should detect case-sensitivity, instead of
				// assuming, but this is good enough for now.
				return item;
			}
			#else
			if (item == seg)
			{
				// found an exact match for case-sensitive file systems
				return item;
			}
			#end
		}

		return seg;
	}

	@:noCompletion private function __dispatchCancel():Void
	{
		__dialogPending = false;
		this.dispatchEvent(new Event(Event.CANCEL));
	}

	@:noCompletion private function __dispatchSelect(?filepath:String):Void
	{
		__dialogPending = false;
		nativePath = filepath;

		this.dispatchEvent(new Event(Event.SELECT));
	}

	@:noCompletion private function __dispatchSelectMultiple(?filepaths:Array<String>):Void
	{
		__dialogPending = false;
		var files:Array<File> = [];

		for (filepath in filepaths)
		{
			files.push(new File(filepath));
		}

		this.dispatchEvent(new FileListEvent(FileListEvent.SELECT_MULTIPLE, files));
	}

	@:noCompletion private function __dispatchDialogError(error:Dynamic):Void
	{
		__dialogPending = false;
		__dispatchFileIOError(error);
	}

	@:noCompletion private function __dispatchFileIOError(error:Dynamic):Void
	{
		dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, Std.string(error)));
	}

	@:noCompletion private function __createIoErrorEvent(e:Dynamic):IOErrorEvent
	{
		if (hasEventListener(IOErrorEvent.IO_ERROR))
		{
			if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (e, Error))
			{
				var error = (e : Error);
				return new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, error.message, error.errorID);
			}
			else
			{
				return new IOErrorEvent(IOErrorEvent.IO_ERROR);
			}
		}
		return null;
	}

	@:noCompletion private function __formatPath(path:String):String
	{
		var dirs:Array<String> = [];
		var lastBreak:Int = 0;

		for (i in 0...path.length)
		{
			var char:String = path.charAt(i);

			if (path.charAt(i) == "\\" || char == "/")
			{
				if (lastBreak != i)
				{
					dirs.push(path.substring(lastBreak, i));
				}
				lastBreak = i + 1;
			}
		}

		if (path.length != lastBreak)
		{
			dirs.push(path.substring(lastBreak, path.length));
		}

		path = "";

		for (dir in dirs)
		{
			path += '$dir$separator';
		}

		return Path.removeTrailingSlashes(path);
	}

	#if windows
	@:noCompletion private function __winGetHiddenAttr():Bool
	{
		var process:Process = new Process('attrib "$nativePath"');
		var result:String = process.stdout.readLine();
		process.close();
		return result.split(nativePath)[0].indexOf(" H ") > -1;
	}
	#end

	@:noCompletion private static function __getTempPath(dir:Bool):String
	{
		var path = "";

		if (#if lime System.platformName == "Windows" #else Sys.systemName() == "Windows" #end)
		{
			path = Sys.getEnv("TEMP");
		}
		else
		{
			path = Sys.getEnv("TMPDIR");

			if (path == null)
			{
				path = "/tmp";
			}
		}

		var tempPath = "";

		while (new File(tempPath = FlightFileSystem.joinFilePath(path, "ofl" + Math.round(0xFFFFFF * Math.random()))).exists)
		{
			// repeat
		}

		if (dir)
		{
			return Path.addTrailingSlash(tempPath);
		}

		return tempPath + ".tmp";
	}

	#if windows
	@:noCompletion private function __replaceWindowsEnvVars(path:String):String
	{
		// replace all environment variables wrapped in %VAR_NAME%
		var pattern:EReg = ~/%([^%]+)%/g;
		return pattern.map(path, function(p)
		{
			var envVar = p.matched(1);
			var value = Sys.getEnv(envVar);
			return (value != null) ? value : p.matched(0);
		});
	}
	#end

	@:noCompletion private function __updateFileStats(?path:String):Void
	{
		if (path == null)
		{
			path = __path;
		}

		var fileInfo = __flightStat(path);
		if (fileInfo != null)
		{
			creationDate = Date.fromTime(fileInfo.createdTime);
			modificationDate = Date.fromTime(fileInfo.modifiedTime);
			size = fileInfo.size;
		}
		else
		{
			creationDate = null;
			modificationDate = null;
			size = 0;
		}
		var flightExtension = FlightFileSystem.getFileExtensionName(path.split("\\").join("/"));
		var normalizedExtension = StringTools.startsWith(flightExtension, ".") ? flightExtension.substr(1) : flightExtension;
		extension = normalizedExtension;
		type = normalizedExtension;
		name = FlightFileSystem.getFileBaseName(path.split("\\").join("/"));
		__fileStatsDirty = false;
	}

	@:noCompletion private static function get_applicationDirectory():File
	{
		var host = __getFlightHost();
		var appHost:FlightAppPathHost = cast host;
		var path = host == null ? "" : FlightApp.getAppPath(appHost);
		#if lime
		if (path == null || path == "") path = System.applicationDirectory;
		#else
		if (path == null || path == "") path = Sys.programPath();
		#end
		var result = new File(Path.removeTrailingSlashes(path));
		result.__urlScheme = "app";
		return result;
	}

	@:noCompletion private static function get_applicationStorageDirectory():File
	{
		var host = __getFlightHost();
		var appHost:FlightAppPathHost = cast host;
		var path = host == null ? "" : FlightApp.getAppDirectoryPath(appHost, "userData");
		#if lime
		if (path == null || path == "") path = System.applicationStorageDirectory;
		#else
		if (path == null || path == "") path = Sys.getCwd();
		#end
		var result = new File(Path.removeTrailingSlashes(path));
		result.__urlScheme = "app-storage";
		return result;
	}

	@:noCompletion private static function get_documentsDirectory():File
	{
		var path = FlightFileSystem.getFileSystemPath(__getFlightFileSystemHost(), "documents");
		#if lime
		if (path == null || path == "") path = System.documentsDirectory;
		#else
		if (path == null || path == "") path = Sys.getEnv("HOME") != null ? Sys.getEnv("HOME") : Sys.getCwd();
		#end
		return new File(Path.removeTrailingSlashes(path));
	}

	@:noCompletion private static function get_desktopDirectory():File
	{
		var path = FlightFileSystem.getFileSystemPath(__getFlightFileSystemHost(), "desktop");
		#if lime
		if (path == null || path == "") path = System.desktopDirectory;
		#else
		if (path == null || path == "") path = Sys.getEnv("HOME") != null ? Sys.getEnv("HOME") : Sys.getCwd();
		#end
		return new File(Path.removeTrailingSlashes(path));
	}

	@:noCompletion private static function get_userDirectory():File
	{
		var path = FlightFileSystem.getFileSystemPath(__getFlightFileSystemHost(), "home");
		#if lime
		if (path == null || path == "") path = System.userDirectory;
		#else
		if (path == null || path == "") path = Sys.getEnv("HOME") != null ? Sys.getEnv("HOME") : Sys.getCwd();
		#end
		return new File(Path.removeTrailingSlashes(path));
	}

	@:noCompletion private static function get_workingDirectory():File
	{
		return new File(Path.removeTrailingSlashes(Sys.getCwd()));
	}

	@:noCompletion override private function get_creationDate():Date
	{
		if (__fileStatsDirty) __updateFileStats();
		return creationDate;
	}

	@:noCompletion private static inline function get_lineEnding():String
	{
		#if windows
		return "\r\n";
		#else
		return "\n";
		#end
	}

	@:noCompletion override private function get_modificationDate():Date
	{
		if (__fileStatsDirty) __updateFileStats();
		return modificationDate;
	}

	@:noCompletion override private function get_name():String
	{
		if (__fileStatsDirty) __updateFileStats();
		return name;
	}

	@:noCompletion override private function get_extension():String
	{
		var fileName = get_name();
		if (fileName == null) return null;
		var index = fileName.lastIndexOf(".");
		return index > -1 ? fileName.substr(index + 1) : null;
	}

	@:noCompletion private inline static function get_separator():String
	{
		#if windows
		return "\\";
		#else
		return "/";
		#end
	}

	@:noCompletion override private function get_size():Float
	{
		if (__fileStatsDirty) __updateFileStats();
		return size;
	}

	@:noCompletion override private function get_type():String
	{
		if (__fileStatsDirty) __updateFileStats();
		return type;
	}

	@:noCompletion private function get_nativePath():String
	{
		return __path;
	}

	@:noCompletion private function set_nativePath(path:String):String
	{
		if (path != null)
		{
			__urlScheme = "file";
			if (StringTools.startsWith(path, "app:"))
			{
				__urlScheme = "app";
				path = StringTools.replace(path, "app:", File.applicationDirectory.nativePath);
			}
			else if (StringTools.startsWith(path, "app-storage:"))
			{
				__urlScheme = "app-storage";
				path = StringTools.replace(path, "app-storage:", File.applicationStorageDirectory.nativePath);
			}

			#if windows
			if (path.indexOf("%") > -1)
			{
				path = __replaceWindowsEnvVars(path);
			}
			#end

			if (path.charAt(path.length - 1) == ":" /*|| FileSystem.isDirectory(path)*/)
			{
				path = Path.addTrailingSlash(path);
			}

			if (#if !windows !StringTools.startsWith(path, "/") && #end Path.directory(path).length == 0)
			{
				throw new ArgumentError("One of the parameters is invalid.");
			}

			__updateFileStats(path);

			if (path.indexOf(#if windows "/" #else "\\" #end) > 0)
			{
				path = __formatPath(path);
			}
		}

		return __path = path;
	}

	@:noCompletion private function get_url():String
	{
		var path = nativePath;
		if (__urlScheme == "app" || __urlScheme == "app-storage")
		{
			var root = __urlScheme == "app" ? File.applicationDirectory.nativePath : File.applicationStorageDirectory.nativePath;
			if (StringTools.startsWith(path, root)) path = path.substr(root.length);
			if (!StringTools.startsWith(path, "/") && !StringTools.startsWith(path, "\\")) path = "/" + path;
		}

		#if windows
		// convert to forward slashes for URLs
		path = path.split("\\").join("/");
		if (!StringTools.startsWith(path, "/"))
		{
			path = "/" + path;
		}
		#end

		var encoded = StringTools.urlEncode(path);
		// keep path separators and drive colon unescaped
		encoded = StringTools.replace(encoded, "%2F", "/");
		encoded = StringTools.replace(encoded, "%3A", ":");
		return __urlScheme == "file" ? "file://" + encoded : __urlScheme + ":" + encoded;
	}

	@:noCompletion private function set_url(value:String):String
	{
		if (value == null)
		{
			throw new ArgumentError("One of the parameters is invalid.");
		}

		var resolveFromDirectory:File = null;
		var scheme = "file";
		var schemeRegex = ~/^(.+?):/;
		if (schemeRegex.match(value))
		{
			scheme = schemeRegex.matched(1);
			if (scheme == "app")
			{
				resolveFromDirectory = File.applicationDirectory;
			}
			else if (scheme == "app-storage")
			{
				resolveFromDirectory = File.applicationStorageDirectory;
			}
			else if (scheme != "file")
			{
				throw new ArgumentError("One of the parameters is invalid.");
			}
		}

		value = ~/^\/{2,}/.replace(value.substr(5), "/");
		value = StringTools.urlDecode(value);

		if (resolveFromDirectory != null)
		{
			nativePath = resolveFromDirectory.resolvePath(value).nativePath;
		}
		else
		{
			nativePath = value;
		}
		__urlScheme = scheme;

		return url;
	}

	@:noCompletion private function get_exists():Bool
	{
		return SysFileSystem.exists(__path);
	}

	@:noCompletion private function get_isHidden():Bool
	{
		#if windows
		return __winGetHiddenAttr();
		#else
		return name.charAt(0) == ".";
		#end
	}

	@:noCompletion private function get_isDirectory():Bool
	{
		return SysFileSystem.exists(__path) && SysFileSystem.isDirectory(__path);
	}

	@:noCompletion private function get_parent():File
	{
		var path = Path.removeTrailingSlashes(__path).split("\\").join("/");
		if (path == "" || path == "/" || ~/^[A-Za-z]:$/.match(path)) return null;
		var parentPath = FlightFileSystem.getFileDirectoryName(path);
		if (StringTools.startsWith(path, "/")) parentPath = "/" + parentPath;
		if (parentPath == "" || parentPath == path) return null;
		var result = new File(parentPath);
		result.__urlScheme = __urlScheme;
		result.__readOnly = __readOnly;
		return result;
	}
}
#else
#if air
typedef File = flash.filesystem.File;
#end
#end
