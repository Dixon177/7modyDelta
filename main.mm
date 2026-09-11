#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ExecutorUI : NSObject
+ (void)showMenu;
@end

@implementation ExecutorUI

+ (void)showMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        
        UIViewController *topVC = keyWindow.rootViewController;
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"7modyDelta iOS"
                                                                       message:@"الـ Executor شغال داخل الماب بنجاح!\nالخطوة الجاية: ربط Luau."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"حسناً" style:UIAlertActionStyleDefault handler:nil]];
        [topVC presentViewController:alert animated:YES completion:nil];
    });
}

@end

__attribute__((constructor))
static void initialize_executor() {
    // إظهار التنبيه بعد 5 ثواني من دخول الماب لضمان تحميل واجهة الماب بالكامل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ExecutorUI showMenu];
    });
}
