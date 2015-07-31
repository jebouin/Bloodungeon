package ;
class TiledGroup {
	public var name : String;
	public var objects : Array<TiledObject>;
	public function new(xml:Xml) {
		objects = new Array();
		name = xml.get("name");
		for(child in xml) {
			if(child.nodeType == Xml.Element) {
				if(child.nodeName == "object") {
					objects.push(new TiledObject(child));
				}
			}
		}
	}
}