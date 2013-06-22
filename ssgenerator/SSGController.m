//
//  SSGController.m
//  storyboard_segue_generator
//
//  Created by Max Lunin on 21.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import "SSGController.h"

@implementation SSGController

-(id)initWithClass:(NSString *)className segue:(NSString *)segueName
{
    self = [super init];
    if ( self )
    {
        self.className = className;
        self.segues = [NSMutableSet setWithObject:segueName];
    }
    return self;
}

+(instancetype)controllerWithClass:(NSString *)className segue:(NSString *)segueName
{
    return [[self alloc] initWithClass:className segue:segueName];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ segues:%@>", self.className, self.segues];
}

@end
