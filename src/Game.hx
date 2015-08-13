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
	public var cd : Countdown;
	var locked : Bool;
	public function new() {
		super();
		CUR = this;
		lm = new LayerManager();
		frontlm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		Main.renderer.addChild(frontlm.getContainer());
		entities = [];
		level = new Level();
		hero = new Hero();
		entities.push(hero);
		cd = new Countdown();
		locked = false;
	}
	override public function delete() {
		super.delete();
		lm.delete();
		frontlm.delete();
		clearEntities();
	}
	override public function update() {
		super.update();
		if(locked) {
			hero.update();
			Torch.updateAll();
		} else {
			level.update();
			var toDelete = [];
			for(e in entities) {
				e.update();
				if(e.deleted) {
					toDelete.push(e);
				}
			}
			for(e in toDelete) {
				entities.remove(e);
			}
			level.checkActions();
			cd.update();
		}
	}
	public function addEntity(e:Entity) {
		entities.push(e);
	}
	public function clearEntities(keepHero:Bool = false) {
		for(s in Spike.ALL) {
			if(s.timer != null) {
				s.timer.stop();
				s.timer = null;
			}
		}
		for(e in entities) {
			if(!keepHero || e != hero) {
				e.delete();
			}
		}
		entities = [];
		if(keepHero) {
			entities.push(hero);
		}
	}
	public function moveCameraTo(x:Float, y:Float, t=.5, onEnd:Dynamic=null) {
		Actuate.tween(lm.getContainer(), t, {x:-x, y:-y}).onComplete(onEnd).ease(Quad.easeOut);
	}
	public function nextRoom(dir:Const.DIR) {
		level.nextRoom(dir);
		cd.reset();
	}
	public function lock() {
		locked = true;
		cd.lock();
		for(e in entities) {
			e.locked = true;
		}
	}
	public function unlock() {
		locked = false;
		cd.unlock();
		for(e in entities) {
			e.locked = false;
		}
	}
	public function onRespawn() {
		Enemy.fade = false;
		level.reloadEntities();
	}
}