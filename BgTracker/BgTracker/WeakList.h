//
//  WeakList.h
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/19.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeakList : NSObject

- (instancetype)init;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)forEach:(void (^)(id object))consumer;

@end
