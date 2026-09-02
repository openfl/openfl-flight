package harness.scenarios;

#if harness_compare
import flight.Signals as FlightSignals;
#end
import openfl.events.Event;
import openfl.events.GameInputEvent;
import openfl.ui.GameInput;
import openfl.ui.GameInputControl;
import openfl.ui.GameInputDevice;
import openfl.utils.ByteArray;

class GameInputScenario
{
	public static function run():Dynamic
	{
		var input = new GameInput();
		var addedCount = 0;
		var removedCount = 0;
		var addedDevices:Array<GameInputDevice> = [];
		var removedDevices:Array<GameInputDevice> = [];
		input.addEventListener(GameInputEvent.DEVICE_ADDED, function(event:GameInputEvent):Void
		{
			addedCount++;
			addedDevices.push(event.device);
		});
		input.addEventListener(GameInputEvent.DEVICE_REMOVED, function(event:GameInputEvent):Void
		{
			removedCount++;
			removedDevices.push(event.device);
		});

		var initial = {
			isSupported: GameInput.isSupported,
			numDevices: GameInput.numDevices,
			negativeDeviceIsNull: GameInput.getDeviceAt(-1) == null,
			missingDeviceIsNull: GameInput.getDeviceAt(0) == null
		};

		#if harness_compare
		var manager = @:privateAccess GameInput.__flightInputManager;
		FlightSignals.emitSignal(manager.onGamepadConnect, {
			gamepad: 2,
			id: "Harness Gamepad",
			mapping: "standard"
		});
		var device = GameInput.getDeviceAt(0);
		#else
		var device = @:privateAccess new GameInputDevice("Harness Gamepad", "Harness Gamepad");
		@:privateAccess GameInput.__deviceList.push(device);
		@:privateAccess GameInput.numDevices = 1;
		input.dispatchEvent(new GameInputEvent(GameInputEvent.DEVICE_ADDED, true, false, device));
		#end

		#if harness_compare
		FlightSignals.emitSignal(manager.onGamepadConnect, {
			gamepad: 5,
			id: "Second Gamepad",
			mapping: "standard"
		});
		var secondDevice = GameInput.getDeviceAt(1);
		#else
		var secondDevice = @:privateAccess new GameInputDevice("Second Gamepad", "Second Gamepad");
		@:privateAccess GameInput.__deviceList.push(secondDevice);
		@:privateAccess GameInput.numDevices = 2;
		input.dispatchEvent(new GameInputEvent(GameInputEvent.DEVICE_ADDED, true, false, secondDevice));
		#end

		var enabledBefore = device.enabled;
		var sampleIntervalBefore = device.sampleInterval;
		device.enabled = true;
		device.sampleInterval = 16;
		var axis = device.getControlAt(0);
		var button = device.getControlAt(6);
		var axisChanges = 0;
		var buttonChanges = 0;
		axis.addEventListener(Event.CHANGE, function(_:Event):Void axisChanges++);
		button.addEventListener(Event.CHANGE, function(_:Event):Void buttonChanges++);

		#if harness_compare
		FlightSignals.emitSignal(manager.onGamepadAxisMove, {axis: 0, gamepad: 2, timeStamp: 10, value: 0.5});
		FlightSignals.emitSignal(manager.onGamepadButtonDown, {button: 0, gamepad: 2, timeStamp: 11, value: 1});
		FlightSignals.emitSignal(manager.onGamepadButtonUp, {button: 0, gamepad: 2, timeStamp: 12, value: 0});
		#else
		@:privateAccess axis.value = 0.5;
		axis.dispatchEvent(new Event(Event.CHANGE));
		@:privateAccess button.value = 1;
		button.dispatchEvent(new Event(Event.CHANGE));
		@:privateAccess button.value = 0;
		button.dispatchEvent(new Event(Event.CHANGE));
		#end

		var replayedAddedCount = 0;
		var replayInput = new GameInput();
		replayInput.addEventListener(GameInputEvent.DEVICE_ADDED, function(_:GameInputEvent):Void replayedAddedCount++);
		var numDevicesWhileConnected = GameInput.numDevices;
		var enumeration = {
			firstDeviceMatches: GameInput.getDeviceAt(0) == device,
			firstName: device.name,
			missingDeviceIsNull: GameInput.getDeviceAt(2) == null,
			numDevices: numDevicesWhileConnected,
			secondDeviceMatches: GameInput.getDeviceAt(1) == secondDevice,
			secondName: secondDevice.name
		};
		var cachingDoesNotThrow = doesNotThrow(function()
		{
			device.startCachingSamples(2, null);
			device.stopCachingSamples();
			return null;
		});

		#if harness_compare
		FlightSignals.emitSignal(manager.onGamepadDisconnect, {
			gamepad: 2,
			id: "Harness Gamepad",
			mapping: "standard"
		});
		#else
		@:privateAccess GameInput.__deviceList.remove(device);
		@:privateAccess GameInput.numDevices = 1;
		input.dispatchEvent(new GameInputEvent(GameInputEvent.DEVICE_REMOVED, true, false, device));
		#end
		var afterFirstDisconnect = {
			firstRemoved: removedDevices[0] == device,
			numDevices: GameInput.numDevices,
			remainingDeviceMatches: GameInput.getDeviceAt(0) == secondDevice
		};

		#if harness_compare
		FlightSignals.emitSignal(manager.onGamepadDisconnect, {
			gamepad: 5,
			id: "Second Gamepad",
			mapping: "standard"
		});
		#else
		@:privateAccess GameInput.__deviceList.remove(secondDevice);
		@:privateAccess GameInput.numDevices = 0;
		input.dispatchEvent(new GameInputEvent(GameInputEvent.DEVICE_REMOVED, true, false, secondDevice));
		#end

		var event = new GameInputEvent(GameInputEvent.DEVICE_ADDED, true, false, device);
		var clone = event.clone();
		var samples = new ByteArray();

		return {
			constants: {
				deviceAdded: Std.string(GameInputEvent.DEVICE_ADDED),
				deviceRemoved: Std.string(GameInputEvent.DEVICE_REMOVED),
				deviceUnusable: Std.string(GameInputEvent.DEVICE_UNUSABLE),
				maxBufferSize: GameInputDevice.MAX_BUFFER_SIZE
			},
			initial: initial,
			enumeration: enumeration,
			device: {
				addedCount: addedCount,
				addedFirstMatches: addedDevices[0] == device,
				addedSecondMatches: addedDevices[1] == secondDevice,
				axisChanges: axisChanges,
				axisDeviceMatches: axis.device == device,
				axisID: axis.id,
				axisRange: [axis.minValue, axis.maxValue],
				axisValue: axis.value,
				buttonChanges: buttonChanges,
				buttonDeviceMatches: button.device == device,
				buttonID: button.id,
				buttonRange: [button.minValue, button.maxValue],
				buttonValue: button.value,
				cachedSamples: device.getCachedSamples(samples),
				cachedSamplesAppend: device.getCachedSamples(samples, true),
				cachingDoesNotThrow: cachingDoesNotThrow,
				enabledAfter: device.enabled,
				enabledBefore: enabledBefore,
				id: device.id,
				name: device.name,
				negativeControlIsNull: device.getControlAt(-1) == null,
				numControls: device.numControls,
				numDevicesWhileConnected: numDevicesWhileConnected,
				outOfRangeControlIsNull: device.getControlAt(device.numControls) == null,
				replayedAddedCount: replayedAddedCount,
				sampleIntervalAfter: device.sampleInterval,
				sampleIntervalBefore: sampleIntervalBefore
			},
			disconnect: {
				afterFirst: afterFirstDisconnect,
				deviceIsGone: GameInput.getDeviceAt(0) == null,
				numDevices: GameInput.numDevices,
				removedCount: removedCount,
				removedSecondMatches: removedDevices[1] == secondDevice
			},
			event: {
				bubbles: event.bubbles,
				cloneDeviceMatches: clone.device == device,
				cloneType: clone.type,
				type: event.type
			}
		};
	}

	private static function doesNotThrow(operation:Void->Dynamic):Bool
	{
		try
		{
			operation();
			return true;
		}
		catch (_:Dynamic)
		{
			return false;
		}
	}
}
