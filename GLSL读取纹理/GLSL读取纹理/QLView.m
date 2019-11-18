//
//  QLView.m
//  GLSL读取纹理
//
//  Created by 钟奇龙 on 2019/11/18.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "QLView.h"
#import <GLKit/GLKit.h>
@interface QLView()
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *eaglContext;
@property (nonatomic, assign) GLuint      frameBuffer;
@property (nonatomic, assign) GLuint      renderBuffer;
@property (nonatomic, assign) GLuint      program;
@end

@implementation QLView

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
    
    GLfloat attrArr[] =
    {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    // 处理顶点数据
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    
    GLuint textureCoord = glGetAttribLocation(self.program, "textureCoord");
    glEnableVertexAttribArray(textureCoord);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    [self setupTexture];
    
    glUniform1i(glGetUniformLocation(self.program, "colorMap"), 0);
    
    //解决纹理翻转(方法1)
//    [self rotateTextureImage];

    glDrawArrays(GL_TRIANGLES, 0, 6);
    
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

- (void)setupTexture {
    CGImageRef spriteImage = [UIImage imageNamed:@"notebook"].CGImage;
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(spriteContext, rect, spriteImage);
    // 纹理翻转 方法2
//    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
//    CGContextScaleCTM(spriteContext, 1.0, -1.0);
//    CGContextDrawImage(spriteContext, rect, spriteImage);

    // 纹理翻转 方法3

//    CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
//    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
//    CGContextScaleCTM(spriteContext, 1.0, -1.0);
//    CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
//    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    CGContextRelease(spriteContext);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width, (float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


-(void)rotateTextureImage
{
    //注意，想要获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    //1. rotate等于shaderv.vsh中的uniform属性，rotateMatrix
    GLuint rotate = glGetUniformLocation(self.program, "rotateMatrix");
    
    //2.获取渲旋转的弧度
    float radians = 180 * 3.14159f / 180.0f;
    
    //3.求得弧度对于的sin\cos值
    float s = sin(radians);
    float c = cos(radians);
    
    //4.因为在3D课程中用的是横向量，在OpenGL ES用的是列向量
    /*
     参考Z轴旋转矩阵
     */
    GLfloat zRotation[16] = {
        c,-s,0,0,
        s,c,0,0,
        0,0,1,0,
        0,0,0,1
    };
    
    //5.设置旋转矩阵
    /*
     glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
     location : 对于shader 中的ID
     count : 个数
     transpose : 转置
     value : 指针
     */
    glUniformMatrix4fv(rotate, 1, GL_FALSE, zRotation);
    
    
}

@end
