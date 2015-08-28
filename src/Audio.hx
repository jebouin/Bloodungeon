package ;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.Lib;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import haxe.ds.StringMap;
import motion.Actuate;
import motion.easing.Linear;
//music should be 160 kbps
@:sound("res/floor0.mp3") class Floor0Music extends Sound {}
@:sound("res/floor1.mp3") class Floor1Music extends Sound {}
@:sound("res/floor2.mp3") class Floor2Music extends Sound {}
@:sound("res/floor3.mp3") class Floor3Music extends Sound {}
@:sound("res/rush.mp3") class RushMusic extends Sound {}
@:sound("res/title.mp3") class TitleMusic extends Sound {}
@:sound("res/endingShort.mp3") class EndingMusic extends Sound {}
@:sound("res/floor3end.mp3") class Floor3EndMusic extends Sound {}
@:sound("res/select.mp3") class SelectSound extends Sound {}
@:sound("res/moveCursor.mp3") class MoveCursorSound extends Sound {}
@:sound("res/moveAch.mp3") class MoveAchSound extends Sound {}
@:sound("res/explosion.mp3") class ExplosionSound extends Sound {}
@:sound("res/warp.mp3") class WarpSound extends Sound {}
@:sound("res/button.mp3") class ButtonSound extends Sound {}
@:sound("res/door.mp3") class DoorSound extends Sound {}
@:sound("res/fall.mp3") class FallSound extends Sound {}
@:sound("res/spike.wav") class SpikeSound extends Sound {}
@:sound("res/bow.mp3") class BowSound extends Sound {}
@:sound("res/laser.wav") class LaserSound extends Sound {}
@:sound("res/enter.mp3") class EnterSound extends Sound {}
@:sound("res/ask.wav") class AskSound extends Sound {}
@:sound("res/cannon.wav") class CannonSound extends Sound {}
@:sound("res/noise0.wav") class Noise0Sound extends Sound {}
@:sound("res/noise1.wav") class Noise1Sound extends Sound {}
@:sound("res/rocks.mp3") class RocksSound extends Sound {}
@:sound("res/voices.mp3") class VoicesSound extends Sound {}
@:sound("res/launcher.mp3") class LauncherSound extends Sound {}
@:sound("res/tesla.mp3") class TeslaSound extends Sound {}
@:sound("res/thwomp.mp3") class ThwompSound extends Sound {}
@:sound("res/achievementUnlocked.wav") class AchievementUnlockedSound extends Sound {}
@:sound("res/dialog.wav") class DialogSound extends Sound {}
@:sound("res/rocketExplosion.wav") class RocketExplosionSound extends Sound {}
class Music {
	public var sound : Sound;
	public var chan : SoundChannel;
	public var trans : SoundTransform;
	public var length : Float;
	public var pausePos : Float;
	public var introLength : Float;
	public var playing : Bool;
	public function new(snd:Sound, introLength:Float, length:Float) {
		this.sound = snd;
		this.length = length;
		this.introLength = introLength;
		playing = false;
		trans = new SoundTransform();
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
	}
	public function play(?pos=0, ?fadeTime:Float=-1) {
		playing = true;
		chan = sound.play(pos, 0);
		setVolume(1.);
		Actuate.stop(trans);
		if(Audio.musicMuted) {
			mute();
		} else if(fadeTime > 0) {
			trans.volume = 0.;
			Actuate.tween(trans, fadeTime, {volume:1.}).ease(Linear.easeNone).onComplete(function() {
				
			}).onUpdate(function() {
				chan.soundTransform = trans;
			});
		}
	}
	public function pause() {
		pausePos = chan.position;
		chan.stop();
	}
	public function resume() {
		if(!playing) return;
		chan = sound.play(pausePos);
		chan.soundTransform = trans;
		if(Audio.musicMuted) {
			mute();
		}
	}
	public function stop(?fadeTime:Float=-1) {
		if(!playing) return;
		if(fadeTime > 0) {
			trans.volume = 1.;
			Actuate.tween(trans, fadeTime, {volume:0.}).ease(Linear.easeNone).onComplete(function() {
				playing = false;
				chan.stop();
			}).onUpdate(function() {
				chan.soundTransform = trans;
			});
		} else {
			playing = false;
			chan.stop();
		}
	}
	function update(_) {
		if(playing) {
			if(length > 0) {
				if(chan.position / 1000. > length) {
					play(Std.int(introLength * 1000.));
				}
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
	public function setVolume(v:Float, ?t:Float=-1) {
		Actuate.stop(trans);
		if(t > 0) {
			Actuate.tween(trans, t, {volume:v}).ease(Linear.easeNone).onComplete(function() {
				
			}).onUpdate(function() {
				chan.soundTransform = trans;
			});
		} else {
			trans.volume = v;
			chan.soundTransform = trans;
		}
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
		musics.push(new Music(new EndingMusic(), 0, 0));
		musics.push(new Music(new Floor3EndMusic(), .031, 5.7));
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
		addSound("noise0", new Noise0Sound());
		addSound("noise1", new Noise1Sound());
		addSound("rocks", new RocksSound());
		addSound("voices", new VoicesSound());
		addSound("launcher", new LauncherSound());
		addSound("tesla", new TeslaSound());
		addSound("thwomp", new ThwompSound());
		addSound("achievementUnlocked", new AchievementUnlockedSound());
		addSound("dialog", new DialogSound());
		addSound("rocketExplosion", new RocketExplosionSound());
		muteState = 3;
		playingMusic = -1;
		/*mute(false);
		mute(false);*/
	}
	static function addSound(name:String, snd:Sound) {
		if(!sounds.exists(name)) {
			sounds.set(name, snd);
		}
	}
	public static function playSound(name:String, ?loop=false) {
		if(name != "voices" && soundsMuted) {
			return null;
		}
		var chan = null;
		if(sounds.exists(name)) {
			if(chans.exists(name)) {
				chans.get(name).stop();
			}
			if(soundsMuted && name == "voices") {
				chan = sounds.get(name).play(0., loop?1<<30:0, new SoundTransform(0.));
			} else {
				chan = sounds.get(name).play(0., loop?1<<30:0);
			}
			chans.set(name, chan);
		}
		return chan;
	}
	public static function stopSound(name:String) {
		if(chans.exists(name)) {
			chans.get(name).stop();
		}
	}
	public static function stopSounds() {
		for(c in chans.iterator()) {
			c.stop();
		}
	}
	public static function playMusic(id:Int, ?fadeTime:Float=-1) {
		if(id >= 0 && id < musics.length) {
			playingMusic = id;
			for(m in musics) {
				m.stop();
			}
			musics[id].play(0, fadeTime);
		}
	}
	public static function stopMusics(?fadeTime:Float=-1) {
		if(musicMuted) return;
		for(m in musics) {
			m.stop(fadeTime);
		}
	}
	public static function setMusicVolume(v:Float, t:Float) {
		if(musicMuted) return;
		if(playingMusic >= 0) {
			var m = musics[playingMusic];
			if(m.playing) {
				m.setVolume(v, t);
			}
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
		if(playingMusic >= 0) {
			musics[playingMusic].pause();
		}
	}
	public static function onFocusIn() {
		if(playingMusic >= 0) {
			musics[playingMusic].resume();
		}
	}
}