package ;
import com.xay.util.SpriteLib;
import com.xay.util.Util;
import com.xay.util.XSprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.Lib;
class Torch extends Sprite {
	public static var dark : Sprite;
	static var ALL = [];
	static var bd : BitmapData;
	var fire : XSprite;
	var light : Shape;
	var bmp : Bitmap;
	var ls : Float;
	var off : Float;
	var spd : Float;
	public function new(tx:Int, ty:Int) {
		super();
		if(bd == null) {
			bd = new BitmapData(16, 16, true);
			SpriteLib.copyFramePixelsFromSlice(bd, "tileset", 87);
		}
		bmp = new Bitmap(bd);
		addChild(bmp);
		fire = new XSprite("fire", true);
		fire.setOrigin(.5, 1);
		fire.anim.setFrame(Std.random(5));
		Game.CUR.lm.addChild(fire, Const.FRONT_L);
		this.x = tx * 16;
		this.y = ty * 16;
		fire.x = this.x + 8;
		fire.y = this.y + 6;
		Game.CUR.lm.addChild(this, Const.BACK_L);
		light = new Shape();
		var g = light.graphics;
		g.beginFill(0xFFFFFF, .5);
		g.drawCircle(0, 0, 20);
		g.endFill();
		g.beginFill(0xFFFFFF, .3);
		g.drawCircle(0, 0, 100);
		g.endFill();
		light.blendMode = BlendMode.ERASE;
		dark.addChild(light);
		update();
		ALL.push(this);
		ls = 1.;
		off = Math.random() * 10;
		spd = Util.randFloat(.5, 1.2);
	}
	public function delete() {
		if(parent != null) {
			parent.removeChild(this);
		}
		if(light.parent != null) {
			light.parent.removeChild(light);
		}
		fire.delete();
		ALL.remove(this);
	}
	public function update() {
		light.x = x + 8 + Game.CUR.lm.getContainer().x;
		light.y = y + Game.CUR.lm.getContainer().y;
		fire.update();
		ls = Math.sin(Lib.getTimer() / 50. * spd + off) * .05 + Math.sin(Lib.getTimer() / 20. * spd - off * 2.)*.02 + 1.;
		light.scaleX = light.scaleY = ls;
	}
	public static function updateAll() {
		for(f in ALL) {
			f.update();
		}
	}
}