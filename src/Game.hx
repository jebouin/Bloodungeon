package ;
import com.xay.util.Input;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.Quad;
import motion.easing.Sine;
class Game extends Scene {
	public static var CUR : Game;
	public static var skipStory : Bool;
	public static var yoloMode : Bool;
	public static var continueGame : Bool;
	public static var canPause : Bool;
	public var lm : LayerManager;
	public var frontlm : LayerManager;
	public var entities : Array<Entity>;
	public var level : Level;
	public var hero : Hero;
	public var cd : Countdown;
	public var camX : Float;
	public var camY : Float;
	var locked : Bool;
	public var respawnTimer : Int;
	public function new() {
		super();
		CUR = this;
		lm = new LayerManager();
		frontlm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		Main.renderer.addChild(frontlm.getContainer());
		camX = camY = 0;
		cd = new Countdown();
		entities = [];
		FakeTile.nbBroken = 0;
		var floorId = 0;
		if(continueGame) {
			floorId = Save.so.data.floorId;
		} else {
			Save.onStartGame();
			if(skipStory) {
				floorId = 1;
			}
		}
		level = new Level(floorId);
		if(continueGame) {
			Save.continueGame();
			if(Hero.prevRoomDir != null) {
				level.closeRoom(level.roomIdX + Const.getDirX(Const.getOpposite(Hero.prevRoomDir)), level.roomIdY + Const.getDirY(Const.getOpposite(Hero.prevRoomDir)), Hero.prevRoomDir);
			}
		}
		level.loadEntities();
		setCamPos(level.posX, level.posY);
		hero = new Hero();
		entities.push(hero);
		locked = false;
		respawnTimer = 0;
		if(Save.so.data.isRush) {
			startRush();
		}
		canPause = true;
		if(!skipStory && !continueGame) {
			Story.start();
			Action.onFloor0();
		}
	}
	override public function delete() {
		Save.onQuitGame();
		Particle.deleteAll();
		lm.delete();
		frontlm.delete();
		clearEntities();
		CUR = null;
		Audio.playMusic(5);
		super.delete();
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
				//if(respawnTimer > 0 && e == hero) continue;
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
		Dialog.updateAll();
		Fx.update();
		if(Input.newKeyPress("escape")) {
			pause();
		}
		Stats.gameTime++;
		if(respawnTimer > 0) {
			respawnTimer--;
			if(respawnTimer == 0) {
				respawn();
			}
		}
		Story.update();
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
		Fx.stopScreenShake();
		var c = lm.getContainer();
		Actuate.tween(this, t, {camX:x, camY:y}).onUpdate(function() {
			c.x = -camX;
			c.y = -camY;
		}).onComplete(onEnd).ease(Quad.easeOut);
		//Actuate.tween(lm.getContainer(), t, {x:-x, y:-y}).onComplete(onEnd).ease(Quad.easeOut);
	}
	public function setCamPos(cx:Float, cy:Float) {
		camX = cx;
		camY = cy;
		lm.getContainer().x = -camX;
		lm.getContainer().y = -camY;
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
	public function onExitFloor0() {
		var s = new VoiceScene();
		lm.getContainer().parent.removeChild(lm.getContainer());
		frontlm.getContainer().parent.removeChild(frontlm.getContainer());
		s.onDelete = function() {
			Main.renderer.addChild(lm.getContainer());
			Main.renderer.addChild(frontlm.getContainer());
			nextFloor();
		}
	}
	public function onHeroDeath() {
		respawnTimer = 60;
	}
	public function respawn() {
		hero.spawn();
		Enemy.fade = false;
		level.reloadEntities();
	}
	public function nextFloor() {
		level.nextFloor();
		hero.nbDeathBeforeFloor = hero.nbDeaths;
	}
	public function startRush() {
		Audio.playMusic(4);
	}
	public function onFocusOut() {
		pause();
	}
	public function onFocusIn() {
		
	}
	function pause() {
		if(canPause) {
			var p = new Pause();
		}
	}
}