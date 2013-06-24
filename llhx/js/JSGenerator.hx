package llhx.js;
import haxe.macro.*;
import haxe.macro.Type;
import haxe.macro.Expr;
using Lambda;
using tink.macro.tools.MacroTools;
class JSGenerator {
	static var windowVar = {
		name: "window",
		type: ComplexType.TPath({
			params: [],
			pack: ["js", "html"],
			name: "DOMWindow"
		}),
		expr: null
	};
	static inline var FIELD_PRE = "f_";
	static inline var HEAP_NAME = "heap";
	static inline var EXTERN_NAME = "ext";
	static inline var STDLIB_NAME = "std";
	public var globals:Map<String, String>;
	public var externs:Map<String, String>;
	public var functions:Map<String, Function>;
	public var functionIds:Map<String, String>;
	var fields:Array<Field>;
	var locals:Array<Var>;
	var idn:Int;
	public static function gen():Array<Field> {
		var fs:Array<Field> = Context.getBuildFields();
		var fexpr:Expr = macro return untyped __js__($v{new JSGenerator(fs).toString()});
		var func:Function = {
			ret: ComplexType.TPath({params: [], pack: [], name: "Dynamic"}),
			params: [],
			expr: fexpr,
			args: []
		};
		fs = [{
			pos: Context.currentPos(),
			name: Generator.IDENTIFIER,
			kind: FFun(func),
			access: [Access.AStatic, Access.APublic]
		}];
		return fs;
	}
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
		fields = fs;
		functions = new Map();
		functionIds = new Map();
		globals = new Map();
		externs = new Map();
		locals = null;
		for(f in fs) {
			switch(f.kind) {
				case FVar(t, e): globals.set(f.name, genAsm(e, true));
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
		if(locals == null) locals = [];
		if(locals.indexOf(windowVar) == -1) locals.push(windowVar);
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
			case EWhile(cond, exp, true):
				var gcond = genAsm(cond, true), gexp = genAsm(toBlock(exp));
				'while($gcond)$gexp';
			case ECall({expr: EField({expr: EConst(CIdent("String")), pos: _}, "fromCharCode")}, [val]):
				complic = false; "["+genAsm(val)+"]";
			case ECall({expr: EField(str, "charCodeAt")}, [n]) if(Generator.is(str, macro:String, locals)): complic = false; genAsm(str)+"["+genAsm(n)+"]";
			case ECall({expr: EField(str, "charAt")}, [n]) if(Generator.is(str, macro:String, locals)): complic = false; "["+genAsm(str)+"["+genAsm(n)+"]]";
			case ECall({expr: EField({expr: EConst(CIdent("Std")), pos: _}, "int")}, [val]): complic = false; "~~" + genAsm(val);
			case ECall(field, ps) if(switch(field.expr) {case EField(_, _): true; default: false;}):
				var id = genId();
				externs.set(id, genAsm(field));
				'${EXTERN_NAME}.$id(' + [for(p in ps) genAsm(p, true)].join(", ") + ")";
			case ECall(exp, ps): complic = false; genAsm(exp) + "(" + [for(p in ps) genAsm(p, true)].join(", ") + ")";
			case EConst(CIdent("true")): complic = false; "1";
			case EConst(CIdent("false")): complic = false; "0";
			case EConst(CIdent("null")): throw "Null is not allowed";
			case EConst(CIdent(b)): complic = false; b;
			case EConst(CInt(v)): complic = false; '$v';
			case EConst(CFloat(f)): complic = false; f;
			case EConst(CString(_)): throw "String literal must be in variable";
			case EArrayDecl(_): throw "Array declaration must be in variable";
			case EArray(a, i): genAsm(a) + "[" + genAsm(i) + "]";
			case EUntyped(e): complic = false; genAsm(e);
			case EVars(vars): 
				locals = locals.concat(vars);
				function isArrayConstVar(v:Var) {
					return switch(v.expr.expr) {
						case EConst(CString(_)): true;
						case EArrayDecl(_): true;
						default: false; 
					}
				}
				var svars = vars.filter(isArrayConstVar);
				var nvars = vars.filter(function(v) return !isArrayConstVar(v));
				var s = "";
				if(nvars.length > 0)
					s += "var "+[for(v in nvars) {
						var s = v.name;
						if(v.expr != null)
							s += " = " + genAsm(v.expr, true);
					}].join(", ") + ";";
				if(svars.length > 0)
					s += svars.map(function(v:Var) {
						return switch(v.expr.expr) {
							case EConst(CString(s)):
								var str = 'var ${v.name} = new ${STDLIB_NAME}.Uint8Array(${HEAP_NAME});';
								for(i in 0...s.length)
									str += '${v.name}[$i]=${s.charCodeAt(i)}|0;';
								str;
							case EArrayDecl(vs):
								var type = if (Generator.is(v.expr, macro:Array<Int>, this.locals))
									"Int32"
								else if(Generator.is(v.expr, macro:Array<Float>, this.locals))
									"Float64"
								else
									throw 'Unsupported array type: ${vs[0].typeof(locals)}';
								var str = 'var ${v.name} = new ${STDLIB_NAME}.${type}Array(${HEAP_NAME});';
								for(i in 0...vs.length) {
									var code = genAsm(vs[i], true);
									str += '${v.name}[$i]=$code;';
								}
								str;
							default: ""; 
						}
					}).join("");
				s;
			case EField({expr: EConst(CIdent(n)), pos: _}, field) if(n != "Math"):
				'$n.$field';
			case EField({expr: EConst(CIdent("Math")), pos: _}, field):
				var name = '${STDLIB_NAME}.Math.$field';
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
				var s = 'for(var $i=$a;$i<$b;$i++)${genAsm(expr)}';
				locals.remove(tlocal);
				s;
			case ENew({name: "String", pack: [], params: []}, params):
				'new ${STDLIB_NAME}.Uint8Array(${HEAP_NAME})';
			case ENew({name: "Array", pack: [], params: [TPType(p)]}, params) if(Generator.typeEq(p, macro: Float)):
				'new ${STDLIB_NAME}.Float64Array(${HEAP_NAME})';
			case ENew({name: "Array", pack: [], params: [TPType(p)]}, params) if(Generator.typeEq(p, macro: Int)):
				'new ${STDLIB_NAME}.Int32Array(${HEAP_NAME})';
			case EUnop(OpDecrement, true, exp): complic = false; genAsm(exp) + "--";
			case EBinop(OpAssign, a, b): genAsm(a) + "=" + genAsm(b, true);
			case EBinop(OpAssignOp(op), a, b): genAsm(a) + getOp(op) + "=" + genAsm(b, true);
			case EBinop(op, a, b): genAsm(a, true) + getOp(op) + genAsm(b, true);
			default: trace(e.expr); "";
		};
		as = StringTools.replace(as, ";;", ";");
		var format = switch(e.typeof(locals)) {
			case Success(TAbstract(t, params)) if(t.get().name == "Int"): complic ? "($)|0" : "$|0";
			case Success(TAbstract(t, params)) if(t.get().name == "Float"): complic ? "+($)" : "+$";
			case Failure(info): 
				var localss = [for(l in locals) if(l.name == null) Std.string(l) else l.name].join(", ");
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
		s.add('(function(${STDLIB_NAME}, ${EXTERN_NAME}, ${HEAP_NAME}) {');
		s.add("\"use asm\";");
		var fieldLocals:Array<Var> = [for(f in fields) switch(f.kind) {
			case FVar(typ, exp): {
				type: typ,
				expr: exp,
				name: f.name
			}
			default: null;
		}].filter(function(x) return x != null);
		var genFuncs = [for(f in functions.keys()) {
			var v = functions.get(f);
			locals = fieldLocals.copy();
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
		s.add("})(window, {");
		s.add([for(k in externs.keys()) '$k: ${externs.get(k)}'].join(", "));
		s.add("}, new ArrayBuffer(4 * 1024))");
		trace(s);
		return s.toString();
	}
}