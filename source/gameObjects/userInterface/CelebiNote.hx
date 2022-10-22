package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class CelebiNote extends FlxSprite {
    var initialPosition:FlxPoint;
    public function new(x:Float, y:Float) {
        super(x, y);
		initialPosition = new FlxPoint(x, y);
        directionAngle = FlxG.random.float(0, 360);
    }

    var directionAngle:Float = 0;
    var angleSpeed:Float = 4;
    var angleProgression:Float = 0;

    override public function update(elapsed:Float) {
		directionAngle += angleSpeed * (elapsed / (1 / 60));
		angleProgression += angleSpeed * (elapsed / (1 / 60));
        // if (angleSpeed < 4)
		    // angleSpeed += 0.0125 * (elapsed / (1 / 60));
		x = initialPosition.x + Math.cos((directionAngle * (Math.PI / 180)) / 1.5) * angleProgression;
		y = initialPosition.y + Math.sin((directionAngle * (Math.PI / 180)) / 1.5) * angleProgression;
    }
}