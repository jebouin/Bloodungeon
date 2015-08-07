package ;
import com.xay.util.SpriteLib;
import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import motion.Actuate;
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
		super(null, false);
		horizontal = wid > 1;
		this.id = id;
		this.tx = x;
		this.ty = y;
		this.wid = wid;
		this.hei = hei;
		this.level = level;
		bmp.bitmapData = new BitmapData(16 * wid, 27, true, 0x0);
		SpriteLib.copyFramePixelsFromSlice(bmp.bitmapData, "door", 0, 0, 0);
		SpriteLib.copyFramePixelsFromSlice(bmp.bitmapData, "door", 2, wid * 16 - 16, 0);
		for(i in 1...wid-1) {
			SpriteLib.copyFramePixelsFromSlice(bmp.bitmapData, "door", 1, i * 16, 0);
		}
		setOrigin(0, 1);
		xx = tx * 16;
		yy = ty * 16 + 16;
		setCollision(FULL);
		Game.CUR.lm.addChild(this, Const.BACK_L);
		ALL.push(this);
		filters = [new DropShadowFilter(1., 45, 0xFF000000, .5, 8., 8., 1., 1, false), 
				   new DropShadowFilter(1., 135, 0xFF000000, .5, 8., 8., 1., 1, false)];
	}
	override public function delete() {
		super.delete();
		ALL.remove(this);
	}
	public function open() {
		setCollision(NONE);
		bmp.scrollRect = new Rectangle(0, 0, width, 13);
		bmp.y += 12;
		this.transform.colorTransform = new ColorTransform(.6, .6, .6);
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