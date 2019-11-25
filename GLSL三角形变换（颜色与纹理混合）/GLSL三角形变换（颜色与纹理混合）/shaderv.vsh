attribute vec4 position;
attribute vec4 positionColor;
attribute vec2 textureCoord;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying lowp vec2 vTextureCoord;
varying lowp vec4 vPositionColor;

void main() {
    
    vTextureCoord = textureCoord;
    vPositionColor = positionColor;

    vec4 pos = projectionMatrix * modelViewMatrix * position;
    
    gl_Position = pos;
}
