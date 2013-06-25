@:build(llhx.Generator.gen()) class Testy {
	static var a = [34, 245, 32, 54];
	public static function root():Int {
		return a[2];
	}
}
class Test {
	public static function main() {
		var t = Testy.getGenerated();
		while(true) {
			var a = Std.parseInt(js.Browser.window.prompt("Number", "3"));
			js.Browser.window.alert(Std.string(t.root()));
		}
	}
}