//
//  SSGController.h
//  storyboard_segue_generator
//
//  Created by Max Lunin on 21.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSGController : NSObject

@property (strong, nonatomic) NSString* className;
@property (strong, nonatomic) NSMutableSet* segues;

+(instancetype)controllerWithClass:( NSString* )className segue:( NSString* )segueName;

@end
