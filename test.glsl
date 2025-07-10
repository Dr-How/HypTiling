
#include "Common.glsl"

void init(){
    angles[0] = 50.;
    angles[1] = 60.;
    angles[2] = 55.;
    angles[3] = 135.;
    angles[4] = 120.,
    angles[5] = 50.;
    angles[6] = 70.;

    edges[0] = 4.;
    edges[1] = 1.516762842489248386736963515807255698911489082731954588991916460;
    edges[2] = 2.165613466618387923994722211134964417529648672122022097538209402;
    edges[3] = 1.516762842489248386736963515807255698911489082731954588991916460;
    edges[4] = 1.644048033351887582567516469113665346506666443936385360810934537;
    edges[5] = 2.165613466618387923994722211134964417529648672122022097538209402;
    edges[6] = 2.165613466618387923994722211134964417529648672122022097538209402;

    P[0] = vec2(0., 0.);
    P[1] = vec2(0., 0.);
    P[2] = vec2(0., 0.);
    P[3] = vec2(0., 0.);
    P[4] = vec2(0., 0.);
    P[5] = vec2(0., 0.);
    P[6] = vec2(0., 0.);
}

// ============================================================================
// HYPERBOLIC POLYGON COORDINATE CALCULATION - 双曲多边形坐标计算
// ============================================================================
// Calculate the coordinates of vertices of a hyperbolic polygon
// given the internal angles and edge lengths
// 根据给定的内角和边长计算双曲多边形顶点的坐标

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy-0.5;
    uv *= 2.*vec2(iResolution.x/iResolution.y, 1.);
    fragColor=vec4(1.);
    
    init();
    
    coordinates();

    float shade = 1. - smoothstep(0.99, 1.0, length(uv));
    
    if (abs(hypDist(P[6], P[0]) - edges[6]) > 0.00001){
        shade = 0.0;
    }

    for (int i = 0; i < 7; i++){
        shade *= step(0.05, length(uv-P[i]));
    }

    shade += (1. -step(0.05, length(uv-P[0])))*0.5;

    float fundDomain = 1.0;
    for (int i = 0; i < 7; i++){
        fundDomain *= hypGeodesic(uv, P[i], P[(i+1)%7]);
    }
    shade *= step(1.0, (1.-fundDomain)) * 0.3 + 0.7;
    
    fragColor = vec4(shade);
}