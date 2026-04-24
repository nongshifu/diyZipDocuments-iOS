//
//  RuleEngine.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "RuleEngine.h"

@implementation RuleEngine
+ (BOOL)matchFile:(NSString *)path rules:(NSArray *)rules {
    if (!rules.count) return YES; // 🔥 没有规则 = 全部备份
    
    for (SandboxRuleModel *r in rules) {
        if (!r.enable) continue;
        
        BOOL match = NO;
        
        if (r.type == RuleTypeSuffix) {
            match = [path.pathExtension isEqualToString:r.rule];
        }
        else if (r.type == RuleTypeFileName) {
            match = [path.lastPathComponent containsString:r.rule];
        }
        else if (r.type == RuleTypeDirectory) {
            // 当规则为空时，匹配整个目录
            if ([r.rule isEqualToString:@""]) {
                match = YES;
            } else {
                match = [path containsString:r.rule];
            }
        }
        
        if (match) {
            return r.action == RuleActionInclude;
        }
    }
    
    return NO;
}
@end
