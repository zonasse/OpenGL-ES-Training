//
//  QLView.m
//  GLSL三角形变换（颜色与纹理混合）
//
//  Created by 钟奇龙 on 2019/11/25.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "QLView.h"

#import "GLESMath.h"
#import "GLESUtils.h"
#import <OpenGLES/ES3/gl.h>

@interface QLView()

@property (nonatomic,strong) CAEAGLLayer *eaglLayer;
@property (nonatomic,strong) EAGLContext *context;

@property (nonatomic,assign) GLuint frameBuffer;
@property (nonatomic,assign) GLuint renderBuffer;

@property (nonatomic,assign) GLuint program;
@property (nonatomic,assign) GLuint vertices;


@end

@implementation QLView
{
    float xDegree;
    float yDegree;
    float zDegree;
    BOOL bX;
    BOOL bY;
    BOOL bZ;
    NSTimer* myTimer;
    
}
#pragma mark - XYClick
- (IBAction)XClick:(id)sender {
    
    //开启定时器
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    //更新的是X还是Y
    bX = !bX;
    
}
- (IBAction)YClick:(id)sender {
    
    //开启定时器
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    //更新的是X还是Y
    bY = !bY;
}
- (IBAction)ZClick:(id)sender {
    
    //开启定时器
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
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
    [self render];
    
}

- (void)layoutSubviews {
    // 1.设置图层layer
    [self setupLayer];
    // 2.设置上下文context
    [self setupContext];
    // 3.删除缓冲区
    [self deleteBuffer];
    // 4.设置渲染缓冲区renderBuffer
    [self setupRenderBuffer];
    // 5.设置帧缓冲区frameBuffer
    [self setupFrameBuffer];
    // 6.渲染
    [self render];
}

- (void)setupLayer {
    self.eaglLayer = (CAEAGLLayer *)self.layer;
    [self.eaglLayer setContentsScale:[UIScreen mainScreen].scale];
    self.eaglLayer.opaque = YES;
    self.eaglLayer.drawableProperties = @{
                                          kEAGLDrawablePropertyRetainedBacking: @(NO),
                                          kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                          };
}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
}

- (void)deleteBuffer {
    if (self.renderBuffer) {
        glDeleteBuffers(1, &_renderBuffer);
        self.renderBuffer = 0;
    }
    if (self.frameBuffer) {
        glDeleteBuffers(1, &_frameBuffer);
        self.frameBuffer = 0;
    }
}

- (void)setupRenderBuffer {
    glGenBuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
}

- (void)setupFrameBuffer {
    glGenBuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)render {
    glClearColor(0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [UIScreen mainScreen].scale;
    CGPoint origin = self.frame.origin;
    CGSize size = self.frame.size;
    glViewport(origin.x * scale,origin.y * scale, size.width * scale, size.height * scale);
    
    NSString *vertexFilePath = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragmentFilePath = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    if(self.program) {
        glDeleteProgram(self.program);
        self.program = 0;
    }
    
    self.program = [self loadShaderWithVertexFile:vertexFilePath fragFile:fragmentFilePath];
    
    glLinkProgram(self.program);
    
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if(linkStatus == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        
        return ;
    } else {
        glUseProgram(self.program);
    }
    // 顶点数据： 顶点(3) 颜色(3) 纹理坐标(2)
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 0.0f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     1.0f, 0.0f, 0.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
        
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
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
    
    if(self.vertices == 0) {
        glGenBuffers(1, &_vertices);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    // 为顶点和片元着色器设置数据
//    -> 属性变量，从外部传入
//    attribute vec4 position;
//    attribute vec4 positionColor;
//    attribute vec2 textureCoord;
//
//    -> 不可变变量，从外部传入
//    uniform mat4 projectionMatrix;
//    uniform mat4 modelViewMatrix;
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *) NULL + 0);
    
    GLuint positionColor = glGetAttribLocation(self.program, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *) NULL + 3);
    
    GLuint textureCoord = glGetAttribLocation(self.program, "textureCoord");
    glEnableVertexAttribArray(textureCoord);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 6);
    
    // 加载纹理数据并将纹理数据绑定到纹理上下文
    [self setupTexture];
    
    // 设置纹理采样器数据 sampler2D
    glUniform1i(glGetUniformLocation(self.program, "colorMap"), 0);
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.program, "projectionMatrix");
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.program, "modelViewMatrix");
    
    // 设置透视投影矩阵
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    float aspect = size.width / size.height;
    ksPerspective(&_projectionMatrix, 30.0f, aspect, 5.0f, 20.0f);
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    
    // 设置模型变换矩阵
    KSMatrix4 _modelViewMatrix;
    //(1)获取单元矩阵
    ksMatrixLoadIdentity(&_modelViewMatrix);
    //(2)平移，z轴平移-10
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -10.0);
    //(3)创建一个4 * 4 矩阵，旋转矩阵
    KSMatrix4 _rotationMatrix;
    //(4)初始化为单元矩阵
    ksMatrixLoadIdentity(&_rotationMatrix);
    //(5)旋转
    ksRotate(&_rotationMatrix, xDegree, 1.0, 0.0, 0.0); //绕X轴
    ksRotate(&_rotationMatrix, yDegree, 0.0, 1.0, 0.0); //绕Y轴
    ksRotate(&_rotationMatrix, zDegree, 0.0, 0.0, 1.0); //绕Z轴
    //(6)把变换矩阵相乘.将_modelViewMatrix矩阵与_rotationMatrix矩阵相乘，结合到模型视图
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    //(7)将模型视图矩阵传递到顶点着色器
    /*
     void glUniformMatrix4fv(GLint location,  GLsizei count,  GLboolean transpose,  const GLfloat *value);
     参数列表：
     location:指要更改的uniform变量的位置
     count:更改矩阵的个数
     transpose:是否要转置矩阵，并将它作为uniform变量的值。必须为GL_FALSE
     value:执行count个元素的指针，用来更新指定uniform变量
     */
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    
    [self.context presentRenderbuffer:GL_RENDERER];
}

- (GLuint)loadShaderWithVertexFile:(NSString *)vert fragFile:(NSString *)frag
{
    //创建2个临时的变量，verShader,fragShader
    GLuint verShader,fragShader;
    //创建一个Program
    GLuint program = glCreateProgram();
    
    //编译文件
    //编译顶点着色程序、片元着色器程序
    //参数1：编译完存储的底层地址
    //参数2：编译的类型，GL_VERTEX_SHADER（顶点）、GL_FRAGMENT_SHADER(片元)
    //参数3：文件路径
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    //创建最终的程序
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //释放不需要的shader
    glDeleteProgram(verShader);
    glDeleteProgram(fragShader);
    
    return program;
    
}

//链接shader
-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    //读取文件路径字符串
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    //获取文件路径字符串，C语言字符串
    const GLchar *source = (GLchar *)[content UTF8String];
    
    //创建一个shader（根据type类型）
    *shader = glCreateShader(type);
    
    //将顶点着色器源码附加到着色器对象上。
    //参数1：shader,要编译的着色器对象 *shader
    //参数2：numOfStrings,传递的源码字符串数量 1个
    //参数3：strings,着色器程序的源码（真正的着色器程序源码）
    //参数4：lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
    glShaderSource(*shader, 1, &source, NULL);
    
    //把着色器源代码编译成目标代码
    glCompileShader(*shader);
    
}

/**
 设置纹理数据
 */
- (void)setupTexture {
    CGImageRef spriteImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star" ofType:@"jpg"]].CGImage;
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteImageData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef spriteImageContext = CGBitmapContextCreate(spriteImageData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(spriteImageContext, rect, spriteImage);
    
    CGContextRelease(spriteImageContext);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width, (float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteImageData);
    
    free(spriteImageData);
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}
@end
