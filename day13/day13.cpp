#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

using namespace std;

struct Dots
{
    unique_ptr<bool[]> grid;
    int width;
    int height;
    int real_width;

    bool operator[](pair<int, int> p) const { return grid[p.second * real_width + p.first]; }
    bool& operator[](pair<int, int> p) { return grid[p.second * real_width + p.first]; }

    int count() const
    {
        int c = 0;
        for (int y = 0; y < height; ++y)
        {
            for (int x = 0; x < width; ++x)
            {
                if ((*this)[make_pair(x, y)])
                    ++c;
            }
        }
        return c;
    }

    friend istream& operator>>(istream& is, Dots& dots)
    {
        dots.width = 0;
        dots.height = 0;
        vector<pair<int, int>> points;
        for (;;)
        {
            string line;
            getline(is, line);
            if (line.empty())
                break;
            auto comma = line.find(',');
            int x = stoi(line.substr(0, comma));
            int y = stoi(line.substr(comma+1));
            dots.width = max(dots.width, x+1);
            dots.height = max(dots.height, y+1);
            points.push_back(make_pair(x, y));
        }
        dots.grid = make_unique<bool[]>(dots.width * dots.height);
        dots.real_width = dots.width;
        for (auto& p : points)
            dots[p] = true;
        return is;
    }
    friend ostream& operator<<(ostream& os, const Dots& dots)
    {
        for (int y = 0; y < dots.height; ++y)
        {
            for (int x = 0; x < dots.width; ++x)
                os << (dots[make_pair(x, y)] ? "█" : " ");
            os << '\n';
        }
        return os;
    }
};

int main()
{
    ifstream file {"day13.txt"};
    Dots dots;
    file >> dots;

    bool first = true;
    string line;
    while (getline(file, line))
    {
        char axis;
        int coord;
        sscanf(line.c_str(), "fold along %c=%d", &axis, &coord);
        switch (axis)
        {
        case 'x':
            for (int y = 0; y < dots.height; ++y)
            {
                for (int x = 0; x < coord; ++x)
                {
                    if (dots[make_pair(coord+coord-x, y)])
                        dots[make_pair(x, y)] = true;
                }
            }
            dots.width = coord;
            break;
        case 'y':
            for (int y = 0; y < coord; ++y)
            {
                for (int x = 0; x < dots.width; ++x)
                {
                    if (dots[make_pair(x, coord+coord-y)])
                        dots[make_pair(x, y)] = true;
                }
            }
            dots.height = coord;
        }
        if (first)
        {
            cout << dots.count() << '\n';
            first = false;
        }
    }

    cout << '\n' << dots;
    return 0;
}
