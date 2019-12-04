precision lowp float;
uniform sampler2D fTexture;
varying lowp vec2 textureCoordVarying;

void main() {
    vec2 uv = textureCoordVarying.xy;
    if (uv.x >= 0.0 && uv.x <= 0.5) {
        uv.x = uv.x * 2.0;
    } else {
        uv.x = (uv.x - 0.5) * 2.0;
    }
    if (uv.y >= 0.0 && uv.y <= 0.5) {
        uv.y = uv.y * 2.0;
    } else {
        uv.y = (uv.y - 0.5) * 2.0;
    }
    vec4 mask = texture2D(fTexture,uv);
    gl_FragColor = vec4(mask.rgb,1.0);
}
