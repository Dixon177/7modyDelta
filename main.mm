#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

__attribute__((constructor))
static void initialize_executor() {
    // تشغيل صوت هز/تنبيه بالجهاز فور التحميل للتحقق بدون واجهة
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSLog(@"[+] 7modyDelta Loaded Successfully!");

    // الانتظار 3 ثواني لحد ما واجهة اللعبة تفتح تماماً
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        
        UIViewController *rootVC = keyWindow.rootViewController;
        if (rootVC) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"7modyDelta"
                                                                           message:@"تم حقن الـ Dylib بنجاح!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"تم" style:UIAlertActionStyleDefault handler:nil]];
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    });
}
