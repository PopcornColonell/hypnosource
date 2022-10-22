package meta.state.charting;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameObjects.Boyfriend;
import gameObjects.Character;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.FNFSprite;
import meta.state.menus.StoryMenuState;

class CharacterOffsetState extends MusicBeatState {
	var currentState:Array<String> = [
		'idle',
		'singUP',
		'singLEFT',
		'singRIGHT',
		'singDOWN',
		'hit1',
		'hit2',
	];
	var offsetXback:Array<Int> = [0, 0, 0, 0, 0];
	var offsetYback:Array<Int> = [0, 0, 0, 0, 0];
	var offsetXfront:Array<Int> = [0, 0, 0, 0, 0];
	var offsetYfront:Array<Int> = [0, 0, 0, 0, 0];

	var spriteDisplay:FlxText;

	var selectedState:Int = 0;
	var stateDisplay:FlxText;
    
	var back:Boyfriend;
	var front:Boyfriend;

    override public function create() {
        super.create();

		var i = StoryMenuState.cartridgeList[0];
		var fakeBack = new Boyfriend();
		fakeBack.setCharacter(0, 0, 'hypno-cards');
		fakeBack.playAnim('idle');
        fakeBack.screenCenter();
        add(fakeBack);
        fakeBack.alpha = 0.5;

		back = new Boyfriend();
		back.setCharacter(0, 0, 'hypno-cards');
		//
		back.playAnim('idle');
		back.screenCenter();

		front = new Boyfriend();
		front.setCharacter(0, 0, 'hypno-cards-front');
		front.playAnim('idle');
		front.screenCenter();

        add(back);
        add(front);

		stateDisplay = new FlxText(100, 20, 0, 'Current Anim: ', 20);
		add(stateDisplay);
		spriteDisplay = new FlxText(500, 20, 0, 'X: 0', 20);
		add(spriteDisplay);
        
		FlxG.camera.bgColor = FlxColor.GRAY;
        FlxG.camera.zoom = 0.9;
    }

    var isBack:Bool = false;

    override public function update(elapsed:Float) {
        super.update(elapsed);
        
		var currentAnim:String = currentState[selectedState];
		stateDisplay.text = "Current Anim: " + currentAnim;
		spriteDisplay.text = "X Back: " + offsetXback[selectedState] + '\n' + "Y Back: " + offsetYback[selectedState] + '\n' + "X Front: "
			+ offsetXfront[selectedState] + '\n' + "Y Front: " + offsetYfront[selectedState] + '\n';

		if (FlxG.keys.justPressed.SPACE)
		{
			if (selectedState + 1 < currentState.length)
				selectedState++;
			else
				selectedState = 0;
			currentAnim = currentState[selectedState];
			animPlay(currentAnim);
		}

        // var dude:Character = (isBack ? back : front);
        var offsetX:Array<Int> = (isBack ? offsetXback : offsetXfront);
		var offsetY:Array<Int> = (isBack ? offsetYback : offsetYfront);
        if (FlxG.keys.pressed.SHIFT) {
			if (FlxG.keys.justPressed.LEFT)
			{
				offsetX[selectedState]++;
				animPlay(currentAnim);
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				offsetX[selectedState]--;
				animPlay(currentAnim);
			}
			if (FlxG.keys.justPressed.UP)
			{
				offsetY[selectedState]++;
				animPlay(currentAnim);
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				offsetY[selectedState]--;
				animPlay(currentAnim);
			}
        } else {
			if (FlxG.keys.pressed.LEFT)
			{
				offsetX[selectedState]++;
				animPlay(currentAnim);
			}
			if (FlxG.keys.pressed.RIGHT)
			{
				offsetX[selectedState]--;
				animPlay(currentAnim);
			}
			if (FlxG.keys.pressed.UP)
			{
				offsetY[selectedState]++;
				animPlay(currentAnim);
			}
			if (FlxG.keys.pressed.DOWN)
			{
				offsetY[selectedState]--;
				animPlay(currentAnim);
			}
        }
	
		if (FlxG.keys.justPressed.H)
            isBack = !isBack;
    }

    function animPlay(currentAnim:String) {
		back.addOffset(currentAnim, offsetXback[selectedState], offsetYback[selectedState]);
		back.playAnim(currentAnim);
		front.addOffset(currentAnim, offsetXfront[selectedState], offsetYfront[selectedState]);
		front.playAnim(currentAnim);
    }
}