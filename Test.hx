@:build(llhx.Generator.gen()) class Testy {
	static var a = [34, 245, 32, 54];
	public static function root(n:Int):Int {
		var b = [2, 3, 5];
		return a[n];
	}
}
class Test {
	public static function main() {
		var t = Testy.getGenerated();
		while(true) {
			var a = Std.parseInt(js.Browser.window.prompt("Number", "3"));
			js.Browser.window.alert(Std.string(t.root(a)));
		}
	}
}