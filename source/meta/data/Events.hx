package meta.data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import gameObjects.Character;
import gameObjects.userInterface.notes.Note;
import gameObjects.userInterface.notes.Strumline;
import meta.data.ScriptHandler;
import meta.state.PlayState;
import openfl.filters.ShaderFilter;
import sys.FileSystem;

using StringTools;

typedef PlacedEvent = {
    var timestamp:Float;
    var params:Array<Dynamic>;
    var eventName:String;
}; 

class Events {
	public static var eventList:Array<String> = [
		/*
		'Pendulum Fade' => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent)
			{
				myEvent.myState.tranceActive = true;
				FlxTween.tween(myEvent.myState.pendulum, {alpha: 1}, (Conductor.stepCrochet * 8) / 1000, {ease: FlxEase.linear});
			},
			initFunction: function(myEvent:PlacedEvent) {
				myEvent.myState.fadePendulum = true;
			},
			paramCount: 0,
			description: 'Fade the Pendulum',
		},
		'Fakeshock' => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent) {
				myEvent.myState.psyshock(false);
			},
			initFunction: function(myEvent:PlacedEvent) {},
			paramCount: 0,
			description: 'Fake Psyshock',
		},
		"Unown" => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent)
			{
				myEvent.myState.startUnown(Std.parseInt(myEvent.params[0]), myEvent.params[1]);
			},
			initFunction: function(myEvent:PlacedEvent) {},
			paramCount: 0,
			description: 'Unown',
		},
		"Missingno" => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent)
			{
				if (PlayState.old) {
					for (i in myEvent.myState.dadStrums.receptors)
						i.alpha = 0;

					if (myEvent.myState.shaderCatalog.length > 0)
					{
						var newShader:ShaderFilter = cast(myEvent.myState.shaderCatalog[0], ShaderFilter);
						newShader.shader.data.prob.value = [0.5];
						newShader.shader.data.time.value = [Conductor.songPosition];
					}

					// ash algorithm
					var isDownscroll = FlxG.random.bool(50);
					var boyfriendStrums:Strumline = myEvent.myState.boyfriendStrums;
					PlayState.defaultDownscroll = isDownscroll;
					for (i in 0...boyfriendStrums.receptors.length)
					{
						if (i == 0)
						{
							boyfriendStrums.receptors.members[i].x = FlxG.random.int(100, Std.int(FlxG.width / 3)) - 25;
							if (isDownscroll)
								boyfriendStrums.receptors.members[i].y = FlxG.random.int(Std.int(FlxG.height / 2), FlxG.height - 100);
							else
								boyfriendStrums.receptors.members[i].y = FlxG.random.int(0, 300);
						}
						else
						{
							var futurex = FlxG.random.int(Std.int(boyfriendStrums.receptors.members[i - 1].x) + 80,
								Std.int(boyfriendStrums.receptors.members[i - 1].x) + 400);
							if (futurex > FlxG.width - 100)
								futurex = FlxG.width - 100;
							boyfriendStrums.receptors.members[i].x = futurex;
							boyfriendStrums.receptors.members[i].y = FlxG.random.int(Std.int(boyfriendStrums.receptors.members[0].y - 50),
								Std.int(boyfriendStrums.receptors.members[0].y + 50));
						}
						//
					}
				} else {
					//
					
				}
				
			},
			initFunction: function(myEvent:PlacedEvent) {
				myEvent.myState.setupGlitchShader();
			},
			paramCount: 0,
			description: 'Missingno Glitch',
		},
		'Zoom Set' => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent) {
				var newZoom = myEvent.params[0];
				if (Math.isNaN(newZoom))
					newZoom = 0;
				var timestep = myEvent.params[1];
				if (Math.isNaN(timestep))
					timestep = 0;
				PlayState.forceZoom[0] = newZoom;
			},
			initFunction: function(myEvent:PlacedEvent) {},
			paramCount: 0,
			description: 'your mother hung herself',
		},
		'Monochrome No More' => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent)
			{
				PlayState.dadOpponent.setCharacter(PlayState.dadOpponent.x, PlayState.dadOpponent.y, 'gold-headless');
				FlxTween.tween(FlxG.camera, {zoom: 0.625}, ((Conductor.stepCrochet * 48) / 1000),
					{ease: FlxEase.cubeInOut, startDelay: ((Conductor.stepCrochet * 48) / 1000)});
			},
			initFunction: function(myEvent:PlacedEvent) {
				var newSprite = new Character().setCharacter(0,0,'gold-headless');
				myEvent.myState.add(newSprite);
				newSprite.visible = false;
			},
			paramCount: 0,
			description: 'hes dead I guess',
		},
		"Chromatic Riser" => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent) {
				var newZoom = myEvent.params[0];
				if (Math.isNaN(newZoom))
					newZoom = 0;
				var timestep = myEvent.params[1];
				if (Math.isNaN(timestep))
					timestep = 0;
				
				if (myEvent.myState.riserTween != null && myEvent.myState.riserTween.active && !myEvent.myState.riserTween.finished)
				{
					myEvent.myState.riserTween.active = false;
					myEvent.myState.riserTween = null;
				}

				var onCompleteRiser:FlxTween->Void = function(tween:FlxTween) {
					myEvent.myState.canRise = false;
				};
				
				myEvent.myState.canRise = true;
				if (newZoom > myEvent.myState.brimstoneDistortion) {
					myEvent.myState.riserTween = FlxTween.tween(myEvent.myState, {brimstoneDistortion: newZoom}, (timestep * Conductor.stepCrochet) / 1000,
						{ease: FlxEase.cubeIn, onComplete: onCompleteRiser});
				} else {
					myEvent.myState.riserTween = FlxTween.tween(myEvent.myState, {brimstoneDistortion: newZoom}, (timestep * Conductor.stepCrochet) / 1000,
						{ease: FlxEase.cubeOut, onComplete: onCompleteRiser});
				}
			},
			initFunction: function(myEvent:PlacedEvent) {
				myEvent.myState.setupBrimstoneShaders();
			},
			paramCount: 0,
			description: 'Changes the filter effect',
		},
		"Camera Bop Speed" => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent){
				var intensity = myEvent.params[0];
				if (Math.isNaN(intensity))
					intensity = 0;
				var speed = myEvent.params[1];
				if (Math.isNaN(speed)) 
					speed = 0;
				myEvent.myState.bopIntensity = intensity;
				myEvent.myState.bopFrequency = speed;
			},
			initFunction: function(myEvent:PlacedEvent) {},
			paramCount: 0,
			description: 'Basically just does what the name says\nvalue 1: intensity\nvalue 2: speed',
		},
		"Camera Bop" => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent)
			{
				var intensity = myEvent.params[0];
				if (intensity == 0)
					intensity = 1;
				var speed = myEvent.params[1];
				if (speed == 0)
					speed = 1;
				
				if ((FlxG.camera.zoom < 1.35 && (!Init.trueSettings.get('Reduced Movements'))))
				{
					FlxG.camera.zoom += 0.015 * intensity;
					PlayState.camHUD.zoom += 0.05 * intensity;
					for (hud in PlayState.strumHUD)
						hud.zoom += 0.05 * intensity;
				}
			},
			initFunction: function(myEvent:PlacedEvent) {},
			paramCount: 0,
			description: 'Basically just does what the name says\nvalue 1: intensity\nvalue 2: speed',
		},
		"Fade Strum" => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent) {
				var newAlpha = myEvent.params[0];
				if (Math.isNaN(newAlpha))
					newAlpha = 0;
				var timestep = myEvent.params[1];
				if (Math.isNaN(timestep) || timestep < 1)
					timestep = 1;
				trace('new timestep $timestep');
				var myStrums:Strumline = myEvent.myState.dadStrums;
				FlxTween.tween(myStrums, {alpha: newAlpha}, (timestep * Conductor.stepCrochet) / 1000, {
					ease: FlxEase.linear,
					onComplete: function(tween:FlxTween)
					{
						myStrums.visible = false;
					}
				});
			},
			initFunction: function(myEvent:PlacedEvent) {

			},
			paramCount: 0,
			description: "Fades the enemy's notes out\nvalue 0 alpha\nvalue 1 steps",
		},
		"Jumpscare" => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent) {
				var outOfTen:Float = Std.random(10);
                // params
                var chance:Int = myEvent.params[0];
				var duration:Int = myEvent.params[1];
                // code for the jumpscare
				if (outOfTen <= ((!Math.isNaN(chance) && chance != 0) ? chance : 4))
				{
					myEvent.myState.jumpScare.visible = true;
					PlayState.dialogueHUD.shake(0.0125 * (myEvent.myState.jumpscareSizeInterval / 2),
						(((!Math.isNaN(duration) && duration != 0) ? duration : 1) * Conductor.stepCrochet) / 1000, function()
					{
						myEvent.myState.jumpScare.visible = false;
						myEvent.myState.jumpscareSizeInterval += 0.125;
						myEvent.myState.jumpScare.setGraphicSize(Std.int(FlxG.width * myEvent.myState.jumpscareSizeInterval),
							Std.int(FlxG.height * myEvent.myState.jumpscareSizeInterval));
						myEvent.myState.jumpScare.updateHitbox();
						myEvent.myState.jumpScare.screenCenter();
					}, true);
				}
            },
			initFunction: function(myEvent:PlacedEvent) {},
			paramCount: 1, 
			description: 'The Monochrome Jumpscare, \nvalue 0 is Chance, \nvalue 1 is Duration',
		},
		"Lane Modifier" => {
			delay: 0,
			eventFunction: function(myEvent:PlacedEvent) {
				var val:Int = myEvent.params[0];
				if (val > 3 || Math.isNaN(val))
					val = 3;
				var val2:Float = myEvent.params[1];
				if (Math.isNaN(val2))
					val2 = 1;
				switch(PlayState.gameplayMode)
				{
					case HELL_MODE:
						val2 *= 1.2;
					case FUCK_YOU:
						val2 *= 1.4;
					case PUSSY_MODE:
						val2 *= 0.9;
				}

				myEvent.myState.laneSpeed[val] = PlayState.SONG.speed * val2;
				myEvent.myState.setLaneSpeed(val);
			},
			initFunction: function(myEvent:PlacedEvent) {},
			paramCount: 2, 
			description: 'Set a lanes scrollspeed modifier,\nval 1 lane,\nval 2 speed',
		},
		*/
    ];

	// boovb

	public static var loadedModules:Map<String, ForeverModule> = [];

	public static function obtainEvents() {
		loadedModules.clear();
		eventList = [];
		var tempEventArray:Array<String> = FileSystem.readDirectory('assets/events');
		//
		var futureEvents:Array<String> = [];
		var futureSubEvents:Array<String> = [];
		for (event in tempEventArray) {
			if (event.contains('.')) {
				event = event.substring(0, event.indexOf('.', 0));
				loadedModules.set(event, ScriptHandler.loadModule('events/$event'));
				futureEvents.push(event);
			} else {
				if (PlayState.SONG != null && CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()) == event) {
					var internalEvents:Array<String> = FileSystem.readDirectory('assets/events/$event');
					for (subEvent in internalEvents)
					{
						subEvent = subEvent.substring(0, subEvent.indexOf('.', 0));
						loadedModules.set(subEvent, ScriptHandler.loadModule('events/$event/$subEvent'));
						futureSubEvents.push(subEvent);
					}
					//
				} 
			}
		}
		futureEvents.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
		futureSubEvents.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));

		for (i in futureSubEvents)
			eventList.push(i);
		futureEvents.insert(0, '');
		for (i in futureEvents)
			eventList.push(i);

		futureEvents = [];
		futureSubEvents = [];
		
		eventList.insert(0, '');
	}

	public static function returnDescription(event:String):String {
		if (loadedModules.get(event) != null) {
			var module:ForeverModule = loadedModules.get(event);
			if (module.exists('returnDescription'))
				return module.get('returnDescription')();
		}
		return '';
	}
}