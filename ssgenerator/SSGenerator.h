//
//  SSGenerator.h
//  storyboard_segue_generator
//
//  Created by Max Lunin on 21.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSGenerator : NSObject

@property (strong, nonatomic) NSString* defaultControllerClass;

+(instancetype)generatorForStoryboard:( NSString* )storyboard controllers:( NSArray* )controllers;

-(NSError*)writeH:( NSString* )file;
-(NSError*)writeM:( NSString* )file;

@end
