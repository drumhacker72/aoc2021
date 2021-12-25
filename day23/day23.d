import std.algorithm;
import std.array;
import std.container;
import std.format;
import std.range;
import std.stdio;
import std.sumtype;
import std.typecons;

struct Hallway {}
struct Room {
    char owner;
}

alias Descriptor = SumType!(Hallway, Room);

class Node {
    string id;
    Node[] outs;
    Descriptor info;

    override int opCmp(const Object o) const { return cmp(id, (cast(Node) o).id); }
    override bool opEquals(const Object o) const { return id == (cast(Node) o).id; }
    override string toString() const { return id; }
}

struct Burrow(int depth) {
    Node[11] hallway;
    Node[depth][4] rooms;
}

Burrow!depth createBurrow(int depth)() {
    Burrow!depth b;
    foreach (i; 0..11) {
        b.hallway[i] = new Node;
        b.hallway[i].id = "H%d".format(i);
        b.hallway[i].info = Hallway();
    }
    foreach (c; 0..4) {
        foreach (r; 0..depth) {
            b.rooms[c][r] = new Node;
            b.rooms[c][r].id = "R%c%d".format(cast(char)('A' + c), r);
            b.rooms[c][r].info = Room(cast(char)('A' + c));
        }
    }

    foreach (i; 0..11) {
        if (i != 0) b.hallway[i].outs ~= b.hallway[i-1];
        if (i != 10) b.hallway[i].outs ~= b.hallway[i+1];
        if ([2, 4, 6, 8].canFind(i)) b.hallway[i].outs ~= b.rooms[i/2 - 1][0];
    }

    foreach (c; 0..4) {
        foreach (r; 0..depth) {
            if (r != 0) b.rooms[c][r].outs ~= b.rooms[c][r-1];
            if (r != depth - 1) b.rooms[c][r].outs ~= b.rooms[c][r+1];
        }
        b.rooms[c][0].outs ~= b.hallway[c*2 + 2];
    }
    return b;
}

template b(int depth) {
    auto b = createBurrow!depth();
}

Node linkedRoom(Node node) {
    foreach (o; node.outs) {
        if (o.info.match!((Room r) => true, _ => false)) return o;
    }
    return null;
}

Tuple!(int, Node[depth*4]) pathfind(int depth)(Node[depth*4] pods, int i, Node t) {
    auto pq = heapify!"a > b"([Tuple!(int, Node[depth*4])(0, pods)]);
    auto seen = new RedBlackTree!Node;
    for (; !pq.empty; pq.removeFront()) {
        auto count = pq.front[0];
        auto npods = pq.front[1];
        if (npods[i] == t) return tuple(count, npods);
        if (!seen.equalRange(npods[i]).empty) continue;
        seen.insert(npods[i]);
        foreach (o; npods[i].outs) {
            if (!npods.array.canFind(o)) {
                npods[i] = o;
                pq.insert(tuple(count+1, npods));
            }
        }
    }
    return tuple(-1, pods);
}

bool badOccupants(int depth)(Node[depth*4] pods, char owner) {
    int c = owner - 'A';
    foreach (r; 0..depth) {
        if (pods.array.canFind(b!depth.rooms[c][r]) && pods.array.countUntil(b!depth.rooms[c][r]) / depth != c)
            return true;
    }
    return false;
}

Tuple!(int, Node[depth*4]) moveCount(int depth)(Node[depth*4] pods, int i, Node t) {
    auto c = cast(char)('A' + i / depth);
    if (pods.array.canFind(t)) return tuple(-1, pods);
    alias doMatch = match!(
        (Hallway _fh, Hallway _th) => tuple(-1, pods),
        (Hallway _fh, Room tr) =>
            (tr.owner == c && !badOccupants!depth(pods, c)) ? pathfind!depth(pods, i, t) : tuple(-1, pods),
        (Room fr, Hallway _th) =>
            ((fr.owner != c || badOccupants!depth(pods, fr.owner)) && t.linkedRoom is null) ? pathfind!depth(pods, i, t) : tuple(-1, pods),
        (Room fr, Room tr) => tuple(-1, pods)
    );
    return doMatch(pods[i].info, t.info);
}

int costPer(int depth)(int i) {
    final switch (i / depth) {
        case 0: return 1;
        case 1: return 10;
        case 2: return 100;
        case 3: return 1000;
    }
}

bool hasOwner(Node node, char c) {
    return node.info.match!(
        (Hallway _h) => false,
        (Room r) => r.owner == c
    );
}

bool isDone(int depth)(Node[depth*4] pods) {
    foreach (i; 0..depth*4) {
        if (!pods[i].hasOwner(cast(char)('A' + i / depth))) return false;
    }
    return true;
}

string makeKey(int depth : 2)(Node[8] pods) {
    auto k0 = [pods[0], pods[1]];
    auto k1 = [pods[2], pods[3]];
    auto k2 = [pods[4], pods[5]];
    auto k3 = [pods[6], pods[7]];
    sort(k0);
    sort(k1);
    sort(k2);
    sort(k3);
    return "%s%s%s%s".format(k0, k1, k2, k3);
}
string makeKey(int depth : 4)(Node[16] pods) {
    auto k0 = [pods[0], pods[1], pods[2], pods[3]];
    auto k1 = [pods[4], pods[5], pods[6], pods[7]];
    auto k2 = [pods[8], pods[9], pods[10], pods[11]];
    auto k3 = [pods[12], pods[13], pods[14], pods[15]];
    sort(k0);
    sort(k1);
    sort(k2);
    sort(k3);
    return "%s%s%s%s".format(k0, k1, k2, k3);
}

char fromInit(int depth : 2)(char[2][4] init, int c, int r) {
    return init[c][r];
}
char fromInit(int depth : 4)(char[2][4] init, int c, int r) {
    final switch (r) {
        case 0: return init[c][0];
        case 1: return "DCBA"[c];
        case 2: return "DBAC"[c];
        case 3: return init[c][1];
    }
}

void main() {
    auto f = File("day23.txt", "r");
    f.readln();
    f.readln();
    char[2][4] init;
    f.readf!"###%c#%c#%c#%c###\n"(init[0][0], init[1][0], init[2][0], init[3][0]);
    f.readf!"  #%c#%c#%c#%c#"(init[0][1], init[1][1], init[2][1], init[3][1]);

    static foreach (depth; [2, 4]) {{
        int[4] seen;
        Node[depth*4] amphipods;
        foreach (c; 0..4) {
            foreach (r; 0..depth) {
                auto a = fromInit!depth(init, c, r) - 'A';
                amphipods[a*depth + seen[a]] = b!depth.rooms[c][r];
                ++seen[a];
            }
        }

        auto pq = heapify!"a > b"([Tuple!(int, Node[depth*4])(0, amphipods)]);
        auto seen2 = new RedBlackTree!string;
        for (; !pq.empty; pq.removeFront()) {
            auto energy = pq.front[0];
            auto pods = pq.front[1];
            auto k = makeKey!depth(pods);
            if (!seen2.equalRange(k).empty) continue;
            seen2.insert(k);
            if (isDone!depth(pods)) {
                writeln(energy);
                break;
            }
            for (int i = 0; i < depth*4; ++i) {
                foreach (t; chain(b!depth.hallway.array, b!depth.rooms[0].array, b!depth.rooms[1].array, b!depth.rooms[2].array, b!depth.rooms[3].array)) {
                    auto r = moveCount!depth(pods, i, t);
                    auto count = r[0];
                    auto npods = r[1];
                    if (count < 0) continue;
                    pq.insert(tuple(energy + costPer!depth(i) * count, npods));
                }
            }
        }
    }}
}
