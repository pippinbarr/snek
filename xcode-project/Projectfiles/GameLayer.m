//
//  GameLayer.m
//  Snayke
//
//  Created by Pippin Barr on 13/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "MenuLayer.h"
#import "SimpleAudioEngine.h"

#import "SnekMenuItemFont.h"
#import "SnekMenuItemSprite.h"


@interface GameLayer (PrivateMethods)

@end


@implementation GameLayer

+ (id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [GameLayer node];
    
    [scene addChild:layer];
    
    return scene;
}


- (id) init
{
    if ( self = [super init] )
    {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        
        //        GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
        //        gkHelper.delegate = self;
        //        [gkHelper authenticateLocalPlayer];
        
        
        // INFORMATION
        
        CCSprite* gridUnitSprite = [CCSprite spriteWithFile:@"TempHead.png"];
        CGSize size = [[CCDirector sharedDirector] winSize];
        //        gridUnitInPixels = gridUnitSprite.texture.contentSize.width;
        gridUnitInPixels = gridUnitSprite.contentSize.width;
        
        CCLOG(@"Set gridUnitInPixels to %i",gridUnitInPixels);
        
        int gridWidthInUnits = floor(size.width / gridUnitInPixels);
        if (gridWidthInUnits % 2 == 0) gridWidthInUnits--;
        int gridHeightInUnits = floor(size.height / gridUnitInPixels) - 2;
        float gridXOffset = (size.width - (gridWidthInUnits * gridUnitInPixels))/2;
        float gridYOffset = (size.height - (gridHeightInUnits * gridUnitInPixels))/2;
        
        grid = CGRectMake(gridXOffset,gridYOffset,gridWidthInUnits*gridUnitInPixels,gridHeightInUnits*gridUnitInPixels);
        
        gridInTiles = CGRectMake(0,0,gridWidthInUnits,gridHeightInUnits);
        
        
        
        CCLOG(@"Grid is %fx%f",grid.size.width,grid.size.height);
        CCLOG(@"Grid in tiles is is %fx%f",gridInTiles.size.width,gridInTiles.size.height);
        
        
        moveTime = STARTING_MOVE_TIME;
        
        // BACKGROUND
        
        CCLayerColor* gridBG = [CCLayerColor layerWithColor:ccc4(50,50,50,255) width:grid.size.width height:grid.size.height];
        gridBG.position = CGPointMake(grid.origin.x,grid.origin.y);
        //        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(50,50,50,255)];
        [self addChild:gridBG z:-1000];
        
        
        // INPUT
        
        [self setTouchEnabled:YES];
        
        
        // SPRITES
        
        snakeHead = [SnakeSegment spriteWithFile:@"TempHead.png"];
        snakeHead.anchorPoint = CGPointMake(0.0f,0.0f);
        
        snakeBodyArray = [NSMutableArray array];
        snakeBodySprites = [CCSpriteBatchNode batchNodeWithFile:@"TempBody.png"];
        [self addChild:snakeBodySprites];
        
        patternSprites = [CCSpriteBatchNode batchNodeWithFile:@"PatternSegment.png"];
        [self addChild:patternSprites];
        
        obstacles = [NSMutableArray array];
        apple = [CCSprite spriteWithFile:@"apple.png"];
        apple.anchorPoint = CGPointMake(0,0);
        drumApple = [CCSprite spriteWithFile:@"drumapple.png"];
        drumApple.anchorPoint = CGPointMake(0,0);
        warpApple = [CCSprite spriteWithFile:@"BlackHole.png"];
        warpApple.anchorPoint = CGPointMake(0,0);
        
        [self addChild:snakeHead];
        [self addChild:apple];
        [self addChild:drumApple];
        [self addChild:warpApple];
        
        [self addUI];
        
        // SOUNDS
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"move.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"miss1.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"miss2.wav"];
        
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tone.wav"];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"kick.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"snare.wav"];
        
        drumFiles = [NSArray arrayWithObjects:@"kick.wav",@"snare.wav",nil];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"0.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"1.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"2.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"3.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"4.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"5.wav"];
        
        toneFiles = [NSArray arrayWithObjects:@"0.wav",@"1.wav",@"2.wav",@"3.wav",@"4.wav",@"5.wav",nil];
        
        
        musicSounds = [NSMutableArray array];
        
        
        [self scheduleUpdate];
        CCLOG(@"... scheduled update");
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        state = TUTORIAL;
        
        KKInput* input = [KKInput sharedInput];
        input.gestureTapEnabled = YES;
        
        [self showTutorial];
    }
    
    return self;
}


- (void) addUI
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    scoreText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%li",(unsigned long) score]
                                   fontName:@"Helvetica"
                                   fontSize:gridUnitInPixels * 0.75];
    
    float yOffset = grid.origin.y + grid.size.height + (size.height - (grid.origin.y + grid.size.height))/2;
    
    scoreText.position = CGPointMake(size.width - grid.origin.x - gridUnitInPixels,yOffset);
    scoreText.color = ccSCORE_COLOR;
    scoreText.anchorPoint = CGPointMake(1.0,0.5f);
    
    [self addChild:scoreText];
    
    multiplierText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"x%li",(unsigned long)multiplier]
                                        fontName:@"Helvetica"
                                        fontSize:gridUnitInPixels * 0.75];
    multiplierText.position = CGPointMake(0 + grid.origin.x + gridUnitInPixels,yOffset);
    multiplierText.color = ccMULTIPLIER_COLOR;
    multiplierText.anchorPoint = CGPointMake(0,0.5f);
    
    [self addChild:multiplierText];
    
    CCLabelTTF* exitText = [CCLabelTTF labelWithString:@"Double-tap center of screen for menu."
                                              fontName:@"Helvetica"
                                              fontSize:gridUnitInPixels/2];
    yOffset = (size.height - (grid.origin.y + grid.size.height))/2;
    exitText.position = CGPointMake(size.width/2,yOffset);
    exitText.color = ccSCORE_COLOR;
    exitText.anchorPoint = CGPointMake(0.5f,0.5f);
    
    [self addChild:exitText];
}



- (void) returnToGame:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [self resumeSchedulerAndActions];
    
    
    KKInput* input = [KKInput sharedInput];
    [input setGestureDoubleTapEnabled:YES];
    
    [self removeChild:pauseMenu];
    
    
    state = PLAY;
    
}



- (void) returnToMainMenu:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.delegate = nil;
    
    [[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
}


- (void) update:(ccTime)delta
{
    if (state != GAME_OVER)
        [self handleInput];
    
    if (state == PAUSE || state == GAME_OVER || state == TUTORIAL || state == LEVEL_CLEAR)
    {
        return;
    }
}


- (void) gameTick
{
    if (state == PAUSE || state == GAME_OVER || state == LEVEL_CLEAR) return;
    
    if (state == PLAY)
    {
        [self move];
        [self checkCollisions];
        [self handleAppleEating];
        [self handleDrumAppleEating];
        [self handleWarpAppleEating];
    }
    else if (state == WARP_APPLE)
    {
        [self warpAppleMove];
    }
    
    [self handleMusic];
    
    
    if (warpApple.visible)
        warpApple.color = ccc3(150 + floor(CCRANDOM_0_1() * 155),150 + floor(CCRANDOM_0_1() * 155),150 + floor(CCRANDOM_0_1() * 155));
    
}



- (void) handleMusic
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    // Check if we've hit the end of the bar and reset if so
    ticksThisBar++;
    
    if (ticksThisBar == ticksPerBar)
    {
        ticksThisBar = 0;
    }
    
    NSMutableDictionary* musicDict = [musicArray objectAtIndex:ticksThisBar];
    
    for (id key in musicDict)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:key];
    }
}


- (void) handleInput
{
    KKInput* input = [KKInput sharedInput];
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if (state == PLAY && input.gestureDoubleTapRecognizedThisFrame)
    {
        if (input.gestureDoubleTapLocation.y < size.height * 0.80 &&
            input.gestureDoubleTapLocation.y > size.height * 0.20 &&
            input.gestureDoubleTapLocation.x < size.width * 0.80 &&
            input.gestureDoubleTapLocation.x > size.width * 0.20)
        {
            [input setGestureDoubleTapEnabled:NO];
            
            [self showPauseMenu];
        }
    }
    else if (state == TUTORIAL && input.gestureTapRecognizedThisFrame)
    {
        [self removeTutorial];
        input.gestureTapEnabled = NO;
        
        [self resetScoresAndGame];
    }
    else if (state == LEVEL_CLEAR && input.gestureTapRecognizedThisFrame)
    {
        input.gestureTapEnabled = NO;
        
        [self removeLevelClear];
        [self handleLevelComplete];
    }
}


- (void) move
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    double numSegments = [snakeBodyArray count];
    
    if (segmentsToAdd > 0)
    {
        SnakeSegment* lastSnakeSegment = [snakeBodyArray lastObject];
        SnakeSegment* newSegment = [SnakeSegment spriteWithFile:@"TempBody.png"];
        newSegment.anchorPoint = CGPointMake(0.0f,0.0f);
        if (lastSnakeSegment != nil)
            newSegment.position = lastSnakeSegment.position;
        else
            newSegment.position = snakeHead.position;
        
        [snakeBodyArray addObject:newSegment];
        [obstacles addObject:newSegment];
        [snakeBodySprites addChild:newSegment];
        
        segmentsToAdd--;
    }
    
    
    for (int i = numSegments - 1; i >= 0; i--)
    {
        SnakeSegment* segment = [snakeBodyArray objectAtIndex:i];
        if (i != 0)
        {
            SnakeSegment* nextSegment = [snakeBodyArray objectAtIndex:(i - 1)];
            segment.position = nextSegment.position;
        }
        else
        {
            segment.position = snakeHead.position;
        }
    }
    
    snakeHead.facing = nextDir;
    
    float posX = snakeHead.position.x;
    float posY = snakeHead.position.y;
    
    if (snakeHead.facing == RIGHT)
    {
        posX += gridUnitInPixels;
    }
    else if (snakeHead.facing == LEFT)
    {
        posX -= gridUnitInPixels;
    }
    else if (snakeHead.facing == UP)
    {
        posY += gridUnitInPixels;
    }
    else if (snakeHead.facing == DOWN)
    {
        posY -= gridUnitInPixels;
    }
    
    if (posX >= grid.origin.x + grid.size.width)
        posX = grid.origin.x;
    
    if (posX < grid.origin.x)
        posX = grid.origin.x + grid.size.width - gridUnitInPixels;
    
    if (posY >= grid.origin.y + grid.size.height)
        posY = grid.origin.y;
    
    if (posY < grid.origin.y)
        posY = grid.origin.y + grid.size.height - gridUnitInPixels;
    
    snakeHead.position = CGPointMake(posX,posY);
    
    elapsed = 0;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"move.wav"];
}



- (void) warpAppleMove
{
    double numSegments = [snakeBodyArray count];
    
    if (segmentsToAdd > 0)
    {
        SnakeSegment* lastSnakeSegment = [snakeBodyArray lastObject];
        SnakeSegment* newSegment = [SnakeSegment spriteWithFile:@"TempBody.png"];
        newSegment.anchorPoint = CGPointMake(0.0f,0.0f);
        if (lastSnakeSegment != nil)
            newSegment.position = lastSnakeSegment.position;
        else
            newSegment.position = snakeHead.position;
        
        [snakeBodyArray addObject:newSegment];
        [obstacles addObject:newSegment];
        [snakeBodySprites addChild:newSegment];
        
        segmentsToAdd--;
    }
    
    
    for (int i = numSegments - 1; i >= 0; i--)
    {
        SnakeSegment* segment = [snakeBodyArray objectAtIndex:i];
        
        if (segment.position.x == warpApple.position.x &&
            segment.position.y == warpApple.position.y)
        {
            segment.visible = false;
        }
        
        if (i != 0)
        {
            SnakeSegment* nextSegment = [snakeBodyArray objectAtIndex:(i - 1)];
            segment.position = nextSegment.position;
        }
        else
        {
            segment.position = snakeHead.position;
        }
    }
    
    if (snakeHead.position.x == warpApple.position.x &&
        snakeHead.position.y == warpApple.position.y)
    {
        snakeHead.visible = false;
    }
    
    elapsed = 0;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"move.wav"];
    
    
    BOOL allInvisible = YES;
    for (SnakeSegment* s in snakeBodyArray)
    {
        if (s.visible)
        {
            allInvisible = NO;
            break;
        }
    }
    
    if (allInvisible)
    {
        state = LEVEL_CLEAR;
        [self showLevelClear];
    }
}




- (void) checkCollisions
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    for (SnakeSegment* s in obstacles)
    {
        if (snakeHead.position.x == s.position.x &&
            snakeHead.position.y == s.position.y)
        {
            [self handleSnakeCrash];
            return;
        }
    }
}


- (void) handleSnakeCrash
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.wav"];
    
    [self unschedule:@selector(gameTick)];
    
    [self schedule:@selector(snakeHeadFlash) interval:moveTime/2 repeat:101 delay:0];
    [self schedule:@selector(gameOver) interval:SNAKE_HEAD_FLASH_TIME];
}


- (void) gameOver
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    [self unscheduleAllSelectors];
    [self scheduleUpdate];
    
    [self showGameOverMenu];
    
    state = GAME_OVER;
}


- (void) resetGame
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    // SNAKE
    
    int startX = grid.origin.x + floor(gridInTiles.size.width / 2) * gridUnitInPixels;
    snakeHead.position = CGPointMake(startX,grid.origin.y + gridUnitInPixels);
    snakeHead.facing = UP;
    snakeHead.visible = YES;
    snakeHead.opacity = 255;
    nextDir = UP;
    
    [snakeBodyArray removeAllObjects];
    [snakeBodySprites removeAllChildren];
    
    [patternSprites removeAllChildren];
    
    warpApple.position = CGPointMake(-1000,-1000);
    warpApple.visible = NO;
    
    segmentsToAdd = STARTING_SEGMENTS;
    
    // STATS
    
    elapsed = 0;
    gameIsOver = NO;
    segmentsToAdd = STARTING_SEGMENTS;
    
    
    NSString *scoreDisplay = [NSNumberFormatter localizedStringFromNumber:@(score)
                                                              numberStyle:NSNumberFormatterDecimalStyle];
    [scoreText setString:scoreDisplay];
    
    NSString *multDisplay = [NSString stringWithFormat:@"x%li",(long int)multiplier];
    [multiplierText setString:multDisplay];
    
    
    // APPLE
    
    applesEaten = 1;
    
    // OBSTACLES
    
    for (SnakeSegment* s in obstacles)
    {
        [self removeChild:s];
    }
    
    [obstacles removeAllObjects];
    
    
    // MUSIC
    
    ticksThisBar = 0;
    ticksPerBar = TICKS_PER_BAR;
    
    musicArray = [NSMutableArray array];
    for (int i = 0; i < ticksPerBar; i++)
        [musicArray addObject:[NSMutableDictionary dictionary]];
    
    [musicSounds removeAllObjects];
    
    // STATE
    
    state = PLAY;
    
    [self addPattern];
    
    [self unscheduleAllSelectors];
    
    [self placeApple];
    
    [self schedule:@selector(gameTick) interval:moveTime];
    [self scheduleUpdate];
    
    KKInput* input = [KKInput sharedInput];
    
    input.gestureDoubleTapEnabled = YES;    
}




- (void) placeApple
{
    if (applesEaten % APPLES_PER_DRUM_APPLE == 0)
    {
        CCLOG(@"%@: %@ (drum)", NSStringFromSelector(_cmd), self);
        
        // Move the apple off screen
        apple.position = CGPointMake(-1000,-1000);
        
        // Move the apple to a random location
        drumApple.position = [self getRandomApplePosition];
        drumApple.opacity = 255;
    }
    else
    {
        CCLOG(@"%@: %@ (apple)", NSStringFromSelector(_cmd), self);
        
        // Move the drum apple off screen
        drumApple.position = CGPointMake(-1000,-1000);
        
        // Move the apple to a random location
        apple.position = [self getRandomApplePosition];
        apple.opacity = 255;
    }
    
    [self unschedule:@selector(appleFail)];
    [self unschedule:@selector(appleFlash)];
    
    [self schedule:@selector(appleFlash) interval:moveTime/2 repeat:101 delay:APPLE_SAFE_TIME];
    [self schedule:@selector(appleFail) interval:(APPLE_SAFE_TIME + APPLE_FLASHING_TIME)];
}


- (void) appleFail
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [self unschedule:_cmd];
    
    // Reset the multipler
    multiplier = 1;
    NSString *multDisplay = [NSString stringWithFormat:@"x%li",(long int)multiplier];
    [multiplierText setString:multDisplay];
    
    apple.opacity = 255;
    drumApple.opacity = 255;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"miss1.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:@"miss2.wav"];
    
    // And place the apple somewhere else
    [self placeApple];
}


- (void) appleFlash
{
    //    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    if (applesEaten % APPLES_PER_DRUM_APPLE == 0)
    {
        if (drumApple.opacity == 255)
        {
            drumApple.opacity = 1;
            [[SimpleAudioEngine sharedEngine] playEffect:@"miss1.wav"];
        }
        else
        {
            drumApple.opacity = 255;
            [[SimpleAudioEngine sharedEngine] playEffect:@"miss2.wav"];
        }
    }
    else
    {
        if (apple.opacity == 255)
        {
            apple.opacity = 1;
            [[SimpleAudioEngine sharedEngine] playEffect:@"miss1.wav"];
        }
        else
        {
            apple.opacity = 255;
            [[SimpleAudioEngine sharedEngine] playEffect:@"miss2.wav"];
        }
    }
}



- (void) snakeHeadFlash
{
    snakeHead.opacity = (255 - snakeHead.opacity);
}


- (void) addToScore:(NSUInteger)points
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    score += (multiplier * points);
    NSString *scoreDisplay = [NSNumberFormatter localizedStringFromNumber:@(score)
                                                              numberStyle:NSNumberFormatterDecimalStyle];
    [scoreText setString:scoreDisplay];
    
    if (score > hiscore)
    {
        hiscore = score;
        [[NSUserDefaults standardUserDefaults] setInteger:hiscore forKey:highScoreKey];
    }
}


- (void) handleAppleEating
{
    if (snakeHead.position.x == apple.position.x &&
        snakeHead.position.y == apple.position.y)
    {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        applesEaten++;
        
        [self placeApple];
        
        segmentsToAdd = SEGMENTS_TO_ADD;
        
        [self addToScore:APPLE_POINTS];
        [self increaseMultiplier];
        
        // Add a tone to musicSound
        CCLOG(@"apple .. Getting dictionary at index %i...",ticksThisBar);
        NSMutableDictionary* currentDict = [musicArray objectAtIndex:ticksThisBar];
        NSString* key = [self getRandomToneFile];
        CCLOG(@"apple .. Got music file %@",key);
        [currentDict setValue:[NSNumber numberWithBool:YES] forKey:key];
        CCLOG(@"apple .. Added to dictionary");
        
        [[SimpleAudioEngine sharedEngine] playEffect:key];
    }
}


-(void) increaseMultiplier
{
    multiplier *= 2;
    if (multiplier > MAX_MULTIPLIER) multiplier = MAX_MULTIPLIER;
    NSString *multDisplay = [NSString stringWithFormat:@"x%li",(long int)multiplier];
    [multiplierText setString:multDisplay];
}

- (NSString*) getRandomToneFile
{
    NSUInteger numTones = [toneFiles count];
    NSUInteger i = floor(CCRANDOM_0_1() * numTones);
    return [toneFiles objectAtIndex:i];
}


- (void) handleDrumAppleEating
{
    if (snakeHead.position.x == drumApple.position.x &&
        snakeHead.position.y == drumApple.position.y)
    {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        applesEaten++;
        
        segmentsToAdd = SEGMENTS_TO_ADD;
        
        [self addToScore:DRUM_APPLE_POINTS];
        [self increaseMultiplier];
        
        // Move drum apple off screen
        
        drumApple.position = CGPointMake(-1000,-1000);
        
        CCLOG(@"drum .. Getting dictionary at index %i...",ticksThisBar);
        NSMutableDictionary* currentDict = [musicArray objectAtIndex:ticksThisBar];
        NSString* key = [self getRandomDrumFile];
        CCLOG(@"drum .. Got music file %@",key);
        [currentDict setValue:[NSNumber numberWithBool:YES] forKey:key];
        CCLOG(@"drum .. Added to dictionary");
        [[SimpleAudioEngine sharedEngine] playEffect:key];
        
        if (applesEaten >= APPLES_PER_LEVEL)
        {
            [self addWarpApple];
            return;
        }
        else
        {
            [self placeApple];
        }
    }
}


- (void) addWarpApple
{
    [self unschedule:@selector(appleFlash)];
    [self unschedule:@selector(appleFail)];
    
    warpApple.position = [self getRandomApplePosition];
    warpApple.visible = YES;
}


-(void) handleWarpAppleEating
{
    if (snakeHead.position.x == warpApple.position.x &&
        snakeHead.position.y == warpApple.position.y)
    {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

        state = WARP_APPLE;
        
        [self unschedule:@selector(gameTick)];
        [self schedule:@selector(gameTick) interval:STARTING_MOVE_TIME/4];
    }
}


- (void) handleLevelComplete
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    level++;
    if (level >= TOTAL_LEVELS)
    {
        level = START_LEVEL;
        moveTime -= 0.01;
    }
    
    [self resetGame];
}


- (NSString*) getRandomDrumFile
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    NSUInteger numDrums = [drumFiles count];
    NSUInteger i = floor(CCRANDOM_0_1() * numDrums);
    return [drumFiles objectAtIndex:i];
}


- (CGPoint) getRandomApplePosition
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    //    CGSize size = [CCDirector sharedDirector].winSize;
    CGPoint pos = snakeHead.position;
    BOOL freePositionFound = NO;
    
    double numSegments = [snakeBodyArray count];
    
    if (numSegments + 1 >= gridInTiles.size.width * gridInTiles.size.height)
        return CGPointMake(-gridUnitInPixels,-gridUnitInPixels);
    
    while (!freePositionFound)
    {
        freePositionFound = YES;
        pos = CGPointMake(grid.origin.x + floor(CCRANDOM_0_1() * (gridInTiles.size.width - 1)) * gridUnitInPixels,
                          grid.origin.y + floor(CCRANDOM_0_1() * (gridInTiles.size.height - 1)) * gridUnitInPixels);
        
        for (CCSprite* s in obstacles)
        {
            if (pos.x == s.position.x && pos.y == s.position.y)
            {
                freePositionFound = NO;
                continue;
            }
        }
        
        if (pos.x == snakeHead.position.x && pos.y == snakeHead.position.y)
        {
            freePositionFound = NO;
            continue;
        }
    }
    
    return pos;
}

- (void) snakeTurnCW
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if (snakeHead.facing == LEFT) nextDir = UP;
    else if (snakeHead.facing == UP) nextDir = RIGHT;
    else if (snakeHead.facing == RIGHT) nextDir = DOWN;
    else if (snakeHead.facing == DOWN) nextDir = LEFT;
}


- (void) snakeTurnCCW
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if (snakeHead.facing == LEFT) nextDir = DOWN;
    else if (snakeHead.facing == UP) nextDir = LEFT;
    else if (snakeHead.facing == RIGHT) nextDir = UP;
    else if (snakeHead.facing == DOWN) nextDir = RIGHT;
    
}


- (void) snakeFaceUp
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if (snakeHead.facing != DOWN)
        nextDir = UP;
}


- (void) snakeFaceDown
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if (snakeHead.facing != UP)
        nextDir = DOWN;
}


- (void) snakeFaceLeft
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if (snakeHead.facing != RIGHT)
        nextDir = LEFT;
}


- (void) snakeFaceRight
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if (snakeHead.facing != LEFT)
        nextDir = RIGHT;
}





/******************** PATTERNS ***********************/


- (void) addPattern
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    if (level == START_LEVEL) return;
    
    int levelPattern = floor(CCRANDOM_0_1() * PATTERNS_PER_LEVEL) + 1;
    NSString* filename = [NSString stringWithFormat:@"%li-%i",(unsigned long)level,levelPattern];
    
    CCLOG(@"filename: %@",filename);
    
    NSString* path = [[NSBundle mainBundle] pathForResource:filename
                                                     ofType:@"pbm"];
    NSError *error = nil;
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    
    
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    CCLOG(@"File string:\n%@",content);
    NSArray* positions = [content componentsSeparatedByString:@" "];
    
    
    if ([[CCDirector sharedDirector] currentPlatformIsIOS])
    {
        float offsetX = grid.origin.x + ((floor(gridInTiles.size.width/2) * gridUnitInPixels) - (floor(PATTERN_SIZE/2) * gridUnitInPixels));
        float offsetY = grid.origin.y + ((floor(gridInTiles.size.height/2) * gridUnitInPixels) - (floor(PATTERN_SIZE/2) * gridUnitInPixels));
        
        CCLOG(@"Pattern offset is (%f,%f)",offsetX,offsetY);
        
        for (int y = 0; y < PATTERN_SIZE; y++)
        {
            for (int x = 0; x < PATTERN_SIZE; x++)
            {
                // CCLOG(@"... checking if next obstacle is solid.");
                
                long index = y*(PATTERN_SIZE) + x;
                NSNumber* value = [positions objectAtIndex:index + 3]; // offset by three to avoid the first three stats in file
                
                if (value.intValue == 1)
                {
                    CCSprite* patternSprite = [CCSprite spriteWithFile:@"PatternSegment.png"];
                    patternSprite.anchorPoint = CGPointMake(0,0);
                    patternSprite.position = CGPointMake(offsetX + x*gridUnitInPixels,
                                                         offsetY + y*gridUnitInPixels);
                    patternSprite.zOrder = -10;
                    
                    [obstacles addObject:patternSprite];
                    
                    [patternSprites addChild:patternSprite];
                    
                    //                    CCLOG(@"... added obstacle segment.");
                }
            }
        }
    }
    else
    {
        for (int y = 0; y < 17; y++)
        {
            for (int x = 0; x < 10; x++)
            {
                //                CCLOG(@"... checking if next obstacle is solid.");
                
                long index = y*(10) + x;
                NSNumber* value = [positions objectAtIndex:index + 3];
                if (value.intValue == 1)
                {
                    CCSprite* patternSprite = [CCSprite spriteWithFile:@"PatternSegment.png"];
                    patternSprite.anchorPoint = CGPointMake(0,0);
                    patternSprite.position = CGPointMake(y*gridUnitInPixels,
                                                         (gridInTiles.size.height-1)*gridUnitInPixels - x*gridUnitInPixels);
                    patternSprite.zOrder = -10;
                    
                    [obstacles addObject:patternSprite];
                    [self addChild:patternSprite];
                    
                    //                    CCLOG(@"... added obstacle segment.");
                }
            }
        }
    }
    
}



- (void) restartGame:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [self removeChild:gameOverMenu];
    
    [self resetScoresAndGame];
}



- (void) resetScoresAndGame
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    score = 0;
    latestScore = [[NSUserDefaults standardUserDefaults] integerForKey:latestScoreKey];
    hiscore = [[NSUserDefaults standardUserDefaults] integerForKey:highScoreKey];
    startingHighScore = hiscore;
    multiplier = 1;
    NSString *multDisplay = [NSString stringWithFormat:@"x%li",(long int)multiplier];
    [multiplierText setString:multDisplay];
    
    level = START_LEVEL;
    moveTime = STARTING_MOVE_TIME;
    
    [self resetGame];
}


/******** MENU CODE ********/


- (void) showPauseMenu
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if (state == PAUSE || state == GAME_OVER || state == LEVEL_CLEAR) return;
    
    state = PAUSE;

    [self pauseSchedulerAndActions];
    
    pauseMenu = [CCNode node];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    

    
    // MENU WITH BUTTONS
    
    CCMenu* menu;
    CCSprite* normalSprite = [CCSprite spriteWithFile:@"menuItem.png"];
    
    [CCMenuItemFont setFontName:@"Helvetica-Bold"];
    [CCMenuItemFont setFontSize:normalSprite.contentSize.height / 3];
    
    


    SnekMenuItemSprite* resumeItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(returnToGame:) color:ccc3(254,221,191) highlight:YES];
    [resumeItem addLabel:@"Resume."];
    
    SnekMenuItemSprite* mainMenuItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(returnToMainMenu:) color:ccc3(208,192,255) highlight:YES];
    [mainMenuItem addLabel:@"Menu."];
    
    float verticalPadding = resumeItem.contentSize.height/4;
    
    menu = [CCMenu menuWithItems:resumeItem,mainMenuItem,nil];
    
    [menu alignItemsVerticallyWithPadding:verticalPadding];
    
    menu.position = CGPointMake(winSize.width/2,winSize.height/3);
    
    
    
    
    
    // LABELS
    
    NSString *modeString = @"Snek is paused.";
    
    NSString *scoreFormattedString = [NSNumberFormatter localizedStringFromNumber:@(score)
                                                                      numberStyle:NSNumberFormatterDecimalStyle];
    
    NSString* scoreString = [NSString stringWithFormat:@"%@ points.",scoreFormattedString];
    
    //    NSUInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:highScoreKey];
    NSString *highScoreFormattedString = [NSNumberFormatter localizedStringFromNumber:@(startingHighScore)
                                                                          numberStyle:NSNumberFormatterDecimalStyle];
    
    NSString* highScoreString;
    if (score > startingHighScore)
        highScoreString = [NSString stringWithFormat:@"New high score."];
    else
        highScoreString = [NSString stringWithFormat:@"High score is\n%@ points.",highScoreFormattedString];
    
    
    CCLabelTTF* scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"Helvetica" fontSize:gridUnitInPixels * 1.2];
    scoreLabel.anchorPoint = CGPointMake(0.5, 0.5);
    scoreLabel.position = CGPointMake(winSize.width/2,winSize.height * 5/6);
    
    CCLabelTTF* modeLabel = [CCLabelTTF labelWithString:modeString fontName:@"Helvetica-Bold" fontSize:gridUnitInPixels * 1.2];
    modeLabel.anchorPoint = CGPointMake(0.5, 0);
    modeLabel.position = CGPointMake(winSize.width/2,scoreLabel.position.y + scoreLabel.contentSize.height/3);
    
    CCLabelTTF* highScoreLabel = [CCLabelTTF labelWithString:highScoreString fontName:@"Helvetica" fontSize:gridUnitInPixels * 0.8];
    highScoreLabel.anchorPoint = CGPointMake(0.5, 0.5);
    float highScoreY = scoreLabel.position.y - scoreLabel.contentSize.height*2;
    highScoreLabel.position = CGPointMake(winSize.width/2,highScoreY);
    
    
    
    
    // BACKGROUND
    
    CCLayerColor* layerColor = [CCLayerColor layerWithColor:ccc4(50,50,50,255)];
    
    [pauseMenu addChild:layerColor];
    [pauseMenu addChild:scoreLabel];
    [pauseMenu addChild:modeLabel];
    [pauseMenu addChild:highScoreLabel];
    [pauseMenu addChild:menu];
    
    
    [self addChild:pauseMenu];
    
    
}


- (void) showGameOverMenu
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [self unscheduleUpdate];
    [self unscheduleAllSelectors];
    
    gameOverMenu = [CCNode node];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    
    // MENU WITH BUTTONS
    
    CCMenu* menu;
    CCSprite* normalSprite = [CCSprite spriteWithFile:@"menuItem.png"];
    
    [CCMenuItemFont setFontName:@"Helvetica-Bold"];
    [CCMenuItemFont setFontSize:normalSprite.contentSize.height / 3];

    
    SnekMenuItemSprite* againItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(restartGame:) color:ccc3(253, 254, 191) highlight:YES];
    [againItem addLabel:@"Again."];
    
    SnekMenuItemSprite* mainMenuItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(returnToMainMenu:) color:ccc3(244, 192, 255) highlight:YES];
    [mainMenuItem addLabel:@"Menu."];
    
    float verticalPadding = againItem.contentSize.height/4;
    
    menu = [CCMenu menuWithItems:againItem,mainMenuItem,nil];
    
    [menu alignItemsVerticallyWithPadding:verticalPadding];
    
    menu.position = CGPointMake(winSize.width/2,winSize.height/3);
    
    
    
    
    
    // LABELS
    
    NSString *modeString = @"Snek is over.";
    
    NSString *scoreFormattedString = [NSNumberFormatter localizedStringFromNumber:@(score)
                                                                      numberStyle:NSNumberFormatterDecimalStyle];
    
    NSString* scoreString = [NSString stringWithFormat:@"%@ points.",scoreFormattedString];
    
    //    NSUInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:highScoreKey];
    NSString *highScoreFormattedString = [NSNumberFormatter localizedStringFromNumber:@(startingHighScore)
                                                                          numberStyle:NSNumberFormatterDecimalStyle];
    
    
    NSString* highScoreString;
    if (score > startingHighScore)
        highScoreString = [NSString stringWithFormat:@"New high score."];
    else
        highScoreString = [NSString stringWithFormat:@"High score is\n%@ points.",highScoreFormattedString];
    
    
    CCLabelTTF* scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"Helvetica" fontSize:gridUnitInPixels * 1.2];
    scoreLabel.anchorPoint = CGPointMake(0.5, 0.5);
    scoreLabel.position = CGPointMake(winSize.width/2,winSize.height * 5/6);
    
    CCLabelTTF* modeLabel = [CCLabelTTF labelWithString:modeString fontName:@"Helvetica-Bold" fontSize:gridUnitInPixels * 1.2];
    modeLabel.anchorPoint = CGPointMake(0.5, 0);
    modeLabel.position = CGPointMake(winSize.width/2,scoreLabel.position.y + scoreLabel.contentSize.height/3);
    
    CCLabelTTF* highScoreLabel = [CCLabelTTF labelWithString:highScoreString fontName:@"Helvetica" fontSize:gridUnitInPixels * 0.8];
    highScoreLabel.anchorPoint = CGPointMake(0.5, 0.5);
    float highScoreY = scoreLabel.position.y - scoreLabel.contentSize.height*2;
    highScoreLabel.position = CGPointMake(winSize.width/2,highScoreY);
    
    
    
    
    // BACKGROUND
    
    CCLayerColor* layerColor = [CCLayerColor layerWithColor:ccc4(50,50,50,255)];
    
    [gameOverMenu addChild:layerColor];
    [gameOverMenu addChild:scoreLabel];
    [gameOverMenu addChild:modeLabel];
    [gameOverMenu addChild:highScoreLabel];
    [gameOverMenu addChild:menu];
    
    
    [self addChild:gameOverMenu];
}



- (void) showLevelClear
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    levelClearNode = [CCNode node];
    [self addChild:levelClearNode];
    
    CCLayerColor* bg = [CCLayerColor layerWithColor:ccc4(100,100,100,255)];
    [levelClearNode addChild:bg];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSString* levelClearString = @"Level\nclear.";
    NSString* touchString = @"Touch to continue.";
    
    CCLabelTTF* levelClearText = [CCLabelTTF labelWithString:levelClearString fontName:@"Helvetica-Bold" fontSize:gridUnitInPixels*3];
    levelClearText.position = CGPointMake(size.width/2,size.height/2);
    
    CCLabelTTF* touchText = [CCLabelTTF labelWithString:touchString fontName:@"Helvetica" fontSize:gridUnitInPixels];
    touchText.position = CGPointMake(size.width/2,gridUnitInPixels*2);
    
    [levelClearNode addChild:levelClearText];
    [levelClearNode addChild:touchText];
    
    KKInput* input = [KKInput sharedInput];
    input.gestureTapEnabled = YES;
    
}



- (void) removeLevelClear
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [self removeChild:levelClearNode];
    levelClearNode = nil;
}


- (void) showTutorial
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    tutorialNode = [CCNode node];
    [self addChild:tutorialNode];
    
    // BACKGROUND
    
    CCLayerColor* bg = [CCLayerColor layerWithColor:ccc4(100,100,100,255)];
    [tutorialNode addChild:bg];    
}


- (void) removeTutorial
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [self removeChild:tutorialNode];
    tutorialNode = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPauseMenu)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
