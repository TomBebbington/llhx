package asm;
import haxe.macro.*;
import haxe.macro.Type;
import haxe.macro.Expr;
class Asm {
	static var externs:Map<String, String> = new Map();
	static var nids:Int = 0;
	public static macro function gen():Array<Field> {
		externs = new Map();
		nids = 0;
		var fs:Array<Field> = Context.getBuildFields();
		var mod = new AsmMod(fs);
		var str = mod.toString();
		var fexpr:Expr = macro {
			return untyped __js__($v{str});
		};
		var func:Function = {
			ret: ComplexType.TPath({params: [], pack: [], name: "Dynamic"}),
			params: [],
			expr: fexpr,
			args: []
		};
		fs = [{
			pos: Context.currentPos(),
			name: "asm",
			kind: FFun(func),
			access: [Access.AStatic, Access.APublic]
		}];
		return fs;
	}
}