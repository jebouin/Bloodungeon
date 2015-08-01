package ;
import com.xay.util.SpriteLib;
import flash.geom.Rectangle;
import haxe.crypto.Base64;
#if openfl
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
#elseif flash
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.utils.ByteArray;
import flash.utils.Endian;
#end
class TiledLayer extends Sprite {
	public var wid : Int;
	public var hei : Int;
	public var layerName : String;
	var tiles : Array<Array<Int> >;
	var tileSize : Int;
	public var bmp : Bitmap;
	public function new(xml:Xml, tileSize:Int) {
		super();
		this.tileSize = tileSize;
		wid = Std.parseInt(xml.get("width"));
		hei = Std.parseInt(xml.get("height"));
		tiles = [for(j in 0...hei) []];
		layerName = xml.get("name");
		for(child in xml) {
			if(child.nodeType == Xml.Element) {
				if(child.nodeName == "data") {
					if(child.get("compression") != "zlib") {
						return;
					}
					var base64data = child.firstChild().nodeValue;
					parseTiles(base64data);
				}
			}
		}
		render();
	}
	public function delete() {
		if(bmp != null) {
			bmp.bitmapData.dispose();
		}
		if(parent != null) {
			parent.removeChild(this);
		}
	}
	function parseTiles(base64data:String) {
		var toParse = "";
		for(i in 0...base64data.length) {
			var c = base64data.charAt(i);
			if(c != " " && c != "\n" && c != "\t") {
				toParse += c;
			}
		}
		var bytes = Base64.decode(toParse);
		var array = new ByteArray();
		for(i in 0...bytes.length) {
			array.writeByte(bytes.get(i));
		}
		array.uncompress();
		array.endian = Endian.LITTLE_ENDIAN;
		var tilesId = [];
		while(array.position < array.length){
			tilesId.push(array.readInt());
		}
		for(i in 0...tilesId.length) {
			var x = i%wid;
			var y = Std.int(i/wid);
			tiles[y][x] = tilesId[i];
		}
	}
	public function render() {
		var bd:BitmapData=null;
		if(bmp != null && bmp.bitmapData != null) {
			bd = bmp.bitmapData;
			bd.fillRect(bd.rect, 0x0);
		} else {
			bd = new BitmapData(wid*tileSize, hei*tileSize, true, 0x0);
		}
		for(j in 0...hei) {
			for(i in 0...wid) {
				var tile = getTileAt(i, j)-1;
				if(tile<0) continue;
				SpriteLib.copyFramePixelsFromSlice(bd, "tileset", tile, i*tileSize, j*tileSize);
			}
		}
		bmp = new Bitmap(bd);
		addChild(bmp);
	}
	public function isOnLayer(x:Int, y:Int) {
		return (x>=0 && y>=0 && x<wid && y<hei);
	}
	public function getTileAt(x:Int, y:Int) {
		if(!isOnLayer(x, y)) {
			return 0;
		}
		return tiles[y][x];
	}
	public function setTileAt(x:Int, y:Int, id:Int) {
		if(!isOnLayer(x, y)) {
			return;
		}
		tiles[y][x] = id;
	}
}