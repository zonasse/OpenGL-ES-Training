//
//  ViewController.m
//  GLSL滤镜处理
//
//  Created by 钟奇龙 on 2019/11/27.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "ViewController.h"
#import "FilterBar.h"

typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 textureCoord;
}SceneVertex;

@interface ViewController ()<FilterBarDelegate>

@property (nonatomic, strong) FilterBar *filterBar;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval startTimeInterval;

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint textureID;

@property (nonatomic, assign) SceneVertex *vertices;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFilterBar];
    [self setupContext];
    [self setupLayer];
    [self setupVBO];
    [self setupTexture];
    [self setupShaderProgramWithName:@"Normal"];
    [self startFilterAnimation];
}

- (void)setupFilterBar {
    CGFloat filterBarHeight = 100;
    self.filterBar = [[FilterBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - filterBarHeight, self.view.bounds.size.width, filterBarHeight)];
    [self.view addSubview:self.filterBar];
    self.filterBar.delegate = self;
    NSArray *dataSource = @[@"原始",@"2分屏",@"3分屏",@"4分屏",@"6分屏",@"灰度",@"颠倒",@"旋涡",@"马赛克",@"马赛克2",@"缩放",@"灵魂出窍",@"抖动",@"闪白",@"毛刺"];

    self.filterBar.itemList = dataSource;
}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupLayer {
    CAEAGLLayer *layer = [CAEAGLLayer layer];
    CGFloat width = self.view.bounds.size.width;
    layer.frame = CGRectMake(0, 100, width, width);
    layer.contentsScale = [UIScreen mainScreen].scale;
    [self.view.layer addSublayer:layer];
    
    GLuint frameBuffer, renderBuffer;
    
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
}


- (void)setupVBO {
    
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    self.vertices = malloc(sizeof(SceneVertex) * 4);
    self.vertices[0] = (SceneVertex){{-1,1,0},{0,1}};
    self.vertices[1] = (SceneVertex){{-1,-1,0},{0,0}};
    self.vertices[3] = (SceneVertex){{1,-1,0},{1,0}};
    self.vertices[2] = (SceneVertex){{1,1,0},{1,1}};
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SceneVertex)*4, self.vertices, GL_STATIC_DRAW);
    
    
}

- (void)setupTexture {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star" ofType:@"jpg"]];
    CGImageRef imageRef = image.CGImage;
    
    if (!imageRef) {
        NSLog(@"load image failed");
        return;
    }
    
    GLuint width = (GLuint)CGImageGetWidth(imageRef);
    GLuint height = (GLuint)CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    void* imageData = malloc(width * height * 4);
    
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    
    CGContextDrawImage(context, rect, imageRef);
    //1.
//    glGenTextures(1, &_textureID);
//    glBindTexture(GL_TEXTURE_2D, _textureID);
    //2.
    glBindTexture(GL_TEXTURE_2D, 0);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    CGContextRelease(context);
    free(imageData);
    
}

- (void)setupShaderProgramWithName:(NSString *)programName {
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:programName ofType:@"vsh"];
    GLuint vertexShader = [self compileShaderWithPath:vertexShaderPath type:GL_VERTEX_SHADER];
    
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:programName ofType:@"fsh"];
    GLuint fragmentShader = [self compileShaderWithPath:fragmentShaderPath type:GL_FRAGMENT_SHADER];
    
    self.program = glCreateProgram();
    glAttachShader(self.program, vertexShader);
    glAttachShader(self.program, fragmentShader);
    
    glLinkProgram(self.program);
    
    GLint linkSuccess;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program链接失败：%@", messageString);
        exit(1);
    }

    glUseProgram(self.program);
    
    GLuint positionSlot = glGetAttribLocation(self.program, "vPosition");
    GLuint textureSlot = glGetUniformLocation(self.program, "fTexture");
    GLuint textureCoordSlot = glGetAttribLocation(self.program, "vTextureCoord");
    
    //3.
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    glUniform1i(textureSlot, 0);
    
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, positionCoord));
    
    glEnableVertexAttribArray(textureCoordSlot);
    glVertexAttribPointer(textureCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoord));
    
    
}

- (void)startFilterAnimation {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)timeAction {
    if(self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
    }
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint timeSlot = glGetUniformLocation(self.program, "time");
    glUniform1f(timeSlot, currentTime);
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.2, 0.3, 0.1, 1.0);

//    glUseProgram(self.program);
//    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)compileShaderWithPath:(NSString *)shaderPath type:(GLenum)shaderType {
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderPath) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    GLuint shader = glCreateShader(shaderType);
    
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shader);
    
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败：%@", messageString);
        exit(1);
    }
    return shader;
}

- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}

- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self setupShaderProgramWithName:@"Normal"];
            break;
        case 1:
            [self setupShaderProgramWithName:@"SplitScreen_2"];
            break;
        case 2:
            [self setupShaderProgramWithName:@"SplitScreen_3"];
            break;
        case 3:
            [self setupShaderProgramWithName:@"SplitScreen_4"];
            break;
        case 4:
            [self setupShaderProgramWithName:@"SplitScreen_6"];
            break;
        case 5:
            [self setupShaderProgramWithName:@"Gray"];
            break;
        case 6:
            [self setupShaderProgramWithName:@"Reverse"];
            break;
        case 7:
            [self setupShaderProgramWithName:@"Circle"];
            break;
        case 8:
            [self setupShaderProgramWithName:@"Mosaic"];
            break;
        case 9:
            [self setupShaderProgramWithName:@"HexagonMosaic"];
            break;
        case 10:
            [self setupShaderProgramWithName:@"Scale"];
        
        break;
        case 11:
            [self setupShaderProgramWithName:@"SoulOut"];
        
        break;
        case 12:
            [self setupShaderProgramWithName:@"Shake"];
        
        break;
        case 13:
            [self setupShaderProgramWithName:@"ShineWhite"];
        
        break;
        case 14:
            [self setupShaderProgramWithName:@"Glitch"];
        
        break;
        default:
            break;
    }
    // 重新开始滤镜动画
    [self startFilterAnimation];
}

- (void)dealloc {
    if (self.context == [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
}
@end
