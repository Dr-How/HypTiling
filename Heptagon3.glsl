/*
Based on an ongoing research project of the group of Wang Erxiao from Zhejiang Normal University.
Tiling data computed using exterior program.

List of heptagonal monohedral tilings:
Tiling 1 : https://www.shadertoy.com/view/t3t3Df
Tiling 2 : https://www.shadertoy.com/view/t3KGR1
Tiling 3 : https://www.shadertoy.com/view/33y3R1
*/

#include "Common.glsl"

void init() {
    angles[0] = 95.;
    angles[1] = 120.;
    angles[2] = 110.;
    angles[3] = 105.;
    angles[4] = 155.;
    angles[5] = 130.;
    angles[6] = 125.;

    edges[0] = 0.753560127018144;
    edges[1] = edges[0];
    edges[2] = 0.43422736908768;
    edges[3] = 0.798077355147606;
    edges[4] = edges[2];
    edges[5] = 0.186557981786547;
    edges[6] = edges[3];

    for(int i = 0; i < 7; i++) {
        P[i] = vec2(0.0);
    }
    coordComputed = false;

    coordinates();
    vec2 P0 = P[0];
    vec2 P1 = P[1];
    vec2 Q0 = vec2(0.2, 0.0);
    vec2 Q1 = vec2(0.0, 0.3);

    for(int i = 0; i < 7; i++) {
        P[i] = hypTranslate(P0, P1, Q0, Q1, P[i]);
    }
}

float insideFD(vec2 st){
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

// Generators of the symmetry group of the tiling
vec2 a(vec2 z){return hypRotate3(P[1],z);}
vec2 ina(vec2 z){return a(a(z));}
vec2 b(vec2 z){return hypTranslate(P[2], P[3], P[5], P[4], z);}
vec2 inb(vec2 z){return hypTranslate(P[5], P[4], P[2], P[3], z);}
vec2 c(vec2 z){return hypTranslate(P[3], P[4], P[0], P[6], z);}
vec2 inc(vec2 z){return hypTranslate(P[0], P[6], P[3], P[4], z);}
vec2 d(vec2 z){return hypRotate2(hypMid(P[5], P[6]),z);}
vec2 bf(vec2 z){return hypBisectReflect(P[5], P[4], z);}
vec2 cf(vec2 z){return hypBisectReflect(P[0], P[6], z);}

vec2 B(vec2 z){return bf(b(z));}
vec2 inB(vec2 z){return inb(bf(z));}
vec2 C(vec2 z){return cf(c(z));}
vec2 inC(vec2 z){return inc(cf(z));}

vec2 T1(vec2 z){return B(C(ina(z)));}
vec2 inT1(vec2 z){return a(inC(inB(z)));}
vec2 T2(vec2 z){return inC(inB(a(z)));}
vec2 inT2(vec2 z){return ina(B(C(z)));}
vec2 T3(vec2 z){return a(d(inB(inB(z))));}
vec2 inT3(vec2 z){return B(B(d(ina(z))));}
vec2 T4(vec2 z){return C(ina(B(z)));}
vec2 inT4(vec2 z){return inB(a(inC(z)));}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy-0.5;
    uv *= 2.*vec2(iResolution.x/iResolution.y,1.);
    fragColor=vec4(0.0, 0.0, 0.0, 1.);

    // Poincare disk
    float shade = 1. - smoothstep(0.95, 1.0, length(uv));

    init();

    // Mouse searching the suitable vertices
    // vec4 m = iMouse;
    // vec2 p0 = vec2(0.0);
    // if(m.z>0. && m.w < 0. || m.z < 0.){
    //     p0 = m.xy/iResolution.xy-0.5;;
    //     p0 *= 2.*vec2(iResolution.x/iResolution.y,1.);
    // }
    // p0 = P3;
    // shade *= step(0.05, length(uv-p0));
    // vec2 p1 = inT2(p0);
    // shade *= step(0.05, length(uv-p1));
    // vec2 p2 = T4(p1);
    // shade *= step(0.05, length(uv-p2));
    // vec2 p3 = T1(p2);
    // shade *= step(0.05, length(uv-p3));
    // vec2 p4 = T3(p3);
    // shade *= step(0.05, length(uv-p4));
    // vec2 p5 = T2(p4);
    // shade *= step(0.05, length(uv-p5));
    // vec2 p6 = inT1(p5);
    // shade *= step(0.05, length(uv-p6));
    // vec2 p7 = inT3(p6);
    // shade *= step(0.05, length(uv-p7));
    // shade *= step(1.0, (1. -
    //     hypGeodesic(uv, p1, p0) *
    //     hypGeodesic(uv, p4, p1) *
    //     hypGeodesic(uv, p6, p4) *
    //     hypGeodesic(uv, p2, p6) *
    //     hypGeodesic(uv, p7, p2) *
    //     hypGeodesic(uv, p3, p7) *
    //     hypGeodesic(uv, p5, p3) *
    //     hypGeodesic(uv, p0, p5)
    // ))*.3+.7;

    index = int[8](0, 1, 4, 6, 2, 7, 3, 5);

    // Vertices of the fundamental octagon
    O[0] = vec2(0.0);

    for(int i = 0; i < 10; i++) {
        O[1] = inT2(O[0]);
        O[2] = T4(O[1]);
        O[3] = T1(O[2]);
        O[4] = T3(O[3]);
        O[5] = T2(O[4]);
        O[6] = inT1(O[5]);
        O[7] = inT3(O[6]);
        moveO0();
    }
    
    shade *= step(0.01, length(uv-O[0]));

    // Shade the interior of the octagon
    float s = 1.0;
    for (int i = 0; i < 8; i++) {
        s *= hypGeodesic(uv, o(i+1), o(i));  // Side from o((i+3)%8) to o((i+2)%8) / 从o((i+3)%8)到o((i+2)%8)的边
    }
    shade *= step(1.0, (1. - s)) * 0.3 + 0.7;  // Adjust shading based on geodesic product / 根据测地线乘积调整着色

    // Test fixedPoints and fold
    // vec4 fixPts = fixedPoints(o0, o1, o7, o2);
    // shade *= step(0.1, abs(length(uv-fixPts.xy)));
    // shade *= step(0.1, abs(length(uv-fixPts.zw)));

    // vec3 foldedUV = fold(uv, o6, o2, o5, o3);
    // shade += 1. - smoothstep(0.0, 0.01, abs(foldedUV.z-0.0));

    for(int i = 0; i <8 ; i++) {
        uv = fold(uv, O[0], O[1], O[7], O[2]).xy;
        uv = fold(uv, O[1], O[4], O[0], O[5]).xy;
        uv = fold(uv, O[4], O[6], O[3], O[7]).xy;
        uv = fold(uv, O[6], O[2], O[5], O[3]).xy;
    }
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
    
    // Color the inside of the fundamental domain
    // fragColor = mix(fragColor, insideSomeFD(uv), step(0.5, insideSomeFD(uv).w));
    
    fragColor += vec4(col1, 1.) * insideFD(uv);
    fragColor += vec4(col2, 1.) * insideFD(ina(uv));
    fragColor += vec4(col3, 1.) * insideFD(a(uv));
    fragColor += vec4(col4, 1.) * insideFD(B(uv));
    fragColor += vec4(col5, 1.) * insideFD(inB(uv));
    fragColor += vec4(col6, 1.) * insideFD(C(uv));
    fragColor += vec4(col7, 1.) * insideFD(inC(uv));
    fragColor += vec4(col8, 1.) * insideFD(d(uv));
    fragColor += vec4(col9, 1.) * insideFD(inB(ina(uv)));
    fragColor += vec4(colA, 1.) * insideFD(inC(ina(uv)));
    fragColor += vec4(colB, 1.) * insideFD(d(ina(uv)));
    fragColor += vec4(col8, 1.) * insideFD(inC(B(uv)));
    fragColor += vec4(col4, 1.) * insideFD(C(d(uv)));
    fragColor += vec4(colB, 1.) * insideFD(inB(inB(uv)));
    fragColor += vec4(col7, 1.) * insideFD(d(ina(C(uv))));
    fragColor += vec4(col9, 1.) * insideFD(C(B(C(uv))));
    fragColor += vec4(colA, 1.) * insideFD(inB(inB(inB(uv))));
    fragColor += vec4(colA, 1.) * insideFD(ina(inC(uv)));
    fragColor += vec4(colC, 1.) * insideFD(d(a(uv)));
    fragColor += vec4(colC, 1.) * insideFD(C(C(uv)));
    fragColor += vec4(col3, 1.) * insideFD(B(C(uv)));
    fragColor += vec4(col5, 1.) * insideFD(inB(T1(uv)));
    fragColor += vec4(colC, 1.) * insideFD(ina(d(ina(uv))));
    fragColor += vec4(colA, 1.) * insideFD((a(B(uv))));
    fragColor += vec4(colC, 1.) * insideFD((a(d(uv))));
    fragColor += vec4(colC, 1.) * insideFD(inB(ina(inB(uv))));
    fragColor += vec4(colA, 1.) * insideFD(d(ina(inB(uv))));
    fragColor += vec4(colA, 1.) * insideFD(C(C(C(uv))));
    fragColor += vec4(colA, 1.) * insideFD(C(a(d(uv))));
    fragColor += vec4(colA, 1.) * insideFD(C(inB(inB(ina(uv)))));
    
    // Coloring two generations suffices
    /* for (int i = 0; i < 8; i++) { 
        vec2 w0 = fun2(i, uv);
        fragColor = mix(fragColor, insideSomeFD(w0), step(0.5, insideSomeFD(w0).w));
        for(int j = 0; j < 8; j++) {
            vec2 w1 = fun2(j, w0);
            fragColor = mix(fragColor, insideSomeFD(w1), step(0.5, insideSomeFD(w1).w));
            for(int k = 0; k < 8; k++) {
                vec2 w2 = fun2(k, w1);
                fragColor = mix(fragColor, insideSomeFD(w2), step(0.5, insideSomeFD(w2).w));
            }
        }
    }*/
    
    fragColor.rgb *= shade;
}