//
//  AddRuleVC.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "AddRuleViewController.h"
#import "SandboxRuleModel.h"

@interface AddRuleViewController ()
@property (nonatomic, strong) UISegmentedControl *typeSegment;
@property (nonatomic, strong) UISegmentedControl *actionSegment;
@property (nonatomic, strong) UISegmentedControl *directorySegment;
@property (nonatomic, strong) UITextField *ruleField;
@property (nonatomic, strong) UITextField *descField;
@property (nonatomic, strong) UISwitch *enableSwitch;
@end

@implementation AddRuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = self.editModel ? @"编辑规则" : @"新增规则";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    [self setupUI];
    [self fillEditData];
}

- (void)setupUI {
    CGFloat left = 20;
    CGFloat w = self.view.bounds.size.width - 40;
    CGFloat y = 70;
    
    // 规则类型
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, y, w, 30)];
    typeLabel.text = @"规则类型";
    [self.view addSubview:typeLabel];
    y += 35;
    
    _typeSegment = [[UISegmentedControl alloc] initWithItems:@[@"文件夹",@"后缀",@"文件名",@"正则"]];
    _typeSegment.frame = CGRectMake(left, y, w, 40);
    _typeSegment.selectedSegmentIndex = 0; // 默认选择文件夹
    [self.view addSubview:_typeSegment];
    y += 55;
    
    // 沙盒目录
    UILabel *dirLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, y, w, 30)];
    dirLabel.text = @"沙盒目录";
    [self.view addSubview:dirLabel];
    y += 35;
    
    _directorySegment = [[UISegmentedControl alloc] initWithItems:@[@"Documents",@"Library",@"tmp",@"自定义"]];
    _directorySegment.frame = CGRectMake(left, y, w, 40);
    _directorySegment.selectedSegmentIndex = 0; // 默认选择Documents
    [self.view addSubview:_directorySegment];
    y += 55;
    
    // 规则动作
    UILabel *actLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, y, w, 30)];
    actLabel.text = @"规则动作";
    [self.view addSubview:actLabel];
    y += 35;
    
    _actionSegment = [[UISegmentedControl alloc] initWithItems:@[@"包含(备份)",@"排除(不备份)"]];
    _actionSegment.frame = CGRectMake(left, y, w, 40);
    _actionSegment.selectedSegmentIndex = 0; // 默认选择包含(备份)
    [self.view addSubview:_actionSegment];
    y += 55;
    
    // 规则内容
    UILabel *ruleLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, y, w, 30)];
    ruleLabel.text = @"规则内容";
    [self.view addSubview:ruleLabel];
    y += 35;
    
    _ruleField = [[UITextField alloc] initWithFrame:CGRectMake(left, y, w, 45)];
    _ruleField.borderStyle = UITextBorderStyleRoundedRect;
    _ruleField.placeholder = @"例如：txt / backup";
    [self.view addSubview:_ruleField];
    y += 55;
    
    // 规则内容说明
    UITextView *ruleTipView = [[UITextView alloc] initWithFrame:CGRectMake(left, y, w, 220)];
    ruleTipView.text = @"规则内容说明：\n\n"
    "1. 当选择 Documents、Library 或 tmp 目录时：\n" 
    "   - 直接填写目录或文件路径，如：backup、images/photo.jpg\n" 
    "   - 系统会自动添加目录前缀，如：Documents/backup\n\n" 
    "2. 当选择自定义目录时：\n" 
    "   - 需要填写完整路径，如：/Documents/backup\n\n" 
    "3. 后缀规则：\n" 
    "   - 直接填写文件后缀，如：txt、jpg、pdf\n\n" 
    "4. 文件名规则：\n" 
    "   - 填写完整文件名，如：config.plist、README.md\n\n" 
    "5. 正则规则：\n" 
    "   - 填写正则表达式，如：^test.*\\.txt$";
    
    ruleTipView.font = [UIFont systemFontOfSize:15];
    ruleTipView.textColor = [UIColor grayColor];
    ruleTipView.editable = NO;
    ruleTipView.selectable = YES;
    ruleTipView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:ruleTipView];
    y += 230;
    
    // 描述
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, y, w, 30)];
    descLabel.text = @"规则描述";
    [self.view addSubview:descLabel];
    y += 35;
    
    _descField = [[UITextField alloc] initWithFrame:CGRectMake(left, y, w, 45)];
    _descField.borderStyle = UITextBorderStyleRoundedRect;
    _descField.placeholder = @"例如：备份所有txt文件";
    [self.view addSubview:_descField];
    y += 55;
    
    // 启用
    UILabel *enableLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, y, 200, 30)];
    enableLabel.text = @"规则是否启用";
    [self.view addSubview:enableLabel];
    
    _enableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(w-30, y, 0, 0)];
    _enableSwitch.on = YES;
    [self.view addSubview:_enableSwitch];
}

- (void)fillEditData {
    if (!_editModel) return;
    
    _typeSegment.selectedSegmentIndex = _editModel.type;
    _actionSegment.selectedSegmentIndex = _editModel.action;
    _directorySegment.selectedSegmentIndex = _editModel.directory;
    
    // 如果不是自定义目录，提取规则内容中的目录部分
    if (_editModel.directory < 3) {
        NSString *dirName = @[@"Documents",@"Library",@"tmp"][_editModel.directory];
        if ([_editModel.rule hasPrefix:dirName]) {
            NSString *ruleContent = [_editModel.rule substringFromIndex:dirName.length];
            if ([ruleContent hasPrefix:@"/"]) {
                ruleContent = [ruleContent substringFromIndex:1];
            }
            _ruleField.text = ruleContent;
        } else {
            _ruleField.text = _editModel.rule;
        }
    } else {
        _ruleField.text = _editModel.rule;
    }
    
    _descField.text = _editModel.desc;
    _enableSwitch.on = _editModel.enable;
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save {
    SandboxRuleModel *model = self.editModel ?: [SandboxRuleModel new];
    
    model.type = (RuleType)_typeSegment.selectedSegmentIndex;
    model.action = (RuleAction)_actionSegment.selectedSegmentIndex;
    model.directory = (RuleDirectory)_directorySegment.selectedSegmentIndex;
    
    // 自动封装沙盒目录前缀
    NSString *ruleContent = self.ruleField.text ?: @"";
    NSInteger dirIndex = _directorySegment.selectedSegmentIndex;
    if (dirIndex < 3) { // 不是自定义目录
        NSString *dirName = @[@"Documents",@"Library",@"tmp"][dirIndex];
        if (ruleContent.length > 0) {
            model.rule = [NSString stringWithFormat:@"%@/%@", dirName, ruleContent];
        } else {
            model.rule = dirName;
        }
    } else {
        model.rule = ruleContent;
    }
    
    model.desc = self.descField.text;
    model.enable = self.enableSwitch.on;
    
    if (self.completion) {
        self.completion(model);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
