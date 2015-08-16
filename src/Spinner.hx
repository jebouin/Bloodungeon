package ;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import haxe.Timer;
class Spinner extends Enemy {
	var nbBranches : Int;
	var size : Int;
	var rotSpeed : Float;
	var angle : Float;
	static var partBD : BitmapData;
	static var revPartBD : BitmapData;
	static var frame = 0;
	var parts : Array<Bitmap>;
	var partCont : Sprite;
	public function new(x:Float, y:Float, initAngle:Float, nbBranches:Int, size:Int, speed:Float) {
		super("spinnerBase", false);
		this.xx = x;
		this.yy = y;
		this.nbBranches = nbBranches;
		this.angle = initAngle;
		this.size = size;
		this.rotSpeed = speed;
		moves = false;
		if(partBD == null) {
			partBD = new BitmapData(16, 18, true, 0x0);
			revPartBD = new BitmapData(16, 18, true, 0x0);
			SpriteLib.copyFramePixelsFromSlice(partBD, "spinnerPart", 0, 0, 0);
			SpriteLib.copyFramePixelsFromSlice(revPartBD, "spinnerPart", 7, 0, 0);
		}
		partCont = new Sprite();
		parts = [];
		for(i in 0...size*nbBranches) {
			parts.push(new Bitmap(speed > 0 ? partBD : revPartBD));
		}
		for(p in parts) {
			partCont.addChild(p);
		}
		addChild(partCont);
	}
	function updatePos() {
		for(b in 0...nbBranches) {
			var da = Math.PI * 2. / nbBranches * b;
			var a = angle*Math.PI/180. + da;
			for(i in 0...size) {
				var p = parts[b * size + i];
				var mat = p.transform.matrix;
				var dist = i*16 + 16;
				/*p.x = Math.cos(a) * dist;
				p.y = Math.sin(a) * dist;
				p.rotation = a * 180. / Math.PI;*/
				mat.identity();
				mat.translate(-8, -9);
				mat.rotate(a);
				mat.translate(Math.cos(a) * dist, Math.sin(a) * dist);
				//mat.translate(Math.cos(a) * dist, Math.sin(a) * dist);
				p.transform.matrix = mat;
			}
		}
	}
	override public function update() {
		angle += rotSpeed;
		updatePos();
		super.update();
	}
	override public function collidesHero() {
		var hero = Game.CUR.hero;
		if(hero == null) return false;
		var dx = hero.xx - xx;
		var dy = hero.yy - yy;
		var r = 14 + size*16;
		var distSq = dx*dx + dy*dy;
		if(distSq > r * r) {
			return false; //too far
		}
		var dist = Math.sqrt(distSq);
		var heroAngle = Math.atan2(dy, dx);
		for(i in 0...nbBranches) {
			var da = Math.PI * 2. / nbBranches * i;
			var a = angle*Math.PI/180. + da;
			var aa = a - heroAngle;
			var distFromBranch = Math.tan(aa) * dist;
			if(Math.abs(distFromBranch) > 6) continue;
			var l = dist * Math.cos(aa);
			if(l > 10 && l < (size + 1) * 16 - 8) {
				return true;
			}
			//trace(distFromBranch, l);
		}
		return false;
	}
	public static function updateAll() {
		if(partBD == null) return;
		var frameChanged = false;
		frame++;
		if(frame % 5 == 0) {
			frameChanged = true;
		}
		if(frame >= 40) {
			frame = 0;
			frameChanged = true;
		}
		if(frameChanged) {
			SpriteLib.copyFramePixelsFromSlice(partBD, "spinnerPart", Std.int(frame / 5), 0, 0);
			SpriteLib.copyFramePixelsFromSlice(revPartBD, "spinnerPart", 7 - Std.int(frame / 5), 0, 0);
		}
	}
}