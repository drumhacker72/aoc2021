#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <string>

using namespace std;

using Rules = map<pair<char, char>, char>;
using Counts = map<pair<char, char>, int64_t>;

Counts step(const Rules& rules, const Counts& polymer)
{
    Counts new_counts;
    for (auto [p, cnt] : polymer)
    {
        auto match = rules.find(p);
        if (match == rules.end())
        {
            new_counts[p] += cnt;
        }
        else
        {
            auto insertion = match->second;
            new_counts[make_pair(p.first, insertion)] += cnt;
            new_counts[make_pair(insertion, p.second)] += cnt;
        }
    }
    return new_counts;
}

int64_t difference(const string& templ, const Counts& polymer)
{
    map<char, int64_t> char_counts;
    ++char_counts[templ.front()];
    ++char_counts[templ.back()];
    for (auto [p, cnt] : polymer)
    {
        char_counts[p.first] += cnt;
        char_counts[p.second] += cnt;
    }

    set<int64_t> just_counts;
    for (auto [c, cnt] : char_counts)
        just_counts.insert(cnt >> 1);
    return *just_counts.rbegin() - *just_counts.begin();
}

int main()
{
    ifstream file {"day14.txt"};
    string templ;
    getline(file, templ);
    Counts polymer;
    for (int i = 0; i < templ.size() - 1; ++i)
        ++polymer[make_pair(templ[i], templ[i+1])];

    string blank;
    getline(file, blank);

    Rules rules;
    string rule;
    while (getline(file, rule))
    {
        char a, b, insert;
        sscanf(rule.c_str(), "%c%c -> %c", &a, &b, &insert);
        rules[make_pair(a, b)] = insert;
    }

    for (int i = 0; i < 10; ++i)
        polymer = step(rules, polymer);
    cout << difference(templ, polymer) << '\n';
    for (int i = 10; i < 40; ++i)
        polymer = step(rules, polymer);
    cout << difference(templ, polymer) << '\n';
    return 0;
}
