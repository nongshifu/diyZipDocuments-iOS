//
//  RuleManager.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>
#import "SandboxRuleModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RuleManager : NSObject
+ (NSArray *)allRules;
+ (void)saveRule:(SandboxRuleModel *)rule;
+ (void)deleteRule:(SandboxRuleModel *)rule;
+ (void)clearRules;
@end

NS_ASSUME_NONNULL_END
