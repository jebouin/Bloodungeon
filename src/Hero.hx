package ;
import com.xay.util.Input;
class Hero extends Entity {
	public var hooverTimer : Int;
	public function new() {
		super("heroIdle");
		/*graphics.beginFill(0xFF0000);
		graphics.drawCircle(0, 0, 8);
		graphics.endFill();*/
		Game.CUR.lm.addChild(this, Const.HERO_L);
		maxSpeed = 2.3;
		collides = true;
		xx = Game.CUR.level.startX;
		yy = Game.CUR.level.startY;
		hooverTimer = 0;
		gravity = 0;
		setOrigin(.5, .8);
	}
	override function delete() {
		super.delete();
	}
	override function update() {
		if(locked) return;
		if(Input.keyDown("left")) {
			vx -= speed;
			scaleX = -1;
		}
		if(Input.keyDown("right")) {
			vx += speed;
			scaleX = 1;
		}
		if(Input.keyDown("up")) {
			vy -= speed;
		}
		if(Input.keyDown("down")) {
			vy += speed;
		}
		if(Input.oldKeyDown("action")) {
			jump();
		}
		super.update();
		var level = Game.CUR.level;
		if(xx > level.posX + Level.RWID * 16 - 8) {
			Game.CUR.nextRoom(1, 0);
		}
		if(xx < level.posX + 8) {
			Game.CUR.nextRoom(-1, 0);
		}
		if(yy > level.posY + Level.RHEI * 16 - 8) {
			Game.CUR.nextRoom(0, 1);
		}
		if(yy < level.posY + 8) {
			Game.CUR.nextRoom(0, -1);
		}
		hooverTimer++;
		zz = 2 + Math.sin(hooverTimer * .2) * 2;
	}
}