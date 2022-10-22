package meta.state.charting;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxUIDropDownMenuCustom;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.notes.*;
import haxe.Json;
import lime.utils.Assets;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Section.SwagSection;
import meta.data.Song.SwagSong;
import meta.data.font.AttachedText;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

/**
	In case you dont like the forever engine chart editor, here's the base game one instead.
**/
class OriginalChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	var curNoteType:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;
	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedNoteType:FlxTypedGroup<AttachedText>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;
	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	override function create()
	{
		super.create();

		curSection = lastSection;

		_song = PlayState.SONG;
		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		gridBlackLines = new FlxTypedGroup<FlxSprite>();

		generateChartEditor(_song.threeLanes == true ? 3 : 2);

		add(gridBG);
		add(eventLine);
		add(gridBlackLines);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedNoteType = new FlxTypedGroup<AttachedText>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		FlxG.mouse.visible = true;

		tempBpm = _song.bpm;

		addSection();
		updateGrid();

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Events", label: 'Events'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		add(curRenderedNotes);
		add(curRenderedNoteType);
		add(curRenderedSustains);

		addSongUI();
		addSectionUI();
		addEventsUI();
		addMechanicsUI();
		addNoteUI();
	}



	var eventLine:FlxSprite;
	var curZoom:Int = 1;
	var gridBlackLines:FlxTypedGroup<FlxSprite>;
	function generateChartEditor(lanes:Int) {
		var baseWidth = GRID_SIZE * lanes * PlayState.numberOfKeys;
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, baseWidth + GRID_SIZE + (PlayState.bronzongMechanic ? GRID_SIZE : 0), Std.int(GRID_SIZE * 16 * zoomList[curZoom]));
		gridBG.x -= GRID_SIZE; //+ ((lanes - 1) * PlayState.numberOfKeys * GRID_SIZE);
		
		eventLine = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
	
		gridBlackLines.clear();
		for (i in 0...(lanes - 1)) {
			var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + ((((i + 1) * PlayState.numberOfKeys) + 1) * GRID_SIZE)).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
			gridBlackLines.add(gridBlackLine);
		}		
	}

	var eventDropDown:FlxUIDropDownMenuCustom;
	public var blockInput:Bool = false;
	var descText:FlxText;
	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenuCustom> = [];
	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	
	function addEventsUI():Void {
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		descText = new FlxText(20, 200, 0, '');

		Events.obtainEvents();

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		eventDropDown = new FlxUIDropDownMenuCustom(20, 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray(Events.eventList, true), function(pressed:String)
		{
			var selectedEvent:Int = Std.parseInt(pressed);
			descText.text = Events.returnDescription(Events.eventList[selectedEvent]);
			if (curSelectedNote != null)
			{
				curSelectedNote[2] = Events.eventList[selectedEvent];
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");
		blockPressWhileTypingOn.push(value1InputText);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");
		blockPressWhileTypingOn.push(value2InputText);

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	function addMechanicsUI():Void
	{
		var tab_group_mechanic = new FlxUI(null, UI_box);
		tab_group_mechanic.name = 'Mechanics';
		UI_box.addGroup(tab_group_mechanic);
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			songMusic.volume = vol;
		};

		var check_mute_voices = new FlxUICheckBox(10, 220, null, null, "Mute Vocals (in editor)", 100);
		check_mute_voices.checked = false;
		check_mute_voices.callback = function()
		{
			var vol:Float = 1;
			if (check_mute_voices.checked)
				vol = 0;
			vocals.volume = vol;
		};

		var lane_chart_editor = new FlxUICheckBox(10, 240, null, null, "3 Lane Chart", 100);
		lane_chart_editor.checked = false;

		var hitsounds = new FlxUICheckBox(10, 260, null, null, "Enable (Makeshift) Hitsounds", 100);
		hitsounds.checked = enableHitsounds;
		
		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var clearEventsButton:FlxButton = new FlxButton(saveButton.x, saveButton.y + 30, "Clear Events", function()
		{
			clearEvents();
		});

		var loadEventJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Load Event", function()
		{
			loadJson(_song.song.toLowerCase(), true);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 60, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});		

		var saveEventsButton:FlxButton = new FlxButton(saveButton.x, reloadSongJson.y + 30, "Save Events", function()
		{
			saveEvents();
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		characters.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
		var stages:Array<String> = CoolUtil.returnAssetsLibrary('stages', 'assets');
		stages.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));

		var player1DropDown = new FlxUIDropDownMenuCustom(10, 140, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		var player2DropDown = new FlxUIDropDownMenuCustom(140, 140, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});

		var stageDropDown = new FlxUIDropDownMenuCustom(140, 160, FlxUIDropDownMenuCustom.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});

		stageDropDown.selectedLabel = _song.stage;

		blockPressWhileScrolling.push(player1DropDown);
		blockPressWhileScrolling.push(player2DropDown);
		blockPressWhileScrolling.push(stageDropDown);

		player2DropDown.selectedLabel = _song.player2;

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		//
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_voices);
		tab_group_song.add(lane_chart_editor);
		tab_group_song.add(hitsounds);
		//
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(clearEventsButton);
		tab_group_song.add(loadEventJson);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(saveEventsButton);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(stageDropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + PlayState.numberOfKeys) % (PlayState.numberOfKeys * 2);
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var stepperType:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);

		// note types
		stepperType = new FlxUINumericStepper(10, 30, Conductor.stepCrochet / 125, 0, 0, (Conductor.stepCrochet / 125) + 10); // 10 is placeholder
		// I have no idea what i'm doing lmfao
		stepperType.value = 0;
		stepperType.name = 'note_type';

		tab_group_note.add(stepperType);

		UI_box.addGroup(tab_group_note);
		// I'm genuinely tempted to go around and remove every instance of the word "sus" it is genuinely killing me inside
	}

	var songMusic:FlxSound;

	function loadSong(daSong:String):Void
	{
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();

		songMusic = new FlxSound().loadEmbedded(Paths.inst(daSong, PlayState.old, PlayState.songLibrary), false, true);
		if (_song.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong, PlayState.old, PlayState.songLibrary), false, true);
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		songMusic.play();
		vocals.play();

		pauseMusic();

		songMusic.onComplete = function()
		{
			ForeverTools.killMusic([songMusic, vocals]);
			loadSong(daSong);
		};
		//
	}

	function pauseMusic()
	{
		songMusic.time = Math.max(songMusic.time, 0);
		songMusic.time = Math.min(songMusic.time, songMusic.length);

		songMusic.pause();
		vocals.pause();
		playedNote = [];
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	public static var enableHitsounds:Bool = false;

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
				case '3 Lane Chart':
					_song.threeLanes = check.checked;
					remove(gridBG);
					generateChartEditor(_song.threeLanes == true ? 3 : 2);
					add(gridBG);
					updateGrid();
					UI_box.x = FlxG.width / 2;
					if (_song.threeLanes)
						UI_box.x += (GRID_SIZE * PlayState.numberOfKeys);
				case 'Enable (Makeshift) Hitsounds':
					enableHitsounds = check.checked;
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			// ew what was this before? made it switch cases instead of else if
			switch (wname)
			{
				case 'section_length':
					_song.notes[curSection].lengthInSteps = Std.int(nums.value); // change length
					updateGrid(); // vrrrrmmm
				case 'song_speed':
					_song.speed = nums.value; // change the song speed
				case 'song_bpm':
					tempBpm = Std.int(nums.value);
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));
				case 'note_susLength': // STOP POSTING ABOUT AMONG US
					curSelectedNote[2] = nums.value; // change the currently selected note's length
					updateGrid(); // oh btw I know sus stands for sustain it just bothers me
				case 'note_type':
					curNoteType = Std.int(nums.value); // oh yeah dont forget this has to be an integer
				// set the new note type for when placing notes next!
				case 'section_bpm':
					_song.notes[curSection].bpm = Std.int(nums.value); // redefine the section's bpm
					updateGrid(); // update the note grid
			}
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			if (curSelectedNote != null)
			{
				if (sender == value1InputText)
				{
					curSelectedNote[3] = value1InputText.text;
					updateGrid();
				}
				else if (sender == value2InputText)
				{
					curSelectedNote[4] = value2InputText.text;
					updateGrid();
				}
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = songMusic.time;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		
		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		blockInput = false;

		if (!blockInput) {
			for (dropDownMenu in blockPressWhileScrolling)
			{
				if (dropDownMenu.dropPanel.visible)
				{
					blockInput = true;
					break;
				}
			}
		}
		
		if (!blockInput) {
			if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(curRenderedNotes))
				{
					curRenderedNotes.forEach(function(note:Note)
					{
						if (FlxG.mouse.overlaps(note))
						{
							if (FlxG.keys.pressed.CONTROL)
							{
								selectNote(note);
							}
							else
							{
								trace('tryin to delete note...');
								deleteNote(note);
							}
						}
					});
				}
				else
				{
					if (FlxG.mouse.x > gridBG.x
						&& FlxG.mouse.x < gridBG.x + gridBG.width
						&& FlxG.mouse.y > gridBG.y
						&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps) * zoomList[curZoom])
					{
						FlxG.log.add('added note');
						addNote();
					}
				}
			}

			if (FlxG.mouse.x > gridBG.x
				&& FlxG.mouse.x < gridBG.x + gridBG.width
				&& FlxG.mouse.y > gridBG.y
				&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps) * zoomList[curZoom])
			{
				dummyArrow.visible = true;
				dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
				if (FlxG.keys.pressed.SHIFT)
					dummyArrow.y = FlxG.mouse.y;
				else
					dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
			}
			else
			{
				dummyArrow.visible = false;
			}

			if (FlxG.keys.justPressed.ENTER)
			{
				lastSection = curSection;

				PlayState.SONG = _song;
				songMusic.stop();
				vocals.stop();
				Main.switchState(this, new PlayState());
			}

			if (FlxG.keys.justPressed.E)
			{
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q)
			{
				changeNoteSustain(-Conductor.stepCrochet);
			}

			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 2;
				}
				else
				{
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 3)
						UI_box.selected_tab = 0;
				}
			}

			if (!typingShit.hasFocus)
			{
				if (FlxG.keys.justPressed.SPACE)
				{
					if (songMusic.playing)
					{
						songMusic.pause();
						vocals.pause();
						playedNote = [];
					}
					else
					{
						vocals.play();
						songMusic.play();
					}
				}

				if (FlxG.keys.justPressed.R)
				{
					if (FlxG.keys.pressed.SHIFT)
						resetSection(true);
					else
						resetSection();
				}

				if (FlxG.mouse.wheel != 0)
				{
					songMusic.pause();
					vocals.pause();
					playedNote = [];

					songMusic.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
					vocals.time = songMusic.time;
				}

				if (!FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
					{
						songMusic.pause();
						vocals.pause();
						playedNote = [];

						var daTime:Float = 700 * FlxG.elapsed;

						if (FlxG.keys.pressed.W)
						{
							songMusic.time -= daTime;
						}
						else
							songMusic.time += daTime;

						vocals.time = songMusic.time;
					}
				}
				else
				{
					if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
					{
						songMusic.pause();
						vocals.pause();
						playedNote = [];

						var daTime:Float = Conductor.stepCrochet * 2;

						if (FlxG.keys.justPressed.W)
						{
							songMusic.time -= daTime;
						}
						else
							songMusic.time += daTime;

						vocals.time = songMusic.time;
					}
				}

				if (FlxG.keys.justPressed.Z && curZoom > 0 && !FlxG.keys.pressed.CONTROL)
				{
					--curZoom;
					updateZoom();
				}
				if (FlxG.keys.justPressed.X && curZoom < zoomList.length - 1)
				{
					curZoom++;
					updateZoom();
				}
			}
		}
		else if (FlxG.keys.justPressed.ENTER)
		{
			for (i in 0...blockPressWhileTypingOn.length)
			{
				if (blockPressWhileTypingOn[i].hasFocus)
				{
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
		}
		_song.bpm = tempBpm;

		var cancel:Bool = false; // only play one hitsound per frame so no overlayering
		if (songMusic.playing && enableHitsounds) {
			curRenderedNotes.forEachAlive(function(note:Note):Void
			{
				if (!cancel && !playedNote.contains(note) && (note.strumTime <= Conductor.songPosition))
				{
					if (Math.abs(Conductor.songPosition - note.strumTime) < 20)
						FlxG.sound.play(Paths.sound('soundNoteTick'));
					playedNote.push(note);
					cancel = true;
					return;
				}
			});
		}

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(songMusic.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nStep: "
			+ curStep;
		super.update(elapsed);
	}

	var playedNote:Array<Note> = [];

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (songMusic.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((songMusic.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		songMusic.pause();
		vocals.pause();
		playedNote = [];

		// Basically old shit from changeSection???
		songMusic.time = sectionStartTime();

		if (songBeginning)
		{
			songMusic.time = 0;
			curSection = 0;
		}

		vocals.time = songMusic.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				songMusic.pause();
				vocals.pause();
				playedNote = [];

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				songMusic.time = sectionStartTime();
				vocals.time = songMusic.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

	}


	function updateNoteUI():Void
	{
		if (curSelectedNote != null) {
			if (curSelectedNote[1] > -1)
				stepperSusLength.value = curSelectedNote[2];
			else {
				eventDropDown.selectedLabel = curSelectedNote[2];
				var selected:Int = Std.parseInt(eventDropDown.selectedId);
				if (selected > 0 && selected < Events.eventList.length) 
					descText.text = Events.returnDescription(Events.eventList[selected]);
				value1InputText.text = curSelectedNote[3];
				value2InputText.text = curSelectedNote[4];
			}
		}
	}

	function updateGrid():Void
	{
		curRenderedNotes.clear();
		curRenderedNoteType.clear();
		curRenderedSustains.clear();

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1] % PlayState.numberOfKeys;
			var daStrumTime = i[0];
			var daSus:Dynamic = i[2];
			var daNoteType = 0;
			
			if (i.length > 2)
				daNoteType = i[3];
			var note:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, Std.int(daNoteInfo), daNoteType, 0);
			if (daNoteInfo <= -1)
				note.loadGraphic(Paths.image('UI/base/eventArrow'));
			note.lane = Std.int(Math.max(Math.floor(i[1] / PlayState.numberOfKeys), 0));
			note.sustainLength = daSus;
			note.noteType = daNoteType;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor((daNoteInfo + (note.lane * PlayState.numberOfKeys)) * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps),
					false));

			curRenderedNotes.add(note);

			if (note.noteData < 0)
			{
				note.eventName = daSus;
				note.eventVal1 = i[3];
				note.eventVal2 = i[4];
				
				var daText:AttachedText = new AttachedText(0, 0, 400,
					'Event: '
					+ note.eventName
					+ ' ('
					+ Math.floor(note.strumTime)
					+ ' ms)'
					+ '\nValue 1: '
					+ note.eventVal1
					+ '\nValue 2: '
					+ note.eventVal2,
					12);
				daText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				daText.xAdd = -410;
				daText.borderSize = 1;
				curRenderedNoteType.add(daText);
				daText.sprTracker = note;
			}

			if (daSus > 0)
				curRenderedSustains.add(setupSusNote(note));
		}
	}

	function setupSusNote(note:Note):FlxSprite
	{
		var height:Int = Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, (gridBG.height))
			+ (GRID_SIZE * zoomList[curZoom])
			- GRID_SIZE / 2);
		var minHeight:Int = Std.int((GRID_SIZE * zoomList[curZoom] / 2) + GRID_SIZE / 2);
		if (height < minHeight)
			height = minHeight;
		if (height < 1)
			height = 1; // Prevents error of invalid height

		var spr:FlxSprite = new FlxSprite(note.x + (GRID_SIZE * 0.5) - 4, note.y + GRID_SIZE / 2).makeGraphic(8, height);
		return spr;
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			sectionCamera: 1,
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % PlayState.numberOfKeys == note.noteData)
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % PlayState.numberOfKeys == note.noteData) {
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		if (FlxG.keys.pressed.G) curNoteType = 1; //kinda lazy sorry lol
		else curNoteType = 0;

		var noteStrum = getStrumTime(dummyArrow.y, false) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteType = curNoteType; // define notes as the current type
		var noteSus = 0; // ninja you will NOT get away with this
		
		switch (noteData) {
			case -1:
				var event = Events.eventList[Std.parseInt(eventDropDown.selectedId)];
				var text1 = value1InputText.text;
				var text2 = value2InputText.text;
				_song.notes[curSection].sectionNotes.push([noteStrum, noteData, event, text1, text2]);
			default:
				if (PlayState.bronzongMechanic && noteData == (PlayState.numberOfKeys * 2))
					noteType = 2;
				_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);
		}
		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL && noteData > -1) {
			_song.notes[curSection].sectionNotes.push([noteStrum, 
				(noteData + PlayState.numberOfKeys) % (PlayState.numberOfKeys* 2), noteSus, noteType]);
		}
		
		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if (!doZoomCalc)
			leZoom = 1;
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height * leZoom, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if (!doZoomCalc)
			leZoom = 1;
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height * leZoom);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String, eventChart:Bool = false):Void
	{
		if (eventChart)
			PlayState.SONG = Song.loadFromJson('events', song.toLowerCase(), PlayState.old);
		else
			PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase(), PlayState.old);
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0)){
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, _song.song.toLowerCase() + ".json");
		}
	}

	private function clearEvents() {
		for (daSection in 0..._song.notes.length)
		{
			for (note in _song.notes[daSection].sectionNotes) {
				if (note[1] == -1)
					_song.notes[daSection].sectionNotes.remove(note);
			}
		}
		updateGrid();
	}

	var zoomList:Array<Float> = [0.5, 1, 2, 4, 8, 12, 16, 24];

	function updateZoom()
	{
		remove(gridBG);
		generateChartEditor(_song.threeLanes == true ? 3 : 2);
		add(gridBG);
		updateGrid();
	}

	private function saveEvents()
	{
		var newSong:SwagSong = {
			song: _song.song,
			notes: [],
			bpm: _song.bpm,
			needsVoices: _song.needsVoices,
			speed: _song.speed,
			player1: _song.player1,
			player2:_song.player2,
			stage: _song.stage,
			noteSkin: _song.noteSkin,
			validScore: _song.validScore,
			threeLanes: _song.threeLanes,
		};
		
		// get rid of everything not events
		for (daSection in 0..._song.notes.length) {
			var mySectionNotes:Array<Dynamic> = [];
			for (note in _song.notes[daSection].sectionNotes)
			{
				trace('note $note');
				if (note[1] == -1)
				{
					trace('saving note at ' + note[0] + ', ' + note[2]);
					mySectionNotes.push(note);
				}
			}
			var section:SwagSection = {
				sectionNotes: mySectionNotes,
				lengthInSteps: 16,
				typeOfSection: 0,
				mustHitSection: false,
				bpm: 0,
				changeBPM: false,
				altAnim: false,
				sectionCamera: 1
			};
			newSong.notes.push(section);
		}
		
		var json = {
			"song": newSong
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, "events.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	
}
