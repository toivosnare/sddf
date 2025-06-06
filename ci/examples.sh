#!/bin/bash

# Copyright 2024, UNSW
#
# SPDX-License-Identifier: BSD-2-Clause

set -e

SDK_PATH=$1
SDDF=$(pwd)

# Number of threads/jobs to compile with, default to 1
if [ "$#" -eq 1 ]; then
NUM_JOBS=1
else
NUM_JOBS=$2
fi

CI_BUILD_DIR="ci_build"

export ZIG_LOCAL_CACHE_DIR="${CI_BUILD_DIR}/zig-cache"
export ZIG_GLOBAL_CACHE_DIR="${CI_BUILD_DIR}/zig-cache"

[[ -z $SDK_PATH ]] && echo "usage: examples.sh [PATH TO SDK]" && exit 1
[[ ! -d $SDK_PATH ]] && echo "The path to the SDK provided does not exist: '$SDK_PATH'" && exit 1

NETWORK=true
I2C=true
SERIAL=true
TIMER=true
BLK=true
GPU=true

build_network_echo_server_make() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building echo server example with Make, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/echo_server/make/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    make -j${NUM_JOBS} -C ${SDDF}/examples/echo_server \
        BUILD_DIR=${BUILD_DIR} \
        MICROKIT_CONFIG=${CONFIG} \
        MICROKIT_SDK=${SDK_PATH} \
        MICROKIT_BOARD=${BOARD}
}

build_i2c_make() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building I2C example with Make, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/i2c/make/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    make -j${NUM_JOBS} -C ${SDDF}/examples/i2c \
        BUILD_DIR=${BUILD_DIR} \
        MICROKIT_CONFIG=${CONFIG} \
        MICROKIT_SDK=${SDK_PATH} \
        MICROKIT_BOARD=${BOARD}
}

build_i2c_zig() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building I2C example with Zig, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/i2c/zig/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    pushd ${SDDF}/examples/i2c
    zig build -Dsdk=${SDK_PATH} -Dboard=${BOARD} -Dconfig=${CONFIG} -p ${BUILD_DIR}
    popd
}

build_timer_make() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building timer example with Make, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/timer/make/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    make -j${NUM_JOBS} -C ${SDDF}/examples/timer \
        BUILD_DIR=${BUILD_DIR} \
        MICROKIT_CONFIG=${CONFIG} \
        MICROKIT_SDK=${SDK_PATH} \
        MICROKIT_BOARD=${BOARD}
}

build_timer_zig() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building timer example with Zig, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/timer/zig/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    pushd ${SDDF}/examples/timer
    zig build -Dsdk=${SDK_PATH} -Dboard=${BOARD} -Dconfig=${CONFIG} -p ${BUILD_DIR}
    popd
}

build_serial_make() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building serial example with Make, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/serial/make/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    make -j${NUM_JOBS} -C ${SDDF}/examples/serial \
        BUILD_DIR=${BUILD_DIR} \
        MICROKIT_CONFIG=${CONFIG} \
        MICROKIT_SDK=${SDK_PATH} \
        MICROKIT_BOARD=${BOARD}
}

build_serial_zig() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building serial example with Zig, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/serial/zig/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    pushd ${SDDF}/examples/serial
    zig build -Dsdk=${SDK_PATH} -Dboard=${BOARD} -Dconfig=${CONFIG} -p ${BUILD_DIR}
    popd
}

build_blk_make() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building blk example with Make, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/blk/make/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    make -j${NUM_JOBS} -C ${SDDF}/examples/blk \
        BUILD_DIR=${BUILD_DIR} \
        MICROKIT_CONFIG=${CONFIG} \
        MICROKIT_SDK=${SDK_PATH} \
        MICROKIT_BOARD=${BOARD}
}

build_blk_zig() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building blk example with Zig, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/blk/zig/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    pushd ${SDDF}/examples/blk
    zig build -Dsdk=${SDK_PATH} -Dboard=${BOARD} -Dconfig=${CONFIG} -p ${BUILD_DIR}
    popd
}

build_gpu_make() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building gpu example with Make, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/gpu/make/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    make -j${NUM_JOBS} -C ${SDDF}/examples/gpu \
        BUILD_DIR=${BUILD_DIR} \
        MICROKIT_CONFIG=${CONFIG} \
        MICROKIT_SDK=${SDK_PATH} \
        MICROKIT_BOARD=${BOARD}
}

build_gpu_zig() {
    BOARD=$1
    CONFIG=$2
    echo "CI|INFO: building gpu example with Zig, board: ${BOARD}, config: ${CONFIG}"
    BUILD_DIR="${PWD}/${CI_BUILD_DIR}/examples/gpu/zig/${BOARD}/${CONFIG}"
    rm -rf ${BUILD_DIR}
    pushd ${SDDF}/examples/gpu
    zig build -Dsdk=${SDK_PATH} -Dboard=${BOARD} -Dconfig=${CONFIG} -p ${BUILD_DIR}
    popd
}

network() {
    BOARDS=("qemu_virt_riscv64" "imx8mm_evk" "imx8mp_evk" "imx8mq_evk" "maaxboard" "odroidc2" "odroidc4" "qemu_virt_aarch64")
    CONFIGS=("debug" "release" "benchmark")
    for BOARD in "${BOARDS[@]}"
    do
      for CONFIG in "${CONFIGS[@]}"
      do
         build_network_echo_server_make ${BOARD} ${CONFIG}
       done
    done
}

i2c() {
    BOARDS=("odroidc4")
    CONFIGS=("debug" "release")
    for BOARD in "${BOARDS[@]}"
    do
      for CONFIG in "${CONFIGS[@]}"
      do
         build_i2c_make ${BOARD} ${CONFIG}
         build_i2c_zig ${BOARD} ${CONFIG}
       done
    done
}

timer() {
    BOARDS=("imx8mm_evk" "imx8mp_evk" "imx8mq_evk" "maaxboard" "odroidc2" "odroidc4" "qemu_virt_aarch64" "qemu_virt_riscv64" "star64")
    CONFIGS=("debug" "release")
    for BOARD in "${BOARDS[@]}"
    do
      for CONFIG in "${CONFIGS[@]}"
      do
         build_timer_make ${BOARD} ${CONFIG}
         build_timer_zig ${BOARD} ${CONFIG}
       done
    done
}

serial() {
    BOARDS=("imx8mm_evk" "imx8mq_evk" "imx8mp_evk" "maaxboard" "odroidc2" "odroidc4" "qemu_virt_aarch64" "qemu_virt_riscv64" "star64")
    CONFIGS=("debug" "release")
    for BOARD in "${BOARDS[@]}"
    do
      for CONFIG in "${CONFIGS[@]}"
      do
         build_serial_make ${BOARD} ${CONFIG}
         build_serial_zig ${BOARD} ${CONFIG}
       done
    done
}

blk() {
    BOARDS=("qemu_virt_aarch64" "qemu_virt_riscv64" "maaxboard")
    CONFIGS=("debug" "release")
    for BOARD in "${BOARDS[@]}"
    do
        for CONFIG in "${CONFIGS[@]}"
        do
            build_blk_make ${BOARD} ${CONFIG}
            build_blk_zig ${BOARD} ${CONFIG}
        done
    done
}

gpu() {
    BOARDS=("qemu_virt_aarch64")
    CONFIGS=("debug" "release")
    for BOARD in "${BOARDS[@]}"
    do
        for CONFIG in "${CONFIGS[@]}"
        do
            build_gpu_make ${BOARD} ${CONFIG}
            build_gpu_zig ${BOARD} ${CONFIG}
        done
    done
}

# Only run the examples that have been enabled
$NETWORK && network
$I2C && i2c
$TIMER && timer
$SERIAL && serial
$BLK && blk
$GPU && gpu

echo ""
echo "CI|INFO: Passed all sDDF tests"
