//
//  SandboxRuleModel.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RuleType) {
    RuleTypeDirectory,
    RuleTypeSuffix,
    RuleTypeFileName,
    RuleTypeRegex
};

typedef NS_ENUM(NSInteger, RuleAction) {
    RuleActionInclude,
    RuleActionExclude
};

typedef NS_ENUM(NSInteger, RuleDirectory) {
    RuleDirectoryDocuments,
    RuleDirectoryLibrary,
    RuleDirectoryTmp,
    RuleDirectoryCustom
};

@interface SandboxRuleModel : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) RuleType type;
@property (nonatomic, assign) RuleAction action;
@property (nonatomic, assign) RuleDirectory directory;
@property (nonatomic, copy) NSString *rule;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL isDefault;
- (NSDictionary *)toDict;
+ (instancetype)fromDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
