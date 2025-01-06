import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.runner import get_runner
from conv_model import conv_model

import random
import numpy as np


@cocotb.test()
async def test_pe_array(dut):
    """Cocotb test for pe_array."""

    # Parameters
    oc = 3
    ocb = 2
    ic = 2
    icb = 2
    filter_width = 3
    filter_height = 3
    ifm_height = 5
    ifm_width = 5

    ofm_width = ifm_width - filter_width + 1
    ofm_height = ifm_height - filter_height + 1
    # Generate clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.S.value = filter_width
    dut.R.value = filter_height
    dut.p.value = oc
    dut.q.value = ic
    dut.r.value = icb
    dut.t.value = ocb
    dut.H.value = ifm_height
    dut.W.value = ifm_width
    dut.alarm.value = 0

    # Initialize random filter and ifmap
    # random.seed(666)
    filter = np.zeros((oc*ocb, ic*icb, filter_height, filter_width), dtype=int)
    ifmap  = np.zeros((ic*icb, ifm_height, ifm_width), dtype=int)
    count = 0
    for oc_idx in range(oc*ocb):
        for ic_idx in range(ic*icb):
            for h in range(filter_height):
                for w in range(filter_width):
                    # filter[oc_idx, ic_idx, h, w] = count
                    filter[oc_idx, ic_idx, h, w] = random.randint(0,65535)
                    count += 1
    count = 0
    for ic_idx in range(ic*icb):
        for h in range(ifm_height):
            for w in range(ifm_width):
                # ifmap[ic_idx, h, w] = count
                ifmap[ic_idx, h, w] = random.randint(0,65535)
                count += 1
    # 打印结果
    # print("filter:")
    # print(filter)
    # print("ifmap:")
    # print(ifmap)

    # Load filter into the DUT, instead of read DMA
    for i in range(oc * ocb):
        for j in range(ic * icb):
            for k in range(filter_height):
                for l in range(filter_width):
                    idx = i * (ic * icb * filter_height * filter_width) + j * (filter_height * filter_width) + k * filter_width + l
                    dut.ld_filter.filter[idx].value = int(filter[i,j,k,l])
                    # if (i == 2 and j == 0 and k < 3 and l < 3) :
                    #     print(f"filter[{i}][{j}][{k}][{l}] is {filter[i,j,k,l]}")

    # Load ifmap into the DUT
    for i in range(ic * icb):
        for j in range(ifm_height):
            for k in range(ifm_width):
                idx = i * (ifm_height * ifm_width) + j * ifm_width + k
                dut.ld_feature.ifmap[idx].value = int(ifmap[i,j,k])
                # if (j < 6 and k < 3) :
                #     print(f"ifmap[{i}][{j}][{k}] is {ifmap[i][j][k]}")

    # start computation
    await FallingEdge(dut.clk)
    dut.alarm.value = 1
    # dut.alarm.value = 0

    # Wait for computation to complete
    await cocotb.triggers.Timer(3400, units="ns")

    # Calculate expected result
    ref = conv_model(oc, ocb, ic, icb, filter_height, filter_width, ifm_height, ifm_width, filter, ifmap)

    # Verify results
    test_failed = False
    print(f"out_psum length: {len(dut.out_psum)}")

    # 尝试访问某些扁平化索引
    # for i in range(11):  # 假设前10个元素存在
    #     print(f"out_psum[{i}] = {dut.out_psum[i].value}")
    for i in range(oc * ocb):
        for j in range (ofm_height):
            for k in range (ofm_width):
                # RTL shift register output p2 as oc_0, p1 as oc_1, p0 as oc_2
                d = (i // oc) * oc * ocb
                oc_index = d + oc - 1 - i
                flat_index = oc_index * 101 + (j * ofm_width + k)
                # dut_value = int(dut.out_psum[oc_index][j * (ofm_width) + k].value)
                dut_value = int(dut.out_psum[flat_index].value)
                # print(f"out_psum[{flat_index}[{oc_index}][{j*ofm_width+k}]] = {dut.out_psum[flat_index].value}")
                if dut_value != int(ref[i,j,k]):
                    test_failed = True
                    dut._log.error(
                        f"FAIL: ref[{i}][{j}][{k}] = {int(ref[i,j,k])}, "
                        f"DUT:out_psum[{oc_index}][{j*ofm_width+k}] = {dut_value}"
                    )
                # else:
                #     dut._log.info(
                #         f"PASS: ref[{i}][{j}][{k}] = {int(ref[i,j,k])}, "
                #         f"DUT:out_psum[{oc_index}][{j*ofm_width+k}] = {dut_value}"
                #     )

    if not test_failed:
        dut._log.info("ALL Values Match !!!")
