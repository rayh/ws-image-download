//
//  UIImageView+WSImageDownload.h
//
//  Created by Ray Hilton on 19/01/12.
//  Copyright (c) 2012 Wirestorm Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (WSImageDownload)

// Compatability with SDWebImage
- (void)setImageWithURL:(NSURL*)url;


- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage*)placeholderImage;

- (void)setImageWithURL:(NSURL*)url
       placeholderImage:(UIImage*)placeholderImage
             animateOut:(void(^)(void))animateOut
              animateIn:(void(^)(void))animateIn
               duration:(CGFloat)duration;


@end
