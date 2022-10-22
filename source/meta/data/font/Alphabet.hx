package meta.data.font;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxTypedSpriteGroup<AlphaCharacter>
{
	public var textSpeed:Float = 0.06;
	public var randomSpeed:Bool = false; // When enabled, it'll change the speed of the text speed randomly between 80% and 180%

	public var textSize:Float;

	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var disableX:Bool = false;
	public var controlGroupID:Int = 0;
	public var textIdentifier:Int = 0;
	public var extensionJ:Int = 0;

	public var infiniteShuffle:Bool = false;

	public var textInit:String;

	public var xTo = 100;

	public var isMenuItem:Bool = false;

	public var text:String = "";

	public var _finalText:String = "";
	public var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	public var finishedLine:Bool = false;

	public var zDepth:Float = 1;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public var soundChoices:Array<String> = ["GF_1", "GF_2", "GF_3", "GF_4",];
	public var beginPath:String = "assets/sounds/";
	public var soundChance:Int = 40;
	public var playSounds:Bool = true;
	public var lastPlayed:Int = 0;
	public var canUnown:Bool = true;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, ?canUnown:Bool = true, ?textSize:Float = 1)
	{
		super(x, y);

		this.text = text;
		isBold = bold;
		this.textSize = textSize;
		this.canUnown = canUnown;

		startText(text, typed);
	}

	public function startText(newText, typed)
	{
		yMulti = 1;
		finishedLine = false;
		xPosResetted = true;

		_finalText = newText;
		textInit = newText;
		this.text = newText;

		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
		else
		{
			if (swagTypingTimer != null)
			{
				destroyText();
				swagTypingTimer.cancel();
				swagTypingTimer.destroy();
			}
		}
	}

	public function destroyText():Void
	{
		for (_sprite in _sprites.copy())
			_sprite.destroy();
		clear();
	}

	public var arrayLetters:Array<AlphaCharacter>;

	public function addText()
	{
		doSplitWords();

		arrayLetters = [];
		var xPos:Float = 0;
		var number:Int = 0;
		for (character in splitWords)
		{
			if (character == " " || character == "-")
				lastWasSpace = true;

			var isNumber:Bool = AlphaCharacter.numbers.contains(character);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(character);

			if ((AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1) 
			|| (AlphaCharacter.numbers.contains(character)) 
			|| (AlphaCharacter.symbols.contains(character)))
			{
				if (xPosResetted)
				{
					xPos = 0;
					xPosResetted = false;
				}
				else
				{
					if (lastSprite != null)
						xPos += lastSprite.width;
				}

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(this, xPos, 0, number, textSize, canUnown);
				number++;

				if (isBold) {
					letter.createBold(character);
				} 
				else
				{
					if (isNumber)
						letter.createNumber(character);
					else if (isSymbol)
						letter.createSymbol(character);
					else
						letter.createLetter(character);
				}

				arrayLetters.push(letter);
				add(letter);

				lastSprite = letter;
			}
		}
	}

	function doSplitWords():Void
		splitWords = _finalText.split("");

	public var personTalking:String = 'gf';

	public var swagTypingTimer:FlxTimer;

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// Remove all the old garbage
		destroyText();

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		// Forget any potential old timers
		if (swagTypingTimer != null)
			swagTypingTimer.destroy();

		// Create a new timer
		var number = 0;
		swagTypingTimer = new FlxTimer().start(textSpeed, function(tmr:FlxTimer)
		{
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			#end

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
				}
				else
				{
					xPos = 0;
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				var letter:AlphaCharacter = new AlphaCharacter(this, xPos, 55 * yMulti, number, textSize, canUnown);
				number++;
				letter.row = curRow;
				if (isBold)
				{
					letter.createBold(splitWords[loopNum]);
				}
				else
				{
					if (isNumber)
						letter.createNumber(splitWords[loopNum]);
					else if (isSymbol)
						letter.createSymbol(splitWords[loopNum]);
					else
						letter.createLetter(splitWords[loopNum]);

					letter.x += 90;
				}

				if (FlxG.random.bool(soundChance) || lastPlayed > 2)
				{
					if (playSounds)
					{
						lastPlayed = 0;

						var cur = FlxG.random.int(0, soundChoices.length - 1);
						var daSound:String = beginPath + soundChoices[cur] + "." + Paths.SOUND_EXT;

						FlxG.sound.play(daSound);
					}
				}
				else
					lastPlayed += 1;

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			if (randomSpeed)
				tmr.time = FlxG.random.float(0.8 * textSpeed, 1.8 * textSpeed);

			// I'm sorry for this implementation being a bit janky but the FlxTimer loops were not reliable for this
			// Hope you forgive me <3 <3 xoxo Sammu
			// i forgive u sammu :D
			if (loopNum >= splitWords.length)
			{
				finishedLine = true;
				tmr.destroy();
			}
		}, 0);
	}

	public var controllable:Bool = false;

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), elapsed * 6);
			// lmao
			if (!disableX)
				x = FlxMath.lerp(x, (targetY * 20) + 90, elapsed * 6);
			else
				x = FlxMath.lerp(x, xTo, elapsed * 6);
		}

		if (controllable) {
			for (i in members)
				i.x = x + i.posX;
		}

		if ((text != textInit))
		{
			if (arrayLetters.length > 0)
				for (i in 0...arrayLetters.length)
					arrayLetters[i].destroy();
			//
			lastSprite = null;
			startText(text, false);
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	private var textSize:Float = 1;

	var altTex:FlxAtlasFrames;
	var tex:FlxAtlasFrames;

	public var posX:Float;
	public var parent:Alphabet = null;
	
	public function new(parent:Alphabet, x:Float, y:Float, number:Int, textSize:Float = 1, canUnown:Bool)
	{
		super(x, y);
		this.textSize = textSize;
		tex = Paths.getSparrowAtlas('UI/base/alphabet');
		altTex = Paths.getSparrowAtlas('UI/base/Unown_Alphabet');
		frames = tex;
		this.number = number;
		this.canUnown = canUnown;
		this.parent = parent;
		setOffsets = new FlxPoint();
		posX = x;

		antialiasing = true;
		// unown shit
		chances = Math.floor(FlxG.random.int(5, 30) * (Init.trueSettings.get('Framerate Cap') / 60));
		initialChances = chances;
	}

	var isBold:Bool = false;
	var letter:String = '';
	public function createBold(letter:String, ?unown:Bool)
	{
		isBold = true;
		if (this.letter == '')
			this.letter = letter;
		if (alphabet.contains(letter.toLowerCase()) || numbers.contains(letter.toLowerCase()) || symbols.contains(letter.toLowerCase())) {
			if (unown) {
				frames = altTex;
				animation.addByPrefix(letter, letter.toUpperCase(), 24);
				animation.play(letter);
				scale.set(textSize / 3, textSize / 3);
				updateHitbox();
				offset.x -= textSize / 6;
			
			} else {
				var isNumber:Bool = numbers.contains(letter);
				var isSymbol:Bool = symbols.contains(letter);
				
				frames = tex;
				if (isNumber) {
					animation.addByPrefix(letter, "bold" + letter, 24);
					animation.play(letter);
					scale.set(textSize, textSize);
					updateHitbox();
				}  else if (isSymbol) {
					switch (letter)
					{
						case '.':
							animation.addByPrefix(letter, 'PERIOD bold', 24);
						case "'":
							animation.addByPrefix(letter, 'APOSTRAPHIE bold', 24);
						case "?":
							animation.addByPrefix(letter, 'QUESTION MARK bold', 24);
						case "!":
							animation.addByPrefix(letter, 'EXCLAMATION POINT bold', 24);
						case "(":
							animation.addByPrefix(letter, 'bold (', 24);
						case ")":
							animation.addByPrefix(letter, 'bold )', 24);
						default:
							animation.addByPrefix(letter, 'bold ' + letter, 24);
					}
					animation.play(letter);

					scale.set(textSize, textSize);
					updateHitbox();
					// /*
					switch (letter)
					{
						case "'":
							y -= 20 * textSize;
						case '(':
							// x -= 65 * textSize;
							y += 5 * textSize;
							offset.x = -58 * textSize;
						case ')':
							// offset.x -= 20 / textSize;
							y += 5 * textSize;
							offset.x = 12 * textSize;
						case '.':
							y += 45 * textSize;
							// x += 5 * textSize;
							offset.x += 3 * textSize;
					}
					// */
				} else {
					// or just load regular text
					animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
					animation.play(letter);
					scale.set(textSize, textSize);
					updateHitbox();
				}

			}
		}
		//
		setOffsets.set(offset.x, offset.y);
	}

	public var setOffsets:FlxPoint;

	var prevY:Float = 0;
	var elapsedTotal:Float = 0;
	var number:Int = 0;
	public var isUnown:Bool = true;

	var chances:Int = 0;
	var initialChances:Int = 0;
	var curFrame:Int = 0;

	var frameDivisor:Int = 4;
	public var hasReverted:Bool = false;

	public var canUnown:Bool = true;
	public var fullFrames:Float = 0;

	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		// i love math
		if (elapsed > 0) {
			displacementFormula();

			// unown chance
			if (isBold && canUnown)
			{
				if (curFrame % Math.floor(frameDivisor * (Init.trueSettings.get('Framerate Cap') / 60)) == 0)
				{
					if (chances > 1)
					{
						createBold(alphabet.charAt(FlxG.random.int(0, alphabet.length - 1)), isUnown);
						if (chances < (initialChances - Math.floor(initialChances / 4)))
						{
							if (FlxG.random.int(0, 10) == 1)
								isUnown = false;
						}
					}
					else
					{
						if (!hasReverted)
						{
							createBold(letter, false);
							hasReverted = true;
						}
					}
					if (chances > 0 && !parent.infiniteShuffle)
						chances -= frameDivisor;
				}
				curFrame++;
			}
		}
	}

	public function displacementFormula() {
		elapsedTotal += FlxG.elapsed;
		var elapsedAverage:Float = (1 / FlxG.drawFramerate);
		var formula:Float = Math.sin(Math.PI * (elapsedTotal + ((number * elapsedAverage) * 24))) * ((FlxG.elapsed / (1 / 120)) / 16);
		prevY += y;
		y = prevY + formula;
		prevY -= y + formula;
	}
			
	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
			letterCase = 'capital';

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		scale.set(textSize, textSize);
		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 50;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '#':
				animation.addByPrefix(letter, 'hashtag', 24);
			case '.':
				animation.addByPrefix(letter, 'period', 24);
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				y -= 50;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
			case ",":
				animation.addByPrefix(letter, 'comma', 24);
			default:
				animation.addByPrefix(letter, letter, 24);
		}

		animation.play(letter);
		updateHitbox();

		y = (110 - height);
		y += row * 60;
	}
}
