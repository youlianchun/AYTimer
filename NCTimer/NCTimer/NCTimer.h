//
//  NCTimer.h
//  NCTimer
//
//  Created by YLCHUN on 16/10/18.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,NCTimerStatus){
    NCTimerResume,//执行中
    NCTimerCancel,//停止
    NCTimerSuspend,//暂停
};

@interface NCTimer : NSObject

@property (nonatomic, readonly) NCTimerStatus status;

@property(nonatomic, readonly)NSUInteger tCount;


-(BOOL)resume;
-(BOOL)suspend;
-(BOOL)cancel;

-(instancetype)init NS_UNAVAILABLE;

+ (NCTimer *)timerWithCount:(NSUInteger)count interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector ;

@end
NS_ASSUME_NONNULL_END
