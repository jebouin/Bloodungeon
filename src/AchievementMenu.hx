package ;
import com.xay.util.Input;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager;
import com.xay.util.SceneManager.Scene;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import haxe.Timer;
import motion.Actuate;
class AchievementMenu extends Scene {
	static inline var BOXWID = 180;
	static inline var BOXHEI = 50;
	static inline var BOXMARGIN = 10;
	var lm : LayerManager;
	var title : Bitmap;
	var progress : Bitmap;
	var boxes : Array<Sprite>;
	var selected : Int;
	var exiting : Bool;
	public function new() {
		super();
		lm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		/*title = new Bitmap(Main.font.getText("achievements"));
		title.scaleX = title.scaleY = 2.;
		title.x = Const.WID * .5 - title.width * .5;
		title.y = 25;
		lm.addChild(title, 0);*/
		progress = new Bitmap(Main.font.getText(Std.string(Achievements.nbUnlocked) + "/" + Std.string(Achievements.count)));
		progress.scaleX = progress.scaleY = 2.;
		progress.x = Const.WID * .5 - progress.width * .5;
		progress.y = Const.HEI * .6;
		lm.addChild(progress, 0);
		var a : Achievements.Achievement;
		boxes = [];
		for(i in 0...7) {
			var a = Achievements.achievements[i];
			var hidden = a.secret && !a.unlocked;
			var b = new Sprite();
			var backCol = 0x0;
			var borderCOl = 0xAAAAAA;
			var rm = .55;
			var gm = .55;
			var bm = .55;
			if(a.unlocked) {
				backCol = 0x101000;
				borderCOl = 0xEEEEEE;
				rm = gm = bm = 1.;
			}
			b.graphics.beginFill(backCol);
			b.graphics.lineStyle(1., borderCOl);
			b.graphics.drawRect(-BOXWID * .5, -BOXHEI * .5, BOXWID, BOXHEI);
			b.graphics.endFill();
			b.x = Const.WID * .5;
			b.y = Const.HEI + i * (BOXHEI + BOXMARGIN);
			lm.addChild(b, 0);
			boxes.push(b);
			var title = new Bitmap(Main.font.getText(a.title));
			title.x = -title.width * .5;
			title.y = -BOXHEI * .5 + 10;
			title.transform.colorTransform = new ColorTransform(rm, gm, bm);
			b.addChild(title);
			b.graphics.lineStyle(1., a.unlocked ? 0xFFFFFF : 0x808080);
			b.graphics.moveTo(title.x, title.y + title.height + 1);
			b.graphics.lineTo(title.x + title.width, title.y + title.height + 1);
			var desc = new Bitmap(Main.font.getText(hidden ? "???" : a.description, 20, true));
			desc.x = hidden ? -desc.width * .5 : -BOXWID * .5 + 40;
			desc.y = -BOXHEI * .5 + 26;
			if(a.unlocked) {
				desc.transform.colorTransform = new ColorTransform(.3, .6, .75);
			} else {
				desc.transform.colorTransform = new ColorTransform(.4, .4, .4);
			}
			b.addChild(desc);
			if(a.unlocked) {
				var check = new Shape();
				check.x = b.width * .4;
				var g = check.graphics;
				var s = 20;
				g.lineStyle(8, 0x22DD22, 1., false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
				g.moveTo(0, 0);
				g.lineTo(s*.5, 0);
				g.lineTo(s*.5, -s);
				check.rotation = 45;
				b.addChild(check);
			}
			var icon = new Bitmap(Achievements.icons[a.unlocked ? i+1 : 0]);
			icon.x = -BOXWID * .5 + 1;
			icon.y = b.height * .5 - 33;
			b.addChild(icon);
		}
		exiting = false;
		select(0);
	}
	function select(id:Int) {
		selected = id;
		var exits = false;
		if(id < 0 || id >= boxes.length) {
			exits = true;
		}
		if(exits) {
			if(id < 0) {
				id = -2;
			} else {
				id = boxes.length + 1;
			}
		}
		for(i in 0...7) {
			var b = boxes[i];
			var ty = Const.HEI * .5 - (id - i) * (BOXHEI + BOXMARGIN);
			var alpha = id == i ? 1. : (id == i-1 || id == i+1 ? .3 : 0.);
			if(exits) {
				alpha = .7;
			}
			Actuate.tween(b, .5, {y:ty, alpha:alpha});
		}
		if(exits) {
			Actuate.tween(progress, .5, {y:20 - id * (BOXHEI + BOXMARGIN), alpha:0.});
		} else {
			Actuate.tween(progress, .5, {y:20 - id * (BOXHEI + BOXMARGIN)});
		}
	}
	override public function delete() {
		super.delete();
		lm.delete();
	}
	override public function update() {
		super.update();
		if(!exiting) {
			if(Input.newKeyPress("down") && !Main.secondUpdate) {
				select(selected + 1);
				if(selected >= boxes.length) {
					delayExit();
				}
				Audio.playSound("moveAch");
			}
			if(Input.newKeyPress("up") && !Main.secondUpdate) {
				select(selected - 1);
				if(selected < 0) {
					delayExit();
				}
				Audio.playSound("moveAch");
			}
			if(Input.newKeyPress("escape")) {
				delayExit();
			}
			/*if(Input.newKeyPress("start")) {
				if(selected >=0 && selected < boxes.length) {
					Achievements.unlockId(selected);
				}
			}*/
		}
	}
	function delayExit() {
		if(exiting) return;
		exiting = true;
		Menu.removeBlur();
		Timer.delay(function() {
			delete();
		}, 200);
	}
}