import pegged.grammar;
import std.algorithm;
import std.array;
import std.conv;
import std.file;
import std.format;
import std.math;
import std.stdio;
import std.sumtype;
import std.typecons;

mixin(grammar(`
ALU:
    Program <- (Instruction :eol)+ eoi
    Instruction <- Inp / Add / Mul / Div / Mod / Eql
    Inp <- "inp" ' ' Variable
    Add <- "add" ' ' Variable ' ' Value
    Mul <- "mul" ' ' Variable ' ' Value
    Div <- "div" ' ' Variable ' ' Value
    Mod <- "mod" ' ' Variable ' ' Value
    Eql <- "eql" ' ' Variable ' ' Value
    Variable <- W / X / Y / Z
    W <- 'w'
    X <- 'x'
    Y <- 'y'
    Z <- 'z'
    Value <- Variable / Number
    Number <- ~('-'? digits)
`));

enum Var { w, x, y, z };
Var parseVar(ParseTree var) {
    assert(var.name == "ALU.Variable");
    final switch (var.children[0].name) {
        case "ALU.W": return Var.w;
        case "ALU.X": return Var.x;
        case "ALU.Y": return Var.y;
        case "ALU.Z": return Var.z;
    }
}

alias Value = SumType!(int, Var);
Value parseValue(ParseTree value) {
    assert(value.name == "ALU.Value");
    final switch (value.children[0].name) {
        case "ALU.Variable": return Value(parseVar(value.children[0]));
        case "ALU.Number": return Value(to!int(value.children[0].matches[0]));
    }
}

struct Inp { int n; }
struct AddT(Expr) { Expr* a; Expr* b; }
struct MulT(Expr) { Expr* a; Expr* b; }

alias Expr = SumType!(int, Inp, AddT!This, MulT!This);
alias Add = Expr.Types[2];
alias Mul = Expr.Types[3];

Expr* evalValue(ref Expr*[Var] vars, Value value) {
    return value.match!(
        (Var v) => vars[v],
        (int n) => new Expr(n)
    );
}

Tuple!(Expr*, Expr*) divmod(Expr* aExpr, Expr* bExpr) {
    int b = (*bExpr).tryMatch!((int b) => b);
    return (*aExpr).tryMatch!(
        (int a) => tuple(new Expr(a / b), new Expr(a % b)),
        (Mul a) {
            if (*a.a == *bExpr) return tuple(a.b, new Expr(0));
            else if (*a.b == *bExpr) return tuple(a.a, new Expr(0));
            else assert(false);
        },
        (Add a) {
            alias doMatch = match!(
                (Mul aa, _ab) {
                    if (*aa.a == *bExpr) return tuple(aa.b, a.b);
                    else if (*aa.b == *bExpr) return tuple(aa.a, a.b);
                    else assert(false);
                },
                (_aa, Mul ab) {
                    if (*ab.a == *bExpr) return tuple(ab.b, a.a);
                    else if (*ab.b == *bExpr) return tuple(ab.a, a.a);
                    else assert(false);
                },
                (_aa, _ab) { return tuple(new Expr(0), aExpr); }
            );
            return doMatch(*a.a, *a.b);
        }
    );
}

string show(Expr expr) {
    return expr.match!(
        (int i) => to!string(i),
        (Inp i) => "i%s".format(i.n),
        (Add add) => "(%s+%s)".format(show(*add.a), show(*add.b)),
        (Mul mul) => "(%s*%s)".format(show(*mul.a), show(*mul.b))
    );
}

alias Equation = Tuple!(Inp, int, Inp); // 0 + 1 == 2
Equation[] equations;

void eval(ref Expr*[Var] vars, ref int nextInput, ParseTree inst) {
    auto var = parseVar(inst.children[0]);
    final switch (inst.name) {
        case "ALU.Inp":
            vars[var] = new Expr(Inp(nextInput++));
            break;
        case "ALU.Add":
            auto aExpr = vars[var];
            auto bExpr = evalValue(vars, parseValue(inst.children[1]));
            alias doMatch = match!(
                (int a, int b) => new Expr(a + b),
                (int a, Add b) {
                    if (a == 0) return bExpr;
                    alias doMatch = match!(
                        (int ba, _bb) => new Expr(Add(new Expr(a + ba), b.b)),
                        (_ba, int bb) => new Expr(Add(b.a, new Expr(a + bb))),
                        (_ba, _bb) => new Expr(Add(aExpr, bExpr))
                    );
                    return doMatch(*b.a, *b.b);
                },
                (int a, _b) => a == 0 ? bExpr : new Expr(Add(aExpr, bExpr)),
                (Add a, int b) {
                    if (b == 0) return aExpr;
                    alias doMatch = match!(
                        (int aa, _ab) => new Expr(Add(new Expr(aa + b), a.b)),
                        (_aa, int ab) => new Expr(Add(a.a, new Expr(ab + b))),
                        (_aa, _ab) => new Expr(Add(aExpr, bExpr))
                    );
                    return doMatch(*a.a, *a.b);
                },
                (_a, int b) => b == 0 ? aExpr : new Expr(Add(aExpr, bExpr)),
                (_a, _b) => new Expr(Add(aExpr, bExpr))
            );
            vars[var] = doMatch(*aExpr, *bExpr);
            break;
        case "ALU.Mul":
            auto aExpr = vars[var];
            auto bExpr = evalValue(vars, parseValue(inst.children[1]));
            alias doMatch = match!(
                (int a, int b) => new Expr(a * b),
                (int a, _b) {
                    switch (a) {
                        case 0: return new Expr(0);
                        case 1: return bExpr;
                        default: return new Expr(Mul(aExpr, bExpr));
                    }
                },
                (_a, int b) {
                    switch (b) {
                        case 0: return new Expr(0);
                        case 1: return aExpr;
                        default: return new Expr(Mul(aExpr, bExpr));
                    }
                },
                (_a, _b) => new Expr(Mul(aExpr, bExpr))
            );
            vars[var] = doMatch(*aExpr, *bExpr);
            break;
        case "ALU.Div":
            auto bExpr = evalValue(vars, parseValue(inst.children[1]));
            if (*bExpr != Expr(1)) {
                auto dm = divmod(vars[var], bExpr);
                vars[var] = dm[0];
            }
            break;
        case "ALU.Mod":
            auto dm = divmod(vars[var], evalValue(vars, parseValue(inst.children[1])));
            vars[var] = dm[1];
            break;
        case "ALU.Eql":
            auto aExpr = vars[var];
            auto bExpr = evalValue(vars, parseValue(inst.children[1]));
            alias doMatch = tryMatch!(
                (int a, int b) {
                    vars[var] = new Expr(a == b ? 1 : 0);
                },
                (int a, Inp b) {
                    assert(a < 1 || a > 9);
                    vars[var] = new Expr(0);
                },
                (Add a, Inp b) {
                    alias doMatch2 = tryMatch!(
                        (Inp aa, int ab) {
                            if (ab < -8 || ab > 8) vars[var] = new Expr(0);
                            else {
                                equations ~= tuple(aa, ab, b);
                                vars[var] = new Expr(1);
                            }
                        }
                    );
                    doMatch2(*a.a, *a.b);
                }
            );
            doMatch(*aExpr, *bExpr);
    }
}

enum Mode { max, min }
Tuple!(int, int) calcDigits(int additive, Mode mode) {
    final switch (mode) {
        case Mode.max:
            return additive > 0 ? tuple(9 - additive, 9) : tuple(9, 9 + additive);
        case Mode.min:
            return additive > 0 ? tuple(1, 1 + additive) : tuple(1 - additive, 1);
    }
}

void main() {
    auto alu = ALU(readText("day24.txt"));
    assert(alu.successful);
    auto program = alu.children[0];
    Expr*[Var] vars;
    vars[Var.w] = new Expr(0);
    vars[Var.x] = new Expr(0);
    vars[Var.y] = new Expr(0);
    vars[Var.z] = new Expr(0);
    int nextInput;
    foreach (inst; program.children) {
        eval(vars, nextInput, inst.children[0]);
    }
    foreach (mode; [Mode.max, Mode.min]) {
        int[14] digits;
        foreach (eq; equations) {
            auto ds = calcDigits(eq[1], mode);
            digits[eq[0].n] = ds[0];
            digits[eq[2].n] = ds[1];
        }
        writeln(digits.array.map!(to!string).join);
    }
}
