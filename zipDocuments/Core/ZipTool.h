//
//  ZipTool.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZipTool : NSObject
// 异步压缩
+ (void)zipFiles:(NSArray<NSString *> *)files
          toPath:(NSString *)zipPath
      completion:(void(^)(BOOL success))completion;

// 异步解压
+ (void)unzipFile:(NSString *)zipPath
           toPath:(NSString *)destDir
       completion:(void(^)(BOOL success))completion;
@end

NS_ASSUME_NONNULL_END
