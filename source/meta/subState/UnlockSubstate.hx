package meta.subState;

import flixel.util.typeLimit.OneOfTwo;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.display.BlendMode;
import flixel.text.FlxText;
import meta.data.font.Alphabet;
import flixel.util.FlxColor;
import gameObjects.userInterface.menu.Textbox;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.dependency.FNFSprite;

using StringTools;

typedef Unlockable = {
	var unlocks:Array<String>;
	var onComplete:Void->Void;
}
class UnlockSubstate extends MusicBeatSubState {

	public var unlocks:Array<String> = [];
	public var onComplete:Void->Void;
	public var youCanSpamConfirmNow:Bool = true;

	var newLock:LockSprite;
	var textbox:Textbox;
	var textGroup:FlxTypedGroup<FlxText>;
	var unlockText:Alphabet;

	/**
	 * I was originally just gonna shove the information into queue new unlock but
	 * APPARENTLY YOU CANT STORE FUNCTIONS IN SAVE FILES so that throws a wrench into everything.
	 * my bandage solution is to just assign the functions in code and then tie them to names
	 * so that you can call an unlock by a name
	 */
	public static var unlockablesMap:Map<String, Unlockable> = [
		'freeplay' => {
			unlocks: ['The Shop', 'Freeplay', 'The Pokedex'],
			onComplete: function(){
				FlxG.save.data.mainMenuOptionsUnlocked.push('freeplay');
				FlxG.save.data.mainMenuOptionsUnlocked.push('pokedex');
			}
		}
	];

	public static function queueNewUnlock(unlockName:String) {
		if (FlxG.save.data.doneUnlocks == null || !FlxG.save.data.doneUnlocks.contains(unlockName)) {
			FlxG.save.data.queuedUnlocks.push(unlockName);
			trace(FlxG.save.data.queuedUnlocks);
			FlxG.save.flush();
		}
	}
	
	var curUnlockable:String = '';

    public function new(?unlockableName:String) {
        super();

		var unlockable:Unlockable = unlockablesMap[unlockableName];
		if (unlockable != null) {
			this.unlocks = unlockable.unlocks;
			this.onComplete = unlockable.onComplete;
		}
		curUnlockable = unlockableName;
		
		var blackBackground:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackBackground.setGraphicSize(FlxG.width, FlxG.height);
		blackBackground.screenCenter();
		blackBackground.alpha = 0;
		blackBackground.scrollFactor.set();
		add(blackBackground);

		textbox = new Textbox(0, 0);
		textbox.scale.set(3, 3);
		// textbox.boxWidth = 24;
		// textbox.boxHeight = 12;
		textbox.screenCenter();
		textbox.alpha = 0;
		add(textbox);

		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);

		FlxTween.tween(blackBackground, {alpha: 0.75}, 0.35, {ease: FlxEase.quintOut});
		FlxTween.tween(textbox, {alpha: 1, boxWidth: 24, boxHeight: 12}, 0.75, {ease: FlxEase.elasticOut, onComplete: function(tween:FlxTween){
			unlockText = new Alphabet(0, 64, "YOU HAVE UNLOCKED", true, false, false);
			add(unlockText);
			unlockText.isMenuItem = false;
			unlockText.screenCenter(X);
			unlockText.forEach(function(alphaChar:AlphaCharacter){
				//
				alphaChar.scale.set(0, 0);
				FlxTween.tween(alphaChar, {"scale.x": 1, "scale.y": 1}, 2.25, {ease: FlxEase.elasticOut, onUpdate: function(tween:FlxTween){
					alphaChar.x = (unlockText.x + alphaChar.posX);
				}});
			});
			FlxTween.tween(textbox, {y: textbox.y + 80,}, 0.75, {ease: FlxEase.circInOut, onComplete: function(tween:FlxTween){
				//
				newLock = new LockSprite(true);
				add(newLock);
				newLock.setPosition(textbox.x + textbox.width / 4 - newLock.width / 2, textbox.y - newLock.height / 2);
				newLock.alpha = 0;
				newLock.scale.set(0, 0);
				FlxTween.tween(newLock, {alpha: 1, "scale.x": 1, "scale.y": 1}, 0.25, {ease: FlxEase.circOut});
				for (i in 0...unlocks.length + 1) {
					var newText:FlxText = new FlxText(0, 0, 16 * textbox.boxWidth - 32);
					newText.setFormat(Paths.font('poketext.ttf'), 8, FlxColor.BLACK);
					if (i < unlocks.length) {
						newText.text = '* "${unlocks[i]}"';
						newText.setPosition(Std.int(textbox.x + 16), Std.int(textbox.y + (32 * (i - (unlocks.length / 2)))));
					} else {
						newText.text = 'Press ';
						var keyArray = cast(Init.gameControls.get('ACCEPT')[0], Array<Dynamic>);
						for (i in 0...keyArray.length) {
							if (i > 0 && i < keyArray.length - 1) {
								newText.text += ', ';
							} else 
							if (i == keyArray.length - 1)
								newText.text += ' or ';
							var key:Dynamic = keyArray[i];
							if (key != null) {
								var keyDisplay:FlxKey = key;
								newText.text += keyDisplay.toString();
							}
						}
						newText.text += ' to continue';
						newText.setPosition(Std.int(textbox.x + 16), Std.int(textbox.y + (textbox.height / 2) - 56));
					}
					newText.alpha = 0;
					newText.x += FlxG.width / 8;
					newText.scale.set(3, 3);
					textGroup.add(newText);
					FlxTween.tween(newText, {alpha: 1, x: newText.x - FlxG.width / 8}, 0.25, {ease: FlxEase.circOut, startDelay: 0.05 * i});
				}
			}});
		}});
    }

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (youCanSpamConfirmNow) {
			if (controls.ACCEPT) {
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
				for (i in 0...textGroup.members.length) {
					var text:FlxText = textGroup.members[i];
					FlxTween.cancelTweensOf(text);
					FlxTween.tween(text, {alpha: 0}, 0.5, {ease: FlxEase.sineOut});
				}
				if (unlockText != null) {
					unlockText.forEach(function(alphaChar:AlphaCharacter){
						//
						FlxTween.cancelTweensOf(alphaChar);
						FlxTween.tween(alphaChar, {"scale.x": 1.25, "scale.y": 1.25, alpha: 0}, 0.5, {ease: FlxEase.sineOut, onUpdate: function(tween:FlxTween){
							alphaChar.x = (unlockText.x + alphaChar.posX);
						}});
					});
				}
				FlxTween.cancelTweensOf(textbox);
				if (newLock != null) {
					FlxTween.cancelTweensOf(newLock);
					newLock.unlock();
				}
				FlxTween.tween(textbox, {alpha: 0, "scale.x": 3.5, "scale.y": 3.5}, 0.5, {ease: FlxEase.sineOut});
				new FlxTimer().start(1.25, function(timer:FlxTimer){
					// closing statements
					unlockablesMap[curUnlockable].onComplete();
					if (FlxG.save.data.queuedUnlocks.contains(curUnlockable)) {
						FlxG.save.data.queuedUnlocks.splice(curUnlockable, 1);
						FlxG.save.data.doneUnlocks.push(curUnlockable);
						FlxG.save.flush();
					}
					close();
				});
				youCanSpamConfirmNow = false;
			}
		}
	}
}

class LockSprite extends FNFSprite {
    public var lockIdentifier:Int = 0;
	public var zDepth:Float = 0;
	public var locked:Bool = true;
	public var dark:Bool = false;
	//
    public function new(?dark:Bool = false) {
        super();
		this.dark = dark;
		if (dark)
	    	frames = Paths.getSparrowAtlas('ui/base/darkunlocked');
		else frames = Paths.getSparrowAtlas('ui/base/unlocked');
		animation.addByPrefix('lock', 'lock', 24, true);
        animation.addByPrefix('unlock', 'unlock', 24, false);
        addOffset('unlock', -4, 32);
        animation.play('lock');
		antialiasing = true;
    }

    public function unlock() {
		playAnim('unlock', true);
        new FlxTimer().start(0.1, function(timer:FlxTimer) {
			var newLock:LockSprite = new LockSprite(dark);
            newLock.playAnim('unlock', true, false, 12);
            newLock.x = x;
            newLock.y = y;
            FlxG.state.add(newLock);
			FlxTween.tween(newLock, {"scale.x": 1.5, "scale.y": 1.5, alpha: 0}, 0.25, {onComplete: function(tween:FlxTween)
			{
				newLock.kill();
				newLock.destroy();
			}, ease: FlxEase.expoOut});
            //
			FlxTween.tween(this, {alpha: 0}, 0.5, {
				ease: FlxEase.circOut, onComplete: function(tween:FlxTween){
					locked = false;
				}
			});
        });
    }
}