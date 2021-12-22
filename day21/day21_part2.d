import std.algorithm;
import std.file;
import std.stdio;
import std.typecons;

alias State = Tuple!(int, "score1", int, "pos1", int, "score2", int, "pos2", bool, "turn2");

long wins1;
long wins2;

long[State] step(const long[State] states) {
    long[State] r;
    foreach (state, count; states) {
        State n;
        if (state.turn2) {
            n.score1 = state.score1;
            n.pos1 = state.pos1;
            n.turn2 = false;
        } else {
            n.score2 = state.score2;
            n.pos2 = state.pos2;
            n.turn2 = true;
        }
        foreach (a; [1, 2, 3]) {
            foreach (b; [1, 2, 3]) {
                foreach (c; [1, 2, 3]) {
                    if (!state.turn2) {
                        n.pos1 = (state.pos1 + a+b+c - 1) % 10 + 1;
                        n.score1 = state.score1 + n.pos1;
                        if (n.score1 >= 21) {
                            wins1 += count;
                        } else {
                            r[n] += count;
                        }
                    } else {
                        n.pos2 = (state.pos2 + a+b+c - 1) % 10 + 1;
                        n.score2 = state.score2 + n.pos2;
                        if (n.score2 >= 21) {
                            wins2 += count;
                        } else {
                            r[n] += count;
                        }
                    }
                }
            }
        }
    }
    return r;
}

void main() {
    auto input = slurp!(int, int)("day21.txt", "Player %d starting position: %d");
    long[State] states;
    states[State(0, input[0][1], 0, input[1][1], false)] = 1;
    while (states.length > 0) {
        states = step(states);
    }
    writeln(max(wins1, wins2));
}
