package ;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.Lib;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import haxe.ds.StringMap;
//music should be 160 kbps
@:sound("res/floor0.mp3") class Floor0Music extends Sound {}
@:sound("res/floor1.mp3") class Floor1Music extends Sound {}
@:sound("res/floor2.mp3") class Floor2Music extends Sound {}
@:sound("res/floor3.mp3") class Floor3Music extends Sound {}
@:sound("res/rush.mp3") class RushMusic extends Sound {}
@:sound("res/title.mp3") class TitleMusic extends Sound {}
@:sound("res/select.mp3") class SelectSound extends Sound {}
@:sound("res/moveCursor.mp3") class MoveCursorSound extends Sound {}
@:sound("res/moveAch.mp3") class MoveAchSound extends Sound {}
@:sound("res/explosion.mp3") class ExplosionSound extends Sound {}
@:sound("res/warp.mp3") class WarpSound extends Sound {}
@:sound("res/button.mp3") class ButtonSound extends Sound {}
@:sound("res/door.mp3") class DoorSound extends Sound {}
@:sound("res/fall.mp3") class FallSound extends Sound {}
@:sound("res/spike.mp3") class SpikeSound extends Sound {}
@:sound("res/bow.mp3") class BowSound extends Sound {}
@:sound("res/laser.wav") class LaserSound extends Sound {}
@:sound("res/enter.mp3") class EnterSound extends Sound {}
@:sound("res/ask.wav") class AskSound extends Sound {}
@:sound("res/cannon.wav") class CannonSound extends Sound {}
class Music {
	public var sound : Sound;
	public var chan : SoundChannel;
	public var length : Float;
	public var pausePos : Float;
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
		if(Audio.musicMuted) {
			mute();
		}
	}
	public function pause() {
		pausePos = chan.position;
		chan.stop();
	}
	public function resume() {
		chan = sound.play(pausePos);
		if(Audio.musicMuted) {
			mute();
		}
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
		if(chan == null) return;
		chan.soundTransform = new SoundTransform(0.);
	}
	public function unmute() {
		if(chan == null) return;
		chan.soundTransform = new SoundTransform(1.);
	}
}
class Audio {
	static var muteState : Int;
	public static var musicMuted : Bool;
	public static var soundsMuted : Bool;
	static var musics : Array<Music>;
	static var sounds : StringMap<Sound>;
	static var chans : StringMap<SoundChannel>;
	static var playingMusic : Int;
	public static function init() {
		musics = [];
		musics.push(new Music(new Floor0Music(), 22.80, 45.61));
		musics.push(new Music(new Floor1Music(), 41.77, 104.345));
		musics.push(new Music(new Floor2Music(), 29.56, 88.605));
		musics.push(new Music(new Floor3Music(), 0, 80));
		musics.push(new Music(new RushMusic(), 5.672, 80.47));
		musics.push(new Music(new TitleMusic(), 18.02, 66));
		sounds = new StringMap<Sound>();
		chans = new StringMap<SoundChannel>();
		addSound("moveCursor", new MoveCursorSound());
		addSound("select", new SelectSound());
		addSound("moveAch", new MoveAchSound());
		addSound("explosion", new ExplosionSound());
		addSound("warp", new WarpSound());
		addSound("button", new ButtonSound());
		addSound("door", new DoorSound());
		addSound("fall", new FallSound());
		addSound("spike", new SpikeSound());
		addSound("bow", new BowSound());
		addSound("laser", new LaserSound());
		addSound("enter", new EnterSound());
		addSound("ask", new AskSound());
		addSound("cannon", new CannonSound());
		muteState = 3;
		mute(false);
		mute(false);
	}
	static function addSound(name:String, snd:Sound) {
		if(!sounds.exists(name)) {
			sounds.set(name, snd);
		}
	}
	public static function playSound(name:String, ?loop=false) {
		if(soundsMuted) return;
		if(sounds.exists(name)) {
			if(chans.exists(name)) {
				chans.get(name).stop();
			}
			var chan = sounds.get(name).play(0., loop?1<<30:0);
			chans.set(name, chan);
		}
	}
	public static function stopSound(name:String) {
		if(chans.exists(name)) {
			chans.get(name).stop();
		}
	}
	public static function playMusic(id:Int) {
		if(id >= 0 && id < musics.length) {
			playingMusic = id;
			for(m in musics) {
				m.stop();
			}
			musics[id].play(0);
		}
	}
	public static function stopMusics() {
		for(m in musics) {
			m.stop();
		}
	}
	public static function mute(?announce=true) {
		muteState++;
		if(muteState == 4) {
			muteState = 0;
		}
		switch(muteState) {
			case 0:
				muteMusic(announce);
			case 1:
				muteSounds(announce);
			case 2:
				unmuteMusic(announce);
			case 3:
				unmuteSounds(announce);
		}
	}
	static function muteMusic(announce:Bool) {
		musicMuted = true;
		for(m in musics) {
			m.mute();
		}
		if(announce) {
			Main.announce("muted musics");
		}
	}
	static function unmuteMusic(announce:Bool) {
		musicMuted = false;
		for(m in musics) {
			m.unmute();
		}
		if(announce) {
			Main.announce("unmuted musics");
		}
	}
	static function muteSounds(announce:Bool) {
		soundsMuted = true;
		if(announce) {
			Main.announce("muted sounds");
		}
	}
	static function unmuteSounds(announce:Bool) {
		soundsMuted = false;
		if(announce) {
			Main.announce("unmuted sounds");
		}
	}
	public static function onFocusOut() {
		musics[playingMusic].pause();
	}
	public static function onFocusIn() {
		musics[playingMusic].resume();
	}
}