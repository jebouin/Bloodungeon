package ;
class Door extends Entity {
	public static var ALL = [];
	public var horizontal : Bool;
	public var id : Int;
	var level : Level;
	var tx : Int;
	var ty : Int;
	var wid : Int;
	var hei : Int;
	public function new(level:Level, x:Int, y:Int, wid:Int, hei:Int, id:Int) {
		super();
		horizontal = wid > 1;
		this.id = id;
		this.tx = x;
		this.ty = y;
		this.wid = wid;
		this.hei = hei;
		this.level = level;
		setCollision(FULL);
		Game.CUR.lm.addChild(this, Const.BACK_L);
		ALL.push(this);
	}
	override public function delete() {
		super.delete();
		ALL.remove(this);
	}
	public function open() {
		setCollision(NONE);
	}
	function setCollision(type:Collision.TILE_COLLISION_TYPE) {
		if(horizontal) {
			for(i in 0...wid) {
				level.setCollision(tx+i, ty, type);
			}
		} else {
			for(i in 0...hei) {
				level.setCollision(tx, ty+i, type);
			}
		}
	}
	public static function openId(id:Int) {
		for(d in ALL) {
			if(d.id == id) {
				d.open();
			}
		}
	}
}