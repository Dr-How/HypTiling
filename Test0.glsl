#include "Common.glsl"

#define pattern 4

// Choosing between four possible gluing patterns
// 1: a b c d A B C D
// 2: a b A B c d C D
// 3: a b A c B d C D
// 4: a b c A B d C D

float rr = sqrt(sqrt(2.)-1.);

void init() {
    for(int i = 0; i < 8; i++) {
       O[i] = rr * vec2(cos(float(i) * PI / 4.), sin(float(i) * PI / 4.));
    }
}

float insideFD(vec2 uv) {
  float c = 1.;
  for(int i = 0; i < 8; i++) {
    c *= hypGeodesic(uv, O[i], O[(i+1)%8]);
  }
  return c;  
}

//from thebookofshaders
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy-0.5;
    uv *= 2.*vec2(iResolution.x/iResolution.y,1.);
    fragColor=vec4(0., 0., 0., 1.);
    float shade = 1. - smoothstep(0.95, 1.0, length(uv));

    init();

#if pattern == 1
    for(int i = 0; i < 6; i++) {
        uv = fold(uv, O[0], O[1], O[5], O[4]).xy;  // Fold across geodesic o3-o0 vs o2-o1 / 跨测地线o3-o0 vs o2-o1折叠
        uv = fold(uv, O[1], O[2], O[6], O[5]).xy;  // Fold across geodesic o0-o4 vs o7-o5 / 跨测地线o0-o4 vs o7-o5折叠
        uv = fold(uv, O[2], O[3], O[7], O[6]).xy;  // Fold across geodesic o7-o1 vs o6-o2 / 跨测地线o7-o1 vs o6-o2折叠
        uv = fold(uv, O[3], O[4], O[0], O[7]).xy;  // Fold across geodesic o4-o5 vs o3-o6 / 跨测地线o4-o5 vs o3-o6折叠
    }
#endif

#if pattern == 2
    for(int i = 0; i < 6; i++) {
        uv = fold(uv, O[0], O[1], O[3], O[2]).xy;  // Fold across geodesic o3-o0 vs o2-o1 / 跨测地线o3-o0 vs o2-o1折叠
        uv = fold(uv, O[1], O[2], O[4], O[3]).xy;  // Fold across geodesic o0-o4 vs o7-o5 / 跨测地线o0-o4 vs o7-o5折叠
        uv = fold(uv, O[4], O[5], O[7], O[6]).xy;  // Fold across geodesic o7-o1 vs o6-o2 / 跨测地线o7-o1 vs o6-o2折叠
        uv = fold(uv, O[5], O[6], O[0], O[7]).xy;  // Fold across geodesic o4-o5 vs o3-o6 / 跨测地线o4-o5 vs o3-o6折叠
    }
#endif

#if pattern == 3
    for(int i = 0; i < 6; i++) {
        uv = fold(uv, O[0], O[1], O[3], O[2]).xy;  // Fold across geodesic o3-o0 vs o2-o1 / 跨测地线o3-o0 vs o2-o1折叠
        uv = fold(uv, O[1], O[2], O[5], O[4]).xy;  // Fold across geodesic o0-o4 vs o7-o5 / 跨测地线o0-o4 vs o7-o5折叠
        uv = fold(uv, O[3], O[4], O[7], O[6]).xy;  // Fold across geodesic o7-o1 vs o6-o2 / 跨测地线o7-o1 vs o6-o2折叠
        uv = fold(uv, O[5], O[6], O[0], O[7]).xy;  // Fold across geodesic o4-o5 vs o3-o6 / 跨测地线o4-o5 vs o3-o6折叠
    }
#endif

#if pattern == 4
    for(int i = 0; i < 6; i++) {
        uv = fold(uv, O[0], O[1], O[4], O[3]).xy;  // Fold across geodesic o3-o0 vs o2-o1 / 跨测地线o3-o0 vs o2-o1折叠
        uv = fold(uv, O[1], O[2], O[5], O[4]).xy;  // Fold across geodesic o0-o4 vs o7-o5 / 跨测地线o0-o4 vs o7-o5折叠
        uv = fold(uv, O[2], O[3], O[7], O[6]).xy;  // Fold across geodesic o7-o1 vs o6-o2 / 跨测地线o7-o1 vs o6-o2折叠
        uv = fold(uv, O[5], O[6], O[0], O[7]).xy;  // Fold across geodesic o4-o5 vs o3-o6 / 跨测地线o4-o5 vs o3-o6折叠
    }
#endif

    float angle = atan(uv.y,uv.x)+iTime*PI/2.;
    float radius = length(uv)*2.;
    fragColor.rgb += insideFD(uv)*hsb2rgb(vec3(angle/2./PI,radius,1.0));
    // fragColor.rgb += vec3(0.5);

    fragColor *= shade;
}