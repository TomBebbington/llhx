class Testy implements llhx.LowLevel {
	public static function run():Float {
		return Math.PI;
	}
}
class Test {
	public static function main() {
		var r = Testy.run();
		trace(r);
	}
}