//
//  WSImageDownload.h
//  Local
//
//  Created by Ray Hilton on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WSDataDownloadCompletionBlock)(NSData *data, BOOL fromCache);
typedef void (^WSImageDownloadCompletionBlock)(UIImage *image, BOOL fromCache);
typedef void (^WSDataDownloadFailureBlock)(NSError *error);

@interface WSImageDownload : NSObject

+ (WSImageDownload*)sharedService;
- (void)cancelAllDownloads;
- (void)cancelDownloadsForOwner:(id)owner;
- (void)downloadUrl:(NSURL*)url owner:(id)owner asData:(WSDataDownloadCompletionBlock)completion failure:(WSDataDownloadFailureBlock)failure;
- (void)downloadUrl:(NSURL*)url owner:(id)owner asImage:(WSImageDownloadCompletionBlock)completion failure:(WSDataDownloadFailureBlock)failure;
@end
