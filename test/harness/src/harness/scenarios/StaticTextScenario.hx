package harness.scenarios;

import harness.TypeContract;
import openfl.text.StaticText;

class StaticTextScenario
{
	public static function run():Dynamic
	{
		var instance:StaticText = Type.createInstance(StaticText, []);
		var text:String = null;
		var textReadable = succeeds(function() {
			text = instance.text;
		});

		return {
			typeName: Type.getClassName(Type.getClass(instance)),
			constructorIsPublic: TypeContract.constructorIsPublic("openfl.text.StaticText"),
			cannotConstructPublicly: !TypeContract.constructorIsPublic("openfl.text.StaticText"),
			text: text,
			textReadable: textReadable,
			emptyDefault: text == null || text == "",
			display: {
				alpha: instance.alpha,
				height: instance.height,
				parent: instance.parent == null,
				root: instance.root == null,
				stage: instance.stage == null,
				visible: instance.visible,
				width: instance.width
			}
		};
	}

	private static function succeeds(operation:Void->Void):Bool
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
