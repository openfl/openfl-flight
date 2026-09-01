package harness;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class FixtureStore {
	private static final ROOT = "test/fixtures";

	public static function read(name:String):Dynamic {
		var fixturePath = path(name);

		if (!FileSystem.exists(fixturePath)) {
			throw 'Fixture not found: $fixturePath (run capture mode first)';
		}

		return Json.parse(File.getContent(fixturePath));
	}

	public static function write(name:String, value:Dynamic):Void {
		var fixturePath = path(name);
		ensureDirectory(Path.directory(fixturePath));
		File.saveContent(fixturePath, Json.stringify(value, null, "  ") + "\n");
	}

	private static function path(name:String):String {
		return Path.join([ROOT, name + ".json"]);
	}

	private static function ensureDirectory(directory:String):Void {
		if (directory == "" || FileSystem.exists(directory)) {
			return;
		}

		ensureDirectory(Path.directory(directory));
		FileSystem.createDirectory(directory);
	}
}
