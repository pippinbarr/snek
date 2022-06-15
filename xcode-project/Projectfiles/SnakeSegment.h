//
//  SnakeSegment.h
//  Snek
//
//  Created by Pippin Barr on 19/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Typedefs.h"

@interface SnakeSegment : CCSprite
{
}

@property BOOL matches;
@property Facing facing;

@end
