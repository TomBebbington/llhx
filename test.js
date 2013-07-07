(function () { "use strict";
var Std = function() { }
Std.__name__ = true;
Std.string = function(s){
	return js.Boot.__string_rec(s,"");
}
Std.parseFloat = function(x){
	return parseFloat(x);
}
var llhx = {}
llhx.LowLevel = function() { }
llhx.LowLevel.__name__ = true;
var CircleTools = function() { }
CircleTools.__name__ = true;
CircleTools.__interfaces__ = [llhx.LowLevel];
var Test = function() { }
Test.__name__ = true;
Test.main = function(){
	Test.lastVal = 0;
	if(js.Browser.window.mozRequestAnimationFrame != null) js.Browser.window.requestAnimationFrame = js.Browser.window.mozRequestAnimationFrame;
	js.Browser.window.addEventListener("load",function(_){
		Test.radius = js.Browser.document.getElementById("radius");
		Test.area = js.Browser.document.getElementById("area");
		Test.circ = js.Browser.document.getElementById("circ");
		js.Browser.window.requestAnimationFrame(Test.update);
	});
}
Test.update = function(d){
	var radiusv = Std.parseFloat(Test.radius.value);
	if(radiusv == Test.lastVal) return true;
	Test.area.value = Std.string(CircleTools.area(radiusv));
	Test.circ.value = Std.string(CircleTools.circ(radiusv));
	js.Browser.window.requestAnimationFrame(Test.update);
	return true;
}
var js = {}
js.Boot = function() { }
js.Boot.__name__ = true;
js.Boot.__string_rec = function(o,s){
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Browser = function() { }
js.Browser.__name__ = true;
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i){
	return isFinite(i);
};
Math.isNaN = function(i){
	return isNaN(i);
};
String.__name__ = true;
Array.__name__ = true;
CircleTools = (function(std, ext, heap) {"use asm";function _a(r) {r = +r;return +(+3.14159265359*r*r);}function _b(r) {r = +r;return +(2.0*+3.14159265359*r);}function init() {}return {__init__: init, area: _a, circ: _b};})(window,{ },new ArrayBuffer(4096));
CircleTools.__init__();
js.Browser.window = typeof window != "undefined" ? window : null;
js.Browser.document = typeof window != "undefined" ? window.document : null;
Test.main();
})();
