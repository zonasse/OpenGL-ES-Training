//
//  ViewController.m
//  立方体纹理
//
//  Created by 钟奇龙 on 2019/11/17.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
typedef struct  {
    GLKVector3 positionCoord; // 顶点向量
    GLKVector2 textureCoord; // 纹理向量
    GLKVector3 normalVec; // 法向量
} QLVertex;
// 顶点数
static const NSInteger kCoordCount = 36;
@interface ViewController ()<GLKViewDelegate>
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, assign) QLVertex *vertexes;

@property (nonatomic, strong) CADisplayLink *displayLink; // 定时器
@property (nonatomic, assign) NSInteger rotateAngle; // 旋转角度
@property (nonatomic, assign) GLuint vertexBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfig];
    [self setupVertexData];
    [self addDisplayLink];
}

- (void)setupConfig {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    self.glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width) context:context];
    [self.view addSubview:self.glkView];
    
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.glkView.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    self.glkView.delegate = self;
    
    
    // 获取纹理数据
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"star" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    GLKTextureInfo *info = [GLKTextureLoader textureWithCGImage:image.CGImage options:@{GLKTextureLoaderOriginBottomLeft : @(YES)} error:nil];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = info.name;
    self.baseEffect.texture2d0.target = info.target;
    
}

- (void)setupVertexData {
    self.vertexes = malloc(sizeof(QLVertex) * kCoordCount);
    // 前面
    self.vertexes[0] = (QLVertex){{-0.5, 0.5, 0.5},  {0, 1}};
    self.vertexes[1] = (QLVertex){{-0.5, -0.5, 0.5}, {0, 0}};
    self.vertexes[2] = (QLVertex){{0.5, 0.5, 0.5},   {1, 1}};
    
    self.vertexes[3] = (QLVertex){{-0.5, -0.5, 0.5}, {0, 0}};
    self.vertexes[4] = (QLVertex){{0.5, 0.5, 0.5},   {1, 1}};
    self.vertexes[5] = (QLVertex){{0.5, -0.5, 0.5},  {1, 0}};
    
    // 上面
    self.vertexes[6] = (QLVertex){{0.5, 0.5, 0.5},    {1, 1}};
    self.vertexes[7] = (QLVertex){{-0.5, 0.5, 0.5},   {0, 1}};
    self.vertexes[8] = (QLVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertexes[9] = (QLVertex){{-0.5, 0.5, 0.5},   {0, 1}};
    self.vertexes[10] = (QLVertex){{0.5, 0.5, -0.5},  {1, 0}};
    self.vertexes[11] = (QLVertex){{-0.5, 0.5, -0.5}, {0, 0}};
    
    // 下面
    self.vertexes[12] = (QLVertex){{0.5, -0.5, 0.5},    {1, 1}};
    self.vertexes[13] = (QLVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertexes[14] = (QLVertex){{0.5, -0.5, -0.5},   {1, 0}};
    self.vertexes[15] = (QLVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertexes[16] = (QLVertex){{0.5, -0.5, -0.5},   {1, 0}};
    self.vertexes[17] = (QLVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    
    // 左面
    self.vertexes[18] = (QLVertex){{-0.5, 0.5, 0.5},    {1, 1}};
    self.vertexes[19] = (QLVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertexes[20] = (QLVertex){{-0.5, 0.5, -0.5},   {1, 0}};
    self.vertexes[21] = (QLVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertexes[22] = (QLVertex){{-0.5, 0.5, -0.5},   {1, 0}};
    self.vertexes[23] = (QLVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    
    // 右面
    self.vertexes[24] = (QLVertex){{0.5, 0.5, 0.5},    {1, 1}};
    self.vertexes[25] = (QLVertex){{0.5, -0.5, 0.5},   {0, 1}};
    self.vertexes[26] = (QLVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertexes[27] = (QLVertex){{0.5, -0.5, 0.5},   {0, 1}};
    self.vertexes[28] = (QLVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertexes[29] = (QLVertex){{0.5, -0.5, -0.5},  {0, 0}};
    
    // 后面
    self.vertexes[30] = (QLVertex){{-0.5, 0.5, -0.5},   {0, 1}};
    self.vertexes[31] = (QLVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    self.vertexes[32] = (QLVertex){{0.5, 0.5, -0.5},    {1, 1}};
    self.vertexes[33] = (QLVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    self.vertexes[34] = (QLVertex){{0.5, 0.5, -0.5},    {1, 1}};
    self.vertexes[35] = (QLVertex){{0.5, -0.5, -0.5},   {1, 0}};
    
    // 开辟缓冲区 VBO
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(QLVertex)*kCoordCount, self.vertexes, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(QLVertex), NULL + offsetof(QLVertex, positionCoord));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(QLVertex), NULL + offsetof(QLVertex, textureCoord));
    
}

- (void)addDisplayLink {
    self.rotateAngle = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)update {
    self.rotateAngle = (self.rotateAngle + 5) % 360;
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.rotateAngle), 0, 1.0, 0);
    [self.glkView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, kCoordCount);
}
@end
