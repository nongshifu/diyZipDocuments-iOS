//
//  SandboxCleaner.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "SandboxCleaner.h"

#import "SandboxTool.h"
#import "RuleManager.h"

@implementation SandboxCleaner
+ (void)cleanSandboxExcludeBackupDir:(void(^)(BOOL done))completion {
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSArray *dirs = @[[SandboxTool documentPath], [SandboxTool libraryPath], [SandboxTool tmpPath]];
        NSString *exclude = [SandboxTool defaultBackupDir];
        
        for (NSString *dir in dirs) {
            NSArray *files = [SandboxTool listFilesInDir:dir recursive:YES];
            for (NSString *f in files) {
                NSString *full = [dir stringByAppendingPathComponent:f];
                if ([full containsString:exclude]) continue;
                [SandboxTool removeFile:full];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(YES);
        });
    });
}
@end
