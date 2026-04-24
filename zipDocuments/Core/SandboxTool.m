//
//  SandboxTool.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "SandboxTool.h"

@implementation SandboxTool
+ (NSString *)homePath { return NSHomeDirectory(); }
+ (NSString *)documentPath { return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]; }
+ (NSString *)libraryPath { return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]; }
+ (NSString *)tmpPath { return NSTemporaryDirectory(); }
+ (NSString *)defaultBackupDir { return [[self documentPath] stringByAppendingPathComponent:@"sandbox_backups"]; }

+ (NSArray *)allSandboxDirs {
    return @[[self documentPath], [self libraryPath], [self tmpPath]];
}

+ (BOOL)fileExists:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)createDir:(NSString *)path {
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

// 🔥 新增：判断是不是文件（不是文件夹）
+ (BOOL)isFile:(NSString *)path {
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    return exists && !isDir;
}

+ (NSArray *)listFilesInDir:(NSString *)dir recursive:(BOOL)recursive {
    return [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:dir error:nil];
}

+ (BOOL)copyFile:(NSString *)from to:(NSString *)to {
    return [[NSFileManager defaultManager] copyItemAtPath:from toPath:to error:nil];
}

+ (BOOL)removeFile:(NSString *)path {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
