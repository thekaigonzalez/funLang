import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.variant;
import core.stdc.stdlib;

struct Request
{
    string action;
    string[] args;
}

Function[string] funclist;

struct Function {
    Request[] reqs;
}

void runFunction(Function s) {
    foreach (Request r ; s.reqs) {
        executeRequest(r);
    }
}

void executeRequest(Request r)
{
    if (r.action == "print")
    {
      writeln(r.args[0]);
    } else if (r.action == "run") {
      runFunction(funclist[r.args[0]]);
    } else {
      fenv[r.action](r.args);
    }
}

Variant[] convertToVariants(string[] old_arr) {
  Variant[] new_arr;

  foreach (string n ; old_arr) new_arr~=Variant(n);
  return new_arr;
}

Variant add(string[] args) {
  int m = to!int(args[0]);
  int m2 = to!int(args[1]);

  writeln(m + m2);

  return Variant(0);
}

/* planning to add lambda expressions/unknown host expressions

they'll work like this:

fn main {
    print [+add a b]

they'll especially be useful in variable situations, where, using code in
one place isn't as helpful.

you also can't print added results, only use whatever the function provides.

add a b

*/

void fun_error(string fileheader, string msg) {
    writeln(fileheader ~ ": error: " ~ msg);
}

Variant[string] environment; /* "_" because it matches with the 'scope' keyword lol */
Variant function(string[])[string] fenv;

Variant get_variable(string name) {
  return (name in environment) ? environment[name] : Variant(null);
}

void run_fun_body(string body, bool execute = true, string toplevel_name = "")
{
    string lex;

    int state;

    string fname;

    string[] arg;
    
    Function l;

    state = 0;

    foreach (char s; body)
    {
        if (s == ' ' && state == 0 && lex.strip().length > 1)
        {
            fname = lex.strip();
            state = 2;
            lex = "";
        }
        else if (s == ' ' && state == 2 && lex.strip().length > 0)
        {
            arg = arg ~ lex.strip();
            lex = "";
        }
        else if (s == '"' && state == 2)
        {
            state = 9;
        }
        else if (s == '"' && state == 9)
        {
            state = 2;
        }
        else if (s == ';' && state == 2)
        {
            Request r;

            if (lex.strip().length > 0)
            {
                arg = arg ~ lex.strip();
                lex = "";
            }
            r.action = fname;
            r.args = arg;

            if (execute)
                executeRequest(r);
            
            else {
                /* save function */
                l.reqs = l.reqs ~ r;
            }

            state = 0;
            arg = [];
            lex = "";

        }
        else
        {
            lex ~= s;
        }
    }

    if (!execute) {
        funclist[toplevel_name] = l;
    }

    
}

void run_fun_basic(string code)
{
    string lex;

    int state;

    string cache;
    string cache2;

    state = 0;

    string fileheader = "";

    foreach (char s; code)
    {
        if (s == ' ' && state == 0)
        {
            if (lex.strip() == "fn")
            {
                state = 1;
                lex = "";
            }
            else if (lex.strip() == "def") {
                state = -2;
            }
            else
            {
                fun_error(fileheader, "expected class_identifier, got `" ~ lex ~ "'");
                fun_error(fileheader, "unrecoverable status; exiting...");
                exit(-1);
            }
        } 

        else if (s == '(' && state == -2) {
            state = -3;
            lex = "";
        }

        else if (s == '=' && state == -3) {
            state = -4;
            cache = lex.strip;
            lex = "";
            
        }

        else if (s == ')' && state == -4) {
            cache2 = lex.strip;
            environment[cache] = Variant(cache2);
            state = 0;
            lex = "";
        }

        else if (s == '{' && state != 0)
        {
            if (state == 1)
            {
                
                
                state = 8;
                cache = lex.strip;
                
                lex = "";
            }
        }
        else if (s == '}' && state == 7)
        {
            run_fun_body(lex);
            state = 0;
            lex = "";
        }
        else if ((s == '"' || s == '\'') && state == 7) state = -1;

        else if ((s == '"' || s == '\'') && state == -1) state = 7;
        
        else if (s == '}' && state == 8)
        {

            run_fun_body(lex, false, cache);

            state = 0;
            lex = "";
        }
        else
        {
            lex ~= s;
        }
    }

}

void main(string[] args)
{
  fenv["add"] = &add;
  run_fun_basic(to!string(read(args[1])));
  runFunction(funclist["main"]);
}
