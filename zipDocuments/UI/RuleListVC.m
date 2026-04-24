#import "RuleListVC.h"
#import "RuleManager.h"
#import "SandboxRuleModel.h"
#import "AddRuleViewController.h"
#import "SVProgressHUD.h"


@interface RuleListVC ()
@property (nonatomic, strong) NSMutableArray<SandboxRuleModel *> *rules;
@end

@implementation RuleListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"备份规则";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"默认规则" style:UIBarButtonItemStylePlain target:self action:@selector(defaultRulesAction)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(addAction)];
    UIBarButtonItem *dissmissItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dissmiss)];
    
    self.navigationItem.rightBarButtonItems = @[dissmissItem,addItem];;
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"RuleCell"];
    self.tableView.tableFooterView = [UIView new];
    
    // 首次打开时自动加载默认规则
    [self loadDefaultRulesIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.rules = [RuleManager.allRules mutableCopy];
    [self.tableView reloadData];
}

- (void)dissmiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAction {
    AddRuleViewController *vc = [AddRuleViewController new];
    vc.completion = ^(SandboxRuleModel *model) {
        [RuleManager saveRule:model];
        self.rules = [RuleManager.allRules mutableCopy];
        [self.tableView reloadData];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RuleCell"];
    
    SandboxRuleModel *m = self.rules[indexPath.row];
    
    NSString *type = @[@"📁目录",@"📄后缀",@"🏷️文件名",@"🔍正则"][m.type];
    NSString *action = m.action == 0 ? @"[包含]" : @"[排除]";
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ | %@", type, action, m.rule];
    cell.detailTextLabel.text = m.desc;
    
    if (m.isDefault) {
        cell.backgroundColor = m.enable ? [UIColor colorWithRed:0.95 green:0.97 blue:1.0 alpha:1.0] : [UIColor lightGrayColor];
    } else {
        cell.backgroundColor = m.enable ? UIColor.whiteColor : [UIColor lightGrayColor];
    }
    
    // 添加开关
    UISwitch *enableSwitch = [[UISwitch alloc] init];
    enableSwitch.on = m.enable;
    [enableSwitch addTarget:self action:@selector(enableSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    enableSwitch.tag = indexPath.row;
    cell.accessoryView = enableSwitch;
    
    return cell;
}

- (void)enableSwitchChanged:(UISwitch *)sender {
    NSInteger row = sender.tag;
    if (row < self.rules.count) {
        SandboxRuleModel *model = self.rules[row];
        model.enable = sender.on;
        [RuleManager saveRule:model];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SandboxRuleModel *model = self.rules[indexPath.row];
    AddRuleViewController *vc = [AddRuleViewController new];
    vc.editModel = model;
    vc.completion = ^(SandboxRuleModel *newModel) {
        [RuleManager deleteRule:model];
        [RuleManager saveRule:newModel];
        self.rules = [RuleManager.allRules mutableCopy];
        [self.tableView reloadData];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        SandboxRuleModel *model = self.rules[indexPath.row];
        [RuleManager deleteRule:model];
        self.rules = [RuleManager.allRules mutableCopy];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [SVProgressHUD showSuccessWithStatus:@"删除成功"];
    }];
    return @[delete];
}

#pragma mark - 默认规则

- (void)loadDefaultRulesIfNeeded {
    NSArray *rules = RuleManager.allRules;
    if (rules.count == 0) {
        [self createDefaultRules];
    }
}

- (void)defaultRulesAction {
    [self createDefaultRules];
}

- (void)createDefaultRules {
    // 保存非默认规则
    NSMutableArray *nonDefaultRules = [NSMutableArray array];
    for (SandboxRuleModel *rule in RuleManager.allRules) {
        if (!rule.isDefault) {
            [nonDefaultRules addObject:rule];
        } else {
            [RuleManager deleteRule:rule];
        }
    }
    
    // 创建 Documents 文件夹规则
    SandboxRuleModel *docRule = [SandboxRuleModel new];
    docRule.type = RuleTypeDirectory;
    docRule.action = RuleActionInclude;
    docRule.directory = RuleDirectoryDocuments;
    docRule.rule = @"";
    docRule.desc = @"备份 Documents 文件夹";
    docRule.enable = YES;
    docRule.isDefault = YES;
    [RuleManager saveRule:docRule];
    
    // 创建 Library 文件夹规则
    SandboxRuleModel *libRule = [SandboxRuleModel new];
    libRule.type = RuleTypeDirectory;
    libRule.action = RuleActionInclude;
    libRule.directory = RuleDirectoryLibrary;
    libRule.rule = @"";
    libRule.desc = @"备份 Library 文件夹";
    libRule.enable = YES;
    libRule.isDefault = YES;
    [RuleManager saveRule:libRule];
    
    // 重新添加非默认规则
    for (SandboxRuleModel *rule in nonDefaultRules) {
        [RuleManager saveRule:rule];
    }
    
    // 刷新列表
    self.rules = [RuleManager.allRules mutableCopy];
    [self.tableView reloadData];
    
    [SVProgressHUD showSuccessWithStatus:@"默认规则已加载"];
}

@end
