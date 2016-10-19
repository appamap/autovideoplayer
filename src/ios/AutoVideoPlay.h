#import <Cordova/CDV.h>

@class CustomMoviePlayerViewController;

@interface AutoVideoPlay : CDVPlugin
{
   NSString* fileURL;
   CustomMoviePlayerViewController *moviePlayer;
    BOOL delayRequest;
    NSString* fullPath;
    NSString* finalPath;
}

- (void) autoplay:(CDVInvokedUrlCommand*)command;

@end