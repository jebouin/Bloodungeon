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
	public static var achievements : StringMap<Achievement>;
	public static var count : Int;
	public static var nbUnlocked : Int;
	public static function init() {
		achievements = new StringMap<Achievement>();
		add({title:"I can do that too", description:"Die on the last saw blade",              difficulty:0, secret:true, unlocked:false, id:0});
		add({title:"Secret...",         description:"Find a broken wall",                     difficulty:0, secret:true, unlocked:false, id:1});
		add({title:"Phrygian warrior",  description:"Beat the phrygian temple without dying", difficulty:1, secret:false, unlocked:false, id:2});
		add({title:"Cheater",           description:"Use every shortcut in one play",         difficulty:1, secret:true, unlocked:false, id:3});
		add({title:"Icy hell",          description:"Beat the ice cave without dying",        difficulty:2, secret:false, unlocked:false, id:4});
		add({title:"I did it!",         description:"Beat the game",                          difficulty:2, secret:false, unlocked:false, id:5});
		add({title:"Survivor",          description:"Beat the yolo mode",                     difficulty:3, secret:false, unlocked:false, id:6});
	}
	static function add(a:Achievement) {
		if(achievements.exists(a.title)) {
			return;
		}
		count++;
		nbUnlocked = 0;
		achievements.set(a.title, a);
	}
	public static function unlock(name:String) {
		if(!achievements.exists(name)) {
			return;
		}
		var a = achievements.get(name);
		if(a.unlocked) {
			return;
		}
		a.unlocked = true;
		nbUnlocked++;
		trace(name + " unlocked!");
	}
	public static function unlockId(id:Int) {
		for(a in achievements.iterator()) {
			if(a.id == id) {
				unlock(a.title);
			}
		}
	}
}