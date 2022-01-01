FROM archlinux

ARG VERSION=0.9.0
ARG TARGETOS=linux
ARG TARGETARCH=x86_64
RUN curl https://ziglang.org/download/$VERSION/zig-$TARGETOS-$TARGETARCH-$VERSION.tar.xz > zig.tar.xz && \
    tar xf zig.tar.xz && \
    rm zig.tar.xz && \
    mv zig-$TARGETOS-$TARGETARCH-$VERSION zig && \
    mv zig/* /usr/local/bin/ && \
    rm -rf zig