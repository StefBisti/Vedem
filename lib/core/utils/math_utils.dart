double lerp(double a, double b, double t) => (1 - t) * a + t * b;
double invLerp(double a, double b, double value) => (value - a) / (b - a);
