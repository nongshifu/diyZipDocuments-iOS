//
//  BackupListVC.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "BackupListVC.h"
#import "BackupManager.h"
#import "SVProgressHUD.h"

@interface BackupListVC ()

@end

@implementation BackupListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择备份";
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return BackupManager.allBackups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    BackupModel *m = BackupManager.allBackups[indexPath.row];
    cell.textLabel.text = m.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BackupModel *m = BackupManager.allBackups[indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择操作" message:m.name preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showRenameAlertWithModel:m];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"导出到文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BackupManager exportToFiles:m.path fromViewController:weakSelf];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确认还原" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"正在还原..."];
        [BackupManager restoreBackup:m completion:^(BOOL success) {
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"还原完成"];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            } else {
                [SVProgressHUD showErrorWithStatus:@"还原失败"];
                [SVProgressHUD dismissWithDelay:1.5];
            }
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = [tableView cellForRowAtIndexPath:indexPath];
        alert.popoverPresentationController.sourceRect = [tableView cellForRowAtIndexPath:indexPath].bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showRenameAlertWithModel:(BackupModel *)model {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重命名备份" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = model.name;
        textField.placeholder = @"输入新名称";
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newName = alert.textFields.firstObject.text;
        if (newName.length > 0) {
            BOOL success = [BackupManager renameBackup:model toName:newName];
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"重命名成功"];
                [weakSelf.tableView reloadData];
            } else {
                [SVProgressHUD showErrorWithStatus:@"重命名失败"];
                [SVProgressHUD dismissWithDelay:1.5];
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
