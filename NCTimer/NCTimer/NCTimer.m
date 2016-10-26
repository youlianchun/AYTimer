//
//  NCTimer.m
//  NCTimer
//
//  Created by YLCHUN on 16/10/18.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "NCTimer.h"
static dispatch_queue_t NCTimer_Queue;//计时器并发队列

@interface NCTimer ()

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSUInteger count;
@property(nonatomic) NSUInteger tCount;

@property (nonatomic) NSTimeInterval interval;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;
@property (nonatomic) NCTimerStatus status;
@property (nonatomic, weak) NSRunLoop *runLoop;
@property (nonatomic, readonly) dispatch_queue_t queue;

-(instancetype)initWithCount:(NSUInteger)count interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector;
@end

@implementation NCTimer

+ (NCTimer *)timerWithCount:(NSUInteger)count interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector{
    NCTimer *timer = [[NCTimer alloc] initWithCount:count interval:interval target:target selector:selector];
    return timer;
}

-(instancetype)initWithCount:(NSUInteger)count interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector {
    self = [super init];
    if (self) {
        NSAssert([target respondsToSelector:selector], @"target 不能响应 selector");
        NSAssert(interval > 0.0, @"interval的值必须大于0.0");
        self.status = 0;
        self.count = count;
        self.target = target;
        self.interval = interval;
        self.selector = selector;
        self.status = NCTimerCancel;
    }
    return self;
}

-(dispatch_queue_t)queue {
    if (!NCTimer_Queue) {
        NCTimer_Queue = dispatch_queue_create("com.NCTimer.thread", DISPATCH_QUEUE_CONCURRENT);
    }
    return NCTimer_Queue;
}

-(void)_initTimer{
    [self cancel];
    NSAssert([self.target respondsToSelector:self.selector], @"target 不能响应 selector");
    self.tCount = (int)self.count;
    __weak typeof(self) wself = self;
    dispatch_async(self.queue, ^{
        wself.timer = [NSTimer scheduledTimerWithTimeInterval:wself.interval target:wself selector:@selector(_timerAction) userInfo:nil repeats:true];
        wself.runLoop = [NSRunLoop currentRunLoop];
        [wself.runLoop addTimer:wself.timer forMode:NSDefaultRunLoopMode];
        [wself.runLoop run];
    });
}

-(void)_timerAction {
    if (self.count>0){
        self.tCount -- ;
    }else {
        self.tCount ++;
    }
    __weak typeof(self) wself = self;
    if (self.target && [self.target respondsToSelector:self.selector]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.target performSelector:wself.selector withObject:wself  afterDelay:0.0];
        });
    }
    if (self.tCount == 0 || !self.target) {//倒计时结束或者触发者不存在时候取消
        [self cancel];
    }
}

-(BOOL)resume {
    if (self.status == NCTimerCancel) {
        [self _initTimer];
        self.status = NCTimerResume;
        return true;
    }
    if (self.status == NCTimerSuspend) {
        [self.timer setFireDate:[NSDate date]];
        self.status = NCTimerResume;
        return true;
    }
    return false;
}

-(BOOL)suspend {
    if (self.status == NCTimerResume) {
        [self.timer setFireDate:[NSDate distantFuture]];//暂停
        self.status = NCTimerSuspend;
        return true;
    }
    return false;
}

-(BOOL)cancel {
    if (self.status == NCTimerResume || self.status == NCTimerSuspend) {
        if (self.timer) {
            if (self.timer.valid) {
                [self.timer invalidate];
            }
            self.timer = nil;
        }
        self.status = NCTimerCancel;
        return true;
    }
    return false;
}

@end

