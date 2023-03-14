package;

using api.IdeckiaApi;

typedef Props = {
	var index:UInt;
	var initCallback:UInt->(ItemState->Void)->Void;
	var executeCallback:UInt->ItemState->js.lib.Promise<ActionOutcome>;
}

@:name("memory-item")
@:description("A memory game item")
class MemoryItem extends IdeckiaAction {
	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		props.initCallback(props.index, server.updateClientState);
		return super.init(initialState);
	}

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return props.executeCallback(props.index, currentState);
	}
}
