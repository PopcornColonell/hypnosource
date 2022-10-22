package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public var isOldIcon:Bool = false;
	public var isPlayer:Bool = false;

	public var char:String = '';

	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	public var offsetX = 0;
	public var offsetY = 0;

	public var animatedIcon:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon()
	{
		if (isOldIcon = !isOldIcon)
			changeIcon('bf-old');
		else
			changeIcon('bf');
	}

	public function changeIcon(char:String, ?newPlayer:Bool = null)
	{
		if (this.char != char || (newPlayer != null && newPlayer != isPlayer))
		{
			if (newPlayer != null)
				isPlayer = newPlayer;
			
			offsetX = 0;
			offsetY = 0;
			animatedIcon = false;
			//
			var trimmedCharacter:String = char;
			if (trimmedCharacter.contains('-'))
				trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.indexOf('-'));

			var iconPath = char;
			while (!FileSystem.exists(Paths.getPath('images/icons/icon-' + iconPath + '.png', IMAGE)))
			{
				if (iconPath != trimmedCharacter)
					iconPath = trimmedCharacter;
				else
					iconPath = 'face';
				trace('$char icon trying $iconPath instead you fuck');
			}
			
			switch (char) {
				case 'hypno2' | 'hypno-two':
					// LOOK IM LAZY :sob:
					frames = Paths.getSparrowAtlas('icons/Hypno2 Health Icon');

					animation.addByPrefix(char, 'Hypno2 Icon', 24, true);
					animation.play(char);

					animatedIcon = true;
				case 'abomination-hypno':
					frames = Paths.getSparrowAtlas('icons/NEW_ABOMINATION_HYPNO_ICON');

					animation.addByPrefix(char, 'ABOMINATION HYPNO ICON instance 1', 24, true, true);
					animation.play(char);

					setGraphicSize(Std.int(width * 0.44));
					updateHitbox();

					animatedIcon = true;
				case 'gffisk':
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-' + iconPath, 'shitpost');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();

				case 'gold':
					var file:FlxAtlasFrames = Paths.getSparrowAtlas('icons/Gold Health Icon');
					frames = file;
					animation.addByPrefix(char, 'Gold Icon', 24, true);
					animation.play(char);
					offsetY = -12;
				case 'missingno':
					var file:FlxAtlasFrames = Paths.getSparrowAtlas('icons/MissingnoIcons');
					frames = file;
					animation.addByPrefix(char, 'missingno icons', 0, true);
					animation.play(char);
					offsetX = 24;
				case 'wigglytuff': 
					// lmao dont mind me just importing forever's dynamic healthicons
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-wigglytuff');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 4), iconGraphic.height);

					animation.add(char, [0, 1, 2, 3], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
					offsetY = -16;
				case 'wiggles-death-stare' | 'wiggles-terror': 
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-wigglytuff');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 4), iconGraphic.height);

					animation.add(char, [3], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
					offsetY = -16;
				case 'jigglyfront':
					//offsetY = -16;
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-jigglypuff');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				case 'lord-x' | 'mx':
					offsetX = 24;
					offsetY = -16;
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-' + iconPath);
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				case 'beelze':
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-beelze');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);
	
					animation.add(char, [0], 0, false, false);
					animation.play(char);
					updateHitbox();
				case 'beelzescary':
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-beelze');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);
	
					animation.add(char, [1], 0, false, false);
					animation.play(char);
					updateHitbox();
				case 'hypno-cards':
					offsetX = 24;
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-' + iconPath);
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				case 'smol-hypno':
					var file:FlxAtlasFrames = Paths.getSparrowAtlas('icons/SmallHypnoIcons');
					frames = file;
					animation.addByIndices(char, 'SmallHypnoIcons instance 1',[0,4], "", 24, false, isPlayer);
					animation.play(char);
				case 'alexis':
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-alexis');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				case 'glitchy-bf':
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-bf');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				case 'steven-front' | 'steven-bed' | 'steven-fp' | 'steven-start':
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-steven');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				case 'mike-bed' | 'mike-fp':
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-mike');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				case 'grey' | 'grey-cold':
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-grey');
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				default:
					var iconGraphic:FlxGraphic = Paths.image('icons/icon-' + iconPath);
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);

					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
				
			}
			this.char = char;

			updateHitbox();
			if (char == 'gold') {
				setGraphicSize(Std.int(width * 0.8));
				updateHitbox();
			}
			if (char == 'silver')
				offsetY = -16;
			if (char == 'glitchy-red') offsetY = -15;
			initialWidth = width;
			initialHeight = height;

			antialiasing = true;
			if (char.endsWith('-pixel') || char == 'missingno')
				antialiasing = false;
		}
	}

	public function getCharacter():String
		return char;
}
