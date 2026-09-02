package harness.scenarios;

import openfl.filesystem.File;
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
			var nested = root.resolvePath("nested");
			nested.createDirectory();
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
				text: File.getFileText(source.nativePath)
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
			result.operationsCompleted = true;
		} catch (error:Dynamic) {
			result.error = Std.string(error);
		}

		if (root.exists) root.deleteDirectory(true);
		result.cleaned = !root.exists;
		return result;
	}
}
