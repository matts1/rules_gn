SOURCE_UNKNOWN = 0
SOURCE_ASM = 1
SOURCE_C = 2
SOURCE_CPP = 3
SOURCE_H = 4
SOURCE_M = 5
SOURCE_MM = 6
SOURCE_MODULEMAP = 7
SOURCE_S = 8
SOURCE_RC = 9
SOURCE_O = 10
SOURCE_DEF = 11
SOURCE_RS = 12
SOURCE_GO = 13
SOURCE_SWIFT = 14
SOURCE_SWIFTMODULE = 15
SOURCE_NUMTYPES = 16

_SOURCE_TYPES = {
    "c": SOURCE_C,
    "h": SOURCE_H,
    "m": SOURCE_M,
    "o": SOURCE_O,
    "S": SOURCE_S,
    "s": SOURCE_S,
    "cc": SOURCE_CPP,
    "go": SOURCE_GO,
    "hh": SOURCE_H,
    "mm": SOURCE_MM,
    "rc": SOURCE_RC,
    "rs": SOURCE_RS,
    "cpp": SOURCE_CPP,
    "cxx": SOURCE_CPP,
    "c++": SOURCE_CPP,
    "hpp": SOURCE_H,
    "hxx": SOURCE_H,
    "inc": SOURCE_H,
    "ipp": SOURCE_H,
    "inl": SOURCE_H,
    "asm": SOURCE_S,
    "def": SOURCE_DEF,
    "obj": SOURCE_O,
    "hpp11": SOURCE_H,
    "swift": SOURCE_SWIFT,
    "swiftmodule": SOURCE_SWIFTMODULE,
    "modulemap": SOURCE_MODULEMAP,
}

_TOOL_BY_TYPE = {
    SOURCE_C: "cc",
    SOURCE_CPP: "cxx",
}

def get_source_file_type(f):
    return _SOURCE_TYPES.get(f.extension, SOURCE_UNKNOWN)

def select_tool(source):
    return _TOOL_BY_TYPE.get(get_source_file_type(source), None)
