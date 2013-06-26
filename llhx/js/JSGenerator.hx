package llhx.js;
import haxe.macro.*;
import haxe.macro.Type;
import haxe.macro.Expr;
using Lambda;
using haxe.macro.ExprTools;
class JSGenerator {
	static var defaultVars:Array<Var> = [{
		name: "window",
		type: ComplexType.TPath({
			params: [],
			pack: ["js", "html"],
			name: "DOMWindow"
		}),
		expr: null
	}, {
		name: "__js__",
		type: ComplexType.TFunction([macro:String], macro: Void),
		expr: null
	}];
	static inline var FIELD_PRE = "f_";
	static inline var HEAP_NAME = "heap";
	static inline var EXTERN_NAME = "ext";
	static inline var STDLIB_NAME = "std";
	static inline var BUFFER_SIZE = 4096;
	public var globals:Array<Var>;
	public var externs:Map<String, Expr>;
	public var functions:Map<String, Function>;
	public var functionIds:Map<String, String>;
	public var inits:Array<Expr>;
	var fields:Array<Field>;
	var locals:Array<Var>;
	var idn:Int;
	public static function gen():Array<Field> {
		var fs:Array<Field> = Context.getBuildFields();
		var typath = Generator.toTypePath(Context.getLocalClass().get());
		var ty = (typath.sub == null ? "" : '${typath.sub}.') + typath.name;
		for(p in typath.pack)
			ty = '$p.$ty';
		var exp = new JSGenerator(fs).toExpr();
		var a = Context.parse(ty, exp.pos);
		exp = macro untyped $a = $exp;
		fs.push({
			pos: exp.pos,
			kind: FFun({
				ret: macro:Void,
				params: [],
				args: [],
				expr: exp
			}),
			name: "__init__",
			access: [AStatic]
		});
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
		globals = [];
		inits = [];
		externs = new Map();
		locals = null;
		for(f in fs) {
			switch(f.kind) {
				case FVar(t, e): globals.push({expr: e, type: t, name: f.name});
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
		if(locals.indexOf(defaultVars[0]) == -1) locals = locals.concat(defaultVars);
		var complic = true;
		var typeCheck = true;
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
						case _ if(a.type == null): Context.error("Must be typed", e.pos);
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
				"{" + [for(ex in exprs) {
					genAsm(ex) + ";";
				}].join("") + "}";
			case EReturn(exp): "return " + genAsm(exp, true);
			case EIf(conf, eif, eelse):
				var gconf = genAsm(conf, true), gif = genAsm(eif), gelse = eelse == null ? null : genAsm(eelse);
				'if($gconf) $gif' + (eelse == null ? "" : ' else $gelse');
			case EWhile(cond, exp, true):
				var gcond = genAsm(cond, true), gexp = genAsm(toBlock(exp));
				'while($gcond)$gexp';
			case ECall({expr: EField({expr: EConst(CIdent("String")), pos: _}, "fromCharCode")}, [val]):
				complic = false; "["+genAsm(val)+"]";
			case ECall({expr: EConst(CIdent("__js__")), pos: _}, [{expr: EConst(CString(val)), pos: _}]):
				complic = false; val;
			case ECall({expr: EField(str, "charCodeAt")}, [n]) if(Generator.is(str, macro:String, locals)): complic = false; genAsm(str)+"["+genAsm(n)+"]";
			case ECall({expr: EField(str, "charAt")}, [n]) if(Generator.is(str, macro:String, locals)): complic = false; "["+genAsm(str)+"["+genAsm(n)+"]]";
			case ECall({expr: EField({expr: EConst(CIdent("Std")), pos: _}, "int")}, [val]): complic = false; "~~" + genAsm(val);
			case ECall(field, ps) if(switch(field.expr) {case EField(_, _): true; default: false;}):
				var func = field;
				switch(llhx.Generator.typeOf(field, locals)) {
					case TFunction(args, ret):
						var sargs = [for(i in 0...args.length) if(Generator.typeEq(args[i], macro: String)) i];
						var shouldWrap = sargs.length > 0 || Generator.typeEq(ret, macro:String);
						var newType = if(Generator.typeEq(ret, macro:String)) macro: js.html.Uint8Array else ret;
						if(shouldWrap) {
							var nargs = 0;
							for(sarg in sargs)
								args[sarg] = macro: js.html.Uint8Array;
							func = {expr: EFunction("", {
								ret: newType,
								params: [],
								args: [for(a in 0...args.length) {type: sargs.indexOf(a) != -1 ? macro:js.html.Uint8Array : args[a], opt: false, name: genId(a)}],
								expr: {
									expr: ECall(func, [for(a in 0...args.length) {expr: EConst(CIdent(genId(a))), pos: e.pos}]),
									pos: e.pos
								}
							}), pos: e.pos};
						}
					default:
				}
				var id = genId();
				externs.set(id, func);
				'${EXTERN_NAME}.$id(' + [for(p in ps) genAsm(p, true)].join(", ") + ")";
			case ECall(exp, ps): complic = false; genAsm(exp) + "(" + [for(p in ps) genAsm(p, true)].join(", ") + ")";
			case EConst(CIdent("true")): complic = false; "1";
			case EConst(CIdent("false")): complic = false; "0";
			case EConst(CIdent("null")): Context.error("Null is not allowed", e.pos);
			case EConst(CIdent(b)): complic = false; b;
			case EConst(CInt(v)): complic = false; '$v';
			case EConst(CFloat(f)): complic = false; f;
			case EConst(CString(_)): Context.error("String literal must be in variable", e.pos);
			case EArrayDecl(_): Context.error("Array declaration must be in variable", e.pos);
			case EArray(a, i): genAsm(a) + "[" + genAsm(i, true) + "]";
			case EUntyped(e): complic = false; typeCheck = false; genAsm(e);
			case EVars(vars):
				vars = llhx.Tools.removeDuplicates(vars, function(a:Var, b:Var) return a.name == b.name && Generator.typeEq(a.type, b.type));
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
								var name = v.name;
								var str = 'var $name = new ${STDLIB_NAME}.Uint8Array(${HEAP_NAME});';
								for(i in 0...s.length) {
									var ind = Context.makeExpr(i, v.expr.pos);
									var code = Context.makeExpr(s.charCodeAt(i), v.expr.pos);
									var namex = {expr: EConst(CIdent(name)), pos: v.expr.pos};
									inits.push(macro $namex[$ind] = $code);
								}
								str;
							case EArrayDecl(vs) if(typeCheck):
								var type = if (Generator.is(v.expr, macro:Array<Int>, this.locals))
									"Int32"
								else if(Generator.is(v.expr, macro:Array<Float>, this.locals))
									"Float64"
								else {
									Context.error("Unsupported array type", v.expr.pos);
									"";
								}
								var str = 'var ${v.name} = new ${STDLIB_NAME}.${type}Array(${HEAP_NAME});';
								for(i in 0...vs.length) {
									var val = vs[i];
									var ind = Context.makeExpr(i, v.expr.pos);
									var code = Context.makeExpr(genAsm(val, true), v.expr.pos);
									var namex = {expr: EConst(CIdent(v.name)), pos: v.expr.pos};
									inits.push(macro $namex[$ind] = untyped __js__($code));
								}
								str;
							default: ""; 
						}
					}).join("");
				s;
			case EField({expr: EConst(CIdent("Math"))}, field) if(Generator.typeEq(Generator.typeOf(e, locals), macro:Void)):
				var id = genId();
				externs.set(id, macro function() return $e);
				genAsm(Context.makeExpr(Reflect.field(Math, field), e.pos), true);
			case EField({expr: EConst(CIdent("Math")), pos: pos}, field):
				var name = '${STDLIB_NAME}.Math.$field';
				var ref = null;
				for(gk in globals) {
					switch(gk.expr.expr) {
						case EUntyped({expr: EConst(CIdent(cname)), pos: _}) if(name == cname):
							ref = cname;
							break;
						default:
					}
				}
				if(ref != null)
					ref;
				else {
					var id = genId();
					globals.push({
						name: id,
						expr: {expr: EUntyped({expr: EConst(CIdent(name)), pos: pos}), pos: pos},
						type: null
					});
					id;
				}
			case EField(exp, field):
				'${genAsm(exp)}.$field';
			case ECast(exp, to):
				annot = true;
				genAsm(exp);
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
			default: Generator.error('Could not compile ${e.toString()}', e.pos); "";
		};
		as = StringTools.replace(as, ";;", ";");
		return if(typeCheck) {
			var format = switch(Generator.typeOf(e, locals)) {
				case TPath({name: "Int", pack: [], sub: _, params: []}): complic ? "($)|0" : "$|0";
				case TPath({name: "Float", pack: [], sub: _, params: []}): complic ? "+($)" : "+$";
				case all: "$";
			};
			!annot ? as : StringTools.replace(format, "$", as); 
		} else as;
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
	public function toExpr():Expr {
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
		var allVars = fieldLocals.concat(globals);
		s.add(genAsm({expr: EVars(allVars), pos: Context.currentPos()}, true));
		for(f in genFuncs)
			s.add(f);
		var b = genAsm({expr: EBlock(inits), pos: Context.currentPos()});
		s.add('function init() $b');
		functionIds.set("init", "__init__");
		var obj = [for(f in functionIds.keys()) '${functionIds.get(f)}: $f'].join(", ");
		s.add('return {$obj};');
		s.add("})");
		var funcExpr = macro untyped __js__($v{s.toString()});
		var window = macro js.Browser.window;
		var obj =  {expr: EObjectDecl([for(k in externs.keys())
			{
				expr: externs.get(k),
				field: k
			}
		]), pos: Context.currentPos()};
		var buf = macro new js.html.ArrayBuffer($v{BUFFER_SIZE});
		return macro {
			$funcExpr($window, $obj, $buf);
		};
	}
}