(function () { "use strict";
var llhx = {}
llhx.LowLevel = function() { }
var Testy = function() { }
Testy.__interfaces__ = [llhx.LowLevel];
Testy.getGenerated = function() {
	var o = (function(std, ext, heap) {"use asm";function _a() {ext._b(ext._c());}function init() {}return {run: _a, __init__: init};})(js.Browser.window,{ _b : ($_=js.Browser.window,$bind($_,$_.alert)), _c : function() {
		return Math.PI;
	}},new ArrayBuffer(4096));
	o.__init__();
	return o;
}
var Test = function() { }
Test.main = function() {
	var t = Testy.getGenerated();
	t.run();
}
var js = {}
js.Browser = function() { }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; };
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
js.Browser.window = typeof window != "undefined" ? window : null;
Test.main();
})();
