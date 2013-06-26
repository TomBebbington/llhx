class Testy implements llhx.LowLevel {
	public static function circumference(r:Float):Float {
		return r * Math.PI * 2.0;
	}
}
class Test {
	public static function main() {
		var r = Testy.circumference(10);
		trace(r);
	}
}