//
//  ViewController.m
//  OpenGL ES 读取纹理
//
//  Created by 钟奇龙 on 2019/11/17.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    EAGLContext *context;
    GLKBaseEffect *effect;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfig];
    [self setupData];
    [self setupTexture];
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 初始化方法
 */
- (void)setupConfig {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    
    GLKView *view = (GLKView*) self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    glClearColor(0.2, 0.8, 0.2, 1.0f);
}

/**
 设置顶点和纹理数据
 */
- (void)setupData {
    GLfloat vertexData[] = {
        0.5, -0.5, 0, 1.0, 0, // 右下
        0.5, 0.5, 0, 1, 1, // 右上
        -0.5, -0.5, 0, 0, 0, // 左下
        0.5, 0.5, 0, 1, 1, // 右上
        -0.5, 0.5, 0, 0, 1, // 左上
        -0.5, -0.5, 0, 0, 0 // 左下
    };
    GLuint bufferId;
    glGenBuffers(1, &bufferId);
    glBindBuffer(GL_ARRAY_BUFFER, bufferId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat*)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 3);
}

/**
 设置纹理
 */
- (void)setupTexture {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"star" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:imagePath options:options error:nil];
    
    
    effect = [[GLKBaseEffect alloc] init];
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = info.name;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
    [effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
@end
