fn main {
    run make2;
}


fn umain {
    
    print "hello world!";
    print "goodbye";

    run tunnel;
}

fn tunnel {
    print "Going through";
    print "the magical tunnel!";
}

fn make2 {
    print "Hello again.";

    run umain;
}

