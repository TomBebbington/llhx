package llhx;
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ExprTools;
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
		return if(Context.defined("js") && !Context.defined("no-asm"))
			llhx.js.JSGenerator.gen();
		else Context.getBuildFields();
	}
	static function getParamType(p:TypeParam):ComplexType {
		return switch(p) {
			case TPType(t): t;
			default: null;
		}
	}
	public static function typeEq(a:ComplexType, b:ComplexType):Bool {
		return if (a == null && b == null) true;
		else if((a == null && b != null) || (b == null && a != null)) false;
		else switch(a) {
			case TOptional(t): typeEq(t, b);
			case TPath(pa): switch(b) {
				case TPath(pb): ((pa.name == "StdTypes" && pa.sub == pb.name) || (pb.name == "StdTypes" && pb.sub == pa.name) || (pa.name == pb.name && pa.pack.length == pb.pack.length)) && pa.params.length == pb.params.length && [for(i in 0...pa.params.length)typeEq(getParamType(pa.params[i]), getParamType(pb.params[i]))].length == pa.params.length;
				default: false;
			}
			case TParent(t): return typeEq(t, b);
			case TFunction(args, ret):
				switch(b) {
					case TFunction(bargs, bret): typeEq(ret, bret) && args.length == bargs.length && [for(i in 0...bargs.length) i].filter(function(i) return typeEq(args[i], bargs[i])).length == bargs.length;
					default: false;
				}
			case TAnonymous(a):
				switch(b) {
					case TAnonymous(b): a.length == b.length && [for(i in 0...b.length) i].filter(function(n) return a[n].name == b[n].name).length == a.length;
					default: false;
				}
			default: false;
		};
	}
	public static function typeOf(e:Expr, p:Array<Var>):ComplexType {
		return switch(e.expr) {
			default:
				if(p != null && p.length > 0)
					e = {expr: EBlock([{expr: EVars(p), pos: e.pos}]), pos: e.pos};
				Context.toComplexType(Context.typeof(e));
		}
	}
	public static function is(e:Expr, ct:ComplexType, p:Array<Var>):Bool {
		return typeEq(ct, typeOf(e, p));
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
	public static inline function error(s:String, p:Position):Dynamic {
		var pi = Context.getPosInfos(p);
		Sys.println('$s at ${pi.file} chars ${pi.min}-${pi.max}');
		Sys.exit(0);
		return null;
	}
}