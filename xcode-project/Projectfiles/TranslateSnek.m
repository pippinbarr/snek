//
//  TranslateSnek.m
//  Snek
//
//  Created by Pippin Barr on 10/5/13.
//  Copv.yight 2013 __MyCompanyName__. All rights reserved.
//

#import "TranslateSnek.h"



@implementation TranslateSnek


+ (id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [TranslateSnek node];
    
    [scene addChild:layer];
    
    return scene;
}

- (id) init
{
    highScoreKey = @"ThrustHighScore";
    latestScoreKey = @"ThrustLatestScore";
    
    
    if ( self = [super init] )
    {
        KKInput* input = [KKInput sharedInput];
        //        input.accelerometerActive = YES;
        input.deviceMotionActive = YES;
        
#if TARGET_OS_IPHONE
        
#endif
        
        canTranslate = YES;
        translated = NO;
        stable = YES;
        high = CGPointMake(0,0);
        trigger = CGPointMake(0, 0);
        previous = CGPointMake(0, 0);
        translateElapsed = 0;
        translating = NO_TRANSLATION;
        
        pa = CGPointMake(0, 0);
        pv = CGPointMake(0, 0);
        
    }
    
    return self;
}


- (void) update:(ccTime)delta
{
    //    [self handleInputAgain:delta];
    
//    [self handleInputNew:delta];
    
    [super update:delta];
    
    
    
    return;
}


- (void) gameOver
{
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper submitScore:score category:@"translation.high.scores"];
    
    [super gameOver];
}


#if TARGET_OS_IPHONE







- (void) handleInput
{
    [super handleInput];
    
    
    KKInput* input = [KKInput sharedInput];
    //    KKAcceleration* acceleration = input.acceleration;
    KKDeviceMotion* motion = input.deviceMotion;
    KKAcceleration* acceleration = motion.acceleration;
    CGPoint translation = CGPointMake(acceleration.rawX, acceleration.rawY);
    
    //    CGPoint diff = CGPointMake(translation.x - previous.x,translation.y - previous.y);
    //
    //    if (abs(translation.x) > 0.1 || abs(translation.y) > 0.1)
    //        CCLOG(@"trans=(%f,%f), diff=(%f,%f)",translation.x,translation.y,diff.x,diff.y);
    
    
    if (translating == NO_TRANSLATION)
    {
        if ((snakeHead.facing == LEFT || snakeHead.facing == RIGHT) && nextDir != UP && translation.y > MIN_TRANSLATION)
        {
            translating = GOING_DOWN;
            CCLOG(@"Started going down...");
        }
        else if ((snakeHead.facing == LEFT || snakeHead.facing == RIGHT) && nextDir != DOWN && translation.y < -MIN_TRANSLATION)
        {
            translating = GOING_UP;
            CCLOG(@"Started going up...");
        }
        else if ((snakeHead.facing == UP || snakeHead.facing == DOWN) && nextDir != RIGHT && translation.x > MIN_TRANSLATION)
        {
            translating = GOING_LEFT;
            CCLOG(@"Started going left...");
        }
        else if ((snakeHead.facing == UP || snakeHead.facing == DOWN) && nextDir != LEFT && translation.x < -MIN_TRANSLATION)
        {
            translating = GOING_RIGHT;
            CCLOG(@"Started going right...");
        }
        
        if (translating != NO_TRANSLATION)
            translateElapsed = 0;
    }
    else if (translating == GOING_DOWN)
    {
        if (translation.y < previous.y)
        {
            if (previous.y >= TRIGGER_ACCELERATION)
            {
                [self snakeFaceDown];
                CCLOG(@"... turned down!");
            }
            translating = DECELERATING_UP;
            CCLOG(@"... decelerating.");
        }
    }
    else if (translating == GOING_UP)
    {
        if (translation.y > previous.y)
        {
            if (previous.y <= -TRIGGER_ACCELERATION)
            {
                [self snakeFaceUp];
                CCLOG(@"... turned up!");
            }
            translating = DECELERATING_DOWN;
            CCLOG(@"... decelerating.");
        }
    }
    else if (translating == GOING_LEFT)
    {
        if (translation.x < previous.x)
        {
            if (previous.x >= TRIGGER_ACCELERATION)
            {
                [self snakeFaceLeft];
                CCLOG(@"... turned left!");
            }
            translating = DECELERATING_RIGHT;
            CCLOG(@"... decelerating.");
        }
    }
    else if (translating == GOING_RIGHT)
    {
        if (translation.x > previous.x)
        {
            if (previous.x <= -TRIGGER_ACCELERATION)
            {
                [self snakeFaceRight];
                CCLOG(@"... turned right!");
            }
            translating = DECELERATING_LEFT;
            CCLOG(@"... decelerating.");
        }
    }
    else if (translating == DECELERATING_UP)
    {
        if (translation.y > previous.y)
        {
            translating = NO_TRANSLATION;
            CCLOG(@"... deceleration completed.");
        }
    }
    else if (translating == DECELERATING_DOWN)
    {
        if (translation.y < previous.y)
        {
            translating = NO_TRANSLATION;
            CCLOG(@"... deceleration completed.");
        }
    }
    else if (translating == DECELERATING_LEFT)
    {
        if (translation.x > previous.x)
        {
            translating = NO_TRANSLATION;
            CCLOG(@"... deceleration completed.");
        }
    }
    else if (translating == DECELERATING_RIGHT)
    {
        if (translation.x < previous.x)
        {
            translating = NO_TRANSLATION;
            CCLOG(@"... deceleration completed.");
        }
    }
    
    previous = translation;
}


//- (void) handleInputOld
//{
//    [super handleInput];
//
//    KKInput* input = [KKInput sharedInput];
//    //    KKAcceleration* acceleration = input.acceleration;
//    KKDeviceMotion* motion = input.deviceMotion;
//    KKAcceleration* acceleration = motion.acceleration;
//
//    CGPoint raw, smooth, instant;
//
//    // raw, unmodified accelerometer values
//    raw = CGPointMake(acceleration.rawX, acceleration.rawY);
//
//    // low-pass filtered (smoothed) values
//    smooth = CGPointMake(acceleration.smoothedX, acceleration.smoothedY);
//
//    // high-pass filtered (instantaneous) values
//    instant = CGPointMake(acceleration.instantaneousX, acceleration.instantaneousY);
//
//
//    CGPoint translation = CGPointMake(acceleration.rawX, acceleration.rawY);
//
//    //    if (translation.x > 0.5 || translation.x < -0.5 || translation.y > 0.5 || translation.y < -0.5)
//    CCLOG(@"::: %f,%f", translation.x, translation.y);
//
//    //    if (abs(translation.x) > high.x) high.x = abs(translation.x);
//    //    if (abs(translation.y) > high.y) high.y = abs(translation.y);
//
//    //    CCLOG(@"::: highs: %f,%f", high.x, high.y);
//
//
//    if (!canTranslate)
//    {
//        if (translating == GOING_RIGHT)
//        {
//            if (translation.x > 0 && translation.x < previous.x && translation.x < TRIGGER_ACCELERATION/2)
//            {
//                canTranslate = YES;
//                CCLOG(@"RIGHT DECELERATION ACCOUNTED FOR!");
//            }
//            //            if (translation.x > -0.8 * trigger.x) canTranslate = YES;
//        }
//        else if (translating == GOING_LEFT)
//        {
//            if (translation.x < 0 && translation.x > previous.x && translation.x > -TRIGGER_ACCELERATION/2)
//            {
//                canTranslate = YES;
//                CCLOG(@"LEFT DECELERATION ACCOUNTED FOR!");
//            }
//            //            if (translation.x < -0.8 * trigger.x) canTranslate = YES;
//        }
//        else if (translating == GOING_DOWN)
//        {
//            if (translation.y < 0 && translation.y > previous.y && translation.y > -TRIGGER_ACCELERATION/2)
//            {
//                canTranslate = YES;
//                CCLOG(@"DOWN DECELERATION ACCOUNTED FOR!");
//            }
//            //            if (translation.y < -0.8 * trigger.y) canTranslate = YES;
//        }
//        else if (translating == GOING_UP)
//        {
//            if (translation.y > 0 && translation.y < previous.y && translation.y < TRIGGER_ACCELERATION/2)
//            {
//                canTranslate = YES;
//                CCLOG(@"UP DECELERATION ACCOUNTED FOR!");
//            }
//            //            if (translation.y > -0.8 * trigger.y) canTranslate = YES;
//        }
//    }
//
//
//    // HERE WE WANT TO INSERT SOME CODE ABOUT SUSTAINED TRANSLATION
//    // RATHER THAN JUST HITTING A PEAK
//
//
//    if (!canTranslate) return;
//
//    if (translation.x > TRIGGER_ACCELERATION && snakeHead.facing != RIGHT)
//    {
//        trigger.x = translation.x;
//        translating = GOING_LEFT;
//        [self snakeFaceLeft];
//        canTranslate = NO;
//        CCLOG(@"TRANSLATE! LEFT!");
//
//    }
//    else if (translation.x < -TRIGGER_ACCELERATION && snakeHead.facing != LEFT)
//    {
//        trigger.x = translation.x;
//        translating = GOING_RIGHT;
//        [self snakeFaceRight];
//        canTranslate = NO;
//        CCLOG(@"TRANSLATE! RIGHT!");
//    }
//    else if (translation.y < -TRIGGER_ACCELERATION && snakeHead.facing != DOWN)
//    {
//        trigger.y = translation.y;
//        translating = GOING_UP;
//        [self snakeFaceUp];
//        canTranslate = NO;
//        CCLOG(@"TRANSLATE! UP!");
//    }
//    else if (translation.y > TRIGGER_ACCELERATION && snakeHead.facing != UP)
//    {
//        trigger.y = translation.y;
//        translating = GOING_DOWN;
//        [self snakeFaceDown];
//        canTranslate = NO;
//        CCLOG(@"TRANSLATE! DOWN!");
//    }
//
//    previous = translation;
//
//}


//- (void) handleInputNew:(ccTime)delta
//{
//    KKInput* input = [KKInput sharedInput];
//    //    KKAcceleration* acceleration = input.acceleration;
//    KKDeviceMotion* motion = input.deviceMotion;
//    KKAcceleration* acceleration = motion.acceleration;
//    
//    CGPoint a = CGPointMake(acceleration.rawX, acceleration.rawY);
//    CGPoint v = CGPointMake(((a.x + pa.x)/2 * delta + pv.x),((a.y + pa.y)/2 * delta + pv.y));
//    
//    if (a.x > 0.5 || a.x < -0.5 || a.y > 0.5 || a.y < -0.5)
//        CCLOG(@"delta=%f; v = (%f,%f); a = (%f,%f)",delta,v.x,v.y,a.x,a.y);
//    
//    if (a.x > -0.2 && a.x < 0.2) v.x = 0;
//    if (a.y > -0.2 && a.y < 0.2) v.y = 0;
//    
//    if (translating == NO_TRANSLATION)
//    {
//        if (v.x > MIN_TRANSLATION_VELOCITY)
//        {
//            CCLOG(@"... started LEFT");
//            translating = GOING_LEFT;
//        }
//        else if (v.x < -MIN_TRANSLATION_VELOCITY)
//        {
//            CCLOG(@"... started RIGHT");
//            translating = GOING_RIGHT;
//        }
//        else if (v.y < -MIN_TRANSLATION_VELOCITY)
//        {
//            CCLOG(@"... started UP");
//            translating = GOING_UP;
//        }
//        else if (v.y > MIN_TRANSLATION_VELOCITY)
//        {
//            CCLOG(@"... started DOWN");
//            translating = GOING_DOWN;
//        }
//        
//        if (translating != NO_TRANSLATION) translateElapsed = 0;
//    }
//    
//    
//    if (translating == GOING_LEFT)
//    {
//        if (v.x > MIN_TRANSLATION_VELOCITY)
//        {
//            translateElapsed += delta;
//            if (translateElapsed >= MIN_TRANSLATE_TIME)
//            {
//                CCLOG(@"... turned LEFT");
//                [self snakeFaceLeft];
//                translating = NO_TRANSLATION;
//            }
//        }
//        else
//        {
//            CCLOG(@"... cancelled LEFT");
//            translating = NO_TRANSLATION;
//        }
//    }
//    else if (translating == GOING_RIGHT)
//    {
//        if (v.x < -MIN_TRANSLATION_VELOCITY)
//        {
//            translateElapsed += delta;
//            if (translateElapsed >= MIN_TRANSLATE_TIME)
//            {
//                CCLOG(@"... turned RIGHT");
//                [self snakeFaceRight];
//                translating = NO_TRANSLATION;
//            }
//        }
//        else
//        {
//            CCLOG(@"... cancelled RIGHT");
//            translating = NO_TRANSLATION;
//        }
//    }
//    else if (translating == GOING_UP)
//    {
//        if (v.y < -MIN_TRANSLATION_VELOCITY)
//        {
//            translateElapsed += delta;
//            if (translateElapsed >= MIN_TRANSLATE_TIME)
//            {
//                CCLOG(@"... turned UP");
//                [self snakeFaceUp];
//                translating = NO_TRANSLATION;
//            }
//        }
//        else
//        {
//            CCLOG(@"... cancelled UP");
//            translating = NO_TRANSLATION;
//        }
//    }
//    else if (translating == GOING_DOWN)
//    {
//        if (v.y > MIN_TRANSLATION_VELOCITY)
//        {
//            translateElapsed += delta;
//            if (translateElapsed >= MIN_TRANSLATE_TIME)
//            {
//                CCLOG(@"... turned DOWN");
//                [self snakeFaceDown];
//                translating = NO_TRANSLATION;
//            }
//        }
//        else
//        {
//            CCLOG(@"... cancelled DOWN");
//            translating = NO_TRANSLATION;
//        }
//    }
//    
//    pv = v;
//    pa = a;
//}


- (void) showTutorial
{
    [super showTutorial];
    
    // TEXT
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSString* instructionsString = @"Thrust the device smoothly\nin the direction you\nwant Snek to move.";
    
    CCLabelTTF* instructionsText = [CCLabelTTF labelWithString:instructionsString fontName:@"Helvetica" fontSize:gridUnitInPixels];
    [tutorialNode addChild:instructionsText];
    instructionsText.position = CGPointMake(size.width/2,size.height - gridUnitInPixels*3);
    
    CCLabelTTF* continueText =  [CCLabelTTF labelWithString:@"Touch to continue." fontName:@"Helvetica" fontSize:gridUnitInPixels * 0.75];
    [tutorialNode addChild:continueText];
    continueText.position = CGPointMake(size.width/2,0 + gridUnitInPixels);
    
    
    // ANIMATION
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ThrustInstructions.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"ThrustInstructions.png"];
    
    [tutorialNode addChild:spriteSheet];
    NSMutableArray *startLoopFrames = [NSMutableArray array];
    for (int i=1; i<=7; i++) {
        [startLoopFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekThrustInstructions%d.png",i]]];
    }
    CCAnimation *startAnimation = [CCAnimation
                                   animationWithSpriteFrames:startLoopFrames delay:moveTime];
    
    NSMutableArray *thrustFrames = [NSMutableArray array];
    for (int i=8; i<=9; i++)
    {
        [thrustFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekThrustInstructions%d.png",i]]];
    }
    CCAnimation* thrustAnimation = [CCAnimation
                                    animationWithSpriteFrames:thrustFrames delay:moveTime];
    
    
    NSMutableArray *postThrustLoop = [NSMutableArray array];
    for (int i=10; i<=14; i++)
    {
        [postThrustLoop addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"SnekThrustInstructions%d.png",i]]];
    }
    CCAnimation* postThrustAnimation = [CCAnimation
                                        animationWithSpriteFrames:postThrustLoop delay:moveTime];
    
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite* animSprite = [CCSprite spriteWithSpriteFrameName:@"SnekThrustInstructions1.png"];
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
