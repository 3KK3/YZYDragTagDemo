//
//  ViewController.m
//  DragTagDemo
//
//  Created by YZY on 2017/4/26.
//  Copyright © 2017年 YZY. All rights reserved.
//

#import "ViewController.h"
#import "BGImgeEditorViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 200, 30);
    [button setTitle: @"点击进入标签编辑页面" forState: UIControlStateNormal];
    [self.view addSubview: button];
    
    button.backgroundColor = [UIColor greenColor];
    [button addTarget: self action: @selector(buttonClick) forControlEvents: UIControlEventTouchUpInside];
    
}

- (void)buttonClick {
    
    NSMutableArray *tempItemArray = [NSMutableArray array];
    
    for (NSInteger i = 1; i <= 5; i++) {
        
        BGImageEditorItem *item = [[BGImageEditorItem alloc] init];
        
        item.image = [UIImage imageNamed: [NSString stringWithFormat: @"%ld.jpg",i]];
        
        [tempItemArray addObject: item];
    }
    
    BGImgeEditorViewController *controller = [[BGImgeEditorViewController alloc] initWithImages: tempItemArray showIndex: 0];
    
    [self presentViewController: controller  animated:YES completion: nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
