#import <Cordova/CDV.h>

@class CustomMoviePlayerViewController;

@interface AutoVideoPlay : CDVPlugin
{
   NSString* fileURL;
   CustomMoviePlayerViewController *moviePlayer;
    BOOL delayRequest;
}

- (void) autoplay:(CDVInvokedUrlCommand*)command;

@end