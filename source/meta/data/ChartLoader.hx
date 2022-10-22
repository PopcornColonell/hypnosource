package meta.data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameObjects.userInterface.notes.*;
import meta.data.Events;
import meta.data.ScriptHandler.ForeverModule;
import meta.data.Section.SwagSection;
import meta.data.Song.SwagSong;
import meta.state.PlayState;
import meta.state.charting.ChartingState;

/**
	This is the chartloader class. it loads in charts, but also exports charts, the chart parameters are based on the type of chart, 
	say the base game type loads the base game's charts, the forever chart type loads a custom forever structure chart with custom features,
	and so on. This class will handle both saving and loading of charts with useful features and scripts that will make things much easier
	to handle and load, as well as much more modular!
**/
class ChartLoader
{
	// hopefully this makes it easier for people to load and save chart features and such, y'know the deal lol
	public static function generateChartType(songData:SwagSong, ?typeOfChart:String = "FNF", state:PlayState):Dynamic
	{
		var unspawnNotes:Array<Note> = [];
		var noteData:Array<SwagSection>;

		noteData = songData.notes;
		switch (typeOfChart)
		{
			default:
				// load fnf style charts (PRE 2.8)
				var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
				var eventCount:Int = 0;
				for (section in noteData) {
					var coolSection:Int = Std.int(section.lengthInSteps / 4);

					for (songNotes in section.sectionNotes)
					{
						var daStrumTime:Float = songNotes[0] - Init.trueSettings['Offset']; // - | late, + | early
						switch (songNotes[1]) {
							default:
								if (PlayState.bronzongMechanic && songNotes[1] == 8) {
									var swagNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, 4, 2, 0);
									swagNote.noteSpeed = songData.speed;
	
									swagNote.lane = PlayState.playerLane;
									swagNote.sustainLength = songNotes[2];
									swagNote.scrollFactor.set(0, 0);
	
									var susLength:Float = swagNote.sustainLength;
									susLength = susLength / Conductor.stepCrochet;
									unspawnNotes.push(swagNote);
	
									var oldNote:Note;
									if (unspawnNotes.length > 0)
										oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
									else 
										oldNote = null;
									
									for (susNote in 0...Math.floor(susLength))
									{
										oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
										var sustainNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier,
											daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, 4, 2, 0, true,
											oldNote);
										sustainNote.scrollFactor.set();
										sustainNote.lane = swagNote.lane;
	
										unspawnNotes.push(sustainNote);
									}
								} else {
									var daNoteData:Int = Std.int(songNotes[1] % PlayState.numberOfKeys);
									var daNoteAlt:Float = 0;
									if (songNotes.length > 2)
										daNoteAlt = songNotes[3];

									var daNoteType:Float = Std.int(songNotes[3]);

									var oldNote:Note;
									if (unspawnNotes.length > 0)
										oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
									else // if it exists, that is
										oldNote = null;

									if (songData.song.toLowerCase() == 'sansno')
										daNoteData = FlxG.random.int(0,3);

									// create the new note
									var swagNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteData, daNoteType, daNoteAlt);
									// set note speed
									swagNote.noteSpeed = songData.speed;

									var gottaHitNote:Bool = section.mustHitSection;
									if (songNotes[1] >= PlayState.numberOfKeys)
										gottaHitNote = !section.mustHitSection;
									
									swagNote.lane = Std.int(Math.max(Math.floor(songNotes[1] / PlayState.numberOfKeys), 0));
									if (!songData.threeLanes) // backwards compat
										swagNote.lane = gottaHitNote ? 1 : 0;
										
									// set the note's length (sustain note)
									swagNote.sustainLength = songNotes[2];
									swagNote.scrollFactor.set(0, 0);
									var susLength:Float = swagNote.sustainLength; // sus amogus

									// adjust sustain length
									susLength = susLength / Conductor.stepCrochet;
									// push the note to the array we'll push later to the playstate
									unspawnNotes.push(swagNote);
									// STOP POSTING ABOUT AMONG US
									// basically said push the sustain notes to the array respectively
									for (susNote in 0...Math.floor(susLength))
									{
										oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
										var sustainNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier,
											daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, daNoteType, daNoteAlt, true, oldNote);
										sustainNote.scrollFactor.set();
										sustainNote.lane = swagNote.lane;

										unspawnNotes.push(sustainNote);
									}
								}
							case -1:
								pushEvent(songNotes, PlayState.eventList);
						}
							
					}
					daBeats += 1;
				}
				if (eventCount > 0)
					trace(eventCount);
			/*
				This is basically the end of this section, of course, it loops through all of the notes it has to,
				But any optimisations and such like the ones sammu is working on won't be handled here, I want to keep this code as
				close to the original as possible with a few tweaks and optimisations because I want to go for the abilities to 
				load charts from the base game, export charts to the base game, and generally handle everything with an accuracy similar to that
				of the main game so it feels like loading things in works well.
			 */
			case 'forever':
				/*
					That being said, however, we also have forever charts, which are complete restructures with new custom features and such.
					Will be useful for projects later on, and it will give you more control over things you can do with the chart and with the game.
					I'll also make it really easy to convert charts, you'll just have to load them in and pick an export option! If you want to play
					songs made in forever engine with the base game then you can do that too.
				 */
			case 'event':
				var eventList:Array<PlacedEvent> = [];
				for (section in noteData) {
					for (songNotes in section.sectionNotes)
						pushEvent(songNotes, eventList);
				}
				return eventList;
		}

		return unspawnNotes;
	}


	public static function pushEvent(note:Array<Dynamic>, myEventList:Array<PlacedEvent>) {
		var daStrumTime:Float = note[0] - Init.trueSettings['Offset']; // - | late, + | early
		// event notes
		if (Events.eventList.contains(note[2])) {
			var mySelectedEvent:String = Events.eventList[Events.eventList.indexOf(note[2])];
			if (mySelectedEvent != null)
			{
				// /*
				var module:ForeverModule = Events.loadedModules.get(note[2]);
				var delay:Float = 0;
				if (module.exists("returnDelay"))
					delay = module.get("returnDelay")();
				// 
				var myEvent:PlacedEvent = {
					timestamp: daStrumTime + (delay * Conductor.stepCrochet),
					params: [note[3], note[4]],
					eventName: note[2],
				};
				//
				if (module.exists("initFunction"))
					module.get("initFunction")(myEvent.params);
				// */
				myEventList.push(myEvent);
			}
		}
		//
	}
}
