import std.stdio;
import std.file;
import std.string;
import std.conv;
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
    }
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
        else if (s == ' ' && state == 2 && lex.strip().length > 1)
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

            if (lex.strip().length > 1)
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

    state = 0;

    foreach (char s; code)
    {
        if (s == ' ' && state == 0)
        {
            if (lex.strip() == "fn")
            {
                state = 1;
                lex = "";
            }
            else
            {
                writeln("expected class_identifier, got `" ~ lex ~ "'");
                writeln("unrecoverable status; exiting...");
                exit(-1);
            }
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
    run_fun_basic(to!string(read(args[1])));
    runFunction(funclist["main"]);
}
