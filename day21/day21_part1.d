import std.file;
import std.stdio;

class DeterministicDie {
    int next = 1;
    int rolls = 0;

    int roll() {
        auto r = next;
        ++rolls;
        next = next == 100 ? 1 : next+1;
        return r;
    }
}

class Player {
    int position;
    int score;

    this(int position) {
        this.position = position;
    }
}

void turn(DeterministicDie die, Player player) {
    int r;
    for (int i = 0; i < 3; ++i) {
        r += die.roll();
    }
    player.position = (player.position + r - 1) % 10 + 1;
    player.score += player.position;
}

void main() {
    auto input = slurp!(int, int)("day21.txt", "Player %d starting position: %d");
    Player[] players = [new Player(input[0][1]), new Player(input[1][1])];
    int current = 0;
    auto die = new DeterministicDie();
    while (players[0].score < 1000 && players[1].score < 1000) {
        turn(die, players[current]);
        current = (current + 1) % 2;
    }
    if (players[0].score >= 1000)
        writeln(players[1].score * die.rolls);
    else
        writeln(players[0].score * die.rolls);
}
