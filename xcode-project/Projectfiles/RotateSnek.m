//
//  RotateSnek.m
//  Snek
//
//  Created by Pippin Barr on 9/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RotateSnek.h"


@implementation RotateSnek


+ (id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [RotateSnek node];
    
    [scene addChild:layer];
    
    return scene;
}

- (id) init
{
    highScoreKey = @"TurnHighScore";
    latestScoreKey = @"TurnLatestScore";
    
    if ( self = [super init] )
    {
        
        KKInput* input = [KKInput sharedInput];
//        input.accelerometerActive = YES;
        input.gyroActive = YES;
        input.deviceMotionActive = YES;
        
#if TARGET_OS_IPHONE
        
#endif

        previous = 0.0f;
        canRotate = YES;
        rotateElapsed = 0;
        
        hitTrigger = NO;
        
    }
    
    return self;
}


- (void) update:(ccTime)delta
{
    [super update:delta];
    
    [self handleInputNewNew:delta];

    return;
}


- (void) gameOver
{
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper submitScore:score category:@"rotation.high.scores"];
    
    [super gameOver];
}


#if TARGET_OS_IPHONE


- (void) handleInput
{
    [super handleInput];
    
    
   
}



- (void) handleInputNewNew:(ccTime)delta
{
    KKInput* input = [KKInput sharedInput];
    KKRotationRate* rotationRate = input.rotationRate;
    
    float r = rotationRate.z;
    
    CCLOG(@"r - previous = %f",(r - previous));
    
    if (rotating == NO_ROTATION)
    {
        if (r - previous > MIN_ROTATE_STEP)
        {
            rotating = CCW;
            rotateElapsed = 0;
        }
        else if (previous - r > MIN_ROTATE_STEP)
        {
            rotating = CW;
            rotateElapsed = 0;
        }
    }
    else if (rotating == CCW)
    {
        if (r - previous > MIN_ROTATE_STEP)
        {
            rotateElapsed += delta;
            if (rotateElapsed >= MIN_ROTATE_TIME)
            {
                [self snakeTurnCCW];
                rotating = NO_ROTATION;
            }
        }
        else
        {
            rotating = NO_ROTATION;
        }
    }
    else if (rotating == CW)
    {
        if (previous - r > MIN_ROTATE_STEP)
        {
            rotateElapsed += delta;
            if (rotateElapsed >= MIN_ROTATE_TIME)
            {
                [self snakeTurnCW];
                rotating = NO_ROTATION;
            }
        }
        else
        {
            rotating = NO_ROTATION;
        }
    }
}


//- (void) handleInputNew:(ccTime)delta
//{
//    KKInput* input = [KKInput sharedInput];
//    KKRotationRate* rotationRate = input.rotationRate;
//    
//    float r = rotationRate.z;
//
//    if (rotating == NO_ROTATION)
//    {
//        if (r > 0 && r > previous)
//        {
//            rotating = CCW;
//        }
//        else if (r < 0 && r < previous)
//        {
//            rotating = CW;
//        }
//    }
//    else
//    {
//        rotateElapsed += delta;
//        
//        if (rotating == CCW)
//        {
//            if (r < previous) rotating = NO_ROTATION;
//            else if (r > TRIGGER_ROTATION)
//            {
//                if (rotateElapsed >= 0.15)
//                {
//                    [self snakeTurnCCW];
//                    rotating = NO_ROTATION;
//                    rotateElapsed = 0;
//                }
//                else
//                {
//                    rotating = NO_ROTATION;
//                    rotateElapsed = 0;
//                }
//            }
//        }
//        else if (rotating == CW)
//        {
//            if (r > previous) rotating = NO_ROTATION;
//            else if (r < -TRIGGER_ROTATION)
//            {
//                if (rotateElapsed >= 0.15)
//                {
//                    [self snakeTurnCW];
//                    rotating = NO_ROTATION;
//                    rotateElapsed = 0;
//                }
//                else
//                {
//                    rotating = NO_ROTATION;
//                    rotateElapsed = 0;
//                }
//            }
//        }
//    }
//    
//    previous = r;
//}
//
//
//- (void) handleInputOld
//{
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
    
    NSString* instructionsString = @"Turn the device smoothly\nin the direction you\nwant Snek to move.";
    
    CCLabelTTF* instructionsText = [CCLabelTTF labelWithString:instructionsString fontName:@"Helvetica" fontSize:gridUnitInPixels];
    [tutorialNode addChild:instructionsText];
    instructionsText.position = CGPointMake(size.width/2,size.height - gridUnitInPixels*3);
    
    CCLabelTTF* continueText =  [CCLabelTTF labelWithString:@"Touch to continue." fontName:@"Helvetica" fontSize:gridUnitInPixels * 0.75];
    [tutorialNode addChild:continueText];
    continueText.position = CGPointMake(size.width/2,0 + gridUnitInPixels);
    
    
    // ANIMATION
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"RotateInstructions.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"RotateInstructions.png"];
    
    [tutorialNode addChild:spriteSheet];
    NSMutableArray *startLoopFrames = [NSMutableArray array];
    for (int i=1; i<=7; i++) {
        [startLoopFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekRotateInstructions%d.png",i]]];
    }
    CCAnimation *startAnimation = [CCAnimation
                                   animationWithSpriteFrames:startLoopFrames delay:moveTime];
    
    NSMutableArray *thrustFrames = [NSMutableArray array];
    for (int i=8; i<=9; i++)
    {
        [thrustFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekRotateInstructions%d.png",i]]];
    }
    CCAnimation* thrustAnimation = [CCAnimation
                                    animationWithSpriteFrames:thrustFrames delay:moveTime];
    
    
    NSMutableArray *postThrustLoop = [NSMutableArray array];
    for (int i=10; i<=14; i++)
    {
        [postThrustLoop addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekRotateInstructions%d.png",i]]];
    }
    CCAnimation* postThrustAnimation = [CCAnimation
                                        animationWithSpriteFrames:postThrustLoop delay:moveTime];
    
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite* animSprite = [CCSprite spriteWithSpriteFrameName:@"SnekRotateInstructions1.png"];
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
}


#endif


@end
