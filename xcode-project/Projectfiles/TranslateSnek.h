//
//  TranslateSnek.h
//  Snek
//
//  Created by Pippin Barr on 10/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"

static const float TRIGGER_ACCELERATION = 2.0;
static const float MIN_TRANSLATION = 1.2;
static const float MIN_TRANSLATE_TIME = 0.1;

static const float MIN_TRANSLATION_STEP = 0.025;
static const float MIN_TRANSLATION_VELOCITY = 0.05f;

@interface TranslateSnek : GameLayer
{
    BOOL canTranslate;
    BOOL translated;
    Motion translating;
    BOOL stable;
    CGPoint high;
    CGPoint trigger;
    CGPoint previous;
    float translateElapsed;
    
    CGPoint pa;
    CGPoint pv;
}

@end
