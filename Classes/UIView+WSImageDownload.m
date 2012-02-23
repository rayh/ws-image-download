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


- (void)downloadUrl:(NSURL*)url asImage:(WSImageDownloadCompletionBlock)completion failure:(WSDataDownloadFailureBlock)failure
{
    [[WSImageDownload sharedService] cancelDownloadsForOwner:self];
    [[WSImageDownload sharedService] downloadUrl:url owner:self asImage:completion failure:failure];
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
            if(image==nil) {
                configure(nil, NO);
                return;
            } // Ignore, as this means we have missed the cache and are going to fetch
            
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
    }];
}
@end
