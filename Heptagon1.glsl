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
vec2 P1 = vec2(0.187509955772656, 0.235130047455799);
vec2 P2 = vec2(-0.066921528403913, 0.293202373398501);
vec2 P3 = vec2(-0.407880227210424, 0.12629188065801);
vec2 P4 = vec2(-0.394332095466785, -0.012650020343597);
vec2 P5 = vec2(-0.189392617382025, -0.167766507309416);
vec2 P6 = vec2(0.21988773883909, -0.167364950094866);

float insideFD(vec2 st){
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

// Generators of the symmetry group of the tiling
vec2 a(vec2 z) {return hypRotate3(P1,z);}
vec2 ina(vec2 z) {return a(a(z));}
vec2 b(vec2 z) {return hypRotate2(hypMid(P6,P0),z);}
vec2 c(vec2 z){return hypTranslate(P6, P5, P2, P3, z);}
vec2 inc(vec2 z){return hypTranslate(P2, P3, P6, P5, z);}
vec2 d(vec2 z) {return hypRotate2(hypMid(P4,P5),z);}
vec2 e(vec2 z) {return hypRotate2(hypMid(P3,P4),z);}

// Translational symmetries of the tiling
vec2 T1(vec2 z){return b(e(z));}
vec2 inT1(vec2 z){return e(b(z));}
vec2 T2(vec2 z){return inc(b(ina(z)));}
vec2 inT2(vec2 z){return a(b(c(z)));}
vec2 T3(vec2 z){return ina(e(a(inc(z))));}
vec2 inT3(vec2 z){return c(ina(e(a(z))));}
vec2 T4(vec2 z){return ina(d(ina(d(z))));}
vec2 inT4(vec2 z){return d(a(d(a(z))));}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy-0.5;
    uv *= 2.*vec2(iResolution.x/iResolution.y,1.);
    fragColor=vec4(0., 0., 0., 1.);

    // Poincare disk
    float shade = 1. - smoothstep(0.99, 1.0, length(uv));

    // Mouse searching the suitable vertices
    // vec4 m = iMouse;
    // vec2 p0 = vec2(0.0);
    // if(m.z>0. && m.w < 0. || m.z < 0.){
    //     p0 = m.xy/iResolution.xy-0.5;;
    //     p0 *= 2.*vec2(iResolution.x/iResolution.y,1.);
    // }
    // shade *= step(0.05, length(uv-p0));
    // vec2 p1 = T1(p0);
    // shade *= step(0.05, length(uv-p1));
    // vec2 p2 = T2(p1);
    // shade *= step(0.05, length(uv-p2));
    // vec2 p3 = inT1(p2);
    // shade *= step(0.05, length(uv-p3));
    // vec2 p4 = T4(p3);
    // shade *= step(0.05, length(uv-p4));
    // vec2 p5 = T3(p4);
    // shade *= step(0.05, length(uv-p5));
    // vec2 p6 = inT4(p5);
    // shade *= step(0.05, length(uv-p6));
    // vec2 p7 = inT2(p6);
    // shade *= step(0.05, length(uv-p7));


    // Vertices of the fundamental octagon
    vec2 o0 = vec2(-0.625, 0.545);
    vec2 o1 = T1(o0);
    vec2 o2 = T2(o1);
    vec2 o3 = inT1(o2);
    vec2 o4 = T4(o3);
    vec2 o5 = T3(o4);
    vec2 o6 = inT4(o5);
    vec2 o7 = inT2(o6);
    // vec2 o8 = inT3(o7);

    // Shade the interior of the octagon
    shade *= step(1.0, (1.-
        hypGeodesic(uv, o4, o0) *
        hypGeodesic(uv, o5, o4) *
        hypGeodesic(uv, o7, o5) *
        hypGeodesic(uv, o1, o7) *
        hypGeodesic(uv, o2, o1) *
        hypGeodesic(uv, o6, o2) *
        hypGeodesic(uv, o3, o6) *
        hypGeodesic(uv, o0, o3) *
    1.))*.3+.7;

    // Test fixedPoints and fold
    // vec4 fixPts = fixedPoints(o3, o0, o2, o1);
    // shade *= step(0.1, abs(length(uv-fixPts.xy)));
    // shade *= step(0.1, abs(length(uv-fixPts.zw)));

    // vec3 foldedUV = fold(uv, o3, o0, o2, o1);
    // shade += 1. - smoothstep(0.0, 0.01, abs(foldedUV.z-0.0));

    // Fold into a fundamental domain modulo translations
    for(int i = 0; i < 6; i++) {
        uv = fold(uv, o3, o0, o2, o1).xy;
        uv = fold(uv, o0, o4, o7, o5).xy;
        uv = fold(uv, o7, o1, o6, o2).xy;
        uv = fold(uv, o4, o5, o3, o6).xy;
    }

    //fragColor += smoothstep(0.5, 0.0, length(uv));

    // 12 well-distinguishable, visually pleasing tile colors
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

    // fragColor = mix(fragColor, insideSomeFD(uv), insideSomeFD(uv).w);
    fragColor += vec4(col1, 1.) * insideFD(uv);
    fragColor += vec4(col2, 1.) * insideFD(ina(uv));
    fragColor += vec4(col3, 1.) * insideFD(a(uv));
    fragColor += vec4(col4, 1.) * insideFD(b(uv));
    fragColor += vec4(col5, 1.) * insideFD(c(uv));
    fragColor += vec4(col6, 1.) * insideFD(inc(uv));
    fragColor += vec4(col7, 1.) * insideFD(d(uv));
    fragColor += vec4(col8, 1.) * insideFD(c(ina(uv)));
    fragColor += vec4(col9, 1.) * insideFD(d(ina(uv)));
    fragColor += vec4(colA, 1.) * insideFD(c(a(uv)));
    fragColor += vec4(colB, 1.) * insideFD(d(a(uv)));
    fragColor += vec4(colC, 1.) * insideFD(e(a(uv)));
    fragColor += vec4(col4, 1.) * insideFD(e(uv));
    fragColor += vec4(col5, 1.) * insideFD(inc(a(uv)));
    fragColor += vec4(col6, 1.) * insideFD(e(ina(uv)));
    fragColor += vec4(colC, 1.) * insideFD(a(inc(uv)));
    fragColor += vec4(col9, 1.) * insideFD(inc(inc(uv)));
    fragColor += vec4(colB, 1.) * insideFD(b(ina(inc(uv))));
    fragColor += vec4(col7, 1.) * insideFD(c(e(a(uv))));
    fragColor += vec4(colB, 1.) * insideFD(ina(d(uv)));
    fragColor += vec4(col2, 1.) * insideFD(b(c(uv)));
    fragColor += vec4(col8, 1.) * insideFD(ina(c(uv)));
    fragColor += vec4(col9, 1.) * insideFD(e(ina(c(uv))));
    fragColor += vec4(col8, 1.) * insideFD((a(e(uv))));
    fragColor += vec4(col8, 1.) * insideFD(d(c(a(uv))));
    fragColor += vec4(col9, 1.) * insideFD(c(c(a(uv))));
    fragColor += vec4(col2, 1.) * insideFD((e(inc(uv))));
    fragColor += vec4(colA, 1.) * insideFD(d(a(e(uv))));
    fragColor += vec4(col9, 1.) * insideFD(e(a(e(uv))));
    fragColor += vec4(col9, 1.) * insideFD(ina(inc(inc(uv))));

    // Coloring three generations suffices
    // for (int i = 0; i < 8; i++) {
    //     vec2 w0 = fun2(i, uv);
    //     fragColor = mix(fragColor, insideSomeFD(w0), insideSomeFD(w0).w);
    //     for(int j = 0; j < 8; j++) {
    //         vec2 w1 = fun2(j, w0);
    //         fragColor = mix(fragColor, insideSomeFD(w1), insideSomeFD(w1).w);
    //         for(int k = 0; k < 8; k++) {
    //             vec2 w2 = fun2(k, w1);
    //             fragColor = mix(fragColor, insideSomeFD(w2), insideSomeFD(w2).w);
    //         }
    //     }
    // }
    fragColor.rgb *= shade;
}