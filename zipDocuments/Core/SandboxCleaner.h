//
//  SandboxCleaner.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SandboxCleaner : NSObject
+ (void)cleanSandboxExcludeBackupDir:(void(^)(BOOL done))completion;
@end

NS_ASSUME_NONNULL_END
