//
//  UIView+WSImageDownload.m
//
//  Created by Ray Hilton on 14/02/12.
//  Copyright (c) 2012 Wirestorm Pty Ltd. All rights reserved.
//

#import "UIView+WSImageDownload.h"

@implementation UIView (WSImageDownload)

- (void)downloadUrl:(NSURL*)url asImage:(WSImageDownloadCompletionBlock)completion
{
    [self downloadUrl:url asImage:completion failure:nil];
}


- (void)downloadUrl:(NSURL*)url
            asImage:(WSImageDownloadCompletionBlock)completion 
              start:(WSDataDownloadStartBlock)start
            failure:(WSDataDownloadFailureBlock)failure
{
    [[WSImageDownload sharedService] cancelDownloadsForOwner:self];
    [[WSImageDownload sharedService] downloadUrl:url owner:self asImage:completion start:start failure:failure];
}

- (void)downloadUrl:(NSURL*)url
         animateOut:(void(^)(void))animateOut
          animateIn:(void(^)(void))animateIn
          configure:(WSImageDownloadCompletionBlock)configure 
           duration:(CGFloat)duration
{
    [[WSImageDownload sharedService] cancelDownloadsForOwner:self];
    [self downloadUrl:url asImage:^(UIImage *image, BOOL fromCache) {
        if(fromCache) {
            configure(image,fromCache);
        } else {            
            [UIView animateWithDuration:duration/2
                             animations:^{
                                 if(animateOut) animateOut();
                             }
                             completion:^(BOOL finished) {
                                 configure(image, fromCache);
                                 
                                 [UIView animateWithDuration:duration/2
                                                  animations:^{
                                                      if(animateIn) animateIn();
                                                  }];
                             }];
        }        
    } start:^(NSURL *url, BOOL fromCache) {
        configure(nil, NO);
    } failure:^(NSError *error) {
        //
    }];
}
@end
