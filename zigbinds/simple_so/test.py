import subprocess

# failed = subprocess.call(["zig", "build-lib", "simple.zig", "-dynamic", "-lc", "-I", "/usr/include/python3.11", "-isystem", "."])
failed = subprocess.call(["zig", "build-lib", "simple.zig", "-dynamic"])
assert not failed

from ctypes import cdll
simple = cdll.LoadLibrary("./libsimple.so")

a = input("enter a: ")
b = input("enter b: ")
print("sum: ",simple.sum(int(a),int(b)))
# print("multiple: ",simple.mul(int(a),int(b)))
# print("type sum: ", type(simple.sum(int(a),int(b))))
# simple.hello()
simple.printSt(input("enter something: "))
# print(simple.returnArrayWithInput(100))