@:build(asm.Asm.gen()) class Testy {
	public static function fib(d:Int):Float {
		var a = 2, b = 5, c = 6;
		return a + b - c + d;
	}
}
class Test {
	public static function main() {
		var comp = Testy.asm();
		while(true) {
			var a = Std.parseFloat(js.Browser.window.prompt("Number", "3"));
			js.Browser.window.alert('Diagonal: ${comp.fib(a)}');
		}
	}
}