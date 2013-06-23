package asm;
import haxe.macro.*;
import haxe.macro.Type;
import haxe.macro.Expr;
using tink.macro.tools.MacroTools;
class AsmMod {
	static inline var FIELD_PRE = "f_";
	public var globals:Map<String, String>;
	public var functions:Map<String, Function>;
	public var functionIds:Map<String, String>;
	var locals:Array<Var>;
	var idn:Int;
	function genId(x:Int=-1):String {
		if(x < 0)
			x = idn++;
		return "_"+if(x < 26)
			String.fromCharCode("a".code + x);
		else if(x < 52)
			String.fromCharCode("A".code + x - 26);
		else {
			var avail = 52;
			var s = "";
			while (x > 0) {
				s = genId(x % avail) + s;
				x = Std.int(x / avail);
			}
			s;
		}
	}
	public function new(fs:Array<Field>) {
		idn = 0;
		functions = new Map();
		functionIds = new Map();
		globals = new Map();
		for(f in fs) {
			switch(f.kind) {
				case FVar(t, e): globals.set(f.name, genAsm(e));
				case FProp(get, set, t, e): 
				case FFun(fn):
					var id = genId();
					functions.set(id, fn);
					functionIds.set(id, f.name);
			}
		}
	}
	static function toBlock(e:Expr):Expr {
		return switch(e.expr) {
			case EBlock(_): e;
			default: {expr: EBlock([e]), pos: e.pos};
		}
	}
	public function genAsm(e:Expr, annot:Bool=false):String {
		var complic = true;
		var as = switch(e.expr) {
			case EFunction(name, f) if(name == null):
				throw "No anonymous functions allowed in ASM";
			case EFunction(name, f):
				var args = [for(a in f.args) a.name].join(", ");
				var asserts = "";
				for(a in f.args) {
					locals.push({
						name: a.name,
						type: a.type,
						expr: a.value
					});
					switch(a.type) {
						case TPath({name: "Int", pack: [], params: []}):
							asserts += '${a.name} = ${a.name}|0;';
						case TPath({name: "Float", pack: [], params: []}):
							asserts += '${a.name} = +${a.name};';
						default:
					}
				}
				var aexprs = switch(f.expr.expr) {
					case EBlock(exprs): exprs;
					default: [f.expr];
				}
				var asm = [for(ex in aexprs) genAsm(ex) + ";"].join("");
				'function $name($args) {$asserts$asm}';
			case EBlock(exprs): complic = false;
				"{" + [for(ex in exprs) genAsm(ex) + ";"].join("") + "}";
			case EReturn(exp): "return " + genAsm(exp, true);
			case ECall(exp, ps): complic = false; genAsm(exp) + "(" + [for(p in ps) genAsm(p, true)].join(", ") + ")";
			case EConst(CIdent(b)): complic = false; b;
			case EConst(CInt(v)): complic = false; '$v';
			case EConst(CFloat(f)): complic = false; f;
			case EConst(CString(s)): "[" + [for(i in 0...s.length) s.charCodeAt(i)].join(", ") + "]";
			case EVars(vars): 
				locals = locals.concat(vars);
				[for(v in vars) {
					var s = 'var ${v.name}';
					if(v.expr != null)
						s += " = " + genAsm(v.expr, true);
					s += ";";
				}].join("");
			case EField({expr: EConst(CIdent(ident)), pos: _}, field):
				var name = 'std.$ident.$field';
				var ref = null;
				for(gk in globals.keys()) {
					if(globals.get(gk) == name) {
						ref = gk;
						break;
					}
				}
				if(ref != null)
					ref;
				else {
					var id = genId();
					globals.set(id, name);
					id;
				}
			case EFor({expr:EIn({expr:EConst(CIdent(i)), pos: _}, {expr: EBinop(OpInterval, ea, eb), pos: _}), pos: _}, expr):
				var a = genAsm(ea), b = genAsm(eb);
				var tlocal = {
					type: TPath({
						params: [],
						pack: [],
						name: "Int"
					}),
					name: i,
					expr: null
				};
				locals.push(tlocal);
				var s = 'for($i=$a;$i<$b;$i++)${genAsm(expr)}';
				locals.remove(tlocal);
				s;
			case EBinop(OpAssign, a, b): genAsm(a) + "=" + genAsm(b, true);
			case EBinop(OpAssignOp(op), a, b): genAsm(a) + getOp(op) + "=" + genAsm(b, true);
			case EBinop(op, a, b): genAsm(a) + getOp(op) + genAsm(b);
			default: trace(e.expr); "";
		};
		var format = switch(e.typeof(locals)) {
			case Success(TAbstract(t, params)) if(t.get().name == "Int"): complic ? "($)|0" : "$|0";
			case Success(TAbstract(t, params)) if(t.get().name == "Float"): complic ? "+($)" : "+$";
			case Failure(info): 
				var localss = [for(l in locals) l.name].join(", ");
				throw '$info in ${e.expr} with $localss';
			default: "$";
		};
		return !annot ? as : StringTools.replace(format, "$", as); 
	}
	function getOp(op:Binop) {
		return switch(op) {
			case OpXor: "^";
			case OpUShr: ">>>";
			case OpShr: ">>";
			case OpShl: "<<";
			case OpOr: "|";
			case OpNotEq: "!=";
			case OpMult: "*";
			case OpMod: "%";
			case OpLte: "<=";
			case OpLt: "<";
			case OpGte: ">=";
			case OpGt: ">";
			case OpEq: "==";
			case OpInterval, OpArrow: throw "Unsupported";
			case OpDiv: "/";
			case OpBoolOr: "||";
			case OpBoolAnd: "&&";
			case OpAssign: "=";
			case OpAnd: "&";
			case OpSub: "-";
			case OpAdd: "+";
			case OpAssignOp(oop): getOp(oop)+"=";
		}
	}
	public function toString() {
		var s = new StringBuf();
		s.add("(function(std, ext, heap) {");
		s.add("\"use asm\";");
		var genFuncs = [for(f in functions.keys()) {
			var v = functions.get(f);
			locals = [];
			genAsm({expr: EFunction(f, v), pos: Context.currentPos()});
		}];
		for(k in globals.keys()) {
			var v = globals.get(k);
			s.add('var $k = $v;');
		}
		for(f in genFuncs)
			s.add(f);
		var obj = [for(f in functionIds.keys()) '${functionIds.get(f)}: $f'].join(", ");
		s.add('return {$obj};');
		s.add("})");
		s.add("(window)");
		trace(s);
		return s.toString();
	}
}