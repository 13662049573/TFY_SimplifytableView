//
//  TFY_CommonUtils.m
//  TFY_AutoLayoutModelTools
//
//  Created by 田风有 on 2019/5/10.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_CommonUtils.h"
#import <UIKit/UIKit.h>
#pragma 获取网络系统库头文件
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/socket.h>
#import <netinet/in.h>
#pragma 手机授权需求系统库头文件
#import <Photos/Photos.h>
#import <EventKit/EventKit.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <HealthKit/HealthKit.h>
#import <MediaPlayer/MediaPlayer.h>
#define IOS_10_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#pragma 各种方法需要的系统头文件
#import <CommonCrypto/CommonDigest.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
#pragma *******************************************判断获取网络数据****************************************

NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags
    
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)                ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [TFY_CommonUtils class]], @"info was wrong class in ReachabilityCallback");
    
    TFY_CommonUtils* noteObject = (__bridge TFY_CommonUtils *)info;
    [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
}

@interface TFY_CommonUtils ()<CLLocationManagerDelegate,CBCentralManagerDelegate>
#pragma 获取网络需求
@property(nonatomic , assign)SCNetworkReachabilityRef reachabilityRef;
#pragma 手机授权需求
@property(nonatomic,copy)callBack block;
@property(nonatomic, strong)CLLocationManager *locationManager; //定位
@property(nonatomic, strong)CBCentralManager *centralManager;    //蓝牙
@property(nonatomic, strong)HKHealthStore *healthStore;          //健康
@end


@implementation TFY_CommonUtils
static TFY_CommonUtils *_instance; //单例数据需求
const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};
#pragma ------------------------------------------手机获取网络监听方法---------------------------------------

+ (instancetype)reachabilityWithHostName:(NSString *)hostName{
    TFY_CommonUtils* returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL)
    {
        returnValue= [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    
    TFY_CommonUtils* returnValue = NULL;
    
    if (reachability != NULL)
    {
        returnValue = [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityForInternetConnection{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

- (BOOL)startNotifier{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}


- (void)stopNotifier{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)dealloc{
    [self stopNotifier];
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
}


#pragma mark - Network Flag Handling

- (TFY_NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags{
    PrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        return TFY_NotReachable;
    }
    TFY_NetworkStatus returnValue = TFY_NotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        returnValue = TFY_ReachableViaWiFi;
    }
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            returnValue = TFY_ReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        returnValue = TFY_ReachableViaWWAN;
    }
    
    return returnValue;
}


- (BOOL)connectionRequired{
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}
- (TFY_NetworkStatus)currentReachabilityStatus{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    TFY_NetworkStatus returnValue = TFY_NotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        returnValue = [self networkStatusForFlags:flags];
    }
    
    return returnValue;
}

/**
 获取网络状态 2G/3G/4G/wifi
 */
+(NSString *)getNetconnType{
    NSString *netcomType = @"";
    TFY_CommonUtils *reach = [TFY_CommonUtils reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case TFY_NotReachable:{
            netcomType = @"network";
        }
        break;
        case TFY_ReachableViaWiFi:{
            netcomType = @"Wifi";
        }
        break;
        case TFY_ReachableViaWWAN:{
            netcomType = [self getNetType];
        }
        break;
    }
    return netcomType;
}

//针对蜂窝网络判断是3G或者4G
+(NSString *)getNetType
{
    NSString *netconnType = nil;
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = info.currentRadioAccessTechnology;
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {netconnType = @"GPRS";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {netconnType = @"2.75G EDGE";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){netconnType = @"3G";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){netconnType = @"3.5G HSDPA";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){netconnType = @"3.5G HSUPA";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){netconnType = @"2G";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){netconnType = @"3G";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){netconnType = @"3G";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){netconnType = @"3G";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){netconnType = @"HRPD";}
    else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){netconnType = @"4G";}
    return netconnType;
}

#pragma ---------------------------------------手机权限授权方法开始---------------------------------------
/*
 * 单例
 */
+(instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    }) ;
    return _instance;
}
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [TFY_CommonUtils shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [TFY_CommonUtils shareInstance] ;
}
/**
 * 获取权限 type       类型  block      回调
 */
- (void)permissonType:(TFY_PermissionType)type withHandle:(callBack)block{
    self.block = block;
    switch (type) {
        case TFY_PermissionTypePhoto:
        {
            [self permissionTypePhotoAction];
        }
            break;
        case TFY_PermissionTypeCamera:
        {
            [self permissionTypeCameraAction];
        }
            break;
        case TFY_PermissionTypeMic:
        {
            [self permissionTypeMicAction];
        }
            break;
        case TFY_PermissionTypeLocationWhen:
        {
            [self permissionTypeLocationWhenAction];
        }
            break;
        case TFY_PermissionTypeCalendar:
        {
            [self permissionTypeCalendarAction];
        }
            break;
        case TFY_PermissionTypeContacts:
        {
            [self permissionTypeContactsAction];
        }
            break;
        case TFY_PermissionTypeBlue:
        {
            [self permissionTypeBlueAction];
        }
            break;
        case TFY_PermissionTypeRemaine:
        {
            [self permissionTypeRemainerAction];
        }
            break;
        case TFY_PermissionTypeHealth:
        {
            [self permissionTypeHealthAction];
        }
            break;
        case TFY_PermissionTypeMediaLibrary:
        {
            [self permissionTypeMediaLibraryAction];
        }
            break;
        default:
            break;
    }
}
/*
 *相册权限
 */
- (void)permissionTypePhotoAction{
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    __block TFY_CommonUtils *weakSelf = self;
    if (photoStatus == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                weakSelf.block(YES, @(photoStatus));
            } else {
                weakSelf.block(NO, @(photoStatus));
            }
        }];
    } else if (photoStatus == PHAuthorizationStatusAuthorized) {
        self.block(YES, @(photoStatus));
    } else if(photoStatus == PHAuthorizationStatusRestricted||photoStatus == PHAuthorizationStatusDenied){
        self.block(NO, @(photoStatus));
        [self pushSetting:@"相册权限"];
        
    }else{
        self.block(NO, @(photoStatus));
    }
}

/*
 *相机权限
 */
- (void)permissionTypeCameraAction{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    __block TFY_CommonUtils *weakSelf = self;
    if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            weakSelf.block(granted, @(authStatus));
        }];
    }  else if (authStatus == AVAuthorizationStatusAuthorized) {
        self.block(YES, @(authStatus));
    } else if(authStatus == AVAuthorizationStatusRestricted||authStatus == AVAuthorizationStatusDenied){
        self.block(NO, @(authStatus));
        [self pushSetting:@"相机权限"];
        
    }else{
        self.block(NO, @(authStatus));
    }
}

/*
 *麦克风权限
 */
- (void)permissionTypeMicAction{
    AVAudioSessionRecordPermission micPermisson = [[AVAudioSession sharedInstance] recordPermission];
    __block TFY_CommonUtils *weakSelf = self;
    if (micPermisson == AVAudioSessionRecordPermissionUndetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            weakSelf.block(granted, @(micPermisson));
        }];
    } else if (micPermisson == AVAudioSessionRecordPermissionGranted) {
        self.block(YES, @(micPermisson));
    } else {
        self.block(NO, @(micPermisson));
        [self pushSetting:@"麦克风权限"];
    }
}


/*
 *获取地理位置When
 */
- (void)permissionTypeLocationWhenAction{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
        }
        [self.locationManager requestWhenInUseAuthorization];
        
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
        self.block (YES, @(status));
    } else {
        self.block(NO, @(status));
        [self pushSetting:@"使用期间访问地理位置权限"];
    }
}

/*
 *日历
 */
- (void)permissionTypeCalendarAction{
    EKEntityType type  = EKEntityTypeEvent;
    __block TFY_CommonUtils *weakSelf = self;
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
    if (status == EKAuthorizationStatusNotDetermined) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError * _Nullable error) {
            weakSelf.block(granted,@(status));
        }];
    } else if (status == EKAuthorizationStatusAuthorized) {
        self.block(YES,@(status));
    } else {
        [self pushSetting:@"日历权限"];
        self.block(NO,@(status));
    }
}


/*
 *联系人
 */
- (void)permissionTypeContactsAction{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    __block TFY_CommonUtils *weakSelf = self;
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                weakSelf.block(granted,[weakSelf openContact]);
            }
            weakSelf.block(granted,@(status));
        }];
    } else if (status == CNAuthorizationStatusAuthorized) {;
        self.block(YES,[self openContact]);
    } else {
        self.block(NO,@(status));
        [self pushSetting:@"联系人权限"];
    }
}


/*
 *蓝牙
 */
- (void)permissionTypeBlueAction{
    if (!self.centralManager) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
}

/*
 * 提醒
 */
- (void)permissionTypeRemainerAction{
    EKEntityType type  = EKEntityTypeReminder;
    __block TFY_CommonUtils *weakSelf = self;
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
    if (status == EKAuthorizationStatusNotDetermined) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError * _Nullable error) {
            weakSelf.block(granted,@(status));
        }];
    } else if (status == EKAuthorizationStatusAuthorized) {
        self.block(YES,@(status));
    } else {
        [self pushSetting:@"日历权限"];
        self.block(NO,@(status));
    }
}

/*
 * 健康
 */
- (void)permissionTypeHealthAction{
    //查看healthKit在设备上是否可用，ipad不支持HealthKit
    NSError *error;
    if (![HKHealthStore isHealthDataAvailable]) {self.block(NO, error);return;}
    if (!self.healthStore) {self.healthStore = [HKHealthStore new];}
    __block TFY_CommonUtils *weakSelf = self;
    NSSet *writeDataTypes = [self dataTypesToWrite];//写权限
    NSSet *readDataTypes = [self dataTypesRead];//读权限
    [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [weakSelf readStepCount];
        }else{
            weakSelf.block(NO, error);
        }
    }];
}
- (NSSet *)dataTypesToWrite
{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *temperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    return [NSSet setWithObjects:heightType, temperatureType, weightType,activeEnergyType,nil];
}
- (NSSet *)dataTypesRead
{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *temperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    return [NSSet setWithObjects:heightType, temperatureType,birthdayType,sexType,weightType,stepCountType, activeEnergyType,nil];
}

/*
 * 多媒体
 */
- (void)permissionTypeMediaLibraryAction{
    __block TFY_CommonUtils *weakSelf = self;
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
        switch (status) {
            case MPMediaLibraryAuthorizationStatusNotDetermined: {
                weakSelf.block(NO, @(status));
                break;
            }
            case MPMediaLibraryAuthorizationStatusRestricted: {
                weakSelf.block(NO, @(status));
                break;
            }
            case MPMediaLibraryAuthorizationStatusDenied: {
                weakSelf.block(NO, @(status));
                break;
            }
            case MPMediaLibraryAuthorizationStatusAuthorized: {
                // authorized
                weakSelf.block(YES, @(status));
                break;
            }
            default: {
                break;
            }
        }
        
    }];
}

/*
 * 查询步数数据
 */
- (void)readStepCount
{
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    __block TFY_CommonUtils *weakSelf = self;
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:[TFY_CommonUtils predicateForSamplesToday] limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if(error){
            weakSelf.block(NO, error);
        }
        else{
            NSInteger totleSteps = 0;
            for(HKQuantitySample *quantitySample in results)
            {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heightUnit = [HKUnit countUnit];
                double usersHeight = [quantity doubleValueForUnit:heightUnit];
                totleSteps += usersHeight;
            }
            weakSelf.block(YES,@(totleSteps));
        }
    }];
    [self.healthStore executeQuery:query];

}

/*
 *跳转设置
 */
- (void)pushSetting:(NSString*)urlStr{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@%@",urlStr,@"尚未开启,是否前往设置"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (IOS_10_OR_LATER) {
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication]openURL:url options:@{}completionHandler:^(BOOL        success) {
                }];
            }
        }else{
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication]openURL:url];
            }
        }
    }];
    [alert addAction:okAction];
    [[TFY_CommonUtils getCurrentVC] presentViewController:alert animated:YES completion:nil];
}

//获取当前VC
+ (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

/*!
 *  @brief  当天时间段(可以获取某一段时间)
 *
 *  @return 时间段
 */
+ (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}


//有通讯录权限-- 获取通讯录
- (NSArray*)openContact{
    // 获取指定的字段
    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSMutableArray *arr = [NSMutableArray new];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        //拼接姓名
        NSString *nameStr = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
        
        NSArray *phoneNumbers = contact.phoneNumbers;
        
        for (CNLabeledValue *labelValue in phoneNumbers) {
            CNPhoneNumber *phoneNumber = labelValue.value;
            NSString * string = phoneNumber.stringValue ;
            //去掉电话中的特殊字符
            string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            [arr addObject:@{@"name":nameStr,@"phone":string}];
        }
    }];
    return [NSArray arrayWithArray:arr];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.block(YES, error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.block(YES, newLocation);
    [self stopLocationService];
}

- (void)stopLocationService
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate=nil;
    self.locationManager = nil;
}

#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSError *error=nil;
    //蓝牙第一次以及之后每次蓝牙状态改变都会调用这个函数
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        NSLog(@"蓝牙设备开着");
        
        self.block(YES, error);
    }
    else
    {
        NSLog(@"蓝牙设备关着");
        self.block(NO, error);
    }
}

#pragma ------------------------------------------各种方法使用------------------------------------------

/**
 *  NSDictionary或NSArray转换为NSString
 */
+(NSString *)toJSONString:(id)theData{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil){
        NSString *jsonStr_ = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonStr_;
    }
    else{return nil;}
}
//formart时间戳格式("yyyy-MM-dd HH-mm-ss")
+(NSString *)dateStringWithDate:(NSDate *)date formart:(NSString *)formart
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formart];
    NSString *dataStr = [dateFormatter stringFromDate:date];
    return dataStr;
}
/**
 *  //时间戳转化为NSDate formart时间戳格式("yyyy-MM-dd HH-mm-ss")
 */
+(NSDate *)dateWithNSString:(NSString*)string formart:(NSString *)formart{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formart];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}
/**
 *  根据日期计算N个月前的日期
 */
+(NSDate *)dateOfPreviousMonth:(NSInteger)previousMonthCount WithDate:(NSDate *)fromDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *comps = nil;
    
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:fromDate];
    
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    
    [adcomps setYear:0];
    
    [adcomps setMonth:-previousMonthCount];
    
    [adcomps setDay:0];
    
    NSDate *resultDate_ = [calendar dateByAddingComponents:adcomps toDate:fromDate options:0];
    
    return resultDate_;
}
/**
 *  获取长度为stringLength的随机字符串, 随机数字字符混合类型字符串函数
 */
+(NSString *)getRandomString:(NSInteger)stringLength{
    NSMutableString *randomString_ = [NSMutableString string];
    NSString *baseString_ = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (int i=0; i<stringLength; i++)
    {
        NSInteger count_ = arc4random()%(baseString_.length);
        NSString *subStr_ = [baseString_ substringWithRange:NSMakeRange(count_, 1)];
        [randomString_ appendString:subStr_];
    }
    return randomString_;
}
/**
 *  随机数字类型字符串函数
 */
+(NSString *)getRandomNumberString:(NSInteger)stringLength{
    NSMutableString *randomString_ = [NSMutableString string];
    NSString *baseString_ = @"0123456789";
    for (int i=0; i<stringLength; i++)
    {
        NSInteger count_ = arc4random()%(baseString_.length);
        NSString *subStr_ = [baseString_ substringWithRange:NSMakeRange(count_, 1)];
        [randomString_ appendString:subStr_];
    }
    
    return randomString_;
}
/**
 *  随机字符类型字符串函数
 */
+(NSString *)getRandomCharacterString:(NSInteger)stringLength{
    NSMutableString *randomString_ = [NSMutableString string];
    NSString *baseString_ = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    for (int i=0; i<stringLength; i++)
    {
        NSInteger count_ = arc4random()%(baseString_.length);
        NSString *subStr_ = [baseString_ substringWithRange:NSMakeRange(count_, 1)];
        [randomString_ appendString:subStr_];
    }
    
    return randomString_;
}
/**
 *  获取wifi信号 method
 */
+(NSString*)currentWifiSSID{
    NSString *ssid = nil;
    NSArray *ifs = (__bridge  id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs)
    {
        NSDictionary *info = (__bridge  id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        ssid = [info objectForKey:@"SSID"];
        if (ssid)
            break;
    }
    return ssid;
}
/**
 *  获取设备的UUID
 */
+(NSString *)gen_uuid{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}
/**
 *  替换掉Json字符串中的换行符
 */
+(NSString *)ReplacingNewLineAndWhitespaceCharactersFromJson:(NSString *)jsonStr{
    NSScanner *scanner = [[NSScanner alloc] initWithString:jsonStr];
    [scanner setCharactersToBeSkipped:nil];
    NSMutableString *result = [[NSMutableString alloc] init];
    
    NSString *temp;
    NSCharacterSet*newLineAndWhitespaceCharacters = [NSCharacterSet newlineCharacterSet];
    // 扫描
    while (![scanner isAtEnd])
    {
        temp = nil;
        [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
        if (temp) [result appendString:temp];
        
        // 替换换行符
        if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
            if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                [result appendString:@"|"];
        }
    }
    return result;
}
/**
 * 直接调用这个方法即可签名成功
 */
+ (NSString *)serializeURL:(NSString *)baseURL Token:(NSString *)token params:(NSDictionary *)params
{
    
    NSURL* parsedURL = [NSURL URLWithString:[baseURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:[self parseQueryString:[parsedURL query]]];
    if (params)
    {
        [paramsDic setValuesForKeysWithDictionary:params];
    }
    NSMutableString *paramsString = [NSMutableString stringWithFormat:@""];//字符串
    NSArray *sortedKeys = [[paramsDic allKeys] sortedArrayUsingSelector: @selector(compare:)];//排序
    
    NSMutableArray *parametersArray = [[NSMutableArray alloc] init];
    for (NSString *key in sortedKeys)
    {
        id value = [params objectForKey :key];
        
        if ([value isKindOfClass :[NSString class]])
        {
            [parametersArray addObject :[NSString stringWithFormat:@"%@=%@",key,value]];
            
        }
    }
    NSString *str=[parametersArray componentsJoinedByString:@"&"];
    
    [paramsString appendString:str];
    
    NSString *md5=[NSString stringWithFormat:@"%@%@",str,token];//Token公司秘钥
    NSString * mdfiveString = [self md5HexDigest:md5];//MD5加密
    
    [paramsString appendFormat:@"&sign=%@", mdfiveString];//加密后即获得签名串
    
    return [NSString stringWithFormat:@"%@://%@%@?%@", [parsedURL scheme], [parsedURL host], [parsedURL path], [paramsString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
}
+(NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] <= 1) {
            return nil;
        }
        NSString *key = [[elements objectAtIndex:0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSString *val = [[elements objectAtIndex:1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [dict setObject:val forKey:key];
    }
    return dict;
}

/*MD5加密*/
+(NSString *)md5HexDigest:(NSString *)str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    NSString * mdfiveString = [hash lowercaseString];
    
    return mdfiveString;
}

+(NSString *)HTTPBodyWithParameters:(NSDictionary *)parameters Token:(NSString *)token{
    
    NSMutableArray *parametersArray = [[NSMutableArray alloc] init];
    
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector: @selector(compare:)];//排序
    
    for (NSString *key in sortedKeys)
    {
        
        [parametersArray addObject :[NSString stringWithFormat:@"%@=%@",key,[parameters objectForKey:key]]];
        
    }
    NSString *md5=[NSString stringWithFormat:@"%@%@",[parametersArray componentsJoinedByString : @"&"],token];
    return  [self md5HexDigest:md5];
}
/**
 *  返回一个请求头
 */
+(NSString *)parmereaddWithDict:(NSDictionary *)dict Token:(NSString *)token{
    NSMutableArray *parametersArray = [[NSMutableArray alloc] init];
    
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(compare:)];//排序
    
    for (NSString *key in sortedKeys)
    {
        [parametersArray addObject :[NSString stringWithFormat:@"%@=%@",key,[dict objectForKey:key]]];
    }
    NSString *parme=[NSString stringWithFormat:@"%@&sign=%@",[parametersArray componentsJoinedByString : @"&"],[self HTTPBodyWithParameters:dict Token:token]];
    
    return  parme;
}
/**
 *  把多个json字符串转为一个json字符串
 */
+(NSString *)objArrayToJSON:(NSArray *)array{
    NSString *jsonStr = @"[";
    for (NSInteger i = 0; i < array.count; ++i) {
        if (i != 0) {
            jsonStr = [jsonStr stringByAppendingString:@","];
        }
        jsonStr = [jsonStr stringByAppendingString:array[i]];
    }
    jsonStr = [jsonStr stringByAppendingString:@"]"];
    return jsonStr;
}
/**
 *   获取当前时间
 */
+(NSString *)audioTime{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    return timeNow;
}
/**
 *   字符串时间——时间戳
 */
+(NSString *)cTimestampFromString:(NSString *)theTime{
    //装换为时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    formatter.locale=[NSLocale localeWithLocaleIdentifier:@"en_us"];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* dateTodo = [formatter dateFromString:theTime];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[dateTodo timeIntervalSince1970]];
    return timeSp;
}
/**
 *   时间戳——字符串时间
 */
+(NSString *)cStringFromTimestamp:(NSString *)timestamp{
    //时间戳转时间的方法
    NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *strTime = [dateFormatter stringFromDate:timeData];
    return strTime;
}
/**
 *  两个时间之差
 */
+(NSString *)intervalFromLastDate:(NSString *)dateString1 toTheDate:(NSString *)dateString2{
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    dateString1=[timeArray1 objectAtIndex:0];
    
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    dateString2=[timeArray2 objectAtIndex:0];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *d1=[date dateFromString:dateString1];
    
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    
    NSDate *d2=[date dateFromString:dateString2];
    
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *house=@"";
    NSString *min=@"";
    NSString *sen=@"";
    sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    sen=[NSString stringWithFormat:@"%@", sen];
    min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    min=[NSString stringWithFormat:@"%@", min];
    house = [NSString stringWithFormat:@"%d", (int)cha/3600];
    house=[NSString stringWithFormat:@"%@", house];
    timeString=[NSString stringWithFormat:@"%@时%@分%@秒",house,min,sen];
    return timeString;
}
/**
 *   一个时间距现在的时间
 */
+(NSString *)intervalSinceNow:(NSString *)theDate{
    NSArray *timeArray=[theDate componentsSeparatedByString:@"."];
    theDate=[timeArray objectAtIndex:0];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate * d= [date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=late-now;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"剩余%@分", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"剩余%@小时", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"剩余%@天", timeString];
        
    }
    return timeString;
}
/**
 *  将字符串转化为中文时间
 */
+(NSString *)Formatter:(NSString *)time{
    NSString* string = time;
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMM"];
    NSDate* inputDate = [inputFormatter dateFromString:string];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy年MM月"];
    NSString *str = [outputFormatter stringFromDate:inputDate];
    NSString *index=[str substringWithRange:NSMakeRange(5,2)];
    NSString *sssss= [self mone:[index integerValue]];
    // NSString *string5= [self translation:index];
    return sssss;
}
+(NSString *)mone:(NSInteger )mones{
    switch (mones) {
        case 1:
            return @"一月";
            break;
        case 2:
            return @"二月";
            break;
        case 3:
            return @"三月";
            break;
        case 4:
            return @"四月";
            break;
        case 5:
            return @"五月";
            break;
        case 6:
            return @"六月";
            break;
        case 7:
            return @"七月";
            break;
        case 8:
            return @"八月";
            break;
        case 9:
            return @"九月";
            break;
        case 10:
            return @"十月";
            break;
        case 11:
            return @"十一月";
            break;
        case 12:
            return @"十二月";
            break;
    }
    return [NSString stringWithFormat:@"%ld",(long)mones];
}
/**
 *  去掉手机号码上的+号和+86
 */
+ (NSString *)formatPhoneNum:(NSString *)phone{
    if ([phone hasPrefix:@"86"]) {
        NSString *formatStr = [phone substringWithRange:NSMakeRange(2, [phone length]-2)];
        return formatStr;
    }
    else if ([phone hasPrefix:@"+86"])
    {
        if ([phone hasPrefix:@"+86·"]) {
            NSString *formatStr = [phone substringWithRange:NSMakeRange(4, [phone length]-4)];
            return formatStr;
        }
        else
        {
            NSString *formatStr = [phone substringWithRange:NSMakeRange(3, [phone length]-3)];
            return formatStr;
        }
    }
    return phone;
}
/**
 *  手机系统版本
 */
+(NSString *)phoneVersions{
    return [[UIDevice currentDevice] systemVersion];
}
/**
 *  设备名称
 */
+(NSString *)deviceName{
    return [[UIDevice currentDevice] systemName];
}
/**
 *  获取当前版本号
 */
+(NSString *)cfbundleVersion{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}
/**
 *  获取当前应用名称
 */
+(NSString *)cfbundleDisplayName{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
}
/**
 *  当前应用软件版本
 */
+(NSString *)cfbundleShortVersionString{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}
/**
 *  国际化区域名称
 */
+(NSString *)localizedModel{
    return [[UIDevice currentDevice] localizedModel];
}
/**
 *  获取当前年份
 */
+(NSString *)setDateFormat{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}
/**
 *  当前使用的语言
 */
+(NSString *)defaultsTH{
    //取得用户默认信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 取得 iPhone 支持的所有语言设置
    NSArray *languages = [defaults objectForKey :@"AppleLanguages" ];
    // 获得当前iPhone使用的语言
    NSString* currentLanguage =[languages objectAtIndex:0];
    return currentLanguage;
}
/**
 *  程序主目录，可见子目录(3个):Documents、Library、tmp
 */
+ (NSString *)homePath{
    return NSHomeDirectory();
}
/**
 *   程序目录，不能存任何东西
 */
+(NSString *)appPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
/**
 *  文档目录，需要ITUNES同步备份的数据存这里，可存放用户数据
 */
+(NSString *)docPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
/**
 *  配置目录，配置文件存这里
 */
+(NSString *)libPrefPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Preference"];
}
/**
 *  缓存目录，系统永远不会删除这里的文件，ITUNES会删除
 */
+(NSString *)libCachePath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
}
/**
 *  临时缓存目录，APP退出后，系统可能会删除这里的内容
 */
+(NSString *)tmpPath{
    return [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
}
/**
 *  获取本机IP
 */
+(NSString *)getIPAddress{
    NSURL *ipURL = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    NSData *data = [NSData dataWithContentsOfURL:ipURL];
    if (data==nil) {
        return  @"0.0.0.0";
    }
    NSDictionary *ipDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *ipStr = nil;
    if (ipDic && [ipDic[@"code"] integerValue] == 0) { //获取成功
        ipStr = ipDic[@"data"][@"ip"];
        NSLog(@">>>%@",ipStr);
    }
    return (ipStr ? ipStr : @"0.0.0.0");
}
/**
 *  获取WIFI的MAC地址
 */
+(NSString *)getWifiBSSID{
    return (NSString *)[self fetchSSIDInfo][@"BSSID"];
}
/**
 *   获取WIFI名字
 */
+(NSString *)getWifiSSID{
     return (NSString *)[self fetchSSIDInfo][@"SSID"];
}
+ (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
            break;
        }
    }
    return info;
}
/**
 *  截取字符串后几位
 */
+(NSString *)substring:(NSString *)substring length:(NSInteger )lengths{
    return [substring substringFromIndex:substring.length-lengths];
}
/**
 *  不需要加密的参数请求
 */
+(NSString *)requestparmereaddWithDict:(NSDictionary *)dict{
    NSMutableArray *parametersArray = [[NSMutableArray alloc] init];
    
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(compare:)];//排序
    
    for (NSString *key in sortedKeys)
    {
        [parametersArray addObject :[NSString stringWithFormat:@"%@=%@",key,[dict objectForKey:key]]];
    }
    NSString *parme=[NSString stringWithFormat:@"%@",[parametersArray componentsJoinedByString : @"&"]];
    
    return  parme;
}
/**
 *  秒数转换成时间,时，分，秒 转换成时分秒
 */
+(NSString *)timeFormatted:(int)totalSeconds{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    int day = hours/24;
    return [NSString stringWithFormat:@"%d天 %d时 %d分 %d秒",day,hours,minutes,seconds];
}
/**
 *   将时间数据（毫秒）转换为天和小时
 */
+(NSString*)getOvertime:(NSString*)mStr{
    long msec = (long)[mStr longLongValue];
    
    if (msec <= 0){
        return @"";
    }
    
    NSInteger d = msec/1000/60/60/24;
    NSInteger h = msec/1000/60/60%24;
    //NSInteger  m = msec/1000/60%60;
    //NSInteger  s = msec/1000%60;
    
    NSString *_tStr = @"";
    NSString *_dStr = @"";
    NSString *_hStr = @"";
    NSString *_hTimeType = @"defaultColor";
    
    if (d > 0)
    {
        _dStr = [NSString stringWithFormat:@"%ld天",(long)d];
    }
    
    if (h > 0)
    {
        _hStr = [NSString stringWithFormat:@"%ld小时",(long)h];
    }
    
    //小于2小时 高亮显示
    if (h > 0 && h < 2)
    {
        _hTimeType = @"hightColor";
    }
    
    _tStr = [NSString stringWithFormat:@"%@%@后到期-%@",_dStr,_hStr,_hTimeType];
    
    return _tStr;
}
/**
 *   获取图片格式
 */
+(NSString *)typeForImageData:(NSData *)data{
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @"image/jpg";
            
        case 0x89:
            
            return @"image/png";
            
        case 0x47:
            
            return @"image/gif";
            
        case 0x49:
            
        case 0x4D:
            
            return @"image/tiff";
            
    }
    
    return nil;
}
/**
 *  指定字符串末尾倒数第5个 是 . 替换成自己需要的字符
 */
+(NSString *)stringByReplacing_String:(NSString *)str withString:(NSString *)String{
    return [str stringByReplacingOccurrencesOfString:@"." withString:String options:NSBackwardsSearch range:NSMakeRange(str.length-5, 5)];
}
/**
 *  字典转化成字符串
 */
+(NSString*)dictionaryToJsonString:(NSDictionary *)dic{
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if(error) {
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
/**
 *  图片转f字符串
 */
+(NSString *)imageToString:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    return [data base64EncodedStringWithOptions:0];
}
/**
 *   出生日期计算星座
 */
+(NSString *)getAstroWithMonth:(int)m day:(int)d{
    NSString *astroString = @"摩羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手摩羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    if(m==2 && d>29)
    {
        return @"错误日期格式!!";
    }else if(m==4 || m==6 || m==9 || m==11) {
        if (d>30) {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}
/**
 *   计算生肖
 */
+(NSString *)getZodiacWithYear:(NSString *)year{
    NSInteger constellation = ([year integerValue] - 4)%12;
    NSString * result;
    switch (constellation) {
        case 0:result = @"鼠";break;
        case 1:result = @"牛";break;
        case 2:result = @"虎";break;
        case 3:result = @"兔";break;
        case 4:result = @"龙";break;
        case 5:result = @"蛇";break;
        case 6:result = @"马";break;
        case 7:result = @"羊";break;
        case 8:result = @"猴";break;
        case 9:result = @"鸡";break;
        case 10:result = @"狗";break;
        case 11:result = @"猪";break;
        default:
            break;
    }
    return result;
}
/**
 *  将中文字符串转为拼音
 */
+(NSString *)chineseStringToPinyin:(NSString *)string{
    // 将中文字符串转成可变字符串
    NSMutableString *pinyinText = [[NSMutableString alloc] initWithString:string];
    // 先转换为带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformMandarinLatin, NO);// 输出 pinyin: zhōng guó sì chuān
    // 再转换为不带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformStripDiacritics, NO);// 输出 pinyin: zhong guo si chuan
    // 转换为首字母大写拼音
    NSString *newString = [NSString stringWithFormat:@"%@",pinyinText];
    NSString *newStr = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return newStr.lowercaseString;
}
/**
 *  iOS 隐藏手机号码中间的四位数字
 */
+(NSString *)numberSuitScanf:(NSString*)number{
    BOOL isOk = [TFY_CommonUtils mobilePhoneNumber:number];;
    if (isOk) {//如果是手机号码的话
        NSString *numberString = [number stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        return numberString;
    }
    return number;
}
/**
 *  设置银行卡号的格式方法
 */
+(NSString *)getNewBankNumWitOldBankNum:(NSString *)bankNum{
    NSMutableString *mutableStr;
    if (bankNum.length) {
        mutableStr = [NSMutableString stringWithString:bankNum];
        for (int i = 0 ; i < mutableStr.length; i ++) {
            
            if(i>=0&&i<mutableStr.length - 4) {
                [mutableStr replaceCharactersInRange:NSMakeRange(i, 1) withString:@"*"];
            }
        }
        NSString *text = mutableStr;
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *newString = @"";
        while (text.length > 0) {
            NSString *subString = [text substringToIndex:MIN(text.length, 4)];
            newString = [newString stringByAppendingString:subString];
            if (subString.length == 4) {
                newString = [newString stringByAppendingString:@" "];
            }
            text = [text substringFromIndex:MIN(text.length, 4)];
        }
        return newString;
        
    }
    return bankNum;
}

/**
 *  判断字符串是否是纯数字
 */
+(BOOL)isPureNumber:(NSString *)string{
    NSString *numberRegex = @"([1-9][0-9]*||[0-9][0-9]+)";
    NSPredicate *idCardNumberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    BOOL isPureNum_ = [idCardNumberTest evaluateWithObject:string];
    return isPureNum_;
}
/**
 *  判断数组是否为空
 */
+(BOOL)isBlankArray:(NSArray *)array{
    if (array == nil || [array isKindOfClass:[NSNull class]] || ![array isKindOfClass:[NSArray class]] || array.count == 0) {
        return YES;
    }
    return NO;
}
/**
 *  拿去存储的当前状态
 */
+(BOOL)addWithisLink:(NSString *)isLink{
    NSUserDefaults *defaultison = [NSUserDefaults standardUserDefaults];
    return [defaultison boolForKey:isLink];
}
/**
 *  判断目录是否存在，不存在则创建
 */
+(BOOL)hasLive:(NSString *)path{
    if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:path] ){
        return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return NO;
}
/**
 *   判断字符串是否为空  @return YES or NO
 */
+(BOOL)judgeIsEmptyWithString:(NSString *)string{
    if (string.length == 0 || [string isEqualToString:@""] || string == nil || string == NULL || [string isEqual:[NSNull null]] || [string isEqualToString:@" "] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"])
    {
        return YES;
    }
    return NO;
}
/**
 * 检测字符串中是否包含表情符号
 */
+(BOOL)stringContainsEmoji:(NSString *)string{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}
/**
 * 判断字符串是否是整形数字
 */
+(BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}
/**
 * 判断是否为空NSNumber对象，nil,NSNull都为空，不是NSNumber对象也判为空
 */
+(BOOL)emptyNSNumber:(NSNumber *)number{
    if (number == nil || [number isKindOfClass:[NSNull class]] || ![number isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    return NO;
}
/**
 *  判断是否为空NSDictionary对象，nil,NSNull,@{}都为空,零个键值对也是空，不是NSDictionary对象也判为空
 */
+(BOOL)emptyNSDictionary:(NSDictionary *)dictionary{
    if (dictionary == nil || [dictionary isKindOfClass:[NSNull class]] || ![dictionary isKindOfClass:[NSDictionary class]] || dictionary.allKeys == 0) {
        return YES;
    }
    return NO;
}
/**
 *  判断是否为空NSSet对象，nil,NSNull,@{}都为空，零个键值对也是空不是NSSet对象也判为空
 */
+(BOOL)emptyNSSet:(NSSet *)set{
    if (set == nil || [set isKindOfClass:[NSNull class]] || ![set isKindOfClass:[NSSet class]] || set.count == 0) {
        return YES;
    }
    return NO;
}
/**
 *  判断email格式是否正确，正则表达式不够好，慎用
 */
+(BOOL)email:(NSString *)email{
    NSString *patternEmail = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    
    if ([self judgeIsEmptyWithString:email]) {
        return NO;
    } else {
        return [self regular:patternEmail withString:email];
    }
}
+(BOOL)regular:(NSString *)regular withString:(NSString *)string {
    NSError *error = NULL;
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regular options:0 error:&error];
    
    NSTextCheckingResult *result = [regularExpression firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (result > 0) {
        return YES;
    }
    return NO;
}
/**
 *  验证手机号
 */
+(BOOL)mobilePhoneNumber:(NSString *)mobile{
    BOOL  mobilebool =[self isPureNumber:mobile];
    if (mobilebool==YES) {
        NSString *patternMobile = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0-9]))\\d{8}$";
        
        if ([self judgeIsEmptyWithString:mobile]) {
            return NO;
        } else {
            return [self regular:patternMobile withString:mobile];
        }
    }
    else{
        return NO;
    }
}
/**
 *  判断是否全数字 符合则为YES，不符合则为NO
 */
+ (BOOL)OnlyDigitalNumber:(NSString *)number{
    NSString *patternFloatNumber = @"^[0-9]+$";
    if ([self judgeIsEmptyWithString:number]) {
        return NO;
    } else {
        return [self regular:patternFloatNumber withString:number];
    }
}
/**
 * 判断是不是小数，如1.2这样  符合则为YES，不符合则为NO
 */
+(BOOL)floatNumber:(NSString *)number{
    if ([self judgeIsEmptyWithString:number]) {
        return NO;
    } else {
        
        NSString *signNumber = [number substringToIndex:1];
        NSString *finalString = number;
        if ([signNumber isEqualToString:@"-"] || [signNumber isEqualToString:@"+"]) {
            finalString = [number substringFromIndex:1];
        }
        
        NSRange dotRange = [finalString rangeOfString:@"."];
        if (dotRange.location == NSNotFound) {
            return [self OnlyDigitalNumber:finalString];
        } else {
            if (dotRange.length ==1) {
                NSString *leftSting = [finalString substringToIndex:dotRange.location];
                NSString *rightString = [finalString substringFromIndex:dotRange.location+1];
                
                return [self OnlyDigitalNumber:leftSting] && [self OnlyDigitalNumber:rightString];
                
            } else {
                return NO;
            }
            
        }
    }
}
/**
 *   判断版本号是否发生变化，有为 yes
 */
+(BOOL)version_CFBundleShortVersionString{
    // 1.当前应用软件版本
    NSString *currentVersion = [self cfbundleShortVersionString];
    // 2.获取上一次的版本号
    NSString *lastVersion = [self getStrValueInUDWithKey:@"VersionKey"];
    
    if ([currentVersion isEqualToString:lastVersion]) {
        return NO;
    }else{
        [self saveStrValueInUD:currentVersion forKey:@"VersionKey"];
        return YES;
    }
}
/*
 *  判断手机是否越狱
 */
+(BOOL)isJailBreak{
    BOOL isYUEYU = [self mgjpf_isJailbroken];
    if (isYUEYU) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"检测到此设备为越狱设备，此应用暂不支持该设备使用" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            exit(0);
        }];
        [alert addAction:okAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return isYUEYU;
    }
    return isYUEYU;
}
+(BOOL)mgjpf_isJailbroken
{
    //以下检测的过程是越往下，越狱越高级
    
    //    /Applications/Cydia.app, /privte/var/stash
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    
    if ([self isJailBreak1]) {
        jailbroken = YES;
    }
    
    if ([self isJailBreak2]) {
        jailbroken = YES;
    }
    
    if ([self isJailBreak3]) {
        jailbroken = YES;
    }
    //可能存在hook了NSFileManager方法，此处用底层C stat去检测
    struct stat stat_info;
    if (0 == stat("/Library/MobileSubstrate/MobileSubstrate.dylib", &stat_info)) {
        jailbroken = YES;
    }
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        jailbroken = YES;
    }
    if (0 == stat("/var/lib/cydia/", &stat_info)) {
        jailbroken = YES;
    }
    if (0 == stat("/var/cache/apt", &stat_info)) {
        jailbroken = YES;
    }
    //    /Library/MobileSubstrate/MobileSubstrate.dylib 最重要的越狱文件，几乎所有的越狱机都会安装MobileSubstrate
    //    /Applications/Cydia.app/ /var/lib/cydia/绝大多数越狱机都会安装
    //    /var/cache/apt /var/lib/apt /etc/apt
    //    /bin/bash /bin/sh
    //    /usr/sbin/sshd /usr/libexec/ssh-keysign /etc/ssh/sshd_config
    
    //可能存在stat也被hook了，可以看stat是不是出自系统库，有没有被攻击者换掉
    //这种情况出现的可能性很小
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char *,struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSLog(@"lib:%s",dylib_info.dli_fname);      //如果不是系统库，肯定被攻击了
        if (strcmp(dylib_info.dli_fname, "/usr/lib/system/libsystem_kernel.dylib")) {   //不相等，肯定被攻击了，相等为0
            jailbroken = YES;
        }
    }
    
    //还可以检测链接动态库，看下是否被链接了异常动态库，但是此方法存在appStore审核不通过的情况，这里不作罗列
    //通常，越狱机的输出结果会包含字符串： Library/MobileSubstrate/MobileSubstrate.dylib——之所以用检测链接动态库的方法，是可能存在前面的方法被hook的情况。这个字符串，前面的stat已经做了
    
    //如果攻击者给MobileSubstrate改名，但是原理都是通过DYLD_INSERT_LIBRARIES注入动态库
    //那么可以，检测当前程序运行的环境变量
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSLog(@"%s",env);
    if (env != NULL) {
        jailbroken = YES;
    }
    return jailbroken;
}
+(BOOL)isJailBreak3
{
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            NSLog(@"The device is jail broken!");
            return YES;
        }
    }
    NSLog(@"The device is NOT jail broken!");
    
    return NO;
}
+(BOOL)isJailBreak1
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"The device is jail broken!");
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}



#define USER_APP_PATH   @"/User/Applications/"

+(BOOL)isJailBreak2
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        NSLog(@"The device is jail broken!");
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        NSLog(@"applist = %@", applist);
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}
/**
 *  判断是否需要过滤的特殊字符：~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€。
 */
+(BOOL)isIncludeSpecialCharact:(NSString *)str{
    //***需要过滤的特殊字符：~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€。
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€"]];
    if (urgentRange.location == NSNotFound)
    {
        return NO;
    }
    return YES;
}
/**
 *  存储当前BOOL
 */
+(void)saveBoolValueInUD:(BOOL)value forKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:value forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSString
 */
+(void)saveStrValueInUD:(NSString *)str forKey:(NSString *)key{
    if(!str){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:str forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSData
 */
+(void)saveDataValueInUD:(NSData *)data forKey:(NSString *)key{
    if(!data){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:data forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSDictionary
 */
+(void)saveDicValueInUD:(NSDictionary *)dic forKey:(NSString *)key{
    if(!dic){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:dic forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSArray
 */
+(void)saveArrValueInUD:(NSArray *)arr forKey:(NSString *)key{
    if(!arr){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:arr forKey:key];
    [ud synchronize];

}
/**
 *  存储当前NSDate
 */
+(void)saveDateValueInUD:(NSDate *)date forKey:(NSString *)key{
    if(!date){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:date forKey:key];
    [ud synchronize];
}
/**
 *  存储当前NSInteger
 */
+(void)saveIntValueInUD:(NSInteger)value forKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:value forKey:key];
    [ud synchronize];
}
/**
 *   保存模型id
 */
+(void)saveValueInUD:(id)value forKey:(NSString *)key{
    if(!value){
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:value forKey:key];
    [ud synchronize];
}
/**
 *  获取保存的id
 */
+(id)getValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud valueForKey:key];
}
/**
 *  获取保存的NSDate
 */
+(NSDate *)getDateValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud valueForKey:key];
}
/**
 *  获取保存的NSString
 */
+(NSString *)getStrValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud stringForKey:key];
}
/**
 *  获取保存的NSInteger
 */
+(NSInteger )getIntValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud integerForKey:key];
}
/**
 *  获取保存的NSDictionary
 */
+(NSDictionary *)getDicValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud dictionaryForKey:key];
}
/**
 *  获取保存的NSArray
 */
+(NSArray *)getArrValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud arrayForKey:key];
}
/**
 *  获取保存的NSData
 */
+(NSData *)getdataValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud dataForKey:key];
}
/**
 *  获取保存的BOOL
 */
+(BOOL)getBoolValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:key];
}
/**
 *  删除对应的KEY
 */
+(void)removeValueInUDWithKey:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:key];
    [ud synchronize];
}
/**
 *   归档
 */
+ (void)keyedArchiverObject:(id)object ForKey:(NSString *)key ToFile:(NSString *)path{
    NSMutableData *md=[NSMutableData data];
    NSKeyedArchiver *arch=[[NSKeyedArchiver alloc]initForWritingWithMutableData:md];
    [arch encodeObject:object forKey:key];
    [arch finishEncoding];
    [md writeToFile:path atomically:YES];
}
static CGRect oldframe;
/**
 *  图片点击放大缩小
 */
+(void)showImage:(UIImageView*)avatarImageView{
    UIImage *image = avatarImageView.image;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:oldframe];
    imageView.image = image;
    imageView.tag = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = oldframe;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}
/**
 *  反归档
 */
+(NSArray *)keyedUnArchiverForKey:(NSString *)key FromFile:(NSString *)path{
    NSData *data=[NSData dataWithContentsOfFile:path];
    NSKeyedUnarchiver *unArch=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    NSArray *arr = [unArch decodeObjectForKey:key];
    return arr;
}
/**
 *  直接跳转到手机浏览器
 */
+(void)openURLAtSafari:(NSString *)urlString{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
/**
 *  设置语音提示
 */
+(void)SpeechSynthesizer:(NSString *)SpeechUtterancestring{
    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:SpeechUtterancestring];
    utterance.rate=0.1;//设置语速快慢
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置语言类别（不能被识别，返回值为nil）
    utterance.voice = voiceType;
    [av speakUtterance:utterance];//语音合成器会生成音频
}
/**
 *  心跳动画
 */
+(void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(CGFloat)fDurationPerBeat{
    if (view && (fDurationPerBeat > 0.1f))
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.8, 0.8, 1);
        
        CATransform3D scale2 = CATransform3DMakeScale(fMaxSize, fMaxSize, 1);
        
        CATransform3D scale3 = CATransform3DMakeScale(fMaxSize - 0.3f, fMaxSize - 0.3f, 1);
        
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:
                                
                                [NSValue valueWithCATransform3D:scale1],
                                
                                [NSValue valueWithCATransform3D:scale2],
                                
                                [NSValue valueWithCATransform3D:scale3],
                                
                                [NSValue valueWithCATransform3D:scale4],
                                
                                nil];
        
        [animation setValues:frameValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
                               
                               [NSNumber numberWithFloat:0.05],
                               
                               [NSNumber numberWithFloat:0.2],
                               
                               [NSNumber numberWithFloat:0.6],
                               
                               [NSNumber numberWithFloat:1.0],
                               
                               nil];
        
        [animation setKeyTimes:frameTimes];
        
        animation.fillMode = kCAFillModeForwards;
        
        animation.duration = fDurationPerBeat;
        
        animation.repeatCount = fDuration/fDurationPerBeat;
        
        [view.layer addAnimation:animation forKey:@"heartbeatView"];
        
    }else{}
    
}
/**
 *  保存数组数据以  data.plist
 */
+(void)save:(NSArray *)Array data_plist:(NSString *)plistname{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *namepist=[NSString stringWithFormat:@"%@.plist",plistname];
    
    path = [path stringByAppendingPathComponent:namepist];
    
    [Array writeToFile:path atomically:YES];
}
/**
 *  拨打电话号码
 */
+(void)makePhoneCallWithNumber:(NSString *)number{
    NSInteger length = number.length;
    NSString *realNumber = [NSString string];
    
    for (NSInteger i = 0 ; i <length; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [number substringWithRange:range];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        NSNumber *subnum = [numberFormatter numberFromString:subString];
        if ( subnum || [subString isEqualToString:@"-"])
        {
            realNumber = [realNumber stringByAppendingString:subString];
        }
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"telprompt://", realNumber]]])
    {
        [self openURLAtSafari:[NSString stringWithFormat:@"%@%@", @"telprompt://", realNumber]];
    }
}
/**
 *   调转到系统邮箱
 */
+(void)makeEmil:(NSString *)mailbox{
    [self openURLAtSafari:[NSString stringWithFormat:@"%@%@",@"mailto://",mailbox]];
}
/**
 *  保存相应viwe的图片到相册
 */
+(void)savePhoto:(UIView *)views{
    UIImage * image = [self captureImageFromView:views];
    //方法1：同步存到系统相册
    __block NSString *createdAssetID =nil;//唯一标识，可以用于图片资源获取
    NSError *error =nil;
    
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
}
+(void)saveImage:(UIImage *)image assetCollectionName:(NSString *)collectionName{
    // 1. 获取当前App的相册授权状态
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    
    // 2. 判断授权状态
    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
        
        // 2.1 如果已经授权, 保存图片(调用步骤2的方法)
        [self saveImage:image toCollectionWithName:collectionName];
        
    } else if (authorizationStatus == PHAuthorizationStatusNotDetermined) { // 如果没决定, 弹出指示框, 让用户选择
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            // 如果用户选择授权, 则保存图片
            if (status == PHAuthorizationStatusAuthorized) {
                [self saveImage:image toCollectionWithName:collectionName];
            }
        }];
        
    }
}
// 保存图片
+ (void)saveImage:(UIImage *)image toCollectionWithName:(NSString *)collectionName {
    
    // 1. 获取相片库对象
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    
    // 2. 调用changeBlock
    [library performChanges:^{
        
        // 2.1 创建一个相册变动请求
        PHAssetCollectionChangeRequest *collectionRequest;
        
        // 2.2 取出指定名称的相册
        PHAssetCollection *assetCollection = [self getCurrentPhotoCollectionWithTitle:collectionName];
        
        // 2.3 判断相册是否存在
        if (assetCollection) { // 如果存在就使用当前的相册创建相册请求
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else { // 如果不存在, 就创建一个新的相册请求
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:collectionName];
        }
        
        // 2.4 根据传入的相片, 创建相片变动请求
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        // 2.4 创建一个占位对象
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        
        // 2.5 将占位对象添加到相册请求中
        [collectionRequest addAssets:@[placeholder]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        // 3. 判断是否出错, 如果报错, 声明保存不成功
        if (error) {
            NSLog(@"保存相册失败");
        } else {
            NSLog(@"保存相册成功");
        }
    }];
}
/**
 *  改变导航栏工具条字体颜色 0 为白色 1 为黑色
 */
+(void)BackstatusBarStyle:(NSInteger)index{
  [UIApplication sharedApplication].statusBarStyle = index==0?(UIStatusBarStyleLightContent):(UIStatusBarStyleDefault);
    
}

/**
 *  按钮旋转动画
 */
+(void)RotatinganimationView:(UIButton *)btn animateWithDuration:(NSTimeInterval)duration{
    btn.selected?(btn.selected=YES):(btn.selected=NO);
    if (btn.selected) {
        btn.selected = NO;
        [UIView animateWithDuration:duration animations:^{
            btn.imageView.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {}];
    }
    else{
        btn.selected = YES;
        [UIView animateWithDuration:duration animations:^{
            btn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {}];
    }
}

//步骤三用于获取当前系统中是否有指定的相册
+ (PHAssetCollection *)getCurrentPhotoCollectionWithTitle:(NSString *)collectionName {
    
    // 1. 创建搜索集合
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 2. 遍历搜索集合并取出对应的相册
    for (PHAssetCollection *assetCollection in result) {
        
        if ([assetCollection.localizedTitle containsString:collectionName]) {
            return assetCollection;
        }
    }
    
    return nil;
}

//截图功能
+(UIImage *)captureImageFromView:(UIView *)view{
    
    CGRect screenRect = [view bounds];
    
    UIGraphicsBeginImageContextWithOptions(screenRect.size, NO, 0.0);//原图
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:ctx];
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}
/**
 *  修改状态栏的颜色
 */
+ (void)statusBarBackgroundColor:(UIColor *)statusBarColor{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        
        statusBar.backgroundColor = statusBarColor;
    }
}
/**
 *  过滤数组中相等的数据
 */
+(NSArray *)filterSameObject:(NSArray *)array{
    NSMutableArray * mArray = [NSMutableArray new];
    for (id object in array) {
        
        if (![array containsObject:object]) {
            [mArray addObject:object];
            
        }
    }
    NSArray * filterArray =  [NSArray arrayWithArray:mArray];
    return filterArray;
}
/**
 *  获取保存好的数组数据以  data.plist
 */
+(NSArray *)readsenderArraydata_plist:(NSString *)plistname{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *namepist=[NSString stringWithFormat:@"%@.plist",plistname];
    
    path = [path stringByAppendingPathComponent:namepist];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
    return array;
}
/**
 *  新建UICollectionViewFlowLayout容器
 */
+(UICollectionViewFlowLayout *)setUICollectionViewFlowLayoutWidths:(float)width High:(float)high minHspacing:(float)minhs minVspacing:(float)minvs UiedgeUp:(float)up Uiedgeleft:(float)left Uiedgebottom:(float)bottom Uiedgeright:(float)right Scdirection:(BOOL) direction{
    UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];
    
    flow = [UICollectionViewFlowLayout new];
    //格子的大小 (长，高)
    flow.itemSize = CGSizeMake(width, high);
    //横向最小距离
    flow.minimumInteritemSpacing = minhs;
    //代表的是纵向的空间间隔
    flow.minimumLineSpacing=minvs;
    //设置，上／左／下／右 边距 空间间隔数是多少
    flow.sectionInset = UIEdgeInsetsMake(up, left, bottom, right);
    
    //确定是水平滚动，还是垂直滚动
    if (direction) {
        [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    }else{
        [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }
    return flow;
}
/**
 *  获取某个view在屏幕上的frame
 */
+(CGRect)rectFromSunView:(UIView *)view{
    //查找frame
    UIView *vcView = [self rootViewFromSubView:view];
    UIView *superView = view.superview;
    CGRect viewRect = view.frame;
    CGRect viewRectFromWindow = [superView convertRect:viewRect toView:vcView];
    return viewRectFromWindow;
}

+(UIView *)rootViewFromSubView:(UIView *)view
{
    UIViewController *vc = nil;
    UIResponder *next = view.nextResponder;
    do {
        if ([next isKindOfClass:[UINavigationController class]]) {
            vc = (UIViewController *)next;
            break ;
        }
        next = next.nextResponder;
    } while (next != nil);
    if (vc == nil) {
        next = view.nextResponder;
        do {
            if ([next isKindOfClass:[UIViewController class]] || [next isKindOfClass:[UITableViewController class]]) {
                vc = (UIViewController *)next;
                break ;
            }
            next = next.nextResponder;
        } while (next != nil);
    }
    
    return vc.view;
}

@end
