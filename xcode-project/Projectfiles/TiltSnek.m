//
//  TiltSnek.m
//  Snek
//
//  Created by Pippin Barr on 15/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "TiltSnek.h"


@implementation TiltSnek

+ (id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [TiltSnek node];
    
    [scene addChild:layer];
    
    return scene;
}

- (id) init
{
    highScoreKey = @"TiltHighScore";
    latestScoreKey = @"TiltLatestScore";
    
    if ( self = [super init] )
    {
        KKInput* input = [KKInput sharedInput];
        //        input.accelerometerActive = YES;
        input.gyroActive = YES;
        input.deviceMotionActive = YES;
        
#if TARGET_OS_IPHONE
        
#endif
        
        xp = 0.0f;
        yp = 0.0f;        
    }
    
    return self;
}


- (void) update:(ccTime)delta
{
    [self handleInputNewNew:delta];
    
    [super update:delta];
    
    
    return;
}


- (void) gameOver
{
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper submitScore:score category:@"tilt.high.scores"];
    
    [super gameOver];
}


#if TARGET_OS_IPHONE


- (void) handleInputNewNew:(ccTime)delta
{
    KKInput* input = [KKInput sharedInput];
    KKRotationRate* rotationRate = input.rotationRate;
    
    float xr = rotationRate.x;
    float yr = rotationRate.y;
    
    
    if (tilting == NO_TILT)
    {
        if (xr - xp > MIN_TILT_STEP)
        {
            tilting = BACKWARD;
        }
        else if (xp - xr > MIN_TILT_STEP)
        {
            tilting = FORWARD;
        }
        else if (yr - yp > MIN_TILT_STEP)
        {
            tilting = RIGHT_SIDE;
        }
        else if (yp - yr > MIN_TILT_STEP)
        {
            tilting = LEFT_SIDE;
        }
        
        if (tilting != NO_TILT) tiltElapsed = 0;
    }
    
    if (tilting == BACKWARD)
    {
        if (xr - xp > MIN_TILT_STEP)
        {
            tiltElapsed += delta;
            if (tiltElapsed >= MIN_TILT_TIME)
            {
                [self snakeFaceDown];
                tilting = NO_TILT;
            }
        }
        else
        {
            tilting = NO_TILT;
        }
    }
    else if (tilting == FORWARD)
    {
        if (xp - xr > MIN_TILT_STEP)
        {
            tiltElapsed += delta;
            if (tiltElapsed >= MIN_TILT_TIME)
            {
                [self snakeFaceUp];
                tilting = NO_TILT;
            }
        }
        else
        {
            tilting = NO_TILT;
        }
    }
    else if (tilting == RIGHT_SIDE)
    {
        if (yr - yp > MIN_TILT_STEP)
        {
            tiltElapsed += delta;
            if (tiltElapsed >= MIN_TILT_TIME)
            {
                [self snakeFaceRight];
                tilting = NO_TILT;
            }
        }
        else
        {
            tilting = NO_TILT;
        }
    }
    else if (tilting == LEFT_SIDE)
    {
        if (yp - yr > MIN_TILT_STEP)
        {
            tiltElapsed += delta;
            if (tiltElapsed >= MIN_TILT_TIME)
            {
                [self snakeFaceLeft];
                tilting = NO_TILT;
            }
        }
        else
        {
            tilting = NO_TILT;
        }
    }
    
}



//- (void) handleInputOld
//{
//    [super handleInput];
//    
//    KKInput* input = [KKInput sharedInput];
//    KKRotationRate* rotationRate = input.rotationRate;
//    
//    float r = rotationRate.z;
//    
//    if (!canRotate)
//    {
//        if (rotating == CW)
//        {
//            if (r > 0 && r < previous && r < TRIGGER_ROTATION/2) canRotate = YES;
//        }
//        else if (rotating == CCW)
//        {
//            if (r < 0 && r > previous && r > -TRIGGER_ROTATION/2) canRotate = YES;
//        }
//    }
//    
//    previous = r;
//    
//    if (!canRotate) return;
//    
//    if (r < -TRIGGER_ROTATION)
//    {
//        rotating = CW;
//        [self snakeTurnCW];
//        canRotate = NO;
//        
//    }
//    else if (r > TRIGGER_ROTATION)
//    {
//        rotating = CCW;
//        [self snakeTurnCCW];
//        canRotate = NO;
//    }
//}


- (void) showTutorial
{
    [super showTutorial];
    
    // TEXT
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSString* instructionsString = @"Tilt the device smoothly\nin the direction you\nwant Snek to move.";
    
    CCLabelTTF* instructionsText = [CCLabelTTF labelWithString:instructionsString fontName:@"Helvetica" fontSize:gridUnitInPixels];
    [tutorialNode addChild:instructionsText];
    instructionsText.position = CGPointMake(size.width/2,size.height - gridUnitInPixels*3);
    
    CCLabelTTF* continueText =  [CCLabelTTF labelWithString:@"Touch to continue." fontName:@"Helvetica" fontSize:gridUnitInPixels * 0.75];
    [tutorialNode addChild:continueText];
    continueText.position = CGPointMake(size.width/2,0 + gridUnitInPixels);
    
    
    // ANIMATION
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"TiltInstructions.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"TiltInstructions.png"];
    
    [tutorialNode addChild:spriteSheet];
    NSMutableArray *startLoopFrames = [NSMutableArray array];
    for (int i=1; i<=7; i++) {
        [startLoopFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekTiltInstructions%d.png",i]]];
    }
    CCAnimation *startAnimation = [CCAnimation
                                   animationWithSpriteFrames:startLoopFrames delay:moveTime];
    
    NSMutableArray *thrustFrames = [NSMutableArray array];
    for (int i=8; i<=10; i++)
    {
        [thrustFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekTiltInstructions%d.png",i]]];
    }
    CCAnimation* thrustAnimation = [CCAnimation
                                    animationWithSpriteFrames:thrustFrames delay:moveTime];
    
    
    NSMutableArray *postThrustLoop = [NSMutableArray array];
    for (int i=11; i<=14; i++)
    {
        [postThrustLoop addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekTiltInstructions%d.png",i]]];
    }
    CCAnimation* postThrustAnimation = [CCAnimation
                                        animationWithSpriteFrames:postThrustLoop delay:moveTime];
    
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite* animSprite = [CCSprite spriteWithSpriteFrameName:@"SnekTiltInstructions1.png"];
    animSprite.position = ccp(winSize.width/2, winSize.height/2 - gridUnitInPixels);
    
    
    CCAnimate* startAnimate = [CCAnimate actionWithAnimation:startAnimation];
    CCAnimate* thrustAnimate = [CCAnimate actionWithAnimation:thrustAnimation];
    CCAnimate* postThrustAnimate = [CCAnimate actionWithAnimation:postThrustAnimation];
    
    CCSequence* animationSequence = [CCSequence actions:
                                     startAnimate,
                                     thrustAnimate,
                                     postThrustAnimate,postThrustAnimate,postThrustAnimate,postThrustAnimate,nil];
    
    [animSprite runAction:[CCRepeatForever actionWithAction:animationSequence]];
    [spriteSheet addChild:animSprite];
    
    [[animSprite texture] setAliasTexParameters];
    animSprite.scale = 24;
    
//    CCLOG(@"gridUnitInPixels is %i",gridUnitInPixels);
}

#endif

@end
