load("@rules_testing//lib:test_suite.bzl", "test_suite")
load("//gn:tool.bzl", "shlex_split")

def _shlex_split_test(env):
    env.expect.that_collection(shlex_split("foo")).contains_exactly(["foo"]).in_order()
    env.expect.that_collection(shlex_split("foo bar")).contains_exactly(["foo", "bar"]).in_order()
    env.expect.that_collection(shlex_split('foo "bar baz" qux')).contains_exactly(["foo", "bar baz", "qux"]).in_order()
    env.expect.that_collection(shlex_split('foo --bar="baz"')).contains_exactly(["foo", "--bar=baz"]).in_order()
    env.expect.that_collection(shlex_split('"python3" foo.py')).contains_exactly(["python3", "foo.py"]).in_order()

def tool_test_suite(name):
    test_suite(
        name = name,
        basic_tests = [
            _shlex_split_test,
        ],
    )
