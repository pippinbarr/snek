//
//  MenuLayer.m
//  Snayke
//
//  Created by Pippin Barr on 16/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MenuLayer.h"
#import "SwipeSnek.h"
#import "RotateSnek.h"
#import "TranslateSnek.h"
#import "TiltSnek.h"

#import "SnekMenuItemFont.h"
#import "SnekMenuItemSprite.h"


@implementation MenuLayer

static NSDate* lastPreMenu;



+ (id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [MenuLayer node];
    
    [scene addChild:layer];
    
    return scene;
}


- (id) init
{
    if ( self = [super init] )
    {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(80,80,80,255)];
        [self addChild:colorLayer z:-1000];
        
        GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
        gkHelper.delegate = self;
        [gkHelper authenticateLocalPlayer];
        
        // INPUT
        
        //[self setTouchEnabled:YES];
        //[self setKeyboardEnabled:YES];
        
        
//        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"])
//        {
//            [self makePreMenu];
//            state = PRE_MENU;
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
//        }
//        else
//        {
//            [self makeMainMenu];
//            state = NORMAL_MENU;
//        }

        [self scheduleUpdate];
        
        [self makeMainMenu];
        state = NORMAL_MENU;

        
        // TESTING OUT SOMETHING
        

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doShowPreMenu)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];

    }
    
    return self;
}


- (void) doShowPreMenu
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if (state == PRE_MENU) return;
    
    if (lastPreMenu != nil)
        CCLOG(@"%f",[lastPreMenu timeIntervalSinceDate:[NSDate date]]);
    
    if (lastPreMenu != nil && [lastPreMenu timeIntervalSinceDate:[NSDate date]] > -3600)
    {
        // Do nothing
        CCLOG(@"Doing nothing.");
    }
    else
    {
        [self makePreMenu];
        state = PRE_MENU;
    }
}



-(void) makePreMenu
{
    preMenu = [CCNode node];
    
    CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(50,50,50,255)];
    [preMenu addChild:colorLayer z:-1000];
    
    CCSprite* sprite = [CCSprite spriteWithFile:@"TempHead.png"];
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCLabelTTF* text = [CCLabelTTF labelWithString:@"Snek.\n\nBest learned\nin private.\n\nBest played\nin public." fontName:@"Helvetica" fontSize:sprite.contentSize.height];
    text.position = CGPointMake(size.width/2,size.height/2);
    
    CCLabelTTF* continueText = [CCLabelTTF labelWithString:@"Touch to start." fontName:@"Helvetica" fontSize:sprite.contentSize.height/1.5];
    continueText.position = CGPointMake(size.width/2,sprite.contentSize.height);

    
    [preMenu addChild:text];
    [preMenu addChild:continueText];
    
    KKInput* input = [KKInput sharedInput];
    input.gestureTapEnabled = YES;
    
    [self addChild:preMenu];
}


-(void) removePreMenu
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    [self removeChild:preMenu];
    preMenu = nil;
    
    [self makeMainMenu];
    state = NORMAL_MENU;
    
    KKInput* input = [KKInput sharedInput];
    input.gestureTapEnabled = NO;
    
    lastPreMenu = [NSDate date];
}


- (void) update:(ccTime)delta
{
    [super update:delta];
    
    KKInput* input = [KKInput sharedInput];
    
    if (state == BACKUP_HIGH_SCORES && input.gestureTapRecognizedThisFrame)
    {
        [self hideBackupScoreMenu];
    }
    else if (state == PRE_MENU && input.gestureTapRecognizedThisFrame)
    {
        [self removePreMenu];
    }
    
}



- (void) showCredits:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}


- (void) startTiltSnek:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.delegate = nil;
    [[CCDirector sharedDirector] replaceScene:[TiltSnek scene]];
}


- (void) showScores:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    
    if (gkHelper.isGameCenterAvailable)
    {
        if (gkHelper.lastError == nil)
            [gkHelper showLeaderboard];
        else
            [self showBackupScoreMenu];
    }
    else
    {
        [self showBackupScoreMenu];
    }
}

- (void) startRotateSnek:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.delegate = nil;
    [[CCDirector sharedDirector] replaceScene:[RotateSnek scene]];
}

- (void) startTranslateSnek:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.delegate = nil;
    [[CCDirector sharedDirector] replaceScene:[TranslateSnek scene]];
}

- (void) startSwipeSnek:(id)sender
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.delegate = nil;
    [[CCDirector sharedDirector] replaceScene:[SwipeSnek scene]];
}




/******** MENU CODE ********/

- (void) makeMainMenu
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    CCMenu* menu;
    
    CCSprite* tempSprite = [CCSprite spriteWithFile:@"menuItem.png"];
    [CCMenuItemFont setFontName:@"Helvetica-Bold"];
    [CCMenuItemFont setFontSize:tempSprite.contentSize.height/2];
    CGSize size = [[CCDirector sharedDirector] winSize];


    
    
    SnekMenuItemSprite* swipeItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(startSwipeSnek:) color:ccc3(255,192,192) highlight:YES];
    [swipeItem addLabel:@"Swipe."];
    
    SnekMenuItemSprite* tiltItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(startTiltSnek:) color:ccc3(255,192,192) highlight:YES];
    [tiltItem addLabel:@"Tilt."];
    
    SnekMenuItemSprite* turnItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(startRotateSnek:) color:ccc3(215,253,190) highlight:YES];
    [turnItem addLabel:@"Turn."];
    
    SnekMenuItemSprite* thrustItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(startTranslateSnek:) color:ccc3(191,213,254) highlight:YES];
    [thrustItem addLabel:@"Thrust."];
    
    SnekMenuItemSprite* scoresItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(showScores:) color:ccc3(255,192,232) highlight:YES];
    [scoresItem addLabel:@"Scores."];
    
    float verticalPadding = tiltItem.contentSize.height/4;
    
    menu = [CCMenu menuWithItems:swipeItem,tiltItem,turnItem,thrustItem,scoresItem,nil];
//    menu = [CCMenu menuWithItems:tiltItem,turnItem,thrustItem,scoresItem,nil];
    
    [menu alignItemsVerticallyWithPadding:verticalPadding];
    
    menu.position = CGPointMake(size.width/2,size.height/2);
    
    [self addChild:menu];
    
    
    float menuHeight = tiltItem.contentSize.height * 4 + verticalPadding * 3;
    
    CCLabelTTF* titleLabel;
    titleLabel = [CCLabelTTF labelWithString:@"Snek." fontName:@"Helvetica-Bold" fontSize:tiltItem.contentSize.height/2];
    titleLabel.position = CGPointMake(size.width/2,size.height - (size.height - (menu.position.y + menuHeight/2))/2);

    [self addChild:titleLabel];
    
    
    // EDIT THIS TO HAVE A BG-COLOURED NORMAL menuItem.png SPRITE
    CCMenu* aboutMenu;
    CCLabelTTF* aboutLabel = [CCLabelTTF labelWithString:@"by Pippin Barr" fontName:@"Helvetica" fontSize:tempSprite.contentSize.height/4];
    aboutLabel.position = CGPointMake(size.width/2,tempSprite.contentSize.height/2);
//    SnekMenuItemFont* aboutItem = [SnekMenuItemFont itemWithLabel:aboutLabel target:self selector:@selector(doAbout)];
    
    SnekMenuItemSprite* aboutItem = [SnekMenuItemSprite spriteWithTarget:self selector:@selector(doAbout) color:ccc3(80,80,80) highlight:NO];
//    [aboutItem addLabel:@"by Pippin Barr"];
    [aboutItem addChild:aboutLabel];
    
    aboutMenu = [CCMenu menuWithItems:aboutItem, nil];
    aboutMenu.position = CGPointMake(size.width/2,tempSprite.contentSize.height/2);
    
    [self addChild:aboutMenu];
//    [self addChild:aboutLabel];
}


- (void) doAbout
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.pippinbarr.com/"]];
}



- (void) showBackupScoreMenu
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    backupScores = [CCNode node];
    [self addChild:backupScores];
    
    CCLayerColor* bg = [CCLayerColor layerWithColor:ccc4(100,100,100,255)];
    [backupScores addChild:bg];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSString* titleString = @"High scores.";
    
    
    NSUInteger turnHiscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"TurnHighScore"];
    NSString *turnHiscoreString = [NSString stringWithFormat:@"%@ points.",[NSNumberFormatter localizedStringFromNumber:@(turnHiscore)
                                                                                                            numberStyle:NSNumberFormatterDecimalStyle]];
    
    NSUInteger tiltHiscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"TiltHighScore"];
    NSString *tiltHiscoreString = [NSString stringWithFormat:@"%@ points.",[NSNumberFormatter localizedStringFromNumber:@(tiltHiscore)
                                                                                                            numberStyle:NSNumberFormatterDecimalStyle]];
    
    NSUInteger thrustHiscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"ThrustHighScore"];
    NSString *thrustHiscoreString = [NSString stringWithFormat:@"%@ points.",[NSNumberFormatter localizedStringFromNumber:@(thrustHiscore)
                                                                                                              numberStyle:NSNumberFormatterDecimalStyle]];
    
    
    CCSprite* sprite = [CCSprite spriteWithFile:@"menuItem.png"];
    float gridUnitInPixels = sprite.contentSize.height;
    
    CCLabelTTF* titleText = [CCLabelTTF labelWithString:titleString fontName:@"Helvetica-Bold" fontSize:gridUnitInPixels/2];
    titleText.position = CGPointMake(size.width/2,size.height * 7/8);
    
    float scoreItemFactor = 0.4;
    
    CCLabelTTF* tiltTitle = [CCLabelTTF labelWithString:@"Tilt." fontName:@"Helvetica-Bold" fontSize:gridUnitInPixels * scoreItemFactor];
    tiltTitle.position = CGPointMake(size.width/2,size.height * 7/10 + tiltTitle.contentSize.height/2);
    CCLabelTTF* tiltScore = [CCLabelTTF labelWithString:tiltHiscoreString fontName:@"Helvetica" fontSize:gridUnitInPixels * scoreItemFactor];
    tiltScore.position = CGPointMake(size.width/2,size.height * 7/10 - tiltTitle.contentSize.height/2);
    
    CCLabelTTF* turnTitle = [CCLabelTTF labelWithString:@"Turn." fontName:@"Helvetica-Bold" fontSize:gridUnitInPixels * scoreItemFactor];
    turnTitle.position = CGPointMake(size.width/2,size.height * 5/10 + turnTitle.contentSize.height/2);
    CCLabelTTF* turnScore = [CCLabelTTF labelWithString:turnHiscoreString fontName:@"Helvetica" fontSize:gridUnitInPixels * scoreItemFactor];
    turnScore.position = CGPointMake(size.width/2,size.height * 5/10 - turnTitle.contentSize.height/2);
    
    CCLabelTTF* thrustTitle = [CCLabelTTF labelWithString:@"Thrust." fontName:@"Helvetica-Bold" fontSize:gridUnitInPixels * scoreItemFactor];
    thrustTitle.position = CGPointMake(size.width/2,size.height * 3/10 + turnTitle.contentSize.height/2);
    CCLabelTTF* thrustScore = [CCLabelTTF labelWithString:thrustHiscoreString fontName:@"Helvetica" fontSize:gridUnitInPixels * scoreItemFactor];
    thrustScore.position = CGPointMake(size.width/2,size.height * 3/10 - turnTitle.contentSize.height/2);
    
    CCLabelTTF* continueText = [CCLabelTTF labelWithString:@"Touch to continue." fontName:@"Helvetica" fontSize:gridUnitInPixels/4];
    continueText.position = CGPointMake(size.width/2,size.height * 1/10);
    
    [backupScores addChild:titleText];
    [backupScores addChild:turnTitle];
    [backupScores addChild:turnScore];
    [backupScores addChild:tiltTitle];
    [backupScores addChild:tiltScore];
    [backupScores addChild:thrustTitle];
    [backupScores addChild:thrustScore];
    [backupScores addChild:continueText];
    
    KKInput* input = [KKInput sharedInput];
    input.gestureTapEnabled = YES;
    
    state = BACKUP_HIGH_SCORES;
}



- (void) hideBackupScoreMenu
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [self removeChild:backupScores];
    backupScores = nil;
    
    
    KKInput* input = [KKInput sharedInput];
    input.gestureTapEnabled = NO;
    
    state = NORMAL_MENU;
}

- (void) dealloc
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#if KK_PLATFORM_IOS
-(CGPoint) locationFromTouches:(NSSet *)touches
{
    UITouch *touch = touches.anyObject;
    CGPoint touchLocation = [touch locationInView:touch.view];
    return [[CCDirector sharedDirector] convertToGL:touchLocation];
}
#endif

@end
