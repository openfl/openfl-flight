package harness;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

class TypeContract
{
	public static macro function constructorIsPublic(typePath:String):Expr
	{
		var isPublic = switch (Context.follow(Context.getType(typePath)))
		{
			case TInst(type, _):
				var constructor = type.get().constructor;
				constructor != null && constructor.get().isPublic;
			default:
				false;
		};

		return macro $v{isPublic};
	}
}
