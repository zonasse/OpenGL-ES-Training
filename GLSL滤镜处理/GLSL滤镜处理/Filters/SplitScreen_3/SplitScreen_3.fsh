precision lowp float;
uniform sampler2D fTexture;
varying lowp vec2 textureCoordVarying;

void main() {
    vec2 uv = textureCoordVarying.xy;
    float y;
    if (uv.y >= 0.0 && uv.y <= 0.33) {
        y = uv.y + 0.33;
    } else if(uv.y >= 0.66) {
        y = uv.y - 0.33;
    } else {
        y = uv.y;
    }
    vec4 mask = texture2D(fTexture,vec2(uv.x,y));
    gl_FragColor = vec4(mask.rgb,1.0);
}
