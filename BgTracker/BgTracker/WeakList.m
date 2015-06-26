//
//  WeakList.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/19.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "WeakList.h"

@interface WeakRef : NSObject
- (instancetype)initWithObject:(id)object;
@property (weak, readonly) id object;
@end

@implementation WeakRef

- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        _object = object;
    }
    return self;
}

@end

@implementation WeakList {
    NSMutableArray *_array;
}

- (instancetype)init {
    if (self = [super init]) {
        _array = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObject:(id)object {
    WeakRef *ref = [[WeakRef alloc] initWithObject:object];
    [_array addObject:ref];
}

- (void)removeObject:(id)object {
    NSUInteger i = 0;
    while (i < _array.count) {
        WeakRef *ref = _array[i];
        id refObj = ref.object;
        if (refObj != nil) {
            if ([refObj isEqual:object]) {
                [_array removeObjectAtIndex:i];
                continue;
            }
        } else if (refObj == nil) {
            [_array removeObjectAtIndex:i];
            continue;
        }
        i++;
    }
}

- (void)forEach:(void (^)(id object))consumer {
    NSUInteger i = 0;
    while (i < _array.count) {
        WeakRef *ref = _array[i];
        id refObj = ref.object;
        if (refObj != nil) {
            consumer(refObj);
        } else if (refObj == nil) {
            [_array removeObjectAtIndex:i];
            continue;
        }
        i++;
    }
}

@end
