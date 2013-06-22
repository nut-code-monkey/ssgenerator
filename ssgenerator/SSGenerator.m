//
//  SSGenerator.m
//  storyboard_segue_generator
//
//  Created by Max Lunin on 21.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import "SSGenerator.h"
#import "SSGController.h"

@interface SSGenerator ()

@property (strong, nonatomic) NSArray* controllers;

@end

@implementation SSGenerator

-(instancetype)initWithControllers:( NSArray* )controllers
{
    self = [super init];
    if ( self )
    {
        self.controllers = controllers;
    }
    return self;
}

+(instancetype)generatorForControllers:( NSArray* )controllers
{
    return [[self alloc] initWithControllers:controllers];
}


-(NSString*)linesForControllerH:( SSGController* )controller
{
    NSString* controllerSeguesType = [NSString stringWithFormat:@"%@Segues", controller.className];

    NSMutableArray* segueLines = [NSMutableArray arrayWithCapacity:controller.segues.count];
    for ( NSString* segue in controller.segues )
        [segueLines addObject:[NSString stringWithFormat:@"   __unsafe_unretained NSString* %@;", segue]];
    
    id seguesTypedef = [NSString stringWithFormat:@""
                      "extern const struct %@ {\n"
                      "%@\n"
                      "} %@ ;\n"
                      , controllerSeguesType
                      , [segueLines componentsJoinedByString:@"\n"]
                      , controllerSeguesType];
    
    
    id import = [NSString stringWithFormat:@"#import \"%@.h\"\n\n", controller.className];
    if ( [controller.className isEqual:@"UIViewController"] )
        import = @"";
    
    id category = [NSString stringWithFormat:@"\n"
                           "@interface %@ ( Segues )\n"
                           "\n"
                           "@property (assign, nonatomic, readonly) struct %@ segues;\n"
                           "\n"
                           "+(struct %@)segues;\n"
                           "\n"
                           "-(struct %@)segues;\n"
                           "\n"
                           @"@end\n\n"
                           , controller.className
                           , controllerSeguesType
                           , controllerSeguesType
                           , controllerSeguesType];

    
    
    return [@[seguesTypedef, import, category] componentsJoinedByString:@"\n"];
}

-(NSError*)writeH:( NSString* )file
{
    NSMutableArray* controllers = [NSMutableArray arrayWithObject:@"#import <UIKit/UIKit.h>\n\n"];
    for (SSGController* controller in self.controllers)
    {
        [controllers addObject:[self linesForControllerH:controller]];
    }
    NSString* hFile = [controllers componentsJoinedByString:@"\n\n"];
    
    NSError* error = nil;
    [hFile writeToFile:[file stringByAppendingString:@".h"]
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:&error];
    return error;
}

-(NSString*)linesForControllerM:( SSGController* )controller
{
    NSString* controllerSeguesType = [NSString stringWithFormat:@"%@Segues", controller.className];
    
    NSMutableArray* segueLines = [NSMutableArray arrayWithCapacity:controller.segues.count];
    for ( NSString* segue in controller.segues )
        [segueLines addObject:[NSString stringWithFormat:@"   .%@ = @\"%@\",", segue, segue]];
    
    NSString* seguesTypedef = [NSString stringWithFormat:@"const struct %@ %@ = {\n"
                               "%@\n"
                               "};\n"
                               , controllerSeguesType
                               , controllerSeguesType
                               , [segueLines componentsJoinedByString:@"\n"]];
    
    NSString* category = [NSString stringWithFormat:@"@implementation %@ ( Segues )\n\n"
                          "@dynamic segues;\n"
                          "\n"
                          "+(struct %@)segues {\n"
                          "   return %@;\n"
                          "}\n"
                          "\n"
                          "-(struct %@)segue {\n"
                          "   return [self.class segues];\n"
                          "}\n"
                          "\n"
                          "@end\n\n"
                          , controller.className
                          , controllerSeguesType
                          , controllerSeguesType
                          , controllerSeguesType];
    
    
    return [@[seguesTypedef ,category] componentsJoinedByString:@"\n\n"];
}

-(NSError*)writeM:( NSString* )file
{
    NSString* import = [file lastPathComponent];
    id header = [NSString stringWithFormat:@"#import \"\%@.h\"", import];

    NSMutableArray* controllers = [NSMutableArray arrayWithObject:header];
    for (SSGController* controller in self.controllers)
    {
        [controllers addObject:[self linesForControllerM:controller]];
    }

    NSString* mFile = [controllers componentsJoinedByString:@"\n\n"];
    
    NSError* error = nil;
    [mFile writeToFile:[file stringByAppendingString:@".m"]
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:&error];
    
    return error;
}


@end
