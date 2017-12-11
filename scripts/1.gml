#define drawPlayer
///drawPlayer()
//Draws the player.

drawSelf3Colors(global.primaryCol, global.secondaryCol, global.outlineCol);

#define playerStep
///playerStep()
//Handles general step event code for the player

//Check for ground
if place_meeting(x, y+global.yspeed+1, objSolid) || (place_meeting(x, y+global.yspeed+1, objTopSolid)  && global.yspeed >= 0)
|| (place_meeting(x, y+global.yspeed+1, prtMovingPlatformJumpthrough) && global.yspeed >= 0)
|| (place_meeting(x, y+global.yspeed+1, prtMovingPlatformSolid) && !place_meeting(x, y, prtMovingPlatformSolid))
{
    //We are only on the ground if the moving platform is not 'dead' (despawned and ready to respawn)
    if place_meeting(x, y+global.yspeed+1, objSolid)
    {
        ground = true;
    }
    else if place_meeting(x, y+global.yspeed+1, objTopSolid)
    {
        if bbox_bottom < instance_place(x, y+global.yspeed+1, objTopSolid).bbox_top
            ground = true;
        else if !onRushJet
            ground = false;
    }
    else if place_meeting(x, y+global.yspeed+1, prtMovingPlatformJumpthrough)
    {
        if instance_place(x, y+global.yspeed+1, prtMovingPlatformJumpthrough).dead == false
        {
            if bbox_bottom < instance_place(x, y+global.yspeed+1, prtMovingPlatformJumpthrough).bbox_top
                ground = true;
            else
                ground = false;
        }
        else if !onRushJet
            ground = false;
    }
    else if place_meeting(x, y+global.yspeed+1, prtMovingPlatformSolid)
    {
        if instance_place(x, y+global.yspeed+1, prtMovingPlatformSolid).dead == false
            ground = true;
        else
            ground = false;
    }
    else
    {
        ground = true;
    }
}
else
{
    ground = false;
    if prevGround == true
        y += 1; //To make Mega Man able to fall through 1-block wide gaps
}


//Should the landing sound be played when colliding with a floor? (Disabled on ladders, for example)
//Lasts two frames because one extra frame is required for the collision to register
if playLandSoundTimer < 2
{
    playLandSoundTimer += 1;
}
else
{
    playLandSound = true;
}


//Movement (includes initializing sidestep while on the ground)
if canMove == true
{
    if ground == true
    {
        if global.keyLeft && !global.keyRight
        {
            if canInitStep == true
            {
                canInitStep = false;
                isStep = true;
                image_xscale = -1;
            }
            else if isStep == false
            {
                if !(place_meeting(x, y+1, objIce) && global.xspeed > 0)
                {
                    //Normal physics
                    if !place_meeting(x-1, y, objSolid) && !place_meeting(x-1, y, prtMovingPlatformSolid)
                        global.xspeed = -walkSpeed;
                    else if place_meeting(x-1, y, prtMovingPlatformSolid) //Still walk when the moving platform is despawned
                    {
                        if instance_place(x-1, y, prtMovingPlatformSolid).dead == true
                            global.xspeed = -walkSpeed;
                    }
                }
                else
                {
                    //Ice physics
                    if !place_meeting(x-1, y, objSolid) && !place_meeting(x-1, y, prtMovingPlatformSolid)
                        global.xspeed -= iceDecWalk;
                    else if place_meeting(x-1, y, prtMovingPlatformSolid) //Still walk when the moving platform is despawned
                    {
                        if instance_place(x-1, y, prtMovingPlatformSolid).dead == true
                            global.xspeed -= iceDecWalk;
                    }
                }
                    
                image_xscale = -1;
                            
                if canSpriteChange == true
                {
                    sprite_index = spriteWalk;
                    image_speed = 0.15;
                }
            }
        }
        else if global.keyRight && !global.keyLeft
        {
            if canInitStep == true
            {
                canInitStep = false;
                isStep = true;
                image_xscale = 1;
            }
            else if isStep == false
            {
                if !(place_meeting(x, y+1, objIce) && global.xspeed < 0)
                {
                    //Normal physics
                    if !place_meeting(x+1, y, objSolid) && !place_meeting(x+1, y, prtMovingPlatformSolid)
                        global.xspeed = walkSpeed;
                    else if place_meeting(x+1, y, prtMovingPlatformSolid) //Still walk when the moving platform is despawned
                    {
                        if instance_place(x+1, y, prtMovingPlatformSolid).dead == true
                            global.xspeed = walkSpeed;
                    }
                }
                else
                {
                    //Ice physics
                    if !place_meeting(x+1, y, objSolid) && !place_meeting(x+1, y, prtMovingPlatformSolid)
                        global.xspeed += iceDecWalk;
                    else if place_meeting(x+1, y, prtMovingPlatformSolid) //Still walk when the moving platform is despawned
                    {
                        if instance_place(x+1, y, prtMovingPlatformSolid).dead == true
                            global.xspeed += iceDecWalk;
                    }
                }
                    
                image_xscale = 1;
                
                if canSpriteChange == true
                {
                    sprite_index = spriteWalk;
                    image_speed = 0.15;
                }
            }
        }
        else
        {
            if !(place_meeting(x, y+1, objIce) && global.xspeed != 0)
            {
                //Normal physics
                global.xspeed = 0;
                canInitStep = true;
            }
            else
            {
                //Ice physics
                if global.xspeed > 0
                    global.xspeed -= iceDec;
                else if global.xspeed < 0
                    global.xspeed += iceDec;
                    
                if global.xspeed > -iceDec && global.xspeed < iceDec
                    global.xspeed = 0;
            }
            
            if global.keyLeft && !global.keyRight
                image_xscale = -1;
            else if global.keyRight && !global.keyLeft
                image_xscale = 1;
            
            if canSpriteChange {
                image_speed = 0;
                if !prevGround {    //Landing animation
                    sprite_index = spriteWalk;
                    image_index = 1;
                }
                else {
                    sprite_index = spriteStand;
                    image_index = blinkImage;
                }
            }
        }
    }
    else
    {
        canInitStep = false;
        isStep = false;
        
        if canSpriteChange == true
            sprite_index = spriteJump;
            
        if global.keyLeft && !global.keyRight && !place_meeting(x-1, y, objSolid)
        {
            if !place_meeting(x-1, y, prtMovingPlatformSolid)
            {
                global.xspeed = -walkSpeed;
                image_xscale = -1;
            }
            else
            {
                if instance_place(x-1, y, prtMovingPlatformSolid).dead == true //Still allow movement when the moving platform is despawned
                {
                    global.xspeed = -walkSpeed;
                    image_xscale = -1;
                }
            }
        }
        else if global.keyRight && !global.keyLeft && !place_meeting(x+1 + (prevXScale == -1), y, objSolid) //For some reason, while on the left of the wall and facing left, then jumping and holding right would clip you through it. Prevented by checking if the player was facing left on the previous frame, and if so, disallow Mega Man to move if 2 pixels away from the wall instead of 1
        {
            if !place_meeting(x+1 + (prevXScale == -1), y, prtMovingPlatformSolid)
            {
                global.xspeed = walkSpeed;
                image_xscale = 1;
            }
            else
            {
                if instance_place(x+1 + (prevXScale == -1), y, prtMovingPlatformSolid).dead == true //Still allow movement when the moving platform is despawned
                {
                    global.xspeed = walkSpeed;
                    image_xscale = 1;
                }
            }
        }
        else
        {
            global.xspeed = 0;
            
            if global.keyLeft && !global.keyRight
                image_xscale = -1;
            else if global.keyRight && !global.keyLeft
                image_xscale = 1;
        }
    }
}
else if canSpriteChange == true
{
    //Even if canMove is false, we should still be able to change sprites
    if ground == true
    {
        if global.xspeed == 0
        {
            sprite_index = spriteStand;
            image_index = blinkImage;
            image_speed = 0;
        }
        else
        {
            sprite_index = spriteWalk;
            image_speed = 0.15;
        }
    }
    else
    {
        sprite_index = spriteJump;
    }
}


//Blinking animation
if sprite_index == asset_get_index("spr" + global.sprName + "Stand") { //Don't use spriteStand as this could also be sprMegamanStandShoot!
    blinkTimer++;
    if blinkImage == 0 {
        if blinkTimer >= blinkTimerMax {
            blinkImage = 1;
            blinkTimer = 0;
        }
    }
    else {
        if blinkTimer >= blinkDuration {
            blinkImage = 0;
            blinkTimer = 0;
        }
    }
}
else {
    blinkTimer = 0;
    blinkImage = 0;
}


//Sidestepping
if isStep {
    if !place_meeting(x+image_xscale, y, objSolid) && !place_meeting(x+image_xscale, y, prtMovingPlatformSolid)
        global.xspeed = stepSpeed * image_xscale;
    else if place_meeting(x+image_xscale, y, prtMovingPlatformSolid) {
        if instance_place(x+image_xscale, y, prtMovingPlatformSolid).dead == true //Still allow movement when the moving platform is despawned
            global.xspeed = stepSpeed * image_xscale;
    }
    
    if canSpriteChange
        sprite_index = spriteStep;
    
    stepTimer++;
    if stepTimer >= stepFrames {
        isStep = false;
        stepTimer = 0;
    }
}


//Allow movement
move(global.xspeed, global.yspeed);

//Avoids free movement on screen above
if (!ground && !climbing && !instance_exists(objSectionSwitcher) && sprite_get_bottom() < sectionTop) {
    y = sectionTop - sprite_height;
}


//Stop movement at section borders
if (canMove || isSlide) && visible {
    if x > sectionRight-6 && !place_meeting(x+6, y, objSectionArrowRight) && !place_meeting(x-global.xspeed, y, objSectionArrowRight) {
        x = sectionRight-6;
        global.xspeed = 0;
    }
    else if x < sectionLeft+6 && !place_meeting(x-6, y, objSectionArrowLeft) && !place_meeting(x-global.xspeed, y, objSectionArrowLeft) {
        x = sectionLeft+6;
        global.xspeed = 0;
    }    
    if y < sectionTop-32 {
        y = sectionTop-32;
    }
    else if bbox_top > sectionBottom && !place_meeting(x, y, objSectionArrowDown) {
        global._health = 0;
        deathByPit = true;
    }
}   
    
//Stop movement at room borders
if x > room_width-6
    x = room_width-6;
else if x < 6
    x = 6;
    
if y < -32
    y = -32;
else if bbox_top > room_height
{
    global._health = 0;
    deathByPit = true;
}


//Jumping
if (canMove || (isThrow and room != rmWeaponGet) || onRushJet) && ground && global.keyJumpPressed && !global.keyDown
{
    if isThrow {  //We can jump-cancel the throwing animation (after throwing a Metal Blade, Pharaoh Shot etc)
        canMove = true;
        canSpriteChange = true;
        shootTimer -= 5; //20 frames for freezing was too long so it was changed to 15. However, when not frozen, 20 looks better
    }
    else if onRushJet {
        canMove = true;
    }
    
    global.yspeed = -currentJumpSpeed;
    ground = false;
    canMinJump = true;
    y -= 1; //To negate the prevGround y += 1
    sprite_index = spriteJump;
}


//Minjumping (lowering jump when the jump button is released)
if ground == false && global.yspeed < 0 && !global.keyJump && canMinJump == true
{
    canMinJump = false;
    global.yspeed = 0;
}


var box;
if image_xscale == 1
    box = bbox_right;
else
    box = bbox_left;
    
//Sliding
if enableSlide {
    if ground && !isSlide && ((global.keyJumpPressed && global.keyDown) || (global.enableSlideKey && global.keySlidePressed)) 
        && (canMove || (isThrow and room != rmWeaponGet)) && !position_meeting(box+image_xscale*5, bbox_bottom-12, objSolid)
    {
        var canSld = false;
        
        if !position_meeting(box+image_xscale*5, bbox_bottom-12, prtMovingPlatformSolid) {
            canSld = true;
        }
        else {
            if instance_position(box+image_xscale*5, bbox_bottom-12, prtMovingPlatformSolid).dead == true //We can still slide if the moving platform is despawned
                canSld = true;
        }
        
        
        if canSld {
            if isThrow {
                isThrow = false;
                shootTimer -= 5; //20 frames for freezing was too long so it was changed to 15. However, when not frozen, 20 looks better
            }
            
            isSlide = true;
            canMove = false;
            canSpriteChange = false;
            sprite_index = spriteSlide;
            mask_index = mskMegamanSlide;
            
            if image_xscale == -1
                with instance_create(bbox_right-2, bbox_bottom-2, objSlideDust) image_xscale = -1;
            else
                instance_create(bbox_left+2, bbox_bottom-2, objSlideDust);
            
            /*while position_meeting(x, y+5, objSolid) || (position_meeting(x, y+5, prtMovingPlatformSolid) && !instance_position(x, y+5, prtMovingPlatformSolid).dead) {
                x += image_xscale;
            }*/
            
            global.xspeed = slideSpeed * image_xscale;
        }
    }
    
    
    //While sliding
    if isSlide {
        image_speed = 1/6;
        isStep = false;
        canInitStep = false;
        slideTimer++;
        
        var canProceed = true;
        
        if ((place_meeting(x, y-3, objSolid) and !place_meeting(x, y-3, objSpike)) || place_meeting(x, y-3, prtMovingPlatformSolid)) && (ground == true || place_meeting(x-(slideSpeed-1), y+1, objSolid) || place_meeting(x-(slideSpeed-1), y+1, objTopSolid) || place_meeting(x-(slideSpeed-1), y+1, prtMovingPlatformJumpthrough) || place_meeting(x-(slideSpeed-1), y+1, prtMovingPlatformSolid)
        || place_meeting(x+(slideSpeed-1), y, objSolid) || place_meeting(x+(slideSpeed-1), y, prtMovingPlatformSolid)) //Extra check because if Mega Man falls down while sliding and a wall is on the other side of him and a ceiling is on top of him, when turning around on the right frame he would zip through the solids
        {            
            if place_meeting(x, y-3, prtMovingPlatformSolid)
            {
                if instance_place(x, y-3, prtMovingPlatformSolid).dead == true
                    canProceed = false;
            }
            if place_meeting(x-(slideSpeed-1), y+1, prtMovingPlatformSolid)
            {
                if instance_place(x-(slideSpeed-1), y+1, prtMovingPlatformSolid).dead == true
                    canProceed = false;
            }
            if place_meeting(x+(slideSpeed-1), y, prtMovingPlatformSolid)
            {
                if instance_place(x+(slideSpeed-1), y, prtMovingPlatformSolid).dead == true
                    canProceed = false;
            }
            if place_meeting(x-(slideSpeed-1), y+1, prtMovingPlatformJumpthrough)
            {
                if instance_place(x-(slideSpeed-1), y+1, prtMovingPlatformJumpthrough).dead == true
                    canProceed = false;
            }
            
            if canProceed {
                if global.keyLeft && !global.keyRight
                {
                    image_xscale = -1;
                    global.xspeed = -slideSpeed;
                }
                else if global.keyRight && !global.keyLeft
                {
                    image_xscale = 1;
                    global.xspeed = slideSpeed;
                }
                
                ground = true;  //For the bugfix as explained on the second line of the place_meeting checks
            }
        }
        else
        {
            canProceed = false;
        }
        
        
        if !canProceed {
            if !ground || (global.keyLeft && !global.keyRight && image_xscale == 1)
            || (global.keyRight && !global.keyLeft && image_xscale == -1)
            || slideTimer >= slideFrames || (global.keyJumpPressed && !global.keyDown)
            || place_meeting(x+image_xscale*3, y, objSolid) || place_meeting(x+image_xscale*3, y, prtMovingPlatformSolid)
            {
                var stopSld = true;
                
                if !ground || (global.keyLeft && !global.keyRight && image_xscale == 1)
                || (global.keyRight && !global.keyLeft && image_xscale == -1)
                || slideTimer >= slideFrames || (global.keyJumpPressed && !global.keyDown)
                || place_meeting(x+image_xscale*3, y, objSolid)
                {
                    stopSld = true;
                }
                else if place_meeting(x+image_xscale*3, y, prtMovingPlatformSolid)
                {
                    if instance_place(x+image_xscale*3, y, prtMovingPlatformSolid).dead == true //We should not stop sliding if the moving platform is despawned
                        stopSld = false;
                }
                
                if stopSld {
                    isSlide = false;
                    canMove = true;
                    canSpriteChange = true;
                    mask_index = mskMegaman;
                    slideTimer = 0;
                    
                    var endLoop = false;
                    
                    //Pushing down until not inside a ceiling anymore
                    while (place_meeting(x, y, objSolid) || place_meeting(x, y, prtMovingPlatformSolid)) && endLoop == false      //If your slide cancels right under a ceiling, move MM down
                    {
                        if place_meeting(x, y, objSpike) {
                            playerCollision();
                            break;
                        }
                        if !place_meeting(x, y, objSolid) && place_meeting(x, y, prtMovingPlatformSolid)
                        {
                            if instance_place(x, y, prtMovingPlatformSolid).dead == true
                                endLoop = true;
                        }
                        
                        if !endLoop {
                            y++;
                            sprite_index = spriteJump;
                            ground = false;
                        }
                    }
                        
                    if !place_meeting(x, y+1, objIce)
                        global.xspeed = 0;
                    else
                        global.xspeed = walkSpeed * image_xscale;
                    
                    if global.keyJumpPressed && !global.keyDown
                    {
                        global.yspeed = -jumpSpeed;
                        ground = false;
                        y -= 1; //To negate the prevGround y += 1
                    }
                }
            }
        }
    }
    else
    {
        slideTimer = 0;
    }
}


//Climbing
var ladder, ladderDown;
ladder = collision_rectangle(sprite_get_xcenter()-3, bbox_top+4, sprite_get_xcenter()+3, bbox_bottom-1, objLadder, false, false);
ladderDown = collision_rectangle(sprite_get_xcenter()-1, bbox_bottom+1, sprite_get_xcenter()+1, bbox_bottom+2, objLadder, false, false);
var solidDown = collision_rectangle(sprite_get_xcenter()-1, bbox_bottom+1, sprite_get_xcenter()+1, bbox_bottom+2, objSolid, false, false);
var solidAbove = false;
if (ladderDown >= 0) {
    with ladderDown {
        solidAbove = !place_free(x, y - 1);
    }
}
if ((ladder >= 0 && global.keyUp && !global.keyDown)
|| (ladderDown >= 0 and solidDown < 0 and !solidAbove and ground and !isSlide and global.keyDown and !global.keyUp and !place_meeting(x, y, objLadder)))
&& (canMove == true || isSlide == true) && sprite_get_bottom() > sectionTop {
    isSlide = false;
    mask_index = mskMegaman;
    slideTimer = 0;
    
    climbing = true;
    canMove = false;
    canSpriteChange = false;
    canGravity = false;
    
    global.xspeed = 0;
    global.yspeed = 0;
    
    if ladder >= 0
        x = ladder.x+8;
    else if ladderDown >= 0
    {
        x = ladderDown.x+8;
        y += climbSpeed * 2 + 2;
        ground = false;
    }
    
    sprite_index = spriteClimb;
    image_speed = 0;
    
    ladderXScale = image_xscale;
    climbShootXscale = ladderXScale;
}


//While climbing
if climbing == true
{
    isStep = false;
    canInitStep = false;
    
    //Movement
    if global.keyUp && !global.keyDown && isShoot == false && isThrow == false
    {
        climbSpriteTimer += 1;
        global.yspeed = -climbSpeed;
    }
    else if global.keyDown && !global.keyUp && isShoot == false && isThrow == false
    {
        climbSpriteTimer += 1;
        global.yspeed = climbSpeed;
    }
    else
    {
        global.yspeed = 0;
    }
    
    //Left/right
    if global.keyRight && !global.keyLeft
        climbShootXscale = 1;
    else if global.keyLeft && !global.keyRight
        climbShootXscale = -1;
    
    if climbSpriteTimer >= 8 && sprite_index == spriteClimb && isShoot == false && isThrow == false
    {
        climbSpriteTimer = 0;
        image_xscale = -image_xscale;
    }
    
    //Getup sprite
    if !position_meeting(x, bbox_top+7, objLadder) && position_meeting(x, bbox_bottom+1, objLadder) //The second check is to make sure the getup animation is not shown when on the BOTTOM of a ladder that's placed in the air
    {
        sprite_index = spriteGetup;
        if sprite_index == sprMegamanClimbGetup //not when shooting
            image_xscale = 1;
        if global.yspeed < 0 && !position_meeting(x, bbox_top+14, objLadder) {
            while place_meeting(x, y, objLadder) {
                y--;
            }
        }
    }
    else
    {
        sprite_index = spriteClimb;
    }
    
    //Releasing the ladder
    if (ground == true && !global.keyUp) || !place_meeting(x, y, objLadder) || (global.keyJumpPressed && !global.keyUp)
    {
        climbing = false;
        canMove = true;
        canSpriteChange = true;
        canGravity = true;
        image_xscale = ladderXScale;
        global.yspeed = 0;
        
        if position_meeting(x, bbox_bottom+15, objTopSolid) || ground == true {
            ground = true;  //To avoid "falling" after climbing (shouldn't play the landing sfx)
            if (global.keyRight && !global.keyLeft) || (global.keyLeft && !global.keyRight) {
                sprite_index = spriteWalk;
                
                if global.keyRight {
                    global.xspeed = walkSpeed;
                    image_xscale = 1;
                }
                else if global.keyLeft {
                    global.xspeed = -walkSpeed;
                    image_xscale = -1;
                }
            }
            else {
                sprite_index = spriteStand;
            }
        }
        else {
            sprite_index = spriteJump;
        }
        
        if !place_meeting(x, y+1, objLadder)
        {
            var topSolidID;
            topSolidID = instance_place(x, y+2, objTopSolid);
            if topSolidID >= 0
                y = topSolidID.y - (sprite_get_height(mask_index) - sprite_get_yoffset(mask_index));
                
            playLandSound = false;
            playLandSoundTimer = 0;
        }
    }
}


//Water
if place_meeting(x, y, objWater) && inWater == false
{
    inWater = true;
    playSFX(sfxSplash);
    
    var currentWater;
    currentWater = instance_place(x, y, objWater);
    instance_create(x, currentWater.bbox_top+1, objSplash);
}

if inWater == true
{
    currentGrav = gravWater;
    currentJumpSpeed = jumpSpeedWater;
    
    bubbleTimer += 1;
    if bubbleTimer >= 10
    {
        bubbleTimer = 0;
        if !instance_exists(objAirBubble)
            instance_create(x, y, objAirBubble);
    }
}
else
{
    currentGrav = grav;
    currentJumpSpeed = jumpSpeed;
    bubbleTimer = 0;
}


//Leaving the water
if inWater == true
{
    var wtr;
    wtr = instance_place(x, y-global.yspeed, objWater);
    if wtr >= 0
    {
        if bbox_bottom < wtr.bbox_top
        {
            instance_create(x, wtr.bbox_top+1, objSplash);
            inWater = false;
            playSFX(sfxSplash);
        }
    }
}
    

//While being hit
if isHit {
    hitTimer += 1;
    if hitTimer >= hitTime {
        isHit = false;
        drawHitspark = false;
        hitTimer = 0;
        
        //When sliding and there's a solid above us, we should not experience knockback
        //If we did, we would clip inside the ceiling above us
        if !(isSlide && (place_meeting(x, y-3, objSolid) || place_meeting(x, y-3, prtMovingPlatformSolid))) {
            canMove = true;
            canSpriteChange = true;
        }
        
        invincibilityTimer = 60;
    }
    else {
        if hitTimer mod 4 == 0 || hitTimer mod 4 == 1  //mod: modulo, %. Gives the remainder
            drawHitspark = true;
        else
            drawHitspark = false;
    }
}


//Invincibility
if invincibilityTimer != 0
{
    invincibilityTimer -= 1;
    if invincibilityTimer <= 0
    {
        invincibilityTimer = 0;
        canHit = true;
        visible = true;
    }
    else
    {
        if invincibilityTimer mod 2 == 1
            visible = false;
        else
            visible = true;
    }
}


//Dying
if global._health <= 0 {
    if !deathByPit {
        var i, explosionID;
            
        i = 0;
        repeat 8 {
            explosionID = instance_create(x, y, objMegamanExplosion);
            explosionID.dir = i;
            explosionID.spd = 1.5;
                
            i += 45;
        }
        
        i = 0;
        repeat 8 {
            explosionID = instance_create(x, y, objMegamanExplosion);
            explosionID.dir = i;
            explosionID.spd = 2.5;
                
            i += 45;
        }
    }
    
    instance_create(x, y, objMegamanDeathTimer); //Because the Mega Man object is destoyed upon death, we need to make a different object execute the room restarting code
    instance_destroy();
    
    stopAllSFX();
    playSFX(sfxDeath);
}


//Gravity
if ground == false && canGravity == true
{
    global.yspeed += currentGrav;
    if global.yspeed > maxVspeed
        global.yspeed = maxVspeed;
}
else
{
    canMinJump = true;
}


//Variables on the previous frame
prevGround = ground;
prevXScale = image_xscale;


escapeWall();

#define playerShoot
///playerShoot()
//Handles Mega Man's shooting


var box, yy, attackID;
if image_xscale == 1
    box = bbox_right + shoot_shift;
else
    box = bbox_left - shoot_shift;
    
switch sprite_index
{
    case spriteStand: yy = y+shoot_height; break;
    case spriteStep: yy = y+shoot_height; break;
    case spriteWalk: yy = y+shoot_height; break;
    case spriteJump: yy = y+jump_shoot_height; break;
    case spriteClimb: yy = y+shoot_height; break;
    default: yy = y+shoot_height; break;
}


//Shooting
if global.keyShootPressed && canShoot && (canMove || climbing || (isThrow and room != rmWeaponGet) || onRushJet)
&& instance_number(objBusterShotCharged) < 1 && global.ammo[global.currentWeapon] > 0
{   
    if climbing {
        image_xscale = climbShootXscale;
        
        if image_xscale == 1
            box = bbox_right;
        else
            box = bbox_left;
    }
    
    with global.weapons[global.weapon] {
        print("Trying to use " + name + " with " + string(ammo) + " ammo");
        event_user(1);
    }
    
}


//While shooting
if isShoot {
    isThrow = false;
    shootTimer++;
    if shootTimer >= 20 {
        isShoot = false;
    }
}
else if isThrow { //Throwing weapons, like Pharaoh Shot and Metal Blade
    isShoot = false;
    
    //To allow shooting in the opposite direction
    if global.keyShootPressed {
        if global.keyRight && !global.keyLeft
            image_xscale = 1;
        else if global.keyLeft && !global.keyRight
            image_xscale = -1;
    }
    
    if ground && shootTimer == 0 && !climbing { //Only do this on the ground on the first frame
        canMove = false;
        global.xspeed = 0;
        canSpriteChange = false;
        playerHandleSprites(); //We need to call this script because between throwing and checking throwing, it isn't executed and the wrong sprite would display
        sprite_index = spriteStand;
        shootTimer = 5; //20 frames is too much to be frozen for. However, when not frozen, 20 frames looks better
    }
    
    if !ground && !climbing {
        canMove = true;
        canSpriteChange = true;
    }
    
    shootTimer++;
    if shootTimer >= 20 {
        isThrow = false;
        if ground {
            canMove = true;
            canSpriteChange = true;
        }
    }
}

instance_activate_object(prtWeapon);

//Charging weapons
if global.weapons[global.currentWeapon].ammo > 0 and room != rmWeaponGet {
    if global.keyShoot || (isSlide && global.weapons[global.currentWeapon].chargeTimer != 0) {    // Pressing shoot key
        with global.weapons[global.currentWeapon] event_user(3);
    }
    if !global.keyShoot && global.weapons[global.currentWeapon].chargeTimer != 0 {  // Shoot key released
        with global.weapons[global.currentWeapon] event_user(4);
    }
}

#define playerCollision
///playerCollision()
//Handles the player's collision code


var mySolid, mySpikeFloor, mySpikeWall, mySpikeCeiling;

//Spikes
mySolid = instance_place(x, y+global.yspeed+1, objSolid);
mySolidLeft = instance_place(bbox_left + 4, y+global.yspeed+1, objSolid);
mySolidRight = instance_place(bbox_right - 4, y+global.yspeed+1, objSolid);
mySpikeFloor = instance_place(x, y+global.yspeed+1, objSpike);
mySpikeWall = instance_place(x+global.xspeed, y, objSpike);
mySpikeCeiling = instance_place(x, y+global.yspeed-1, objSpike);
if ((mySpikeFloor >= 0 and mySolid > -1 and mySolid.object_index == objSpike and (mySolidLeft == -1 or mySolidLeft.object_index == objSpike) and (mySolidRight == -1 or mySolidRight.object_index == objSpike)) || mySpikeWall >= 0 || mySpikeCeiling >= 0) && canHit {
    if objShockGuardEquip.count < 1 {
        global._health = 0;
        exit;
    }
    else {
        objShockGuardEquip.count--;
        playerGetHit(1);
    }
}


//Floor
mySolid = instance_place(x, y+global.yspeed, objSolid);
if mySolid >= 0 && global.yspeed > 0 {
    y = mySolid.y - (sprite_get_height(mask_index) - sprite_get_yoffset(mask_index));
    ground = true;
    global.yspeed = 0;
    
    if playLandSound == true {
        playSFX(sfxLand);
    }
    
    //Note: there used to be a system here that set MM's sprite to the walking sprite when landing
    //However, due to complications such as climbing up ladders, it was a lot of work for such a minor feature
    //Therefore, it has been removed
}


//Wall
mySolid = instance_place(x+global.xspeed, y, objSolid);
if mySolid >= 0 && global.xspeed != 0 {
    if global.xspeed < 0
        x = mySolid.x + mySolid.sprite_width + sprite_get_xoffset(mask_index) - sprite_get_bbox_left(mask_index) + 1;
    else
        x = mySolid.x - (sprite_get_width(mask_index) - sprite_get_xoffset(mask_index)) + (sprite_get_width(mask_index) - sprite_get_bbox_right(mask_index)) - 1;
        
    global.xspeed = 0;
}


//Ceiling
mySolid = instance_place(x, y+global.yspeed, objSolid);
if mySolid >= 0 && global.yspeed < 0 {
    y = mySolid.y + mySolid.sprite_height + sprite_get_yoffset(mask_index);
    global.yspeed = 0;
}


//Topsolids
mySolid = instance_place(x, y+global.yspeed, objTopSolid);
if mySolid >= 0 && global.yspeed > 0 {
    if !place_meeting(x, y, mySolid) {
        y = mySolid.y - (sprite_get_height(mask_index) - sprite_get_yoffset(mask_index));
        ground = true;
        global.yspeed = 0;
        
        if playLandSound {
            playSFX(sfxLand);
        }
    }
}

#define playerMovingPlatform
///playerMovingPlatform()
//Handles moving platform collision


//Jumpthrough moving platforms
mySolid = instance_place(x, y+global.yspeed, prtMovingPlatformJumpthrough);
if mySolid >= 0 && global.yspeed > 0
{
    if mySolid.dead == false
    {
        if !place_meeting(x, y, mySolid)
        {
            y = mySolid.bbox_top - (sprite_get_height(mask_index) - sprite_get_yoffset(mask_index));
            ground = true;
            global.yspeed = 0;
            
            if playLandSound == true
                playSFX(sfxLand);
        }
    }
}


//Floor (moving platforms)
mySolid = instance_place(x, y+global.yspeed, prtMovingPlatformSolid);
if mySolid >= 0 /*&& global.yspeed >= 0*/ && !place_meeting(x, y, mySolid)
&& collision_rectangle(bbox_left, bbox_bottom, bbox_right, bbox_bottom+global.yspeed+1, mySolid, false, false)
{
    if mySolid.dead == false
    {
        y = mySolid.bbox_top - (sprite_get_height(mask_index) - sprite_get_yoffset(mask_index));
        ground = true;
        global.yspeed = 0;
        
        if playLandSound == true
            playSFX(sfxLand);
            
        
        //Note: there used to be a system here that set MM's sprite to the walking sprite when landing
        //However, due to complications such as climbing up ladders, it was a lot of work for such a minor feature
        //Therefore, it has been removed
    }
}


//Wall (moving platforms)
mySolid = instance_place(x+global.xspeed, y, prtMovingPlatformSolid);
if mySolid >= 0 && global.xspeed != 0 && !collision_rectangle(bbox_left+4, bbox_bottom, bbox_right-4, bbox_bottom+3, mySolid, false, false)
{
    if mySolid.dead == false
    {
        if global.xspeed < 0 && mySolid.xspeed >= 0
            x = mySolid.bbox_right + sprite_get_xoffset(mask_index) - sprite_get_bbox_left(mask_index) + 1;
        else if mySolid.xspeed <= 0
            x = mySolid.bbox_left - (sprite_get_width(mask_index) - sprite_get_xoffset(mask_index)) + (sprite_get_width(mask_index) - sprite_get_bbox_right(mask_index)) - 1;
            
        global.xspeed = 0;
    }
}


//Ceiling (moving platforms)
mySolid = instance_place(x, y+global.yspeed+sign(global.yspeed), prtMovingPlatformSolid);
if mySolid >= 0 && global.yspeed < 0 && !place_meeting(x, y, mySolid)
{
    if mySolid.dead == false
    {
        y = mySolid.bbox_bottom + sprite_get_yoffset(mask_index);
        global.yspeed = mySolid.yspeed;
    }
}

#define playerHandleSprites
///playerHandleSprites()
//Handles the player's sprites, e.g. use different sprites when shooting
//Note that some sprites like sliding are static and are thus not altered in this script
if !instance_exists(global.character) exit;

if isShoot {
    spriteStand = asset_get_index("spr" + global.character.sprName + "StandShoot");
    spriteStep = asset_get_index("spr" + global.character.sprName + "StandShoot");
    spriteJump = asset_get_index("spr" + global.character.sprName + "JumpShoot");
    spriteWalk = asset_get_index("spr" + global.character.sprName + "WalkShoot");
    spriteClimb = asset_get_index("spr" + global.character.sprName + "ClimbShoot");
    spriteGetup = asset_get_index("spr" + global.character.sprName + "ClimbShoot");
}
else if isThrow {
    spriteStand = asset_get_index("spr" + global.character.sprName + "StandThrow");
    spriteStep = asset_get_index("spr" + global.character.sprName + "StandThrow");
    spriteJump = asset_get_index("spr" + global.character.sprName + "JumpThrow");
    spriteWalk = asset_get_index("spr" + global.character.sprName + "WalkThrow");
    spriteClimb = asset_get_index("spr" + global.character.sprName + "ClimbThrow");
    spriteGetup = asset_get_index("spr" + global.character.sprName + "ClimbThrow");
}
else {
    spriteStand = asset_get_index("spr" + global.character.sprName + "Stand");
    spriteStep = asset_get_index("spr" + global.character.sprName + "Step");
    spriteJump = asset_get_index("spr" + global.character.sprName + "Jump");
    spriteWalk = asset_get_index("spr" + global.character.sprName + "Walk");
    spriteClimb = asset_get_index("spr" + global.character.sprName + "Climb");
    spriteGetup = asset_get_index("spr" + global.character.sprName + "ClimbGetup");
}

#define playerPause
///playerPause()
//Pauses the game when the pause button is pressed

if global.keyPausePressed && canPause && instance_exists(prtPlayer) {
    global.weapons[global.currentWeapon].initChargeTimer = 0;
    global.weapons[global.currentWeapon].chargeTimer = 0;

    global.frozen = true;
    instance_create(x, y, objPauseMenu);
    playSFX(sfxPause);
}

#define playerCameraInit
///playerCameraInit()
//Initialize the camera
//For the meanings of newSectionXOffset/newSectionYOffset, see playerSwitchSections
var dist;


//Left
dist = 0;
while !place_meeting(floor((x+newSectionXOffset)/16)*16 - dist, y+newSectionYOffset, objSectionBorderLeft)
&& dist <= 16 * 200
{
    dist += 16;
}

if dist >= 16 * 200
{
    show_message("Got stuck on left");
}

sectionLeft = instance_place(floor((x+newSectionXOffset)/16)*16 - dist, y+newSectionYOffset, objSectionBorderLeft).x;


//Right
dist = 0;
while !place_meeting(ceil((x+newSectionXOffset)/16)*16 + dist, y+newSectionYOffset, objSectionBorderRight)
&& dist <= 16 * 200
{
    dist += 16;
}

if dist >= 16 * 200
{
    show_message("Got stuck on right");
}

sectionRight = instance_place(ceil((x+newSectionXOffset)/16)*16 + dist, y+newSectionYOffset, objSectionBorderRight).x + 16;


//Top
dist = 0;
while !place_meeting(x+newSectionXOffset, floor((y+newSectionYOffset)/16)*16 - dist, objSectionBorderTop)
&& dist <= 16 * 200
{
    dist += 16;
}

if dist >= 16 * 200
{
    show_message("Got stuck on top");
}


sectionTop = instance_place(x+newSectionXOffset, floor((y+newSectionYOffset)/16)*16 - dist, objSectionBorderTop).y;


//Bottom
dist = 0;
while !place_meeting(x+newSectionXOffset, ceil((y+newSectionYOffset)/16)*16 + dist, objSectionBorderBottom)
&& dist <= 16 * 200
{
    dist += 16;
}

if dist >= 16 * 200
{
    show_message("Got stuck on bottom");
}

sectionBottom = instance_place(x+newSectionXOffset, ceil((y+newSectionYOffset)/16)*16 + dist, objSectionBorderBottom).y + 16;

#define playerCamera
///playerCamera()
//Handles the camera
//Call it in prtPlayer

//Follow the player
view_xview[0] = round(x - view_wview[0] / 2);
view_yview[0] = round(y - view_hview[0] / 2);

//Stop at section borders
if view_xview[0] > sectionRight-view_wview[0]
    view_xview[0] = sectionRight-view_wview[0];
else if view_xview[0] < sectionLeft
    view_xview[0] = sectionLeft;
    
if view_yview[0] > sectionBottom-view_hview[0]
    view_yview[0] = sectionBottom-view_hview[0];
else if view_yview[0] < sectionTop
    view_yview[0] = sectionTop;
    
    
//Stop at room borders
if view_xview[0] > room_width-view_wview[0]
    view_xview[0] = room_width-view_wview[0];
else if view_xview[0] < 0
    view_xview[0] = 0;
    
if view_yview[0] > room_height-view_hview[0]
    view_yview[0] = room_height-view_hview[0];
else if view_yview[0] < 0
    view_yview[0] = 0;

#define playerSwitchSections
///playerSwitchSections()
//Moving from one section to the next, if possible

//newSectionXOffset/newSectionYOffset are used to get the right section borders in the new section
//Taking the normal X/Y coordinate would result in rounding errors in playerCameraInit(),
//which could either cause the game to freeze or the wrong section borders to be used
//Using 16 or 32 instead of 64 would also occassionally cause these problems, probably because of the +6/-6

if x > sectionRight-6 && place_meeting(x-global.xspeed+6, y, objSectionArrowRight) //Right
&& !collision_rectangle(sectionRight+1, bbox_top, sectionRight+2, bbox_bottom, objSolid, false, false)
{
    instance_activate_object(objSectionBorderLeft);
    instance_activate_object(objSectionBorderRight);
    instance_activate_object(objSectionBorderTop);
    instance_activate_object(objSectionBorderBottom);
    instance_activate_object(objSectionArrowLeft);
    instance_activate_object(objSectionArrowRight);
    instance_activate_object(objSectionArrowUp);
    instance_activate_object(objSectionArrowDown);
    newSectionXOffset = 64;
    
    if bbox_top <= view_yview[0]
        newSectionYOffset = 96;
    else if bbox_bottom >= view_yview[0]+view_hview[0]
        newSectionYOffset = -96;
    else
        newSectionYOffset = 0;
        
    alarm[1] = 1; //In GM Studio, the code in alarm 1 needs to be executed one frame later, else an error message will pop up
}
else if x < sectionLeft+6 && place_meeting(x-global.xspeed-6, y, objSectionArrowLeft) //Left
&& !collision_rectangle(sectionLeft-1, bbox_top, sectionLeft-2, bbox_bottom, objSolid, false, false)
{
    instance_activate_object(objSectionBorderLeft);
    instance_activate_object(objSectionBorderRight);
    instance_activate_object(objSectionBorderTop);
    instance_activate_object(objSectionBorderBottom);
    instance_activate_object(objSectionArrowLeft);
    instance_activate_object(objSectionArrowRight);
    instance_activate_object(objSectionArrowUp);
    instance_activate_object(objSectionArrowDown);
    newSectionXOffset = -64;
    
    if bbox_top <= view_yview[0]
        newSectionYOffset = 96;
    else if bbox_bottom >= view_yview[0]+view_hview[0]
        newSectionYOffset = -96;
    else
        newSectionYOffset = 0;
    
    alarm[1] = 1; //In GM Studio, the code in alarm 1 needs to be executed one frame later, else an error message will pop up
}
else if sprite_get_ycenter() > sectionBottom-6 && place_meeting(x, sprite_get_ycenter()-global.yspeed+6, objSectionArrowDown) //Down
&& !collision_rectangle(bbox_left+4, sectionBottom+1, bbox_right-4, sectionBottom+2, objSolid, false, false)
{
    instance_activate_object(objSectionBorderLeft);
    instance_activate_object(objSectionBorderRight);
    instance_activate_object(objSectionBorderTop);
    instance_activate_object(objSectionBorderBottom);
    instance_activate_object(objSectionArrowLeft);
    instance_activate_object(objSectionArrowRight);
    instance_activate_object(objSectionArrowUp);
    instance_activate_object(objSectionArrowDown);
    newSectionXOffset = 0;
    newSectionYOffset = 64;
    
    alarm[1] = 1; //In GM Studio, the code in alarm 1 needs to be executed one frame later, else an error message will pop up
}
else if sprite_get_ycenter() < sectionTop+6 && place_meeting(x, sprite_get_ycenter()-global.yspeed-6, objSectionArrowUp) //Up
&& (climbing == true || ground == true) && !collision_rectangle(bbox_left+4, sectionTop-1, bbox_right-4, sectionTop-2, objSolid, false, false)
{
    instance_activate_object(objSectionBorderLeft);
    instance_activate_object(objSectionBorderRight);
    instance_activate_object(objSectionBorderTop);
    instance_activate_object(objSectionBorderBottom);
    instance_activate_object(objSectionArrowLeft);
    instance_activate_object(objSectionArrowRight);
    instance_activate_object(objSectionArrowUp);
    instance_activate_object(objSectionArrowDown);
    newSectionXOffset = 0;
    newSectionYOffset = -64;
        
    alarm[1] = 1; //In GM Studio, the code in alarm 1 needs to be executed one frame later, else an error message will pop up
}

#define playerSwitchWeapons
///playerSwitchWeapons()
//Allows for quick weapon switching
//If you do not want quick weapon switching in your game, simply remove the script from objMegaman's step event

if global.totalWeapons < 2 or room == rmWeaponGet {
    return false;
}

//Switching to the left
if global.keyWeaponSwitchLeftPressed {
    global.weapons[global.currentWeapon].initChargeTimer = 0;
    global.weapons[global.currentWeapon].chargeTimer = 0;
    do {
        global.currentWeapon--;
        if global.currentWeapon < 0
            global.currentWeapon = global.totalWeapons - 1;            
    } until global.weapons[global.currentWeapon].unlocked;
    
    global.weapons[global.currentWeapon].initChargeTimer = 0;
    global.weapons[global.currentWeapon].chargeTimer = 0;
    with global.weapons[global.currentWeapon] event_user(0);

    drawWeaponIcon = true;
    drawWeaponIconTimer = 30;
    
    global.weapon = global.currentWeapon;
    event_user(0); //Colors
    
    with prtPlayerProjectile if destroyOnSwitch instance_destroy();
    with objReflectedProjectile instance_destroy();
    with prtRush instance_destroy();
    with objRushJet instance_destroy();
    shootTimer = 20;
        
    playSFX(sfxWeaponSwitch);
    
    sound_stop(sfxCharging);
    sound_stop(sfxCharged);
}

//Switching to the right
if global.keyWeaponSwitchRightPressed {
    global.weapons[global.currentWeapon].initChargeTimer = 0;
    global.weapons[global.currentWeapon].chargeTimer = 0;
    do {
        global.currentWeapon++;
        if global.currentWeapon > global.totalWeapons - 1
            global.currentWeapon = 0;
    } until global.weapons[global.currentWeapon].unlocked;
    
    global.weapons[global.currentWeapon].initChargeTimer = 0;
    global.weapons[global.currentWeapon].chargeTimer = 0;
    with global.weapons[global.currentWeapon] event_user(0);
    
    drawWeaponIcon = true;
    drawWeaponIconTimer = 30;
    
    global.weapon = global.currentWeapon;
    event_user(0); //Colors
    
    with prtPlayerProjectile if destroyOnSwitch instance_destroy();
    with objReflectedProjectile instance_destroy();
    with prtRush instance_destroy();
    with objRushJet instance_destroy();
    shootTimer = 20;
            
    playSFX(sfxWeaponSwitch);
    
    sound_stop(sfxCharging);
    sound_stop(sfxCharged);
}

//Holding the left and right weapon switch keys at the same time results in the Mega Buster being selected
if global.keyWeaponSwitchLeft && global.keyWeaponSwitchRight && global.weapon != objMegaBusterWeapon.ID {
    global.weapons[global.currentWeapon].initChargeTimer = 0;
    global.weapons[global.currentWeapon].chargeTimer = 0;

        global.currentWeapon = 0;
    
    global.weapons[global.currentWeapon].initChargeTimer = 0;
    global.weapons[global.currentWeapon].chargeTimer = 0;
    with global.weapons[global.currentWeapon] event_user(0);
    
    drawWeaponIcon = true;
    drawWeaponIconTimer = 30;
    
    global.weapon = global.currentWeapon;
    event_user(0); //Colors
    
    with prtPlayerProjectile if destroyOnSwitch instance_destroy();
    with objReflectedProjectile instance_destroy();
    with prtRush instance_destroy();
    with objRushJet instance_destroy();
    shootTimer = 20;
        
    playSFX(sfxWeaponSwitch);
    
    sound_stop(sfxCharging);
    sound_stop(sfxCharged);
}

//Timer
if drawWeaponIconTimer != -1 {
    drawWeaponIconTimer--;
    if drawWeaponIconTimer == 0 {
        drawWeaponIcon = false;
    }
}

#define playerGetHit
///playerGetHit(health)
//Call it like this: with prtPlayer playerGetHit();
//Makes the player get hit
assert(argument0 >= 0, "playerGetHit: Damage must be non-negative");

if canHit {
    drawDamageNumber(prtPlayer.x, prtPlayer.y, ceil(argument0 * damageMultiplier * global.damageMultiplier));
    global._health -= ceil(argument0 * damageMultiplier * global.damageMultiplier);
    
    canHit = false;
    isHit = true;
    hitTimer = 0;
    isStep = false;
    climbing = false;
    canGravity = true;
    isShoot = false;
    isThrow = false;
    onRushJet = false;
    
    if cfgLoseChargeOnHit {
        weapons[global.currentWeapon].chargeTimer = 0;
        weapons[global.currentWeapon].initChargeTimer = 0;
        with prtPlayer event_user(0); //Reset the colors
    }
    
    //When sliding and there's a solid above us, we should not experience knockback
    //If we did, we would clip inside the ceiling above us
    if !(isSlide && (place_meeting(x, y-3, objSolid) || place_meeting(x, y-3, prtMovingPlatformSolid))) {
        canMove = false;
        canSpriteChange = false;
        isSlide = false;
        mask_index = mskMegaman;
        global.xspeed = image_xscale * -knockbackAmount;
        global.yspeed = 0;
        
        if global._health > 0 {
            sprite_index = spriteHit;
            
            //Create sweat effects
            instance_create(sprite_get_xcenter()-11, sprite_get_ycenter()-17, objMegamanSweat);
            instance_create(sprite_get_xcenter(), sprite_get_ycenter()-17, objMegamanSweat);
            instance_create(sprite_get_xcenter()+11, sprite_get_ycenter()-17, objMegamanSweat);
        }
    }
    
    if global._health > 0 {
        playSFX(sfxHit);
    }
}

#define playerDeactivateObjects
///playerDeactivateObjects()
//Deactivates umimportant objects outside the current section

deactivateUnimportantObjects(); //Can be found under Views

//The -16/+16 is to also activate solids on the left/top; when switching sections, we want to check these, and disallow switching if they are there to avoid getting stuck
instance_activate_region(sectionLeft-16, sectionTop-16, abs(sectionRight - sectionLeft)+16, abs(sectionBottom - sectionTop)+16, true);

#define playerLockMovement
///playerLockMovement()
//Locks the player's movement

with prtPlayer {
    isStep = false;
    climbing = false;
    canGravity = true;
    isShoot = false;
    isThrow = false;
    canMove = false;
    canSpriteChange = true;
    isSlide = false;
    canPause = false;
    onRushJet = false;
    mask_index = mskMegaman;
    global.xspeed = 0;
    global.yspeed = 0;
}

#define playerFreeMovement
///playerFreeMovement()
//Frees the player's movement (e.g. after being locked)

with prtPlayer {
    canMove = true;
    canSpriteChange = true;
    canPause = true;
    mask_index = mskMegaman;
}

#define drawSelf3Colors
/// drawSelf3Colors(col1, col2, col3)
/// Draw sprite replacing MM colors (blue, cyan and black) by others
var col1 = argument0;
var col2 = argument1;
var col3 = argument2;

shader_set(shColorReplace3);

var shader_params;

//Primary Color
shader_params = shader_get_uniform(shColorReplace3, "colorIn1");
shader_set_uniform_f(shader_params, colour_get_red(global.charPrimaryColor) / 255.0, colour_get_green(global.charPrimaryColor) / 255.0, colour_get_blue(global.charPrimaryColor) / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut1");
shader_set_uniform_f(shader_params, color_get_red(col1) / 255.0, color_get_green(col1) / 255.0, color_get_blue(col1) / 255.0, 1.0);

//Secondary Color
shader_params = shader_get_uniform(shColorReplace3, "colorIn2");
shader_set_uniform_f(shader_params, colour_get_red(global.charSecondaryColor) / 255.0, colour_get_green(global.charSecondaryColor) / 255.0, colour_get_blue(global.charSecondaryColor) / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut2");
shader_set_uniform_f(shader_params, color_get_red(col2) / 255.0, color_get_green(col2) / 255.0, color_get_blue(col2) / 255.0, 1.0);

//Outline
shader_params = shader_get_uniform(shColorReplace3, "colorIn3");
shader_set_uniform_f(shader_params, 1.0 / 255.0, 1.0 / 255.0, 1.0 / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut3");
shader_set_uniform_f(shader_params, color_get_red(col3) / 255.0, color_get_green(col3) / 255.0, color_get_blue(col3) / 255.0, 1.0);

drawSelf();

shader_reset();

#define drawSelf3ColorsFixed
/// drawSelf3Colors(col1, col2, col3)
/// Draw sprite replacing MM colors (blue, cyan and black) by others
var col1 = argument0;
var col2 = argument1;
var col3 = argument2;

shader_set(shColorReplace3);

var shader_params;

//Primary Color //make_colour_rgb(0, 112, 236)
shader_params = shader_get_uniform(shColorReplace3, "colorIn1");
shader_set_uniform_f(shader_params, 0.0 / 255.0, 112.0 / 255.0, 236.0 / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut1");
shader_set_uniform_f(shader_params, color_get_red(col1) / 255.0, color_get_green(col1) / 255.0, color_get_blue(col1) / 255.0, 1.0);

//Secondary Color   //make_colour_rgb(0, 232, 216);
shader_params = shader_get_uniform(shColorReplace3, "colorIn2");
shader_set_uniform_f(shader_params, 0.0 / 255.0, 232.0 / 255.0, 216.0 / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut2");
shader_set_uniform_f(shader_params, color_get_red(col2) / 255.0, color_get_green(col2) / 255.0, color_get_blue(col2) / 255.0, 1.0);

//Outline
shader_params = shader_get_uniform(shColorReplace3, "colorIn3");
shader_set_uniform_f(shader_params, 1.0 / 255.0, 1.0 / 255.0, 1.0 / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut3");
shader_set_uniform_f(shader_params, color_get_red(col3) / 255.0, color_get_green(col3) / 255.0, color_get_blue(col3) / 255.0, 1.0);

drawSelf();

shader_reset();

#define projectileCount
///projectileCount(): returns the number of player active projectiles on screen

var count = instance_number(objReflectedProjectile);

with prtPlayerProjectile {
    if !doesNotCount count++;
}

return count;

#define setPlayer
///setPlayer(player): set the current player character

var player = argument0;
if !object_exists(player) {
    return false;
}
global.character = player;

var char = instance_create(0, 0, player);

global.name = char.name;
global.sprName = char.sprName;
global.defaultWeapon = char.defaultWeapon;
global.spriteLife = char.spriteLife;
global.spriteStageSelect = char.spriteStageSelect;
global.stageSelectFollow = char.stageSelectFollow;
global.charPrimaryColor = char.primary_color;
global.charSecondaryColor = char.secondary_color;
global.spriteStand = asset_get_index("spr" + char.sprName + "Stand");
global.spriteJump = asset_get_index("spr" + char.sprName + "Jump");
global.blinkTimerMax = char.blinkTimerMax;
global.blinkDuration = char.blinkDuration;
global.src_col1 = char.src_col1;
global.src_col2 = char.src_col2;
global.src_col3 = char.src_col3;


with char instance_destroy();

#define drawSelf
///drawSelf()
if sprite_index > -1 and visible
    draw_sprite_ext(sprite_index, image_index, round(x), round(y), image_xscale, image_yscale, image_angle, image_blend, image_alpha);

#define sprite_get_xcenter
///sprite_get_xcenter()

return round(x - sprite_xoffset + (sprite_width/2));

#define sprite_get_ycenter
///sprite_get_ycenter()

return round(y - sprite_yoffset + (sprite_height/2));

#define sprite_get_xcenter_object
///sprite_get_xcenter_object(id)

var v;
v = argument0;
return round(v.x - v.sprite_xoffset + (v.sprite_width/2));

#define sprite_get_ycenter_object
///sprite_get_ycenter_object(id)

var v;
v = argument0;
return round(v.y - v.sprite_yoffset + (v.sprite_height/2));

#define sprite_get_left
///sprite_get_left()

return round(x - sprite_xoffset);

#define sprite_get_right
///sprite_get_right()

return round(x - sprite_xoffset + (sprite_width));

#define sprite_get_top
///sprite_get_top()

return round(y - sprite_yoffset);

#define sprite_get_bottom
///sprite_get_bottom()

return round(y - sprite_yoffset + (sprite_height));

#define mask_get_xcenter
///mask_get_xcenter()

return round(x - sprite_get_xoffset(mask_index) + (sprite_get_width(mask_index)/2));

#define mask_get_ycenter
///mask_get_ycenter()

return round(y - sprite_get_yoffset(mask_index) + (sprite_get_height(mask_index)/2));

#define mask_get_xcenter_object
///mask_get_xcenter_object(obj)

var v;
v = argument0;
return round(v.x - sprite_get_xoffset(v.mask_index) + (sprite_get_width(v.mask_index)/2));

#define mask_get_ycenter_object
///mask_get_ycenter_object(obj)

var v;
v = argument0;
return round(v.y - sprite_get_yoffset(v.mask_index) + (sprite_get_height(v.mask_index)/2));

#define drawSpriteTiled
///drawSpriteTiled(tile width, tile height, top sprite tile, middle sprite tile, bottom sprite tile)
//THIS SCRIPT ALLOWS AN OBJECT, WHEN SCALED VIA IMAGE_XSCALE/IMAGE_YSCALE
//TO TILE ITSELF, RATHER THAN JUST STRETCHING OUT.
//USE IN THE DRAW EVENT

//argument0 = tile spacing X
//argument1 = tile spacing Y
//argument2 = top layer sprite tiles
//argument3 = mid layer sprite tiles
//argument4 = bottom layer sprite tiles
//DRAW THE START SPOT TILE
draw_sprite_ext(argument2,-1,x,y,1,1,0,image_blend,image_alpha)

var i, j;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//DRAW THE X ROW TILES (AND ALL Y TILES BUT THE FIRST ROW)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
if image_xscale > 1
    for (i = 1; i < image_xscale; i += 1)
    {
        //Make sure only on screen tiles are drawn.
        
        //
        {
            draw_sprite_ext(argument2,-1,x+(argument0*i),y,1,1,0,image_blend,image_alpha)
            // DRAW ALL Y ROW TILES EXCEPT THE FIRST
            ////////////////////////////////////////
            if image_yscale > 1
                for (j = 1; j < image_yscale; j += 1)
                {
                    //Make sure only on screen tiles are drawn.
                    if y+(argument1*j) > view_yview[0] - argument1 and y+(argument1*j) < view_yview + 240 + argument1
                    //
                    {
                        if j = image_yscale - 1
                            draw_sprite_ext(argument4,-1,x+(argument0*i),y+(argument1*j),1,1,0,image_blend,image_alpha)
                        else
                            draw_sprite_ext(argument3,-1,x+(argument0*i),y+(argument1*j),1,1,0,image_blend,image_alpha)
                    }
                }
        ////////////////////////////////////////
        }
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DRAW THE 1ST ROW Y TILES
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
if image_yscale > 1
    for (i = 1; i < image_yscale; i += 1)
    {
        //Make sure only on screen tiles are drawn.
        //
        {
            if i = image_yscale - 1
                draw_sprite_ext(argument4,-1,x,y+(argument1*i),1,1,0,image_blend,image_alpha)
            else
                draw_sprite_ext(argument3,-1,x,y+(argument1*i),1,1,0,image_blend,image_alpha)
        }
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define drawSpriteColorSwap
/// drawSpriteColorSwap(spr, subimg, sx, sy, src_col1, src_col2, src_col3, col1, col2, col3)
/// Draw sprite replacing colors

var spr = argument0;
var subimg = argument1;
var sx = argument2;
var sy = argument3;

var src_col1 = argument4;
var src_col2 = argument5;
var src_col3 = argument6;

var col1 = argument7;
var col2 = argument8;
var col3 = argument9;

shader_set(shColorReplace3);

var shader_params;

//Primary Color
shader_params = shader_get_uniform(shColorReplace3, "colorIn1");
shader_set_uniform_f(shader_params, color_get_red(src_col1) / 255.0, color_get_green(src_col1) / 255.0, color_get_blue(src_col1) / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut1");
shader_set_uniform_f(shader_params, color_get_red(col1) / 255.0, color_get_green(col1) / 255.0, color_get_blue(col1) / 255.0, 1.0);

//Secondary Color
shader_params = shader_get_uniform(shColorReplace3, "colorIn2");
shader_set_uniform_f(shader_params, color_get_red(src_col2) / 255.0, color_get_green(src_col2) / 255.0, color_get_blue(src_col2) / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut2");
shader_set_uniform_f(shader_params, color_get_red(col2) / 255.0, color_get_green(col2) / 255.0, color_get_blue(col2) / 255.0, 1.0);

//Third Color
shader_params = shader_get_uniform(shColorReplace3, "colorIn3");
shader_set_uniform_f(shader_params, color_get_red(src_col3) / 255.0, color_get_green(src_col3) / 255.0, color_get_blue(src_col3) / 255.0, 1.0);
shader_params = shader_get_uniform(shColorReplace3, "colorOut3");
shader_set_uniform_f(shader_params, color_get_red(col3) / 255.0, color_get_green(col3) / 255.0, color_get_blue(col3) / 255.0, 1.0);

draw_sprite(spr, subimg, sx, sy);

shader_reset();

#define checkGround
///checkGround()
//Checks whether or not the object is on the ground

if place_meeting(x, y+1, objSolid) || (place_meeting(x, y+1, objTopSolid))
|| place_meeting(x, y+1, prtMovingPlatformSolid) || (place_meeting(x, y+1, prtMovingPlatformJumpthrough)) {
    if place_meeting(x, y+1, objSolid)
        ground = true;
    else if place_meeting(x, y+1, objTopSolid) {
        if bbox_bottom < instance_place(x, y+1, objTopSolid).bbox_top
            ground = true;
        else
            ground = false;
    }
    else if place_meeting(x, y+1, prtMovingPlatformSolid) {
        var sld = instance_place(x, y+1, prtMovingPlatformSolid);
        if sld > -1 and sld.object_index != objRushJet and !sld.dead
            ground = true;
        else
            ground = false;
    }
    else {
        var sld = instance_place(x, y+1, prtMovingPlatformJumpthrough);
        if sld > -1 and sld.object_index != objRushJet and !sld.dead {
            if bbox_bottom < sld.bbox_top
                ground = true;
            else
                ground = false;
        }
        else
            ground = false;
    }
}
else
    ground = false;

#define generalCollision
///generalCollision()
//Handles a general object's collision code. The object cannot have a specified mask. If it does, use generalCollisionMask()

var colliding = !place_free(x, y);

//Wall
mySolid = instance_place(x+xspeed, y, objSolid);
if mySolid >= 0 && xspeed != 0 && !colliding {    
    if xspeed < 0
        x = mySolid.x + mySolid.sprite_width + (x - (bbox_left-1));
    else
        x = mySolid.x - (bbox_right+1 - x) - 1;
        
    xspeed = 0;
}

//Floor
var mySolid = instance_place(x, y+yspeed, objSolid);
if mySolid >= 0 and yspeed > 0 and !colliding {
    y = mySolid.bbox_top;
    while place_meeting(x, y, mySolid)
        y -= 1;
    
    //y = mySolid.y - (sprite_height - sprite_yoffset);
    ground = true;
    yspeed = 0;
}


//Ceiling
mySolid = instance_place(x, y+yspeed, objSolid);
if mySolid >= 0 && yspeed < 0 && !colliding {
    y = mySolid.y + mySolid.sprite_height + sprite_yoffset + (y - (bbox_top-1));
    yspeed = 0;
}


//Topsolids
mySolid = instance_place(x, y+yspeed, objTopSolid);
if mySolid >= 0 && yspeed > 0 {
    if !place_meeting(x, y, objTopSolid) {
        y = mySolid.y - (bbox_bottom+1 - y);
        ground = true;
        yspeed = 0;
    }
}


//Floor (moving platform)
var mySolid;
mySolid = instance_place(x, y+yspeed, prtMovingPlatformSolid);
if mySolid >= 0 && yspeed > 0 {
    if mySolid.object_index != objRushJet && mySolid.dead == false
    {
        y = mySolid.bbox_top;
        while place_meeting(x, y, mySolid)
            y -= 1;
        ground = true;
        yspeed = 0;
    }
}


//Wall (moving platform)
mySolid = instance_place(x+xspeed, y, prtMovingPlatformSolid);
if mySolid >= 0 && xspeed != 0
{    
    if mySolid.object_index != objRushJet && mySolid.dead == false
    {
        if xspeed < 0
            x = mySolid.bbox_right + (x - (bbox_left-1));
        else
            x = mySolid.bbox_left - (bbox_right+1 - x) - 1;
            
        xspeed = 0;
    }
}


//Ceiling (moving platform)
mySolid = instance_place(x, y+yspeed, prtMovingPlatformSolid);
if mySolid >= 0 && yspeed < 0
{
    if mySolid.object_index != objRushJet && mySolid.dead == false
    {
        y = mySolid.bbox_bottom + sprite_get_yoffset(sprite_index);
        yspeed = 0;
    }
}


//Topsolids (moving platform)
mySolid = instance_place(x, y+yspeed, prtMovingPlatformJumpthrough);
if mySolid >= 0 && yspeed > 0
{
    if mySolid.object_index != objRushJet && mySolid.dead == false
    {
        if !place_meeting(x, y, mySolid)
        {
            y = mySolid.bbox_top - (bbox_bottom+1 - y);
            ground = true;
            yspeed = 0;
        }
    }
}

//escapeWall();

#define gravityCheckGround
///gravityCheckGround()
//Applies gravity only if we are not on the ground
//Make sure to specify the variable 'ground' in the object [if necessary, use checkGround()]

if !ground {
    yspeed += cfgGravity * update_rate;
    if yspeed > cfgMaxFallingSpeed
        yspeed = cfgMaxFallingSpeed;
}

#define gravityCheckGroundExt
///gravityCheckGroundExt(grav)
//Applies gravity only if we are not on the ground
//Make sure to specify the variable 'ground' in the object [if necessary, use checkGround()]

if !ground {
    yspeed += argument0 * update_rate;
    if yspeed > cfgMaxFallingSpeed
        yspeed = cfgMaxFallingSpeed;
}

#define gravityNoGround
///gravityNoGround()
//Applies gravity no matter what

yspeed += cfgGravity * update_rate;
if yspeed > cfgMaxFallingSpeed
    yspeed = cfgMaxFallingSpeed;

#define gravityNoGroundExt
///gravityNoGroundExt(grav)
//Applies gravity no matter what

yspeed += argument0 * update_rate;
if yspeed > cfgMaxFallingSpeed
    yspeed = cfgMaxFallingSpeed;

#define escapeWall
/// escapeWall(): avoids getting stuck into walls

amount = 1;
while !place_free(x, y) {
    if place_free(x-amount, y) {
        show_debug_message(object_get_name(object_index) + " Stuck: Move "+string(amount)+" pixel to the left");
        x -= amount;
    }
    else if place_free(x+amount, y) {
        show_debug_message(object_get_name(object_index) + " Stuck: Move "+string(amount)+" pixel to the right");
        x += amount;
    }
    else if place_free(x, y-amount) {
        show_debug_message(object_get_name(object_index) + " Stuck: Move "+string(amount)+" pixel up");
        y -= amount;
    }
    else if place_free(x, y+amount) {
        show_debug_message(object_get_name(object_index) + " Stuck: Move "+string(amount)+" pixel down");
        y += amount;
    }
    else {
        amount++;
    }
}


if (cfgDebug || debug_mode) && position_meeting(x, y+5, objSolid) {
    //show_error("Stuck!", false);
    show_debug_message("Stuck!");
}

if (cfgDebug || debug_mode) && place_meeting(x, y, objSolid) {
    //show_error("Stuck!", false);
    show_debug_message("Stuck!?");
}

#define mergeBlocksHorizontal
/// mergeBlocksHorizontal(type)
var type = argument0;
var next;

with type {
    if instance_exists(self) {
        next = instance_position(x + sprite_width, y, type);
        while(next > - 1 && image_yscale == next.image_yscale && object_index == next.object_index && object_get_parent(next.object_index) != prtDestructibleBlock) {
            image_xscale += next.image_xscale;
            with next instance_destroy();
            next = instance_position(x + sprite_width, y, type);
        }
    }
}

#define mergeBlocksVertical
/// mergeBlocksVertical(type)
var type = argument0;
var next;

with type {
    if instance_exists(self) {
        next = instance_position(x, y + sprite_height, type);
        while(next > - 1 && image_xscale == next.image_xscale && object_index == next.object_index && object_get_parent(next.object_index) != prtDestructibleBlock) {
            image_yscale += next.image_yscale;
            with next instance_destroy();
            next = instance_position(x, y + sprite_height, type);
        }
    }
}

#define mergeBlocks
/// mergeBlocks()
mergeBlocksHorizontal(objSolid);
mergeBlocksHorizontal(objTopSolid);
mergeBlocksHorizontal(objIce);
mergeBlocksHorizontal(objSpike);
mergeBlocksHorizontal(objWater);
mergeBlocksHorizontal(objSectionArrowUp);
mergeBlocksHorizontal(objSectionArrowDown);

mergeBlocksVertical(objSolid);
mergeBlocksVertical(objTopSolid);
mergeBlocksVertical(objIce);
mergeBlocksVertical(objSpike);
mergeBlocksVertical(objWater);
mergeBlocksVertical(objLadder);
mergeBlocksVertical(objSectionArrowLeft);
mergeBlocksVertical(objSectionArrowRight);

#define move
/// move(xs, ys)

var xs = argument0;
var ys = argument1;

if place_free(x + xs, y) {
    x += xs * update_rate;
}

if place_free(x, y + ys) {
    y += ys * update_rate;
}

#define insideView
///insideView()
//Returns true if the object is inside the view, and false if not
//This script only works for view 0

if sprite_get_xcenter() >= view_xview[0] && sprite_get_xcenter() < view_xview[0]+view_wview[0]
&& sprite_get_ycenter() >= view_yview[0] && sprite_get_ycenter() < view_yview[0]+view_hview[0]
    return true;
else
    return false;

#define insideViewObj
/// insideViewObj(obj)
//Returns true if the object is inside the view, and false if not
//This script only works for view 0

var obj = argument0;

if sprite_get_xcenter_object(obj) >= view_xview[0] && sprite_get_xcenter_object(obj) < view_xview[0]+view_wview[0]
&& sprite_get_ycenter_object(obj) >= view_yview[0] && sprite_get_ycenter_object(obj) < view_yview[0]+view_hview[0]
    return true;
else
    return false;

#define insideViewAny
/// insideViewAny(obj)
//Returns an object if any object of this type is inside the view, and -1 otherwise
//This script only works for view 0

var obj = argument0;

with obj {
    if sprite_get_xcenter() >= view_xview[0] && sprite_get_xcenter() < view_xview[0]+view_wview[0]
    && sprite_get_ycenter() >= view_yview[0] && sprite_get_ycenter() < view_yview[0]+view_hview[0]
        return self;
}
return -1;

#define deactivateUnimportantObjects
///deactivateUnimportantObjects()
//Deactivates umimportant objects. Even deactivates objects inside the section

instance_deactivate_all(true);

//Add more important objects as they are added
instance_activate_object(prtPlayer);
instance_activate_object(objGlobalControl);
instance_activate_object(objHealthWeaponBar);

instance_activate_object(objBossDoor);
instance_activate_object(objBossDoorH);


//Objects that should remain activated, but without animation (disabled animation code is in the object itself)
instance_activate_object(objMM2Conveyor);


//Objects that destroy themselves off screen
//Though, when switching sections they should not be visible
if !instance_exists(objSectionSwitcher)
{
    instance_activate_object(prtPlayerProjectile);
    instance_activate_object(prtEnemyProjectile);
    instance_activate_object(objReflectedProjectile);
    instance_activate_object(prtEffect);
    instance_activate_object(prtRush);
    instance_activate_object(objRushJet); //Could not be parented to prtRush since it's parented to prtMovingPlatformSolid
    instance_activate_object(prtPickup);
    
    //Objects that have different code off-screen
    instance_activate_object(prtEnemy);
    instance_activate_object(prtGimmick);
    instance_activate_object(objBossControl);
}

instance_activate_object(prtMovingPlatformSolid);   //Moving platforms with keepOnSwitch should be kept visibile and moving
var count = instance_number(prtMovingPlatformSolid);
for (var i = 0; i < count; i++) {
    var obj = instance_find(prtMovingPlatformSolid, i);
    if obj != noone && instance_exists(obj) && !obj.keepOnSwitch {
        instance_deactivate_object(obj);
    }
}
instance_activate_object(prtEquip);
instance_activate_object(prtWeapon);
instance_activate_object(prtAchievement);

#define playSFX
///playSFX(index)
//Plays a sound effect

if audio_system() == audio_old_system {
    sound_stop(argument0);
    sound_play(argument0);
}
else {
    audio_stop_sound(argument0);
    audio_play_sound(argument0, 1, false);
}

#define playMusic
///playMusic(filename)
//Plays music
//Example: playMusic("CutMan.ogg")

stopAllSFX();
if is_string(argument0) {   //For retro compatibility
    var parts = split(argument0, ".");
    var name = ds_queue_dequeue(parts);
    var sound = asset_get_index("bgm" + name);
    if !audio_is_playing(sound) {
        audio_play_sound(sound, 1, true);
    }
}
else if !audio_is_playing(argument0) {
    audio_play_sound(argument0, 1, true);
}

#define playMusicVolume
///playMusicVolume(filename, volume)
//Plays music with a set volume. Volume should be between 0 and 1.
//Example: playMusicVolume("CutMan.ogg", 0.6)

stopAllSFX();
var snd = noone;
if is_string(argument0) {   //For retro compatibility
    var parts = split(argument0, ".");
    var name = ds_queue_dequeue(parts);
    var sound = asset_get_index("bgm" + name);
    if !audio_is_playing(sound) {
        snd = audio_play_sound(sound, 1, true);
    }
}
else if !audio_is_playing(argument0) {
    snd = audio_play_sound(argument0, 1, true);
}
if snd != noone {
    audio_sound_gain(snd, argument1, 0);
}

#define playMusicLoopPoint
///playMusic(filename, loop start, loop end)
//Plays music and loops from one point to another point
//loop start and loop end should be between 0 and 1 (0 being 0:00 and 1 being the end of the music)
//Example: playMusic("CutMan.ogg", 0.4, 0.8)

stopAllSFX();
var snd = noone;
if is_string(argument0) {   //For retro compatibility
    var parts = split(argument0, ".");
    var name = ds_queue_dequeue(parts);
    var sound = asset_get_index("bgm" + name);
    if !audio_is_playing(sound) {
        snd = audio_play_sound(sound, 1, true);
    }
}
else if !audio_is_playing(argument0) {
    snd = audio_play_sound(argument0, 1, true);
}
if snd != noone {
    var len = audio_sound_length(snd);
    global.loopStart = argument1 * len;
    global.loopEnd = argument2 * len;
    global.bgm = snd;
}

#define playMusicVolumeLoopPoint
///playMusic(filename, volume, loop start, loop end)
//Plays music and loops from one point to another point
//loop start and loop end should be between 0 and 1 (0 being 0:00 and 1 being the end of the music)
//Also plays the music at a set volume (volume should be between 0 and 1)
//Example: playMusic("CutMan.ogg", 0.6, 0.4, 0.8)

stopAllSFX();
var snd = noone;
if is_string(argument0) {   //For retro compatibility
    var parts = split(argument0, ".");
    var name = ds_queue_dequeue(parts);
    var sound = asset_get_index("bgm" + name);
    if !audio_is_playing(sound) {
        snd = audio_play_sound(sound, 1, true);
    }
}
else if !audio_is_playing(argument0) {
    snd = audio_play_sound(argument0, 1, true);
}
if snd != noone {
    audio_sound_gain(snd, argument1, 0);
    var len = audio_sound_length(snd);
    global.loopStart = argument2 * len;
    global.loopEnd = argument3 * len;
    global.bgm = snd;
}

#define playMusicNoLoop
///playMusicNoLoop(filename)
//Plays music without looping it
//Example: playMusicNoLoop("CutMan.ogg")

stopAllSFX();
var snd = noone;
if is_string(argument0) {   //For retro compatibility
    var parts = split(argument0, ".");
    var name = ds_queue_dequeue(parts);
    var sound = asset_get_index("bgm" + name);
    if !audio_is_playing(sound) {
        snd = audio_play_sound(sound, 1, false);
    }
}
else if !audio_is_playing(argument0) {
    audio_play_sound(argument0, 1, false);
}

#define playMusicNoLoopVolume
///playMusicNoLoopVolume(filename, volume)
//Plays music with a set volume. Volume should be between 0 and 1.
//Example: playMusicNoLoopVolume("CutMan.ogg", 0.6)

stopAllSFX();
var snd = noone;
if is_string(argument0) {
    var parts = split(argument0, ".");
    var name = ds_queue_dequeue(parts);
    var sound = asset_get_index("bgm" + name);
    if !audio_is_playing(sound) {
        snd = audio_play_sound(sound, 1, false);
    }
}
else if !audio_is_playing(argument0) {
    snd = audio_play_sound(argument0, 1, false);
}
if snd != noone {
    audio_sound_gain(snd, argument1, 0);
}

#define stopSFX
///stopSFX(index)
//Stops a sound effect

if audio_system() == audio_old_system {
    sound_stop(argument0);
}
else {
    audio_stop_sound(argument0);
}

#define loopSFX
///loopSFX(index)
//Loops a sound effect

if audio_system() == audio_old_system {
    sound_stop(argument0);
    sound_loop(argument0);
}
else {
    audio_stop_sound(argument0);
    audio_play_sound(argument0, 1, true);
}

#define stopAllSFX
///stopAllSFX()
//Stops all SFX

if audio_system() == audio_old_system {
    sound_stop_all();
}
else {
    audio_stop_all();
}
global.bgm = -1;
global.loopStart = -1;
global.loopEnd = -1;

#define split
/// ds_queue split(String s, [char delimiter]);
// Will only recognize double-quotation mark for block quotes, not single-quotation marks.
// You can pass a multiple-character string as the delimiter but it'll never get recognized
//      because string_char_at will never equal a multi-character delimiter.
 
var base=argument[0];                           // Base string
if (argument_count==1)
    var delimiter=",";
else
    var delimiter=argument[1];                  // Character to split around, default a comma
var inline=false;                               // inside a block quote?
var queue=ds_queue_create();                    // Contains the individual words
var tn="";                                      // temporary substring
 
base=base+delimiter;                            // lazy way of ensuring the last term in the list does not get skipped
 
for (var i=1; i<=string_length(base); i++){     // for each character in the string:
    var c=string_char_at(base, i);              //      Current character
    if (string_char_at(base, i-1)=="\"){        //      If the previous character is a backslash, bypass the other checks
        tn=string_copy(tn, 1, string_length(tn)-1);     // and remove the backslash
        tn=tn+c;
    } else if (c=='"'){                         //      If double quotation mark:
        if (inline){                            //          If already inside a block, end the block
            inline=false;
        } else {                                //          If not already inside a block, start a block
            inline=true;
        }
    } else if (c==delimiter&&!inline){          //      Delimiter met and not inside a block, enqueue and reset the substring
        ds_queue_enqueue(queue, tn);
        tn="";
    } else {                                    // Just an ordinary character, add it to the substring
        tn=tn+c;
    }
}
 
return queue;

#define string_lpad
/// string_lpad(str,length,padstr)
//
//  Returns a string padded to a certain length 
//  by inserting another string to its left.
//  eg. string_lpad("1234", 7, "0") == "0001234"
//
//      str         string of text, string
//      length      desired total length, real
//      padstr      padding, string
//
/// GMLscripts.com/license
{
    var str,len,pad,padsize,padding,out;
    str = argument0;
    len = argument1;
    pad = argument2;
    padsize = string_length(pad);
    padding = max(0,len - string_length(str));
    out  = string_repeat(pad,padding div padsize);
    out += string_copy(pad,1,padding mod padsize);
    out += str;
    out  = string_copy(out,1,len);
    return out;
}

#define string_rpad
/// string_rpad(str,length,padstr)
//
//  Returns a string padded to a certain length 
//  by inserting another string to its right.
//  eg. string_rpad("1234", 7, "0") == "0001234"
//
//      str         string of text, string
//      length      desired total length, real
//      padstr      padding, string
{
    var str,len,pad,padsize,padding,out;
    str = argument0;
    len = argument1;
    pad = argument2;
    padsize = string_length(pad);
    padding = max(0,len - string_length(str));
    out = str;
    out  += string_repeat(pad,padding div padsize);
    out += string_copy(pad,1,padding mod padsize);
    out  = string_copy(out,1,len);
    return out;
}

#define string_apad
/// string_apad(str,length,padstr)
//
//  Returns a string padded to a certain length 
//  by inserting another string around it.
//  eg. string_apad("1234", 7, "0") == "0001234"
//
//      str         string of text, string
//      length      desired total length, real
//      padstr      padding, string
{
    var str = argument0;
    var length = argument1;
    var padstr = argument2;
    var len = string_length(str);
    var padlen = max(0,length - len);
    return string_rpad(string_lpad(str, len + padlen div 2, padstr), length, padstr);
}

#define string_break
//string_break(str, n)
var str = argument0;
var n = argument1;

var words = split(str, " ");
var line = "";
var result = "";

while !ds_queue_empty(words) {
    var word = ds_queue_dequeue(words);
    if string_length(line + " " + word) >= n {
        result += line + "##";
        line = "";
    }
    if string_length(line) > 0 {
        line += " ";
    }
    line += word;
}
result += line;
return result;

#define string_replace_at
/// string_replace_at(str, index, substr)
var str = argument0;
var index = argument1;
var substr = argument2;
var len = string_length(string(substr));
var newstr = "";

newstr = string_delete(str, index, len);
newstr = string_insert(string(substr), newstr, index);

return newstr;

#define concat
/// concat(variables or strings)

var output_string = "";

for (var i = 0; i < argument_count; i++) {
    output_string += string(argument[i]) + " ";
}

return output_string;

#define key_to_string
/// key_to_string( key )
/*//
How to use:
Simply call this script in a draw_text function.
argument0 should be a keyboard key such as vk_enter or ord('Z').
//*/

if( argument0 > 48 && argument0 < 91 ) {
    return chr(argument0);
}
switch( argument0 ) {
    case -1: return "No Key";
    case 8: return "Backspace";
    case 9: return "Tab";
    case 13: return "Enter";
    case 16: return "Shift";
    case 17: return "Ctrl";
    case 18: return "Alt";
    case 19: return "Pause";
    case 20: return "CAPS";
    case 27: return "Esc";
    case 32: return "Space";
    case 33: return "PgUp";
    case 34: return "PgDn";
    case 35: return "End";
    case 36: return "Home";
    case 37: return "[";
    case 38: return "^";
    case 39: return "]";
    case 40: return "\";
    case 45: return "Insert";
    case 46: return "Delete";
    case 96: return "Numpad 0";
    case 97: return "Numpad 1";
    case 98: return "Numpad 2";
    case 99: return "Numpad 3";
    case 100: return "Numpad 4";
    case 101: return "Numpad 5";
    case 102: return "Numpad 6";
    case 103: return "Numpad 7";
    case 104: return "Numpad 8";
    case 105: return "Numpad 9";
    case 106: return "Numpad *";
    case 107: return "Numpad +";
    case 109: return "Numpad -";
    case 110: return "Numpad .";
    case 111: return "Numpad /";
    case 112: return "F1";
    case 113: return "F2";
    case 114: return "F3";
    case 115: return "F4";
    case 116: return "F5";
    case 117: return "F6";
    case 118: return "F7";
    case 119: return "F8";
    case 120: return "F9";
    case 121: return "F10";
    case 122: return "F11";
    case 123: return "F12";
    case 144: return "Num Lock";
    case 145: return "Scroll Lock";
    case 160: return "L SHIFT";
    case 161: return "R SHIFT";
    case 162: return "L CTRL";
    case 163: return "R CTRL";
    case 164: return "L ALT";
    case 165: return "R ALT";
    case 186: return ";";
    case 187: return "=";
    case 188: return ",";
    case 189: return "-";
    case 190: return ".";
    case 191: return "\";
    case 192: return "`";
    case 219: return "/";
    case 220: return "[";
    case 221: return "]";
    case 222: return "'";
}

#define button_to_string
/// button_to_string( button )
/*//
How to use:
Simply call this script in a draw_text function.
argument0 should be a button such as gp_face1.
//*/

switch( argument0 ) {
    case gp_face1: return "Button 1";
    case gp_face2: return "Button 2";
    case gp_face3: return "Button 3";
    case gp_face4: return "Button 4";
    case gp_shoulderl: return "L Trigger";
    case gp_shoulderlb: return "L Shoulder";
    case gp_shoulderr: return "R Trigger";
    case gp_shoulderrb: return "R Shoulder";
    case gp_select: return "Select";
    case gp_start: return "Start";
    case gp_stickl: return "L Stick";
    case gp_stickr: return "R Stick";
    case gp_padu: return "^";
    case gp_padd: return "\";
    case gp_padl: return "[";
    case gp_padr: return "]";
    default: return noone;
}

#define saveGame
//saveGame(id)
var map = ds_map_create();
map[? "character"] = global.character;
map[? "lives"] = global._lives;
map[? "screws"] = global.screws;
for(var i = 0; i < 8; i++) {
    map[? ("bossDefeated" + string(i))] = global.bossDefeated[i];
}
for (var i = 0; i < global.totalWeapons; i++) {
    map[? ("weaponUnlocked" + string(i))] = global.weapons[i].unlocked;
}
for (var i = 0; i < array_length_1d(global.items); i++) {
    map[? ("itemCount" + string(i))] = global.items[i].count;
}
ds_map_secure_save(map, "save" + string(argument0) + ".dat");
show_debug_message("Game saved.");

#define loadGame
//loadGame(id)
var map = ds_map_secure_load("save" + string(argument0) + ".dat");
setPlayer(map[? "character"]);
global._lives = map[? "lives"];
global.screws = map[? "screws"];
for(i = 0; i < 8; i++) {
     global.bossDefeated[i] = map[? ("bossDefeated" + string(i))];
}
for (var i = 0; i < global.totalWeapons; i++) {
    global.weapons[i].unlocked = map[? ("weaponUnlocked" + string(i))];
}
for (var i = 0; i < array_length_1d(global.items); i++) {
    global.items[i].count = map[? ("itemCount" + string(i))];
    for (var j = 0; j < global.items[i].count; j++) {
        with global.items[i] {
            event_user(1);
            event_user(4);
        }
    }
}
show_debug_message("Game loaded.");

#define make_password
//make_password()
var bin_pass = bin_base_password();

print(bin_pass);

var max_pass = 96;
var checksum = password_checksum(bin_pass);
bin_pass += checksum;
bin_pass = string_copy(bin_pass, 1, max_pass);

print(bin_pass);

assert(string_length(bin_pass) == max_pass, "Invalid Password");

var tern_pass = string_lpad(block_base_convert(bin_pass, 2, 3, 3, 2), 64, "0");

return tern_pass;

#define password_checksum
///password_checksum(bin_pass)
var bin_pass = argument0;

var max_pass = 96;
var pass_length = string_length(bin_pass);
var checksum_size = max_pass - pass_length;
var sum = string_count("1", bin_pass + dec_to_bin(abs(game_id),checksum_size));

print("pass length", pass_length, "checksum size", checksum_size, "sum", sum);

var checksum = dec_to_bin(abs(sum), checksum_size);

print("game id", game_id, "binary checksum", checksum);

return checksum;

#define bin_base_password
//bin_base_password()
bin_pass = "";
//If you don't want something to be stored in the password, just comment the line
print("char bits", ceil(log2(global.totalCharacters)), "char", global.charIndices[global.character]);
bin_pass += dec_to_bin(global.charIndices[global.character], ceil(log2(global.totalCharacters)));
bin_pass += dec_to_bin(global._lives, 4);
bin_pass += dec_to_bin(global.screws, 10);

for (var i = 1; i < global.totalWeapons; i++) { //Skip weapon 0 (mega buster)
    bin_pass += iif(global.weapons[i].unlocked, "1", "0");
}
for (var i = 1; i < array_length_1d(global.items); i++) {   //Skip item 0 (lives)
    bin_pass += dec_to_bin(global.items[i].count, ceil(log2(global.items[i].maxUnits + 1)));
}

return bin_pass;

#define apply_password
///apply_password(tern_pass)
var tern_pass = argument0;
var bin_pass = block_base_convert(tern_pass, 3, 2, 2, 3);
bin_pass = string_lpad(bin_pass, 96, "0");

var pos = 1;

var charlen = ceil(log2(global.totalCharacters));
setPlayer(global.characters[real(base_convert(string_copy(bin_pass, pos, charlen), 2, 10))]);
pos += charlen;
global._lives = real(base_convert(string_copy(bin_pass, pos, 4), 2, 10));
pos += 4;
global.screws = real(base_convert(string_copy(bin_pass, pos, 10), 2, 10));
pos += 10;

//Weapons
global.weapons[0].unlocked = true;
for (var i = 1; i < global.totalWeapons; i++) { //Skip weapon 0 (mega buster)
    global.weapons[i].unlocked = (string_copy(bin_pass, pos, 1) == "1");
    pos++;
}
//Defeated bosses are inferred from unlocked weapons
for (var i = 0; object_exists(i); i++) {
    if object_get_parent(i) == prtBoss {
        var boss = instance_create(0, 0, i);
        if boss.bossID > -1 and boss.weaponID > -1 {
            global.bossDefeated[boss.bossID] = boss.weaponID.unlocked;
        }
        with boss instance_destroy();
    }
}
//Items
for (var i = 1; i < array_length_1d(global.items); i++) {   //Skip item 0 (lives)
    var len = ceil(log2(global.items[i].maxUnits + 1));
    global.items[i].count = real(base_convert(string_copy(bin_pass, pos, len), 2, 10));
    for (var j = 0; j < global.items[i].count; j++) {
        with global.items[i] {
            event_user(1);
            event_user(4);
        }
    }
    pos += len;
}

#define check_password
//check_password(tern_pass)
var tern_pass = argument0;

var bin_pass = block_base_convert(tern_pass, 3, 2, 2, 3);

bin_pass = string_lpad(bin_pass, 96, "0");

//Change character to compute the correct password size
var charlen = ceil(log2(global.totalCharacters));
setPlayer(global.characters[real(base_convert(string_copy(bin_pass, 1, charlen), 2, 10))]);

var pass_size = password_size()
var base_pass = string_copy(bin_pass, 1, pass_size);
var checksum = string_copy(bin_pass, 1 + pass_size, 96 - pass_size);
var correct_checksum = password_checksum(base_pass);

print("bin pass", bin_pass, string_length(bin_pass), "base pass", base_pass, string_length(base_pass));

print("tern pass size", string_length(tern_pass), "password size", string_length(bin_pass), "base bin password size", pass_size, "checksum size", string_length(checksum), "correct checksum size", string_length(correct_checksum));
print("found checksum", checksum, "correct checksum", correct_checksum);

return checksum == correct_checksum;

#define password_size
//password_size()
return string_length(bin_base_password());

#define draw_password
//draw_password(password)
var password = argument0;
var posx = 23;
var posy = 19;
var size = 16;
var offset = 3;
for (i = 0; i < 64; i++) {
    var value = string_char_at(password, i + 1);
    var row = i div 8;
    var col = i mod 8;
    switch(value) {
        case "1": draw_sprite(reddot, 0, posx + col * size + offset, posy + row * size + offset); break;
        case "2": draw_sprite(bluedot, 0, posx + col * size + offset, posy+ row * size + offset); break;
    }
}

#define drawSave
/// drawSave(id, map, selected)
var save_id = argument0;
var map = argument1;
var selected = argument2;

var margin = 30;
var top = 30;
var spacing = 2;
var height = 48;
var x1 = margin;
//var y1 = save_id * (height + spacing) + top;
var y1 = top + 16;
var x2 = room_width - margin;
var y2 = y1 + height;

draw_set_halign(fa_left);

if selected {
    draw_set_colour(c_white);
}
else {
    draw_set_colour(c_gray);
}

if map > -1 and selected {

    if !selected {
        shader_set(shGrayscale);
    }
    
    //Draw Screws
    if cfgEnableScrews {
        draw_text(room_width - margin - 26, y1 + 16, string_lpad(string(map[? "screws"]),3,"0"));
        draw_sprite_ext(sprScrewBig, 0, room_width - margin - 28 - 8, y1 + 14, 0.5, 0.5, 1, c_white, 1);
    }
    
    //Draw Weapons
    for (var i = 0; i < global.totalWeapons; i++) {
        if map[? ("weaponUnlocked" + string(i))] {
            draw_sprite_ext(sprWeaponIconsColor, global.weapons[i].ID, x1 + 4 + i * 8, y1 + 14, 0.5, 0.5, 1, c_white, 1); 
        }
    }
    
    //Draw Items
    for (var i = 0; i < array_length_1d(global.items); i++) {
        var count = map[? ("itemCount" + string(i))];
        if i == 0 { //Lives
            count = map[? "lives"];
            global.items[i].sprite_index = global.spriteLife;
        }
        if count > 0 || i == 0 {
            //print(global.items[i].name, object_get_name(global.items[i].object_index), global.items[i].sprite_index);
            draw_sprite_ext(global.items[i].sprite_index, 0, x1 + 4 + i * 8, y1 + 28, 0.5, 0.5, 1, c_white, 1);
            if global.items[i].showCount {
                draw_text(x1 + 4 + i * 8, y1 + 38, string(count));
            }
        }
    }    
    
    if !selected {
        shader_reset();
    }
    
}
else if selected {
    draw_set_halign(fa_center);
    draw_text(room_width / 2, y1 + 3 + height / 2, "EMPTY");
}

#define debug_password
/// debug_password()
var tern_pass = get_string("Type the ternary password", make_password());

if check_password(tern_pass) {
    apply_password(tern_pass);
    playSFX(sfxMenuSelect);
}
else {
    playSFX(sfxError);
    print("ERROR: Invalid password.");
}

#define block_base_convert
///block_base_convert(input, base_from, base_to, block_size_from, block_size_to)
var input = argument0;
var base_from = argument1;
var base_to = argument2;
var block_size_from = argument3;
var block_size_to = argument4;

var result = "";
var size = string_length(input);

for (var i = 0; i < size; i += block_size_from) {
    result += string_lpad(base_convert(string_copy(input, i + 1, block_size_from), base_from, base_to), block_size_to, "0")
}

return result;

#define save_configs
/// save_configs()

var map = ds_map_create();

//Keys
ds_map_add(map, 'leftKey', global.leftKey);
ds_map_add(map, 'rightKey', global.rightKey);
ds_map_add(map, 'upKey', global.upKey);
ds_map_add(map, 'downKey', global.downKey);
ds_map_add(map, 'jumpKey', global.jumpKey);
ds_map_add(map, 'shootKey', global.shootKey);
ds_map_add(map, 'slideKey', global.slideKey);
ds_map_add(map, 'pauseKey', global.pauseKey);
ds_map_add(map, 'selectKey', global.selectKey);
ds_map_add(map, 'weaponSwitchLeftKey', global.weaponSwitchLeftKey);
ds_map_add(map, 'weaponSwitchRightKey', global.weaponSwitchRightKey);

//Buttons
ds_map_add(map, 'leftButton', global.leftButton);
ds_map_add(map, 'rightButton', global.rightButton);
ds_map_add(map, 'upButton', global.upButton);
ds_map_add(map, 'downButton', global.downButton);
ds_map_add(map, 'jumpButton', global.jumpButton);
ds_map_add(map, 'shootButton', global.shootButton);
ds_map_add(map, 'slideButton', global.slideButton);
ds_map_add(map, 'pauseButton', global.pauseButton);
ds_map_add(map, 'selectButton', global.selectButton);
ds_map_add(map, 'weaponSwitchLeftButton', global.weaponSwitchLeftButton);
ds_map_add(map, 'weaponSwitchRightButton', global.weaponSwitchRightButton);

ds_map_secure_save(map, 'config.dat');

#define load_configs
/// load_configs()

var map = ds_map_secure_load('config.dat');

if map > -1 {

    //Keys
    global.leftKey = ds_map_find_value(map, 'leftKey');
    global.rightKey = ds_map_find_value(map, 'rightKey');
    global.upKey = ds_map_find_value(map, 'upKey');
    global.downKey = ds_map_find_value(map, 'downKey');
    global.jumpKey = ds_map_find_value(map, 'jumpKey');
    global.shootKey = ds_map_find_value(map, 'shootKey');
    global.slideKey = ds_map_find_value(map, 'slideKey');
    global.pauseKey = ds_map_find_value(map, 'pauseKey');
    global.selectKey = ds_map_find_value(map, 'selectKey');
    global.weaponSwitchLeftKey = ds_map_find_value(map, 'weaponSwitchLeftKey');
    global.weaponSwitchRightKey = ds_map_find_value(map, 'weaponSwitchRightKey');
    
    //Buttons
    global.leftButton = ds_map_find_value(map, 'leftButton');
    global.rightButton = ds_map_find_value(map, 'rightButton');
    global.upButton = ds_map_find_value(map, 'upButton');
    global.downButton = ds_map_find_value(map, 'downButton');
    global.jumpButton = ds_map_find_value(map, 'jumpButton');
    global.shootButton = ds_map_find_value(map, 'shootButton');
    global.slideButton = ds_map_find_value(map, 'slideButton');
    global.pauseButton = ds_map_find_value(map, 'pauseButton');
    global.selectButton = ds_map_find_value(map, 'selectButton');
    global.weaponSwitchLeftButton = ds_map_find_value(map, 'weaponSwitchLeftButton');
    global.weaponSwitchRightButton = ds_map_find_value(map, 'weaponSwitchRightButton');

}

#define base_convert
/// base_convert(number,oldbase,newbase)
//
//  Returns a string of digits representing the
//  given number converted form one base to another.
//  Base36 is the largest base supported.
//
//      number      integer value to be converted, string
//      oldbase     base of the given number, integer
//      newbase     base of the returned value, integer
//
/// GMLscripts.com/license
{
    var number, oldbase, newbase, out;
    number = string_upper(argument0);
    oldbase = argument1;
    newbase = argument2;
    out = "";

    var len, tab;
    len = string_length(number);
    tab = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    var i, num;
    for (i=0; i<len; i+=1) {
        num[i] = string_pos(string_char_at(number, i+1), tab) - 1;
    }

    do {
        var divide, newlen;
        divide = 0;
        newlen = 0;
        for (i=0; i<len; i+=1) {
            divide = divide * oldbase + num[i];
            if (divide >= newbase) {
                num[newlen] = divide div newbase;
                newlen += 1;
                divide = divide mod newbase;
            } else if (newlen  > 0) {
                num[newlen] = 0;
                newlen += 1;
            }
        }
        len = newlen;
        out = string_char_at(tab, divide+1) + out;
    } until (len == 0);

    return out;
}

#define dec_to_bin
/// dec_to_bin(dec, [size])
//
//  Returns a string of binary digits (1 bit each)
//  representing the given decimal integer.
//
//      dec         non-negative integer, real
//
/// GMLscripts.com/license
{
    var dec, bin;
    var size = 8;
    if argument_count > 1 {
        size = argument1;
    }
    dec = argument0;
    if (dec) bin = "" else bin="0";
    while (dec) {
        bin = string_char_at("01", (dec & 1) + 1) + bin;
        dec = dec >> 1;
        if string_length(bin) >= size {
            break;
        }
    }
    return string_lpad(bin, size, "0");
}

#define implode
/// implode(delimiter,array)
//
//  Returns a string of elements from a given array
//  of strings and separated by a delimiter.
//
//      delimiter   delimiter character, string
//      array       group of elements, array
//
/// GMLscripts.com/license
{
    var del = argument0;
    var arr = argument1;
    var out = "";
    var ind = 0;
    var num = array_length_1d(arr);
    repeat (num-1) {
        out += arr[ind] + del;
        ind++;
    }
    out += arr[ind];
    return out;
}

#define implode_real
/// implode_real(delimiter,array)
//
//  Returns a string of elements from a given array
//  of real values and separated by a delimiter.
//
//      delimiter   delimiter character, string
//      array       group of elements, array
//
/// GMLscripts.com/license
{
    var del = argument0;
    var arr = argument1;
    var out = "";
    var ind = 0;
    var num = array_length_1d(arr);
    repeat (num-1) {
        out += string(arr[ind]) + del;
        ind++;
    }
    out += string(arr[ind]);
    return out;
}

#define iif
/// iif(cond, a, b)
if argument0 {return argument1} else {return argument2}

#define check_enemy_death
//check_enemy_death()
if healthpoints <= 0 && object_get_parent(object_index) != prtBoss && object_get_parent(object_index) != prtFortressBoss {
    instance_create(sprite_get_xcenter(), sprite_get_ycenter(), objItemExplosion);
}

#define instance_number_alive
//instance_number_alive(obj)
count = 0;
with argument0 {
    if !dead {
        other.count++;
    }
}
return count;

#define refillHealthBar
/// refillHealthBar(): nullifies effects of death and starts a new phase

control = instance_nearest(x, y, objBossControl);
control.canFillHealthBar = true;
global.bossHealth = 0;
healthpoints = 0;
dead = false;
canInitDeath = false;
playerLockMovement();
with prtEnemyProjectile {
    instance_destroy();
}
with prtPlayerProjectile {
    instance_destroy();
}

#define drawDamageNumber
///drawDamageNumber(position x, position y, int amount)
//THIS SCRIPT DISPLAYS A DAMAGE NUMBER OVER A X AND Y COORDINATE.

// If display damage numbers is not enabled, return early.
if (!global.enableDamageNumbers)
{
    return 0;
}


damageString = instance_create(argument0, argument1, objDmgText);
damageString.vspeed = -1*random_range(1, 3);
damageString.hspeed = choose(-1, 1) * random_range(1, 2);
damageString.damageValue = argument2;

#define makeLine
//makeLine(x1,y1,x2,y2)
assert(argument_count == 4, "makeLine has 4 input arguments.");
assert(is_real(argument0), "makeLine argument 0 must be a real number.");
assert(is_real(argument1), "makeLine argument 1 must be a real number.");
assert(is_real(argument2), "makeLine argument 2 must be a real number.");
assert(is_real(argument3), "makeLine argument 3 must be a real number.");

var line;
line[0] = argument0;
line[1] = argument1;
line[2] = argument2;
line[3] = argument3;

return line;

#define makePath
//makePath(x1,y1,x2,y2,x3,y3,...)
assert(argument_count > 0 && argument_count % 2 == 0, "makePath must receive an even number of real number arguments.");

var path = ds_list_create();
var prevX = 0;
var prevY = 0;
for (var i = 0; i < argument_count; i += 2) {
    assert(is_real(argument[i]), "makePath argument " + string(i) + " must be a real number.");
     
    var line = makeLine(prevX, prevY, argument[i], argument[i + 1]);
    ds_list_add(path, line);
    prevX = argument[i];
    prevY = argument[i + 1];
}

return path;

#define numBossesDefeated
//numBossedDefeated()
var n = 0;
for (var i = 0; i < 8; i++) {
    if global.bossDefeated[i] {
        n++;
    }
}
return n;

#define doExplosion
///doExplosion(xx,yy,spd)
var xx = argument0;
var yy = argument1;
var spd = argument2;

var i = 0
repeat 8 {
    explosionID = instance_create(xx, yy, objMegamanExplosion);
        explosionID.dir = i;
        explosionID.spd = spd;
    i += 45;
}

#define numRushBossesDefeated
///numRushBossesDefeated()
var n = 0;
for (var i = 0; i < 8; i++) {
    if global.bossRushDefeated[i] {
        n++;
    }
}
return n;

#define add_equip
//add_equip(equip_index)
var item_index = argument0;
if item_index.count < item_index.maxUnits {
    item_index.count++;
    with item_index event_user(4);
    playSFX(sfxImportantItem);
}

#define platesCollectedCount
/// platesCollectedCount(): returns the number of collected plates
var count = 0;
for (var i = 0; object_exists(i); i++) {
    if object_get_parent(i) == prtPlateEquip and i.count > 0 {
        count++;
    }
}
return count;

#define platesCount
/// platesCount(): returns the total number of plates in the game
var count = 0;
for (var i = 0; object_exists(i); i++) {
    if object_get_parent(i) == prtPlateEquip {
        count++;
    }
}
return count;

#define makeMap
//makeMap(roomid)
roomid = argument0;
oldroom = room;
if oldroom != roomid {
    room_goto(roomid);
}

start_screen[0] = floor(objMegaman.x / view_wview[0]);
start_screen[1] = floor(objMegaman.y / view_hview[0]);
start_screen[2] = 0;    //Depth

max_x = floor((room_width-1)/view_wview[0]);
max_y = floor((room_height-1)/view_hview[0]);

show_debug_message("making map for room " + string(room) + " Start at ("+string(start_screen[0])+","+string(start_screen[1])+")");

q = ds_queue_create();
line_q = ds_queue_create();

ds_queue_enqueue(q, start_screen);

while !ds_queue_empty(q) {
    var r = ds_queue_dequeue(q);
    /*if insideScreen(r[0], r[1], objSectionArrowUp) && r[1] > 0 {
        line[0] = r[0];
        line[1] = r[1];
        line[2] = r[2];
        line[3] = r[0];
        line[4] = r[1] - 1;
        line[5] = r[2] + 1;
        ds_queue_enqueue(line_q, line);
    }*/
    /*if insideScreen(r[0], r[1], objSectionArrowDown) && r[1] < max_y {
        var r_neighbor;
        r_neighbor[0] = r[0];
        r_neighbor[1] = r[1] + 1;
        r_neighbor[2] = r[2] + 1;
        ds_queue_enqueue(q, r_neighbor);
    }*/
    /*if r[0] < max_x && (insideScreen(r[0], r[1], objSectionArrowRight) || (!insideScreen(r[0],r[1], objSectionBorderRightScreen) && !insideScreen(r[0],r[1], objSectionBorderRight))) {
        var r_neighbor;
        r_neighbor[0] = r[0] + 1;
        r_neighbor[1] = r[1];
        r_neighbor[2] = r[2] + 1;
        ds_queue_enqueue(q, r_neighbor);
    }*/
    /*if  r[0] > 0 && (insideScreen(r[0], r[1], objSectionArrowLeft) || (!insideScreen(r[0],r[1], objSectionBorderLeftScreen) && !insideScreen(r[0],r[1], objSectionBorderLeft))) {
        var r_neighbor;
        r_neighbor[0] = r[0] - 1;
        r_neighbor[1] = r[1];
        r_neighbor[2] = r[2] + 1;
        ds_queue_enqueue(q, r_neighbor);
    }*/
    //show_debug_message("from ("+string(prev_r[0])+","+string(prev_r[1])+") to ("+string(r[0])+","+string(r[1])+")");
    line[0] = prev_r[0];
    line[1] = prev_r[1];
    line[2] = prev_r[2];
    line[3] = r[0];
    line[4] = r[1];
    line[5] = r[2];
    ds_queue_enqueue(line_q, line);
    prev_r[0] = r[0];
    prev_r[1] = r[1];
    prev_r[2] = r[2];
}

ds_queue_destroy(q);

if oldroom != roomid {
    room_goto(oldroom);
}

show_debug_message(line_q);
return line_q;

#define drawMap
//drawMap(roomid, scale, startX, startY)
var roomid = argument0;
var scale = argument1;
var oldroom = room;
if oldroom != roomid {
    room_goto(roomid);
}

if instance_exists(objMegaman) {
    var startX = objMegaman.x;
    var startY = objMegaman.y;
}
else {
    var startX = argument2;
    var startY = argument3;
}
var surf = surface_create(room_width * scale + 4, room_height * scale + 4);
surface_set_target(surf);
draw_clear_alpha(c_black, 0);

var sections = getSections(startX, startY);
var init_section = sectionRect(startX, startY);

var curr_section_id = ds_map_find_first(sections);

while !is_undefined(curr_section_id) {
    var curr_section = sections[? curr_section_id];
    var neighbors = sectionNeighbors(curr_section);
    var curr_id = ds_map_find_first(neighbors);
    while !is_undefined(curr_id) {
        var neighbor = neighbors[? curr_id];
        //draw_set_colour(c_black);
        //draw_line_width(round(curr_section[? "center"] * scale), round(curr_section[? "middle"] * scale), round(neighbor[? "center"] * scale), round(neighbor[? "middle"] * scale), 4);
        draw_set_colour(c_white);
        draw_line_width(round(curr_section[? "center"] * scale), round(curr_section[? "middle"] * scale), round(neighbor[? "center"] * scale), round(neighbor[? "middle"] * scale), 2);
        if instanceInside(neighbor[? "left"], neighbor[? "top"], neighbor[? "right"], neighbor[? "bottom"], objBossControl) {
            draw_set_colour(c_red);
            draw_circle(round(neighbor[? "center"] * scale), round(neighbor[? "middle"] * scale), 3, c_black);
        }
        curr_id = ds_map_find_next(neighbors, curr_id);
    }
    curr_section_id = ds_map_find_next(sections, curr_section_id);
}
draw_set_colour(c_red);
draw_circle(round(init_section[? "center"] * scale), round(init_section[? "middle"] * scale), 3, c_black);
surface_reset_target();


if oldroom != roomid {
    room_goto(oldroom);
}


return surf;

#define sectionRect
//sectionRect(posx,posy)
var posx = argument0;
var posy = argument1;

var currx = posx;
var curry = posy;
var left = -999;
while left == -999 {
    if currx <= 15 {
        left = 0;
    }
    var bsid = instance_position(currx, curry, objSectionBorderLeftScreen);
    if bsid > -1 {
        left = bsid.x;
    }
    var bid = instance_position(currx, curry, objSectionBorderLeft);
    if bid > -1 {
        left = bid.x;
    }
    currx--;
}

//show_debug_message("Left: " + string(left));

currx = posx;
curry = posy;
var right = -999;
while right == -999 {
    if currx >= room_width-16 {
        right = room_width-1;
    }
    var bsid = instance_position(currx, curry, objSectionBorderRightScreen);
    if bsid > -1 {
        right = bsid.x + 15;
    }
    var bid = instance_position(currx, curry, objSectionBorderRight);
    if bid > -1 {
        right = bid.x + 15;
    }
    currx++;
}

//show_debug_message("Right: " + string(right));

currx = posx;
curry = posy;
var top = -999;
while top == -999 {
    if curry <= 15 {
        top = 0;
    }
    var bsid = instance_position(currx, curry, objSectionBorderTopScreen);
    if bsid > -1 {
        top = bsid.y;
    }
    var bid = instance_position(currx, curry, objSectionBorderTop);
    if bid > -1 {
        top = bid.y;
    }
    curry--;
}

//show_debug_message("Top: " + string(top));

currx = posx;
curry = posy;
var bottom = -999;
while bottom == -999 {
    if curry >= room_height-16 {
        bottom = room_height-1;
    }
    var bsid = instance_position(currx, curry, objSectionBorderBottomScreen);
    if bsid > -1 {
        bottom = bsid.y + 15;
    }
    var bid = instance_position(currx, curry, objSectionBorderBottom);
    if bid > -1 {
        bottom = bid.y + 15;
    }
    curry++;
}

var center = (left + right) / 2;
var middle = (top + bottom) / 2;

//show_debug_message("Bottom: " + string(bottom));

var rect = ds_map_create();
ds_map_add(rect, "left", left);
ds_map_add(rect, "right", right);
ds_map_add(rect, "top", top);
ds_map_add(rect, "bottom", bottom);
ds_map_add(rect, "width", right - left + 1);
ds_map_add(rect, "height", bottom - top + 1);
ds_map_add(rect, "center", center);
ds_map_add(rect, "middle", middle);
ds_map_add(rect, "id", string(left) + "," +  string(top) );

ds_map_add(rect, "path_top", instanceInside(left, top, right, bottom, objSectionArrowUp) > -1 || instanceInside(left, top - 17, right, middle, objBossDoorH) > -1);    
ds_map_add(rect, "path_right", instanceInside(left, top, right, bottom, objSectionArrowRight) > -1 || instanceInside(center, top, right, bottom, objBossDoor) > -1);    
ds_map_add(rect, "path_bottom", instanceInside(left, top, right, bottom, objSectionArrowDown) > -1 || instanceInside(left, middle, right, bottom, objBossDoorH) > -1);    
ds_map_add(rect, "path_left", instanceInside(left, top, right, bottom, objSectionArrowLeft) > -1 || instanceInside(left - 17, top, center, bottom, objBossDoor) > -1);    

return rect;

#define getSections
//getSections(startX, startY)
var startX = argument0;
var startY = argument1;

var q = ds_queue_create();

var s = sectionRect(startX, startY);
ds_queue_enqueue(q, s);

var sections = ds_map_create();

while !ds_queue_empty(q) {
    s = ds_queue_dequeue(q);
    ds_map_add(sections, s[? "id"], s);
    if s[? "path_top"] {
        var top_section = sectionRect(s[? "left"], s[? "top"] - 1);
        if !ds_map_exists(sections, top_section[? "id"]) {
            ds_queue_enqueue(q, top_section);
        }
    }
    if s[? "path_right"] {
        var right_section = sectionRect(s[? "right"] + 1, s[? "top"]);
        if !ds_map_exists(sections, right_section[? "id"]) {
            ds_queue_enqueue(q, right_section);
        }
    }
    if s[? "path_bottom"] {
        var bottom_section = sectionRect(s[? "left"], s[? "bottom"] + 1);
        if !ds_map_exists(sections, bottom_section[? "id"]) {
            ds_queue_enqueue(q, bottom_section);
        }
    }
    if s[? "path_left"] {
        var left_section = sectionRect(s[? "left"] - 1, s[? "top"]);
        if !ds_map_exists(sections, left_section[? "id"]) {
            ds_queue_enqueue(q, left_section);
        }
    }
}

ds_queue_destroy(q);

return sections;

#define sectionNeighbors
//sectionNeighbors(sectionRect)
var section = argument0;
var neighbors = ds_map_create();

if section[? "path_top"] {
    var rect = sectionRect(section[? "left"], section[? "top"] - 1);
    ds_map_add(neighbors, "top", rect);
}

if section[? "path_right"] {
    var rect = sectionRect(section[? "right"] + 1, section[? "top"]);
    ds_map_add(neighbors, "right", rect);
}

if section[? "path_bottom"] {
    var rect = sectionRect(section[? "left"], section[? "bottom"] + 1);
    ds_map_add(neighbors, "bottom", rect);
}

if section[? "path_left"] {
    var rect = sectionRect(section[? "left"] - 1, section[? "top"]);
    ds_map_add(neighbors, "left", rect);
}

return neighbors;

#define placeHorizontalBorders
/// Place horizontal borders (top and bottom)
for (v = 0; v < room_height; v += view_hview) {
    for (i = 0; i < room_width; i += view_wview) {
        instance_create(i, v, objSectionBorderTopScreen);
        instance_create(i, v + view_hview - 16, objSectionBorderBottomScreen);
        if v > 0 && v < room_height - 1 {
            for (var j = 0; j < view_wview; j += 16) {
                if instance_position(i + j, v, objLadder) {
                    instance_create(i + j, v, objSectionArrowUp);
                }
                if instance_position(i + j, v - 16, objLadder) {
                    instance_create(i + j, v - 16, objSectionArrowDown);
                }
            }            
        }
    }
}  

#define placeRoomBorders
/// Place room borders (left and right)
for (v = 0; v < room_height; v += view_hview) {
    instance_create(0, v, objSectionBorderLeftScreen);
    instance_create(room_width - 16, v, objSectionBorderRightScreen);
}  

#define instanceInside
//instanceInside(left, top, right, bottom, obj)
var left = argument0;
var top = argument1;
var right = argument2;
var bottom = argument3;
var obj = argument4;

var n = instance_number(obj);

for (var i = 0; i < n; i++) {
    var instance = instance_find(obj, i);
    if instance.x >= left && instance.x <= right && instance.y >= top && instance.y <= bottom {
        return instance;
    }
}

return -1;

#define instance_nth_nearest
/// instance_nth_nearest(x,y,obj,n)
//
//  Returns the id of the nth nearest instance of an object
//  to a given point or noone if none is found.
//
//      x,y       point coordinates, real
//      obj       object index (or all), real
//      n         proximity, real
//
/// GMLscripts.com/license
{
    var pointx,pointy,object,n,list,nearest;
    pointx = argument0;
    pointy = argument1;
    object = argument2;
    n = argument3;
    n = min(max(1,n),instance_number(object));
    list = ds_priority_create();
    nearest = noone;
    with (object) ds_priority_add(list,id,distance_to_point(pointx,pointy));
    repeat (n) nearest = ds_priority_delete_min(list);
    ds_priority_destroy(list);
    return nearest;
}

#define instance_distance
/// instance_distance(obj1, obj2)

var obj1 = argument0;
var obj2 = argument1;

return sqrt(power(obj1.x - obj2.x, 2) + power(obj1.y - obj2.y, 2));


#define assert
/// assert(condition, [msg])
if cfgDebug || debug_mode {
    var condition = argument0;
    if !condition {
        var msg = "Assertion Failed on " + object_get_name(self) + ".";
        if argument_count > 1 {
            msg += " " + argument1;
        }
        
        show_error(msg, true);
    }
}

#define print
/// print(variables or strings)

var output_string = "";

for (var i = 0; i < argument_count; i++) {
    output_string += string(argument[i]) + " ";
}

show_debug_message(output_string);

#define changeScene
//changeScene(scene_number, delay)
var scene_number = argument0;
var delay = argument1;

next_scene = scene_number + 1;

var fadeoutin = instance_create(0,0, objFadeIn);
with fadeoutin {
    deactivate = false;
    blackAlpha = 0;
    blackAlphaDecrease = -0.2;
    reverse = true;
}

if scene_number < 11 {
    alarm[scene_number + 1] = room_speed * delay;  //Default time for transitioning to next scene
}

show_debug_message("Scene " + string(next_scene) + ". Next one in " + string(alarm[scene_number + 1]/room_speed) + " seconds.");


#define gamepad_axis_value_any
/// gamepad_axis_value_any(axis)
var axis = argument0;

var gp_num = gamepad_get_device_count();
var maximum = 0;
for (var i = 0; i < gp_num; i++) {
    if gamepad_is_connected(i) {
        var value = gamepad_axis_value(i, axis);
        if abs(value) > abs(maximum) {
            maximum = value;
        }
    }
}
return maximum;

#define gamepad_button_check_any
/// gamepad_button_check_any(button)
var button = argument0;

var gp_num = gamepad_get_device_count();
var result = false;
for (var i = 0; i < gp_num; i++) {
    if gamepad_is_connected(i) {
        result = result || gamepad_button_check(i, button);
    }
}
return result;

#define gamepad_button_check_pressed_any
/// gamepad_button_check_pressed_any(button)
var button = argument0;

var gp_num = gamepad_get_device_count();
var result = false;
for (var i = 0; i < gp_num; i++) {
    if gamepad_is_connected(i) {
        result = result || gamepad_button_check_pressed(i, button);
    }
}
return result;

#define gamepad_button_check_released_any
/// gamepad_button_check_released_any(button)
var button = argument0;

var gp_num = gamepad_get_device_count();
var result = false;
for (var i = 0; i < gp_num; i++) {
    if gamepad_is_connected(i) {
        result = result || gamepad_button_check_released(i, button);
    }
}
return result;

#define gamepad_button_check_all
/// gamepad_button_check_all() : Returns currently pressed button (any)
for ( var i = gp_face1; i < gp_axisrv; i++ ) {
    if ( gamepad_button_check_any( i ) ) return i;
}
return false;

#define gamepad_button_check_pressed_all
/// gamepad_button_check_pressed_all() : Returns currently pressed button (any)
for ( var i = gp_face1; i < gp_axisrv; i++ ) {
    if ( gamepad_button_check_pressed_any( i ) ) return i;
}
return false;

#define reset_controls
/// reset_controls()

reset_keys();

reset_buttons();

#define reset_buttons
/// reset_buttons()

//Buttons
global.leftButton = gp_padl;
global.rightButton = gp_padr;
global.upButton = gp_padu;
global.downButton = gp_padd;
global.jumpButton = gp_face3;
global.shootButton = gp_face4;
global.slideButton = gp_face2;
global.pauseButton = gp_start;
global.selectButton = gp_select;
global.weaponSwitchLeftButton = gp_shoulderlb;
global.weaponSwitchRightButton = gp_shoulderrb;

#define reset_keys
/// reset_keys()

//Keys
global.leftKey = vk_left;
global.rightKey = vk_right;
global.upKey = vk_up;
global.downKey = vk_down;
global.jumpKey = ord('Z');
global.shootKey = ord('X');
global.slideKey = ord('C');
global.pauseKey = vk_space;
global.selectKey = vk_shift;
global.weaponSwitchLeftKey = ord('A');
global.weaponSwitchRightKey = ord('S');

#define readTileObjects
/// readTileObjects
// Must be called from rmInit

global.tiles = ds_map_create();

with all {
    var tile = tile_layer_find(1000000, x, y);
    if tile > -1 {
        var tx = tile_get_x(tile);
        var ty = tile_get_y(tile);
        var dx = x - tx;
        var dy = y - ty;
        var tile_id = tile_get_type(tile, dx, dy);
        ds_map_add(global.tiles, tile_id, object_index);
    }
}


#define readTileAnimations
/// readTileAnimations
// Must be called from rmInit

global.anims = ds_map_create();

var tiles = tile_get_ids();
var num_tiles = array_length_1d(tiles);

for (var i = 0; i < num_tiles; i++) {
    var tid = tiles[i];
    var tl = tile_get_depth(tid);
    if tl == 1000000 {
        continue;
    }
    var tx = tile_get_x(tid);
    var ty = tile_get_y(tid);
    var tw = tile_get_width(tid);
    var th = tile_get_height(tid);
    var tile_id = tile_get_type(tid, 0, 0);
    for (var j = 0; j < num_tiles; j++) {
        var tid_ = tiles[j];
        var tl_ = tile_get_depth(tid_);
        if tl_ != 1000000 {
            continue;
        }        
        var tx_ = tile_get_x(tid_);
        var ty_ = tile_get_y(tid_);
        var tw_ = tile_get_width(tid_);
        var th_ = tile_get_height(tid_);
        if tx > tx_ + tw_ or ty > ty_ + th_ or tx < tx_ or ty < ty_ {
            continue;
        }
        var tile_id_ = tile_get_type(tid_, tx - tx_, ty - ty_);
        //print(tile_id, tile_id_, tx, tx_, ty, ty_);
        var anim = ds_map_find_value(global.anims, tile_id_);
        if is_undefined(anim) {
            anim = ds_map_create();
        }
        ds_map_add(anim, tl, tile_id + "," + string(tw) + "," + string(th));
        ds_map_add(global.anims, tile_id_, anim);
    }
}

#define tile_get_type
/// tile_get_type(id, dx, dy)

var tid = argument0;
var dx = argument1;
var dy = argument2;

var tbg = tile_get_background(tid);
var tleft = tile_get_left(tid) + dx;
var ttop = tile_get_top(tid) + dy;
var tile_id = string(tbg) + "," + string(tleft) + "," + string(ttop);

return tile_id;


#define placeTileObjects
/// placeTileObjects()

var tiles = tile_get_ids();
var num_tiles = array_length_1d(tiles);

for (var i = 0; i < num_tiles; i++) {
    var tid = tiles[i];
    var tx = tile_get_x(tid);
    var ty = tile_get_y(tid);
    var tw = tile_get_width(tid);
    var th = tile_get_height(tid);
    var type = tile_get_type(tid, 0, 0);
    var obj = ds_map_find_value(global.tiles, type);
    if !is_undefined(obj) {
        var inst = instance_create(tx, ty, obj);
        inst.image_xscale = tw / inst.sprite_width;
        inst.image_yscale = th / inst.sprite_height;
    }
}

#define placeTileAnimations
/// placeTileAnimations()

var tiles = tile_get_ids();
var num_tiles = array_length_1d(tiles);

for (var i = 0; i < num_tiles; i++) {
    var tid = tiles[i];
    var tx = tile_get_x(tid);
    var ty = tile_get_y(tid);
    var real_tx = tile_get_x(tid);
    var real_ty = tile_get_y(tid);
    var tw = tile_get_width(tid);
    var th = tile_get_height(tid);
    var tile_id = tile_get_type(tid, tx - real_tx, ty - real_ty);
    var tiles_ = ds_map_find_value(global.anims, tile_id);
    if tiles_ > -1 {
        var key = ds_map_find_first(tiles_);
        while (!is_undefined(key)) {
            var tile = ds_map_find_value(tiles_, key);
            var parts = split(tile, ",");
            var bg = real(ds_queue_dequeue(parts));
            var tleft = real(ds_queue_dequeue(parts));
            var ttop = real(ds_queue_dequeue(parts));
            var tw_ = real(ds_queue_dequeue(parts));
            var th_ = real(ds_queue_dequeue(parts));
            tile_add(bg, tleft, ttop, tw_, th_, tx, ty, real(key));
            key = ds_map_find_next(tiles_, key);
        }
    }
}

#define load_achievements
/// load_achievements()

var map = ds_map_secure_load('achievements.dat');

if map > -1 {
    //Write achievements' completion status
    for (var i = 0; object_exists(i); i++) {
        if object_get_parent(i) == prtAchievement {
            i.completed = ds_map_find_value(map, i.name);
            print("Loaded achievement " + i.name + " as " + iif(i.completed, "COMPLETED", "PENDING"));
        }
    }
}

#define add_achievement
/// add_achievement(achievement)

var achievement = argument0;

if !achievement.completed {
    achievement.completed = true;
    var box = instance_create(0, 0, objAchievementBox);
    box.txt = achievement.name;
    print("Challenge completed! " + achievement.name);
    save_achievements();
}

#define save_achievements
/// save_achievements()

var map = ds_map_create();

//Achievements
for (var i = 0; object_exists(i); i++) {
    if object_get_parent(i) == prtAchievement {
        ds_map_add(map, i.name, i.completed);
    }
}

ds_map_secure_save(map, 'achievements.dat');

