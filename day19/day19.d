import std.algorithm;
import std.array;
import std.container;
import std.format.read;
import std.math;
import std.stdio;
import std.typecons;

struct Vec3i {
    int x, y, z;
    Vec3i opBinary(string op)(Vec3i o) const {
        return mixin("Vec3i(x"~op~"o.x, y"~op~"o.y, z"~op~"o.z)");
    }
    bool opEquals(Vec3i o) const {
        return x == o.x && y == o.y && z == o.z;
    }
    int opCmp(Vec3i o) const {
        if (x == o.x) {
            if (y == o.y) {
                return z - o.z;
            } else {
                return y - o.y;
            }
        } else {
            return x - o.x;
        }
    }
    int manhattan() const {
        return abs(x) + abs(y) + abs(z);
    }
}

struct Scanner {
    int id;
    Vec3i[] beacons;
    bool located;
    Vec3i position;
    int orientation;
}

Nullable!Vec3i readVec3i(File f) {
    string line = f.readln();
    if (line is null || line == "\n") return Nullable!Vec3i.init;
    Vec3i p;
    line.formattedRead!"%d,%d,%d\n"(p.x, p.y, p.z);
    return p.nullable;
}

Scanner readScanner(File f) {
    Scanner scanner;
    f.readf!"--- scanner %d ---\n"(scanner.id);
    Nullable!Vec3i beacon;
    while (!(beacon = readVec3i(f)).isNull) {
        scanner.beacons ~= beacon.get;
    }
    return scanner;
}

Vec3i xRot(Vec3i p) {
    return Vec3i(p.x, -p.z, p.y);
}
Vec3i yRot(Vec3i p) {
    return Vec3i(p.z, p.y, -p.x);
}
Vec3i zRot(Vec3i p) {
    return Vec3i(-p.y, p.x, p.z);
}

enum Basis { XP, XN, YP, YN, ZP, ZN }
Vec3i rebase(Vec3i p, Basis b) {
    final switch (b) {
        case Basis.XP: return p;
        case Basis.XN: return p.yRot.yRot;
        case Basis.YP: return p.zRot;
        case Basis.YN: return p.zRot.zRot.zRot;
        case Basis.ZP: return p.yRot;
        case Basis.ZN: return p.yRot.yRot.yRot;
    }
}
Vec3i rotate(Vec3i p, Basis b) {
    final switch (b) {
        case Basis.XP: return p.xRot;
        case Basis.XN: return p.xRot.xRot.xRot;
        case Basis.YP: return p.yRot;
        case Basis.YN: return p.yRot.yRot.yRot;
        case Basis.ZP: return p.zRot;
        case Basis.ZN: return p.zRot.zRot.zRot;
    }
}
Vec3i orient(Vec3i p, int orientation) {
    auto b = cast(Basis) (orientation % 6);
    p = p.rebase(b);
    foreach (i; 0..orientation / 6)
        p = p.rotate(b);
    return p;
}

int countOverlaps(const ref Vec3i[] root, const ref Vec3i[] test, int rootIdx, int orientation) {
    auto oriented = test.map!(p => p.orient(orientation));
    auto shifted = oriented.map!(p => p + root[rootIdx] - oriented[0]).array;
    shifted.sort;
    return cast(int) setIntersection(root, shifted).array.length;
}

bool tryLocate(const ref Scanner root, ref Scanner test) {
    assert(root.located);
    assert(!test.located);
    auto r = root.beacons.map!(p => p.orient(root.orientation) + root.position).array;
    r.sort;
    auto bs = test.beacons.dup;
    while (bs.length >= 12) {
        for (int rootIdx = 0; rootIdx < r.length; ++rootIdx) {
            for (int orientation = 0; orientation < 24; ++orientation) {
                int x = countOverlaps(r, bs, rootIdx, orientation);
                if (x >= 12) {
                    test.position = r[rootIdx] - bs[0].orient(orientation);
                    test.orientation = orientation;
                    test.located = true;
                    return true;
                }
            }
        }
        bs = bs[1..$];
    }
    return false;
}

void locate1(ref Scanner[] scanners) {
    foreach (ref r; scanners) {
        if (!r.located) continue;
        foreach (ref t; scanners) {
            if (t.located) continue;
            if (tryLocate(r, t)) return;
        }
    }
}

void locateAll(ref Scanner[] scanners) {
    scanners[0].located = true;
    for (int i = 1; i < scanners.length; ++i)
        locate1(scanners);
}

int maxDistance(ref Scanner[] scanners) {
    int best = 0;
    foreach (ref a; scanners) {
        foreach (ref b; scanners) {
            best = max(best, (a.position - b.position).manhattan);
        }
    }
    return best;
}

void main() {
    auto f = File("day19.txt", "r");
    Scanner[] scanners;
    do {
        scanners ~= readScanner(f);
    } while (!f.eof);
    locateAll(scanners);
    auto beacons = new RedBlackTree!Vec3i();
    foreach (ref s; scanners) {
        beacons.insert(s.beacons.map!(p => p.orient(s.orientation) + s.position));
    }
    writeln(beacons.length);
    writeln(maxDistance(scanners));
}
