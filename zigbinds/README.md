# Zig + Python
This repo is for study how to use zig from python.

## Zig Python environment with Docker

```bash
docker compose build
docker compose run zig ash
$ zig version # 0.10.1
$ python --version # python 3.10.12
```

## Lib Method
* test (into the zig/python environment ex. docker)
```bash
cd simple_module
python test.py
```
* install manually
```bash
cd simple_module
pip install -e .
# import simple
```

## Import .so Method
* test (into the zig/python environment ex. docker)
```bash
cd simple_so

python test.py
```
* compile manually
```
# zig build-lib -lc -dynamic -I /usr/include/python3.11 -isystem . simple.zig
zig build-lib simple.zig -dynamic
```


# References
* docker, docker-compose
* python
* zig
* [pythton zig example](https://github.com/Lucifer-02/python_zig/tree/main)
* [Extending and Embedding the python interpreter](https://docs.python.org/3/extending/index.html)