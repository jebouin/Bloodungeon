package ;
import flash.net.SharedObject;
class Save {
	public static var so : SharedObject;
	public static function init() {
		so = SharedObject.getLocal("save");
		//so.clear();
		Stats.totalDeaths = so.data.totalDeaths;
		Stats.gameTime = so.data.gameTime;
	}
	public static function onStartGame() {
		so.data.skipStory = Game.skipStory;
		so.data.yoloMode = Game.yoloMode;
		so.flush();
		//trace("Started game with " + Game.skipStory + " " + Game.yoloMode);
	}
	public static function continueGame() {
		Game.yoloMode = so.data.yoloMode;
		Game.skipStory = so.data.skipStory;
		Hero.spawnX = so.data.spawnX;
		Hero.spawnY = so.data.spawnY;
		Hero.prevRoomDir = so.data.prevDir;
		Game.CUR.level.setRoomId(so.data.roomX, so.data.roomY);
		//trace("Continued game with " + Game.yoloMode + " " + Game.skipStory + " " + so.data.roomX + " " + so.data.roomY + " " + so.data.spawnX + " " + so.data.spawnY);
	}
	public static function onNextRoom(floor:Int, roomX:Int, roomY:Int, spawnX:Float, spawnY:Float, prevDir:Const.DIR) {
		so.data.floorId = floor;
		so.data.roomX = roomX;
		so.data.roomY = roomY;
		so.data.spawnX = spawnX;
		so.data.spawnY = spawnY;
		so.data.prevDir = prevDir;
		so.data.gameTime = Stats.gameTime;
		so.flush();
	}
	public static function onAchievementUnlocked() {
		//so.data.ach0
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
	public static function onNextFloor() {
		
	}
}