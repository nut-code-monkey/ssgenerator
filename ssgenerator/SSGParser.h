//
//  SSGParser.h
//  storyboard_segue_generator
//
//  Created by Max Lunin on 20.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSGParser : NSObject

@property (strong, nonatomic) NSMutableArray* controllers;

+(instancetype)parserForStoryboard:( NSString* )storyboard error:( NSError*__autoreleasing* )error;

@end
