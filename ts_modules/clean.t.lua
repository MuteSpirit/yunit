-- test Clean utility
assert(require("unittest"))

local usageText =
    (
        "clean.lua [options] extlist directory\n" ..
        "Options:\n" ..
        "\t-h\t\tprint this message and exit\n" ..
        "\t-v\t\tverbose output\n" ..
        "\t-n <name>\tdelete files with name <name> only\n" ..
        "Operands:\n" ..
        "\textlist\tcomma separated extension list\n" ..
        "\tdirectory\tdirectory to clean\n"
    )

flush_message("Run test: clean usage")
assert_exec(0) [[lua5.1 clean.lua -h > output.txt]]
assert_file_equal("output.txt")(usageText)


preparedir("cleantst")
preparefile("./cleantst/fa")[[]]
preparefile("./cleantst/fa.")[[]]
preparefile("./cleantst/.fa")[[]]
preparefile("./cleantst/.ea")[[]]
preparefile("./cleantst/fa.ea")[[]]
preparefile("./cleantst/fa..ea")[[]]


flush_message("Run test: test another extension")
assert_exec(0) [[lua5.1 clean.lua .fa "cleantst"]]
assert_file_exists("./cleantst/fa")
assert_file_exists("./cleantst/fa.")
assert_file_exists("./cleantst/.fa")
assert_file_exists("./cleantst/.ea")
assert_file_exists("./cleantst/fa.ea")
assert_file_exists("./cleantst/fa..ea")

flush_message("Run test: test anothe name")
assert_exec(0) [[lua5.1 clean.lua -n fx .ea "./cleantst"]]
assert_file_exists("./cleantst/fa")
assert_file_exists("./cleantst/fa.")
assert_file_exists("./cleantst/.fa")
assert_file_exists("./cleantst/.ea")
assert_file_exists("./cleantst/fa.ea")
assert_file_exists("./cleantst/fa..ea")

flush_message("Run test: test exact clean")
assert_exec(0) [[lua5.1 clean.lua -v -n fa .ea "./cleantst" > output.txt]]
assert_file_match("output.txt")
[[
^Clean utility: current directory is '.+'
Clean utility: delete file './cleantst\fa.ea'
$]]
assert_file_exists("./cleantst/fa")
assert_file_exists("./cleantst/fa.")
assert_file_exists("./cleantst/.fa")
assert_file_exists("./cleantst/.ea")
assert_file_not_exists("./cleantst/fa.ea")
assert_file_exists("./cleantst/fa..ea")

flush_message("Run test: test empty extension clean")
assert_exec(0) [[lua5.1 clean.lua -n fa . "./cleantst"]]
assert_file_not_exists("./cleantst/fa")
assert_file_not_exists("./cleantst/fa.")
assert_file_exists("./cleantst/.fa")
assert_file_exists("./cleantst/.ea")
assert_file_exists("./cleantst/fa..ea")

flush_message("Run test: test multi extension clean")
assert_exec(0) [[lua5.1 clean.lua .ea. "./cleantst"]]
assert_file_not_exists("./cleantst/.fa")
assert_file_not_exists("./cleantst/.ea")
assert_file_not_exists("./cleantst/fa..ea")

rmtree("cleantst", true)
