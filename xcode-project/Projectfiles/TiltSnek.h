//
//  TiltSnek.h
//  Snek
//
//  Created by Pippin Barr on 15/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Typedefs.h"
#import "GameLayer.h"

static const float MIN_TILT_STEP = 3.0f;
static const float MIN_TILT_TIME = 0.1f;

@interface TiltSnek : GameLayer
{
    float xp;
    float yp;
    Tilt tilting;
    float tiltElapsed;

}

+ (id) scene;
@end
