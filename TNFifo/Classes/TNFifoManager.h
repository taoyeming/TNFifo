//
//  TNFifoManager.h
//  TNFifo
//
//  Created by taoyeming on 2022/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TNFifoManager : NSObject

/**
 顺序执行block，默认主队列，不延迟

 @param block 需要顺序执行的block，uuid为当前执行block唯一id，和completeWithUUID:一起使用
 */
+ (void)exec:(void (^)(NSString *uuid))block;

/**
 顺序执行block

 @param block 需要顺序执行的block，uuid为当前执行block唯一id，和completeWithUUID:一起使用
 @param queue 需要执行任务的任务队列
 @param delay 延迟执行时间
 */
+ (void)exec:(void (^)(NSString *uuid))block queue:(dispatch_queue_t)queue delay:(double)delay;

/**
 完成当前执行block

 @param uuid 当前执行的block的uuid
 */
+ (void)completeWithUUID:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
