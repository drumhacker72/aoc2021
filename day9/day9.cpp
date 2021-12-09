#include <algorithm>
#include <array>
#include <functional>
#include <iostream>
#include <memory>
#include <numeric>
#include <set>
#include <vector>

using namespace std;
using namespace std::placeholders;

using Point = pair<int, int>;

array<Point, 4> neighbors(Point p)
{
    auto x = p.first;
    auto y = p.second;
    return {Point{x-1, y}, Point{x+1, y}, Point{x, y-1}, Point{x, y+1}};
}

class Heights
{
    unique_ptr<int[]> values;
    int w;
    int h;
public:
    int width() const { return w; }
    int height() const { return h; }

    int operator[](Point p) const
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

Heights read_heights()
{
    Heights heights;
    cin >> heights;
    return heights;
}

vector<Point> find_low_points(const Heights& heights)
{
    vector<Point> low_points;
    for (int j = 0; j < heights.height(); ++j)
    {
        for (int i = 0; i < heights.width(); ++i)
        {
            auto p = Point{i, j};
            auto val = heights[p];
            auto ns = neighbors(p);
            bool is_low = none_of(ns.begin(), ns.end(), [&](auto n) { return heights[n] <= val; });
            if (is_low)
                low_points.push_back(p);
        }
    }
    return low_points;
}

template <class It>
int get_risk(const Heights& heights, It begin, It end)
{
    return accumulate(begin, end, 0, [&](int a, Point b) { return a + heights[b] + 1; });
}

int find_basin_size(const Heights& heights, Point low_point)
{
    set<Point> closed;
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
    return basin_size;
}

int main()
{
    const auto heights = read_heights();

    const auto low_points = find_low_points(heights);
    cout << get_risk(heights, low_points.begin(), low_points.end()) << '\n';

    vector<int> basins;
    transform(low_points.begin(), low_points.end(), back_inserter(basins), bind(find_basin_size, cref(heights), _1));
    sort(basins.begin(), basins.end(), greater{});
    cout << accumulate(basins.begin(), basins.begin() + 3, 1, multiplies{}) << '\n';
    return 0;
}
