package ;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager;
class Game extends Scene {
	public static var CUR : Game;
	public var lm : LayerManager;
	public var frontlm : LayerManager;
	public var entities : Array<Entity>;
	public var level : Level;
	public function new() {
		super();
		CUR = this;
		lm = new LayerManager();
		frontlm = new LayerManager();
		Main.renderer.addChild(frontlm.getContainer());
		Main.renderer.addChild(lm.getContainer());
		level = new Level();
		entities = [];
		entities.push(new Hero());
	}
	override public function delete() {
		super.delete();
		lm.delete();
		frontlm.delete();
		clearEntities();
	}
	override public function update() {
		super.update();
		for(e in entities) {
			e.update();
		}
	}
	public function clearEntities() {
		for(e in entities) {
			e.delete();
		}
	}
}