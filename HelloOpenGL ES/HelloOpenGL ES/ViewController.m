//
//  ViewController.m
//  HelloOpenGL ES
//
//  Created by 钟奇龙 on 2019/11/16.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "ViewController.h"
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>

@interface ViewController ()
{
    EAGLContext *context;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"Create ES context failed");
    }
    [EAGLContext setCurrentContext:context];
    GLKView *view = (GLKView*) self.view;
    view.context = context;
    glClearColor(0.3, 0.8, 0.3, 1.0f);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
