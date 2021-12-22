import std.algorithm;
import std.container;
import std.stdio;
import std.string;
import std.typecons;

alias Point = Tuple!(int, "x", int, "y");

struct Image {
    RedBlackTree!Point pixels;
    int xMin;
    int xMax;
    int yMin;
    int yMax;
    bool default_;

    bool opIndex(int x, int y) const {
        if (x < xMin || x > xMax || y < yMin || y > yMax) return default_;
        Point p;
        p.x = x;
        p.y = y;
        return !pixels.equalRange(p).empty;
    }

    void addPixel(int x, int y) {
        Point p;
        p.x = x;
        p.y = y;
        pixels.insert(p);
        xMin = min(xMin, x);
        xMax = max(xMax, x);
        yMin = min(yMin, y);
        yMax = max(yMax, y);
    }
}

int findIndex(const ref Image img, int x, int y) {
    return (img[x-1, y-1] ? 256 : 0) +
        (img[x, y-1] ? 128 : 0) +
        (img[x+1, y-1] ? 64 : 0) +
        (img[x-1, y] ? 32 : 0) +
        (img[x, y] ? 16 : 0) +
        (img[x+1, y] ? 8 : 0) +
        (img[x-1, y+1] ? 4 : 0) +
        (img[x, y+1] ? 2 : 0) +
        (img[x+1, y+1] ? 1 : 0);
}

Image step(string algo, const ref Image img) {
    Image s;
    s.pixels = new RedBlackTree!Point();
    if (algo[0] == '#') s.default_ = !img.default_;
    for (int x = img.xMin - 1; x <= img.xMax + 1; ++x) {
        for (int y = img.yMin - 1; y <= img.yMax + 1; ++y) {
            if (algo[findIndex(img, x, y)] == '#') {
                s.addPixel(x, y);
            }
        }
    }
    return s;
}

void main() {
    auto f = File("day20.txt", "r");
    string algo = f.readln().stripRight();
    f.readln();
    Image img;
    img.pixels = new RedBlackTree!Point();
    string row;
    int y = 0;
    while ((row = f.readln()) !is null) {
        row = row.stripRight();
        for (int x = 0; x < row.length; ++x) {
            if (row[x] == '#') img.addPixel(x, y);
        }
        ++y;
    }
    for (int i = 0; i < 2; ++i)
        img = step(algo, img);
    writeln(img.pixels.length);
    for (int i = 2; i < 50; ++i)
        img = step(algo, img);
    writeln(img.pixels.length);
}
