//
//  AYTimer.h
//  AYTimer
//
//  Created by YLCHUN on 16/10/18.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,AYTimerStatus){
    AYTimerResume,//执行中
    AYTimerCancel,//停止
    AYTimerSuspend,//暂停
};

@interface AYTimer : NSObject

@property (nonatomic, readonly) AYTimerStatus status;

@property(nonatomic, readonly)NSUInteger tCount;


-(BOOL)resume;
-(BOOL)suspend;
-(BOOL)cancel;

-(instancetype)init NS_UNAVAILABLE;

+ (AYTimer *)timerWithCount:(NSUInteger)count interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector ;

@end
NS_ASSUME_NONNULL_END
