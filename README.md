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