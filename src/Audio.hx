package ;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.Lib;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
//music should be 160 kbps
@:sound("res/floor0.mp3") class Floor0Music extends Sound {}
@:sound("res/floor1.mp3") class Floor1Music extends Sound {}
class Music {
	public var sound : Sound;
	public var chan : SoundChannel;
	public var length : Float;
	public var introLength : Float;
	public var playing : Bool;
	public function new(snd:Sound, introLength:Float, length:Float) {
		this.sound = snd;
		this.length = length;
		this.introLength = introLength;
		playing = false;
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
	}
	public function play(?pos=0) {
		playing = true;
		chan = sound.play(pos, 0);
	}
	public function stop() {
		if(!playing) return;
		playing = false;
		chan.stop();
	}
	function update(_) {
		if(playing) {
			if(chan.position / 1000. > length) {
				play(Std.int(introLength * 1000.));
			}
		}
	}
	public function mute() {
		chan.soundTransform = new SoundTransform(0.);
	}
	public function unmute() {
		chan.soundTransform = new SoundTransform(1.);
	}
}
class Audio {
	public static var musics : Array<Music>;
	public static var playingMusic : Int;
	public static function init() {
		musics = [];
		musics.push(new Music(new Floor0Music(), 22.80, 45.61));
		musics.push(new Music(new Floor1Music(), 31.335, 93.91));
		//mute();
	}
	public static function playMusic(id:Int) {
		if(id >= 0 && id < 2) {
			playingMusic = id;
			for(m in musics) {
				m.stop();
			}
			musics[id].play(0);
		}
	}
	public static function mute() {
		musics[playingMusic].mute();
	}
	public static function unmute() {
		musics[playingMusic].unmute();
	}
}