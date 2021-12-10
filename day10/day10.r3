REBOL [
    Title: "AoC 2021 Day 10"
    Date: 10-Dec-2021
    File: %day10.r3
    Author: "J. Nelson"
]

go: func [
    line completion
    /local open correctClose nextChar badClose close
][
    if tail? line [return reduce [line none completion]]
    open: first line
    correctClose: switch open [
        #"(" [#")"]
        #"[" [#"]"]
        #"{" [#"}"]
        #"<" [#">"]
    ]
    line: next line
    if tail? line [return reduce [line none append completion correctClose]]
    nextChar: first line
    if find "([{<" nextChar [
        set [line badClose] go line completion
        if badClose [return reduce [line badClose completion]]
        if tail? line [return reduce [line none append completion correctClose]]
    ]
    close: first line
    line: next line
    if close != correctClose [return reduce [line close completion]]
    either all [not tail? line find "([{<" first line] [
        go line completion
    ][
        reduce [line none completion]
    ]
]

syntaxErrorScore: 0
completionScores: copy []
foreach line read/lines %day10.txt [
    set [line badClose completion] go line copy ""
    either badClose [
        syntaxErrorScore: syntaxErrorScore + switch badClose [
            #")" [3]
            #"]" [57]
            #"}" [1197]
            #">" [25137]
        ]
    ][
        score: 0
        foreach c completion [
            score: score * 5 + switch c [
                #")" [1]
                #"]" [2]
                #"}" [3]
                #">" [4]
            ]
        ]
        completionScores: append completionScores score
    ]
]
print syntaxErrorScore
sort completionScores
middle: (length? completionScores) + 1 / 2
print pick completionScores middle
