package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxTiledSprite;
import meta.MusicBeat;

class GalleryState extends MusicBeatState {
    public var topBar:FlxSprite;
	public var topStrip:FlxTiledSprite;

    override public function create() {
        super.create();

        topBar = new FlxSprite().makeGraphic(1, 1);
        topBar.setGraphicSize(FlxG.width, 64);
		topStrip = new FlxTiledSprite(Paths.image('gallery/topstrip'), FlxG.width, 0);
        topStrip.height = topStrip.graphic.height;
        
        add(topBar);
        add(topStrip);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

		topStrip.y = topBar.y + topBar.height;
        topStrip.scrollX += (elapsed / (1/60));
    }
}