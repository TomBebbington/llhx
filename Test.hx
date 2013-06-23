@:build(asm.Asm.gen()) class Testy {
	public static function square(n:Float):Float {
		return n * n;
	}
	public static function diag(x:Float, y:Float):Float {
		return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
	}
}
class Test {
	public static function main() {
		var comp = Testy.asm();
		trace(comp.square(56));
	}
}