## Steps to reproduce

1. `echo '/tmp/core.%t.%e.%p' | sudo tee /proc/sys/kernel/core_pattern`

   To ensure docker process could generate `core` file.
2. `docker run --rm --ulimit core=-1 --security-opt seccomp=unconfined -it -p 5000:5000 zao111222333/gtk3:debug`

   Run docker and you will enter gdb terminal. This docker image will start with a test script [entrypoint.sh](https://github.com/zao111222333/gtk3_broadwayd_debug/blob/main/entrypoint.sh), which will start a `broadwayd` process at `:0` display on `5000` port, then loop start & stop a gtk-program, until it meet any error. After testing many times I found the **core dumped** will always occur at time 21.


The dockerfile can be found at [https://github.com/zao111222333/gtk3_broadwayd_debug](https://github.com/zao111222333/gtk3_broadwayd_debug/blob/main/Dockerfile#L4-L5).

## Version information

**Have been verified:**

`gtk+-3.24.38` + `ubuntu:22.04`

`gtk+-3.24.30` + `debian:11`

## Warnings

```plaintext
/entrypoint.sh: line 28:   291 Bus error               (core dumped) /opt/gtk/bin/gtk3-icon-browser
```

Here `gtk3-icon-browser` is just one instance, I also verified with `xclock`, `gtkwave`, etc.

I found restart docker container can "refresh" this issue. I also tried to restart the `broadwayd` process but it can't help. Consequently I thought it might related to runtime memory?

## Backtrace

```plaintext
(gdb) backtrace
#0  0x00007f5794b4076f in ?? () from /lib/x86_64-linux-gnu/libpixman-1.so.0
#1  0x00007f5794acda4e in pixman_blt () from /lib/x86_64-linux-gnu/libpixman-1.so.0
#2  0x00007f57951e2e45 in ?? () from /lib/x86_64-linux-gnu/libcairo.so.2
#3  0x00007f579521c88e in ?? () from /lib/x86_64-linux-gnu/libcairo.so.2
#4  0x00007f579521cb90 in ?? () from /lib/x86_64-linux-gnu/libcairo.so.2
#5  0x00007f57951d7891 in ?? () from /lib/x86_64-linux-gnu/libcairo.so.2
#6  0x00007f5795229718 in ?? () from /lib/x86_64-linux-gnu/libcairo.so.2
#7  0x00007f57952252e6 in ?? () from /lib/x86_64-linux-gnu/libcairo.so.2
#8  0x00007f5795229718 in ?? () from /lib/x86_64-linux-gnu/libcairo.so.2
#9  0x00007f57951dfdea in ?? () from /lib/x86_64-linux-gnu/libcairo.so.2
#10 0x00007f579523741e in cairo_paint () from /lib/x86_64-linux-gnu/libcairo.so.2
#11 0x00007f5795a48ff2 in ?? () from /lib/x86_64-linux-gnu/libgdk-3.so.0
#12 0x00007f5795a49278 in gdk_window_end_draw_frame () from /lib/x86_64-linux-gnu/libgdk-3.so.0
#13 0x00007f5795eabdbc in ?? () from /lib/x86_64-linux-gnu/libgtk-3.so.0
#14 0x00007f5795d5254b in gtk_main_do_event () from /lib/x86_64-linux-gnu/libgtk-3.so.0
#15 0x00007f5795a32743 in ?? () from /lib/x86_64-linux-gnu/libgdk-3.so.0
#16 0x00007f5795a45151 in ?? () from /lib/x86_64-linux-gnu/libgdk-3.so.0
#17 0x00007f5795a4a221 in ?? () from /lib/x86_64-linux-gnu/libgdk-3.so.0
#18 0x00007f5795a4a418 in ?? () from /lib/x86_64-linux-gnu/libgdk-3.so.0
#19 0x00007f5795891700 in g_signal_emit_valist () from /lib/x86_64-linux-gnu/libgobject-2.0.so.0
#20 0x00007f5795891863 in g_signal_emit () from /lib/x86_64-linux-gnu/libgobject-2.0.so.0
#21 0x00007f5795a3fc6f in ?? () from /lib/x86_64-linux-gnu/libgdk-3.so.0
#22 0x00007f5795a2c2ad in ?? () from /lib/x86_64-linux-gnu/libgdk-3.so.0
#23 0x00007f57959152c8 in ?? () from /lib/x86_64-linux-gnu/libglib-2.0.so.0
#24 0x00007f5795914c44 in g_main_context_dispatch () from /lib/x86_64-linux-gnu/libglib-2.0.so.0
#25 0x00007f579596a258 in ?? () from /lib/x86_64-linux-gnu/libglib-2.0.so.0
#26 0x00007f57959123e3 in g_main_context_iteration () from /lib/x86_64-linux-gnu/libglib-2.0.so.0
#27 0x00007f5795766fb5 in g_application_run () from /lib/x86_64-linux-gnu/libgio-2.0.so.0
#28 0x00007f5795485d90 in ?? () from /lib/x86_64-linux-gnu/libc.so.6
#29 0x00007f5795485e40 in __libc_start_main () from /lib/x86_64-linux-gnu/libc.so.6
#30 0x000055bb68e39d75 in _start ()
```
