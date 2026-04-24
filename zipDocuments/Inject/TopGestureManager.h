//
//  TopGestureManager.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopGestureManager : NSObject
+ (instancetype)sharedManager;
- (void)startMonitor;
- (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
