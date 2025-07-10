
#include "Common.glsl"

float[7] angles = float[7](
    50.,
    60.,
    55.,
    135.,
    120.,
    50.,
    70.
);

float[7] edges = float[7](
    4.,
    1.516762842489248386736963515807255698911489082731954588991916460,
    2.165613466618387923994722211134964417529648672122022097538209402,
    1.516762842489248386736963515807255698911489082731954588991916460,
    1.644048033351887582567516469113665346506666443936385360810934537,
    2.165613466618387923994722211134964417529648672122022097538209402,
    2.165613466618387923994722211134964417529648672122022097538209402
);

vec2[7] P = vec2[7](vec2(0., 0.), vec2(0., 0.), vec2(0., 0.), vec2(0., 0.), vec2(0., 0.), vec2(0., 0.), vec2(0., 0.));

// ============================================================================
// HYPERBOLIC POLYGON COORDINATE CALCULATION - 双曲多边形坐标计算
// ============================================================================
// Calculate the coordinates of vertices of a hyperbolic polygon
// given the internal angles and edge lengths
// 根据给定的内角和边长计算双曲多边形顶点的坐标

void collectiveRotate(int i){
    for (int j = 0; j < 7; j++){
        P[j] = hypTranslate(P[i], P[j]);
    }
    vec2 w = normalize(P[i-1]);
    float theta = atan(w.y, w.x);
    theta = angles[i] * PI / 180. - theta;
    for (int j = 0; j < 7; j++){
        P[j] = hypRotate(P[i], theta, P[j]);
    }
}

void coordinates() {
    for (int i = 0; i < 6; i++){
        collectiveRotate(i);
        float x = edges[i] / 2.;
        P[i+1] = vec2((exp(x)-exp(-x))/(exp(x)+exp(-x)), 0.);
    }

    vec2 center = (P[0] + P[1] + P[2] + P[3] + P[4] + P[5] + P[6]) / 7.;
    for (int i = 0; i < 7; i++){
        P[i] = hypTranslate(center, P[i]);
    }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy-0.5;
    uv *= 3.*vec2(iResolution.x/iResolution.y, 1.);
    fragColor=vec4(1.);
    
    coordinates();

    float shade = 1. - smoothstep(0.99, 1.0, length(uv));

    shade *= step(0.05, length(uv-P[0]));
    shade *= step(0.05, length(uv-P[1]));
    shade *= step(0.05, length(uv-P[2]));
    shade *= step(0.05, length(uv-P[3]));
    shade *= step(0.05, length(uv-P[4]));
    shade *= step(0.05, length(uv-P[5]));
    shade *= step(0.05, length(uv-P[6]));
    
    shade *= step(1.0, (1.-
    hypGeodesic(uv, P[0], P[1]) *
    hypGeodesic(uv, P[1], P[2]) *
    hypGeodesic(uv, P[2], P[3]) *
    hypGeodesic(uv, P[3], P[4]) *
    hypGeodesic(uv, P[4], P[5]) *
    hypGeodesic(uv, P[5], P[6]) *
    hypGeodesic(uv, P[6], P[0])
    ))*0.3+0.7;

    fragColor = vec4(shade);
}