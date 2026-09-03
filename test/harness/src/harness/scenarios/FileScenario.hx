package harness.scenarios;

import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

class FileScenario {
	public static function run():Dynamic {
		var root = File.createTempDirectory();
		var result:Dynamic = {
			tempExistsInitially: root.exists,
			operationsCompleted: false,
			cleaned: false
		};

		try {
			root.createDirectory();
			var appChild = new File("app:/assets/example.txt");
			var storageChild = new File("app-storage:/state/example.txt");
			var empty = new File();
			var unresolvedParent = root.resolvePath("nested/../literal.txt");
			var cancelWithoutWorkerThrows = false;
			try {
				root.resolvePath("cancel.txt").cancel();
			} catch (_:Dynamic) {
				cancelWithoutWorkerThrows = true;
			}
			result.pathContracts = {
				appPrefixResolved: appChild.nativePath == File.applicationDirectory.nativePath + File.separator + "assets" + File.separator + "example.txt",
				appStoragePrefixResolved: storageChild.nativePath == File.applicationStorageDirectory.nativePath + File.separator + "state" + File.separator + "example.txt",
				asyncMethodsPresent: root.copyToAsync != null && root.deleteDirectoryAsync != null && root.deleteFileAsync != null
					&& root.getDirectoryListingAsync != null && root.moveToAsync != null,
				browseMethodsPresent: root.browse != null && root.browseForDirectory != null && root.browseForOpen != null
					&& root.browseForOpenMultiple != null && root.browseForSave != null,
				cancelWithoutWorkerThrows: cancelWithoutWorkerThrows,
				emptyFileIsFileReference: Std.isOfType(empty, FileReference),
				emptyFileNameIsNull: empty.name == null,
				fileModes: [Std.string(FileMode.APPEND), Std.string(FileMode.READ), Std.string(FileMode.UPDATE), Std.string(FileMode.WRITE)],
				lineEndingMatchesPlatform: File.lineEnding == (#if windows "\r\n" #else "\n" #end),
				openWithDefaultApplicationPresent: root.openWithDefaultApplication != null,
				resolvePathRetainsDotDot: unresolvedParent.nativePath.indexOf("..") != -1,
				separatorMatchesPlatform: File.separator == (#if windows "\\" #else "/" #end),
				workingDirectoryMatchesCwd: File.workingDirectory.nativePath == haxe.io.Path.removeTrailingSlashes(Sys.getCwd())
			};
			var nested = root.resolvePath("nested");
			nested.createDirectory();
			var canonical = root.resolvePath("nested/../nested");
			canonical.canonicalize();
			var cloned = nested.clone();
			result.pathOperations = {
				canonicalPathMatches: canonical.nativePath == nested.nativePath,
				cloneIsDistinct: cloned != nested,
				clonePathMatches: cloned.nativePath == nested.nativePath,
				relativeChild: root.getRelativePath(nested.resolvePath("child.txt")),
				relativeParentWithoutDotDotIsNull: nested.getRelativePath(root) == null,
				relativeParentWithDotDot: nested.getRelativePath(root, true)
			};
			var source = root.resolvePath("alpha.txt");
			File.saveText(source.nativePath, "flight");
			var bytes = new ByteArray();
			bytes.writeByte(1);
			bytes.writeByte(2);
			bytes.writeByte(255);
			var binary = nested.resolvePath("bytes.bin");
			File.saveBytes(binary.nativePath, bytes);

			result.source = {
				exists: source.exists,
				isDirectory: source.isDirectory,
				isHidden: source.isHidden,
				name: source.name,
				extension: source.extension,
				type: source.type,
				size: source.size,
				creationDateIsNull: source.creationDate == null,
				modificationDateIsNull: source.modificationDate == null,
				parentResolvesSource: source.parent.resolvePath(source.name).nativePath == source.nativePath,
				urlIsFile: StringTools.startsWith(source.url, "file://"),
				urlEndsWithName: StringTools.endsWith(source.url, "alpha.txt"),
				text: File.getFileText(source.nativePath),
				extraFlightPropertiesAbsent: !Reflect.hasField(source, "isSymbolicLink") && !Reflect.hasField(source, "spaceAvailable")
			};

			var copy = root.resolvePath("copy.txt");
			source.copyTo(copy);
			var overwriteRejected = false;
			try source.copyTo(copy) catch (_:Dynamic) overwriteRejected = true;
			var moved = root.resolvePath("moved.txt");
			copy.moveTo(moved);
			result.copyMove = {
				copyExists: copy.exists,
				copyNameAfterMove: copy.name,
				movedExists: moved.exists,
				movedText: File.getFileText(moved.nativePath),
				overwriteRejected: overwriteRejected
			};

			var listed = root.getDirectoryListing();
			var names = [for (file in listed) file.name];
			names.sort(Reflect.compare);
			var binaryRead = File.getFileBytes(binary.nativePath);
			result.listing = {
				names: names,
				binaryLength: binaryRead.length,
				nestedIsDirectory: nested.isDirectory
			};

			moved.deleteFile();
			result.deletedFileExists = moved.exists;
			result.browseReturnsFalse = root.browse() == false;
			result.operationsCompleted = true;
		} catch (error:Dynamic) {
			result.error = Std.string(error);
		}

		if (root.exists) root.deleteDirectory(true);
		result.cleaned = !root.exists;
		return result;
	}
}
