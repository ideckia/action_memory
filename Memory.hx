package;

using api.IdeckiaApi;

typedef Props = {
	@:editable("prop_rows", 3)
	var rows:UInt;
	@:editable("prop_columns", 3)
	var columns:UInt;
	@:editable("prop_item_text_size", 30)
	var item_text_size:UInt;
}

@:name("memory")
@:description("action_description")
@:localize
class Memory extends IdeckiaAction {
	static var BACK = Data.embedBase64('back.jpg');
	static inline var MATCH_COLOR = 'ff009900';

	var flipped = [];
	var values = [];
	var matched = [];
	var childActions:Map<UInt, ItemState->Void> = [];
	var paused = false;

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		var runtimeBack = core.data.getBase64('back.jpg');
		if (runtimeBack != null)
			BACK = runtimeBack;
		return super.init(initialState);
	}

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		var items:Array<DynamicDirItem> = [];
		paused = false;
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
		if (!paused && !matched.contains(index)) {
			if (flipped.length == 0) {
				state.icon = null;
				state.text = Std.string(values[index]);
				flipped.push(index);
			} else if (flipped.length == 1) {
				if (flipped.contains(index)) {
					flipped.remove(index);
					state.icon = BACK;
					state.text = '';
				} else {
					state.icon = null;
					state.text = Std.string(values[index]);
					flipped.push(index);
				}
			}

			if (flipped.length == 2) {
				var flipped0 = flipped[0];
				var updateChildState0 = childActions.get(flipped0);
				var flipped1 = flipped[1];
				var updateChildState1 = childActions.get(flipped1);
				var currentMatched = values[flipped0] == values[flipped1];
				if (currentMatched) {
					matched.push(flipped0);
					matched.push(flipped1);
					updateChildState0({
						icon: null,
						text: Std.string(values[flipped0]),
						bgColor: MATCH_COLOR
					});
					updateChildState1({
						icon: null,
						text: Std.string(values[flipped1]),
						bgColor: MATCH_COLOR
					});
					flipped = [];
				} else {
					paused = true;
					haxe.Timer.delay(() -> {
						updateChildState0({
							icon: BACK,
							text: ''
						});
						updateChildState1({
							icon: BACK,
							text: ''
						});
						flipped = [];
						paused = false;
					}, 1000);
				}
			}
			if (matched.length == values.length) {
				core.dialog.info(Loc.congrats_title.tr(), Loc.congrats_body.tr());
			}
		}

		return js.lib.Promise.resolve(new ActionOutcome({state: state}));
	}
}
