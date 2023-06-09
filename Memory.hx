package;

using api.IdeckiaApi;

typedef Props = {
	@:editable("Rows", 3)
	var rows:UInt;
	@:editable("Columns", 3)
	var columns:UInt;
	@:editable("Item text size", 30)
	var item_text_size:UInt;
	@:editable("Name of the parent directory", {
		toDir: "_main_",
		text: "back",
		textSize: null,
		textColor: null,
		textPosition: null,
		icon: "folder",
		bgColor: "ffff0000"
	})
	var parent_dir_state:{
		toDir:String,
		text:String,
		textSize:UInt,
		textColor:String,
		textPosition:TextPosition,
		icon:String,
		bgColor:String
	};
}

@:name("memory")
@:description("A memory game")
class Memory extends IdeckiaAction {
	static var BACK = Macros.getImageData('back.jpg');
	static inline var MATCH_COLOR = 'ff009900';

	var flipped = [];
	var values = [];
	var matched = [];
	var childActions:Map<UInt, ItemState->Void> = [];

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		getImageData('back.jpg');
		return super.init(initialState);
	}

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		var items:Array<DynamicDirItem> = [];
		var numValues = props.rows * props.columns - 2;
		if (numValues % 2 == 1)
			numValues++;
		numValues = Std.int(numValues * .5);

		var nums = [];
		for (n in 0...numValues) {
			nums.push(n);
			nums.push(n);
		}

		var valIndex;

		for (i in 0...numValues * 2) {
			items.push({
				icon: BACK,
				textSize: props.item_text_size,
				actions: [
					{
						name: '_memory-item',
						props: {
							index: values.length,
							initCallback: itemInitCallback,
							executeCallback: itemExecuteCallback
						}
					}
				]
			});
			valIndex = Math.floor(Math.random() * nums.length);
			values.push(nums[valIndex]);
			nums.splice(valIndex, 1);
		}
		if (props.parent_dir_state != null)
			items.unshift(cast props.parent_dir_state);

		var dynamicDir = {
			rows: props.rows,
			columns: props.columns,
			items: items
		}
		return new js.lib.Promise((resolve, reject) -> resolve(new ActionOutcome({directory: dynamicDir})));
	}

	function itemInitCallback(index:UInt, updateItemState:ItemState->Void) {
		if (childActions.exists(index))
			return;
		childActions.set(index, updateItemState);
	}

	function itemExecuteCallback(index:UInt, state:ItemState):js.lib.Promise<ActionOutcome> {
		if (!matched.contains(index)) {
			if (flipped.length == 2 && flipped.contains(index)) {
				flipped.remove(index);
				state.icon = BACK;
				state.text = '';
			} else if (flipped.length < 2) {
				state.icon = null;
				state.text = Std.string(values[index]);
				if (values[flipped[0]] == values[index]) {
					matched.push(flipped[0]);
					matched.push(index);
					childActions.get(flipped[0])({
						icon: null,
						text: Std.string(values[flipped[0]]),
						bgColor: MATCH_COLOR
					});
					childActions.get(index)({
						icon: null,
						text: Std.string(values[index]),
						bgColor: MATCH_COLOR
					});
					flipped = [];
				} else {
					flipped.push(index);
				}
			}
			if (matched.length == values.length) {
				server.dialog.info('Congratulations!', 'You matched all the pairs!');
			}
		}

		return js.lib.Promise.resolve(new ActionOutcome({state: state}));
	}

	public static function getImageData(name:String) {
		var filePath:String = haxe.io.Path.join([js.Node.__dirname, name]);

		if (sys.FileSystem.exists(filePath))
			BACK = haxe.crypto.Base64.encode(sys.io.File.getBytes(filePath));
	}
}
