import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

class Macros {
	public static macro function getImageData(filename:String):ExprOf<String> {
		// get the path of the current current class file, e.g. "src/path/to/MyClassName.hx"
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);

		var filePath:String = Path.join([directory, filename]);

		if (FileSystem.exists(filePath)) {
			var content = File.getBytes(filePath);
			return macro $v{haxe.crypto.Base64.encode(content)};
		} else {
			return macro null;
		}
	}
}
