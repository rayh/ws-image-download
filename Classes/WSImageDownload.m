//
//  WSImageDownload.m
//
//  Created by Ray Hilton on 14/02/12.
//  Copyright (c) 2012 Wirestorm Pty Ltd. All rights reserved.
//

#import "WSImageDownload.h"
#import <objc/runtime.h>

#define ASSOC_OBJ_CONNECTION_KEY "au.com.rayh.ws.downloadTask"


@implementation NSObject (WSImageDownload)

- (NSMutableArray*)__ws_addDownloadTasks
{
    NSMutableArray *tasks = objc_getAssociatedObject(self, ASSOC_OBJ_CONNECTION_KEY);
    
    if(!tasks) {
        tasks = [NSMutableArray array];
        objc_setAssociatedObject(self, ASSOC_OBJ_CONNECTION_KEY, tasks, OBJC_ASSOCIATION_RETAIN);
    }
    
    return tasks;
}

@end

@interface WSImageCacheCheckTask : NSOperation 
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, copy) WSDataDownloadCompletionBlock completion;
@property (nonatomic, copy) WSDataDownloadFailureBlock failure;
@property (nonatomic, copy) WSDataDownloadStartBlock startBlock;
@property (nonatomic, assign) id owner;
@property (nonatomic, retain) NSOperationQueue *downloadQueue;
@end

@interface WSImageDownloadTask : NSOperation
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, copy) WSDataDownloadCompletionBlock completion;
@property (nonatomic, copy) WSDataDownloadFailureBlock failure;
@property (nonatomic, copy) WSDataDownloadStartBlock startBlock;
@property (nonatomic, assign) id owner;


+ (WSImageDownloadTask*)taskForOwner:(id)owner
                                 url:(NSURL*)url
                          completion:(WSDataDownloadCompletionBlock)completion
                               start:(WSDataDownloadStartBlock)startBlock
                             failure:(WSDataDownloadFailureBlock)failure;
@end


@implementation WSImageCacheCheckTask
@synthesize startBlock=_startBlock;
@synthesize url=_url;
@synthesize completion=_completion;
@synthesize failure=_failure;
@synthesize owner=_owner;
@synthesize downloadQueue=_downloadQueue;

- (void)dealloc
{
    self.downloadQueue = nil;
    self.startBlock = nil;
    self.failure = nil;
    self.url = nil;
    self.owner = nil;
    self.completion = nil;
    [super dealloc];
}

+ (WSImageCacheCheckTask*)taskForOwner:(id)owner
                                 url:(NSURL*)url
                         downloadQueue:(NSOperationQueue*)downloadQueue
                          completion:(WSDataDownloadCompletionBlock)completion
                               start:(WSDataDownloadStartBlock)startBlock
                             failure:(WSDataDownloadFailureBlock)failure
{
    WSImageCacheCheckTask *task = [[[WSImageCacheCheckTask alloc] init] autorelease];
    task.owner      = owner;
    task.url        = url;
    task.completion = completion;
    task.failure    = failure;
    task.startBlock = startBlock;
    task.downloadQueue = downloadQueue;
    return task;
}

- (void)main
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if(cachedResponse) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.startBlock)
                self.startBlock(self.url, YES);
            
            self.completion(cachedResponse.data, YES);
        });
        
        return;
    }
    
    WSImageDownloadTask *task = [WSImageDownloadTask taskForOwner:self.owner
                                                              url:self.url
                                                       completion:^(NSData *data, BOOL fromCache) {
                                                           self.completion(data, fromCache);
                                                       } 
                                                            start:self.startBlock
                                                          failure:self.failure];
    
    if(self.owner)
        [[self.owner __ws_addDownloadTasks] addObject:task];
    
    [self.downloadQueue addOperation:task];
    
} 

@end


@implementation WSImageDownloadTask
@synthesize startBlock=_startBlock;
@synthesize url=_url;
@synthesize completion=_completion;
@synthesize failure=_failure;
@synthesize owner=_owner;

- (void)dealloc
{
    self.startBlock = nil;
    self.failure = nil;
    self.url = nil;
    self.owner = nil;
    self.completion = nil;
    [super dealloc];
}

+ (WSImageDownloadTask*)taskForOwner:(id)owner
                                 url:(NSURL*)url
                          completion:(WSDataDownloadCompletionBlock)completion
                               start:(WSDataDownloadStartBlock)startBlock
                             failure:(WSDataDownloadFailureBlock)failure
{
    WSImageDownloadTask *task = [[[WSImageDownloadTask alloc] init] autorelease];
    task.owner      = owner;
    task.url        = url;
    task.completion = completion;
    task.failure    = failure;
    task.startBlock = startBlock;
    return task;
}

- (void)main
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    
    if(self.startBlock)
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startBlock(self.url, NO);
        });
        
        
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    // Unset this object from the owner
    if(self.owner)
        [[self.owner __ws_addDownloadTasks] removeObject:self];

    if(error) {
        if(self.failure) self.failure(error);
        return;
    }
    
    if(response.statusCode>=300) {
        if(self.failure) self.failure([NSError errorWithDomain:request.URL.absoluteString
                                         code:response.statusCode 
                                     userInfo:nil]);
        return;
    }
    
    if(!data) {
        if(self.failure) self.failure([NSError errorWithDomain:@"No Data"
                                         code:response.statusCode 
                                     userInfo:nil]);
        return;
    }
                        
    if(self.isCancelled)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completion(data, NO);
    });              
} 
    
@end

@interface WSImageDownload ()
@property (nonatomic, retain) NSOperationQueue *cacheQueryQueue;
@property (nonatomic, retain) NSOperationQueue *downloadQueue;
@end

@implementation WSImageDownload
@synthesize cacheQueryQueue=_cacheQueryQueue;
@synthesize downloadQueue=_downloadQueue;

+ (WSImageDownload*)sharedService
{
    static WSImageDownload *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[WSImageDownload alloc] init];
    });
    return service;
}

- (void)dealloc
{
    self.cacheQueryQueue = nil;
    self.downloadQueue = nil;
    [super dealloc];
}

- (id)init
{
    if(self = [super init])
    {
        self.cacheQueryQueue = [[[NSOperationQueue alloc] init] autorelease];
        self.cacheQueryQueue.maxConcurrentOperationCount = 4;

        self.downloadQueue = [[[NSOperationQueue alloc] init] autorelease];
        self.downloadQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}

- (void)downloadUrl:(NSURL*)url
              owner:(id)owner
             asData:(WSDataDownloadCompletionBlock)completion 
              start:(WSDataDownloadStartBlock)startBlock
            failure:(WSDataDownloadFailureBlock)failure
{
    if(!url)
    {
        NSLog(@"WSImageDownload was asked to download a nil url!");
        return;
    }

    WSImageCacheCheckTask *task = [WSImageCacheCheckTask taskForOwner:owner
                                                              url:url
                                                        downloadQueue:self.downloadQueue
                                                           completion:^(NSData *data, BOOL fromCache) {
                                                               completion(data, fromCache);
                                                           } 
                                                            start:startBlock
                                                          failure:failure];
    
    if(owner)
        [[owner __ws_addDownloadTasks] addObject:task];
    
    [self.cacheQueryQueue addOperation:task];
}

- (void)downloadUrl:(NSURL*)url
              owner:(id)owner
            asImage:(WSImageDownloadCompletionBlock)completion
              start:(WSDataDownloadStartBlock)startBlock
            failure:(WSDataDownloadFailureBlock)failure
{
    [self downloadUrl:url 
                owner:owner
               asData:^(NSData *data, BOOL fromCache) 
    {
        UIImage *image = [UIImage imageWithData:data];
        if(!image) {
            if(failure) failure([NSError errorWithDomain:@"Bad image data" code:0 userInfo:nil]);
            return;
        }
        
        completion(image, fromCache);
    }
                start:startBlock
              failure:failure];
}

- (void)cancelAllDownloads
{
    [self.cacheQueryQueue cancelAllOperations];
    [self.downloadQueue cancelAllOperations];
}

- (void)suspendDownloads
{
    [self.cacheQueryQueue setSuspended:YES];
    [self.downloadQueue setSuspended:YES];
}

- (void)resumeDownloads
{
    [self.cacheQueryQueue setSuspended:NO];
    [self.downloadQueue setSuspended:NO];
}

- (void)cancelDownloadsForOwner:(id)owner
{
    if(!owner)
        return;
    
    NSArray *tasks = [NSArray arrayWithArray:[owner __ws_addDownloadTasks]];
    
    if(!tasks)
        return;
    
    [[owner __ws_addDownloadTasks] removeAllObjects];
    
    for(WSImageDownloadTask *task in tasks) {
        [task cancel];
    }
    
}
@end
