package meta.subState;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatSubState;
import meta.state.PlayState;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;

class PastaNightSelect extends MusicBeatSubState {
    public static var selectCam:FlxCamera;
    var characters:Array<String> = ['MX', 'LordX', 'Hypno'];
    var characterSprites:Array<Array<FlxSprite>> = [];
    var selectorArrow:FlxSprite;
    var displacementList:Array<Int> = [-4,2,0];
	var crt:ShaderFilter;
	override public function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.music('PastaNightSelect'), 1, true);
		
		selector = -1;
		selectCam = new FlxCamera(0, 0, 768, 672);
		FlxG.cameras.reset(selectCam);
		
		crt = new ShaderFilter(new GraphicsShader("", Paths.shader('crt')));
		selectCam.setFilters([crt]);
		// lmao
		selectCam.x += (FlxG.width / 2 - selectCam.width / 2);
		selectCam.y += (FlxG.height / 2 - selectCam.height / 2);

		var blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(blackBG);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/base/pasta/PastaSelect_BG'));
        bg.setGraphicSize(Std.int(bg.width * 3));
		bg.setPosition(selectCam.width / 2 - bg.width / 2, selectCam.height / 2 - bg.height / 2);
        add(bg);
        // bg.cameras = [selectCam];

		for (i in 0...characters.length) {
			characterSprites[i] = [];
            for (j in 0...3) {
				var charSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/base/pasta/PastaSelect_${characters[i]}_0${j+1}'));
                if (j == 1)
                   charSprite.visible = false; 
				charSprite.setGraphicSize(Std.int(charSprite.width * 3));
				charSprite.setPosition(bg.x + bg.width / 2 - charSprite.width / 2, bg.y + bg.height / 2 - charSprite.height / 2);
				charSprite.x += (i - 1) * (3 * 45) + 3;
				charSprite.x = Std.int(charSprite.x);
				charSprite.y = (176 * 3) - charSprite.height + (displacementList[i]*3);
				add(charSprite);
				characterSprites[i].push(charSprite);
            }
        }

		selectorArrow = new FlxSprite().loadGraphic(Paths.image('UI/base/pasta/PastaSelect_Arrow'));
		selectorArrow.setGraphicSize(Std.int(selectorArrow.width * 3));
        add(selectorArrow);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		updateSelection(0);
    }

    public static var selector:Int = -1;
    public var oldSelector:Int = 0;
	public var totalElapsed:Float = 0;
    override public function update(elapsed:Float) {
		totalElapsed += elapsed;
		if (crt != null)
			crt.shader.data.time.value = [totalElapsed];
		
        if (controls.UI_LEFT_P)
			updateSelection(selector - 1);
        if (controls.UI_RIGHT_P)
			updateSelection(selector + 1);
		
        if (controls.ACCEPT) {
            canSelect = false;
			characterSprites[selector][0].visible = false;
			characterSprites[selector][2].visible = false;
			characterSprites[selector][1].visible = true;
            new FlxTimer().start(0.5, function(tmr:FlxTimer){
				characterSprites[selector][1].visible = false;
				characterSprites[selector][0].visible = true;
				PlayState.selectedPasta = true;
				FlxG.sound.music.stop();
				FlxG.sound.music = null;
                FlxG.switchState(new PlayState());
            });
        }

        super.update(elapsed);
    }

    var canSelect:Bool = true;

    function updateSelection(selection:Int) {
		if (selection != selector && canSelect)
		{
			selector = selection;
			if (selector > characters.length - 1)
				selector = 0;
			else if (selector < 0)
				selector = characters.length - 1;
			// selection
			for (i in 0...characters.length)
				characterSprites[i][2].visible = true;
			characterSprites[selector][2].visible = false;

			selectorArrow.setPosition(characterSprites[selector][0].x+characterSprites[selector][0].width/2-selectorArrow.width/2,124*3);
		}
		
    }
}