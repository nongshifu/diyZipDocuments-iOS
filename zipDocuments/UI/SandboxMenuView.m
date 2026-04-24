//
//  SandboxMenuView.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "SandboxMenuView.h"
#import "BackupManager.h"
#import "BackupModel.h"
#import "SandboxCleaner.h"
#import "BackupListVC.h"
#import "RuleListVC.h"
#import "SVProgressHUD.h"

@implementation SandboxMenuView
+ (void)showInView:(UIView *)view {
    UIViewController *vc = [SandboxMenuView topViewController];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"沙盒工具" message:@"选择操作" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"备份沙盒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self backupActionFromViewController:vc];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"还原数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self restoreActionFromViewController:vc];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"清理沙盒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cleanActionFromViewController:vc];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"备份规则设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self ruleActionFromViewController:vc];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = view;
        alert.popoverPresentationController.sourceRect = CGRectMake(view.bounds.size.width/2, view.bounds.size.height/2, 0, 0);
    }
    
    [vc presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 获取顶层控制器
+ (UIViewController *)topViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *topVC = window.rootViewController;
    
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        topVC = [(UINavigationController *)topVC topViewController];
    }
    
    if ([topVC isKindOfClass:[UITabBarController class]]) {
        topVC = [(UITabBarController *)topVC selectedViewController];
        if ([topVC isKindOfClass:[UINavigationController class]]) {
            topVC = [(UINavigationController *)topVC topViewController];
        }
    }
    return topVC;
}

+ (void)backupActionFromViewController:(UIViewController *)vc {
    [SVProgressHUD showWithStatus:@"正在备份..."];
    
    [BackupManager startBackup:^(BOOL success, NSString *path) {
        [SVProgressHUD dismiss];
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"备份成功！"];
            [self showBackupOptionsWithPath:path fromViewController:vc];
        } else {
            [SVProgressHUD showErrorWithStatus:@"备份失败！"];
        }
    }];
}

+ (void)showBackupOptionsWithPath:(NSString *)path fromViewController:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"备份完成" message:@"选择操作" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showRenameAlertWithPath:path fromViewController:vc];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"导出到文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BackupManager exportToFiles:path fromViewController:vc];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleCancel handler:nil]];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = vc.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(vc.view.bounds.size.width/2, vc.view.bounds.size.height/2, 0, 0);
    }
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)showRenameAlertWithPath:(NSString *)path fromViewController:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重命名备份" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *defaultName = path.lastPathComponent;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [defaultName stringByDeletingPathExtension];
        textField.placeholder = @"输入新名称";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newName = alert.textFields.firstObject.text;
        if (newName.length > 0) {
            BackupModel *model = [BackupModel new];
            model.name = defaultName;
            model.path = path;
            BOOL success = [BackupManager renameBackup:model toName:newName];
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"重命名成功"];
                [self showBackupOptionsWithPath:path fromViewController:vc];
            } else {
                [SVProgressHUD showErrorWithStatus:@"重命名失败"];
                [SVProgressHUD dismissWithDelay:1.5];
            }
        }
    }]];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)restoreActionFromViewController:(UIViewController *)vc {
    BackupListVC *backupVC = [BackupListVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:backupVC];
    [vc presentViewController:nav animated:YES completion:nil];
}

+ (void)cleanActionFromViewController:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定清理？"
                                                                 message:@"清空沙盒，不会删除备份文件"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定清理" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD showWithStatus:@"正在清理..."];
        
        [SandboxCleaner cleanSandboxExcludeBackupDir:^(BOOL done) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"清理完成！"];
        }];
    }]];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)ruleActionFromViewController:(UIViewController *)vc {
    RuleListVC *ruleVC = [RuleListVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ruleVC];
    [vc presentViewController:nav animated:YES completion:nil];
}
@end
