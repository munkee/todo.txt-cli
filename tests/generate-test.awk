#!/usr/bin/awk -f

# To create a test unit, start a shell with an easy prompt for further parsing:
# PS1=">>> "

function execute(description, cmd, expect) {
    print "cat > expect <<EOF"
    print expect
    print "EOF"
    if (description=="") description="description to be filled"
    printf "test_expect_success '" description "' '" cmd " 2>&1 |"
    printf "sed \"/^$/d;"
# absolute location of todo.txt must be replaced by "...todo.txt"
    printf       "s#$remove_trash/#...#;"
# absolute location of todo.sh  must be replaced by "...todo.sh"
    printf       "s#$(which todo.sh)#...todo.sh#;"
# date yyyy-mm-dd must be replaced by "..."
    printf       "s#[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}#...#;"
# time hh:mm:ss   must be replaced by "..."
    printf       "s#[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}#...#;"
    printf "\""
    printf " > output && test_cmp expect output'\n\n"
}
BEGIN {
    printf "#!/bin/sh\n\n"
    printf "test_description=\"todo.sh test description to be filled\"\n\n"
    printf ". ./test-lib.sh\n\n"
    cmd=""
    description=""
    expect=""
}
/^>>>/ && cmd!="" {
    execute(description, cmd, expect)
    cmd=""
    description=""
    expect=""
}
/^(>>>)? *#/ {
    sub(/^(>>>)? *# */,"")
    sub(/:$/,"")
    if (description!="") description=description "\n"
    description=description $0
    next
}
/^>>>/ && cmd=="" {
    sub(/^>>> */,"")
    cmd=$0
    next
}
/./ {
    if (expect!="") expect=expect "\n"
    expect=expect $0
}
END {
    execute(description, cmd, expect)
    print "test_done"
}
