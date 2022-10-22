package meta.state;

import meta.state.menus.StoryMenuState;
import flixel.tweens.FlxEase;
import flixel.addons.text.FlxTypeText;
import meta.MusicBeat.MusicBeatState;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class CartridgeGuyState extends MusicBeatState
{
	var box:FlxSprite;
	var cartridgeGuy:FlxSprite;
	var dialougeText:FlxTypeText;
	var yesText:FlxText;
	var noText:FlxText;

	var curSelect:Int = 0;
	var canSelect:Bool = false;

	var blackOverlay:FlxSprite;

	override public function create():Void
	{
		super.create();

		cartridgeGuy = new FlxSprite(0, 15);
		cartridgeGuy.frames = Paths.getSparrowAtlas('menus/cartridgeguy/CartridgeGuy_Cutscene');
		cartridgeGuy.animation.addByPrefix('idle', 'CG_Cutscene_01', 24, true);
		cartridgeGuy.animation.addByPrefix('game', 'CG_Cutscene_02', 24, true);
		cartridgeGuy.animation.play('idle');
		cartridgeGuy.setGraphicSize(Std.int(cartridgeGuy.width * 0.75));
		cartridgeGuy.updateHitbox();
		cartridgeGuy.screenCenter(X);
		cartridgeGuy.antialiasing = true;
		add(cartridgeGuy);

		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				dialougeText.start(0.055);
			});

		new FlxTimer().start(4, function(tmr:FlxTimer)
			{
				cartridgeGuy.animation.play('game');
				dialougeText.prefix = 'Hello player,';
				dialougeText.resetText('\nwant a free videogame?');
				dialougeText.start(0.055, true);
			});

		new FlxTimer().start(6.5, function(tmr:FlxTimer)
			{
				FlxTween.tween(noText, {alpha: 0.5}, 0.75, {ease: FlxEase.quadInOut});
				FlxTween.tween(yesText, {alpha: 1.0}, 0.75, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {canSelect = true;}});
			});

		box = new FlxSprite(0, 430).loadGraphic(Paths.image('menus/cartridgeguy/textBox'));
		box.screenCenter(X);
		box.antialiasing = true;
		add(box);

		dialougeText = new FlxTypeText(0, 440, 265, 'Hello player,', 64, true);
		dialougeText.setFormat(Paths.font("poke.ttf"), 64, FlxColor.WHITE, CENTER);
		dialougeText.sounds = [FlxG.sound.load(Paths.sound('cartridgeGuy'), 0.2)];
		dialougeText.screenCenter(X);
		add(dialougeText);

		yesText = new FlxText(0, 620, 150, 'Yes', 54);
		yesText.setFormat(Paths.font("poke.ttf"), 54, FlxColor.WHITE, CENTER);
		yesText.screenCenter(X);
		yesText.x -= 100;
		yesText.alpha = 0.0001;
		add(yesText);

		noText = new FlxText(0, 620, 150, 'No', 54);
		noText.setFormat(Paths.font("poke.ttf"), 54, FlxColor.WHITE, CENTER);
		noText.screenCenter(X);
		noText.x += 100;
		noText.alpha = 0.0001;
		add(noText);

		blackOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		blackOverlay.alpha = 0.0001;
		add(blackOverlay);
	}

	override function update(elapsed:Float)
	{
		if (canSelect)
			{
				if (controls.UI_LEFT_P)
					{
						changeSel(-1);
					}
				else if (controls.UI_RIGHT_P)
					{
						changeSel(1);
					}
				else if (controls.ACCEPT)
					{
						if (curSelect == 0)
							{
								FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
								noText.visible = false;
								yesText.visible = false;
								canSelect = false;
								FlxG.sound.play(Paths.sound('cartridgeYes'), 0.4);
								FlxTween.tween(blackOverlay, {alpha: 1.0}, 4.0, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {Main.switchState(this, new StoryMenuState());}});

								if (!FlxG.save.data.cartridgesOwned.contains('LostSilverWeek')) FlxG.save.data.cartridgesOwned.push('LostSilverWeek');
								if (!FlxG.save.data.itemsPurchased.contains('Pokemon Silver')) FlxG.save.data.itemsPurchased.push('Pokemon Silver');

								if (!FlxG.save.data.mainMenuOptionsUnlocked.contains('freeplay')) FlxG.save.data.mainMenuOptionsUnlocked.push('freeplay');
								if (!FlxG.save.data.mainMenuOptionsUnlocked.contains('pokedex')) FlxG.save.data.mainMenuOptionsUnlocked.push('pokedex');
								if (!FlxG.save.data.mainMenuOptionsUnlocked.contains('gallery')) FlxG.save.data.mainMenuOptionsUnlocked.push('gallery');

								FlxG.save.flush();
							}
						if (curSelect == 1)
							{
								FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
								noText.visible = false;
								yesText.visible = false;
								canSelect = false;
								cartridgeGuy.animation.play('idle');
								dialougeText.prefix = '';
								dialougeText.size = 48;
								dialougeText.resetText('If your curiosity calls for more of these, meet me elsewhere.');
								dialougeText.start(0.055, true);

								new FlxTimer().start(5.0, function(tmr:FlxTimer)
									{
										FlxG.sound.play(Paths.sound('cartridgeNo'), 0.4);
										FlxTween.tween(cartridgeGuy, {'scale.x': 0.5, 'scale.y': 0.5, alpha: 0.0001, y: cartridgeGuy.y - 30}, 3.0, {ease: FlxEase.quadOut});
										FlxTween.tween(blackOverlay, {alpha: 1.0}, 4.0, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {Main.switchState(this, new StoryMenuState());}});
									});

								FlxG.save.flush();
							}
					}
			}

		super.update(elapsed);
	}

	function changeSel(amount:Int)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

			curSelect += amount;
			
			if (curSelect <= -1) curSelect = 1;
			else if (curSelect >= 2) curSelect = 0;

			yesText.alpha = 0.5;
			noText.alpha = 0.5;

			if (curSelect == 0) yesText.alpha = 1.0;
			else if (curSelect == 1) noText.alpha = 1.0;
		}
}
