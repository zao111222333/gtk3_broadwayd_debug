#! /bin/bash
export GDK_BACKEND=broadway
/opt/gtk/bin/broadwayd -p 5000&
set_time=1
i=1
while true
do  
    set_time=0.5
    echo ""
    echo "-----------------------"
    echo "TIME $i"
    sleep $set_time
    /opt/gtk/bin/gtk3-icon-browser &
    sleep $set_time
    PID=$!
    PID_EXIST=$(ps aux | awk '{print $2}'| grep -w $PID)
    if [ ! $PID_EXIST ];then
        echo ""
        echo "The process $PID is not exist, it should core dumped at TIME21"
        echo "Break to bash"
        echo ""
        break
    else
        kill -9 $PID
    fi
    let i+=1
done
/bin/bash
# gdb /opt/gtkwave/bin/gtkwave.origin core
# coredumpctl gdb $PID
# coredumpctl -o gtkwave.coredump dump /opt/gtkwave/bin/gtkwave.origin