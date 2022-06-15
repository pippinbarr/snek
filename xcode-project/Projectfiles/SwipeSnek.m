//
//  SwipeSnek.m
//  Snek
//
//  Created by Pippin Barr on 21/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SimpleAudioEngine.h"

#import "SwipeSnek.h"


@implementation SwipeSnek

+ (id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [SwipeSnek node];
    
    [scene addChild:layer];
    
    return scene;
}

- (id) init
{
    highScoreKey = @"SwipeHighScore";
    latestScoreKey = @"SwipeLatestScore";

    
    if ( self = [super init] )
    {
        KKInput* input = [KKInput sharedInput];
        [input setGestureSwipeEnabled:YES];
//        [input setGesturePanEnabled:YES];
        
        
        UISwipeGestureRecognizer* left = [input swipeGestureRecognizerForDirection:KKSwipeGestureDirectionLeft];
        if ([left initWithTarget:self action:@selector(leftSwipe:)])
        {
            [left setDirection:UISwipeGestureRecognizerDirectionLeft];
            [[[CCDirector sharedDirector] view] addGestureRecognizer:left];
        }
        
        UISwipeGestureRecognizer* right = [input swipeGestureRecognizerForDirection:KKSwipeGestureDirectionRight];
        if ([right initWithTarget:self action:@selector(rightSwipe:)])
        {
            [right setDirection:UISwipeGestureRecognizerDirectionRight];
            [[[CCDirector sharedDirector] view] addGestureRecognizer:right];
        }
        
        UISwipeGestureRecognizer* up = [input swipeGestureRecognizerForDirection:KKSwipeGestureDirectionUp];
        if ([up initWithTarget:self action:@selector(upSwipe:)])
        {
            [up setDirection:UISwipeGestureRecognizerDirectionUp];
            [[[CCDirector sharedDirector] view] addGestureRecognizer:up];
        }
        
        UISwipeGestureRecognizer* down = [input swipeGestureRecognizerForDirection:KKSwipeGestureDirectionDown];
        if ([down initWithTarget:self action:@selector(downSwipe:)])
        {
            [down setDirection:UISwipeGestureRecognizerDirectionDown];
            [[[CCDirector sharedDirector] view] addGestureRecognizer:down];
        }        

        
        // SNAKE
        
        snakeCanMove = YES;
        moved = NO;
        swipeRecognized = NO;        
    }
    
    return self;
}


- (void) update:(ccTime)delta
{
    [super update:delta];
        
    moved = NO;
    
    return;
}


#if TARGET_OS_IPHONE

- (void) leftSwipe:(UISwipeGestureRecognizer*)recognizer
{
//    CCLOG(@"LEFT");
    if (snakeHead.facing == UP) nextDir = LEFT;
    if (snakeHead.facing == DOWN) nextDir = LEFT;
    snakeCanMove = NO;
    swipeRecognized = YES;
}


- (void) rightSwipe:(UISwipeGestureRecognizer*)recognizer
{
//    CCLOG(@"RIGHT");
    if (snakeHead.facing == UP) nextDir = RIGHT;
    if (snakeHead.facing == DOWN) nextDir = RIGHT;
    snakeCanMove = NO;
    swipeRecognized = YES;
    
}


- (void) upSwipe:(UISwipeGestureRecognizer*)recognizer
{
//    CCLOG(@"UP");
    if (snakeHead.facing == LEFT) nextDir = UP;
    if (snakeHead.facing == RIGHT) nextDir = UP;
    snakeCanMove = NO;
    swipeRecognized = YES;
}


- (void) downSwipe:(UISwipeGestureRecognizer*)recognizer
{
//    CCLOG(@"DOWN");
    if (snakeHead.facing == LEFT) nextDir = DOWN;
    if (snakeHead.facing == RIGHT) nextDir = DOWN;
    snakeCanMove = NO;
    swipeRecognized = YES;
}






- (void) showTutorial
{
    [super showTutorial];
    
    // TEXT
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSString* instructionsString = @"Swipe your finger\nin the direction you wish\nSnek to turn.";
    
    CCLabelTTF* instructionsText = [CCLabelTTF labelWithString:instructionsString fontName:@"Helvetica" fontSize:gridUnitInPixels];
    [tutorialNode addChild:instructionsText];
    instructionsText.position = CGPointMake(size.width/2,size.height - gridUnitInPixels*2);
    
    CCLabelTTF* continueText =  [CCLabelTTF labelWithString:@"Touch to continue." fontName:@"Helvetica-Bold" fontSize:gridUnitInPixels];
    [tutorialNode addChild:continueText];
    continueText.position = CGPointMake(size.width/2,0 + gridUnitInPixels);
}


#endif


@end
