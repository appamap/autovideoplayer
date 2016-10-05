//
//  CustomMoviePlayerViewController.h
//
//  Copyright Liam Donaghy. 25/11/2015
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CustomMoviePlayerViewController : UIViewController
{
    MPMoviePlayerController *mp;
    NSURL *movieURL;
    BOOL isMP4;
}

@property (nonatomic, strong) NSMutableArray *xmlCopyArray;

- (id)initWithPath:(NSString *)moviePath : (BOOL) runHTTP;
- (void)readyPlayer;
- (void) moviePlayerLoadStateChanged:(NSNotification*)notification;
- (void) setVideoType : (NSString *) fileType;
-(BOOL) isMediaPlaying;
-(void) killPlayer;
- (void) readyPlayerLocal;

@end
