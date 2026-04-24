#import "TopGestureManager.h"
#import "SandboxMenuView.h"


@interface TopGestureManager ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture; // 手势存为属性
@property (nonatomic, weak) UIViewController *lastTopVC;
@end

@implementation TopGestureManager

+ (instancetype)sharedManager {
    static TopGestureManager *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startMonitor {
    if (_timer) return;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTopVC) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopMonitor {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)checkTopVC {
    NSLog(@"✅ checkTopVC");
    UIViewController *topVC = [self topViewController];
    if (!topVC) return;
    
    // 页面没变 → 跳过
    if (self.lastTopVC == topVC) return;
    self.lastTopVC = topVC;

    // 判断：手势已经添加过 → 跳过
    if (self.longGesture && [topVC.view.gestureRecognizers containsObject:self.longGesture]) {
        return;
    }

    // 没添加 → 添加手势
    [self addGestureToVC:topVC];
}

- (void)addGestureToVC:(UIViewController *)vc {
    // 先移除旧的
    if (self.longGesture) {
        [self.longGesture.view removeGestureRecognizer:self.longGesture];
    }
    
    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    ges.numberOfTouchesRequired = 2;       // 双指
    ges.minimumPressDuration = 1.0;        // 长按1秒
    ges.cancelsTouchesInView = NO;         // 不影响原有点击
    
    [vc.view addGestureRecognizer:ges];
    self.longGesture = ges; // 存到属性
}

- (void)onLongPress:(UILongPressGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateBegan) {
        NSLog(@"✅ 双指长按1秒 触发成功！");
        // 在这里写你的业务逻辑
        [SandboxMenuView showInView:[self topViewController].view];
        
    }
}

#pragma mark - 获取顶层控制器
- (UIViewController *)topViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *topVC = window.rootViewController;
    
    while (topVC.presentedViewController) {
        UIViewController *presentedVC = topVC.presentedViewController;
        
        // 排除：弹窗控制器（直接跳过，不把它当成顶层VC）
        if ([presentedVC isKindOfClass:[UIAlertController class]]) {
            break;
        }
        
        topVC = presentedVC;
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

- (void)dealloc {
    [self stopMonitor];
}

@end
