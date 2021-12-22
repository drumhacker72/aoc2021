import std.file;
import std.stdio;
import std.typecons;

void main() {
    auto steps = slurp!(string, int, int, int, int, int, int)("day22.txt", "%s x=%d..%d,y=%d..%d,z=%d..%d");
    bool[101][101][101] cubes;
    foreach (step; steps) {
        bool on = step[0] == "on";
        for (int x = step[1]; x <= step[2]; ++x) {
            if (x < -50 || x > 50) continue;
            for (int y = step[3]; y <= step[4]; ++y) {
                if (y < -50 || y > 50) continue;
                for (int z = step[5]; z <= step[6]; ++z) {
                    if (z < -50 || z > 50) continue;
                    cubes[x+50][y+50][z+50] = on;
                }
            }
        }
    }
    int total;
    for (int x = -50; x <= 50; ++x) {
        for (int y = -50; y <= 50; ++y) {
            for (int z = -50; z <= 50; ++z) {
                if (cubes[x+50][y+50][z+50]) ++total;
            }
        }
    }
    writeln(total);
}
