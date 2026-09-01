package harness.scenarios;

import openfl.net.ObjectEncoding;
import openfl.utils.ByteArray;
import openfl.utils.CompressionAlgorithm;
import openfl.utils.Endian;

class ByteArrayScenario {
	public static function run():Dynamic {
		return {
			construct: testConstruct(),
			writeAndRead: testWriteAndRead(),
			endianness: testEndianness(),
			position: testPosition(),
			bytesAvailable: testBytesAvailable(),
			clear: testClear(),
			writeReadUTF: testWriteReadUTF(),
			writeReadBytes: testWriteReadBytes(),
			writeReadBoolean: testWriteReadBoolean(),
			writeReadShort: testWriteReadShort(),
			writeReadInt: testWriteReadInt(),
			writeReadDouble: testWriteReadDouble(),
			writeReadFloat: testWriteReadFloat(),
			signedByte: testSignedByte(),
			signedShort: testSignedShort(),
			zeroMemory: testZeroMemory(),
			emptyArray: testEmptyArray(),
			utfBytes: testUTFBytes(),
			objectEncodingWrite: testObjectEncodingWrite(),
			zlibCompression: testCompression(CompressionAlgorithm.ZLIB),
			deflateCompression: testCompression(CompressionAlgorithm.DEFLATE)
		};
	}

	private static function testConstruct():Dynamic {
		var ba = new ByteArray();

		return {
			initialLength: ba.length,
			initialPosition: ba.position
		};
	}

	private static function testWriteAndRead():Dynamic {
		var ba = new ByteArray();
		ba.writeByte(42);
		ba.writeByte(255);
		ba.writeByte(0);
		var lengthAfterWrite = ba.length;
		var positionAfterWrite = ba.position;

		ba.position = 0;
		var first = ba.readByte();
		var second = ba.readUnsignedByte();

		ba.position = 0;
		var firstUnsigned = ba.readUnsignedByte();

		return {
			lengthAfterWrite: lengthAfterWrite,
			positionAfterWrite: positionAfterWrite,
			firstByte: first,
			secondUnsigned: second,
			firstUnsigned: firstUnsigned
		};
	}

	private static function testEndianness():Dynamic {
		var ba = new ByteArray();
		ba.endian = BIG_ENDIAN;
		ba.writeInt(0x01020304);
		ba.position = 0;
		var bigEndianFirst = ba.readUnsignedByte();

		ba.clear();
		ba.endian = LITTLE_ENDIAN;
		ba.writeInt(0x01020304);
		ba.position = 0;
		var littleEndianFirst = ba.readUnsignedByte();

		return {
			bigEndianFirstByte: bigEndianFirst,
			littleEndianFirstByte: littleEndianFirst
		};
	}

	private static function testPosition():Dynamic {
		var ba = new ByteArray();
		ba.writeByte(1);
		ba.writeByte(2);
		ba.writeByte(3);
		ba.writeByte(4);

		ba.position = 2;
		var atPos2 = ba.readByte();

		ba.position = 0;
		var atPos0 = ba.readByte();
		var posAfterRead = ba.position;

		return {
			atPosition2: atPos2,
			atPosition0: atPos0,
			posAfterRead: posAfterRead
		};
	}

	private static function testBytesAvailable():Dynamic {
		var ba = new ByteArray();
		ba.writeByte(1);
		ba.writeByte(2);
		ba.writeByte(3);

		var availableAtEnd = ba.bytesAvailable;
		ba.position = 0;
		var availableAtStart = ba.bytesAvailable;
		ba.readByte();
		var availableAfterOne = ba.bytesAvailable;

		return {
			atEnd: availableAtEnd,
			atStart: availableAtStart,
			afterOneRead: availableAfterOne
		};
	}

	private static function testClear():Dynamic {
		var ba = new ByteArray();
		ba.writeByte(1);
		ba.writeByte(2);
		ba.clear();

		return {
			lengthAfterClear: ba.length,
			positionAfterClear: ba.position
		};
	}

	private static function testWriteReadUTF():Dynamic {
		var ba = new ByteArray();
		ba.writeUTF("hello");
		var lengthAfter = ba.length;
		ba.position = 0;
		var readBack = ba.readUTF();

		return {
			lengthAfterWrite: lengthAfter,
			readBack: readBack
		};
	}

	private static function testWriteReadBytes():Dynamic {
		var src = new ByteArray();
		src.writeByte(10);
		src.writeByte(20);
		src.writeByte(30);

		var dst = new ByteArray();
		src.position = 0;
		src.readBytes(dst, 0, 3);

		dst.position = 0;
		var first = dst.readByte();
		var second = dst.readByte();
		var third = dst.readByte();

		return {
			dstLength: dst.length,
			first: first,
			second: second,
			third: third
		};
	}

	private static function testWriteReadBoolean():Dynamic {
		var ba = new ByteArray();
		ba.writeBoolean(true);
		ba.writeBoolean(false);
		ba.writeBoolean(true);
		ba.position = 0;
		var first = ba.readBoolean();
		var second = ba.readBoolean();
		var third = ba.readBoolean();
		return {
			first: first,
			second: second,
			third: third,
			length: ba.length
		};
	}

	private static function testWriteReadShort():Dynamic {
		var ba = new ByteArray();
		ba.endian = BIG_ENDIAN;
		ba.writeShort(1000);
		ba.writeShort(-1000);
		ba.writeShort(32767);
		ba.position = 0;
		var a = ba.readShort();
		var b = ba.readShort();
		var c = ba.readShort();
		return {
			positive: a,
			negative: b,
			max: c,
			length: ba.length
		};
	}

	private static function testWriteReadInt():Dynamic {
		var ba = new ByteArray();
		ba.endian = BIG_ENDIAN;
		ba.writeInt(123456789);
		ba.writeInt(-123456789);
		ba.writeInt(0);
		ba.position = 0;
		var a = ba.readInt();
		var b = ba.readInt();
		var c = ba.readInt();
		return {
			positive: a,
			negative: b,
			zero: c,
			length: ba.length
		};
	}

	private static function testWriteReadDouble():Dynamic {
		var ba = new ByteArray();
		ba.writeDouble(3.141592653589793);
		ba.writeDouble(-1.0e10);
		ba.writeDouble(0.0);
		ba.position = 0;
		var pi = ba.readDouble();
		var neg = ba.readDouble();
		var zero = ba.readDouble();
		return {
			pi: pi,
			negative: neg,
			zero: zero,
			length: ba.length
		};
	}

	private static function testWriteReadFloat():Dynamic {
		var ba = new ByteArray();
		ba.writeFloat(3.14);
		ba.writeFloat(-1.0);
		ba.writeFloat(0.0);
		ba.position = 0;
		var a = ba.readFloat();
		var b = ba.readFloat();
		var c = ba.readFloat();
		var aDiff = a - 3.14;
		var withinTolerance = aDiff > -0.001 && aDiff < 0.001;
		return {
			approxPi: withinTolerance,
			negative: b,
			zero: c,
			length: ba.length
		};
	}

	private static function testSignedByte():Dynamic {
		var ba = new ByteArray();
		ba.writeByte(127);
		ba.writeByte(128);
		ba.writeByte(255);
		ba.writeByte(0);
		ba.position = 0;
		var a = ba.readByte();
		var b = ba.readByte();
		var c = ba.readByte();
		var d = ba.readByte();
		return {
			max: a,
			overMax: b,
			allBits: c,
			zero: d
		};
	}

	private static function testSignedShort():Dynamic {
		var ba = new ByteArray();
		ba.endian = LITTLE_ENDIAN;
		ba.writeByte(0x00);
		ba.writeByte(0x80);
		ba.position = 0;
		var val = ba.readShort();
		return {
			negativeShort: val
		};
	}

	private static function testZeroMemory():Dynamic {
		var ba = new ByteArray();
		ba.length = 10;
		ba.position = 0;
		var allZero = true;
		var i = 0;
		while (i < 10) {
			if (ba.readByte() != 0) allZero = false;
			i++;
		}
		return {
			allZero: allZero,
			length: ba.length
		};
	}

	private static function testEmptyArray():Dynamic {
		var ba = new ByteArray();
		var threw = false;
		try {
			ba.readByte();
		} catch (e:Dynamic) {
			threw = true;
		}
		return {
			throwsOnEmptyRead: threw
		};
	}

	private static function testUTFBytes():Dynamic {
		var written = new ByteArray();
		written.writeUTFBytes("flight");

		var readable = new ByteArray();
		for (value in [102, 108, 105, 103, 104, 116]) readable.writeByte(value);
		readable.position = 0;
		var first = readable.readUTFBytes(3);
		var remaining = readable.readUTFBytes(readable.bytesAvailable);

		return {
			lengthAfterWrite: written.length,
			positionAfterWrite: written.position,
			first: first,
			remaining: remaining,
			positionAfterRead: readable.position
		};
	}

	private static function testObjectEncodingWrite():Dynamic {
		var bytes = new ByteArray();
		bytes.objectEncoding = ObjectEncoding.HXSF;
		bytes.writeObject({name: "flight", count: 3, enabled: true, values: [1, 2, 3]});
		var lengthAfterWrite = bytes.length;
		var positionAfterWrite = bytes.position;

		return {
			encoding: bytes.objectEncoding,
			lengthAfterWrite: lengthAfterWrite,
			positionAfterWrite: positionAfterWrite
		};
	}

	private static function testCompression(algorithm:CompressionAlgorithm):Dynamic {
		var bytes = new ByteArray();
		for (index in 0...64) bytes.writeByte((index % 4) + 1);

		bytes.compress(algorithm);
		var compressedLength = bytes.length;
		var compressedPosition = bytes.position;
		bytes.uncompress(algorithm);
		var positionAfterUncompress = bytes.position;

		var roundTripMatches = bytes.length == 64;
		for (index in 0...64) {
			if (bytes.readUnsignedByte() != (index % 4) + 1) roundTripMatches = false;
		}

		return {
			positionAtCompressedEnd: compressedPosition == compressedLength,
			positionAfterUncompress: positionAfterUncompress,
			roundTripMatches: roundTripMatches
		};
	}
}
