package ;
import com.xay.util.Input;
import com.xay.util.Util;
import haxe.Timer;
import motion.Actuate;
class Hero extends Entity {
	public var hooverTimer : Int;
	public static var spawnX : Float;
	public static var spawnY : Float;
	var targetFrame : Int;
	var turnTimer : Int;
	public var prevRoomDir : Const.DIR;
	var immune : Bool;
	public function new() {
		super("heroIdle");
		anim.playing = false;
		/*graphics.beginFill(0xFF0000);
		graphics.drawCircle(0, 0, 8);
		graphics.endFill();*/
		Game.CUR.lm.addChild(this, Const.HERO_L);
		maxSpeed = 2.3;
		collides = true;
		cradius = 4;
		spawn();
		hooverTimer = 0;
		turnTimer = 1000;
		gravity = 0;
		setOrigin(.5, .6);
		prevRoomDir = null;
		shadow.scaleX *= .8;
		shadow.scaleY *= .5;
		shadow.alpha *= .4;
		targetFrame = anim.getFrame();
		//immune = true;
	}
	public function spawn() {
		xx = spawnX;
		yy = spawnY;
		vx = vy = 0;
		visible = shadow.visible = true;
		locked = false;
		dead = false;
		scaleX = scaleY = 1;
		parent.removeChild(this);
		Game.CUR.lm.addChild(this, Const.HERO_L);
		setLightPos(xx, yy);
		update();
		Game.CUR.cd.reset();
		//set dir
	}
	override function delete() {
		super.delete();
	}
	override function update() {
		if(!locked) {
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
			/*if(Input.oldKeyDown("action")) {
				jump();
			}*/
			if(Input.oldKeyDown("suicide")) {
				var prevImmune = immune;
				immune = false;
				die();
				immune = prevImmune;
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
			shadow.rotation = frame * 45;
		}
		updateLight();
	}
	override public function die() {
		if(dead || immune) return;
		visible = shadow.visible = false;
		dead = true;
		locked = true;
		Timer.delay(function() {
			Game.CUR.onRespawn();
			spawn();
		}, 500);
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
		Game.CUR.nextRoom(dir);
	}
	function updateLight() {
		var level = Game.CUR.level;
		var lx = level.light.x;
		var ly = level.light.y;
		var rlx = lx - Game.CUR.lm.getContainer().x;
		var rly = ly - Game.CUR.lm.getContainer().y;
		setLightPos(rlx + (xx - rlx) * .3, rly + (yy - rly) * .3);
		level.light.scaleX = level.light.scaleY = 1. + .05 * Math.sin(hooverTimer * .1);
		level.light2.scaleX = level.light2.scaleY = 1. + .05 * Math.sin(hooverTimer * .1 + .6);
	}
	public function setLightPos(lx:Float, ly:Float) {
		var light = Game.CUR.level.light;
		var light2 = Game.CUR.level.light2;
		light.x = light2.x = lx + Game.CUR.lm.getContainer().x;
		light.y = light2.y = ly + Game.CUR.lm.getContainer().y;
	}
}