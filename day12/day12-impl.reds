Red/System [
    Title: "AoC 2021 Day 12 Implementation"
    Author: "J. Nelson"
    File: %day12-impl.reds
    Date: 12-Dec-2021
]

#define START 1
#define END 2

bit: func [
    index [integer!]
    return: [integer!]
] [
    1 << (index - 1)
]

has-bit: func [
    bits [integer!]
    index [integer!]
    return: [logic!]
][
    (bits and bit index) <> 0
]

set-bit: func [
    bits [integer!]
    index [integer!]
    return: [integer!]
][
    bits or bit index
]

count-paths: func [
    adjacency [pointer! [integer!]]
    size [integer!]
    seen [integer!]
    current [integer!]
    double-visit-used [logic!]
    return: [integer!]
    /local
        count [integer!]
        i [integer!]
        adj-row [pointer! [integer!]]
][
    count: 0
    if current = END [return 1]
    adj-row: adjacency + (current - 1 * size)
    i: END
    while [i <= size] [
        switch adj-row/i [
            0 []
            1 [
                if not all [has-bit seen i  double-visit-used] [
                    count: count + count-paths adjacency size set-bit seen i i any [double-visit-used  has-bit seen i]
                ]
            ]
            -1 [count: count + count-paths adjacency size set-bit seen i i double-visit-used]
        ]
        i: i + 1
    ]
    count
]
