package ;
import com.xay.util.SpriteLib;
import com.xay.util.Util;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import motion.Actuate;
class Door extends Entity {
	public static var ALL = [];
	public var horizontal : Bool;
	public var id : Int;
	var openTimer : Int;
	var opened : Bool;
	var level : Level;
	var tx : Int;
	var ty : Int;
	var wid : Int;
	var hei : Int;
	var top : Bitmap;
	public function new(level:Level, x:Int, y:Int, wid:Int, hei:Int, id:Int) {
		super(null, false);
		horizontal = wid > 1;
		this.id = id;
		this.tx = x;
		this.ty = y;
		this.wid = wid;
		this.hei = hei;
		this.level = level;
		moves = false;
		bmp.bitmapData = new BitmapData(16 * wid, 27, true, 0x0);
		top = new Bitmap(new BitmapData(16 * wid, 15, true, 0x0));
		SpriteLib.copyFramePixelsFromSlice(bmp.bitmapData, "door", 0, 0, 0);
		SpriteLib.copyFramePixelsFromSlice(bmp.bitmapData, "door", 2, wid * 16 - 16, 0);
		for(i in 1...wid-1) {
			SpriteLib.copyFramePixelsFromSlice(bmp.bitmapData, "door", 1, i * 16, 0);
		}
		for(i in 0...wid) {
			top.bitmapData.copyPixels(bmp.bitmapData, new Rectangle(0, 0, 16, 15), new Point(i * 16, 0));
		}
		setOrigin(0, 1);
		xx = tx * 16;
		yy = ty * 16 + 16;
		top.x = xx;
		top.y = yy - bmp.height;
		Game.CUR.lm.addChild(top, Const.FRONT_L);
		setCollision(FULL);
		Game.CUR.lm.addChild(this, Const.BACK_L);
		ALL.push(this);
		filters = [new DropShadowFilter(1., 45, 0xFF000000, .5, 3., 3., 1., 1, false), 
				   new DropShadowFilter(1., 135, 0xFF000000, .5, 3., 3., 1., 1, false)];
		opened = false;
		openTimer = 0;
	}
	override public function delete() {
		super.delete();
		if(top != null) {
			if(top.parent != null) {
				top.parent.removeChild(top);
				top.bitmapData.dispose();
			}
		}
		ALL.remove(this);
	}
	override public function update() {
		super.update();
		if(opened || openTimer <= 0) {
			return;
		}
		openTimer--;
		var ox = Util.randFloat(-2, 2);
		var oy = Util.randFloat(-2, 2);
		xx = tx * 16 + ox;
		yy = ty * 16 + 16 + oy;
		top.x = xx + ox*.5;
		top.y = yy - bmp.height + oy*.5;
		if(openTimer == 0) {
			goDown();
		}
	}
	public function goDown() {
		xx = tx * 16;
		yy = ty * 16 + 16;
		top.x = xx;
		top.y = yy - bmp.height;
		setCollision(NONE);
		bmp.scrollRect = new Rectangle(0, 0, width, 13);
		bmp.y += 12;
		this.transform.colorTransform = new ColorTransform(.6, .6, .6);
		top.parent.removeChild(top);
		top.bitmapData.dispose();
		top = null;
		Fx.doorOpened(tx, ty, wid, hei);
	}
	public function open() {
		Audio.playSound("door");
		openTimer = 43;
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