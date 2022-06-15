//
//  RotateSnek.h
//  Snek
//
//  Created by Pippin Barr on 9/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"
#import "Typedefs.h"

static const float TRIGGER_ROTATION = 10.0f;


static const float MIN_ROTATE_TIME = 0.1f;
static const float MIN_ROTATE_STEP = 6.0f;

@interface RotateSnek : GameLayer
{
    float previous;
    BOOL canRotate;
    Rotation rotating;
    int rotateCount;
    
    float rotateElapsed;

    BOOL hitTrigger;
}

+ (id) scene;

@end
