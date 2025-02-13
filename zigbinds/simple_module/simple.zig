const py = @cImport({
    @cDefine("PY_SSIZE_T_CLEAN", {});
    @cInclude("/home/lenny/miniconda3/envs/conspnet/include/python3.10/Python.h");
});
const std = @import("std");
const print = std.debug.print;

const PyObject = py.PyObject;
const PyMethodDef = py.PyMethodDef;
const PyModuleDef = py.PyModuleDef;
const PyModuleDef_Base = py.PyModuleDef_Base;
const Py_BuildValue = py.Py_BuildValue;
const PyModule_Create = py.PyModule_Create;
const METH_NOARGS = py.METH_NOARGS;
const PyArg_ParseTuple = py.PyArg_ParseTuple;
const PyLong_FromLong = py.PyLong_FromLong;

fn sum(self: [*c]PyObject, args: [*c]PyObject) callconv(.C) [*]PyObject {
    _ = self;
    var a: c_long = undefined;
    var b: c_long = undefined;
    if (!(py._PyArg_ParseTuple_SizeT(args, "ll", &a, &b) != 0)) return Py_BuildValue("");
    return py.PyLong_FromLong((a + b));
}

fn mul(self: [*c]PyObject, args: [*c]PyObject) callconv(.C) [*]PyObject {
    _ = self;
    var a: c_long = undefined;
    var b: c_long = undefined;
    if (PyArg_ParseTuple(args, "ll", &a, &b) == 0) return Py_BuildValue("");
    return PyLong_FromLong((a * b));
}

fn hello(self: [*c]PyObject, args: [*c]PyObject) callconv(.C) [*]PyObject {
    _ = self;
    _ = args;
    print("welcom to ziglang\n", .{});
    return Py_BuildValue("");
}

fn printSt(self: [*c]PyObject, args: [*c]PyObject) callconv(.C) [*]PyObject {
    _ = self;
    var input: [*:0]u8 = undefined;
    if (PyArg_ParseTuple(args, "s", &input) == 0) return Py_BuildValue("");
    print("you entered: {s}\n", .{input});
    return Py_BuildValue("");
}

fn returnArrayWithInput(self: [*c]PyObject, args: [*c]PyObject) callconv(.C) [*]PyObject {
    _ = self;

    var N: u32 = undefined;
    if (!(py._PyArg_ParseTuple_SizeT(args, "l", &N) != 0)) return Py_BuildValue("");
    const list: [*c]PyObject = py.PyList_New(N);

    var i: u32 = 0;
    while (i < N) : (i += 1) {
        const python_int: [*c]PyObject = Py_BuildValue("i", i);
        _ = py.PyList_SetItem(list, i, python_int);
    }
    return list;
}

var Methods = [_]PyMethodDef{
    PyMethodDef{
        .ml_name = "sum",
        .ml_meth = sum,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "mul",
        .ml_meth = mul,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "hello",
        .ml_meth = hello,
        .ml_flags = METH_NOARGS,
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "printSt",
        .ml_meth = printSt,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "returnArrayWithInput",
        .ml_meth = returnArrayWithInput,
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = null,
        .ml_meth = null,
        .ml_flags = 0,
        .ml_doc = null,
    },
};

var module = PyModuleDef{
    .m_base = PyModuleDef_Base{
        .ob_base = PyObject{
            .ob_refcnt = 1,
            .ob_type = null,
        },
        .m_init = null,
        .m_index = 0,
        .m_copy = null,
    },
    .m_name = "simple",
    .m_doc = null,
    .m_size = -1,
    .m_methods = &Methods,
    .m_slots = null,
    .m_traverse = null,
    .m_clear = null,
    .m_free = null,
};

pub export fn PyInit_simple() [*]PyObject {
    return PyModule_Create(&module);
}
