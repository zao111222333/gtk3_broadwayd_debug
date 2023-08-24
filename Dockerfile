# echo '/tmp/core.%t.%e.%p' | sudo tee /proc/sys/kernel/core_pattern
# docker build --network host -t zao111222333/gtk3:debug -f Dockerfile .
# docker run --rm --ulimit core=-1 --security-opt seccomp=unconfined -it -p 5000:5000 zao111222333/gtk3:debug
# docker push zao111222333/gtk3:debug

# =============== BUILD =================
FROM ubuntu:22.04 AS base
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN apt-get update -y && apt-get upgrade -y

FROM base as build
RUN apt-get install -y --no-install-recommends \
    git\
    wget\
    build-essential \
    autoconf \
    autotools-dev \
    pkg-config \
    automake \
    tcl-dev \
    tk-dev \
    gperf \
    libbz2-dev\
    liblzma-dev\
    libgtk-3-dev\
    gtk-doc-tools\
    gnome-common\
    intltool\
    valac\
    libglib2.0-dev\
    gobject-introspection\
    libgirepository1.0-dev\
    libclutter-gtk-1.0-dev\
    libgnome-desktop-3-dev\
    libcanberra-dev\
    libgdata-dev\
    libdbus-glib-1-dev\
    libgstreamer1.0-dev\
    libupower-glib-dev\
    fonts-droid-fallback\
    libatk1.0-dev\
    cmake\
    python3-pip\
    python3-docutils\
    sassc\
    libgstreamer-plugins-bad1.0-dev
RUN pip3 install meson ninja
WORKDIR /Dependencies

# https://download.gnome.org/sources/atk/2.38
RUN wget https://download.gnome.org/sources/atk/2.38/atk-2.38.0.tar.xz\
 && tar -xf atk-*.tar.xz\
 && cd atk-*\
 && mkdir build && cd build\
 && meson --prefix=/usr --buildtype=release ..\
 && ninja\
 && ninja install
# https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html
RUN wget https://download.gnome.org/sources/glib/2.76/glib-2.76.4.tar.xz\
 && tar -xf glib-*.tar.xz\
 && cd glib-*\
 && mkdir build && cd build\
 && meson --prefix=/usr --buildtype=release -Dman=true ..\
 && ninja\
 && ninja install
# https://www.linuxfromscratch.org/blfs/view/svn/x/at-spi2-core.html
RUN wget https://download.gnome.org/sources/at-spi2-core/2.48/at-spi2-core-2.48.3.tar.xz\
 && tar -xf at-spi2-core-*.tar.xz\
 && cd at-spi2-core-*\
 && mkdir build && cd build\
 && meson --prefix=/usr --buildtype=release ..\
 && ninja\
 && ninja install
# https://www.linuxfromscratch.org/blfs/view/cvs/x/at-spi2-atk.html
RUN wget https://download.gnome.org/sources/at-spi2-atk/2.38/at-spi2-atk-2.38.0.tar.xz\
 && tar -xf at-spi2-atk-*.tar.xz\
 && cd at-spi2-atk-*\
 && mkdir build && cd build\
 && meson --prefix=/usr --buildtype=release ..\
 && ninja\
 && ninja install
# https://www.linuxfromscratch.org/blfs/view/svn/x/gdk-pixbuf.html
RUN wget https://download.gnome.org/sources/gdk-pixbuf/2.42/gdk-pixbuf-2.42.10.tar.xz\
 && tar -xf gdk-pixbuf-*.tar.xz\
 && cd gdk-pixbuf-*\
 && mkdir build && cd build\
 && meson --prefix=/usr --buildtype=release --wrap-mode=nofallback ..\
 && ninja\
 && ninja install
# https://www.linuxfromscratch.org/blfs/view/svn/x/libepoxy.html
RUN wget https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.10.tar.xz\
 && tar -xf libepoxy-*.tar.xz\
 && cd libepoxy-*\
 && mkdir build && cd build\
 && meson --prefix=/usr --buildtype=release ..\
 && ninja\
 && ninja install
# https://www.linuxfromscratch.org/blfs/view/svn/x/pango.html
RUN wget https://download.gnome.org/sources/pango/1.50/pango-1.50.14.tar.xz\
 && tar -xf pango-*.tar.xz\
 && cd pango-*\
 && mkdir build && cd build\
 && meson --prefix=/usr --buildtype=release --wrap-mode=nofallback ..\
 && ninja\
 && ninja install
# http://sources.buildroot.net/tiff/tiff-4.1.0.tar.gz
RUN wget http://sources.buildroot.net/tiff/tiff-4.5.1.tar.gz\
 && tar -xzf tiff-*.tar.gz\
 && cd tiff-*\
 && ./configure\
 && make\
 && make install
# http://sources.buildroot.net/libjpeg/jpegsrc.v9e.tar.gz
RUN wget http://sources.buildroot.net/libjpeg/jpegsrc.v9e.tar.gz\
 && tar -xzf jpegsrc.v*.tar.gz\
 && cd jpeg-*\
 && ./configure\
 && make\
 && make install
# https://github.com/ebassi/graphene
RUN wget https://github.com/ebassi/graphene/archive/refs/tags/1.10.8.tar.gz\
 && tar -xzf 1.10.8.tar.gz\
 && cd graphene-*\
 && mkdir build && cd build\
 && meson --prefix=/usr --buildtype=release ..\
 && ninja\
 && ninja install
# https://download.gnome.org/sources/gtk+/3.24/
RUN wget https://download.gnome.org/sources/gtk+/3.24/gtk+-3.24.38.tar.xz\
 && tar xf gtk+-*.tar.xz\
 && cd gtk+-*\
 && mkdir build && cd build\
 && meson --prefix=/opt/gtk/ --sysconfdir=/etc -Dbroadway_backend=true -Dx11_backend=false -Dwayland_backend=false ..\
 && ninja\
 && ninja install

# =============== RUN =================
FROM base as run
RUN apt-get install -y --no-install-recommends \
    libglib2.0-0\
    libgtk-3-0\
    tk
COPY --from=build /opt/gtk/ /opt/gtk/
COPY --from=build /etc/gtk* /etc/
EXPOSE 5000

# FOR DEBUG
RUN apt-get install -y --no-install-recommends \
    gdb\
    systemd-coredump\
    procps
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]