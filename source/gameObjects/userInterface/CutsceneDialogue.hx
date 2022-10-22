package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.data.font.Alphabet;
import meta.state.PlayState;

class CutsceneDialogueSL extends FlxSpriteGroup {

    public var darkness:FlxGraphic;
    public var box:FlxSprite;

    var textProgression:Int = 0;
    var startText:Bool = false;

    var text:Alphabet;
    var state:PlayState;

    var gf:FlxSprite;
    var hypno:FlxSprite;

    var canAccelerate:Bool = true;
    var blackBackground:FlxSprite;
    public function new(state:PlayState) {
        super();   
        this.state = state;

        if (darkness == null) {
            darkness = FlxG.bitmap.create(100, 100, FlxColor.BLACK, true);
            darkness.persist = true;
        }

        blackBackground = new FlxSprite().loadGraphic(darkness);
        blackBackground.setGraphicSize(FlxG.width, FlxG.height);
        blackBackground.updateHitbox();
        add(blackBackground);

        var centerText:Alphabet = new Alphabet(0, FlxG.height / 2, 'BF is missing, GF went out by herself looking for him worried sick...', false, true, false, 1);
        centerText.setPosition(20, FlxG.height / 2 - 200);
		centerText.blend = SUBTRACT;
        centerText.alpha = 0;
        add(centerText);

        gf = new FlxSprite();
        gf.frames = Paths.getSparrowAtlas('dialogue/Dialogue GF');
        gf.animation.addByPrefix('call', 'GF Sprite 1', 24, false);
        gf.animation.addByPrefix('call2', 'GF Sprite 2', 24, false);
        gf.animation.addByPrefix('disappoint', 'GF Sprite 3', 24, false);
        gf.animation.addByPrefix('shock', 'GF Sprite 4', 24, false);
        gf.animation.play('call');
        gf.setGraphicSize(Std.int(gf.width * 0.6));
		gf.antialiasing = Init.trueSettings.get("Antialiasing");
        gf.updateHitbox();
        gf.alpha = 0;
        add(gf);
        
        hypno = new FlxSprite();
        hypno.frames = Paths.getSparrowAtlas('dialogue/Dialogue Hypno');
        hypno.animation.addByPrefix('call', 'Hypno Sprite 1', 24, false);
        hypno.animation.play('call');
        hypno.setGraphicSize(Std.int(hypno.width * 0.5));
        hypno.updateHitbox();
		hypno.antialiasing = Init.trueSettings.get("Antialiasing");
        hypno.alpha = 0;
        add(hypno);

        box = new FlxSprite(70, 370);
		box.frames = Paths.getSparrowAtlas('dialogue/speech_bubble');
		box.scrollFactor.set();
		box.antialiasing = Init.trueSettings.get("Antialiasing");
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		box.animation.play('normal', true);
		box.alpha = 0;
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);

        gf.setPosition(box.x + box.width - (gf.width * 1.25), box.y - (gf.height / 2) + 50);
        hypno.setPosition(box.x + 20, box.y - (hypno.height / 2) - 50);

        // lmfao
        FlxTween.tween(centerText, {alpha: 1}, 0.75, {onComplete: function(tween:FlxTween){
            var newTimer:FlxTimer = new FlxTimer().start(5, function(timer:FlxTimer){
                FlxTween.tween(centerText, {alpha: 0}, 0.75, {onComplete: function(tween:FlxTween){
                    centerText.kill();
                    centerText.destroy();
                }});
                FlxTween.tween(blackBackground, {alpha: 0.5}, 2, {onComplete: function(tween:FlxTween){
                    FlxTween.tween(gf, {alpha: 1}, 0.25);
                    FlxTween.tween(box, {alpha: 1}, 0.25, {onComplete: function(tween:FlxTween){
                        gf.animation.play('call');
                        text = new Alphabet(0, 0, 'Bf???', false, true, false, 0.7);
                        text.setPosition(box.x + 10, box.y + 60);
                        add(text);

                        startText = true;
                    }});
                }});

            });
        }});
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (startText) {
            if (FlxG.keys.pressed.ANY) {
                progressText();
            } else 
			if (text != null && text.swagTypingTimer != null)
				text.swagTypingTimer.time = 0.05;

            if (!canAccelerate && FlxG.keys.justReleased.ANY)
                canAccelerate = true;
        }
    }

	final textArray:Array<String> = [
		'BF!!!',
		'Man, wheres that cute blue dwarf and his\nmagnum dick...', "You're looking for a blue dwarf, child?", "Follow me into the forest, I saw him in\nthere..."];

    function progressText() {
        if (text != null) {
			if (text.finishedLine && FlxG.keys.justPressed.ANY) {
                switch (textProgression) {
                    case 0:
                        gf.animation.play('call2'); 
                        gf.y -= 64;
                    case 1:
                        gf.animation.play('disappoint');   
                        gf.x -= 64;
                    case 2:
                        FlxTween.tween(hypno, {alpha: 1}, 0.25);
                        box.flipX = true;
                    case 3:
                        gf.animation.play('shock');
                }
                
                text.kill();
                text.destroy();
                text = new Alphabet(0, 0, textArray[textProgression], false, true, false, 0.7);
                text.setPosition(box.x + 10, box.y + 60);
                add(text);
                
                textProgression++;
                canAccelerate = false;
                if (textProgression > textArray.length) {
                    FlxTween.tween(blackBackground, {alpha: 0}, 0.25);
                    FlxTween.tween(box, {alpha: 0}, 0.25);
                    FlxTween.tween(hypno, {alpha: 0}, 0.25);
                    FlxTween.tween(gf, {alpha: 0}, 0.25, {onComplete: function(tween:FlxTween){
                        state.startCountdown();
                    }});
                }
            } else
			if (text.swagTypingTimer != null && canAccelerate)
				text.swagTypingTimer.time = 0.01;
        }
        
    }
}