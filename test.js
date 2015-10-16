(function (console) { "use strict";
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var llhx_LowLevel = function() { };
llhx_LowLevel.__name__ = true;
var CircleTools = function() { };
CircleTools.__name__ = true;
CircleTools.__interfaces__ = [llhx_LowLevel];
var Test = function() { };
Test.__name__ = true;
Test.main = function() {
	Test.lastVal = 0;
	if(window.mozRequestAnimationFrame != null) window.requestAnimationFrame = window.mozRequestAnimationFrame;
	window.addEventListener("load",function(_) {
		Test.radius = window.document.getElementById("radius");
		Test.area = window.document.getElementById("area");
		Test.circ = window.document.getElementById("circ");
		window.requestAnimationFrame(Test.update);
		console.log(CircleTools.factorial(10));
	});
};
Test.update = function(d) {
	var radiusv = parseFloat(Test.radius.value);
	if(radiusv == Test.lastVal) return true;
	Test.area.value = Std.string(CircleTools.area(radiusv));
	Test.circ.value = Std.string(CircleTools.circ(radiusv));
	window.requestAnimationFrame(Test.update);
	return true;
};
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
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
};
String.__name__ = true;
Array.__name__ = true;
CircleTools = (function(std, ext, heap) {"use asm";function _a(num) {num = num|0;var product = 1|0;{var i = 2|0;while(i<num){product*=i|0;i++;};};return product|0;}function _b(r) {r = +r;return +(+3.14159265358979312*r*r);}function _c(r) {r = +r;return +(2.0*+3.14159265358979312*r);}function init() {}return {__init__: init, factorial: _a, area: _b, circ: _c};})(window,{ },new ArrayBuffer(4096));
CircleTools.__init__();
Test.main();
})(typeof console != "undefined" ? console : {log:function(){}});
