//
//  QLView.m
//  GLSL读取纹理
//
//  Created by 钟奇龙 on 2019/11/18.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "QLView.h"
#import <GLKit/GLKit.h>
#import "GLESMath.h"
#import "GLESUtils.h"
@interface QLView()
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *eaglContext;
@property (nonatomic, assign) GLuint      frameBuffer;
@property (nonatomic, assign) GLuint      renderBuffer;
@property (nonatomic, assign) GLuint      program;
@property (nonatomic, assign) GLuint      verticesBuffer;
@end

@implementation QLView
{
    float xDegree;
    float yDegree;
    float zDegree;
    BOOL bX;
    BOOL bY;
    BOOL bZ;
    NSTimer *timer;
}


#pragma mark - XYClick
- (IBAction)XClick:(id)sender {
    
    //开启定时器
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    //更新的是X还是Y
    bX = !bX;
    
}
- (IBAction)YClick:(id)sender {
    
    //开启定时器
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    //更新的是X还是Y
    bY = !bY;
}
- (IBAction)ZClick:(id)sender {
    
    //开启定时器
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    //更新的是X还是Y
    bZ = !bZ;
}

-(void)reDegree
{
    //如果停止X轴旋转，X = 0则度数就停留在暂停前的度数.
    //更新度数
    xDegree += bX * 5;
    yDegree += bY * 5;
    zDegree += bZ * 5;
    //重新渲染
    [self renderLayer];
    
}

- (void)layoutSubviews {
    [self setupLayer];
    [self setupContext];
    [self deleteBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self renderLayer];
}

- (void)setupLayer {
    self.eaglLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    self.eaglLayer.opaque = YES;
    self.eaglLayer.drawableProperties = @{
                                          kEAGLDrawablePropertyRetainedBacking : @(NO),
                                          kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                          };
}

- (void)setupContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"Create context failed!");
        return;
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"setCurrentContext failed!");
        return;
    }
    self.eaglContext = context;
}

- (void)deleteBuffer {
    if (_frameBuffer) {
        glDeleteBuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_renderBuffer) {
        glDeleteBuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
}

- (void)setupRenderBuffer {
    glGenBuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [self.eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
}

- (void)setupFrameBuffer {
    glGenBuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBuffer);
}

- (void)renderLayer {
    glClearColor(0.3, 0.8, 0.3, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    NSString *vertexFilePath = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragmentFilePath = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    if (self.program) {
        glDeleteProgram(self.program);
        self.program = 0;
    }
    self.program = [self loadShaderFromVertexFile:vertexFilePath andFragmentFile:fragmentFilePath];
    
    glLinkProgram(self.program);
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.program, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    glUseProgram(self.program);
    // 顶点数组 前3顶点值（x,y,z），后3位颜色值(RGB)
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f, //左上0
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f, //右上1
        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f, //左下2
        
        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, //右下3
        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f, //顶点4
    };
    // 索引数组
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    // 处理顶点数据
    if (_verticesBuffer == 0) {
        glGenBuffers(1, &_verticesBuffer);
    }
    glBindBuffer(GL_ARRAY_BUFFER, _verticesBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, NULL);
    
    GLuint positionColor = glGetAttribLocation(self.program, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (GLfloat *)NULL + 3);
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.program, "projectionMatrix");
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.program, "modelViewMatrix");
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    float aspect = width / height;
    KSMatrix4 projectionMatrix;
    ksMatrixLoadIdentity(&projectionMatrix);
    ksPerspective(&projectionMatrix, 20.0, aspect, 5.0, 20.0);
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat *)&projectionMatrix.m[0][0]);
    
    KSMatrix4 modelViewMatrix;
    ksMatrixLoadIdentity(&modelViewMatrix);
    ksTranslate(&modelViewMatrix, 0, 0, -10);
    
    KSMatrix4 rotateMatrix;
    ksMatrixLoadIdentity(&rotateMatrix);
    ksRotate(&rotateMatrix, xDegree, 1.0, 0, 0);
    ksRotate(&rotateMatrix, yDegree, 0, 1.0, 0);
    ksRotate(&rotateMatrix, zDegree, 0, 0, 1.0);

    ksMatrixMultiply(&modelViewMatrix, &rotateMatrix, &modelViewMatrix);
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat *)&modelViewMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

/**
 加载着色器文件

 @param vertFilePath 顶点着色器文件
 @param fragmentFilePath 片元着色器文件
 @return 着色器program
 */
- (GLuint)loadShaderFromVertexFile:(NSString *)vertFilePath andFragmentFile:(NSString *)fragmentFilePath {
    GLuint vertexShader, fragmentShader;
    GLuint program = glCreateProgram();
    [self compileShader:&vertexShader type:GL_VERTEX_SHADER filePath:vertFilePath];
    [self compileShader:&fragmentShader type:GL_FRAGMENT_SHADER filePath:fragmentFilePath];
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type filePath:(NSString *)filePath {
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}




@end
