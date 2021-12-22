import std.algorithm;
import std.container;
import std.file;
import std.range;
import std.stdio;
import std.typecons;

void main() {
    auto steps = slurp!(string, int, int, int, int, int, int)("day22.txt", "%s x=%d..%d,y=%d..%d,z=%d..%d");
    auto xss = new RedBlackTree!int();
    auto yss = new RedBlackTree!int();
    auto zss = new RedBlackTree!int();
    foreach (step; steps) {
        xss.insert([step[1], step[2] + 1]);
        yss.insert([step[3], step[4] + 1]);
        zss.insert([step[5], step[6] + 1]);
    }
    int[] xs = xss.array;
    int[] ys = yss.array;
    int[] zs = zss.array;
    bool[] buf = new bool[(xs.length - 1) * (ys.length - 1) * (zs.length - 1)];
    auto regions = buf.chunks((ys.length - 1) * (zs.length - 1))
        .map!(x => x.chunks(zs.length - 1));
    foreach (step; steps) {
        auto on = step[0] == "on";
        foreach (i, x; xs) {
            if (x < step[1] || x > step[2]) continue;
            foreach (j, y; ys) {
                if (y < step[3] || y > step[4]) continue;
                foreach (k, z; zs) {
                    if (z < step[5] || z > step[6]) continue;
                    regions[i][j][k] = on;
                }
            }
        }
    }
    long total;
    for (int i = 0; i < xs.length - 1; ++i) {
        for (int j = 0; j < ys.length - 1; ++j) {
            for (int k = 0; k < zs.length - 1; ++k) {
                if (regions[i][j][k]) {
                    total += cast(long)(xs[i+1]-xs[i]) * cast(long)(ys[j+1]-ys[j]) * cast(long)(zs[k+1]-zs[k]);
                }
            }
        }
    }
    writeln(total);
}
