//
//  SandboxRuleModel.m
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import "SandboxRuleModel.h"

@implementation SandboxRuleModel

- (instancetype)init {
    self = [super init];
    if (self) {
        // 生成唯一标识符
        self.identifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (NSDictionary *)toDict {
    return @{
        @"identifier": self.identifier ?: @"",
        @"type": @(self.type),
        @"action": @(self.action),
        @"directory": @(self.directory),
        @"rule": self.rule ?: @"",
        @"desc": self.desc ?: @"",
        @"enable": @(self.enable),
        @"isDefault": @(self.isDefault)
    };
}

+ (instancetype)fromDict:(NSDictionary *)dict {
    SandboxRuleModel *m = [self new];
    m.identifier = dict[@"identifier"];
    m.type = [dict[@"type"] integerValue];
    m.action = [dict[@"action"] integerValue];
    m.directory = [dict[@"directory"] integerValue];
    m.rule = dict[@"rule"];
    m.desc = dict[@"desc"];
    m.enable = [dict[@"enable"] boolValue];
    m.isDefault = [dict[@"isDefault"] boolValue];
    return m;
}
@end
