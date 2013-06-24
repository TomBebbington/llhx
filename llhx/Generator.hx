package llhx;
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
using tink.macro.tools.MacroTools;
class Generator {
	public static inline var IDENTIFIER = "getGenerated";
	public static function toTypePath(cp:ClassType):TypePath {
		return {
			name: cp.name,
			pack: cp.pack,
			sub: null,
			params: [for(p in cp.params) TPType(Context.toComplexType(p.t))]
		};
	}
	public static function gen():Array<Field> {
		return if(Context.defined("js"))
			llhx.js.JSGenerator.gen();
		else {
			var pos = Context.currentPos();
			var fs = Context.getBuildFields();
			var cl = Context.getLocalClass().get();
			var tp:TypePath = toTypePath(cl);
			var ty = ComplexType.TPath(tp);
			for(ff in fs) {
				if(!ff.access.remove(AStatic))
					throw "All methods should be static";
				switch(ff.kind) {
					case FFun(func): func.expr.transform(map);
					default: 
				}
			}
			var func:Function = {
				ret: ty,
				params: [],
				args: [],
				expr: {expr: ENew(tp, []), pos: pos}
			};
			var prim:Field = {
				pos: pos,
				name: Generator.IDENTIFIER,
				kind: FFun(func),
				access: [Access.AStatic, Access.APublic]
			};
			var constFunc:Function = {
				ret: null,
				params: [],
				expr: {expr: EBlock([]), pos: pos},
				args: []
			};
			var const:Field = {
				pos: pos,
				name: "new",
				kind: FFun(constFunc),
				access: [Access.APublic]
			};
			fs.push(const);
			//fs.push(prim);
			fs;
		}
	}
	static function map(e:Expr):Expr {
		return switch(e.expr) {
			case EConst(CIdent("true")): {expr: EConst(CInt("1")), pos: e.pos};
			case EConst(CIdent("false")): {expr: EConst(CInt("0")), pos: e.pos};
			case EConst(CIdent("null")): error("Null is not allowed", e.pos);
			case EConst(CString(s)): {expr: EArrayDecl([for(i in 0...s.length) Context.makeExpr(s.charCodeAt(i), e.pos)]), pos: e.pos};
			default: e;
		};
	}
	public static inline function error(s:String, p:Position) {
		var pi = Context.getPosInfos(p);
		Sys.println('$s at ${pi.file} chars ${pi.min}-${pi.max}');
		Sys.exit(0);
		return null;
	}
}