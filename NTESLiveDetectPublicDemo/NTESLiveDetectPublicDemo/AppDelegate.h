//
//  AppDelegate.h
//  NTESLiveDetectPublicDemo
//
//  Created by Ke Xu on 2019/10/10.
//  Copyright © 2019 Ke Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AppDelegateEnterBackgroundHandler)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy, nonatomic) AppDelegateEnterBackgroundHandler enterBackgroundHandler;

@end

