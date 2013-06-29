//
//  SSGController.m
//  storyboard_segue_generator
//
//  Created by Max Lunin on 21.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import "SSGController.h"

@implementation SSGController

-(instancetype)initWithStoryboardElementName:( NSString* )name
                                storyboardID:( NSString* )storyboardID
                                 customClass:( NSString* )customClass
{
    self = [super init];
    if ( self )
    {
        self.storyboardID = storyboardID;
        self.storyboardElementName = name;
        self.customClass = customClass;
        self.segue = [NSMutableSet set];
        self.cell = [NSMutableSet set];
        self.storyboardIdentifiers = [NSMutableSet set];
    }
    return self;
}

+(instancetype)controllerWithStoryboardElementName:( NSString* )name
                                      storyboardID:( NSString* )storyboardID
                                       customClass:( NSString* )customClass
{
    return [[self alloc] initWithStoryboardElementName:name storyboardID:storyboardID customClass:customClass];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ segue:%@>", self.customClass, self.segue];
}

@end
