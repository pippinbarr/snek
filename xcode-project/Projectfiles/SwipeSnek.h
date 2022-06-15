//
//  SwipeSnek.h
//  Snek
//
//  Created by Pippin Barr on 21/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"
#import "Typedefs.h"

@interface SwipeSnek : GameLayer
{
    BOOL snakeCanMove;
    BOOL moved;
    BOOL swipeRecognized;
}
    
+ (id) scene;
    
@end