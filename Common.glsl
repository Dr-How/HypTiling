const float PI = 3.14159265358979323846;
vec2 hypTranslate(vec2 z1, vec2 z);

//Complex arithmetics
//复数运算
vec2 complexMultiply(vec2 z1, vec2 z2) {
    return vec2(z1.x * z2.x - z1.y * z2.y, z1.x * z2.y + z1.y * z2.x);
}

vec2 complexConjugate(vec2 z) {
    return vec2(z.x, -z.y);
}

vec2 complexDivision(vec2 z1, vec2 z2){
    return vec2((z1.x*z2.x+z1.y*z2.y)/(z2.x*z2.x+z2.y*z2.y),(z1.y*z2.x-z1.x*z2.y)/(z2.x*z2.x+z2.y*z2.y));
}

// Toolkits for hyperbolic geometry in the Poincare disk model
// 双曲几何工具包，使用Poincare圆盘模型

// Hyperbolic distance between two points in the Poincare disk model
// Poincare圆盘模型中两点之间的双曲距离
float hypDist(vec2 z1, vec2 z2){
    return 2.*log(
            (length(z1-z2)+sqrt(length(z1)*length(z1) * length(z2)*length(z2) - 2. * dot(z1,z2) + 1.))
            /sqrt((1.-length(z1) * length(z1))*(1.-length(z2)*length(z2)))
        );
}

//Hyperbolic distance between a point z and the geodesic between z1 and z2
//计算点z到z1和z2之间测地线的双曲距离
float hypDist(vec2 z1, vec2 z2, vec2 z) {
    vec2 w2 = hypTranslate(z1, z2);
    vec2 w = hypTranslate(z1, z);
    w = complexMultiply(normalize(complexConjugate(w2)), w);
    float x = (exp(length(w)) - exp(-length(w))) / 2.;
    x *= w.y/length(w);
    return log(x + sqrt(1. + x * x));
}

//Hyperbolic geodesic as a circle, return 1 outside the circle, 0 inside
//计算双曲测地线（一个圆弧），圆外返回1，圆内返回0
float hypGeodesic(vec2 uv, vec2 z1, vec2 z2) {
    return smoothstep(0.0, .01, hypDist(z1, z2, uv));
}

// Hyperbolic midpoint between two points in the Poincare disk model
// Poincare圆盘模型中两点之间的双曲中点
vec2 hypMid(vec2 z1, vec2 z2){
    vec2 w = hypTranslate(z1, z2);
    float r = length(w);
    float t = atan(w.y, w.x);
    float s = r / (1. + sqrt(1. - r * r));
    vec2 ww = s * vec2(cos(t), sin(t));
    return hypTranslate(-z1, ww);
}

// Geometric transformations in the Poincare disk model
// Poincare圆盘模型中的几何变换

// Inversion in a circle with given center and radius
// 在给定中心和半径的圆中进行反演
vec2 hypReflect(vec2 center, float radius, vec2 z) {
    vec2 q = z - center;
    q = normalize(q) * (radius * radius / length(q));
    return q + center;
}

// Reflection in a geodesic between two points z1 and z2
// 关于两点z1和z2之间的测地线上进行反射
vec2 hypReflect(vec2 z1, vec2 z2, vec2 z) {
    float dd = (z1.y * (1. + length(z2) * length(z2)) - z2.y * (1. + length(z1) * length(z1))) / (z1.x * z2.y - z2.x * z1.y);
    float ee = (z2.x * (1. + length(z1) * length(z1)) - z1.x * (1. + length(z2) * length(z2))) / (z1.x * z2.y - z2.x * z1.y);
    vec2 center = -vec2(dd, ee)/2.;
    float radius = sqrt(length(center)*length(center)-1.);
    return hypReflect(center, radius, z);
}

// Hyperbolic translation that sends z1 to 0
// 把z1映射到0的双曲平移
vec2 hypTranslate(vec2 z1, vec2 z) {
    return complexDivision(z - z1, (vec2(1.0,0.0) - complexMultiply(complexConjugate(z1),z)));
}

// Rotate around 0 by angle theta
// 以0为中心旋转theta角度
vec2 hypRotate(float theta, vec2 z) {
    mat2 rot = mat2(cos(theta), sin(theta), -sin(theta), cos(theta));
    return rot * z;
}

// Rotate around z1 by angle theta
// 以z1为中心旋转theta角度
vec2 hypRotate(vec2 z1, float theta, vec2 z){
    vec2 w = hypTranslate(z1, z);
    w = hypRotate(theta, w);
    w = hypTranslate(-z1, w);
    return w;
}

// Hyperbolic rotation by 120 degrees around z1
// 以z1为中心旋转120度
vec2 hypRotate3(vec2 z1, vec2 z) {
    return hypRotate(z1, 2.*PI/3., z);
}

// Hyperbolic rotation by 180 degrees around z1
// 以z1为中心旋转180度
vec2 hypRotate2(vec2 z1, vec2 z) {
    return hypRotate(z1, PI, z);
}

// Hyperbolic translation that sends z1 to z2 and z3 to z4
// 把z1映射到z2，z3映射到z4的双曲平移
vec2 hypTranslate(vec2 z1, vec2 z2, vec2 z3, vec2 z4, vec2 z){
    vec2 w2= hypTranslate(z1, z2);
    vec2 w4= hypTranslate(z3, z4);
    vec2 rho = complexDivision(w4, w2);
    float angle = atan(rho.y, rho.x);
    vec2 w = hypTranslate(z1, z);
    w = hypRotate(angle, w);
    w = hypTranslate(-z3, w);
    return w;
}

// Hyperbolic reflection in the bisector between z1 and z2
// 关于z1和z2之间的垂直平分线做双曲反射
vec2 hypBisectReflect(vec2 z1, vec2 z2, vec2 z) {
    vec2 m = hypMid(z1, z2);
    vec2 w1 = hypRotate(m, PI / 2., z1);
    vec2 w2 = hypRotate(m, PI / 2., z2);
    vec2 w = hypReflect(w1, w2, z);
    return w;
}

// Fixed points (on the ideal boundary) of the translation that sends a to c and b to d
// 对将a映射到c，b映射到d的双曲平移，计算其不动点（在理想边界上）
vec4 fixedPoints(vec2 a, vec2 b, vec2 c, vec2 d) {
    vec2 s = hypTranslate(a, b);
    vec2 t = hypTranslate(c, d);
    vec2 r = complexDivision(t, s);
    vec2 alpha = r - complexMultiply(c, complexConjugate(a));
    vec2 beta = - complexMultiply(r, a) + c;
    vec2 gamma = - complexConjugate(a) + complexMultiply(r, complexConjugate(c));
    vec2 delta = vec2(1.,0.) - complexMultiply(r, complexMultiply(a, complexConjugate(c)));
    vec2 Ddelta = complexMultiply(delta - alpha, delta - alpha) + 4. *complexMultiply(gamma, beta);
    float rho = sqrt(length(Ddelta));
    float theta = atan(Ddelta.y, Ddelta.x)/2.;
    vec2 z1 = (-(delta - alpha) + vec2(rho * cos(theta), rho * sin(theta))) / 2.0;
    z1 = complexDivision(z1, gamma);
    vec2 z2 = (-(delta - alpha) - vec2(rho * cos(theta), rho * sin(theta))) / 2.0;
    z2 = complexDivision(z2, gamma);
    return vec4(z2, z1);
}

// For the translation that sends a to c and b to d, fold the points onto the belt between ab and cd.
// 对将a映射到c，b映射到d的双曲平移，将任意点折叠到ab和cd之间的区域
vec3 fold(vec2 uv, vec2 a, vec2 b, vec2 c, vec2 d) {
    vec4 fixPts = fixedPoints(a, b, c, d);
    vec2 fix1 = fixPts.xy;
    vec2 fix2 = fixPts.zw;
    //to halfplane
    vec2 aH = hypReflect(fix2, length(fix2 - fix1), a);
    vec2 bH = hypReflect(fix2, length(fix2 - fix1), b);
    vec2 cH = hypReflect(fix2, length(fix2 - fix1), c);
    vec2 uvH = hypReflect(fix2, length(fix2 - fix1), uv);
    //to upper halfplane
    float theta = PI/2. - atan(fix2.y, fix2.x);
    mat2 rot = mat2(cos(theta), sin(theta), -sin(theta), cos(theta));
    aH  = rot * (aH - fix1);
    bH  = rot * (bH - fix1);
    cH  = rot * (cH - fix1);
    uvH = rot * (uvH - fix1);
    //amount of shift depending on angle
    float angle = atan(uvH.y, uvH.x);
    float center = (length(aH)*length(aH) - length(bH)*length(bH)) / (aH-bH).x / 2.;
    float radius = length(aH - vec2(center,0.));
    float rz = cos(angle) * center + sqrt(radius * radius - center * center * sin(angle) * sin(angle));
    float lnrz = log(rz);

    // In the upper halfplane, translation appears as scaling
    float lnra = log(length(aH));
    float lnrc = log(length(cH));
    float lnuv = log(length(uvH));
    float d1=lnrc-lnra;
    float d2=lnuv-lnra;
    float shift = lnrz-lnra;
    float w = lnra + fract((d2 - shift)/d1)*d1 + shift;

    // New points after folding
    uvH = mat2(cos(-theta), sin(-theta), -sin(-theta), cos(-theta)) * uvH + fix1;
    uvH = normalize(uvH - fix1) * exp(w) + fix1;
    vec2 uvD = hypReflect(fix2, length(fix2 - fix1), uvH);
    return vec3(uvD, fract((d2 - shift)/d1));
}