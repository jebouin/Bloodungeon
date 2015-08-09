package ;
class Action {
	public static function closeExit() {
		Game.CUR.level.replaceLittleLights();
		Game.CUR.level.removeExitLight();
	}
}