//
//  SnakeSegment.m
//  Snek
//
//  Created by Pippin Barr on 19/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SnakeSegment.h"


@implementation SnakeSegment

@synthesize matches = _matches;
@synthesize facing = _facing;

- (id) init
{
    if ( self = [super init] )
    {
        _matches = NO;
        _facing = RIGHT;
    }
    
    return self;
}

@end
