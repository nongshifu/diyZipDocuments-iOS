//
//  BackupManager.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "BackupManager.h"
#import "SandboxTool.h"
#import "ZipTool.h"
#import "RuleManager.h"
#import "RuleEngine.h"
#import "SSZipArchive.h"
#import "SVProgressHUD.h"

@implementation BackupManager
+ (void)zipFiles:(NSArray<NSString *> *)files
          toPath:(NSString *)zipPath
      completion:(void(^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{        SSZipArchive *zip = [[SSZipArchive alloc] initWithPath:zipPath];
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
        
        NSLog(@"🔥 压缩%@，文件数：%lu", success ? @"成功" : @"失败", (unsigned long)files.count);
        
        dispatch_async(dispatch_get_main_queue(), ^{            if (completion) completion(success);
        });
    });
}

+ (void)unzipFile:(NSString *)zipPath
           toPath:(NSString *)destDir
       completion:(void(^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [SSZipArchive unzipFileAtPath:zipPath
                                        toDestination:destDir];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success);
        });
    });
}

+ (void)startBackup:(void(^)(BOOL success, NSString *path))completion {
    [SandboxTool createDir:[SandboxTool defaultBackupDir]];
    
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyyMMdd_HHmmss";
    NSString *name = [fmt stringFromDate:NSDate.date];
    NSString *zipPath = [[SandboxTool defaultBackupDir] stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"zip"]];
    
    NSMutableArray *files = @[].mutableCopy;
    
    // 遍历所有目录
    for (NSString *dir in SandboxTool.allSandboxDirs) {
        NSArray *subs = [SandboxTool listFilesInDir:dir recursive:YES];
        
        for (NSString *f in subs) {
            NSString *full = [dir stringByAppendingPathComponent:f];
            
            // 🔥 过滤：必须是【文件】，不能是文件夹
            if (![SandboxTool isFile:full]) continue;
            
            // 🔥 过滤：必须符合规则
            if ([RuleEngine matchFile:full rules:RuleManager.allRules]) {
                [files addObject:full];
            }
        }
    }
    
    // 如果没有文件，直接返回
    if (files.count == 0) {
        NSLog(@"🔥 没有需要备份的文件！");
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO, zipPath);
        });
        return;
    }
    
    // 异步压缩
    [ZipTool zipFiles:files toPath:zipPath completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, zipPath);
        });
    }];
}

+ (void)restoreBackup:(BackupModel *)model completion:(void(^)(BOOL success))completion {
    // 异步解压
    [ZipTool unzipFile:model.path toPath:SandboxTool.homePath completion:^(BOOL success) {
        if (completion) completion(success);
    }];
}

+ (NSArray *)allBackups {
    NSArray *files = [SandboxTool listFilesInDir:[SandboxTool defaultBackupDir] recursive:NO];
    NSMutableArray *arr = @[].mutableCopy;
    for (NSString *f in files) {
        if ([f.pathExtension isEqualToString:@"zip"]) {
            BackupModel *m = [BackupModel new];
            m.name = f;
            m.path = [[SandboxTool defaultBackupDir] stringByAppendingPathComponent:f];
            [arr addObject:m];
        }
    }
    return arr;
}


+ (BOOL)renameBackup:(BackupModel *)model toName:(NSString *)newName {
    if (!newName || newName.length == 0) return NO;
    
    NSString *oldPath = model.path;
    NSString *newFileName = [newName hasSuffix:@".zip"] ? newName : [newName stringByAppendingPathExtension:@"zip"];
    NSString *newPath = [[SandboxTool defaultBackupDir] stringByAppendingPathComponent:newFileName];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    
    if (error) {
        NSLog(@"重命名失败: %@", error.localizedDescription);
        return NO;
    }
    return YES;
}

+ (void)exportToFiles:(NSString *)path fromViewController:(UIViewController *)vc {
    if (!path || path.length == 0 || !vc) {
        NSLog(@"导出参数无效");
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        NSLog(@"导出文件不存在: %@", path);
        [SVProgressHUD showErrorWithStatus:@"文件不存在"];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    
    // 适配 iPad
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = vc.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(vc.view.bounds.size.width/2, vc.view.bounds.size.height/2, 0, 0);
    }
    
    [vc presentViewController:activityVC animated:YES completion:^{}];
}

+ (NSString *)rulePath {
    return [[SandboxTool libraryPath] stringByAppendingPathComponent:@"SandboxRules.plist"];
}

+ (NSArray *)allRules {
    NSArray *arr = [NSArray arrayWithContentsOfFile:[self rulePath]];
    NSMutableArray *list = @[].mutableCopy;
    for (NSDictionary *dict in arr) {
        SandboxRuleModel *m = [SandboxRuleModel fromDict:dict];
        [list addObject:m];
    }
    return list;
}

+ (void)saveRule:(SandboxRuleModel *)rule {
    NSMutableArray *all = [[self allRules] mutableCopy];
    
    for (SandboxRuleModel *m in all) {
        if ([m.rule isEqualToString:rule.rule]) {
            [all removeObject:m];
            break;
        }
    }
    
    [all addObject:rule];
    NSMutableArray *dicts = @[].mutableCopy;
    for (SandboxRuleModel *m in all) {
        [dicts addObject:m.toDict];
    }
    [dicts writeToFile:[self rulePath] atomically:YES];
}

+ (void)deleteRule:(SandboxRuleModel *)rule {
    NSMutableArray *all = [[self allRules] mutableCopy];
    NSMutableArray *newArray = @[].mutableCopy;
    
    for (SandboxRuleModel *m in all) {
        if (![m.rule isEqualToString:rule.rule]) {
            [newArray addObject:m];
        }
    }
    
    NSMutableArray *dicts = @[].mutableCopy;
    for (SandboxRuleModel *m in newArray) {
        [dicts addObject:m.toDict];
    }
    [dicts writeToFile:[self rulePath] atomically:YES];
}
@end
