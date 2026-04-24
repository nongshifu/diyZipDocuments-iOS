//
//  SandboxTool.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SandboxTool : NSObject
+ (NSString *)homePath;
+ (NSString *)documentPath;
+ (NSString *)libraryPath;
+ (NSString *)tmpPath;
+ (NSString *)defaultBackupDir;
+ (NSArray *)allSandboxDirs;
+ (BOOL)fileExists:(NSString *)path;
+ (BOOL)createDir:(NSString *)path;
+ (NSArray *)listFilesInDir:(NSString *)dir recursive:(BOOL)recursive;
+ (BOOL)copyFile:(NSString *)from to:(NSString *)to;
+ (BOOL)removeFile:(NSString *)path;
+ (BOOL)isFile:(NSString *)path; // 👈 加上这一行
@end

NS_ASSUME_NONNULL_END
