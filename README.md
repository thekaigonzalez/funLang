# fun

A toy programming language that is designed in branches with a clean control system.

```
fn main {
    run umain;
}

fn umain {
    print "cli";
    run final_func;
}

fn final_func {
    print "Final function";
}
```