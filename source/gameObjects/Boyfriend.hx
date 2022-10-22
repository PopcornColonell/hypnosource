package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	public function new()
		super(true);

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			var nameOfAnimation = '';
			var animationFinished:Bool = false;
			if (atlasCharacter != null) {
				nameOfAnimation = atlasAnimation;
				animationFinished = atlasCharacter.anim.finished;
			} else {
				if (animation != null) {
					nameOfAnimation = animation.curAnim.name;
					animationFinished = animation.curAnim.finished;
				}
			}

			if (nameOfAnimation.startsWith('sing'))
				holdTimer += elapsed;
			else
				holdTimer = 0;

			if (nameOfAnimation.endsWith('miss') && animationFinished)
				dance();
			if (nameOfAnimation == 'firstDeath' && animationFinished)
				playAnim('deathLoop');
		}

		super.update(elapsed);
	}

}
