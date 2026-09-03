package harness.scenarios;

import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.ObjectEncoding;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

class FileStreamScenario {
	public static function run():Dynamic {
		var root = File.createTempDirectory();
		root.createDirectory();
		var file = root.resolvePath("stream.bin");
		var stream = new FileStream();
		var result:Dynamic = {
			defaults: {
				asyncWriteMethodsPresent: stream.openAsync != null && stream.writeBytes != null && stream.close != null,
				position: stream.position,
				readAheadInfinite: !Math.isFinite(stream.readAhead),
				isWriting: stream.isWriting,
				objectEncoding: stream.objectEncoding
			}
		};

		try {
			stream.open(file, FileMode.WRITE);
			var writeStart = {
				endian: stream.endian,
				bytesAvailable: stream.bytesAvailable,
				position: stream.position
			};
			stream.writeBoolean(true);
			stream.writeByte(0xFE);
			stream.writeShort(0x1234);
			stream.writeInt(0x01020304);
			stream.writeUTF("hi");
			stream.writeUTFBytes("é");
			result.write = {
				start: writeStart,
				position: stream.position,
				bytesAvailable: stream.bytesAvailable
			};
			stream.close();
			result.positionAfterClose = stream.position;

			stream.open(file, FileMode.READ);
			var availableAtStart = stream.bytesAvailable;
			result.read = {
				availableAtStart: availableAtStart,
				boolean: stream.readBoolean(),
				byte: stream.readByte(),
				short: stream.readUnsignedShort(),
				intValue: stream.readInt(),
				utf: stream.readUTF(),
				utfBytes: stream.readUTFBytes(2),
				position: stream.position,
				availableAtEnd: stream.bytesAvailable
			};
			stream.close();

			stream.open(file, FileMode.UPDATE);
			var updateReadRejected = false;
			try stream.readUnsignedByte() catch (_:Dynamic) updateReadRejected = true;
			stream.position = 1;
			stream.writeByte(0x7F);
			var updatePosition = stream.position;
			stream.close();

			stream.open(file, FileMode.APPEND);
			stream.writeByte(9);
			stream.close();
			var sizeAfterAppend = new File(file.nativePath).size;

			stream.open(file, FileMode.UPDATE);
			stream.position = 4;
			stream.truncate();
			var truncatePosition = stream.position;
			stream.close();

			result.modes = {
				updateReadRejected: updateReadRejected,
				updatePosition: updatePosition,
				sizeAfterAppend: sizeAfterAppend,
				truncatePosition: truncatePosition,
				finalSize: new File(file.nativePath).size
			};

			var little = root.resolvePath("little.bin");
			stream.open(little, FileMode.WRITE);
			stream.endian = Endian.LITTLE_ENDIAN;
			stream.writeShort(0x1234);
			stream.close();
			stream.open(little, FileMode.READ);
			stream.endian = Endian.LITTLE_ENDIAN;
			result.littleEndianShort = stream.readUnsignedShort();
			stream.close();

			var bulk = root.resolvePath("bulk.bin");
			var sourceBytes = new ByteArray();
			sourceBytes.writeByte(10);
			sourceBytes.writeByte(20);
			sourceBytes.writeByte(30);
			sourceBytes.writeByte(40);
			stream.open(bulk, FileMode.WRITE);
			stream.writeBytes(sourceBytes, 1, 2);
			stream.close();
			var copiedBytes = new ByteArray();
			stream.open(bulk, FileMode.READ);
			stream.readBytes(copiedBytes, 0, 2);
			var bulkPosition = stream.position;
			stream.close();
			result.bulkBytes = {
				length: copiedBytes.length,
				streamPosition: bulkPosition
			};

			var multiByteFile = root.resolvePath("multibyte.bin");
			stream.open(multiByteFile, FileMode.WRITE);
			stream.writeMultiByte("é", "iso-8859-1");
			stream.close();
			stream.open(multiByteFile, FileMode.READ);
			var multiByteValue = stream.readMultiByte(2, "shift-jis");
			stream.close();
			result.multiByte = {
				encodedLength: File.getFileBytes(multiByteFile.nativePath).length,
				ignoredCharacterSetsRoundTripUTF8: multiByteValue == "é"
			};

			var asyncFile = root.resolvePath("async-read.bin");
			var asyncBytes = new ByteArray();
			asyncBytes.writeUTFBytes("ABCDE");
			File.saveBytes(asyncFile.nativePath, asyncBytes);
			var asyncStream = new FileStream();
			var asyncProgress:Array<Dynamic> = [];
			var asyncComplete = false;
			var asyncErrors = 0;
			var asyncCloseEvents = 0;
			asyncStream.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):Void {
				asyncProgress.push({bytesLoaded: event.bytesLoaded, bytesTotal: event.bytesTotal, bytesAvailable: asyncStream.bytesAvailable});
			});
			asyncStream.addEventListener(Event.COMPLETE, function(_:Event):Void asyncComplete = true);
			asyncStream.addEventListener(IOErrorEvent.IO_ERROR, function(_:IOErrorEvent):Void asyncErrors++);
			asyncStream.addEventListener(Event.CLOSE, function(_:Event):Void asyncCloseEvents++);
			asyncStream.openAsync(new File(asyncFile.nativePath), FileMode.READ);
			var asyncContentsLength = asyncComplete ? asyncStream.readUTFBytes(5).length : -1;
			asyncStream.close();
			result.asyncRead = {
				closeEvents: asyncCloseEvents,
				complete: asyncComplete,
				contentsLength: asyncContentsLength,
				errors: asyncErrors,
				progress: asyncProgress
			};

			var objectFile = root.resolvePath("object.bin");
			stream.open(objectFile, FileMode.WRITE);
			stream.objectEncoding = ObjectEncoding.HXSF;
			stream.writeObject({answer: 42, label: "ok"});
			stream.close();
			stream.open(objectFile, FileMode.READ);
			stream.objectEncoding = ObjectEncoding.HXSF;
			var object:Dynamic = stream.readObject();
			stream.close();
			result.objectRoundTrip = {answer: object.answer, label: object.label};

			var missingReadRejected = false;
			try stream.open(root.resolvePath("missing.bin"), FileMode.READ) catch (_:Dynamic) missingReadRejected = true;
			result.missingReadRejected = missingReadRejected;
		} catch (error:Dynamic) {
			result.error = Std.string(error);
			try stream.close() catch (_:Dynamic) {}
		}

		if (root.exists) root.deleteDirectory(true);
		result.cleaned = !root.exists;
		return result;
	}
}
