@:build(asm.Asm.gen()) class Testy {
	public static function diag(b:Int):Float {
		var a = 0;
		for(i in 1...b)
			a += b;
		return a;
	}
}
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