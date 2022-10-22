package meta.state.menus;

import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import flixel.util.FlxSort;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import sys.FileSystem;
import sys.io.File;
import flixel.util.FlxColor;
import haxe.Json;
import meta.MusicBeat.MusicBeatState;
import meta.data.Highscore;

typedef Offsets = {
    var x:Float; 
    var y:Float;
}

typedef PokeData = {
    var name:String;
    var dex:Int;
    var height:String;
    var weight:String;
    var scale:Float;
    var offset:Offsets;
    var tagline:String;
    var desc:String;
} 

class PokedexState extends MusicBeatState {

    var dexArray:Array<PokeData> = [];
    var folderList:Array<String> = CoolUtil.returnAssetsLibrary('images/pokedex', 'assets');
    
    var pokemonSprites:FlxTypedGroup<FlxSprite>;
    //var pokemonNameBoxes:FlxTypedGroup<FlxSprite>;
    var pokemonNames:FlxTypedGroup<FlxText>;

    var nameText:FlxText;
    var taglineText:FlxText;

    var altBg:FlxSprite;
    var altBgText:FlxText;

    var altBgName:FlxText;
    var altTagline:FlxText;
    var altDescription:FlxText;
    var altHtWt:FlxText;

    var maxSelect:Int = 0;
    var curSelect:Int = 0;

    var inSubMenu:Bool = false;

    var scale:Float = 3.05732484076;

    var pokeDexedCharacters:Array<String> = ['1'];

    static final unlockedCharacters:Map<String, Array<String>> = [ //thank you shrubs, very cool!
		'Left-Unchecked' => ['2'],
		'Lost-Cause' => ['3'],
        'Frostbite' => ['5', '6', '7'],
        'Insomnia' => ['8', '9'],
        'Monochrome' => ['4'],
        'Missingno' => ['10'],
        'Brimstone' => ['11'],
        'Amusia' => ['14', '15'],
        'Dissension' => ['12'],
        'Purin' => ['17', '18'],
        'Death-Toll' => ['16'],
        'Isotope' => ['13'],
        'Bygone-Purpose' => [],
        'Pasta-Night' => ['22', '23', '24'],
        'Shinto' => ['19', '20'],
        'Shitno' => ['21'],
	];

    var glitch:ShaderFilter;

    var elapsedTime:Float = 0;

    override public function create() {
        super.create();

        glitch = new ShaderFilter(new GraphicsShader("", Paths.shader('glitch')));

        trace('maxSelect: ' + maxSelect);

        FlxG.sound.playMusic(Paths.music('PokedexTheme'), 0.0, true);
		FlxG.sound.music.fadeIn(0.5, 0, 1);

        var bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/pokedex/BG'));
        bg.antialiasing = false;
        bg.scale.set(80, 80);
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        var boxes = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/pokedex/boxes'));
        boxes.antialiasing = false;
        boxes.scale.set(scale, scale);
        boxes.updateHitbox();
        boxes.screenCenter(X);
        add(boxes);

        var backBtn = new FlxSprite(160, 595).loadGraphic(Paths.image('menus/pokedex/back'));
        backBtn.antialiasing = false;
        backBtn.scale.set(scale, scale);
        backBtn.updateHitbox();
        add(backBtn);

        var arrowUp:FlxSprite = new FlxSprite(910, 25).loadGraphic(Paths.image('UI/pixel/selector'));
		arrowUp.setGraphicSize(Std.int(arrowUp.width * 3));
		arrowUp.updateHitbox();
		arrowUp.antialiasing = false;
        arrowUp.angle = -90;
        add(arrowUp);

        var arrowDown:FlxSprite = new FlxSprite(910, 485).loadGraphic(Paths.image('UI/pixel/selector'));
		arrowDown.setGraphicSize(Std.int(arrowDown.width * 3));
		arrowDown.updateHitbox();
		arrowDown.antialiasing = false;
        arrowDown.angle = 90;
        add(arrowDown);

        pokemonSprites = new FlxTypedGroup<FlxSprite>();
        add(pokemonSprites);

        pokemonNames = new FlxTypedGroup<FlxText>();
        add(pokemonNames);
        
		for (i in 0...CoolUtil.difficultyArray.length) {
			for (j in unlockedCharacters.keys())
				if (Highscore.getScore(j, i) != 0) {
					for (h in unlockedCharacters[j])
						if (!pokeDexedCharacters.contains(h))
							pokeDexedCharacters.push(h);
				}
		}

        for (i in folderList) {
            trace('found folder: ' + i);
            if (FileSystem.exists(Paths.getPath('images/pokedex/${i}/info.json', TEXT))) 
            {
                var rawJson = File.getContent(Paths.getPath('images/pokedex/${i}/info.json', TEXT));
                var swagShit:PokeData = cast Json.parse(rawJson).info;

                dexArray.push(swagShit);

                trace('Got Pokedex entry for ${i}');
            } else {
                trace('No Pokedex entry for ${i}');
            }
        }

        dexArray.sort(function(swagShit1:PokeData, swagShit2:PokeData):Int
        {
            return FlxSort.byValues(FlxSort.ASCENDING, swagShit1.dex, swagShit2.dex);
        });

        for (i in 0...dexArray.length)
            {
                var daPoke:String = dexArray[i].name;

                trace('found folder: ' + daPoke);
                if (FileSystem.exists(Paths.getPath('images/pokedex/'+ daPoke + '/info.json', TEXT))) {
                    var rawJson = File.getContent(Paths.getPath('images/pokedex/' + daPoke + '/info.json', TEXT));
                    var swagShit:PokeData = cast Json.parse(rawJson).info;

                    var newOffset:Offsets = cast Json.parse(rawJson).info.offset;
    
                    var char = new FlxSprite().loadGraphic(Paths.image('pokedex/' + daPoke + '/char'));
                    char.antialiasing = false;
                    char.ID = maxSelect;
                    char.x += newOffset.x;
                    char.y += newOffset.y;
                    char.scale.set(swagShit.scale, swagShit.scale);
                    char.updateHitbox();
                    pokemonSprites.add(char);
    
                    var name:FlxText = new FlxText(160 + (189 * scale), 59 + (6 * scale) + (19 * scale * maxSelect), 122 * scale, swagShit.name);
                    name.setFormat(Paths.font("poketext.ttf"), 16, FlxColor.BLACK, "center");
                    name.antialiasing = false;  
                    name.ID = maxSelect;
                    pokemonNames.add(name); 
                    trace(name.y);
    
                    if (!pokeDexedCharacters.contains(Std.string(swagShit.dex)) && swagShit.dex <= 24) name.text = '???';
                    maxSelect++;
                }
            }

        nameText = new FlxText(160 + (9 * scale), 3 * scale, 162 * scale, ' ');
        nameText.antialiasing = false;
        nameText.setFormat(Paths.font("poke.ttf"), 64, FlxColor.BLACK, "center");
        add(nameText);

        taglineText = new FlxText(160 + (9 * scale), 21 * scale, 162 * scale, ' ');
        taglineText.antialiasing = false;
        taglineText.setFormat(Paths.font("poke.ttf"), 48, FlxColor.BLACK, "center");
        add(taglineText);

        altBg = new FlxSprite(0, 579).loadGraphic(Paths.image('menus/pokedex/altBG'));
        altBg.antialiasing = false;
        altBg.scale.set(scale, scale);
        altBg.updateHitbox();
        altBg.screenCenter(X);
        add(altBg);

        altBgText = new FlxText(0, 0, 0, 'DESCRIPTION');
        altBgText.antialiasing = false;
        altBgText.setFormat(Paths.font("poketext.ttf"), 40, FlxColor.BLACK, "center");
        add(altBgText);
        altBgText.screenCenter(X);

        altBgName = new FlxText(200, 0, 0, '');
        altBgName.antialiasing = false;
        altBgName.setFormat(Paths.font("poketext.ttf"), 48, FlxColor.BLACK, LEFT);
        add(altBgName);

        altTagline = new FlxText(200, 0, 0, '');
        altTagline.antialiasing = false;
        altTagline.setFormat(Paths.font("poketext.ttf"), 40, FlxColor.BLACK, LEFT);
        add(altTagline);

        altDescription = new FlxText(200, 0, 900, '');
        altDescription.antialiasing = false;
        altDescription.setFormat(Paths.font("poketext.ttf"), 28, FlxColor.BLACK, LEFT);
        add(altDescription);

        altHtWt = new FlxText(200, 0, 900, '');
        altHtWt.antialiasing = false;
        altHtWt.setFormat(Paths.font("poketext.ttf"), 32, FlxColor.BLACK, LEFT);
        add(altHtWt);

        moveDexSel(0);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        elapsedTime += FlxG.elapsed;

        var up:Bool = controls.UI_UP_P;
		var down:Bool = controls.UI_DOWN_P;
		var accept:Bool = controls.ACCEPT;
        var back:Bool = controls.BACK;

		if (up && !inSubMenu)
			moveDexSel(-1);
		if (down && !inSubMenu)
			moveDexSel(1);
        if (back)
			Main.switchState(this, new MainMenuState());
        if (accept)
            toggleSubDexMenu();

        altBgText.y = altBg.y + 55;
        altBgName.y = altBg.y + 190;
        altTagline.y = altBg.y + 265;
        altHtWt.y = altBg.y + 335;
        altDescription.y = altBg.y + 450;

        if (inSubMenu && altBg.y > 7) altBg.y -= elapsed / (0.05 / 60);
        if (!inSubMenu && altBg.y < 579) altBg.y += elapsed / (0.05 / 60);

        glitch.shader.data.prob.value = [0.01];
        glitch.shader.data.time.value = [elapsedTime * 2];
    }

    function moveDexSel(diff:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelect += diff;

		if (curSelect >= maxSelect)
            curSelect = 0;
        if (curSelect < 0)
            curSelect = maxSelect - 1;

        //trace(dexArray[curSelect].name);
        if (pokeDexedCharacters.contains(Std.string(dexArray[curSelect].dex)) || curSelect >= 24)
            {
                nameText.text = (dexArray[curSelect].name == null ? 'NULL' : dexArray[curSelect].name);
                taglineText.text = (dexArray[curSelect].tagline == null ? 'NULL' : dexArray[curSelect].tagline);
        
                altBgName.text = (dexArray[curSelect].name == null ? 'NULL' : dexArray[curSelect].name);
                altTagline.text = (dexArray[curSelect].tagline == null ? 'NULL' : dexArray[curSelect].tagline);
                altDescription.text = (dexArray[curSelect].desc == null ? 'NULL' : dexArray[curSelect].desc);
                altHtWt.text = 'HT ' + (dexArray[curSelect].height == null ? 'NULL' : dexArray[curSelect].height) + '    WT ' + (dexArray[curSelect].weight == null ? 'NULL' : dexArray[curSelect].weight);
            }
        else
            {
                nameText.text = '???';
                taglineText.text = '???';
            }

        pokemonSprites.forEach(function(sprite:FlxSprite) {
            sprite.alpha = 0.0001;
            if (sprite.ID == (curSelect) && (pokeDexedCharacters.contains(Std.string(dexArray[curSelect].dex)) || curSelect >= 24)) {
                trace('found sprite using ' + sprite); 
                sprite.alpha = 1;
            }
        });

        pokemonNames.forEach(function(spr:FlxSprite)
            { 
                spr.visible = false;

                var distFromEnd:Int = maxSelect - curSelect;
                trace(distFromEnd);
                if (curSelect > 3)
                    {
                        spr.y = (77.34 + ((58.09 * spr.ID)) - ( 58.09 * (curSelect - 3)));
                        if (spr.ID >= -3 + curSelect && spr.ID <= 3 + curSelect) spr.visible = true;

                        if (distFromEnd <= 4)
                            {
                                spr.y = (77.34 + ((58.09 * spr.ID)) - (58.09 * (pokemonNames.length - 7)));
                                spr.visible = false;
                                if (spr.ID >= pokemonNames.length - 7 && spr.ID <= pokemonNames.length) spr.visible = true;
                            }

                    }
                else
                    {
                        spr.y = (77.34 + ((58.09 * (spr.ID))));
                        if (spr.ID >= 0 && spr.ID <= 6) spr.visible = true;
                    }
            });

        pokemonNames.forEach(function(spr:FlxSprite) {
            spr.alpha = 1.0;
            if (spr.ID == (curSelect)) 
            {
                spr.alpha = 0.5;
            }
        });

        if (pokeDexedCharacters.contains(Std.string(dexArray[curSelect].dex)))
            {
                switch (dexArray[curSelect].name)
                {
                    case "Missingno" | "Glitchy Red":
                            FlxG.camera.setFilters([glitch]);
                    default:
                            FlxG.camera.setFilters([]);
                }
            }
    }

    function toggleSubDexMenu()
        {
            if (pokeDexedCharacters.contains(Std.string(dexArray[curSelect].dex)) || curSelect >= 24)
                {
                    inSubMenu = !inSubMenu;
                    FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
                }
        }
}