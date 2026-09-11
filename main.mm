#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

__attribute__((constructor))
static void initialize_executor() {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[+] Executor Dylib Injected Successfully!");
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Executor Initialized"
                                                                           message:@"تم حقن الـ Dylib بنجاح داخل روبلوكس!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"موافق" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    });
}
