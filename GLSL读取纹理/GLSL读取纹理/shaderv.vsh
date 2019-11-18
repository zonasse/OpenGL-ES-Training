attribute vec4 position;
attribute vec2 textureCoord;
varying lowp vec2 varyTextureCoord;
uniform mat4 rotateMatrix;

void main() {
    //纹理翻转 方法4
    varyTextureCoord = vec2(textureCoord.x,1.0-textureCoord.y);
//    varyTextureCoord = textureCoord;
    //纹理翻转 方法2
//    vec4 vPos = position;
//    vPos = vPos * rotateMatrix;
//    gl_Position = vPos;
    gl_Position = position;
}
