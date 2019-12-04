precision highp float;
uniform sampler2D fTexture;
varying vec2 textureCoordVarying;

const float PI = 3.141592653;
const float uD = 80.0;
const float uR = 0.5;

void main() {
    
    ivec2 ires = ivec2(512, 512);
    float Res = float(ires.s);
    
    vec2 st = textureCoordVarying;
    float Radius = Res * uR;
    
    vec2 xy = Res * st;
    
    vec2 dxy = xy - vec2(Res/2., Res/2.);
    float r = length(dxy);
    
    //(1.0 - r/Radius);
    float beta = atan(dxy.y, dxy.x) + radians(uD) * 2.0 * (-(r/Radius)*(r/Radius) + 1.0);
    
    vec2 xy1 = xy;
    if(r<=Radius)
    {
        xy1 = Res/2. + r*vec2(cos(beta), sin(beta));
    }
    
    st = xy1/Res;
    
    vec3 irgb = texture2D(fTexture, st).rgb;
    
    gl_FragColor = vec4( irgb, 1.0 );
}
