package gameObjects.userInterface.notes;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;

using StringTools;

/*
	import flixel.FlxG;

	import flixel.animation.FlxBaseAnimation;
	import flixel.graphics.frames.FlxAtlasFrames;
	import flixel.tweens.FlxEase;
	import flixel.tweens.FlxTween; 
 */
class UIStaticArrow extends FlxSprite
{
	/*  Oh hey, just gonna port this code from the previous Skater engine 
		(depending on the release of this you might not have it cus I might rewrite skater to use this engine instead)
		It's basically just code from the game itself but
		it's in a separate class and I also added the ability to set offsets for the arrows.

		uh hey you're cute ;)
	 */
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var babyArrowType:Int = 0;
	public var canFinishAnimation:Bool = true;

	public var initialX:Int;
	public var initialY:Int;

	public var xTo:Float;
	public var yTo:Float;
	public var angleTo:Float;

	public var defaultAlpha:Float = (Init.trueSettings.get('Opaque Arrows') || PlayState.assetModifier == 'pixel') ? 1 : 0.8;

	public function new(x:Float, y:Float, ?babyArrowType:Int = 0)
	{
		// this extension is just going to rely a lot on preexisting code as I wanna try to write an extension before I do options and stuff
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();

		this.babyArrowType = babyArrowType;

		updateHitbox();
		scrollFactor.set();
	}

	// literally just character code
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName == 'confirm')
			alpha = 1;
		else
			alpha = 1 * defaultAlpha;

		animation.play(AnimName, Force, Reversed, Frame);
		updateHitbox();

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];

	public static function getArrowFromNumber(numb:Int)
	{
		// yeah no I'm not writing the same shit 4 times over
		// take it or leave it my guy
		var stringSect:String = '';
		switch (numb)
		{
			case(0):
				stringSect = 'left';
			case(1):
				stringSect = 'down';
			case(2):
				stringSect = 'up';
			case(3):
				stringSect = 'right';
			case 4:
				stringSect = 'space';
		}
		return stringSect;
		//
	}

	// that last function was so useful I gave it a sequel
	public static function getColorFromNumber(numb:Int)
	{
		var stringSect:String = '';
		switch (numb)
		{
			case(0):
				stringSect = 'purple';
			case(1):
				stringSect = 'blue';
			case(2):
				stringSect = 'green';
			case(3):
				stringSect = 'red';
			case 4:
				stringSect = 'bell';
		}
		return stringSect;
		//
	}
}

class Strumline extends FlxSpriteGroup {
	//
	public var receptors:FlxTypedSpriteGroup<UIStaticArrow>;
	public var splashNotes:FlxTypedSpriteGroup<NoteSplash>;
	public var notesGroup:FlxTypedSpriteGroup<Note>;
	public var holdsGroup:FlxTypedSpriteGroup<Note>;
	public var allNotes:FlxTypedGroup<Note>;

	public var autoplay:Bool = true;
	public var character:Array<Character> = [];
	public var singingCharacters:Array<Character> = [];
	public var playState:PlayState;
	public var displayJudgements:Bool = false;

	public var keyAmount:Int;
	public var downscroll:Bool;
	public var xPos:Float = 0;
	public var noteSplashes:Bool;

	public var noteWidth:Float = Note.swagWidth;
	public function new(positionX:Float = 0, playState:PlayState, ?character:Array<Character>, ?displayJudgements:Bool = true, ?autoplay:Bool = true,
			?noteSplashes:Bool = false, ?keyAmount:Int = 4, ?downscroll:Bool = false, ?parent:Strumline)
	{
		super(x, y);

		xPos = positionX;

		receptors = new FlxTypedSpriteGroup<UIStaticArrow>();
		splashNotes = new FlxTypedSpriteGroup<NoteSplash>();
		notesGroup = new FlxTypedSpriteGroup<Note>();
		holdsGroup = new FlxTypedSpriteGroup<Note>();

		allNotes = new FlxTypedGroup<Note>();

		this.autoplay = autoplay;
		this.character = character;
		this.playState = playState;
		this.displayJudgements = displayJudgements;
		this.downscroll = downscroll;
		this.noteSplashes = noteSplashes;
		this.keyAmount = keyAmount;

		regenerateStrums();
	}

	public function regenerateStrums() {
		receptors.forEachAlive(function(strum:UIStaticArrow){
			strum.destroy();
		});
		receptors.clear();
		//
		splashNotes.forEachAlive(function(strum:NoteSplash) {
			strum.destroy();
		});
		splashNotes.clear();
		//
		for (i in 0...keyAmount)
		{
			var staticArrow:UIStaticArrow = ForeverAssets.generateUIArrows(-25 + xPos, 25 + (downscroll ? FlxG.height - 200 : 0), i,
				PlayState.assetModifier);
			staticArrow.ID = i;

			noteWidth = Note.swagWidth;
			if (PlayState.buriedNotes) {
				trace('what');
				noteWidth = (32 * (PlayState.daPixelZoom * PlayState.buriedResize));
				if (downscroll)
					staticArrow.y -= 25;
			}

			staticArrow.x -= ((keyAmount / 2) * noteWidth);
			staticArrow.x += (noteWidth * i);
			receptors.add(staticArrow);

			staticArrow.initialX = Math.floor(staticArrow.x);
			staticArrow.initialY = Math.floor(staticArrow.y);
			if (PlayState.bronzongMechanic && i == keyAmount - 1)
				staticArrow.initialY += Math.floor(staticArrow.height);
			staticArrow.angleTo = 0;
			staticArrow.playAnim('static');

			if (!PlayState.buriedNotes) {
				staticArrow.y -= 10;
				staticArrow.alpha = 0;
				FlxTween.tween(staticArrow, {y: staticArrow.initialY, alpha: staticArrow.defaultAlpha}, 1,
					{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else {
				staticArrow.defaultAlpha = 1;
				staticArrow.alpha = staticArrow.defaultAlpha;
			}

			if (noteSplashes) {
				var noteSplash:NoteSplash = ForeverAssets.generateNoteSplashes('noteSplashes', PlayState.assetModifier, PlayState.changeableSkin, 'UI', i);
				splashNotes.add(noteSplash);
			}
		}

		if (PlayState.bronzongMechanic)
		{
			var lastReceptor = receptors.members[receptors.members.length - 1];
			lastReceptor.x = (xPos - lastReceptor.width / 2) + noteWidth / 2;
			//
			if (Init.trueSettings.get('Centered Notefield')) {
				lastReceptor.screenCenter(X);
				lastReceptor.x -= 64;
			}
			//
			for (i in receptors) {
				switch (i.ID)
				{
					case 0:
						i.x = lastReceptor.x - lastReceptor.width / 2;
					case 1:
						i.x = lastReceptor.x - lastReceptor.width / 2 + noteWidth + 10;
					case 2:
						i.x = lastReceptor.x + lastReceptor.width / 2 + noteWidth + 60;
					case 3:
						i.x = lastReceptor.x + lastReceptor.width / 2 + noteWidth * 2 + 70;
					case 4:
						i.x += 74;
				}
			}
		}

		if (Init.trueSettings.get("Clip Style").toLowerCase() == 'stepmania')
			add(holdsGroup);
		add(receptors);
		if (Init.trueSettings.get("Clip Style").toLowerCase() == 'fnf')
			add(holdsGroup);
		add(notesGroup);
		if (splashNotes != null)
			add(splashNotes);
	}

	public function createSplash(coolNote:Note) {
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom);
	}

	public function push(newNote:Note) {
		var chosenGroup = (newNote.isSustainNote ? holdsGroup : notesGroup);
		chosenGroup.add(newNote);
		allNotes.add(newNote);
		chosenGroup.sort(FlxSort.byY, (!Init.trueSettings.get('Downscroll')) ? FlxSort.DESCENDING : FlxSort.ASCENDING);
	}
}
