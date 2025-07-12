/*
Based on an ongoing research project of the group of Wang Erxiao from Zhejiang Normal University.
Tiling data computed using exterior program.

基于浙江师范大学王二小课题组正在进行的科研项目。
平铺数据使用外部程序计算。

List of heptagonal monohedral tilings:
七边形单面体平铺列表：
Tiling 1 : https://www.shadertoy.com/view/t3t3Df
Tiling 2 : https://www.shadertoy.com/view/t3KGR1
Tiling 3 : https://www.shadertoy.com/view/33y3R1
*/

#include "Common.glsl"

// ============================================================================
// FUNDAMENTAL POLYGON - 基本多边形
// ============================================================================
// These are the angles and edge lengths of the fundamental heptagon
// 这些是双曲七边形的角度和边长
// The data are computed to create a regular heptagon in hyperbolic geometry
// 数据经过计算以在双曲几何中创建正七边形

void init() {
    angles[0] = 121.12;
    angles[1] = 120.0;
    angles[2] = 130.0;
    angles[3] = 100.0;
    angles[4] = 125.0;
    angles[5] = 135.0;
    angles[6] = 108.88;
    
    edges[0] = 0.566256306735315;
    edges[1] = 0.566256306735315; 
    edges[2] = 0.854179974219264; 
    edges[3] = 0.334459677626671; 
    edges[4] = 0.570475204949615; 
    edges[5] = 0.854166462392129; 
    edges[6] = 0.402853231606247; 

    for(int i = 0; i < 7; i++) {
        P[i] = vec2(0.0);
    }
    coordComputed = false;

    coordinates();
    vec2 P0 = P[0];
    vec2 P1 = P[1];
    vec2 Q0 = vec2(0.300742618746379, 0);
    vec2 Q1 = vec2(0.187509955772656, 0.235130047455799);

    for(int i = 0; i < 7; i++) {
        P[i] = hypTranslate(P0, P1, Q0, Q1, P[i]);
    }
}

// ============================================================================
// FUNDAMENTAL DOMAIN DETECTION - 基本域检测
// ============================================================================
// Check if a point is inside the fundamental heptagon domain
// 检查点是否在基本七边形域内
// Uses hyperbolic geodesics to define the boundary of the heptagon
// 使用双曲测地线定义七边形的边界
float insideFD(vec2 st){
    // Check if point is outside each of the 7 sides of the heptagon
    // 检查点是否在七边形7条边的外部
    float side0=hypGeodesic(st,P[0],P[1]);  // Side from P0 to P1 / 从P0到P1的边
    float side1=hypGeodesic(st,P[1],P[2]);  // Side from P1 to P2 / 从P1到P2的边
    float side2=hypGeodesic(st,P[2],P[3]);  // Side from P2 to P3 / 从P2到P3的边
    float side3=hypGeodesic(st,P[3],P[4]);  // Side from P3 to P4 / 从P3到P4的边
    float side4=hypGeodesic(st,P[4],P[5]);  // Side from P4 to P5 / 从P4到P5的边
    float side5=hypGeodesic(st,P[5],P[6]);  // Side from P5 to P6 / 从P5到P6的边
    float side6=hypGeodesic(st,P[6],P[0]);  // Side from P6 to P0 / 从P6到P0的边
    
    // Multiply all side checks - if any side returns 1 (outside), result is 1
    // 将所有边的检查结果相乘 - 如果任何边返回0（外部），结果为0
    float c=side0*side1*side2*side3*side4*side5*side6;
    return c;
}

// ============================================================================
// SYMMETRY GROUP GENERATORS - 对称群生成元
// ============================================================================
// These functions generate the symmetry group of the hyperbolic heptagon tiling
// 这些函数生成双曲七边形平铺的对称群
// Each generator is a hyperbolic isometry that preserves the tiling pattern
// 每个生成元都是保持平铺模式的双曲等距变换

// 120-degree rotation around vertex P1
// 围绕顶点P1旋转120度
vec2 a(vec2 z) {return hypRotate3(P[1],z);}
// Inverse of a (240-degree rotation, equivalent to a²)
// a的逆（240度旋转，等价于a²）
vec2 ina(vec2 z) {return a(a(z));}

// 180-degree rotation around the midpoint of P6 and P0 (reflection symmetry)
// 围绕P6和P0的中点旋转180度（反射对称性）
vec2 b(vec2 z) {return hypRotate2(hypMid(P[6],P[0]),z);}

// Hyperbolic translation that maps P6 to P5 and P2 to P3
// 将P6映射到P5，P2映射到P3的双曲平移
vec2 c(vec2 z){return hypTranslate(P[6], P[5], P[2], P[3], z);}
// Inverse of c
// c的逆
vec2 inc(vec2 z){return hypTranslate(P[2], P[3], P[6], P[5], z);}

// 180-degree rotation around the midpoint of P4 and P5
// 围绕P4和P5的中点旋转180度
vec2 d(vec2 z) {return hypRotate2(hypMid(P[4],P[5]),z);}

// 180-degree rotation around the midpoint of P3 and P4
// 围绕P3和P4的中点旋转180度
vec2 e(vec2 z) {return hypRotate2(hypMid(P[3],P[4]),z);}

// ============================================================================
// TRANSLATIONAL SYMMETRIES - 平移对称性
// ============================================================================
// These are composite transformations that create the periodic structure
// 这些是创建周期结构的复合变换
// Each T function represents a different translation direction in the tiling
// 每个T函数代表平铺中不同的平移方向

// Translation T1: combination of b and e transformations
// 平移T1：b和e变换的组合
vec2 T1(vec2 z){return b(e(z));}
vec2 inT1(vec2 z){return e(b(z));}

// Translation T2: combination of inc, b, and ina transformations
// 平移T2：inc、b和ina变换的组合
vec2 T2(vec2 z){return inc(b(ina(z)));}
vec2 inT2(vec2 z){return a(b(c(z)));}

// Translation T3: combination of ina, e, a, and inc transformations
// 平移T3：ina、e、a和inc变换的组合
vec2 T3(vec2 z){return ina(e(a(inc(z))));}
vec2 inT3(vec2 z){return c(ina(e(a(z))));}

// Translation T4: combination of ina and d transformations
// 平移T4：ina和d变换的组合
vec2 T4(vec2 z){return ina(d(ina(d(z))));}
vec2 inT4(vec2 z){return d(a(d(a(z))));}

// ============================================================================
// MAIN RENDERING FUNCTION - 主渲染函数
// ============================================================================
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Convert pixel coordinates to normalized coordinates centered at origin
    // 将像素坐标转换为以原点为中心的归一化坐标
    vec2 uv = fragCoord/iResolution.xy-0.5;
    // Adjust for aspect ratio to maintain circular shape
    // 调整宽高比以保持圆形
    uv *= 2.*vec2(iResolution.x/iResolution.y,1.);
    
    // Initialize output color to black
    // 将输出颜色初始化为黑色
    fragColor=vec4(0., 0., 0., 1.);
    
    // Create smooth boundary for the Poincare disk (unit circle)
    // 为Poincare圆盘（单位圆）创建平滑边界
    // Points outside the disk are darkened to create the boundary effect
    // 圆盘外的点变暗以创建边界效果
    float shade = 1. - smoothstep(0.95, 1.0, length(uv));

    init();

    // Code for interactive vertex placement and testing
    // 用于交互式顶点放置和测试的代码
    // Uncomment to enable mouse-based vertex manipulation
    // 取消注释以启用基于鼠标的顶点操作
    // vec4 m = iMouse;
    // vec2 p0 = vec2(0.0);
    // if(m.z>0. && m.w < 0. || m.z < 0.){
    //     p0 = m.xy/iResolution.xy-0.5;;
    //     p0 *= 2.*vec2(iResolution.x/iResolution.y,1.);
    // }
    // p0 = inT1(P0);
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
    // shade *= step(1.0, (1.-
    //     hypGeodesic(uv, p4, p0) *
    //     hypGeodesic(uv, p5, p4) *
    //     hypGeodesic(uv, p7, p5) *
    //     hypGeodesic(uv, p1, p7) *
    //     hypGeodesic(uv, p2, p1) *
    //     hypGeodesic(uv, p6, p2) *
    //     hypGeodesic(uv, p3, p6) *
    //     hypGeodesic(uv, p0, p3) *
    // 1.))*.3+.7;

    // ============================================================================
    // FUNDAMENTAL OCTAGON - 基本八边形
    // ============================================================================
    // Define vertices of a fundamental octagon for testing and visualization
    // 定义用于测试和可视化的基本八边形的顶点
    // This octagon represents a larger fundamental domain in the tiling
    // 这个八边形代表平铺中基本域
    // The order of the translations are obtained from the relation given by GAP
    // 平移的顺序是从GAP中得到的
    index = int[8](0, 4, 5, 7, 1, 2, 6, 3);

    O[0] = vec2(-0.625, 0.545);  // Starting vertex / 起始顶点
    // o0 = inT1(P0);  // Alternative: derive from fundamental heptagon / 替代方案：从基本七边形导出

    O[1] = T1(O[0]);  // Apply translation T1 / 应用平移T1
    O[2] = T2(O[1]);  // Apply translation T2 / 应用平移T2
    O[3] = inT1(O[2]); // Apply inverse of T1 / 应用T1的逆
    O[4] = T4(O[3]);   // Apply translation T4 / 应用平移T4
    O[5] = T3(O[4]);   // Apply translation T3 / 应用平移T3
    O[6] = inT4(O[5]); // Apply inverse of T4 / 应用T4的逆
    O[7] = inT2(O[6]); // Apply inverse of T2 / 应用T2的逆
    // vec2 o8 = inT3(o7); // Additional vertex if needed / 如果需要额外的顶点

    // Shade the interior of the octagon with a darker color
    // 用较暗的颜色为八边形内部着色
    // This creates a visual boundary for the fundamental domain
    // 这为基本域创建视觉边界
    float s = 1.0;
    for (int i = 0; i < 8; i++) {
        s *= hypGeodesic(uv, o(i+1), o(i));  // Side from o((i+3)%8) to o((i+2)%8) / 从o((i+3)%8)到o((i+2)%8)的边
    }
    shade *= step(1.0, (1. - s)) * 0.3 + 0.7;  // Adjust shading based on geodesic product / 根据测地线乘积调整着色

    // ============================================================================
    // TESTING FUNCTIONS (COMMENTED OUT) - 测试函数（已注释）
    // ============================================================================
    // Code for testing fixed points and folding functions
    // 用于测试不动点和折叠函数的代码
    // Uncomment to visualize fixed points and folding behavior
    // 取消注释以可视化不动点和折叠行为
    // vec4 fixPts = fixedPoints(o3, o0, o2, o1);
    // shade *= step(0.1, abs(length(uv-fixPts.xy)));
    // shade *= step(0.1, abs(length(uv-fixPts.zw)));

    // vec3 foldedUV = fold(uv, o3, o0, o2, o1);
    // shade += 1. - smoothstep(0.0, 0.01, abs(foldedUV.z-0.0));

    // ============================================================================
    // FOLDING INTO FUNDAMENTAL DOMAIN - 折叠到基本域
    // ============================================================================
    // Apply folding transformations to reduce any point to the fundamental domain
    // 应用折叠变换将任意点归约到基本域
    // This ensures we only need to color one fundamental domain and replicate it
    // 这确保我们只需要为一个基本域着色并复制它
    for(int i = 0; i < 6; i++) {
        // Fold using different pairs of geodesics to cover all cases
        // 使用不同的测地线对进行折叠以覆盖所有情况
        uv = fold(uv, O[3], O[0], O[2], O[1]).xy;  // Fold across geodesic o3-o0 vs o2-o1 / 跨测地线o3-o0 vs o2-o1折叠
        uv = fold(uv, O[0], O[4], O[7], O[5]).xy;  // Fold across geodesic o0-o4 vs o7-o5 / 跨测地线o0-o4 vs o7-o5折叠
        uv = fold(uv, O[7], O[1], O[6], O[2]).xy;  // Fold across geodesic o7-o1 vs o6-o2 / 跨测地线o7-o1 vs o6-o2折叠
        uv = fold(uv, O[4], O[5], O[3], O[6]).xy;  // Fold across geodesic o4-o5 vs o3-o6 / 跨测地线o4-o5 vs o3-o6折叠
    }

    // Alternative visualization: show distance to origin after folding
    // 替代可视化：显示折叠后到原点的距离
    //fragColor += smoothstep(0.5, 0.0, length(uv));

    // ============================================================================
    // COLOR PALETTE - 调色板
    // ============================================================================
    // Define 12 visually distinct and pleasing colors for the tiling
    // 为平铺定义12种视觉上不同且美观的颜色
    // Each color is carefully chosen to be distinguishable from others
    // 每种颜色都经过精心选择，与其他颜色区分开来
    vec3 col1 = vec3(0.90, 0.10, 0.15);   // vivid red / 鲜艳的红色
    vec3 col2 = vec3(0.00, 0.60, 0.30);   // emerald green / 翠绿色
    vec3 col3 = vec3(0.10, 0.35, 0.85);   // strong blue / 深蓝色
    vec3 col4 = vec3(1.00, 0.80, 0.10);   // bright yellow / 亮黄色
    vec3 col5 = vec3(0.60, 0.20, 0.80);   // purple / 紫色
    vec3 col6 = vec3(0.00, 0.75, 0.75);   // turquoise / 青绿色
    vec3 col7 = vec3(1.00, 0.50, 0.00);   // orange / 橙色
    vec3 col8 = vec3(0.40, 0.80, 0.10);   // lime green / 酸橙绿
    vec3 col9 = vec3(0.00, 0.50, 1.00);   // cyan blue / 青色蓝
    vec3 colA = vec3(1.00, 0.20, 0.60);   // magenta / 洋红色
    vec3 colB = vec3(0.60, 0.40, 0.10);   // ochre / 赭石色
    vec3 colC = vec3(0.20, 0.80, 0.60);   // mint / 薄荷色

    // ============================================================================
    // TILING COLORING - 平铺着色
    // ============================================================================
    // Apply different colors to different transformed copies of the fundamental domain
    // 为基本域的不同变换副本应用不同颜色
    // Each line applies a symmetry transformation and colors the result
    // 每一行应用一个对称变换并为结果着色
    // The pattern creates a complete tiling with 12 distinct colors
    // 该模式创建具有12种不同颜色的完整平铺
    
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

    // ============================================================================
    // ALTERNATIVE COLORING METHOD (COMMENTED OUT) - 替代着色方法（已注释）
    // ============================================================================
    // More systematic approach using nested loops for coloring
    // 使用嵌套循环进行着色的更系统的方法
    // This method applies transformations in a more organized way
    // 这种方法以更有组织的方式应用变换
    // Coloring three generations suffices for complete coverage
    // 着色三代足以完全覆盖
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
    
    // ============================================================================
    // FINAL OUTPUT - 最终输出
    // ============================================================================
    // Apply the boundary shading to create the final image
    // 应用边界着色以创建最终图像
    fragColor.rgb *= shade;
}