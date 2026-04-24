#import "RuleManager.h"
#import "SandboxRuleModel.h"
#import "SandboxTool.h"

@implementation RuleManager

+ (NSString *)rulePath {
    return [[SandboxTool libraryPath] stringByAppendingPathComponent:@"SandboxRules.plist"];
}

+ (NSArray *)allRules {
    NSArray *arr = [NSArray arrayWithContentsOfFile:[self rulePath]];
    NSMutableArray *list = @[].mutableCopy;
    for (NSDictionary *d in arr) {
        SandboxRuleModel *model = [SandboxRuleModel fromDict:d];
        if (model) [list addObject:model];
    }
    return list;
}

+ (void)saveRule:(SandboxRuleModel *)rule {
    if (!rule) return;
    
    NSMutableArray *all = [[self allRules] mutableCopy];
    
    // 先删除已存在的相同规则（用于编辑更新）
    NSMutableArray *toKeep = [NSMutableArray array];
    for (SandboxRuleModel *m in all) {
        // 根据唯一标识符判断是否重复
        if (![m.identifier isEqualToString:rule.identifier]) {
            [toKeep addObject:m];
        }
    }
    
    // 添加新的
    [toKeep addObject:rule];
    
    // 转字典并保存
    NSMutableArray *dicts = [NSMutableArray array];
    for (SandboxRuleModel *m in toKeep) {
        [dicts addObject:m.toDict];
    }
    
    [dicts writeToFile:[self rulePath] atomically:YES];
}

+ (void)deleteRule:(SandboxRuleModel *)rule {
    if (!rule) return;
    
    NSMutableArray *all = [[self allRules] mutableCopy];
    NSMutableArray *newArray = [NSMutableArray array];
    
    // 保留不等于要删除的规则
    for (SandboxRuleModel *m in all) {
        if (![m.identifier isEqualToString:rule.identifier]) {
            [newArray addObject:m];
        }
    }
    
    // 保存
    NSMutableArray *dicts = [NSMutableArray array];
    for (SandboxRuleModel *m in newArray) {
        [dicts addObject:m.toDict];
    }
    
    [dicts writeToFile:[self rulePath] atomically:YES];
}

+ (void)clearRules {
    [@[] writeToFile:[self rulePath] atomically:YES];
}

@end
