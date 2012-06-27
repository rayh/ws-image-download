//
//  UIView+WSDownload.h
//
//  Created by Ray Hilton on 14/02/12.
//  Copyright (c) 2012 Wirestorm Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSImageDownload.h"

@interface UIView (WSDownload)

- (void)downloadUrl:(NSURL*)url asImage:(WSImageDownloadCompletionBlock)completion;

- (void)downloadUrl:(NSURL*)url
            asImage:(WSImageDownloadCompletionBlock)completion 
              start:(WSDataDownloadStartBlock)start
            failure:(WSDataDownloadFailureBlock)failure;


- (void)cancelAllImageDownloads;

/**
 A convenience method to:
 - Download the image
 - invoke animations to transition out the current image (unless the image is cached, in which case a duration of 0 is used)
 - assign tne image to the view using configure()
 - invoke the animation to transition in the new image

 The duration controls the entire animation time
 */
- (void)downloadUrl:(NSURL*)url
         animateOut:(void(^)(void))animateOut
          animateIn:(void(^)(void))animateIn
          configure:(WSImageDownloadCompletionBlock)configure 
           duration:(CGFloat)duration;
@end
