//
//  Sample.m
//  Snek
//
//  Created by Pippin Barr on 22/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import "Sample.h"
#import "SimpleAudioEngine.h"


@implementation Sample

@synthesize file;
@synthesize offset;
@synthesize repeatOffset;
@synthesize next;




- (id) initWithFile:(NSString*)theFile offset:(NSUInteger)theOffset repeatOffset:(NSUInteger)theRepeatOffset;
{
    self = [super init];
    
    if (self != nil)
    {
        file = theFile;
        offset = theOffset;
        repeatOffset = theRepeatOffset;
        next = offset + repeatOffset;
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:file];

    return self;
}


- (void) play:(NSUInteger)ticks
{
    if (ticks == next)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:file];
        next += repeatOffset;
    }
}


- (void) reset
{
    if (repeatOffset != 0)
        next = (offset % repeatOffset);
    else
        next = offset;
}


@end
