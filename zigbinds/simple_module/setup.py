from builder import ZigBuilder
from setuptools import setup, Extension

simple = Extension("simple", sources=["simple.zig"])

setup(
    name="simple",
    version="0.0.1",
    description="a experiment create Python module in Zig",
    ext_modules=[simple],
    cmdclass={"build_ext": ZigBuilder},
)