import haxe.io.Path;

class ImageData {
	public static macro function embed(filename:String):haxe.macro.Expr.ExprOf<String> {
		// get the path of the current current class file, e.g. "src/path/to/MyClassName.hx"
		var posInfos = haxe.macro.Context.getPosInfos(haxe.macro.Context.currentPos());
		var directory = Path.directory(posInfos.file);

		return macro $v{_get(Path.join([directory, filename]))};
	}

	#if !macro
	public static function get(filename:String) {
		var filePath:String = Path.join([js.Node.__dirname, filename]);

		return _get(filePath);
	}
	#end

	static function _get(filePath:String) {
		return if (sys.FileSystem.exists(filePath)) {
			haxe.crypto.Base64.encode(sys.io.File.getBytes(filePath));
		} else {
			null;
		}
	}
}
