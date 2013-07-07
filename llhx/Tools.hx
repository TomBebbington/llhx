package llhx;
using Lambda;
import haxe.macro.Expr;
import haxe.PosInfos;
import haxe.macro.Context;
class Tools {
	public static inline function enumEq(a:EnumValue, b:EnumValue):Bool {
		return Type.enumEq(a, b);
	}
	public static function removeDuplicates<T>(a:Array<T>, eq:T -> T -> Bool):Array<T> {
		var exc = new Array<T>();
		for(i in a) {
			var unique = true;
			for(b in exc)
				if(i == b || eq(i, b)) {
					unique = false;
					break;
				}
			if(unique)
				exc.push(i);
		}
		return exc;
	}
	public static function getLineInFile(p:Position) {
		var pi = haxe.macro.Context.getPosInfos(p);
		var c = sys.io.File.getContent(pi.file);
		c = c.substr(0, pi.min);
		return c.split("\n").length;
	}
	public static function toPosInfos(p:Position, ?lm:String):haxe.PosInfos {
		var pi = haxe.macro.Context.getPosInfos(p);
		var line = getLineInFile(p);
		return {
			lineNumber: line,
			fileName: pi.file,
			className: Context.getLocalClass().get().name,
			methodName: lm != null ? lm : Context.getLocalMethod()
		};
	}
}