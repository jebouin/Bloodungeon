package com.xay.util;
import haxe.crypto.Sha1;
#if openfl
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
#else
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
#end
class GJAPI {
	public static var inited = false;
	static var gameId : Int;
	static var privateKey : String;
	public static var username : String;
	static var userToken : String;
	static var baseURL = "http://gamejolt.com/api/game/v1/";
	static var req : URLRequest;
	static var loader : URLLoader;
	static var callback : Event->Void;
	public static var loggedIn = false;
	public static function init(gameId:Int, privateKey:String, username:String, userToken:String=null) {
		inited = true;
		GJAPI.gameId = gameId;
		GJAPI.privateKey = privateKey;
		GJAPI.username = username;
		GJAPI.userToken = userToken;
		req = new URLRequest();
		req.method = URLRequestMethod.POST;
		loader = new URLLoader();
		if(userToken!=null) loggedIn = true;
	}
	static function checkInited() {
		if(!inited) {
			trace("GJAPI not inited!");
			return false;
		}
		return true;
	}
	public static function sendHiscore(score:Int, guestName:String=null) {
		if(!checkInited()) return;
		var nameToUse = (guestName!=null?guestName:username);
		var url = baseURL+"scores/add/";
		url+="?game_id=" + Std.string(gameId) + "&score=" + Std.string(score) + "&sort=" + score;
		if(!loggedIn) {
			url+="&username=&user_token=&guest="+nameToUse;
		} else {
			url+="&username=" + nameToUse + "&user_token=" + userToken + "&guest=";
		}
		url = encodeURL(url);
		req.url = url;
		if(GJAPI.callback!=null) {
			loader.removeEventListener(Event.COMPLETE, GJAPI.callback);
		}
		loader.load(req);
	}
	public static function unlockTrophy(id:Int) {
		if(!checkInited()) return;
		if(!loggedIn) return;
		var url = baseURL + "trophies/add-achieved/" + "?game_id=" + Std.string(gameId) 
													+ "&username=" + username
													+ "&user_token=" + userToken
													+ "&trophy-id=" + Std.string(id);
		url = encodeURL(url);
		req.url = url;
		if(GJAPI.callback != null) {
			loader.removeEventListener(Event.COMPLETE, GJAPI.callback);
		}
		/*GJAPI.callback = function(e:Event) {
			trace(e.target.data);
		}*/
		loader.addEventListener(Event.COMPLETE, GJAPI.callback);
		loader.load(req);
		//trace(url);
	}
	public static function getHiscores(callback:Event->Void, limit=10) {
		if(!checkInited()) return;
		var url = baseURL+"scores/";
		url += "?game_id=" + Std.string(gameId) + "&limit=" + limit;
		url += "&format=xml";
		url = encodeURL(url);
		req.url = url;
		if(GJAPI.callback!=null) {
			loader.removeEventListener(Event.COMPLETE, GJAPI.callback);
		}
		GJAPI.callback = callback;
		loader.addEventListener(Event.COMPLETE, GJAPI.callback);
		loader.load(req);
	}
	static function encodeURL(url:String) {
		url += "&signature=" + Sha1.encode(url+privateKey);
		var i=0;
		while(i < url.length) {
			if(url.charAt(i)==" ") {
				var end = url.substr(i+1);
				url = url.substr(0, i)+"%20"+end;
				i+=3;
			} else {
				i++;
			}
		}
		return url;
	}
}