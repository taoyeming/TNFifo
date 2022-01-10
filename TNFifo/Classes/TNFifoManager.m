//
//  TNFifoManager.m
//  TNFifo
//
//  Created by taoyeming on 2022/1/7.
//

#import "TNFifoManager.h"

@implementation TNFifoManager

static dispatch_semaphore_t _semaphore;
static dispatch_queue_t _queue;
static NSString *_uuid;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _semaphore = dispatch_semaphore_create(1);
        _queue = dispatch_queue_create("com.tnfifo.queue", DISPATCH_QUEUE_SERIAL);
    });
}

+ (void)exec:(void (^)(NSString *uuid))block {
    [self exec:block queue:dispatch_get_main_queue() delay:0];
}

+ (void)exec:(void (^)(NSString *uuid))block queue:(dispatch_queue_t)queue delay:(double)delay {
    if(!block) return;
    dispatch_async(_queue, ^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        void(^execBlock)(void) = ^(void) {
            _uuid = [[NSUUID UUID] UUIDString];
            block(_uuid);
        };
        if(delay < 0.0001) {
            dispatch_async(queue, execBlock);
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, execBlock);
        }
    });
}

+ (void)completeWithUUID:(NSString *)uuid {
    if(!uuid || ![_uuid isEqualToString:uuid]) return;
    _uuid = nil;
    dispatch_semaphore_signal(_semaphore);
}

@end
