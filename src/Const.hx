package ;
enum DIR {
	LEFT;
	RIGHT;
	UP;
	DOWN;
}
enum DIR8 {
	LEFT;
	RIGHT;
	UP;
	DOWN;
	UP_LEFT;
	UP_RIGHT;
	DOWN_LEFT;
	DOWN_RIGHT;
}
class Const {
	public static var WID : Int;
	public static var HEI : Int;
	public static var SCALE = 4;
	static var CUR_L = 0;
	public static var VOID_L = CUR_L++;
	public static var BACK_L = CUR_L++;
	public static var SHADOW_L = CUR_L++;
	public static var ENEMY_L = CUR_L++;
	public static var HERO_L = CUR_L++;
	public static var FRONT_L = CUR_L++;
	public static var DIRS : Array<DIR> = [LEFT, RIGHT, UP, DOWN];
	public static var DIRS8 : Array<DIR8> = [LEFT, RIGHT, UP, DOWN, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT];
	public static inline function stringToDir(s:String) : DIR {
		return (s == "up" ? UP : (s == "down" ? DOWN : (s == "left" ? LEFT : (s == "right" ? RIGHT : null))));
	}
	public static inline function dirToString(d:DIR) {
		return (d == UP ? "up" : (d == DOWN ? "down" : (d == LEFT ? "left" : (d == RIGHT ? "right" : "null"))));
	}
	public static inline function dir8ToString(d:DIR8) {
		return (d == UP ? "up" : (d == DOWN ? "down" : (d == LEFT ? "left" : (d == RIGHT ? "right" : (d == UP_LEFT ? "upLeft" : (d == UP_RIGHT ? "upRight" : (d == DOWN_LEFT ? "downLeft" : (d == DOWN_RIGHT ? "downRight" : "null"))))))));
	}
	public static inline function isOpposite(d:DIR, dd:DIR) {
		return ((d == UP && dd == DOWN) ||
			   (d == DOWN && dd == UP) ||
			   (d == LEFT && dd == RIGHT) ||
			   (d == RIGHT && dd == LEFT));
	}
	public static inline function isOpposite8(d:DIR8, dd:DIR8) {
		return ((d == UP && dd == DOWN) ||
			   (d == DOWN && dd == UP) ||
			   (d == LEFT && dd == RIGHT) ||
			   (d == RIGHT && dd == LEFT) ||
			   (d == UP_LEFT && dd == DOWN_RIGHT) ||
			   (d == DOWN_RIGHT && dd == UP_LEFT) ||
			   (d == UP_RIGHT && dd == DOWN_LEFT) ||
			   (d == DOWN_LEFT && dd == UP_RIGHT));
	}
	public static inline function getOpposite(d:DIR) : DIR {
		return (d == UP ? DOWN : (d == DOWN ? UP : (d == LEFT ? RIGHT : (d == RIGHT ? LEFT : null))));
	}
	public static inline function getDirX(d:DIR) {
		return (d == RIGHT ? 1 : (d == LEFT ? -1 : 0));
	}
	public static inline function getDirY(d:DIR) {
		return (d == DOWN ? 1 : (d == UP ? -1 : 0));
	}
	public static inline function getDir8X(d:DIR8) {
		return ((d == RIGHT || d == UP_RIGHT || d == DOWN_RIGHT) ? 1 : ((d == LEFT || d == UP_LEFT || d == DOWN_LEFT) ? -1 : 0));
	}
	public static inline function getDir8Y(d:DIR8) {
		return ((d == DOWN || d == DOWN_LEFT || d == DOWN_RIGHT) ? 1 : ((d == UP || d == UP_LEFT || d == UP_RIGHT) ? -1 : 0));
	}
}