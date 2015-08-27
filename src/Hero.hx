package ;
import com.xay.util.Input;
import com.xay.util.Util;
import com.xay.util.XSprite;
import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.text.TextField;
import haxe.format.JsonPrinter;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Cubic;
import motion.easing.Elastic;
class Hero extends Entity {
	public var hooverTimer : Int;
	public static var spawnX : Float;
	public static var spawnY : Float;
	public static var warpX : Float;
	public static var warpY : Float;
	public var nbDeaths : Int;
	public var nbDeathsBeforeRoom : Int;
	public var nbDeathBeforeFloor : Int;
	var deathCounter : Bitmap;
	var targetFrame : Int;
	var turnTimer : Int;
	public static var prevRoomDir : Const.DIR;
	var immune : Bool;
	public var fell : Bool;
	var explosion : XSprite;
	var warping : Bool;
	var warpTimer : Int;
	public function new() {
		super("heroIdle");
		anim.playing = false;
		Game.CUR.lm.addChild(this, Const.HERO_L);
		maxSpeed = 2.3;
		collides = true;
		cradius = 4;
		explosion = new XSprite("explosion", false);
		explosion.anim.stop();
		explosion.visible = false;
		spawn();
		hooverTimer = 0;
		turnTimer = 1000;
		gravity = 0;
		setOrigin(.5, .6);
		shadow.scaleX *= .8;
		shadow.scaleY *= .5;
		shadow.alpha *= .4;
		targetFrame = anim.getFrame();
		nbDeaths = nbDeathBeforeFloor = nbDeathsBeforeRoom = 0;
		if(Game.continueGame) {
			nbDeaths = Save.so.data.deaths;
		}
		deathCounter = new Bitmap();
		Game.CUR.frontlm.addChild(deathCounter, 0);
		deathCounter.visible = false;
		//immune = true;
	}
	public function spawn() {
		xx = spawnX;
		yy = spawnY;
		vx = vy = 0;
		visible = shadow.visible = true;
		explosion.visible = false;
		locked = false;
		dead = false;
		fell = false;
		scaleX = scaleY = 1;
		parent.removeChild(this);
		Game.CUR.lm.addChild(this, Const.HERO_L);
		setLightPos(xx, yy);
		Game.CUR.cd.reset();
		warping = false;
		warpTimer = 0;
		zz = 0;
		update();
		//set dir
	}
	override function delete() {
		super.delete();
	}
	override function update() {
		if(explosion.parent != null) {
			explosion.update();
		}
		if(Game.CUR.respawnTimer > 0) {
			return;
		}
		if(fell) return;
		if(warping) {
			warpTimer++;
			var frame = anim.getFrame();
			var t = warpTimer;
			if(warpTimer < 100) {
				if(warpTimer & 7 == 0) {
					frame++;
				}
				zz += .05;
			} else if(warpTimer < 150) {
				if(warpTimer & 3 == 0) {
					frame++;
				}
				zz += .1;
			} else if(warpTimer < 248) {
				frame++;
				zz += .42;
			} else if(warpTimer == 248) {
				visible = shadow.visible = false;
				Fx.beam(xx, yy);
				Game.CUR.level.warp.deactivate();
			}
			if(frame == 8) frame = 0;
			anim.setFrame(frame);
			xx += (warpX - xx) * .1;
			yy += (warpY - yy) * .1;
			super.update();
			updateShadow();
		} else if(!locked) {
			if(!Story.active) {
				var curSpeed = onIce ? speed * .05 : speed;
				if(Input.keyDown("left")) {
					vx -= curSpeed;
					targetFrame = 4;
				}
				if(Input.keyDown("right")) {
					vx += curSpeed;
					targetFrame = 0;
				}
				if(Input.keyDown("up")) {
					vy -= curSpeed;
					targetFrame = 6;
					if(Input.keyDown("left")) {
						targetFrame--;
					} else if(Input.keyDown("right")) {
						targetFrame++;
					}
				}
				if(Input.keyDown("down")) {
					vy += curSpeed;
					targetFrame = 2;
					if(Input.keyDown("left")) {
						targetFrame++;
					} else if(Input.keyDown("right")) {
						targetFrame--;
					}
				}
				if(!Input.keyDown("left") && !Input.keyDown("right") && !Input.keyDown("down") && !Input.keyDown("up")) {
					targetFrame = -1;
				}
				/*if(Input.keyDown("suicide") && !Input.oldKeyDown("suicide")) {
					var prevImmune = immune;
					immune = false;
					die();
					immune = prevImmune;
				}*/
			}
			super.update();
			var level = Game.CUR.level;
			if(xx > level.posX + Level.RWID * 16 - 8 && prevRoomDir != LEFT) {
				goToNextRoom(RIGHT);
			}
			if(xx < level.posX + 8 && prevRoomDir != RIGHT) {
				goToNextRoom(LEFT);
			}
			if(yy > level.posY + Level.RHEI * 16 - 8 && prevRoomDir != UP) {
				goToNextRoom(DOWN);
			}
			if(yy < level.posY + 8 && prevRoomDir != DOWN) {
				goToNextRoom(UP);
			}
			hooverTimer++;
			turnTimer++;
			zz = 4.5 + Math.sin(hooverTimer * .2) * 1.5;
			if(onIce) {
				zz = 0;
			}
			var frame = anim.getFrame();
			if(frame != targetFrame && turnTimer > 4 && targetFrame != -1) {
				turnTimer = 0;
				if(frame < targetFrame) {
					if(frame + 8 - targetFrame < targetFrame - frame) {
						frame--;
					} else {
						frame++;
					}
				} else {
					if(frame - targetFrame < targetFrame + 8 - frame) {
						frame--;
					} else {
						frame++;
					}
				}
				if(frame < 0) frame += 8;
				if(frame >= 8) frame -= 8;
				anim.setFrame(frame);
			}
			updateShadow();
		}
		updateLight();
	}
	override public function die(?dx=0., ?dy=0.) {
		if(dead || immune) return;
		visible = shadow.visible = false;
		dead = true;
		locked = true;
		nbDeaths++;
		Stats.totalDeaths++;
		Save.onDeath();
		showDeaths();
		if(zz >= 0) {
			Audio.playSound("explosion");
			Fx.heroDeath(xx, yy, dx, dy);
			explosion.visible = true;
			explosion.setAnim("explosion", false);
			explosion.anim.play();
			explosion.x = xx - 5;
			explosion.y = yy - 8;
			Game.CUR.lm.addChild(explosion, Const.FRONT_L);
			explosion.anim.onEnd = function() {
				explosion.visible = false;
				explosion.parent.removeChild(explosion);
			}
		}
		Game.CUR.onHeroDeath(fell);
	}
	function showDeaths() {
		if(deathCounter.bitmapData != null) {
			deathCounter.bitmapData.dispose();
		}
		deathCounter.bitmapData = Main.font.getText(Std.string(nbDeaths) + " death" + (nbDeaths==1 ? "" : "s"), -1, false, false, 1);
		var bd = deathCounter.bitmapData;
		bd.applyFilter(bd, bd.rect, new Point(0, 0), new DropShadowFilter(1., 0, 0, 1., 0., 0.));
		bd.applyFilter(bd, bd.rect, new Point(0, 0), new DropShadowFilter(1., 90, 0, 1., 0., 0.));
		bd.applyFilter(bd, bd.rect, new Point(0, 0), new DropShadowFilter(1., 180, 0, 1., 0., 0.));
		bd.applyFilter(bd, bd.rect, new Point(0, 0), new DropShadowFilter(1., 270, 0, 1., 0., 0.));
		deathCounter.x = Const.WID + 4;
		deathCounter.y = 8;
		deathCounter.visible = true;
		deathCounter.alpha = 1.;
		Actuate.tween(deathCounter, .4, {x:Const.WID - deathCounter.width - 11}).ease(Elastic.easeOut);
		Actuate.tween(deathCounter, 1., {alpha:0}).ease(Cubic.easeIn).onComplete(function() {
			deathCounter.visible = false;
		});
	}
	public function computeSpawnPos(horizontal:Bool) {
		var tx = Std.int(xx / 16);
		var ty = Std.int(yy / 16);
		var dx = horizontal?1:0;
		var dy = horizontal?0:1;
		var sx = tx, ex = tx;
		var sy = ty, ey = ty;
		while(Game.CUR.level.getCollision(sx, sy) != FULL && Game.CUR.level.getCollision(sx, sy) != HOLE && tx - sx < 10 && ty - sy < 10) {
			sx -= dx;
			sy -= dy;
		}
		while(Game.CUR.level.getCollision(ex, ey) != FULL && Game.CUR.level.getCollision(sx, sy) != HOLE && ex - tx < 10 && ey - ty < 10) {
			ex += dx;
			ey += dy;
		}
		var stx = (sx + ex) * .5;
		var sty = (sy + ey) * .5;
		spawnX = stx * 16 + 8;
		spawnY = sty * 16 + 8;
		if(prevRoomDir == Const.DIR.DOWN) {
			spawnY += 8;
		}
	}
	function goToNextRoom(dir:Const.DIR) {
		prevRoomDir = dir;
		vx = vy = 0;
		nbDeathsBeforeRoom = nbDeaths;
		Game.CUR.nextRoom(dir);
		if(Game.CUR.level.floor > 0) {
			Save.onNextRoom(Game.CUR.level.floor, Game.CUR.level.roomIdX, Game.CUR.level.roomIdY, spawnX, spawnY, dir);
		}
	}
	function updateLight() {
		var level = Game.CUR.level;
		var lx = level.light.x;
		var ly = level.light.y;
		var rlx = lx - Game.CUR.lm.getContainer().x;
		var rly = ly - Game.CUR.lm.getContainer().y;
		setLightPos(rlx + (xx - rlx) * .3, rly + (yy - rly) * .3);
		if(!Actuate.isActive()) {
			level.light.scaleX = level.light.scaleY = 1. + .05 * Math.sin(hooverTimer * .1 + .4);
			level.light2.scaleX = level.light2.scaleY = 1. + .05 * Math.sin(hooverTimer * .1 + .6 + .4);
		}
	}
	function updateShadow() {
		shadow.rotation = anim.getFrame() * 45;
	}
	public function setLightPos(lx:Float, ly:Float) {
		var light = Game.CUR.level.light;
		var light2 = Game.CUR.level.light2;
		light.x = light2.x = lx + Game.CUR.lm.getContainer().x;
		light.y = light2.y = ly + Game.CUR.lm.getContainer().y;
	}
	override public function fall() {
		locked = true;
		fell = true;
		Audio.playSound("fall");
		super.fall();
	}
	public function warp() {
		warping = true;
	}
}