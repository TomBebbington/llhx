@:build(asm.Asm.gen()) class Testy {
	public static function square(n:Float):Float {
		return n * n;
	}
	public static function diag(x:Float, y:Float):Float {
		return Math.sqrt(Math.pow(x, 2.0) + Math.pow(y, 2.0));
	}
}
/* Successfully compiled code should look like this:
(function(std, ext, heap) {
	"use asm";
	var _c = std.Math.sqrt;
	var _d = std.Math.pow;
	function _a(n) {
		n = +n;
		return +(n*n);
	}
	function _b(x, y) {
		x = +x;
		y = +y;
		return +_c(+_d(+x, +2)+_d(+y, +2));
	}
	return {square: _a, diag: _b};;
})(window);
*/
class Test {
	public static function main() {
		var comp = Testy.asm();
		while(true) {
			var a = Std.parseFloat(js.Browser.window.prompt("X", "3"));
			var b = Std.parseFloat(js.Browser.window.prompt("Y", "4"));
			js.Browser.window.alert('Diagonal: ${comp.diag(a, b)}');
		}
	}
}