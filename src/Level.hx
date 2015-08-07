package ;
import com.xay.util.LayerManager;
import flash.accessibility.Accessibility;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.filters.ShaderFilter;
import flash.geom.Matrix;
import flash.net.drm.DRMVoucherDownloadContext;
import flash.utils.ByteArray;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import Collision;
@:file("res/floor0.tmx") class Floor0TMX extends ByteArray {}
class Level {
	public static var ROOMID = 0;
	public static var RWID : Int;
	public static var RHEI : Int;
	public static var WID : Int;
	public static var HEI : Int;
	public var posX : Float;
	public var posY : Float;
	public var dark : Sprite;
	public var light : Shape;
	public var light2 : Shape;
	var roomIdX : Int;
	var roomIdY : Int;
	var nbRoomsX : Int;
	var nbRoomsY : Int;
	var tiles : Array<Array<TILE_COLLISION_TYPE> >;
	var spikePos : Array<{x:Int, y:Int}>;
	var ground0Layer : TiledLayer;
	var ground1Layer : TiledLayer;
	var overLayer : TiledLayer;
	var wall0Layer : TiledLayer;
	var wall1Layer : TiledLayer;
	var activeGroup : TiledGroup;
	var map : TiledMap;
	public function new() {
		RWID = Std.int(Const.WID / 16);
		RHEI = Std.int(Const.HEI / 16);
		load();
		Game.CUR.lm.addChild(ground0Layer, Const.BACK_L);
		Game.CUR.lm.addChild(ground1Layer, Const.BACK_L);
		Game.CUR.lm.addChild(overLayer, Const.BACK_L);
		Game.CUR.lm.addChild(wall0Layer, Const.BACK_L);
		Game.CUR.lm.addChild(wall1Layer, Const.BACK_L);
		setRoomId(1, 3);
		loadEntities(roomIdX, roomIdY);
		Game.CUR.lm.getContainer().x = -posX;
		Game.CUR.lm.getContainer().y = -posY;
		renderLighting();
	}
	public function load() {
		map = new TiledMap(new Floor0TMX().toString());
		ground0Layer = map.getLayer("ground0");
		ground1Layer = map.getLayer("ground1");
		overLayer = map.getLayer("over");
		wall0Layer = map.getLayer("wall0");
		wall1Layer = map.getLayer("wall1");
		activeGroup = map.getGroup("active");
		WID = map.wid;
		HEI = map.hei;
		nbRoomsX = Std.int(WID / (RWID - 1));
		nbRoomsY = Std.int(HEI / (RHEI - 1));
		tiles = [];
		spikePos = [];
		for(j in 0...HEI) {
			tiles[j] = [];
			for(i in 0...WID) {
				var ground0Tile = ground0Layer.getTileAt(i, j);
				var ground0TileCol = Collision.TILE_COLLISIONS[ground0Tile];
				var overTile = overLayer.getTileAt(i, j);
				var overTileCol = Collision.TILE_COLLISIONS[overTile];
				var wall0TileCol = Collision.TILE_COLLISIONS[wall0Layer.getTileAt(i, j)];
				var wall1TileCol = Collision.TILE_COLLISIONS[wall1Layer.getTileAt(i, j)];
				var col = NONE;
				if(ground0Tile == 0) {
					col = HOLE;
				} else {
					if(wall1TileCol != NONE) {
						col = wall1TileCol;
					} else if(wall0TileCol != NONE) {
						col = wall0TileCol;
					} else if(ground0TileCol != NONE) {
						col = ground0TileCol;
					}
				}
				tiles[j][i] = col;
				if(overTile == 16) {
					overLayer.setTileAt(i, j, 0);
					spikePos.push({x:i, y:j});
				}
			}
		}
		overLayer.render(); //cleans spikes on tiles
		var bd = wall0Layer.bmp.bitmapData;
		bd.applyFilter(bd, bd.rect, new Point(0, 0), new DropShadowFilter(1., -90, 0xFF000000, 1., 1., 8., 1., 1, true));
		bd.applyFilter(bd, bd.rect, new Point(0, 0), new DropShadowFilter(1., 45, 0xFF000000, .2, 1., 1., 1., 1, false));
		bd.applyFilter(bd, bd.rect, new Point(0, 0), new DropShadowFilter(1., 135, 0xFF000000, .2, 1., 1., 1., 1, false));
	}
	public function loadEntities(idx:Int, idy:Int) {
		if(idx < 0 || idy < 0 || idx >= nbRoomsX || idy >= nbRoomsY) return false;
		var nextRoomX = idx * (RWID - 1) * 16;
		var nextRoomY = idy * (RHEI - 1) * 16;
		for(pos in spikePos) {
			var tx = pos.x;
			var ty = pos.y;
			if(tx >= idx * (RWID - 1) && tx < (idx + 1) * (RWID - 1) && ty >= idy * (RHEI - 1) && ty < (idy + 1) * (RHEI - 1)) {
				var s = new Spike(tx, ty);
				s.roomId = ROOMID;
				Game.CUR.addEntity(s);
			}
		}
		for(o in activeGroup.objects) {
			var x = Std.parseFloat(o.properties.get("x"));
			var y = Std.parseFloat(o.properties.get("y"));
			var wid = Std.parseFloat(o.properties.get("width"));
			var hei = Std.parseFloat(o.properties.get("height"));
			if(x > nextRoomX && y > nextRoomY && x < nextRoomX + Const.WID && y < nextRoomY + Const.HEI) {
				var tx = Std.int(x / 16);
				var ty = Std.int(y / 16);
				var e : Entity = null;
				switch(o.type) {
					case "Thwomp":
						e = new Thwomp(tx, ty);
					case "Button":
						var facesRight = getCollision(tx+1, ty) == NONE;
						var id = Std.parseInt(o.properties.get("id"));
						e = new Button(tx + (facesRight?0:1), ty, facesRight, id);
					case "Door":
						var id = Std.parseInt(o.properties.get("id"));
						e = new Door(this, tx, ty, Std.int(wid) >> 4, Std.int(hei) >> 4, id);
					default:
						
				}
				if(e != null) {
					e.roomId = ROOMID;
					Game.CUR.addEntity(e);
				}
			}
		}
		return true;
	}
	public function reloadEntities() {
		Game.CUR.clearEntities(true);
		loadEntities(roomIdX, roomIdY);
	}
	public function nextRoom(dir:Const.DIR) {
		ROOMID++;
		var dx = (dir == RIGHT ? 1 : (dir == LEFT ? -1 : 0));
		var dy = (dir == DOWN ? 1 : (dir == UP ? -1 : 0));
		Game.CUR.hero.computeSpawnPos(dir == UP || dir == DOWN);
		closeRoom(dir);
		setRoomId(roomIdX + dx, roomIdY + dy);
		loadEntities(roomIdX, roomIdY);
		Game.CUR.lock();
		Game.CUR.moveCameraTo(posX, posY, .5, function() {
			Game.CUR.unlock();
			for(e in Game.CUR.entities) {
				if(e != Game.CUR.hero && e.roomId != -1) {
					if(e.roomId != ROOMID) {
						e.delete();
						Game.CUR.entities.remove(e);
					}
				}
			}
		});
		return true;
	}
	function closeRoom(dir:Const.DIR) {
		var tx = roomIdX * (RWID - 1);
		var ty = roomIdY * (RHEI - 1);
		if(dir == LEFT || dir == RIGHT) {
			var x = tx + (dir == RIGHT ? RWID-2:1);
			for(j in 0...10) {
				tiles[j + ty][x] = FULL;
			}
		} else {
			var y = ty + (dir == DOWN ? RHEI-2:1);
			for(i in 0...15) {
				tiles[y][i + tx] = FULL;
			}
		}
	}
	function setRoomId(idx:Int, idy:Int) {
		roomIdX = idx;
		roomIdY = idy;
		posX = idx * (RWID - 1) * 16;
		posY = idy * (RHEI - 1) * 16;
	}
	public inline function isOnMap(x:Int, y:Int) {
		return x >= 0 && y >= 0 && x < WID && y < HEI;
	}
	public function getCollision(x:Int, y:Int) {
		if(!isOnMap(x, y)) {
			return NONE;
		}
		return tiles[y][x];
	}
	public function setCollision(x:Int, y:Int, type:TILE_COLLISION_TYPE) {
		if(!isOnMap(x, y)) return;
		tiles[y][x] = type;
	}
	public function getHeight(x:Int, y:Int) {
		if(!isOnMap(x, y)) {
			return 0;
		}
		return 0;
	}
	public function getCollisionAt(x:Float, y:Float) {
		return getCollision(Std.int(x / 16), Std.int(y / 16));
	}
	public function getHeightAt(x:Float, y:Float) {
		var tx = Std.int(x) >> 4;
		var ty = Std.int(y) >> 4;
		return getHeight(tx, ty);
	}
	public function tileCollides(x:Int, y:Int) {
		return getCollision(x, y) == FULL;
	}
	public function pointCollides(x:Float, y:Float) {
		return tileCollides(Std.int(x) >> 4, Std.int(y) >> 4);
	}
	public function entityCollides(e:Entity, x:Float, y:Float) {
		//y -= 16 * getHeightAt(x, y);
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y - e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x + e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		if(tileCollides(Std.int(x - e.cradius) >> 4, Std.int(y + e.cradius) >> 4)) return true;
		return false;
	}
	public function entityCollidesFully(e:Entity, x:Float, y:Float, col:Collision.TILE_COLLISION_TYPE) {
		if(getCollisionAt(x - e.cradius, y - e.cradius) != col) return false;
		if(getCollisionAt(x + e.cradius, y - e.cradius) != col) return false;
		if(getCollisionAt(x + e.cradius, y + e.cradius) != col) return false;
		if(getCollisionAt(x - e.cradius, y + e.cradius) != col) return false;
		return true;
	}
	public function renderLighting() {
		dark = new Sprite();
		dark.graphics.beginFill(0x0);
		dark.graphics.drawRect(0, 0, Const.WID, Const.HEI);
		dark.graphics.endFill();
		dark.alpha = 1.;
		dark.blendMode = BlendMode.LAYER;
		Game.CUR.frontlm.addChild(dark, 0);
		light = new Shape();
		light2 = new Shape();
		var g = light.graphics;
		var g2 = light2.graphics;
		g.beginFill(0xFFFFFF);
		g2.beginFill(0xFFFFFF);
		g.drawCircle(0, 0, 100);
		g2.drawCircle(0, 0, 80);
		g.endFill();
		g2.endFill();
		light.alpha = .4;
		light2.alpha = .6;
		light.blendMode = light2.blendMode = BlendMode.ERASE;
		dark.addChild(light);
		dark.addChild(light2);
	}
}