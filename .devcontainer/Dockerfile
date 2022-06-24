FROM mcr.microsoft.com/vscode/devcontainers/cpp:0-ubuntu-22.04

RUN apt-get --yes update && apt-get --yes install libpcre3-dev && \
    cd /root && \
    git clone https://github.com/danmar/cppcheck.git && \
    cd cppcheck && \
    git reset --hard 57f5b19b343a2921abe80e0060d71a30246b7bde && \
    cmake -S . -B build -DHAVE_RULES=true -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --target install

RUN apt-get update --yes && apt-get --yes install pkg-config && \
    source="https://www.segger.com/downloads/jlink/JLink_Linux_V756_x86_64.deb" && \
    curl -o /root/jlink.deb -d accept_license_agreement=accepted -d non_emb_ctr=confirmed $source && \
    dpkg -i /root/jlink.deb && \
    rm /root/jlink.deb

RUN apt-get update --yes && apt-get --yes install gcc-arm-none-eabi gdb-multiarch ninja-build libncurses5 gcovr astyle \
    clang-tools-14 python-is-python3 clangd-14 clang-format-14 lld gcc-multilib g++-multilib && \
    ln -s /usr/bin/clang-format-14 /usr/bin/clang-format && \
    ln -s /usr/bin/clangd-14 /usr/bin/clangd
