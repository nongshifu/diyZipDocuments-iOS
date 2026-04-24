//
//  BackupManager.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BackupModel.h"
#import "SandboxRuleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BackupManager : NSObject
+ (void)startBackup:(void(^)(BOOL success, NSString *path))completion;
+ (NSArray *)allBackups;
+ (void)restoreBackup:(BackupModel *)model completion:(void(^)(BOOL success))completion;
+ (BOOL)renameBackup:(BackupModel *)model toName:(NSString *)newName;
+ (void)exportToFiles:(NSString *)path fromViewController:(UIViewController *)vc;
+ (void)saveRule:(SandboxRuleModel *)rule;
+ (void)deleteRule:(SandboxRuleModel *)rule;
+ (NSArray *)allRules;
@end

NS_ASSUME_NONNULL_END
