/*
Based on an ongoing research project of the group of Wang Erxiao from Zhejiang Normal University.
Part of the code is contributed by qingshu and Wu.
Tiling data computed using exterior program.

List of heptagonal monohedral tilings:
Tiling 1 : https://www.shadertoy.com/view/t3t3Df
Tiling 2 : https://www.shadertoy.com/view/XfycRy
Tiling 3 : https://www.shadertoy.com/view/33y3R1
*/

#include "Common.glsl"

vec2 P0 = vec2(0.300742618746379, 0);
vec2 P1 = vec2(0.34525955300045, 0.245549869718597);
vec2 P2 = vec2(0.202401568809967, 0.426638584831781);
vec2 P3 = vec2(-0.024016800671514, 0.448665753566109);
vec2 P4 = vec2(-0.14760106304294, 0.331675461412054);
vec2 P5 = vec2(-0.241285628861742, -0.010343249532733);
vec2 P6 = vec2(0.127483229064559, -0.084298662030841);

float inside1(vec2 st){
    float side0=hypGeodesic(st,P0,P1);
    float side1=hypGeodesic(st,P1,P2);
    float side2=hypGeodesic(st,P2,P3);
    float side3=hypGeodesic(st,P3,P4);
    float side4=hypGeodesic(st,P4,P5);
    float side5=hypGeodesic(st,P5,P6);
    float side6=hypGeodesic(st,P6,P0);
    float c=side0*side1*side2*side3*side4*side5*side6;
    return c;
}

vec2 a(vec2 z){return hypRotate3(P1, z);}
vec2 ina(vec2 z){return a(a(z));}
vec2 b(vec2 z){
    vec2 Q2 = hypReflect(P0, P6, P2);
    return hypRotate3(Q2,z);
}
vec2 inb(vec2 z){return b(b(z));}
vec2 d(vec2 z){
    vec2 Q5 = hypReflect(P0, P6, P5);
    vec2 Q2 = hypReflect(P0, P6, P2);
    Q2 = hypRotate2(hypMid(Q5, P6), Q2);
    return hypRotate3(Q2, z);
}
vec2 ind(vec2 z){ return d(d(z)); }
vec2 e(vec2 z){
    vec2 Q1 = hypRotate2(hypMid(P4, P5), P1);
    return hypRotate3(Q1, z);
}
vec2 ine(vec2 z){ return e(e(z));}

float inside2(vec2 z){
    return inside1(hypReflect(P0, P6, z));
}
float inside3(vec2 z){//5
    vec2 Q5 = hypReflect(P0, P6, P5);
    vec2 w = hypRotate2(hypMid(Q5, P6), z);
    w = hypReflect(P0, P6, w);
    return inside1(w);
}
float inside4(vec2 z){//4
    vec2 w = hypRotate2(hypMid(P4, P5), z);
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
    
   float shade = 1. - smoothstep(0.99, 1.0, length(uv));
    
    
    vec2 o0=vec2(-0.09, -0.69);
    vec2 o1 = T1(o0);
    vec2 o2 = T3inv(o1);
    vec2 o3 = T4(o2);
    vec2 o4 = T1inv(o3);
    vec2 o5 = T2(o4);
    vec2 o6 = T3(o5);
    vec2 o7 = T2inv(o6);
    
    shade *=step(1.0, (1.-
    hypGeodesic(uv, o2, o0) *
    hypGeodesic(uv, o5, o2) *
    hypGeodesic(uv, o6, o5) *
    hypGeodesic(uv, o1, o6) *
    hypGeodesic(uv, o3, o1) *
    hypGeodesic(uv, o7, o3) *
    hypGeodesic(uv, o4, o7) *
    hypGeodesic(uv, o0, o4)
    ))*.3+.7;

    for(int i = 0; i < 8; i++) {
        uv = fold(uv, o0, o4, o1, o3).xy;
        uv = fold(uv, o0, o2, o7, o3).xy;
        uv = fold(uv, o2, o5, o1, o6).xy;
        uv = fold(uv, o5, o6, o4, o7).xy;
    }
    
        // Color the inside of the fundamental domain
    vec3 col1 = vec3(0.0, 1.0, 0.0);
    vec3 col2 = vec3(0.0, 0.0, 1.0);
    vec3 col3 = vec3(1.0, 0.0, 0.0);
    vec3 col4 = vec3(1.0, 1.0, 0.0);
    vec3 col5 = vec3(0.0, 1.0, 1.0);
    vec3 col6 = vec3(1.0, 0.0, 1.0);
    vec3 col7 = vec3(0.2, 0.7, 0.8);
    vec3 col8 = vec3(0.6, 0.6, 0.6);
    vec3 col9 = vec3(1.0, 0.7, 0.8);
    vec3 colA = vec3(1.0, 0.4, 0.6);
    vec3 colB = vec3(0.5, 0.8, 0.8);
    vec3 colC = vec3(0.7, 0.8, 1.0);
    
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
