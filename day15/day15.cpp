#include <fstream>
#include <functional>
#include <iostream>
#include <queue>
#include <set>
#include <tuple>
#include <vector>

using namespace std;

using Node = tuple<int, int, int>;

int lowest_risk(const vector<string>& lines, int tiles)
{
    vector<vector<int>> risk;
    for (int j = 0; j < tiles; ++j)
    {
        for (auto line : lines)
        {
            vector<int> row;
            for (int i = 0; i < tiles; ++i)
            {
                for (char c : line)
                    row.push_back((c - '0' - 1 + i + j) % 9 + 1);
            }
            risk.push_back(row);
        }
    }
    int h = risk.size();
    int w = risk[0].size();

    priority_queue<Node, vector<Node>, greater<Node>> pq;
    pq.push(make_tuple(0, 0, 0));
    set<pair<int, int>> seen;
    for (;;)
    {
        auto [r, x, y] = pq.top();
        pq.pop();
        if (seen.contains(make_pair(x, y)))
            continue;
        seen.insert(make_pair(x, y));
        if (x == w-1 && y == h-1)
            return r;
        if (x != 0)
            pq.push(make_tuple(r+risk[y][x-1], x-1, y));
        if (x != w-1)
            pq.push(make_tuple(r+risk[y][x+1], x+1, y));
        if (y != 0)
            pq.push(make_tuple(r+risk[y-1][x], x, y-1));
        if (y != h-1)
            pq.push(make_tuple(r+risk[y+1][x], x, y+1));
    }
}

int main()
{
    ifstream file {"day15.txt"};
    vector<string> lines;
    string line;
    while (getline(file, line))
        lines.push_back(line);
    cout << lowest_risk(lines, 1) << '\n';
    cout << lowest_risk(lines, 5) << '\n';
    return 0;
}
