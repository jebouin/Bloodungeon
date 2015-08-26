package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Namespace;
import haxe.ds.StringMap;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Cubic;
@:bitmap("res/icons.png") class IconsBD extends BitmapData {}
typedef Achievement = {
	title:String,
	description:String,
	difficulty:Int,
	secret:Bool,
	unlocked:Bool,
	id:Int
}
class Achievements {
	public static var icons : Array<BitmapData>;
	public static var unlockedBD : BitmapData;
	public static var achievements : Array<Achievement>;
	public static var corres : StringMap<Int>;
	public static var count : Int;
	public static var nbUnlocked : Int;
	public static function init() {
		var ibd = new IconsBD(0, 0);
		icons = [];
		for(i in 0...8) {
			var x = i % 4 * 33;
			var y = (i >> 2) * 33;
			var bd = new BitmapData(32, 32, true, 0x0);
			bd.copyPixels(ibd, new Rectangle(x, y, 32, 32), new Point(0, 0));
			icons[i] = bd;
		}
		var textBD = Main.font.getText("unlocked");
		unlockedBD = new BitmapData(textBD.width + 32, textBD.height + 32, true, 0x0);
		unlockedBD.copyPixels(textBD, textBD.rect, new Point(16, 16));
		unlockedBD.applyFilter(unlockedBD, unlockedBD.rect, new Point(0, 0), new GlowFilter(0x0, .5, 16., 16., 7., 1));
		textBD.dispose();
		ibd.dispose();
		achievements = new Array<Achievement>();
		corres = new StringMap<Int>();
		add({title:"I can do that too", description:"Die on the last saw blade",              difficulty:0, secret:true, unlocked:false, id:0});
		add({title:"Secret...",         description:"Find a broken wall",                     difficulty:0, secret:true, unlocked:false, id:1});
		add({title:"Phrygian warrior",  description:"Beat the phrygian temple without dying", difficulty:1, secret:false, unlocked:false, id:2});
		add({title:"Cheater",           description:"Use every shortcut in one play",         difficulty:1, secret:true, unlocked:false, id:3});
		add({title:"Icy hell",          description:"Beat the ice cave without dying",        difficulty:2, secret:false, unlocked:false, id:4});
		add({title:"I did it!",         description:"Beat the game",                          difficulty:2, secret:false, unlocked:false, id:5});
		add({title:"Survivor",          description:"Beat the yolo mode",                     difficulty:3, secret:false, unlocked:false, id:6});
		nbUnlocked = 0;
	}
	static function add(a:Achievement) {
		if(corres.exists(a.title)) {
			return;
		}
		count++;
		corres.set(a.title, achievements.length);
		achievements.push(a);
	}
	static function get(title:String) {
		if(corres.exists(title)) {
			return achievements[corres.get(title)];
		}
		return null;
	}
	public static function unlock(name:String, ?isGameLoading=false) {
		var a = get(name);
		if(a == null || a.unlocked) {
			return;
		}
		a.unlocked = true;
		nbUnlocked++;
		if(!isGameLoading) {
			Save.onAchievementUnlocked();
			var text = new Bitmap(unlockedBD);
			text.x = Const.WID;
			text.y = Const.HEI - 16 - text.height * .5;
			Main.renderer.addChild(text);
			var icon = new Bitmap(icons[a.id+1]);
			icon.filters = [new GlowFilter(0x0, 1., 6., 6., 2., 1)];
			icon.x = Const.WID;
			icon.y = Const.HEI - 32;
			Main.renderer.addChild(icon);
			Actuate.tween(icon, 1., {x:Const.WID - 32});
			Actuate.tween(text, 2., {x:Const.WID - 25 - text.width});
			Timer.delay(function() {
				Actuate.tween(text, 1., {x:Const.WID}).ease(Cubic.easeIn);
				Actuate.tween(icon, 1.15, {x:Const.WID}).ease(Cubic.easeIn).onComplete(function() {
					icon.parent.removeChild(icon);
					text.parent.removeChild(text);
				});
			}, 5000);
			for(i in 0...3) {
				Timer.delay(function() {
					text.visible = icon.visible = false;
				}, i*500 + 250);
				Timer.delay(function() {
					text.visible = icon.visible = true;
				}, i*500 + 500);
			}
		}
	}
	public static function unlockId(id:Int, ?isGameLoading=false) {
		if(id < 0 || id >= achievements.length) return;
		unlock(achievements[id].title, isGameLoading);
	}
}