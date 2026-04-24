//
//  ViewController.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "ViewController.h"
#import "SandboxKit.h"
#import "SandboxTool.h"
#import "BackupManager.h"
#import "BackupModel.h"
#import "SandboxCleaner.h"
#import "RuleManager.h"
#import "BackupListVC.h"
#import "RuleListVC.h"
#import "SVProgressHUD.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建测试沙盒文件
    [self createTestSandboxFiles];
    
    // 创建功能按钮
    [self createTestButtons];
}

#pragma mark - 创建测试沙盒文件
- (void)createTestSandboxFiles {
    NSString *docPath = [SandboxTool documentPath];
    
    // 测试文件 1
    NSString *testFile1 = [docPath stringByAppendingPathComponent:@"test_1.txt"];
    [@"测试文本内容111" writeToFile:testFile1 atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // 测试文件 2
    NSString *testFile2 = [docPath stringByAppendingPathComponent:@"test_2.sql"];
    [@"测试数据库内容222" writeToFile:testFile2 atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // 测试文件夹
    NSString *testDir = [docPath stringByAppendingPathComponent:@"testDir"];
    [SandboxTool createDir:testDir];
    
    NSString *testFile3 = [testDir stringByAppendingPathComponent:@"test_3.plist"];
    [@"测试配置文件333" writeToFile:testFile3 atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"✅ 测试文件创建完成：%@", docPath);
}

#pragma mark - 创建按钮
- (void)createTestButtons {
    NSArray *titles = @[
        @"1. 备份沙盒",
        @"2. 还原数据",
        @"3. 清理沙盒",
        @"4. 备份规则设置"
    ];
    
    CGFloat btnW = 250;
    CGFloat btnH = 50;
    CGFloat space = 20;
    CGFloat startY = 120;
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake((self.view.bounds.size.width - btnW)/2, startY + (btnH+space)*i, btnW, btnH);
        btn.backgroundColor = [UIColor systemBlueColor];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btn.layer.cornerRadius = 10;
        btn.tag = i;
        [btn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

#pragma mark - 按钮点击
- (void)onBtnClick:(UIButton *)sender {
    switch (sender.tag) {
        case 0: [self backupAction]; break;
        case 1: [self restoreAction]; break;
        case 2: [self cleanAction]; break;
        case 3: [self ruleAction]; break;
        default: break;
    }
}

#pragma mark - 备份
- (void)backupAction {
    [SVProgressHUD showWithStatus:@"正在备份..."];
    
    __weak typeof(self) weakSelf = self;
    
    [BackupManager startBackup:^(BOOL success, NSString *path) {
        [SVProgressHUD dismiss];
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"备份成功！"];
            [weakSelf showBackupOptionsWithPath:path];
        } else {
            [SVProgressHUD showErrorWithStatus:@"备份失败！"];
        }
    }];
}

- (void)showBackupOptionsWithPath:(NSString *)path {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"备份完成" message:@"选择操作" preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showRenameAlertWithPath:path];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"导出到文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BackupManager exportToFiles:path fromViewController:weakSelf];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleCancel handler:nil]];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0, 0);
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showRenameAlertWithPath:(NSString *)path {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重命名备份" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *defaultName = path.lastPathComponent;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [defaultName stringByDeletingPathExtension];
        textField.placeholder = @"输入新名称";
    }];
    
    __weak typeof(self) weakSelf = self;
    
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
                [weakSelf showBackupOptionsWithPath:path];
            } else {
                [SVProgressHUD showErrorWithStatus:@"重命名失败"];
                [SVProgressHUD dismissWithDelay:1.5];
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 还原
- (void)restoreAction {
    BackupListVC *vc = [BackupListVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 清理
- (void)cleanAction {
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
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 规则
- (void)ruleAction {
    RuleListVC *vc = [RuleListVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
