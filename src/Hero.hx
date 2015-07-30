package ;
import com.xay.util.Input;
class Hero extends Entity {
	public function new() {
		super();
		graphics.beginFill(0xFF0000);
		graphics.drawCircle(0, 0, 8);
		graphics.endFill();
		Game.CUR.lm.addChild(this, Const.HERO_L);
	}
	override function delete() {
		super.delete();
	}
	override function update() {
		if(Input.keyDown("left")) {
			vx -= 1.5;
		}
		if(Input.keyDown("right")) {
			vx += 1.5;
		}
		if(Input.keyDown("up")) {
			vy -= 1.5;
		}
		if(Input.keyDown("down")) {
			vy += 1.5;
		}
		if(Input.oldKeyDown("action")) {
			jump();
		}
		super.update();
	}
}