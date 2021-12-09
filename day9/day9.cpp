#include <algorithm>
#include <array>
#include <functional>
#include <iostream>
#include <memory>
#include <set>
#include <vector>

using namespace std;

using Point = pair<int, int>;

array<Point, 4> neighbors(Point p)
{
    auto x = p.first;
    auto y = p.second;
    return {Point{x-1, y}, Point{x+1, y}, Point{x, y-1}, Point{x, y+1}};
}

struct Heights
{
    unique_ptr<int[]> values;
    int w;
    int h;

    int operator[](Point p)
    {
        auto x = p.first;
        auto y = p.second;
        if (x < 0 || x >= w || y < 0 || y >= h)
            return 9;
        return values[y*w + x];
    }

    friend istream& operator>>(istream& is, Heights& x)
    {
        vector<string> rows;
        string row;
        while (getline(is, row))
            rows.push_back(row);

        x.h = rows.size();
        x.w = rows[0].size();
        x.values = make_unique_for_overwrite<int[]>(x.w * x.h);
        for (int j = 0; j < x.h; ++j)
            for (int i = 0; i < x.w; ++i)
                x.values[j * x.w + i] = rows[j][i] - '0';
        return is;
    }
};

int main()
{
    Heights heights;
    cin >> heights;

    vector<Point> low_points;
    int risk = 0;
    for (int j = 0; j < heights.h; ++j)
    {
        for (int i = 0; i < heights.w; ++i)
        {
            auto p = Point{i, j};
            auto val = heights[p];
            bool is_low = true;
            for (auto n : neighbors(p))
            {
                if (heights[n] <= val)
                {
                    is_low = false;
                    break;
                }
            }
            if (is_low)
            {
                low_points.push_back(p);
                risk += val+1;
            }
        }
    }

    cout << risk << '\n';

    vector<int> basins;
    set<Point> closed;
    for (auto low_point : low_points)
    {
        int basin_size = 0;
        vector<Point> open {low_point};
        while (!open.empty())
        {
            Point p = open.back();
            open.pop_back();
            if (closed.contains(p))
                continue;
            auto val = heights[p];
            if (val == 9)
                continue;
            closed.insert(p);
            ++basin_size;
            for (auto n : neighbors(p))
            {
                if (heights[n] > val)
                    open.push_back(n);
            }
        }
        basins.push_back(basin_size);
    }

    sort(basins.begin(), basins.end(), greater());
    int prod = 1;
    for (int i = 0; i < 3; ++i)
        prod *= basins[i];
    cout << prod << '\n';
    return 0;
}
