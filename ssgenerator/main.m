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

NSString* firstNotNilParameter( NSString* first, NSString* second )
{
    return first ? first : second ? second : nil;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSArray* arguments = [[NSProcessInfo processInfo] arguments];
        
        void(^printHelp)() = ^()
        {
            NSURL* appUrl = [NSURL fileURLWithPath:arguments[0]];
            const char* appName = [[appUrl lastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding];
            
            printf("usage:\n");
            printf("   %s -s <storyboard-name> [-o <output-filename>]\n\n", appName);
            printf("   %s -storyboard <storyboard-name> [-output <output-filename>] [-p | -prefix [UI | NS]]\n", appName);
        };
        
        if ( arguments.count == 1 ) // no params
        {
            printHelp();
            return EXIT_FAILURE;
        }

        if ( [arguments containsObject:@"-h"] || [arguments containsObject:@"-help"] )
        {
            printHelp();
            return EXIT_SUCCESS;
        }
        
        NSDictionary* args = [[NSUserDefaults standardUserDefaults] volatileDomainForName:NSArgumentDomain];
        
        NSString* storyboard = firstNotNilParameter( args[@"s"], args[@"storyboard"] );
        
        if ( !storyboard )
        {
            printHelp();
            return EXIT_FAILURE;
        }
        
        NSString* prefix = firstNotNilParameter(args[@"p"], args[@"prefix"]);
        if (prefix && ![prefix isEqual:@"UI"] && [prefix isEqual:@"NS"] )
        {
            printf("-prefix must be UI or NS");
            return EXIT_FAILURE;
        }
    
        NSString* storyboardPath = [[NSURL fileURLWithPath:storyboard] relativePath];
        
        NSString* storyboardName = [[storyboardPath lastPathComponent] stringByDeletingPathExtension];
        
        NSString* defauldOutputFilename = [storyboardName stringByAppendingString:@"Segue"];

        id defaultOutput = [[storyboardPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:defauldOutputFilename];
        id outputPath = firstNotNilParameter(firstNotNilParameter(args[@"o"], args[@"output"]), defaultOutput);
        
        NSError* error = nil;
        SSGParser* parser = [SSGParser parserForStoryboard:storyboardPath error:&error];
        
        if ( error )
        {
            printf("%s", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            return EXIT_FAILURE;
        }
        
        SSGenerator* generator = [SSGenerator generatorForStoryboard:[storyboardPath lastPathComponent] 
                                                         controllers:parser.controllers];
        
        generator.controllerPrefix = firstNotNilParameter(prefix, @"UI");
        
        error = [generator writeH:outputPath];
        if ( error )
        {
            printf("%s", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            return EXIT_FAILURE;
        }
        
        printf("generate %s.h\n", [defauldOutputFilename cStringUsingEncoding:NSUTF8StringEncoding]);
        
        error =  [generator writeM:outputPath];
        if ( error )
        {
            printf("%s", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            return EXIT_FAILURE;
        }
        
        printf("generate %s.m\n", [defauldOutputFilename cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return EXIT_SUCCESS;
}
