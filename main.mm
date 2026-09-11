#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// إنشاء نافذة مخصصة تمرر اللمس للعبة إذا ما كان الضغط على الزر
@interface PassthroughWindow : UIWindow
@end

@implementation PassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    // إذا كان اللمس على النافذة الشفافة نفسها مو على الزر، مرر اللمس للعبة
    if (hitView == self || hitView == self.rootViewController.view) {
        return nil;
    }
    return hitView;
}
@end

static PassthroughWindow *overlayWindow;
static UIButton *menuButton;

__attribute__((constructor))
static void initialize_executor() {
    dispatch_async(dispatch_get_main_queue(), ^{
        overlayWindow = [[PassthroughWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        overlayWindow.backgroundColor = [UIColor clearColor];
        
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        overlayWindow.rootViewController = vc;
        
        menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
        menuButton.frame = CGRectMake(20, 100, 60, 60);
        menuButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
        [menuButton setTitle:@"Delta" forState:UIControlStateNormal];
        [menuButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        menuButton.layer.cornerRadius = 30;
        menuButton.layer.borderWidth = 2;
        menuButton.layer.borderColor = [UIColor cyanColor].CGColor;
        
        [menuButton addTarget:vc action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [vc.view addSubview:menuButton];
        [overlayWindow setHidden:NO];
    });
}

@implementation UIViewController (ExecutorCat)
- (void)buttonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"7modyDelta"
                                                                   message:@"الواجهة شغالة واللمس شغال بحرية!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"إغلاق" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
