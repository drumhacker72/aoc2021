import std.algorithm;
import std.stdio;
import std.string;
import std.typecons;

char[][] rows;

char* right(ulong x, ulong y) {
    return x == rows[y].length - 1 ? &rows[y][0] : &rows[y][x+1];
}

char* down(ulong x, ulong y) {
    return y == rows.length - 1 ? &rows[0][x] : &rows[y+1][x];
}

alias Point = Tuple!(ulong, "x", ulong, "y");

void step() {
    Point[] moving;
    foreach (y; 0..rows.length) {
        foreach (x; 0..rows[y].length) {
            if (rows[y][x] == '>' && *right(x, y) == '.') moving ~= Point(x, y);
        }
    }
    foreach (p; moving) {
        rows[p.y][p.x] = '.';
        *right(p.x, p.y) = '>';
    }

    moving = [];
    foreach (y; 0..rows.length) {
        foreach (x; 0..rows[y].length) {
            if (rows[y][x] == 'v' && *down(x, y) == '.') moving ~= Point(x, y);
        }
    }
    foreach (p; moving) {
        rows[p.y][p.x] = '.';
        *down(p.x, p.y) = 'v';
    }
}

void main() {
    auto f = File("day25.txt", "r");
    string line;
    while ((line = f.readln()) !is null) {
        rows ~= line.stripRight.dup;
    }
    char[] last;
    int steps = 0;
    do {
        last = rows.join;
        step();
        ++steps;
    } while (last != rows.join);
    writeln(steps);
}
