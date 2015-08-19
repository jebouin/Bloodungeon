package com.xay.util;
import flash.events.Event;
import flash.events.FocusEvent;
import haxe.ds.StringMap;
#if openfl
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.Lib;
#elseif flash
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
#end
class Input {
	static var keys : StringMap<Bool>;
	static var oldKeys : StringMap<Bool>;
	static var keyCorres : StringMap<Array<UInt> >;
	static var it : Iterator<String>;
	static public function init() {
		keyCorres = new StringMap<Array<UInt> >();
		keys = new StringMap<Bool>();
		oldKeys = new StringMap<Bool>();
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEvent.bind(_, true));
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, keyEvent.bind(_, false));
		Lib.current.stage.addEventListener(FocusEvent.FOCUS_OUT, function(_) {
			for(k in keys.keys()) {
				keys.set(k, false);
			}
		});
	}
	static public function addKey(name:String, key:UInt) {
		if(keyCorres.get(name)==null) {
			keyCorres.set(name, new Array());
		}
		keyCorres.get(name).push(key);
	}
	static public function update() {
		for(k in keys.keys()) {
			oldKeys.remove(k);
			oldKeys.set(k, keys.get(k));
		}
	}
	static public function keyDown(keyType:String) {
		return keys.get(keyType);
	}
	static public function oldKeyDown(keyType:String) {
		return oldKeys.get(keyType);
	}
	static public function newKeyPress(keyType:String) {
		return keys.get(keyType) && !oldKeys.get(keyType);
	}
	static public function anyNewKeyPress() {
		//return true;
		for(k in keyCorres.keys()) {
			if(!Input.oldKeyDown(k)&&Input.keyDown(k)) {
				return true;
			}
		}
		return false;
	}
	static function keyEvent(e:KeyboardEvent, down:Bool) {
		for(ck in keyCorres.keys()) {
			for(k in keyCorres.get(ck)) {
				if(k==e.keyCode) {
					keys.set(ck, down);
					break;
				}
			}
		}
	}
}