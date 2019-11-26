//
//  ViewController.m
//  粒子效果-CoreAnimation
//
//  Created by 钟奇龙 on 2019/11/26.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAEmitterLayer *rainLayer = [[CAEmitterLayer alloc] init];
    [self.view.layer addSublayer:rainLayer];
    
    rainLayer.emitterMode = kCAEmitterLayerSurface;
    rainLayer.emitterSize = self.view.frame.size;
    rainLayer.emitterShape = kCAEmitterLayerLine;
    rainLayer.emitterPosition = CGPointMake(self.view.frame.size.width * 0.5, -10);
    
    CAEmitterCell *snowCell = [CAEmitterCell emitterCell];
    snowCell.contents = (id)[UIImage imageNamed:@"jinbi"].CGImage;
    snowCell.birthRate = 1.0;
    snowCell.lifetime = 30;
    snowCell.speed = 2;
    snowCell.velocity = 10.f;
    snowCell.velocityRange = 10.f;
    snowCell.yAcceleration = 60;
    snowCell.scale = 0.1;
    snowCell.scaleRange = 0.f;
    
    rainLayer.emitterCells = @[snowCell];
    
}


@end
