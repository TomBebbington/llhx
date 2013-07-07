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
				case TPath(pb): ((pa.name == "Dynamic" || pb.name == "Dynamic") || (pa.name == "StdTypes" && pa.sub == pb.name) || (pb.name == "StdTypes" && pb.sub == pa.name) || (pa.name == pb.name && pa.pack.length == pb.pack.length)) && pa.params.length == pb.params.length && [for(i in 0...pa.params.length)typeEq(getParamType(pa.params[i]), getParamType(pb.params[i]))].length == pa.params.length;
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
		var void = macro:Void;
		var dynam = macro:Dynamic;
		return switch(e.expr) {
			case EWhile(_, _, _): void;
			case EVars(vs): for(v in vs) p.push(v); void;
			case EUntyped(o): trace(e); trace(o); dynam;
			case EUnop(_, _, e): typeOf(e, p);
			case ETry(e, _): typeOf(e, p);
			case EThrow(e): void;
			case ETernary(econf, eif, eelse): typeOf(eif, p);
			case ESwitch(_, cases, _) if(cases.length > 0): typeOf(cases[0].expr, p); 
			case ESwitch(_, _, edef): typeOf(edef, p);
			case EReturn(e) if(e == null): void;
			case EReturn(e): typeOf(e, p);
			case EParenthesis(e): typeOf(e, p);
			case EObjectDecl(fields): TAnonymous([for(f in fields){name: f.field, pos: e.pos, kind: FieldType.FVar(typeOf(f.expr, p), f.expr)}]);
			case ENew(tp, _): TPath(tp);
			case EMeta(_, _): void;
			case EIn(_, _): void;
			case EIf(_, eif, _): typeOf(eif, p);
			case EFunction(_, f): ComplexType.TFunction([for(a in f.args) a.type == null ? typeOf(a.value, p) : a.type], f.ret == null ? typeOf(f.expr, p) : f.ret);
			case EFor(eit, expr): void;
			case ECall({expr: EField({expr: EConst(CIdent("Math"))}, _)}, _): macro:Float;
			case EField({expr: EConst(CIdent("Math"))}, _): macro:Float;
			case EField({expr: EConst(CIdent(i)), pos: _}, field) if( try Context.getType(i) != null catch(e:Dynamic) true): dynam;
			default: void;
			case EDisplayNew(_): void;
			case EDisplay(e, isCall): void;
			case EContinue: void;
			case EConst(CInt(v)): macro:Int;
			case EConst(CFloat(f)): macro:Float;
			case EConst(CString(s)): macro:String;
			case EConst(CIdent("true") | CIdent("false")) | ECheckType(_, _): macro:Bool;
			case EConst(CIdent(i)):
				var daType = null;
				for(v in p)
					if(v.name == i) {
						daType = v.type == null ? typeOf(v.expr, p) : v.type;
						break;
					}
				try {
					daType = Context.toComplexType(Context.getType(i));
				} catch(e:Dynamic) {}
				daType == null ? error('No such variable "$i"', e.pos) : daType;
			case EConst(CRegexp(r, opt)): macro:RegExp;
			case ECast(e, t) if(t == null): typeOf(e, p);
			case ECast(e, t): t;
			case ECall(f, params):
				switch(typeOf(f, p)) {
					case TFunction(_, ret): ret;
					default: dynam;
				}
			case EBreak: void;
			case EBlock([]): void;
			case EBlock(exprs): typeOf(exprs[exprs.length-1], p);
			case EBinop(_, a, _): typeOf(a, p);
			case EArrayDecl(vals) if(vals.length == 0): macro:Array<Dynamic>;
			case EArrayDecl(vals): macro:Array<Dynamic>;
			case EArray(a, _): switch(typeOf(a, p)) {
				case TPath(pa) if(pa.params.length > 0): switch(pa.params[0]) {
					case TPType(t): t;
					case TPExpr(e): typeOf(e, p);
				};
				default: dynam;
			};
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
		Sys.println('${pi.file}:${Tools.getLineInFile(p)} - $s');
		Sys.exit(1);
		return null;
	}
}