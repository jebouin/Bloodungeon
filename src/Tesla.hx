package ;
class Tesla extends Enemy {
	var tx : Int;
	var ty : Int;
	public var id : Int;
	var links : Array<Int>;
	var time : Int;
	var timer : Int;
	public function new(tx:Int, ty:Int, id:Int, links:Array<Int>, time:Int, off:Int) {
		super("teslaIdle", true);
		this.links = links.copy();
		this.id = id;
		this.tx = tx;
		this.ty = ty;
		this.time = time;
		off %= time;
		timer = off;
		setOrigin(.5, 1);
		xx = tx * 16 + 8;
		yy = ty * 16 + 16;
		moves = false;
		shadow.alpha *= .4;
		update();
	}
	override public function delete() {
		super.delete();
	}
	override public function update() {
		timer++;
		if(timer == time - 10) {
			charge();
		} if(timer >= time) {
			timer = 0;
			shoot();
		}
		super.update();
	}
	public function charge() {
		setAnim("teslaCharge", false);
		anim.play();
	}
	public function shoot() {
		
		setAnim("teslaIdle", false);
		anim.play();
	}
}