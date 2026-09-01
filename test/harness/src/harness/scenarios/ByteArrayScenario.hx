package harness.scenarios;

import openfl.utils.ByteArray;
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
			writeReadBytes: testWriteReadBytes()
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
}
