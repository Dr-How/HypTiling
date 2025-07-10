// ============================================================================
// HYPERBOLIC GEOMETRY LIBRARY - 双曲几何库
// Common functions for hyperbolic tiling and transformations
// 双曲平铺和变换的通用函数库
// ============================================================================

const float PI = 3.14159265358979323846;

// Global variables for heptagon construction
// 七边形构造的全局变量
float angles[7];  // Interior angles in degrees - 内角度数
float edges[7];   // Edge lengths - 边长
vec2 P[7];        // Vertex positions - 顶点位置

// Forward declaration
// 前向声明
vec2 hypTranslate(vec2 z1, vec2 z);

// ============================================================================
// COMPLEX ARITHMETIC - 复数运算
// ============================================================================

// Multiply two complex numbers: (a+bi) * (c+di) = (ac-bd) + (ad+bc)i
// 复数乘法：(a+bi) * (c+di) = (ac-bd) + (ad+bc)i
vec2 complexMultiply(vec2 z1, vec2 z2) {
    return vec2(z1.x * z2.x - z1.y * z2.y, z1.x * z2.y + z1.y * z2.x);
}

// Complex conjugate: (a+bi)* = (a-bi)
// 复数共轭：(a+bi)* = (a-bi)
vec2 complexConjugate(vec2 z) {
    return vec2(z.x, -z.y);
}

// Complex division: (a+bi)/(c+di) = [(ac+bd)/(c²+d²)] + [(bc-ad)/(c²+d²)]i
// 复数除法：(a+bi)/(c+di) = [(ac+bd)/(c²+d²)] + [(bc-ad)/(c²+d²)]i
vec2 complexDivision(vec2 z1, vec2 z2) {
    float denominator = z2.x * z2.x + z2.y * z2.y;
    return vec2(
        (z1.x * z2.x + z1.y * z2.y) / denominator,
        (z1.y * z2.x - z1.x * z2.y) / denominator
    );
}

// ============================================================================
// HYPERBOLIC GEOMETRY TOOLKIT - 双曲几何工具包
// Using the Poincaré disk model where the unit disk represents hyperbolic space
// 使用庞加莱圆盘模型，其中单位圆盘表示双曲空间
// ============================================================================

// Calculate hyperbolic distance between two points in the Poincaré disk model
// Distance formula: d(z1,z2) = 2*log((|z1-z2| + sqrt(|z1|²|z2|² - 2<z1,z2> + 1))/sqrt((1-|z1|²)(1-|z2|²)))
// 计算庞加莱圆盘模型中两点之间的双曲距离
// 距离公式：d(z1,z2) = 2*log((|z1-z2| + sqrt(|z1|²|z2|² - 2<z1,z2> + 1))/sqrt((1-|z1|²)(1-|z2|²)))
float hypDist(vec2 z1, vec2 z2) {
    float len1 = length(z1);
    float len2 = length(z2);
    float numerator = length(z1 - z2) + sqrt(len1 * len1 * len2 * len2 - 2.0 * dot(z1, z2) + 1.0);
    float denominator = sqrt((1.0 - len1 * len1) * (1.0 - len2 * len2));
    return 2.0 * log(numerator / denominator);
}

// Calculate hyperbolic distance from a point z to the geodesic line between z1 and z2
// Uses the formula for distance to a geodesic in the Poincaré disk model
// 计算点z到z1和z2之间测地线的双曲距离
// 使用庞加莱圆盘模型中点到测地线距离的公式
float hypDist(vec2 z1, vec2 z2, vec2 z) {
    // Transform z1 to origin and z2 to a point on positive real axis
    // 将z1变换到原点，z2变换到正实轴上的点
    vec2 w2 = hypTranslate(z1, z2);
    vec2 w = hypTranslate(z1, z);
    w = complexMultiply(normalize(complexConjugate(w2)), w);
    
    // Calculate distance using hyperbolic sine formula
    // 使用双曲正弦公式计算距离
    float x = (exp(length(w)) - exp(-length(w))) / 2.0;
    x *= w.y / length(w);
    return log(x + sqrt(1.0 + x * x));
}

// Determine if a point is inside or outside a hyperbolic geodesic (circular arc)
// Returns 1 outside the geodesic circle, 0 inside (with smooth transition)
// 判断点是否在双曲测地线（圆弧）内部或外部
// 测地线圆外返回1，圆内返回0（带平滑过渡）
float hypGeodesic(vec2 uv, vec2 z1, vec2 z2) {
    return smoothstep(0.0, 0.01, hypDist(z1, z2, uv));
}

// Find the hyperbolic midpoint between two points in the Poincaré disk model
// The midpoint is the point that is equidistant from both z1 and z2
// 在庞加莱圆盘模型中找到两点之间的双曲中点
// 中点是到z1和z2距离相等的点
vec2 hypMid(vec2 z1, vec2 z2) {
    // Transform z1 to origin
    // 将z1变换到原点
    vec2 w = hypTranslate(z1, z2);
    float r = length(w);
    float t = atan(w.y, w.x);
    
    // Calculate midpoint in transformed coordinates
    // 在变换后的坐标中计算中点
    float s = r / (1.0 + sqrt(1.0 - r * r));
    vec2 ww = s * vec2(cos(t), sin(t));
    
    // Transform back to original coordinates
    // 变换回原始坐标
    return hypTranslate(-z1, ww);
}

// ============================================================================
// GEOMETRIC TRANSFORMATIONS - 几何变换
// All transformations preserve hyperbolic distances and angles
// 所有变换都保持双曲距离和角度
// ============================================================================

// Inversion in a circle with given center and radius
// 在给定中心和半径的圆中进行反演
vec2 hypReflect(vec2 center, float radius, vec2 z) {
    vec2 q = z - center;
    q = normalize(q) * (radius * radius / length(q));
    return q + center;
}

// Reflect a point across the geodesic line between two points z1 and z2
// This finds the circle representing the geodesic and performs inversion
// 关于两点z1和z2之间的测地线反射一个点
// 找到表示测地线的圆并进行反演
vec2 hypReflect(vec2 z1, vec2 z2, vec2 z) {
    // Calculate the center and radius of the geodesic circle
    // 计算测地线圆的中心和半径
    float len1 = length(z1);
    float len2 = length(z2);
    float denominator = z1.x * z2.y - z2.x * z1.y;
    
    float dd = (z1.y * (1.0 + len2 * len2) - z2.y * (1.0 + len1 * len1)) / denominator;
    float ee = (z2.x * (1.0 + len1 * len1) - z1.x * (1.0 + len2 * len2)) / denominator;
    
    vec2 center = -vec2(dd, ee) / 2.0;
    float radius = sqrt(length(center) * length(center) - 1.0);
    
    return hypReflect(center, radius, z);
}

// Hyperbolic translation that sends z1 to 0
// 把z1映射到0的双曲平移
vec2 hypTranslate(vec2 z1, vec2 z) {
    return complexDivision(z - z1, vec2(1.0, 0.0) - complexMultiply(complexConjugate(z1), z));
}

// Rotate around origin by angle theta
// 以原点为中心旋转theta角度
vec2 hypRotate(float theta, vec2 z) {
    mat2 rot = mat2(cos(theta), sin(theta), -sin(theta), cos(theta));
    return rot * z;
}

// Rotate a point around z1 by angle theta
// This is done by translating z1 to origin, rotating, then translating back
// 以z1为中心旋转theta角度
// 通过将z1平移到原点，旋转，然后平移回来实现
vec2 hypRotate(vec2 z1, float theta, vec2 z) {
    vec2 w = hypTranslate(z1, z);
    w = hypRotate(theta, w);
    w = hypTranslate(-z1, w);
    return w;
}

// Hyperbolic rotation by 120 degrees around z1
// 以z1为中心旋转120度
vec2 hypRotate3(vec2 z1, vec2 z) {
    return hypRotate(z1, 2.0 * PI / 3.0, z);
}

// Hyperbolic rotation by 180 degrees around z1
// 以z1为中心旋转180度
vec2 hypRotate2(vec2 z1, vec2 z) {
    return hypRotate(z1, PI, z);
}

// Hyperbolic translation that sends z1 to z2 and z3 to z4
// 把z1映射到z2，z3映射到z4的双曲平移
vec2 hypTranslate(vec2 z1, vec2 z2, vec2 z3, vec2 z4, vec2 z) {
    // Find the transformation that maps z1 to z2
    // 找到将z1映射到z2的变换
    vec2 w2 = hypTranslate(z1, z2);
    
    // Find the transformation that maps z3 to z4
    // 找到将z3映射到z4的变换
    vec2 w4 = hypTranslate(z3, z4);
    
    // Calculate the ratio and angle
    // 计算比值和角度
    vec2 rho = complexDivision(w4, w2);
    float angle = atan(rho.y, rho.x);
    
    // Apply the composite transformation
    // 应用复合变换
    vec2 w = hypTranslate(z1, z);
    w = hypRotate(angle, w);
    w = hypTranslate(-z3, w);
    
    return w;
}

// Hyperbolic reflection in the bisector between z1 and z2
// 关于z1和z2之间的垂直平分线做双曲反射
vec2 hypBisectReflect(vec2 z1, vec2 z2, vec2 z) {
    // Find the midpoint
    // 找到中点
    vec2 m = hypMid(z1, z2);
    
    // Rotate z1 and z2 by 90 degrees around the midpoint to find the geodesic
    // 围绕中点将z1和z2旋转90度以找到测地线
    vec2 w1 = hypRotate(m, PI / 2.0, z1);
    vec2 w2 = hypRotate(m, PI / 2.0, z2);
    
    // Reflect across this geodesic
    // 关于这条测地线反射
    return hypReflect(w1, w2, z);
}

// Fixed points (on the ideal boundary) of the translation that sends a to c and b to d
// 对将a映射到c，b映射到d的双曲平移，计算其不动点（在理想边界上）
vec4 fixedPoints(vec2 a, vec2 b, vec2 c, vec2 d) {
    // Transform a to origin and b to a point on real axis
    // 将a变换到原点，b变换到实轴上的点
    vec2 s = hypTranslate(a, b);
    
    // Transform c to origin and d to a point on real axis
    // 将c变换到原点，d变换到实轴上的点
    vec2 t = hypTranslate(c, d);
    
    // Calculate the ratio of these transformations
    // 计算这些变换的比值
    vec2 r = complexDivision(t, s);
    
    // Solve quadratic equation for fixed points
    // 求解不动点的二次方程
    vec2 alpha = r - complexMultiply(c, complexConjugate(a));
    vec2 beta = -complexMultiply(r, a) + c;
    vec2 gamma = -complexConjugate(a) + complexMultiply(r, complexConjugate(c));
    vec2 delta = vec2(1.0, 0.0) - complexMultiply(r, complexMultiply(a, complexConjugate(c)));
    
    // Calculate discriminant
    // 计算判别式
    vec2 Ddelta = complexMultiply(delta - alpha, delta - alpha) + 4.0 * complexMultiply(gamma, beta);
    float rho = sqrt(length(Ddelta));
    float theta = atan(Ddelta.y, Ddelta.x) / 2.0;
    
    // Two fixed points
    // 两个不动点
    vec2 z1 = (-(delta - alpha) + vec2(rho * cos(theta), rho * sin(theta))) / 2.0;
    z1 = complexDivision(z1, gamma);
    
    vec2 z2 = (-(delta - alpha) - vec2(rho * cos(theta), rho * sin(theta))) / 2.0;
    z2 = complexDivision(z2, gamma);
    
    return vec4(z2, z1);
}

// Fold points onto the fundamental domain between geodesics ab and cd
// This is used for creating periodic tilings and reducing computational complexity
// 对将a映射到c，b映射到d的双曲平移，将任意点折叠到ab和cd之间的区域
// 这用于创建周期性平铺和减少计算复杂度
vec3 fold(vec2 uv, vec2 a, vec2 b, vec2 c, vec2 d) {
    // Find fixed points of the transformation
    // 找到变换的不动点
    vec4 fixPts = fixedPoints(a, b, c, d);
    vec2 fix1 = fixPts.xy;
    vec2 fix2 = fixPts.zw;
    
    // Transform to upper half-plane model
    // 变换到上半平面模型
    vec2 aH = hypReflect(fix2, length(fix2 - fix1), a);
    vec2 bH = hypReflect(fix2, length(fix2 - fix1), b);
    vec2 cH = hypReflect(fix2, length(fix2 - fix1), c);
    vec2 uvH = hypReflect(fix2, length(fix2 - fix1), uv);
    
    // Rotate to align with vertical axis
    // 旋转以与垂直轴对齐
    float theta = PI / 2.0 - atan(fix2.y, fix2.x);
    mat2 rot = mat2(cos(theta), sin(theta), -sin(theta), cos(theta));
    
    aH = rot * (aH - fix1);
    bH = rot * (bH - fix1);
    cH = rot * (cH - fix1);
    uvH = rot * (uvH - fix1);
    
    // Calculate folding parameters based on angle
    // 根据角度计算折叠参数
    float angle = atan(uvH.y, uvH.x);
    float center = (length(aH) * length(aH) - length(bH) * length(bH)) / (aH - bH).x / 2.0;
    float radius = length(aH - vec2(center, 0.0));
    float rz = cos(angle) * center + sqrt(radius * radius - center * center * sin(angle) * sin(angle));
    
    // In upper half-plane, hyperbolic translation appears as scaling
    // 在上半平面中，双曲平移表现为缩放
    float lnra = log(length(aH));
    float lnrc = log(length(cH));
    float lnuv = log(length(uvH));
    float d1 = lnrc - lnra;
    float d2 = lnuv - lnra;
    float shift = log(rz) - lnra;
    float w = lnra + fract((d2 - shift) / d1) * d1 + shift;
    
    // Transform back to disk model
    // 变换回圆盘模型
    uvH = mat2(cos(-theta), sin(-theta), -sin(-theta), cos(-theta)) * uvH + fix1;
    uvH = normalize(uvH - fix1) * exp(w) + fix1;
    vec2 uvD = hypReflect(fix2, length(fix2 - fix1), uvH);
    
    // Return folded point and folding parameter
    // 返回折叠后的点和折叠参数
    return vec3(uvD, fract((d2 - shift) / d1));
}

// ============================================================================
// HEPTAGON CONSTRUCTION - 七边形构造
// ============================================================================

// Rotate all points so that P[i] is at the origin, then rotate all points by a specific angle so that P[i-1] aligns with the desired direction.
// If i==0, do nothing. This function is used in the construction of the heptagon.
// Cautious: this function is only to be called in the coordinates() function that follows.
// 先将所有点平移，使P[i]位于原点，然后将所有点旋转特定角度，使P[i-1]对齐到目标方向。
// 如果i==0，则不做任何操作。本函数用于七边形的构造。
// 注意：本函数只能在coordinates()函数中调用。
void collectiveRotate(int i) {
    if (i == 0) return;
    // First, translate all points so that P[i] is at the origin
    // 首先，将所有点平移，使P[i]位于原点
    vec2 Q = P[i];
    for (int j = 0; j <= i; j++) {
        P[j] = hypTranslate(Q, P[j]);
    }
    
    // Compute the angle to rotate so that the previous point aligns with the desired angle
    // 计算旋转角度，使前一个点与目标角度对齐
    vec2 w = normalize(P[i - 1]);
    float theta = atan(w.y, w.x);
    theta = angles[i] * PI / 180.0 - theta;
    
    // Rotate all points around the origin by theta
    // 围绕原点将所有点旋转theta角度
    for (int j = 0; j <= i; j++) {
        P[j] = hypRotate(theta, P[j]);
    }
}

bool coordComputed;
// Set up the coordinates of the points based on edge lengths and angles
// 根据边长和角度设置各点的坐标
// Usage:
// First write an init() function
// set the angles and edges and also set the initial positions of the points to 0.
// Then call coordinates() to update the positions of the points.
// 使用方法：
// 首先编写一个init()函数
// 设置角度和边长，并将各点的初始位置设置为0。
// 然后调用coordinates()来更新各点的位置。
void coordinates() {
    if (coordComputed) return;
    // For each edge, set the next point along the x-axis and rotate
    // 对每条边，将下一个点放在x轴上并旋转
    P[0] = vec2(0.0, 0.0);

    for (int i = 1; i < 7; i++) {
        // Place the next point at the correct distance along the x-axis
        // 将下一个点放在x轴上正确的距离处
        float x = edges[i-1] / 2.0;
        P[i] = vec2((exp(x) - exp(-x)) / (exp(x) + exp(-x)), 0.0);
        // Translate the next point to the origin and rotate the previous point to the given angle
        // 将下一个点平移到原点，并将前一个点旋转到给定角度
        collectiveRotate(i);
    }
    
    // Compute the centroid of all points
    // 计算所有点的中心点
    vec2 center = (P[0] + P[1] + P[2] + P[3] + P[4] + P[5] + P[6]) / 7.0;
    
    // Translate all points so that the centroid is at the origin
    // 平移所有点，使中心点位于原点
    for (int i = 0; i < 7; i++) {
        P[i] = hypTranslate(center, P[i]);
    }

    coordComputed = true;
}