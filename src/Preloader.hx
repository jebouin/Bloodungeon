package ;
import flash.display.Loader;
import flash.media.Sound;
import flash.events.Event;
import flash.Lib;
import flash.display.Sprite;
import flash.events.ProgressEvent;
class Preloader extends Sprite {
	public function new() {
		super();
		mouseEnabled = mouseChildren = false;
		addEventListener(Event.ENTER_FRAME, onProgress);
		trace("!");
	}
	function onProgress(event:Event) {
		var p = Std.int(Lib.current.stage.loaderInfo.bytesLoaded / Lib.current.stage.loaderInfo.bytesTotal * 100);
		trace(p);
		if(p == 100) {
			removeEventListener(Event.ENTER_FRAME, onProgress);
			Lib.current.removeChild(this);
			var c = Type.resolveClass("Main");
			var m = Type.createInstance(c, []);
			Lib.current.addChild(m);
			trace(c);
		}
	}
	public static function main() {
		Lib.current.addChild(new Preloader());
	}
}