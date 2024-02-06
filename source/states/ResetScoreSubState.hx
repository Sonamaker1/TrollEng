package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;

using StringTools;

class ResetScoreSubState extends MusicBeatSubState
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	// var icon:HealthIcon;
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	var name:String;
	var displayName:String;
	var isChapter:Bool;
	
	public function new(name:String, ?isChapter:Bool, ?displayName:String)
	{
		this.name = name;
		this.displayName = displayName==null ? name : displayName;
		this.isChapter = isChapter == true;

		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var tooLong:Float = (displayName.length > 18) ? 0.8 : 1; //Fucking Winter Horrorland

		var text:Alphabet = new Alphabet(0, 180 + FlxG.camera.scroll.y, "Reset the score of", true);
		text.scrollFactor.set();
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);

		var text:Alphabet = new Alphabet(0, text.y + 90, displayName + "?", true, false, 0.05, tooLong);
		text.scrollFactor.set();
		text.screenCenter(X);
		//if(!this.isChapter) text.x += 60 * tooLong;
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);

		/*
		if(week == -1) {
			icon = new HealthIcon(character);
			icon.setGraphicSize(Std.int(icon.width * tooLong));
			icon.updateHitbox();
			icon.setPosition(text.x - icon.width + (10 * tooLong), text.y - 30);
			icon.alpha = 0;
			add(icon);
		}
		*/

		yesText = new Alphabet(0, text.y + 150, 'Yes', true);
		yesText.scrollFactor.set();
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);

		noText = new Alphabet(0, text.y + 150, 'No', true);
		noText.scrollFactor.set();
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);

		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}
		//if(week == -1) icon.alpha += elapsed * 2.5;

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		} else if(controls.ACCEPT) {
			if(onYes) {
				if(isChapter)
					Highscore.resetWeek(name);
				else
					Highscore.resetSong(name);
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		//if(week == -1) icon.animation.curAnim.curFrame = confirmInt;
	}
}