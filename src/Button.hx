package ;
class Button extends Entity {
	var facesRight : Bool;
	var pushed : Bool;
	var tx : Int;
	var ty : Int;
	var onEnd : Dynamic;
	public function new(tx:Int, ty:Int, facesRight:Bool) {
		super("buttonOut", false);
		setOrigin(1, .5);
		this.facesRight = facesRight;
		if(facesRight) {
			scaleX = -1;
		}
		this.tx = tx;
		this.ty = ty;
		pushed = false;
		xx = tx * 16;
		yy = ty * 16 + 16;
		Game.CUR.lm.addChild(this, Const.FRONT_L);
	}
	override public function update() {
		super.update();
		var hero = Game.CUR.hero;
		var htx = Std.int(hero.xx) >> 4;
		var hty = Std.int(hero.yy) >> 4;
		if(!pushed) {
			if(hty == ty || hty == ty + 1) {
				if(facesRight && hero.vx < 0 && htx == tx) {
					push();
				} else if(!facesRight && hero.vx > 0 && htx == tx - 1) {
					push();
				}
			}
		}
	}
	public function push() {
		if(pushed) return;
		pushed = true;
		setAnim("buttonPushed", false);
		anim.play();
		if(onEnd != null) {
			anim.onEnd = onEnd;
		}
	}
}