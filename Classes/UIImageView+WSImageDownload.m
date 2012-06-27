//
//  UIImageView+WSImageDownload.m
//
//  Created by Ray Hilton on 19/01/12.
//  Copyright (c) 2012 Wirestorm Pty Ltd. All rights reserved.
//

#import "UIImageView+WSImageDownload.h"
#import "UIView+WSImageDownload.h"
#import <objc/runtime.h>

#define WS_IMAGE_DOWNLOAD_IMAGE_URL_KEY @"WSImageDownloadImageUrlKey"

@implementation UIImageView (WSImageDownload)

- (NSURL*)imageUrl
{
    return objc_getAssociatedObject(self, WS_IMAGE_DOWNLOAD_IMAGE_URL_KEY);
}

- (void)setImageWithURL:(NSURL*)url
       placeholderImage:(UIImage*)placeholderImage
             animateOut:(void(^)(void))animateOut
              animateIn:(void(^)(void))animateIn
               duration:(CGFloat)duration
{
    if([url isEqual:[self imageUrl]])
        return;
    
    self.image = placeholderImage;
    // FIXME: Only perform download if the URL is not what is currently set
    
    [self downloadUrl:url 
           animateOut:animateOut 
            animateIn:animateIn
            configure:^(UIImage *image, BOOL fromCache) {
                self.image = image;
                objc_setAssociatedObject(self, WS_IMAGE_DOWNLOAD_IMAGE_URL_KEY, url, OBJC_ASSOCIATION_RETAIN);
            } duration:duration];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage*)placeholderImage;
{
    [self setImageWithURL:url
         placeholderImage:placeholderImage
               animateOut:^{
                   self.alpha = 0;
               } animateIn:^{
                   self.alpha = 1;
               } duration:0.3];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

@end
