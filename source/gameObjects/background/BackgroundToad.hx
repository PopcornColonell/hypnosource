package gameObjects.background;

import flixel.FlxSprite;
import flixel.addons.editors.spine.FlxSpine;

class BackgroundToad extends FlxSprite {
    public function new() {
        super();

		frames = Paths.getSparrowAtlas('characters/mx/TOAD_WITH_A_TRUMPET');
        animation.addByPrefix('idle', 'TOAD', 24, false);
    }

    var elapsedTotal:Float = 0;
    override public function update(elapsed:Float) {
		elapsedTotal += elapsed;
		angle = Math.sin(((elapsedTotal / (1/60)) * Math.PI)) * 24;
        super.update(elapsed);
    } 
}