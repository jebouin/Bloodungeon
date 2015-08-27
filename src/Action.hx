package ;
import com.xay.util.SpriteLib;
import com.xay.util.Util;
import flash.display.Bitmap;
import flash.display.BitmapData;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Linear;
class Action {
	static var rocks : Array<Bitmap> = [];
	public static function init() {
		var wids = [16, 13, 16];
		var heis = [13, 13, 14];
		for(i in 0...20) { //5 on top, 15 on exit
			var id = i % 3;
			var bd = new BitmapData(wids[id], heis[id], true, 0x0);
			SpriteLib.copyFramePixelsFromSlice(bd, "rock" + Std.string(id), 0, 0, 0);
			var r = new Bitmap(bd);
			rocks.push(r);
		}
	}
	public static function onFloor0() {
		for(r in rocks) {
			if(r.parent != null) {
				r.parent.removeChild(r);
			}
		}
		var bx = 36 * 16 + 8;
		var by = 28 * 16;
		for(i in 0...5) {
			var r = rocks[i];
			r.x = bx + Util.randFloat(-5, 5) - r.width * .5;
			r.y = by + i * 6;
			Game.CUR.lm.addChild(r, Const.BACK_L);
		}
		Game.CUR.level.setCollision(36, 28, FULL);
		Game.CUR.level.setCollision(36, 29, FULL);
	}
	public static function onFloor1() {
		for(r in rocks) {
			if(r.parent != null) {
				r.parent.removeChild(r);
			}
		}
	}
	public static function teleport() {
		
	}
	public static function shake0() {
		Fx.screenShake(1., 1., 1000000., true);
		Timer.delay(function() {
			Game.CUR.hero.say("wtf", 100);
		}, 400);
		Audio.playSound("noise0", true);
		Audio.stopMusics(5.);
	}
	public static function shake1() {
		Fx.screenShake(2., 2., 1000000., true);
		Timer.delay(function() {
			Game.CUR.hero.say("!!!", 100);
		}, 300);
		Audio.stopSound("noise0");
		Audio.playSound("noise1", true);
	}
	public static function talkExit() {
		Story.talkExit = true;
	}
	public static function closeExit() {
		Game.CUR.level.closeExit();
		Audio.stopSound("noise1");
		Audio.playSound("rocks");
		var bx = 42 * 16 + 9;
		var by = 30 * 16;
		var ey = 33 * 16 + 16;
		for(i in 0...5) {
			rocks[i].parent.removeChild(rocks[i]);
		}
		for(i in 5...20) {
			var r = rocks[i];
			r.x = bx + Util.randFloat(-6, 6) - r.width * .5;
			r.y = by + (ey - by) * (i - 5) / 15 - r.height * .5;
			Game.CUR.lm.addChild(r, [Const.FRONT_L, Const.BACK_L][Std.random(2)]);
		}
		Game.CUR.level.setCollision(36, 28, NONE);
		Game.CUR.level.setCollision(36, 29, NONE);
		Story.talkExit = false;
	}
	public static function warp() {
		Game.CUR.hero.warp();
		Audio.playSound("warp");
		Audio.stopMusics(1.);
		Game.canPause = false;
		Game.CUR.cd.deactivate();
		Game.CUR.level.warp.activate();
		Timer.delay(function() {
			Game.canPause = true;
			Game.CUR.nextFloor();
			Game.CUR.cd.activate();
		}, 6000);
		Fx.screenShake(1., 1., 100000, true);
	}
	public static function exitFloor0() {
		Game.CUR.onExitFloor0();
	}
	public static function exitFloor1() {
		var h = Game.CUR.hero;
		if(h.nbDeaths == h.nbDeathBeforeFloor) {
			Achievements.unlock("Phrygian warrior");
		}
		warp();
	}
	public static function exitFloor2() {
		var h = Game.CUR.hero;
		if(h.nbDeaths == h.nbDeathBeforeFloor) {
			Achievements.unlock("Icy hell");
		}
		warp();
	}
	public static function lastRush() {
		Game.CUR.startRush();
	}
	public static function endScene() {
		Game.CUR.cd.deactivate();
		Game.CUR.cd.visible = false;
		Audio.stopMusics(1.);
		Timer.delay(function() {
			Audio.playMusic(7, 2.);
		}, 800);
		Game.CUR.hero.say("!", 120);
		var b = Game.CUR.badger;
		var h = Game.CUR.hero;
		Actuate.tween(h, 1.5, {yy:h.yy-30}).ease(Linear.easeNone).onComplete(function() {
			h.locked = false;
			h.anim.setFrame(4);
			h.update();
			h.locked = true;
		}).onUpdate(function() {
			h.y = h.yy - 2;
			h.shadow.y = h.y + 4;
		});
		Timer.delay(function() {
			b.setAnim("badgerFront", false);
			b.anim.play();
			b.yy += 10;
			b.say("!", 120);
			Timer.delay(function() {
				b.say("I...", 50);
				Timer.delay(function() {
					b.say("I, huh", 50);
					Timer.delay(function() {
						b.say("I can explain...", 160);
						Timer.delay(function() {
							h.say("...", 120);
							Timer.delay(function() {
								b.vx = 2.;
								b.setAnim("badgerSide", true);
								b.anim.play();
								h.locked = false;
							}, 1000);
						}, 900);
					}, 1000);
				}, 800);
			}, 2000);
		}, 2000);
	}
	public static function theEnd() {
		Game.CUR.complete();
	}
}