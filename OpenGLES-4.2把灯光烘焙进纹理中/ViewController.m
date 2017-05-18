//
//  ViewController.m
//  OpenGLES-4.2把灯光烘焙进纹理中
//
//  Created by ShiWen on 2017/5/17.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

typedef struct{
    GLKVector3 postionCorrds;
    GLKVector2 textureCorrds;
    
}Scentexs;

typedef struct{
    Scentexs singlePoint[3];
}singleVertex;

static Scentexs singleA = {{-0.5f,0.5f,-0.5f},{0.0f,1.0f}};
static Scentexs singleB = {{-0.5f,0.0f,-0.5f},{0.0f,0.5f}};
static Scentexs singleC = {{-0.5f,-0.5f,-0.5f},{0.0f,0.0f}};
static Scentexs singleD = {{0.0f,0.5f,-0.5f},{0.5f,1.0f}};
static Scentexs singleE = {{0.0f,0.0f,0.0f},{0.5f,0.5f}};
static Scentexs singleF = {{0.0f,-0.5f,-0.5f},{0.5f,0.0f}};
static Scentexs singleG = {{0.5f,0.5f,-0.5f},{1.0f,1.0}};
static Scentexs singleH = {{0.5f,0.0f,-0.5},{1.0f,0.5f}};
static Scentexs singleI = {{0.5f,-0.5f,-0.5f},{1.0f,0.0f}};
@interface ViewController ()
{
    singleVertex singles[8];
}
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *mVertexBuffer;
@property (nonatomic,strong) GLKBaseEffect *mBaseEffect;
@property (nonatomic,strong)GLKTextureInfo* lightInfo;
@property (nonatomic,strong)GLKTextureInfo *lithtDetailInfo;
@property (nonatomic,assign)GLKMatrix4 upViewMatrix;
@property (nonatomic,assign)GLKMatrix4 leViewMatrix;
@property (weak, nonatomic) IBOutlet UISwitch *showDetail;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *glView = (GLKView *)self.view;
    glView.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:glView.context];
    [((AGLKContext*)glView.context) setClearColor:GLKVector4Make(0.0f,0.0f, 0.0f, 1.0f)];
    
    self.mBaseEffect = [[GLKBaseEffect alloc] init];
    self.mBaseEffect.useConstantColor = GL_TRUE;
    self.mBaseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    singles[0] = SceneTriangleMake(singleA, singleB, singleD);
    singles[1] = SceneTriangleMake(singleD, singleB, singleE);
    singles[2] = SceneTriangleMake(singleB, singleE, singleF);
    singles[3] = SceneTriangleMake(singleB, singleC, singleF);
    singles[4] = SceneTriangleMake(singleD, singleE, singleH);
    singles[5] = SceneTriangleMake(singleD, singleG, singleH);
    singles[6] = SceneTriangleMake(singleE, singleF, singleH);
    singles[7] = SceneTriangleMake(singleH, singleI, singleF);
    
    
    self.mVertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(Scentexs) numberOfVertices:sizeof(singles)/sizeof(Scentexs) bytes:singles usage:GL_DYNAMIC_DRAW];
    
    CGImageRef lightImageRef = [[UIImage imageNamed:@"Lighting.png"] CGImage];
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    self.lightInfo = [GLKTextureLoader textureWithCGImage:lightImageRef options:options error:nil];
    CGImageRef detailImageRef = [[UIImage imageNamed:@"LightingDetail.png"] CGImage];
    self.lithtDetailInfo = [GLKTextureLoader textureWithCGImage:detailImageRef options:options error:nil];
    
    [self showDetail:self.showDetail];
    
    self.upViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(0), 1.0f, 0.0f, 0.0f);
    self.leViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(0), 0.0f, 1.0f, 0.0f);
    
    

}

- (IBAction)showDetail:(UISwitch *)sender {
    if (sender.on) {
        self.mBaseEffect.texture2d0.target = self.lithtDetailInfo.target;
        self.mBaseEffect.texture2d0.name = self.lithtDetailInfo.name;
    }else{
        self.mBaseEffect.texture2d0.target = self.lightInfo.target;
        self.mBaseEffect.texture2d0.name = self.lightInfo.name;
    }
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    

    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    [self.mVertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(Scentexs, postionCorrds) shouldEnable:YES];
    [self.mVertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(Scentexs, textureCorrds) shouldEnable:YES];
    [self.mBaseEffect prepareToDraw];
    [self.mVertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(singles)/sizeof(Scentexs)];
    
}

- (IBAction)upAndDown:(UISlider *)sender {

    self.upViewMatrix = GLKMatrix4Rotate(self.leViewMatrix, GLKMathDegreesToRadians(sender.value * -180), 1.0f, 0.0f, 0.0f);
    self.mBaseEffect.transform.modelviewMatrix = self.upViewMatrix;
    
}

- (IBAction)leftAndRight:(UISlider *)sender {
    //定义形变量，围绕y轴旋转-60度
    self.leViewMatrix = GLKMatrix4Rotate(self.upViewMatrix, GLKMathDegreesToRadians(sender.value * -180), 0.0f, 1.0f, 0.0f);
    self.mBaseEffect.transform.modelviewMatrix = self.leViewMatrix;

}
static singleVertex SceneTriangleMake( Scentexs vertexA,
                                        Scentexs vertexB,
                                        Scentexs vertexC)
{
    singleVertex   result;
    
    result.singlePoint[0] = vertexA;
    result.singlePoint[1] = vertexB;
    result.singlePoint[2] = vertexC;
    
    return result;
} 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
