//
//  CustomMoviePlayerViewController.m
//
//  Copyright Liam Donaghy. 25/11/2015
//

#import "CustomMoviePlayerViewController.h"

@implementation CustomMoviePlayerViewController

@synthesize xmlCopyArray;

- (id)initWithPath:(NSString *)moviePath : (BOOL) runHTTP
{
    if (self = [super init])
    {
        
        if(runHTTP==YES)
        {
            movieURL = [NSURL URLWithString:moviePath];
        }
        else
        {
            movieURL =  [NSURL fileURLWithPath:moviePath];
            
        }
    }
    return self;
}

-(void) setVideoType : (NSString *) fileType
{
    if ([fileType rangeOfString:@"video/mp4" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        isMP4 = NO;
    }
    else
    {
        isMP4 = YES;
    }
}

- (void) moviePlayerLoadStateChanged:(NSNotification*)notification
{
    if ([mp loadState] != MPMovieLoadStateUnknown)
    {
       
        if(isMP4==NO)
        {
            [mp view].frame = self.view.bounds;
            [[self view] addSubview:[mp view]];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(0,50,100,55);
            button.tag = 1;
            button.backgroundColor = [UIColor blackColor];
            button.titleLabel.font = [UIFont systemFontOfSize:21.0];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:@"Done" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(audioPlayBackDidFinish:) forControlEvents:UIControlEventTouchUpInside];
            
            [ [mp view] addSubview:button];
        }
        else
        {
            [mp view].frame = self.view.bounds;
            [[self view] addSubview:[mp view]];
        }
        
        [mp play]; //autoplay
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        NSLog(@"ssfsd");
    }else if (reason == MPMovieFinishReasonUserExited) {
        NSLog(@"ssfsd");
    }else if (reason == MPMovieFinishReasonPlaybackError) {
        NSLog(@"ssfsd");
    }
    
    
    [self closeNotifications];
    [mp stop];
    [self  dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) isMediaPlaying
{
    if(mp.playbackState == MPMoviePlaybackStatePlaying)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void) audioPlayBackDidFinish :(id) sender
{
    [self closeNotifications];
    [mp stop];
    [self  dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [self cleanup];
}

- (void) cleanup
{
    mp=nil;
    movieURL=nil;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [self cleanup];
}

-(void) closeNotifications
{
    [[NSNotificationCenter 	defaultCenter]
     removeObserver:self
     name:MPMoviePlayerLoadStateDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter 	defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:nil];
    
    [[NSNotificationCenter 	defaultCenter]
     removeObserver:self
     name:UIApplicationDidChangeStatusBarOrientationNotification
     object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [mp  stop];
}

-(void) killPlayer
{
    [self closeNotifications];
    [mp stop];
    [self cleanup];
}


- (void) readyPlayerLocal
{
  
    if ([[NSFileManager defaultManager] fileExistsAtPath:movieURL.path]) {
        NSLog(@"The file exists");
       
        
        NSError *error = nil;
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:movieURL.path error:&error];
        if (fileDictionary) {
            // make use of attributes
        } else {
            // handle error found in 'error'
        }
        
        
        // thumbNail = [UIImage imageWithContentsOfFile:getImagePath];
    } else {
        NSLog(@"The file exists not!");
    }

   
    
    
    mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    if ([mp respondsToSelector:@selector(loadState)])
    {
        mp.movieSourceType = MPMovieSourceTypeFile;
        [mp setControlStyle:MPMovieControlStyleFullscreen];
        [mp setFullscreen:YES];
        [mp prepareToPlay];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerLoadStateChanged:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(orientationDidChange:)
                                                     name: UIApplicationDidChangeStatusBarOrientationNotification
                                                   object: nil];
        
        [mp view].frame = self.view.bounds;
        [[self view] addSubview:[mp view]];
        [mp play]; //autoplay
    
    
    
    }
}

- (void) readyPlayer
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: movieURL];
    [request setHTTPMethod: @"HEAD"];
    
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *myData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error ];
        
        BOOL reachable;
        
        if (myData) {
            
            reachable=YES;
            
        } else {
            
            reachable=NO;
        }
        
        BOOL finished = NO;
        __block BOOL cancelled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (!finished) {
                cancelled = YES;
                
                if(mp.playbackState != MPMoviePlaybackStatePlaying)
                {
                    [self closeNotifications];
                    [mp stop];
                    [self  dismissViewControllerAnimated:YES completion:nil];
                }
            }
        });
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            if(reachable==YES)
            {
                mp =  [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
                
                if ([mp respondsToSelector:@selector(loadState)])
                {
                    [mp setControlStyle:MPMovieControlStyleFullscreen];
                    [mp setFullscreen:YES];
                    [mp prepareToPlay];
                    
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                                               object:nil];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(moviePlayBackDidFinish:)
                                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                                               object:nil];
                    
                    [[NSNotificationCenter defaultCenter] addObserver: self
                                                             selector: @selector(orientationDidChange:)
                                                                 name: UIApplicationDidChangeStatusBarOrientationNotification
                                                               object: nil];
                }
            }
            else
            {
                [self closeNotifications];
                [mp stop];
                [self  dismissViewControllerAnimated:YES completion:nil];
            }
        });
    });
}


- (void) orientationDidChange: (NSNotification *) note //reset control map
{
    [mp view].frame = self.view.bounds;
    [[self view] addSubview:[mp view]];
}


- (BOOL)shouldAutorotate {
    return YES;
}



@end
