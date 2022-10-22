package gameObjects.userInterface.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import meta.*;
import meta.data.*;
import meta.data.Section.SwagSection;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;

using StringTools;

class Note extends FNFSprite
{
	public var strumTime:Float = 0;

	public var noteData:Int = 0;
	public var noteAlt:Float = 0;
	public var noteType:Float = 0;
	public var noteString:String = "";

	public var downscrollNote:Bool = false;

	public var eventName:String = '';
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var spriteOffet:Float = 0.0;

	// only useful for charting stuffs
	public var chartSustain:FlxSprite = null;
	public var rawNoteData:Int;

	// not set initially
	public var noteQuant:Int = -1;
	public var noteVisualOffset:Float = 0;
	public var customScrollspeed:Bool = false;
	@:isVar
	public var noteSpeed(get, set):Float = 0;
	public var noteDirection:Float = 0;

	public var parentNote:Note; 
	public var childrenNotes:Array<Note> = [];

	public static var swagWidth:Float = 160 * 0.7;
	public var lane:Int = 0;
	// it has come to this.
	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	public function new(strumTime:Float, noteData:Int, noteAlt:Float, ?prevNote:Note, ?sustainNote:Bool = false, noteType:Float = 0)
	{
		super(x, y);

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		// oh okay I know why this exists now
		y -= 2000;

		this.strumTime = strumTime;
		this.noteData = noteData;
		this.noteAlt = noteAlt;
		this.noteType = noteType;

		if (PlayState.defaultDownscroll)
			downscrollNote = true;

		// determine parent note
		if (isSustainNote && prevNote != null) {
			parentNote = prevNote;
			while (parentNote.parentNote != null)
				parentNote = parentNote.parentNote;
			parentNote.childrenNotes.push(this);
		} else if (!isSustainNote)
			parentNote = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (lane == PlayState.playerLane)
		{
			if (strumTime > Conductor.songPosition - (Timings.msThreshold) 
				&& strumTime < Conductor.songPosition + (Timings.msThreshold))
				canBeHit = true;
			else
				canBeHit = false;
		}
		else // make sure the note can't be hit if it's the dad's I guess
			canBeHit = false;

		if (tooLate || (parentNote != null && parentNote.tooLate))
			alpha = 0.3;
	}

	/**
		Note creation scripts

		these are for all your custom note needs
	**/
	public static function returnDefaultNote(assetModifier, strumTime, noteData, noteType, noteAlt, ?isSustainNote:Bool = false, ?prevNote:Note = null):Note
	{
		var newNote:Note = new Note(strumTime, noteData, noteAlt, prevNote, isSustainNote, noteType);

		// frames originally go here
		switch (assetModifier)
		{
			case 'pixel': // pixel arrows default
				switch (PlayState.SONG.song.toLowerCase()) {
					case 'brimstone':
						if (isSustainNote)
						{
							newNote.loadGraphic(Paths.image('UI/pixel/HOLDS_buried'), true, 12, 10);
							newNote.animation.add('purpleholdend', [4]);
							newNote.animation.add('greenholdend', [6]);
							newNote.animation.add('redholdend', [7]);
							newNote.animation.add('blueholdend', [5]);
							newNote.animation.add('purplehold', [0]);
							newNote.animation.add('greenhold', [2]);
							newNote.animation.add('redhold', [3]);
							newNote.animation.add('bluehold', [1]);
						}
						else
						{
							if (noteType == 1) //gengar notes
								{
									newNote.loadGraphic(Paths.image('UI/pixel/gega'), true, 48, 48);
									newNote.animation.add('blueScroll', [0, 4, 8, 12], 12, true);
									newNote.animation.add('purpleScroll', [1, 5, 9, 13], 12, true);
									newNote.animation.add('greenScroll', [2, 6, 10, 14], 12, true);
									newNote.animation.add('redScroll', [3, 7, 11, 15], 12, true);
									newNote.spriteOffet = -24;
								}
							else
								{
									newNote.loadGraphic(Paths.image('UI/pixel/NOTES_buried'), true, 32, 32);
									newNote.animation.add('greenScroll', [6]);
									newNote.animation.add('redScroll', [7]);
									newNote.animation.add('blueScroll', [5]);
									newNote.animation.add('purpleScroll', [4]);
								}
						}
						newNote.antialiasing = false;
						newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom * PlayState.buriedResize));
						newNote.updateHitbox();
					case 'shinto':
						if (isSustainNote)
						{
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('shitno_ends1', assetModifier, Init.trueSettings.get("Note Skin"),
								'UI')), true, 7, 6);
							newNote.animation.add('purpleholdend', [4]);
							newNote.animation.add('greenholdend', [6]);
							newNote.animation.add('redholdend', [7]);
							newNote.animation.add('blueholdend', [5]);
							newNote.animation.add('purplehold', [0]);
							newNote.animation.add('greenhold', [2]);
							newNote.animation.add('redhold', [3]);
							newNote.animation.add('bluehold', [1]);
						}
						else
						{
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('shitno_arrows1', assetModifier, Init.trueSettings.get("Note Skin"),
								'UI')), true, 19,
								19);
							newNote.animation.add('greenScroll', [6]);
							newNote.animation.add('redScroll', [7]);
							newNote.animation.add('blueScroll', [5]);
							newNote.animation.add('purpleScroll', [4]);
						}
						newNote.antialiasing = false;
						newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
						newNote.updateHitbox();
					default:
						if (isSustainNote)
						{
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('arrowEnds', assetModifier, Init.trueSettings.get("Note Skin"),
								'UI')), true, 7, 6);
							newNote.animation.add('purpleholdend', [4]);
							newNote.animation.add('greenholdend', [6]);
							newNote.animation.add('redholdend', [7]);
							newNote.animation.add('blueholdend', [5]);
							newNote.animation.add('purplehold', [0]);
							newNote.animation.add('greenhold', [2]);
							newNote.animation.add('redhold', [3]);
							newNote.animation.add('bluehold', [1]);
						}
						else
						{
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('arrows-pixels', assetModifier, Init.trueSettings.get("Note Skin"),
								'UI')), true, 17,
								17);
							newNote.animation.add('greenScroll', [6]);
							newNote.animation.add('redScroll', [7]);
							newNote.animation.add('blueScroll', [5]);
							newNote.animation.add('purpleScroll', [4]);
						}
						newNote.antialiasing = false;
						newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
						newNote.updateHitbox();
				}
			default: // base game arrows for no reason whatsoever
				newNote.frames = Paths.getSparrowAtlas(ForeverTools.returnSkinAsset('NOTE_assets', assetModifier, Init.trueSettings.get("Note Skin"),
					'UI'));
				
				newNote.animation.addByPrefix('greenScroll', 'green0');
				newNote.animation.addByPrefix('redScroll', 'red0');
				newNote.animation.addByPrefix('blueScroll', 'blue0');
				newNote.animation.addByPrefix('purpleScroll', 'purple0');
				newNote.animation.addByPrefix('purpleholdend', 'pruple end hold');
				newNote.animation.addByPrefix('greenholdend', 'green hold end');
				newNote.animation.addByPrefix('redholdend', 'red hold end');
				newNote.animation.addByPrefix('blueholdend', 'blue hold end');
				newNote.animation.addByPrefix('purplehold', 'purple hold piece');
				newNote.animation.addByPrefix('greenhold', 'green hold piece');
				newNote.animation.addByPrefix('redhold', 'red hold piece');
				newNote.animation.addByPrefix('bluehold', 'blue hold piece');

				if (noteType == 2) {
					newNote.frames = Paths.getSparrowAtlas(ForeverTools.returnSkinAsset('hellbell/Bronzong_Gong_mechanic', assetModifier,
						Init.trueSettings.get("Note Skin"), 'UI'));
					newNote.animation.addByPrefix('bellScroll', 'spacebar0');
					newNote.animation.addByPrefix('bellhold', 'spacebar hold piece0');
					newNote.animation.addByPrefix('bellholdend', 'spacebar hold end0');					
					newNote.setGraphicSize(Std.int(newNote.width * 0.875));
					newNote.updateHitbox();
				}

				newNote.setGraphicSize(Std.int(newNote.width * 0.7));
				newNote.updateHitbox();
				newNote.antialiasing = true;
		}
		//
		if (!isSustainNote)
			newNote.animation.play(UIStaticArrow.getColorFromNumber(noteData) + 'Scroll');
		// trace(prevNote);
		if (isSustainNote && prevNote != null)
		{
			newNote.noteSpeed = prevNote.noteSpeed;
			newNote.alpha = (Init.trueSettings.get('Opaque Holds') || assetModifier == 'pixel') ? 1 : 0.6;
			newNote.animation.play(UIStaticArrow.getColorFromNumber(noteData) + 'holdend');
			newNote.updateHitbox();
			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(UIStaticArrow.getColorFromNumber(prevNote.noteData) + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * prevNote.noteSpeed;
				if (prevNote.noteType == 2)
					prevNote.scale.y /= 0.875;
				if (assetModifier == 'pixel' && !PlayState.buriedNotes) {
					prevNote.scale.y *= 0.834;
					prevNote.scale.y *= (6 / newNote.height); // Auto adjust note size
				}
				prevNote.updateHitbox();
				if (assetModifier == 'pixel' && !PlayState.buriedNotes) {
					prevNote.scale.y *= PlayState.daPixelZoom;
					prevNote.updateHitbox();
				}
				// prevNote.setGraphicSize();
			}
		}
		return newNote;
	}

	function get_noteSpeed():Float {
		return noteSpeed;
	}

	function set_noteSpeed(value:Float):Float {
		var ratio:Float = value / noteSpeed;
		if (customScrollspeed && isSustainNote && !animation.curAnim.name.endsWith('end')) {
			scale.y *= ratio;
			updateHitbox();
		}
		noteSpeed = value;
		return value;
	}
}
