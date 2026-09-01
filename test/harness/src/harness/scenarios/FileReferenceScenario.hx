package harness.scenarios;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;

class FileReferenceScenario {
	public static function run():Dynamic {
		var filter = new FileFilter("Images", "*.jpg;*.png", "JPEG;PNGf");
		var defaultFilter = new FileFilter(null, null);
		var reference = new FileReference();
		var events:Array<String> = [];
		var eventTypes:Array<Dynamic> = [Event.CANCEL, Event.COMPLETE, IOErrorEvent.IO_ERROR, Event.OPEN, ProgressEvent.PROGRESS, Event.SELECT];
		for (type in eventTypes) {
			reference.addEventListener(type, function(event:Event):Void events.push(event.type));
		}

		var initial = metadata(reference);
		var browseWithoutFilter = reference.browse();
		var browseWithFilter = reference.browse([filter]);
		reference.cancel();
		reference.load();
		reference.save(null);
		reference.save("flight", "flight.txt");

		filter.description = "Pictures";
		filter.extension = "*.gif";
		filter.macType = null;

		return {
			browseWithFilter: browseWithFilter,
			browseWithoutFilter: browseWithoutFilter,
			defaultFilter: {
				description: defaultFilter.description,
				extension: defaultFilter.extension,
				macType: defaultFilter.macType
			},
			events: events,
			filter: {
				description: filter.description,
				extension: filter.extension,
				macType: filter.macType
			},
			initial: initial,
			referenceAfterOperations: metadata(reference)
		};
	}

	private static function metadata(reference:FileReference):Dynamic {
		return {
			creationDateIsNull: reference.creationDate == null,
			creatorIsNull: reference.creator == null,
			dataIsNull: reference.data == null,
			extension: reference.extension,
			modificationDateIsNull: reference.modificationDate == null,
			name: reference.name,
			size: reference.size,
			type: reference.type
		};
	}
}
