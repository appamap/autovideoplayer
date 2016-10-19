#import "AutoVideoPlay.h"
#import "CustomMoviePlayerViewController.h"


@implementation AutoVideoPlay

- (void)autoplay:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* jsonString = [[command arguments] objectAtIndex:0];
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSString* msg = [NSString stringWithFormat: @"Sended data is ,  %@", jsonString];
    fileURL = [jsonResult objectForKey:@"url"];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil]; //all files
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* mime = @"video/mp4";
    NSString *extension;
    NSString* ext;
    BOOL onStorage = NO;
    NSArray* foo = [fileURL componentsSeparatedByString: @"."];
    NSString* firstBit = [foo lastObject];
    
    for (NSString * filename in contents)
        {
            extension = [filename pathExtension]; //
            
            fullPath = [documentsPath stringByAppendingPathComponent:[firstBit stringByAppendingString:[NSString stringWithFormat:@".%@/", extension]]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) //does it exist?
            {
                finalPath =fullPath;
                if ([extension isEqualToString:@"MP4"]) //what type is it
                {
                    mime = @"video/mp4";
                    ext = @".MP4";
                    onStorage = YES;
                }
                if ([extension isEqualToString:@"MP3"])
                {
                    mime = @"video/mp3";
                    ext = @".MP3";
                    onStorage = YES;
                }
            }
        }//for
    
    BOOL modalPresent = (BOOL)(self.viewController.presentedViewController);
    
    if((!modalPresent)&&(!delayRequest))
    {
        if (onStorage==YES)
        {
            delayRequest=YES;
            moviePlayer = [[CustomMoviePlayerViewController alloc] initWithPath:finalPath: NO];  //need to add local play
            [moviePlayer setVideoType:mime];
            [moviePlayer readyPlayerLocal];
            [super.viewController presentViewController:moviePlayer animated:YES completion:nil];
        }
            else
        {
            delayRequest=YES;
            NSURLRequest    *req  = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
            NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
            [conn start];
        }
        
        NSTimer *timerOutDelay = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                             target: self
                                                           selector:@selector(onTickDelay:)
                                                           userInfo: nil repeats:NO];

        
    }
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];
    
    [self success:result callbackId:callbackId];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Timeout"
                                                        message:@"Unable to play media file."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
     delayRequest=NO;
   
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
        moviePlayer = [[CustomMoviePlayerViewController alloc] initWithPath:fileURL:YES];  //need to add local play
        [moviePlayer setVideoType:[response MIMEType]];
        [moviePlayer readyPlayer];
        [super.viewController presentViewController:moviePlayer animated:YES completion:nil];
        delayRequest=NO;
        
        NSTimer *timerOut = [NSTimer scheduledTimerWithTimeInterval: 15.0
                                                             target: self
                                                           selector:@selector(onTick:)
                                                           userInfo: nil repeats:NO];
}


-(void)onTick:(NSTimer *)timer {
    
    if(moviePlayer.isMediaPlaying==YES)
    {
        //nothing
    }
    else
    {
        [moviePlayer killPlayer];
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Timeout"
                                                        message:@"15 Second Timeout! Your 3G/4G connection is too slow to play this file"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        delayRequest=NO;
        //[alert show];
    }
}


-(void)onTickDelay:(NSTimer *)timer {
    
            delayRequest=NO;

}





@end

