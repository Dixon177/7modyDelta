#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PassthroughWindow : UIWindow
@end

@implementation PassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || hitView == self.rootViewController.view) {
        return nil;
    }
    return hitView;
}
@end

static PassthroughWindow *overlayWindow;
static UIButton *floatingButton;
static UIView *executorMenuView;
static UITextView *scriptTextView;
static UITextField *scriptNameField;
static UITableView *savedScriptsTable;
static NSMutableArray *savedScriptsList;

@interface ExecutorController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@end

@implementation ExecutorController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // تحميل السكربتات المحفوظة من ذاكرة الجهاز
    NSArray *stored = [[NSUserDefaults standardUserDefaults] arrayForKey:@"SavedRobloxScripts"];
    if (stored) {
        savedScriptsList = [NSMutableArray arrayWithArray:stored];
    } else {
        savedScriptsList = [NSMutableArray arrayWithArray:@[
            @{@"name": @"Fly Script", @"code": @"print('Fly Loaded')"},
            @{@"name": @"Speed Hack", @"code": @"print('Speed Loaded')"}
        ]];
    }
    
    // 1. الزر العائم مع السحب
    floatingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    floatingButton.frame = CGRectMake(30, 100, 55, 55);
    floatingButton.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.12 alpha:0.95];
    [floatingButton setTitle:@"Δ" forState:UIControlStateNormal];
    [floatingButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    floatingButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    floatingButton.layer.cornerRadius = 27.5;
    floatingButton.layer.borderWidth = 2;
    floatingButton.layer.borderColor = [UIColor cyanColor].CGColor;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [floatingButton addGestureRecognizer:panGesture];
    [floatingButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:floatingButton];
    
    // 2. الواجهة الرئيسية للمنيو (حجم أكبر لتستوعب السكربتات)
    CGFloat width = 350;
    CGFloat height = 280;
    executorMenuView = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - width)/2, 60, width, height)];
    executorMenuView.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.12 alpha:0.95];
    executorMenuView.layer.cornerRadius = 12;
    executorMenuView.layer.borderWidth = 1.5;
    executorMenuView.layer.borderColor = [UIColor cyanColor].CGColor;
    executorMenuView.hidden = YES;
    
    // اسم السكربت قبل الحفظ
    scriptNameField = [[UITextField alloc] initWithFrame:CGRectMake(12, 10, 150, 28)];
    scriptNameField.placeholder = @"اسم السكربت...";
    scriptNameField.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.2 alpha:1.0];
    scriptNameField.textColor = [UIColor whiteColor];
    scriptNameField.font = [UIFont systemFontOfSize:12];
    scriptNameField.layer.cornerRadius = 5;
    [executorMenuView addSubview:scriptNameField];
    
    // زر حفظ السكربت
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.frame = CGRectMake(168, 10, 80, 28);
    saveBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1.0];
    [saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    saveBtn.layer.cornerRadius = 5;
    [saveBtn addTarget:self action:@selector(saveCurrentScript) forControlEvents:UIControlEventTouchUpInside];
    [executorMenuView addSubview:saveBtn];
    
    // مربع النص المكتوب فيه السكربت
    scriptTextView = [[UITextView alloc] initWithFrame:CGRectMake(12, 45, 210, 185)];
    scriptTextView.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.06 alpha:1.0];
    scriptTextView.textColor = [UIColor greenColor];
    scriptTextView.font = [UIFont fontWithName:@"Courier" size:12];
    scriptTextView.layer.cornerRadius = 8;
    scriptTextView.text = @"-- اكتب السكربت هنا\nprint('Script 1 Active')";
    [executorMenuView addSubview:scriptTextView];
    
    // قائمة السكربتات المحفوظة (Table View)
    savedScriptsTable = [[UITableView alloc] initWithFrame:CGRectMake(228, 45, 110, 185)];
    savedScriptsTable.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.15 alpha:1.0];
    savedScriptsTable.delegate = self;
    savedScriptsTable.dataSource = self;
    savedScriptsTable.layer.cornerRadius = 8;
    [executorMenuView addSubview:savedScriptsTable];
    
    // أزرار التحكم بالأسفل (Execute / Clear / Execute All)
    UIButton *execBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    execBtn.frame = CGRectMake(12, 238, 100, 32);
    execBtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.4 alpha:1.0];
    [execBtn setTitle:@"Execute" forState:UIControlStateNormal];
    [execBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    execBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    execBtn.layer.cornerRadius = 6;
    [execBtn addTarget:self action:@selector(executeScript) forControlEvents:UIControlEventTouchUpInside];
    [executorMenuView addSubview:execBtn];
    
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    clearBtn.frame = CGRectMake(120, 238, 70, 32);
    clearBtn.backgroundColor = [UIColor colorWithRed:0.7 green:0.2 blue:0.2 alpha:1.0];
    [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    clearBtn.layer.cornerRadius = 6;
    [clearBtn addTarget:self action:@selector(clearScript) forControlEvents:UIControlEventTouchUpInside];
    [executorMenuView addSubview:clearBtn];
    
    // زر تشغيل الكل بنفس الوقت
    UIButton *execAllBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    execAllBtn.frame = CGRectMake(198, 238, 140, 32);
    execAllBtn.backgroundColor = [UIColor colorWithRed:0.5 green:0.1 blue:0.7 alpha:1.0];
    [execAllBtn setTitle:@"Execute All Saved" forState:UIControlStateNormal];
    [execAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    execAllBtn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    execAllBtn.layer.cornerRadius = 6;
    [execAllBtn addTarget:self action:@selector(executeAllSavedScripts) forControlEvents:UIControlEventTouchUpInside];
    [executorMenuView addSubview:execAllBtn];
    
    [self.view addSubview:executorMenuView];
}

// السحب والإظهار
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    floatingButton.center = CGPointMake(floatingButton.center.x + translation.x, floatingButton.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.view];
}

- (void)toggleMenu {
    executorMenuView.hidden = !executorMenuView.hidden;
}

// حفظ السكربت بذاكرة الأيفون
- (void)saveCurrentScript {
    NSString *name = scriptNameField.text;
    NSString *code = scriptTextView.text;
    if (name.length == 0) name = [NSString stringWithFormat:@"Script %lu", (unsigned long)savedScriptsList.count + 1];
    
    [savedScriptsList addObject:@{@"name": name, @"code": code}];
    [[NSUserDefaults standardUserDefaults] setObject:savedScriptsList forKey:@"SavedRobloxScripts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [savedScriptsTable reloadData];
    scriptNameField.text = @"";
}

// التحكم بالجدول للسكربتات المحفوظة
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return savedScriptsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor cyanColor];
        cell.textLabel.font = [UIFont systemFontOfSize:11];
    }
    cell.textLabel.text = savedScriptsList[indexPath.row][@"name"];
    return cell;
}

// اختيار سكربت محفوظ لعرضه بالـ TextView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    scriptTextView.text = savedScriptsList[indexPath.row][@"code"];
}

// التشغيل
- (void)executeScript {
    NSLog(@"[+] Executing Script: %@", scriptTextView.text);
    // كود التنفيذ يربط هنا مستقبلاً
}

- (void)executeAllSavedScripts {
    for (NSDictionary *script in savedScriptsList) {
        NSLog(@"[+] Executing Parallel: %@", script[@"code"]);
    }
}

- (void)clearScript {
    scriptTextView.text = @"";
}

@end

__attribute__((constructor))
static void initialize_executor() {
    dispatch_async(dispatch_get_main_queue(), ^{
        overlayWindow = [[PassthroughWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        overlayWindow.backgroundColor = [UIColor clearColor];
        
        ExecutorController *vc = [[ExecutorController alloc] init];
        overlayWindow.rootViewController = vc;
        [overlayWindow setHidden:NO];
    });
}
