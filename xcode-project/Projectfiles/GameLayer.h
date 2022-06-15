//
//  GameLayer.h
//  Snayke
//
//  Created by Pippin Barr on 13/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Typedefs.h"
#import "SnakeSegment.h"
#import "GameKitHelper.h"



static const NSUInteger START_LEVEL = 1;
static const int TOTAL_LEVELS = 5;
static const int PATTERNS_PER_LEVEL = 10;
static const int PATTERN_SIZE = 13;

static const float STARTING_MOVE_TIME = 0.2f;
static const int STARTING_SEGMENTS = 5;
static const int SEGMENTS_TO_ADD = 3;

//static const int APPLES_PER_DRUM_APPLE = 4;
//static const int APPLES_PER_LEVEL = 20;

static const int APPLES_PER_DRUM_APPLE = 5;
static const int APPLES_PER_LEVEL = 20;

static const float APPLE_SAFE_TIME = 7.0f;
static const float APPLE_FLASHING_TIME = 3.0f;

static const float SNAKE_HEAD_FLASH_TIME = 1.0f;

static const int TICKS_PER_BAR = 16;

static const ccColor3B ccSCORE_COLOR = {255,255,255};
static const ccColor3B ccMULTIPLIER_COLOR = {255,255,255};


static const NSUInteger APPLE_POINTS = 10;
static const NSUInteger DRUM_APPLE_POINTS = 100;
static const NSUInteger MAX_MULTIPLIER = 64;

@interface GameLayer : CCLayer<GameKitHelperProtocol>
{
    State state;
    
    // Information
    float elapsed;
    BOOL gameIsOver;
    
    float moveTime;
    
    // THE GRID
    int gridUnitInPixels;
    CGRect grid;
    CGRect gridInTiles;
    
    // SNAKE
    Facing nextDir;
    SnakeSegment* snakeHead;
    NSMutableArray* snakeBodyArray;
    CCSpriteBatchNode* snakeBodySprites;
    
    int segmentsToAdd;
    
    // APPLE
    NSUInteger applesEaten;
    CCSprite* apple;
    CCSprite* drumApple;
    CCSprite* warpApple;

    // PATTERN
    NSUInteger level;
    NSMutableArray* obstacles;
    CCSpriteBatchNode* patternSprites;
    
    // MENU
    CCNode* gameOverMenu;
    CCNode* pauseMenu;
    
    CCNode* tutorialNode;
    CCNode* levelClearNode;
    
    // SOUND
    NSUInteger drumIndex;
    
    
    NSMutableArray* musicArray;
    
    
    int ticksThisBar;
    int ticksPerBar;
    float musicElapsed;
    float barLength;
    
    NSArray* toneFiles;
    NSArray* drumFiles;
    NSMutableArray* musicSounds;
        
    // SCORE
    NSUInteger latestScore;
    NSUInteger hiscore;
    NSUInteger startingHighScore;
    NSUInteger score;
    NSUInteger multiplier;
    CCLabelTTF* scoreText;
    CCLabelTTF* multiplierText;
    
    NSString* highScoreKey;
    NSString* latestScoreKey;
}


+ (id) scene;
- (void) handleInput;
- (void) snakeFaceUp;
- (void) snakeFaceDown;
- (void) snakeFaceLeft;
- (void) snakeFaceRight;
- (void) snakeTurnCW;
- (void) snakeTurnCCW;
- (void) checkCollisions;
- (void) gameOver;
- (void) showTutorial;
- (void) move;
- (void) handleAppleEating;
- (void) handleDrumAppleEating;
- (void) handleWarpAppleEating;
- (void) warpAppleMove;


@end
