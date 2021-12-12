Red [
    Title: "AoC 2021 Day 12"
    Author: "J. Nelson"
    File: %day12.red
    Date: 12-Dec-2021
]

#system [
    #include %day12-impl.reds
]

find-or-append: function [
    xs [series!]
    x [any-type!]
    return: [integer!]
][
    result: find xs x
    either result [
        index? result
    ][
        append xs x
        length? xs
    ]
]

isSmall: function [cave [string!] return: [logic!]] [cave/1 = lowercase cave/1]

connections: copy []
caves: copy ["start" "end"]
foreach line read/lines %day12.txt [
    set [a b] split line "-"
    i: find-or-append caves a
    j: find-or-append caves b
    append connections reduce [i j]
]
size: length? caves
adjacency: make vector! size ** 2
foreach [i j] connections [
    change at adjacency i - 1 * size + j either isSmall pick caves j [1] [-1]
    change at adjacency j - 1 * size + i either isSmall pick caves i [1] [-1]
]

rs-count-paths: routine [
    adjacency [vector!]
    size [integer!]
    double-visit-used [logic!]
    return: [integer!]
    /local s [series!]
] [
    s: GET_BUFFER(adjacency)
    count-paths as pointer! [integer!] s/offset size 0 START double-visit-used
]

print rs-count-paths adjacency size true
print rs-count-paths adjacency size false
