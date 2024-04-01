#!/bin/sh

num_ssh=$(netstat -nt | awk '$4 ~ /:22$/ && $6 == "ESTABLISHED"' | wc -l)

if [ "${num_ssh}" -gt 0 ]; then
    echo "ssh connections: ${num_ssh}, inhibit sleep." | systemd-cat -p info
    systemd-inhibit --who="ssh-keep-awake" --what="sleep" --why="ssh connected" --mode="block" sleep 180
fi

