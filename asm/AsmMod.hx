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
	public function genAsm(e:Expr, ?locals:Array<Var>, annot:Bool=false):String {
		if(locals == null)
			locals = [];
		var format = switch(e.typeof(locals)) {
			case Success(TAbstract(t, params)) if(t.get().name == "Int"): "($)|0";
			case Success(TAbstract(t, params)) if(t.get().name == "Float"): "+$";
			case Failure(info): throw '$info in ${e.expr} with $locals';
			default: "$";
		};
		var typed = annot && format.length > 1;
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
				'function $name($args) {$asserts${genAsm(f.expr, locals, true)}};';
			case EBlock(exprs):
				"{" + [for(ex in exprs) genAsm(ex, locals) + ";"].join("") + "}";
			case EReturn(exp): "return " + genAsm(exp, locals);
			case ECall(exp, ps): genAsm(exp, locals) + "(" + [for(p in ps) genAsm(p, locals, true)].join(", ") + ")";
			case EConst(CIdent(b)): b;
			case EConst(CInt(v)): '$v';
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
				var a = genAsm(ea, locals), b = genAsm(eb, locals);
				var llocals = locals.copy();
				llocals.push({
					type: TPath({
						params: [],
						pack: [],
						name: "Int"
					}),
					name: i,
					expr: null
				});
				'for($i=$a;$i<$b;$i++)${genAsm(expr, llocals)}';
			case EBinop(OpAssign, a, b): genAsm(a, locals) + "=" + genAsm(b, locals, typed);
			case EBinop(OpAssignOp(op), a, b): genAsm(a, locals) + getOp(op) + "=" + genAsm(b, locals, typed);
			case EBinop(op, a, b): genAsm(a, locals, typed) + getOp(op) + genAsm(b, locals, typed);
			default: trace(e.expr); "";
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
		s.add("(function(std, foreign, heap) {");
		s.add("\"use asm\";");
		var genFuncs = [for(f in functions.keys()) {
			var v = functions.get(f);
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