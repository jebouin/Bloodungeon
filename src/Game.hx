package ;
import com.xay.util.GJAPI;
import com.xay.util.Input;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager;
import flash.display.Shape;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Sine;
class Game extends Scene {
	public static var CUR : Game;
	public static var skipStory : Bool;
	public static var yoloMode : Bool;
	public static var continueGame : Bool;
	public static var canPause : Bool;
	public static var curGameTime : Int;
	public var lm : LayerManager;
	public var frontlm : LayerManager;
	public var entities : Array<Entity>;
	public var level : Level;
	public var hero : Hero;
	public var badger : Badger;
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
		FakeTile.brokens = [false, false, false, false, false, false];
		var floorId = 0;
		if(continueGame) {
			floorId = Save.so.data.floorId;
			curGameTime = Save.so.data.curGameTime;
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
		curGameTime = 0;
		if(Save.so.data.isRush) {
			startRush();
		}
		canPause = true;
		if(!skipStory && !continueGame) {
			Story.start();
			Action.onFloor0();
		}
		if(continueGame && Save.so.data.isRush) {
			startRush(true);
		}
		if(yoloMode && !continueGame) {
			Hero.prevRoomDir = null;
		}
	}
	override public function delete() {
		Save.onQuitGame();
		Particle.deleteAll();
		lm.delete();
		frontlm.delete();
		clearEntities();
		CUR = null;
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
		if(Input.newKeyPress("escape") && !Main.secondUpdate) {
			pause();
		}
		Stats.gameTime++;
		curGameTime++;
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
	public function onHeroDeath(fell:Bool=false) {
		if(Level.LAST_ROOM) {
			Achievements.unlock("I can do that too");
		}
		if(yoloMode) {
			continueGame = false;
			Save.so.data.hasSave = false;
			Save.so.flush();
		}
		respawnTimer = fell ? 30 : 60;
	}
	public function respawn() {
		if(yoloMode && hero.dead) {
			var g = new GameOver();
			g.onDelete = function() {
				delete();
			};
		} else {
			hero.spawn();
			Enemy.fade = false;
			level.reloadEntities();
		}
	}
	public function nextFloor() {
		if(level.floor == 1) {
			GJAPI.sendHiscore(hero.nbDeaths, 93249, Std.string(curGameTime));
		} else if(level.floor == 2) {
			GJAPI.sendHiscore(hero.nbDeaths, 93250, Std.string(curGameTime));
		}
		level.nextFloor();
		hero.nbDeathBeforeFloor = hero.nbDeaths;
	}
	public function startRush(?isLoading=false) {
		Audio.playMusic(4);
		if(!isLoading) Save.onRush();
	}
	public function onFocusOut() {
		pause();
	}
	public function onFocusIn() {
		
	}
	public function onLastRoom() {
		badger = new Badger();
		badger.roomId = Level.ROOMID;
		entities.push(badger);
	}
	function pause() {
		if(canPause) {
			canPause = false;
			Audio.setMusicVolume(.2, .5);
			var p = new Pause();
			p.onDelete = function() {
				canPause = true;
				Audio.setMusicVolume(1., .5);
			}
		}
	}
	public function complete() {
		Achievements.unlock("I did it!");
		if(yoloMode) {
			Timer.delay(function() {
				Achievements.unlock("Survivor");
			}, 6000);
		}
		canPause = false;
		GJAPI.sendHiscore(hero.nbDeaths, 90637, Std.string(curGameTime));
		Save.so.data.hasSave = false;
		hero.update();
		hero.anim.setFrame(2);
		hero.anim.update();
		hero.locked = true;
		locked = true;
		Actuate.tween(hero, 1.5, {y:-18}).onComplete(function() {
			var back = new Shape();
			back.graphics.beginFill(0xFFFFFF);
			back.graphics.drawRect(0, 0, Const.WID, Const.HEI);
			back.graphics.endFill();
			frontlm.addChild(back, 100);
			back.alpha = 0.;
			Audio.stopMusics(1.5);
			Actuate.tween(back, 3.5, {alpha:1.}).ease(Linear.easeNone).onComplete(function() {
				var e = new Ending(back, hero.nbDeaths);
				e.onDelete = onDelete;
				onDelete = null;
				delete();
			});
		}).ease(Linear.easeNone).onUpdate(function() {
			hero.shadow.y = hero.y + 2.;
		});
	}
}