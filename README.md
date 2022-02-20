# advent-of-code-2021
Advent of Code 2021

## Zig in docker
```bash
docker build -t zig .
docker run -it -v $(pwd):/home zig
```

## Build and Run
```bash
# clone it
cd advent-of-code-2021
zig run src/main.zig
```

## Thoughts on Zig

I want start with a big thanks to Zig community because I asked many things to people :)

This is my first touch to Zig language and the code can be very dirty but I know it and maybe the advent
of code is not the best way for learning a new programming language. My purpose is just take a look to Zig, btw this challenge takes me more time than 25 days and I handled well this with myseld acceptance.

My "concept" of Zig before starting was a new version of C, new syntax, test suite integrate, CLI with support for build/test/fmt, allocator managment, seems promising for who comes from C.
I know C/C++/Go/Rust then I thought to be at least not so far from my "confort" zone.

First step, set up my "ide", that can be vim/vscode/jetbrains or such, but from this I immediatly understand zig is not so ready as I thought before. In the end I used vscode + extension for syntax + docker image for build source code, not so satisfying but at least usable for writing bad code.

### What I like

First of all, the problem with C/C++ the fmt tool :), I know now go/rust and other have this kind of tool but for me is always a good feeling using it.

Syntax is quite clean and I like the loops like `while (numbers.next()) |n|` or `while (step < 10) : (step += 1)` because keeps all important things on the same line.

Compile time function call, or just `comptime`, is very interesting feature, because you can allocate a bunch of memory with this feature, like `const len = comptime multiply(4, 5);` and use `len` for an array size for example. I know you can call also a block of istruction using `comptime {}` but I don't want dig into this because I don't use it deep.

Rename imported things, like Go, you can use an abbreviation or other fancy names when you import a file into another like `const std = @import("std");` or also for function you can use something like `const my_log = std.debug.print;`. Very neat for possible naming conflict.

The allocators, all containers take an allocator, and this is the core thing of Zig (I think), in this repo I used only testing allocator because I did't want to take care of this but is such a cool feature if you are trying to run your software on bare metal or other hardware with some limits.

Error handling is similar to Rust's `Result` because `!u32` means the function can return a `u32` or an error. This is simple to understand but I don't appreciate how you need to call a function that can return an error, `try funciont()`, this `try` reminds me something related to try/catch with exception handling and they are not a happy memories.

### What I don't like

The concept of `null`, ok if we think zig as new C language is acceptable that we have a sort of null value but coming from Rust I appreciate to not handle anymore `if (variable == null)` or any kind of checks like this. Then `?i32` means that variable "can" be a integer 32.

Initializing arrays is weird in Zig. Lets say you want to have a 0 initialized array, you declare it like `[_]u8{0} ** 4` which means I want an array, of type `u8` of 4 elements initialized to 0, not very intuitive.

For the test command you should specify the file that you want to test like `zig test src/day1.zig`, ok not so strange but I expect that `zig test` runs all unit tests like `cargo test` but it doesn't :(.

Another strange stuff is the macros used to convert types like `@as`/ `@intCast` and others, I personally don't really like to use macro for doing this, but ok, it's a design choice, just add function to standard library, why should I use `@bitReverse` as macro?