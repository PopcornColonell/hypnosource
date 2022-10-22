package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import meta.CoolUtil;
import meta.InfoHud;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;
import meta.state.menus.StoryMenuState;

using StringTools;

class ClassHUD extends FlxSpriteGroup
{
	// set up variables and stuff here
	var centerMark:FlxText; // small side bar like kade engine that tells you engine info
	public var scoreBar:FlxText;
	public var accuracyBar:FlxText;

	var scoreLast:Float = -1;
	var scoreDisplay:String;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	private var SONG = PlayState.SONG;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	private var stupidHealth:Float = 0;

	public var iconGroup:FlxTypedSpriteGroup<HealthIcon>;
	private var timingsMap:Map<String, FlxText> = [];

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		iconGroup = new FlxTypedSpriteGroup<HealthIcon>();
		// fnf mods
		var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		trace('bury some bitches ${PlayState.buriedNotes}');
		var font:String = "vcr.ttf";
		var fontSize:Int = 16;

		divider = " • ";
		if (!PlayState.buriedNotes) {
			healthBarBG = new FlxSprite(0,
				barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
			healthBarBG.screenCenter(X);
			healthBarBG.scrollFactor.set();
			add(healthBarBG);

			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 7));
			healthBar.scrollFactor.set();
			var colorData:Array<Int> = PlayState.boyfriend.characterData.healthbarColors;
			var bfColor = FlxColor.fromRGB(colorData[0], colorData[1], colorData[2]);
			var colorData:Array<Int> = PlayState.dadOpponent.characterData.healthbarColors;
			var dadColor = FlxColor.fromRGB(colorData[0], colorData[1], colorData[2]);
			healthBar.createFilledBar(dadColor, bfColor);
			// healthBar
			add(healthBar);
			// add(iconGroup);

			scoreBar = new FlxText(FlxG.width / 2, Math.floor(healthBarBG.y + 40), 0, scoreDisplay);
			scoreBar.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
			accuracyBar = new FlxText(FlxG.width / 2, Math.floor(healthBarBG.y + 40), 0, scoreDisplay);
			accuracyBar.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
			scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			accuracyBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			updateScoreText();
			// scoreBar.scrollFactor.set();
			scoreBar.antialiasing = true;
			accuracyBar.antialiasing = true;
			// add(scoreBar);
			// add(accuracyBar);

			var cornerMark:FlxText = new FlxText(0, 0, 0, 'FOREVER ENGINE v${Main.gameVersion}\n');
			cornerMark.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
			cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			add(cornerMark);
			cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
			cornerMark.antialiasing = true;

			centerMark = new FlxText(0, 0, 0,
				'- ${CoolUtil.dashToSpace(PlayState.SONG.song) + " [" + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty)}] -\n');
			centerMark.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE);
			centerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			add(centerMark);
			if (Init.trueSettings.get('Downscroll'))
				centerMark.y = (FlxG.height - centerMark.height / 2);
			else centerMark.y = (FlxG.height / 24) - 24;
			centerMark.screenCenter(X);
			centerMark.antialiasing = true;
		} else {
			font = 'poke.ttf';
			fontSize = 24;
			
			scoreBar = new FlxText(FlxG.width / 2, 4, 0, scoreDisplay, 20);
			scoreBar.setFormat(Paths.font(font), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			accuracyBar = new FlxText(FlxG.width / 2, 4, 0, scoreDisplay, 20);
			accuracyBar.setFormat(Paths.font(font), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			updateScoreText();
			scoreBar.scrollFactor.set();
			accuracyBar.scrollFactor.set();
			// add(scoreBar);
			// add(accuracyBar);

			// curSongName = PlayState.songDisplayName;
			var infoDisplay:String = CoolUtil.dashToSpace(PlayState.songDisplayName) + ' - ' + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
			var engineDisplay:String = "Forever Engine v" + Main.gameVersion;
			var engineBar:FlxText = new FlxText(0, FlxG.height - 30, 0, engineDisplay, 16);
			engineBar.setFormat(Paths.font(font), fontSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			engineBar.updateHitbox();
			engineBar.x = FlxG.width - engineBar.width - 5;
			engineBar.scrollFactor.set();
			add(engineBar);

			centerMark = new FlxText(5, FlxG.height - 30, 0, infoDisplay, 20);
			centerMark.setFormat(Paths.font(font), fontSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			centerMark.scrollFactor.set();
			add(centerMark);
			divider = " - ";
		}

		// counter
		if (Init.trueSettings.get('Counter') != 'None') {
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length) {
				var textAsset:FlxText = new FlxText(5 + (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0,
					'', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font("vcr.ttf"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();
	}

	var curSongName:String = '';
	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (Init.trueSettings.get('Counter') == 'Left');

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (curSongName != PlayState.songDisplayName) {
			var infoDisplay:String = '- ${CoolUtil.dashToSpace(PlayState.songDisplayName) + " [" + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty)}] -\n';
			centerMark.text = infoDisplay;
			centerMark.screenCenter(X);
			curSongName = PlayState.songDisplayName;
			PlayState.songDetails = CoolUtil.dashToSpace(PlayState.songDisplayName) + ' - ' + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
			if (PlayState.isStoryMode)
				PlayState.songDetails = '${StoryMenuState.cartridgeList[PlayState.storyWeek].weekName} - '
					+ CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
		}
	}

	static var divider:String = "";

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		scoreBar.text = 'Score: $importSongScore';
		accuracyBar.text = '';
		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			accuracyBar.text += divider + 'Accuracy: ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
			accuracyBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
			accuracyBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}

		scoreBar.x = Math.floor((FlxG.width / 2) - ((scoreBar.width + accuracyBar.width) / 2));
		accuracyBar.x = scoreBar.x + scoreBar.width;

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys()) {
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
		PlayState.detailsSub = scoreBar.text + accuracyBar.text;
		PlayState.updateRPC(false);
	}

}
