package gameObjects.userInterface.menu;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import meta.state.PlayState;

class Textbox extends FlxSpriteGroup {
    public var textboxStack:Array<FlxSprite> = [];

	public var itemStack:FlxSpriteGroup;

    public var boxWidth:Float = 1;
    public var boxHeight:Float = 1;

    public var boxInterval:Int = 9;
    public var boxInternalDivision:Int = 1;

    public var selectionBox:Bool = false;

	public function new(x:Float, y:Float) {
        super(x, y);
		itemStack = new FlxSpriteGroup();
        for (i in 0...9) {
			var sprite:FlxSprite = new FlxSprite();
            if (PlayState.SONG != null) {
				switch (PlayState.SONG.song.toLowerCase()){
					case 'frostbite' | 'insomnia' | 'monochrome':
						boxInterval = 10;
						sprite.loadGraphic(Paths.image('UI/pixel/9slicetextbox-gold'), true, boxInterval, boxInterval);
                    case 'shinto' | 'shitno':
						boxInterval = 16;
						boxInternalDivision = 2;
						sprite.loadGraphic(Paths.image('UI/pixel/9slicetextbox-shinto'), true, boxInterval, boxInterval);
                    default:
						boxInterval = 9;
						sprite.loadGraphic(Paths.image('UI/pixel/9slicetextbox'), true, boxInterval, boxInterval);
                }
            } else
				sprite.loadGraphic(Paths.image('UI/pixel/9slicetextbox'), true, 9, 9);
            
            sprite.animation.add('idle', [i], 24, false);
            sprite.animation.play('idle');
            add(sprite);
            textboxStack.push(sprite);
        }
		add(itemStack);
    }

	// https://youtu.be/Wr6CdxLWYXk thank u mario strikers you kept me sane :pray:

    override public function update(elapsed:Float) {
		super.update(elapsed);

        for (i in 0...9) {
			textboxStack[i].setGraphicSize(Std.int(textboxStack[i].frameWidth * scale.x), Std.int(textboxStack[i].frameHeight * scale.y));
            switch (i) {
				case 1 | 7:
					textboxStack[i].setGraphicSize(Std.int(textboxStack[i].frameWidth * scale.x * boxWidth), Std.int(textboxStack[i].frameHeight * scale.y));
				case 3 | 5:
					textboxStack[i].setGraphicSize(Std.int(textboxStack[i].frameWidth * scale.x), Std.int(textboxStack[i].frameHeight * scale.y * boxHeight));
                case 4: 
					textboxStack[i].setGraphicSize(Std.int(textboxStack[i].frameWidth * scale.x * boxWidth), Std.int(textboxStack[i].frameHeight * scale.y * boxHeight));
            }
            textboxStack[i].updateHitbox();
        }

        for (i in 0...9) {
			textboxStack[i].setPosition(x - (textboxStack[i].width / 2), y - (textboxStack[i].height / 2));
            // the best way I'd know how to do this
			var horizontal:Int = 0;
            var vertical:Int = 0;
            switch (i) {
                case 0 | 3 | 6:
                    horizontal = -1;
                case 1 | 4 | 7:
                    horizontal = 0;
                case 2 | 5 | 8:
                    horizontal = 1;
            }
            switch (i) {
                case 0 | 1 | 2:
					vertical = -1;
                case 3 | 4 | 5:
					vertical = 0;
                case 6 | 7 | 8:
					vertical = 1;
            }
			textboxStack[i].setPosition(textboxStack[i].x + (textboxStack[i].width / 2 + textboxStack[4].width / 2) * horizontal,
				textboxStack[i].y + (textboxStack[i].height / 2 + textboxStack[4].height / 2) * vertical);
        }

    }
}

