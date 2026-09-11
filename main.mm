#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static UIWindow *overlayWindow;
static UIButton *menuButton;

__attribute__((constructor))
static void initialize_executor() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1. إنشاء نافذة خاصة فوق نافذة اللعبة الأساسية
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelAlert + 1; // جعلها فوق اللعبة
        overlayWindow.backgroundColor = [UIColor clearColor];
        
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        overlayWindow.rootViewController = vc;
        
        // 2. إنشاء زر عائم مثل هك دلتا
        menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
        menuButton.frame = CGRectMake(20, 100, 70, 70);
        menuButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
        [menuButton setTitle:@"Delta" forState:UIControlStateNormal];
        [menuButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        menuButton.layer.cornerRadius = 35;
        menuButton.layer.borderWidth = 2;
        menuButton.layer.borderColor = [UIColor cyanColor].CGColor;
        
        // عند الضغط على الزر يظهر التنبيه أو المنيو
        [menuButton addTarget:vc action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [vc.view addSubview:menuButton];
        [overlayWindow setHidden:NO]; // إظهار النافذة
        
        NSLog(@"[+] Overlay Window Created Successfully!");
    });
}

// إضافة الأكشن للزر
@implementation UIViewController (ExecutorCat)
- (void)buttonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"7modyDelta"
                                                                   message:@"الواجهة شغالة 100% داخل الماب!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"إغلاق" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
