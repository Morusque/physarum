#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D dataX;
uniform sampler2D dataY;
uniform float dataSize;
uniform vec2 resolution;
uniform float particleSize;

uniform mat4 transformMatrix;
attribute vec4 position;

const vec3 bitDec = 1./vec3(1.,255.,65025.);
float RGBToFloat (vec3 v) {
    return dot(v, bitDec);
}

void main() {
	vec4 position2 = position;
	position2.xy = position2.xy*particleSize;

	float x2 = mod(position.z,dataSize);
	float y2 = floor(position.z/dataSize);

	vec2 coords = (vec2(x2,y2)+0.5)/dataSize; 

	position2.x += RGBToFloat(texture2D(dataX, coords).rgb)*resolution.x;
	position2.y += RGBToFloat(texture2D(dataY, coords).rgb)*resolution.y;

	position2.z = 1;

	gl_Position = transformMatrix * position2;
}