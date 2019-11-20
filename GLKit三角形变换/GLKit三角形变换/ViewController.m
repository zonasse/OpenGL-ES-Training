//
//  ViewController.m
//  GLKit三角形变换
//
//  Created by 钟奇龙 on 2019/11/20.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) GLuint indexVertexCount;
//旋转的度数
@property (nonatomic,assign) NSInteger XDegree;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContext];
    [self setupVertexData];
    [self setupDisplayLink];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
}

- (void)setupVertexData {
    //1.顶点数据
    //前3个元素，是顶点数据；中间3个元素，是顶点颜色值，最后2个是纹理坐标
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    
    //2.绘图索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    self.indexVertexCount = sizeof(indices) / sizeof(GLuint);
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    // 索引数据
    GLuint indexBufferID;
    glGenBuffers(1, &indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // 注入顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 0);
    // 注入颜色数据
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);
    
    // 注入纹理顶点数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *) NULL + 6);
    
    // 获取纹理数据
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"star" ofType:@"jpg"];
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:imagePath options:@{ GLKTextureLoaderOriginBottomLeft : @(YES)} error:nil];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.texture2d0.enabled = YES;
    self.effect.texture2d0.name = info.name;
    
    // 设置投影矩阵
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1f, 10.0f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0, 1.0, 1.0);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // 设置模型矩阵
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -20.0f);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)setupDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)update {
    self.XDegree = (self.XDegree + 2) % 360;
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.XDegree);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.2f, 0.8, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.indexVertexCount, GL_UNSIGNED_INT, 0);
}
@end
