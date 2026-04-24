//
//  ZipTool.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "ZipTool.h"
#import "SSZipArchive.h"
#import "SandboxTool.h"
#import <zlib.h>

@implementation ZipTool
#pragma mark - 异步压缩
+ (void)zipFiles:(NSArray<NSString *> *)files
          toPath:(NSString *)zipPath
      completion:(void(^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{        SSZipArchive *zip = [[SSZipArchive alloc] initWithPath:zipPath];
        BOOL success = [zip open];
        
        if (success) {
            NSString *homePath = [SandboxTool homePath];
            
            for (NSString *filePath in files) {
                // 计算相对路径，用于在 zip 中保留目录结构
                NSString *relativePath = [filePath stringByReplacingOccurrencesOfString:homePath withString:@""];
                // 移除开头的 /
                if ([relativePath hasPrefix:@"/"]) {
                    relativePath = [relativePath substringFromIndex:1];
                }
                // 写入文件，保留目录结构
                [zip writeFileAtPath:filePath withFileName:relativePath];
            }
            success = [zip close];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{            if (completion) completion(success);
        });
    });
}

#pragma mark - 异步解压
+ (void)unzipFile:(NSString *)zipPath
           toPath:(NSString *)destDir
       completion:(void(^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL success = [SSZipArchive unzipFileAtPath:zipPath
                                        toDestination:destDir];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success);
        });
    });
}
@end
