package options;

import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import openfl.geom.Rectangle;
import states.PlayState;	
import states.MusicBeatState;	
import states.MusicBeatSubState;	
using StringTools;

class NewBindsSubstate extends MusicBeatSubState  {
	// if an option is in this list, then atleast ONE key will have to be bound.
	var forcedBind:Array<String> = ["ui_up", "ui_down", "ui_left", "ui_right", "accept", "back",];

	var binds:Array<Array<String>> = [
		[Paths.getString('controls_gameplay')],
		[Paths.getString('control_note_left'), 'note_left'],
		[Paths.getString('control_note_down'), 'note_down'],
		[Paths.getString('control_note_up'), 'note_up'],
		[Paths.getString('control_note_right'), 'note_right'],
		[Paths.getString('control_pause'), 'pause'],
		[Paths.getString('control_reset'), 'reset'],
		[Paths.getString('controls_ui')],
		[Paths.getString('control_ui_up'), 'ui_up'],
		[Paths.getString('control_ui_down'), 'ui_down'],
		[Paths.getString('control_ui_left'), 'ui_left'],
		[Paths.getString('control_ui_right'), 'ui_right'],
		[Paths.getString('control_accept'), 'accept'],
		[Paths.getString('control_back'), 'back'],
		[Paths.getString('controls_misc')],
		[Paths.getString('control_volume_mute'), 'volume_mute'],
		[Paths.getString('control_volume_up'), 'volume_up'],
		[Paths.getString('control_volume_down'), 'volume_down'],
		//['Fullscreen', 'fullscreen'],
		[Paths.getString('controls_debug')],
		// honestly might just replace this with one debug thing
		// and make it so pressing it in playstate will open a debug menu w/ a bunch of stuff
		// chart editor/character editor, botplay, skip to time, etc. move it from pause menu during charting mode lol
		[Paths.getString('control_debug_1'), 'debug_1'],
		[Paths.getString('control_debug_2'), 'debug_2'],
		[Paths.getString('control_botplay'), 'botplay']
	];


	public var changedBind:(String, Int, FlxKey) -> Void;

    // anything beyond this point prob shouldnt be touched too much
    var cam:FlxCamera = new FlxCamera();
	var overCam:FlxCamera = new FlxCamera();
    var scrollableCam:FlxCamera = new FlxCamera();

	var camFollow = new FlxPoint(0, 0);
	var camFollowPos = new FlxObject(0, 0);

    var bindIndex:Int = -1;
    var bindID:Int = 0;
    var bindButtons:Array<Array<BindButton>> = []; // the actual bind buttons. used for input etc lol
    var internals:Array<String> = [];
	var resetBinds:FlxUI9SliceSprite;

	@:noCompletion
	var _point:FlxPoint = FlxPoint.get();

	function overlaps(object:FlxObject, ?camera:FlxCamera)
	{
		if (camera == null)
			camera = scrollableCam;

		_point = FlxG.mouse.getPositionInCameraView(camera, _point);
		if (camera.containsPoint(_point))
		{
			_point = FlxG.mouse.getWorldPosition(camera, _point);
			if (object.overlapsPoint(_point, true, camera))
				return true;
		}

		return false;
	}

    var height:Float = 0;

    var popupTitle:FlxText;
    var popupText:FlxText;
    var unbindText:FlxText;

	override public function create()
	{
		super.create();
        
        FlxG.cameras.add(cam, false);
		FlxG.cameras.add(scrollableCam, false);
		FlxG.cameras.add(overCam, false);
		
		scrollableCam.bgColor = 0x00000000;
		cam.bgColor = 0x00000000;
		overCam.bgColor = 0x00000000;

		overCam.alpha = 0;

		var overbackdrop = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		overbackdrop.setGraphicSize(FlxG.width, FlxG.height);
		overbackdrop.updateHitbox();
		overbackdrop.screenCenter(XY);
		overbackdrop.alpha = 0.5;
		overbackdrop.cameras = [overCam];
		add(overbackdrop);

		var backdropGraphic = Paths.image("optionsMenu/backdrop");

		var popupDrop:FlxUI9SliceSprite = new FlxUI9SliceSprite(0, 0, backdropGraphic,
			new Rectangle(0, 0, 880, 225), [22, 22, 89, 89]);
		popupDrop.cameras = [overCam];
		popupDrop.screenCenter(XY);

		popupTitle = new FlxText(popupDrop.x, popupDrop.y + 10, popupDrop.width, "Currently binding my penis", 16);
		popupTitle.setFormat(Paths.font("calibrib.ttf"), 32, 0xFFFFFFFF, FlxTextAlign.CENTER);
		popupText = new FlxText(popupDrop.x, popupDrop.y + popupTitle.height, popupDrop.width, "Press key to bind\npress to unbind", 16);
		popupText.setFormat(Paths.font("calibri.ttf"), 32, 0xFFFFFFFF, FlxTextAlign.CENTER);
		unbindText = new FlxText(popupDrop.x, popupDrop.y + 180, popupDrop.width, "(Note that this action needs atleast one key bound)", 16);
		unbindText.setFormat(Paths.font("calibri.ttf"), 32, 0xFFFFFFFF, FlxTextAlign.CENTER);

		unbindText.cameras = [overCam];
		popupText.cameras = [overCam];
		popupTitle.cameras = [overCam];

        add(popupDrop);
        add(popupTitle);
        add(popupText);
        add(unbindText);

		var optionMenu = new FlxSprite(84, 80, CoolUtil.makeOutlinedGraphic(920, 570, FlxColor.fromRGB(82, 82, 82), 2, FlxColor.fromRGB(70, 70, 70)));
		optionMenu.alpha = 0.8;
		optionMenu.cameras = [cam];
		optionMenu.screenCenter(XY);
		add(optionMenu);


		scrollableCam.width = Std.int(optionMenu.width);
		scrollableCam.height = Std.int(optionMenu.height);
		scrollableCam.x = optionMenu.x;
		scrollableCam.y = optionMenu.y;

		scrollableCam.targetOffset.x = scrollableCam.width / 2;
		scrollableCam.targetOffset.y = scrollableCam.height / 2;

		scrollableCam.follow(camFollowPos);
		var group = new FlxTypedGroup<FlxObject>();
		
        
        var daY:Float = 0;
        var idx:Int = 0;
        for(data in binds){
            var label = data[0];

            if(data.length > 1){
                // its a bind
				var internal = data[1];
                var buttArray:Array<BindButton> = [];
				internals.push(data[1]);
                
				var text = new FlxText(16, daY, 0, label, 16);
				text.cameras = [scrollableCam];
				text.setFormat(Paths.font("calibri.ttf"), 28, 0xFFFFFFFF, FlxTextAlign.LEFT);
				text.updateHitbox();
				var height = text.height + 12;
				if (height < 45)
					height = 45;
				var drop:FlxUI9SliceSprite = new FlxUI9SliceSprite(text.x - 12, text.y, backdropGraphic, new Rectangle(0, 0, optionMenu.width - text.x - 8, height), [22, 22, 89, 89]);
				drop.cameras = [scrollableCam];
				text.y += (height - text.height) / 2;


				var rect = new Rectangle(0, 0, 200, height - 10);

				var prButt:BindButton = new BindButton(drop.x + drop.width - 40, drop.y, rect, ClientPrefs.keyBinds.get(internal)[0]);
				prButt.x -= prButt.width * 2;
				prButt.y += 5;
				prButt.ID = idx;
				prButt.cameras = [scrollableCam];
				buttArray.push(prButt);


				var secButt:BindButton = new BindButton(drop.x + drop.width - 20, drop.y, rect, ClientPrefs.keyBinds.get(internal)[1]);
				secButt.x -= secButt.width;
				secButt.y += 5;
				secButt.ID = idx;
				secButt.cameras = [scrollableCam];
				buttArray.push(secButt);

                group.add(drop);
                group.add(text);
				group.add(prButt);
                group.add(secButt);
				daY += height + 3;

				bindButtons.push(buttArray);
            }else{
                // its just a label
				var text = new FlxText(8, daY, 0, label, 16);
				text.cameras = [scrollableCam];
				text.setFormat(Paths.font("calibrib.ttf"), 32, 0xFFFFFFFF, FlxTextAlign.LEFT);
				group.add(text);
				daY += text.height;
            }
			idx++;
        }
        

		var text = new FlxText(16, daY, 0, Paths.getString("control_default"), 16);
		text.cameras = [scrollableCam];
		text.setFormat(Paths.font("calibri.ttf"), 28, 0xFFFFFFFF, FlxTextAlign.LEFT);
		text.updateHitbox();
		
		var height = text.height + 12;
		if (height < 45) height = 45;

		resetBinds = new FlxUI9SliceSprite(text.x - 12, text.y, backdropGraphic,
			new Rectangle(0, 0, optionMenu.width - text.x - 8, height), [22, 22, 89, 89]);
		resetBinds.cameras = [scrollableCam];
		text.y += (height - text.height) / 2;
		daY += height + 3;

		daY += 4;

		this.height = daY > scrollableCam.height ? daY - scrollableCam.height : 0;

        group.add(resetBinds);
		group.add(text);
        add(group);
    }

    override function update(elapsed:Float){
        super.update(elapsed);

		var lerpVal = (elapsed / (1 / 60));
		cam.bgColor = FlxColor.interpolate(cam.bgColor, 0x80000000, lerpVal * 0.1);

        if(bindIndex == -1){
			if (controls.BACK)
			{
				close();
				FlxG.cameras.remove(cam);
				FlxG.cameras.remove(scrollableCam);
				FlxG.cameras.remove(overCam);
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}
            if(FlxG.mouse.justPressed){
                for (index in 0...bindButtons.length){
					var fuck = bindButtons[index];
                    for(id => butt in fuck){
                        if(overlaps(butt, scrollableCam)){
							var internal = internals[index];
							bindID = id;
                            bindIndex = index;

							unbindText.visible = forcedBind.contains(internal);
							popupText.text = Paths.getString("control_rebind").replace("{cancelKey}", "[Backspace]"); //'Press any key to bind, or press [BACKSPACE] to cancel.';
							if (ClientPrefs.keyBinds.get(internal)[id]!=NONE)
								popupText.text += "\n" + Paths.getString("control_unbind").replace("{unbindKey}", '[${InputFormatter.getKeyName(ClientPrefs.keyBinds.get(internal)[id])}]');
                            //'\nPress [${InputFormatter.getKeyName(ClientPrefs.keyBinds.get(internal)[id])}] to unbind.';

							popupTitle.text = Paths.getString("control_binding").replace("{controlNameUpper}", binds[butt.ID][0].toUpperCase()).replace("{controlName}", binds[butt.ID][0]); //"CURRENTLY BINDING " + binds[butt.ID][0].toUpperCase();
                        }
                    }
                }

                if(bindIndex == -1){
					if (overlaps(resetBinds, scrollableCam)){
                        // i hate haxeflixel lmao
						for (key => val in ClientPrefs.defaultKeys.copy()){
							ClientPrefs.keyBinds.set(key, []);
                            for(i => v in val){
								if (changedBind!=null)
									changedBind(key, i, v);
                                ClientPrefs.keyBinds.get(key)[i] = v;
                            }
                        }
						
                        for(index => fuck in bindButtons){
                            for(id => butt in fuck){
								var internal = internals[index];
								butt.bind = ClientPrefs.keyBinds.get(internal)[id];
                            }
                        }
						FlxG.sound.play(Paths.sound('confirmMenu'));
						ClientPrefs.saveBinds();
						ClientPrefs.reloadControls();
                    }
                }
            }
            var movement:Float = -FlxG.mouse.wheel * 45;
            var es:Float = elapsed / (1 / 60);

            if (FlxG.keys.pressed.PAGEUP)
                movement -= 25 * es;
            if (FlxG.keys.pressed.PAGEDOWN)
                movement += 25 * es;

            camFollow.y += movement;
            camFollowPos.y += movement;
            if (camFollow.y < 0)
                camFollow.y = 0;
            if (camFollow.y > height)
                camFollow.y = height; 

            camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
            if (camFollowPos.y < 0)
                camFollowPos.y = 0;

            if (camFollowPos.y > height)
                camFollowPos.y = height; 

			overCam.alpha = FlxMath.lerp(overCam.alpha, 0, lerpVal * 0.2);
        }else{
			overCam.alpha = FlxMath.lerp(overCam.alpha, 1, lerpVal * 0.2);

			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			if (keyPressed == BACKSPACE)
			{
				bindID = 0;
				bindIndex = -1;
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}else if (keyPressed != NONE)
            {
				FlxG.sound.play(Paths.sound('confirmMenu'));
                var opp = bindID == 0 ? 1 : 0 ;
                var internal = internals[bindIndex];
				trace("bound " + internal + " (" + bindID + ") to " + InputFormatter.getKeyName(keyPressed));
				var binds = ClientPrefs.keyBinds.get(internal);
				if (binds[bindID] == keyPressed)
					keyPressed = NONE;
                else if(binds[opp] == keyPressed){
					if (changedBind != null)
						changedBind(internal, opp, NONE);
                    binds[opp] = NONE;
					bindButtons[bindIndex][opp].bind = NONE;
                }

                if(forcedBind.contains(internal)){
                    if(keyPressed == NONE && binds[opp] == NONE){
						var defaults = ClientPrefs.defaultKeys.get(internal);
                        // atleast ONE needs to be bound, so use a default
						if (defaults[bindID] == NONE)
                            keyPressed = defaults[opp];
                        else
						    keyPressed = defaults[bindID]; 
                    }
                }
				if (changedBind != null)
					changedBind(internal, bindID, keyPressed);
				binds[bindID] = keyPressed;

                bindButtons[bindIndex][bindID].bind = keyPressed;
				ClientPrefs.keyBinds.set(internal, binds);
				ClientPrefs.saveBinds();
                ClientPrefs.reloadControls();

                bindID = 0;
				bindIndex = -1;
            }
        }

    }
}

class BindButton extends FlxUI9SliceSprite
{
    public var textObject:FlxText;
    public var bind(default, set):FlxKey = NONE;

    function set_bind(key:FlxKey){
        textObject.text = InputFormatter.getKeyName(key);
        return bind = key;
    }

    public function new(?x:Float, ?y:Float, ?rect:Rectangle, bind:FlxKey = NONE){
		super(x, y, Paths.image("optionsMenu/backdrop"), rect, [22, 22, 89, 89]);

		textObject = new FlxText(x, y, 0, InputFormatter.getKeyName(bind), 16);
		textObject.setFormat(Paths.font("calibri.ttf"), 24, 0xFFFFFFFF, FlxTextAlign.CENTER);
		textObject.updateHitbox();
		textObject.y += (height - textObject.height) / 2;
        this.bind = bind;
    }

    override function draw(){
        super.draw();
		textObject.draw();
    }

	override function kill()
	{
		super.kill();
		textObject.kill();
	}

	override function revive()
	{
		super.revive();
		textObject.revive();
	}

	override function destroy()
	{
		super.destroy();
		textObject.destroy();
	}

	override function set_active(val:Bool)
	{
        textObject.active = val;
        return active = val;
	}

	override function set_visible(val:Bool)
	{
		textObject.visible = val;
		return visible = val;
	}

	override function set_cameras(val:Array<FlxCamera>)
	{
		textObject.cameras = val;
		return super.set_cameras(val);
	}

	override function set_x(val:Float)
	{
		if (textObject!=null)
		    textObject.x += val - x;
		return x = val;
	}

	override function set_y(val:Float)
	{
		if (textObject != null)
		    textObject.y += val - y;

		return y = val;
	}

    override function update(elapsed:Float){
		textObject.fieldWidth = width;
        super.update(elapsed);
		textObject.update(elapsed);
    }
}
