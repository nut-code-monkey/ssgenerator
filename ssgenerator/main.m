//
//  main.m
//  storyboard_segue_generator
//
//  Created by Max Lunin on 20.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSGParser.h"
#import "SSGenerator.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        void(^printHelp)() = ^()
        {
            NSURL* appUrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[0]]];
            const char* appName = [[appUrl lastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding];
            
            printf("usage:\n");
            printf("   %s [-h | -help] [-s | -storyboard] <storyboard_name> [-o | -output] <output_filename>\n", appName);
        };
        
        if ( argc == 1 ) // no params
        {
            printHelp();
            return EXIT_FAILURE;
        }

        for (int i = 1; i < argc; ++i) // -h | -help
        {
            NSString* arg = [NSString stringWithUTF8String:argv[i]];
            if ( [arg isEqual:@"-h"] || [arg isEqual:@"-help"] )
            {
                printHelp();
                return EXIT_SUCCESS;
            }
        }
        
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        NSDictionary *parsedArguments = [args volatileDomainForName:NSArgumentDomain];
        
        NSString* storyboard = parsedArguments[@"s"];
        if ( !storyboard )
        {
            storyboard = parsedArguments[@"storyboard"];
        }
        
        if ( !storyboard )
        {
            printHelp();
            return EXIT_FAILURE;
        }
    
        NSURL* storyboardPath = [NSURL fileURLWithPath:storyboard];
        
        NSString* outputFilename = [[[storyboardPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"Segues"];
        
        NSString* outputPath = [[[storyboardPath URLByDeletingLastPathComponent] URLByAppendingPathComponent:outputFilename] relativePath];
        
        if ( parsedArguments[@"o"] )
        {
            outputPath = parsedArguments[@"o"];  ;
        }
        else if ( parsedArguments[@"output"] )
        {
            outputPath = parsedArguments[@"output"];
        }
        
        NSError* error = nil;
        SSGParser* parser = [SSGParser parserForStoryboard:[storyboardPath relativePath] error:&error];
        
        if ( error )
        {
            printf("%s", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            return EXIT_FAILURE;
        }
        
        SSGenerator* generator = [SSGenerator generatorForControllers:parser.controllers];
    
        error = [generator writeH:outputPath];
        if ( error )
        {
            printf("%s", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            return EXIT_FAILURE;
        }
    
        printf("generate %s.h\n", [outputFilename cStringUsingEncoding:NSUTF8StringEncoding]);
        
        error =  [generator writeM:outputPath];
        if ( error )
        {
            printf("%s", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            return EXIT_FAILURE;
        }
        
        printf("generate %s.m\n", [outputFilename cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return EXIT_SUCCESS;
}

