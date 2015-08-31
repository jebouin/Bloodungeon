package ;
import flash.net.SharedObject;
class Save {
	public static var so : SharedObject;
	public static function init() {
		so = SharedObject.getLocal("save");

		//so.clear();
		if(!so.data.hasOwnProperty("totalDeaths")) {
			so.data.totalDeaths = 0;
			so.data.gameTime = 0;
			so.data.ach0 = false;
			so.data.ach1 = false;
			so.data.ach2 = false;
			so.data.ach3 = false;
			so.data.ach4 = false;
			so.data.ach5 = false;
			so.data.ach6 = false;
			so.data.skipStory = false;
			so.data.yoloMode = false;
			so.data.hasSave = false;
			so.flush();
		}
		Stats.totalDeaths = so.data.totalDeaths;
		Stats.gameTime = so.data.gameTime;
		if(so.data.ach0) Achievements.unlockId(0, true);
		if(so.data.ach1) Achievements.unlockId(1, true);
		if(so.data.ach2) Achievements.unlockId(2, true);
		if(so.data.ach3) Achievements.unlockId(3, true);
		if(so.data.ach4) Achievements.unlockId(4, true);
		if(so.data.ach5) Achievements.unlockId(5, true);
		if(so.data.ach6) Achievements.unlockId(6, true);
	}
	public static function onStartGame() {
		so.data.skipStory = Game.skipStory;
		so.data.yoloMode = Game.yoloMode;
		so.data.nbFakeTileBroken = 0;
		so.data.nbDeaths = 0;
		so.data.isRush = false;
		so.data.brokens = [false, false, false, false, false, false];
		so.flush();
		//trace("Started game with " + Game.skipStory + " " + Game.yoloMode);
	}
	public static function continueGame() {
		Game.yoloMode = so.data.yoloMode;
		Game.skipStory = so.data.skipStory;
		Hero.spawnX = so.data.spawnX;
		Hero.spawnY = so.data.spawnY;
		if(so.data.prevDir == null) {
			Hero.prevRoomDir = null;
		} else {
			Hero.prevRoomDir = Const.DIR.createByIndex(so.data.prevDir);
		}
		Game.CUR.level.setRoomId(so.data.roomX, so.data.roomY);
		FakeTile.nbBroken = so.data.nbFakeTileBroken;
		FakeTile.brokens = so.data.brokens.copy();
		//trace(FakeTile.nbBroken, FakeTile.brokens);
	}
	public static function onNextRoom(floor:Int, roomX:Int, roomY:Int, spawnX:Float, spawnY:Float, prevDir:Const.DIR) {
		//if(Game.yoloMode) return;
		if(floor == 3 && roomX == 3 && roomY == 0) return;
		if(floor > 0) {
			so.data.hasSave = true;
			so.data.floorId = floor;
			so.data.roomX = roomX;
			so.data.roomY = roomY;
			so.data.spawnX = spawnX;
			so.data.spawnY = spawnY;
			if(prevDir == null) {
				so.data.prevDir = null;
			} else {
				so.data.prevDir = prevDir.getIndex();
			}
		}
		so.data.gameTime = Stats.gameTime;
		so.data.curGameTime = Game.curGameTime;
		so.flush();
	}
	public static function onRush() {
		so.data.isRush = true;
		so.flush();
	}
	public static function onAchievementUnlocked() {
		so.data.ach0 = Achievements.achievements[0].unlocked;
		so.data.ach1 = Achievements.achievements[1].unlocked;
		so.data.ach2 = Achievements.achievements[2].unlocked;
		so.data.ach3 = Achievements.achievements[3].unlocked;
		so.data.ach4 = Achievements.achievements[4].unlocked;
		so.data.ach5 = Achievements.achievements[5].unlocked;
		so.data.ach6 = Achievements.achievements[6].unlocked;
		so.flush();
	}
	public static function onQuitGame() {
		so.data.gameTime = Stats.gameTime;
		so.flush();
	}
	public static function onDeath() {
		so.data.deaths = Game.CUR.hero.nbDeaths;
		so.data.totalDeaths = Stats.totalDeaths;
		so.flush();
	}
	public static function onFakeTileBroken() {
		so.data.brokens = FakeTile.brokens.copy();
		so.data.nbFakeTileBroken = FakeTile.nbBroken;
		so.flush();
	}
	public static function onNextFloor() {
		
	}
}