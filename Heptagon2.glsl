/*
Based on an ongoing research project of the group of Wang Erxiao from Zhejiang Normal University.
Tiling data computed using exterior program.

List of heptagonal monohedral tilings:
Tiling 1 : https://www.shadertoy.com/view/t3t3Df
Tiling 2 : https://www.shadertoy.com/view/XfycRy
Tiling 3 : https://www.shadertoy.com/view/33y3R1
*/

#include "Common.glsl"

void init() {
    angles[0] =120.;
    angles[1] =120.;
    angles[2] =120.;
    angles[3] =120.;
    angles[4] =140.;
    angles[5] =80.;
    angles[6] =140.;

    edges[0]= 0.570000000000001 ;
    edges[1]=edges[0];
    edges[2]=edges[0];
    edges[3]= 0.406071093907345 ;
    edges[4]= 0.765551946447333 ;
    edges[5]=edges[4];
    edges[6]=edges[3];

    for(int i = 0; i < 7; i++) {
        P[i] = vec2(0.0);
    }
    coordComputed = false;

    coordinates();
    vec2 P0 = P[0];
    vec2 P1 = P[1];
    vec2 Q0 = vec2(0.300742618746379, 0.0);
    vec2 Q1 = vec2(0.34525955300045, 0.245549869718597);

    for(int i = 0; i < 7; i++) {
        P[i] = hypTranslate(P0, P1, Q0, Q1, P[i]);
    }
}

float inside1(vec2 st){
    float side0=hypGeodesic(st,P[0],P[1]);
    float side1=hypGeodesic(st,P[1],P[2]);
    float side2=hypGeodesic(st,P[2],P[3]);
    float side3=hypGeodesic(st,P[3],P[4]);
    float side4=hypGeodesic(st,P[4],P[5]);
    float side5=hypGeodesic(st,P[5],P[6]);
    float side6=hypGeodesic(st,P[6],P[0]);
    float c=side0*side1*side2*side3*side4*side5*side6;
    return c;
}

vec2 a(vec2 z){return hypRotate3(P[1], z);}
vec2 ina(vec2 z){return a(a(z));}
vec2 b(vec2 z){
    vec2 Q2 = hypReflect(P[0], P[6], P[2]);
    return hypRotate3(Q2,z);
}
vec2 inb(vec2 z){return b(b(z));}
vec2 d(vec2 z){
    vec2 Q5 = hypReflect(P[0], P[6], P[5]);
    vec2 Q2 = hypReflect(P[0], P[6], P[2]);
    Q2 = hypRotate2(hypMid(Q5, P[6]), Q2);
    return hypRotate3(Q2, z);
}
vec2 ind(vec2 z){ return d(d(z)); }
vec2 e(vec2 z){
    vec2 Q1 = hypRotate2(hypMid(P[4], P[5]), P[1]);
    return hypRotate3(Q1, z);
}
vec2 ine(vec2 z){ return e(e(z));}

float inside2(vec2 z){
    return inside1(hypReflect(P[0], P[6], z));
}
float inside3(vec2 z){//5
    vec2 Q5 = hypReflect(P[0], P[6], P[5]);
    vec2 w = hypRotate2(hypMid(Q5, P[6]), z);
    w = hypReflect(P[0], P[6], w);
    return inside1(w);
}
float inside4(vec2 z){//4
    vec2 w = hypRotate2(hypMid(P[4], P[5]), z);
    return inside1(w);
}

vec2 T1(vec2 z){ return a(inb(z)); }
vec2 T2(vec2 z){ return ina(b(z)); }
vec2 T3(vec2 z){ return ina(ind(z)); }
vec2 T4(vec2 z){ return a(d(z)); }
vec2 T1inv(vec2 z){ return b(ina(z)); }
vec2 T2inv(vec2 z){ return inb(a(z)); }
vec2 T3inv(vec2 z){ return d(a(z)); }
vec2 T4inv(vec2 z){ return ind(ina(z)); }

vec2 fun(int index,vec2 z) { 
    switch(index) {
        case 0: return T1(z); break;
        case 1: return T2(z); break;
        case 2: return T3(z); break;
        case 3: return T4(z); break;
        case 4: return T1inv(z); break;
        case 5: return T2inv(z); break;
        case 6: return T3inv(z); break;
        case 7: return T4inv(z); break;
        default:return z; break; // 处理无效索引
    }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy-0.5;
    uv *= 2.*vec2(iResolution.x/iResolution.y, 1.);
    fragColor=vec4(0.);
    
    float shade = 1. - smoothstep(0.95, 1.0, length(uv));
    
    init();

    vec2[8] o;
    o[0]=vec2(-0.09, -0.69);
    o[1] = T1(o[0]);
    o[2] = T3inv(o[1]);
    o[3] = T4(o[2]);
    o[4] = T1inv(o[3]);
    o[5] = T2(o[4]);
    o[6] = T3(o[5]);
    o[7] = T2inv(o[6]);
    
    shade *=step(1.0, (1.-
    hypGeodesic(uv, o[2], o[0]) *
    hypGeodesic(uv, o[5], o[2]) *
    hypGeodesic(uv, o[6], o[5]) *
    hypGeodesic(uv, o[1], o[6]) *
    hypGeodesic(uv, o[3], o[1]) *
    hypGeodesic(uv, o[7], o[3]) *
    hypGeodesic(uv, o[4], o[7]) *
    hypGeodesic(uv, o[0], o[4])
    ))*.3+.7;

    for(int i = 0; i < 8; i++) {
        uv = fold(uv, o[0], o[4], o[1], o[3]).xy;
        uv = fold(uv, o[0], o[2], o[7], o[3]).xy;
        uv = fold(uv, o[2], o[5], o[1], o[6]).xy;
        uv = fold(uv, o[5], o[6], o[4], o[7]).xy;
    }
    
        // Color the inside of the fundamental domain
    vec3 col1 = vec3(0.90, 0.10, 0.15);   // vivid red
    vec3 col2 = vec3(0.00, 0.60, 0.30);   // emerald green
    vec3 col3 = vec3(0.10, 0.35, 0.85);   // strong blue
    vec3 col4 = vec3(1.00, 0.80, 0.10);   // bright yellow
    vec3 col5 = vec3(0.60, 0.20, 0.80);   // purple
    vec3 col6 = vec3(0.00, 0.75, 0.75);   // turquoise
    vec3 col7 = vec3(1.00, 0.50, 0.00);   // orange
    vec3 col8 = vec3(0.40, 0.80, 0.10);   // lime green
    vec3 col9 = vec3(0.00, 0.50, 1.00);   // cyan blue
    vec3 colA = vec3(1.00, 0.20, 0.60);   // magenta
    vec3 colB = vec3(0.60, 0.40, 0.10);   // ochre
    vec3 colC = vec3(0.20, 0.80, 0.60);   // mint
    
    fragColor += vec4(col1, 1.) * inside1(uv);
    fragColor += vec4(col2, 1.) * inside2(uv);
    fragColor += vec4(col3, 1.) * inside3(uv);
    fragColor += vec4(col4, 1.) * inside4(uv);
    fragColor += vec4(col5, 1.) * inside1(a(uv));
    fragColor += vec4(col6, 1.) * inside2(a(uv));
    fragColor += vec4(col7, 1.) * inside3(a(uv));
    fragColor += vec4(col8, 1.) * inside4(a(uv));
    fragColor += vec4(col9, 1.) * inside1(ina(uv)); 
    fragColor += vec4(colA, 1.) * inside2(ina(uv));   
    fragColor += vec4(colB, 1.) * inside3(ina(uv));    
    fragColor += vec4(colC, 1.) * inside4(ina(uv));
    fragColor += vec4(colA, 1.) * inside2(inb(uv));
    fragColor += vec4(col6, 1.) * inside2(b(uv));
    fragColor += vec4(col4, 1.) * inside4(T2(uv));
    fragColor += vec4(colB, 1.) * inside3(d(uv));
    fragColor += vec4(col7, 1.) * inside3(ind(uv));
    fragColor += vec4(colC, 1.) * inside4(d(uv));
    fragColor += vec4(col8, 1.) * inside4(ind(uv));
    fragColor += vec4(col8, 1.) * inside4(ina(inb(uv))); 
    fragColor += vec4(colC, 1.) * inside4(ina(inb(a((uv)))));
    fragColor += vec4(col4, 1.) * inside4(ina(inb(ina((uv)))));
    fragColor += vec4(colA, 1.) * inside2(b(a(uv))); 
    fragColor += vec4(col2, 1.) * inside2(b(a(a(uv))));
    fragColor += vec4(col4, 1.) * inside4(d(a(uv)));
    fragColor += vec4(col8, 1.) * inside4(d(ina(uv)));
    
    fragColor.rgb *= shade;
}
