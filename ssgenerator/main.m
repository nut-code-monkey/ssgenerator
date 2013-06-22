//
//  main.m
//  storyboard_segue_generator
//
//  Created by Max Lunin on 20.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSGParser.h"
#import "SSGController.h"
#import "SSGenerator.h"

#import "FSArgumentSignature.h"
#import "FSArgumentParser.h"
#import "FSArgumentPackage.h"

#import "NSProcessInfo+FSArgumentParser.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {    
        NSString* path = [NSString stringWithFormat:@"%s", argv[0]];
        
        FSArgumentSignature
        * appPath = [FSArgumentSignature argumentSignatureWithFormat:@"[%@]", path],
        * outputFileSignature = [FSArgumentSignature argumentSignatureWithFormat:@"[-o --output]="],
        * storyboardFileSignature = [FSArgumentSignature argumentSignatureWithFormat:@"[-s --storyboard]="],
        * helpSignature = [FSArgumentSignature argumentSignatureWithFormat:@"[-h --help]"];
        
        NSArray* signatures = @[appPath, helpSignature, storyboardFileSignature, outputFileSignature];
        
        FSArgumentPackage * package = [[NSProcessInfo processInfo] fsargs_parseArgumentsWithSignatures:signatures];
        
        void(^printHelp)() = ^()
        {
            NSURL* appUrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[0]]];
            printf("usage:\n");
            printf("   %s  [-h | --help] [-s |--storyboard] <storyboard_name> [-o | --output] <output_filename>\n", [[appUrl lastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding]);
        };
        
        if ( [package unknownSwitches].count || [package uncapturedValues].count || [package countOfSignature:storyboardFileSignature] == 0 )
        {
            printHelp();
            return EXIT_FAILURE;
        }
        
        if ( [package countOfSignature:helpSignature] )
        {
            printHelp();
            return EXIT_SUCCESS;
        }
    
        NSURL* storyboardPath = [NSURL fileURLWithPath:[package firstObjectForSignature:storyboardFileSignature]];
        
        NSString* outputFilename = [[[storyboardPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"Segues"];
        
        NSString* outputPath = [[[storyboardPath URLByDeletingLastPathComponent] URLByAppendingPathComponent:outputFilename] relativePath];
        
        if ( [package countOfSignature:outputFileSignature] )
        {
            outputPath = [package firstObjectForSignature:outputFileSignature];
        }
        
        NSError* error = nil;
        SSGParser* parser = [SSGParser parserForStoryboard:[storyboardPath relativePath] error:&error];
        
        if ( error )
        {
            printf("%s", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            return EXIT_FAILURE;
        }
        
        NSMutableDictionary* controllers = [NSMutableDictionary dictionary];
        
        for (NSDictionary* segue in parser.segues)
        {
            NSString* identifier = segue[@"identifier"];
            if ( !identifier )
                continue;
            
            NSDictionary* sourceViewController = segue[@"sourceViewController"];
            
            NSString* customClass = sourceViewController[@"customClass"];
            if ( !customClass )
            {
                customClass = @"UIViewController";
            }
        
            SSGController* controller = controllers[customClass];
            if (!controller)
            {
                controllers[customClass] = [SSGController controllerWithClass:customClass segue:identifier];
            }
            else
            {
                [controller.segues addObject:identifier];
            }
        }
    
        SSGenerator* generator = [SSGenerator generatorForControllers:[controllers allValues]];
    
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

