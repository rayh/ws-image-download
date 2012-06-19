//
//  WSImageDownload.h
//
//  Created by Ray Hilton on 14/02/12.
//  Copyright (c) 2012 Wirestorm Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WSDataDownloadCompletionBlock)(NSHTTPURLResponse *response, NSData *data, BOOL fromCache);
typedef void (^WSImageDownloadCompletionBlock)(UIImage *image, BOOL fromCache);
typedef void (^WSDataDownloadStartBlock)(NSURL *url, BOOL fromCache);
typedef void (^WSDataDownloadFailureBlock)(NSError *error);

@interface WSImageDownload : NSObject

+ (WSImageDownload*)sharedService;
- (void)cancelAllDownloads;
- (void)cancelDownloadsForOwner:(id)owner;
- (void)suspendDownloads;
- (void)resumeDownloads;

- (void)downloadUrl:(NSURL*)url 
              owner:(id)owner
             asData:(WSDataDownloadCompletionBlock)completion
              start:(WSDataDownloadStartBlock)startBlock
            failure:(WSDataDownloadFailureBlock)failure;

- (void)downloadUrl:(NSURL*)url
              owner:(id)owner
            asImage:(WSImageDownloadCompletionBlock)completion
              start:(WSDataDownloadStartBlock)startBlock
            failure:(WSDataDownloadFailureBlock)failure;
@end
