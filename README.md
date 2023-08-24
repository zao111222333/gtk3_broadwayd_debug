# gtk3_broadwayd_debug

`broadwayd` will gose wrong in docker, which is indicated by a **core dumped** error at exactly 21st execution of any gtk-program. Restarting `broadwayd` process can not help.

## How to reproduce

In any `amd64` computer with `docker`, run `docker run --rm -it -p 5000:5000 zao111222333/gtk3:debug`. 

After testing many times I found the **core dumped** will always occur at time 21, the terminal output is as following.

This docker image will start with a test script [entrypoint.sh](https://github.com/zao111222333/gtk3_broadwayd_debug/blob/main/entrypoint.sh), which will start a `broadwayd` process at `:0` display on `5000` port, then loop start & stop a gtk-program (`gtk3-icon-browser` in this case, can modify at [here](https://github.com/zao111222333/gtk3_broadwayd_debug/blob/main/entrypoint.sh#L13)), until it meet any error. See more at https://github.com/zao111222333/gtk3_broadwayd_debug.

``` shell
$ docker run --rm -it -p 5000:5000 zao111222333/gtk3:debug
-----------------------
TIME 1
Listening on /root/.cache/broadway1.socket

(gtk3-icon-browser:10): Gtk-WARNING **: 19:30:25.379: Could not load a pixbuf from /org/gtk/libgtk/theme/Adwaita/assets/bullet-symbolic.svg.
This may indicate that pixbuf loaders or the mime database could not be found.

.
.
.

-----------------------
TIME 20
/entrypoint.sh: line 27:   262 Killed                  /opt/gtk/bin/gtk3-icon-browser

(gtk3-icon-browser:276): Gtk-WARNING **: 19:30:44.574: Could not load a pixbuf from /org/gtk/libgtk/theme/Adwaita/assets/bullet-symbolic.svg.
This may indicate that pixbuf loaders or the mime database could not be found.

-----------------------
TIME 21
/entrypoint.sh: line 27:   276 Killed                  /opt/gtk/bin/gtk3-icon-browser

(gtk3-icon-browser:290): Gtk-WARNING **: 19:30:45.586: Could not load a pixbuf from /org/gtk/libgtk/theme/Adwaita/assets/bullet-symbolic.svg.
This may indicate that pixbuf loaders or the mime database could not be found.
/entrypoint.sh: line 27:   290 Bus error               (core dumped) /opt/gtk/bin/gtk3-icon-browser

The process 290 is not exist, it should core dumped at TIME21
Break to bash

root@1b0a8c4bda6d:/# 
```
