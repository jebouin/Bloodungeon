package ;
import flash.utils.Namespace;
import haxe.ds.StringMap;
typedef Achievement = {
	title:String,
	description:String,
	difficulty:Int,
	secret:Bool,
	unlocked:Bool,
	id:Int
}
class Achievements {
	public static var achievements : Array<Achievement>;
	public static var corres : StringMap<Int>;
	public static var count : Int;
	public static var nbUnlocked : Int;
	public static function init() {
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
			trace(name + " unlocked!");
			Save.onAchievementUnlocked();
		}
	}
	public static function unlockId(id:Int, ?isGameLoading=false) {
		if(id < 0 || id >= achievements.length) return;
		unlock(achievements[id].title, isGameLoading);
	}
}