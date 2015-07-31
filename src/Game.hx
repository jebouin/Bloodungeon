package ;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.Quad;
import motion.easing.Sine;
class Game extends Scene {
	public static var CUR : Game;
	public var lm : LayerManager;
	public var frontlm : LayerManager;
	public var entities : Array<Entity>;
	public var level : Level;
	public var hero : Hero;
	public function new() {
		super();
		CUR = this;
		lm = new LayerManager();
		frontlm = new LayerManager();
		Main.renderer.addChild(frontlm.getContainer());
		Main.renderer.addChild(lm.getContainer());
		level = new Level();
		entities = [];
		hero = new Hero();
		entities.push(hero);
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
	public function moveCameraTo(x:Float, y:Float, t=.5, onEnd:Dynamic=null) {
		Actuate.tween(lm.getContainer(), t, {x:-x, y:-y}).onComplete(onEnd).ease(Quad.easeOut);
	}
}