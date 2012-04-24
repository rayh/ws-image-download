//
//  UIImageView+WSImageDownload.m
//
//  Created by Ray Hilton on 19/01/12.
//  Copyright (c) 2012 Wirestorm Pty Ltd. All rights reserved.
//

#import "UIImageView+WSImageDownload.h"
#import "UIView+WSImageDownload.h"

@implementation UIImageView (WSImageDownload)

- (void)setImageWithURL:(NSURL*)url
             animateOut:(void(^)(void))animateOut
              animateIn:(void(^)(void))animateIn
               duration:(CGFloat)duration
{
    // FIXME: Only perform download if the URL is not what is currently set
    
    [self downloadUrl:url 
           animateOut:animateOut 
            animateIn:animateIn
            configure:^(UIImage *image, BOOL fromCache) {
                self.image = image;
            } duration:duration];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url
               animateOut:^{
                   self.alpha = 0;
               } animateIn:^{
                   self.alpha = 1;
               } duration:0.3];
}
@end
