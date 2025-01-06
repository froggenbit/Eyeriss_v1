# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import numpy as np
def conv_model(oc, ocb, ic, icb, filter_height, filter_width, ifm_height, ifm_width, filter, ifmap):
    # Calculate expected convolution result.
    ofm_width = ifm_width - filter_width + 1
    ofm_height = ifm_height - filter_height + 1
    out_sum = np.zeros((oc * ocb, ofm_height, ofm_width))
    # 对每个输出通道进行卷积计算
    # for i in range(oc * ocb):
    #     for j in range(ofm_height):
    #         for k in range(ofm_width):
    #             # 取出输入的子区域（即卷积的局部区域）
    #             region = ifmap[:, j:j+filter_height, k:k+filter_width]
    #             # 使用numpy的广播机制来执行点乘并求和
    #             partial_sum = np.sum(region * filter[i])
    #             # 存储结果
    #             out_sum[i, j, k] = partial_sum
    for i in range(oc * ocb):  # 输出通道
        for j in range(ofm_height):  # 输出高度
            for k in range(ofm_width):  # 输出宽度
                # 初始化sum变量
                sum = 0
                for d in range(ic * icb):  # 输入通道
                    for e in range(filter_height):  # 卷积核高度
                        for f in range(filter_width):  # 卷积核宽度
                            # 使用索引来模拟Verilog中计算的过程
                            # 注意e-j和f-k部分在Python中是没有意义的，只是为了模仿Verilog
                            sum += ifmap[d, j + e, k + f] * filter[i, d, e, f]
                            # if i == 2 and j == 0 and k == 0:
                            #    print(f"Multiplying ifmap[{d}, {j + e}, {k + f}] * filter[{i}, {d}, {e}, {f}]")
                            #    print(f"Value of ifmap: {ifmap[d, j + e, k + f]}, Value of filter: {filter[i, d, e, f]}")
                            #    print(f"adder is : {ifmap[d, j + e, k + f] * filter[i, d, e, f]}")
                            #    print(f"sum is : {sum}")
                            sum = sum & 0xFFFF
                # 将计算结果存入out_sum
                out_sum[i, j, k] = sum

    # out_sum = [[[0 for _ in range(ofm_width)] for _ in range(ofm_height)] for _ in range(oc * ocb)]
    # for i in range(oc * ocb):  # Output channels
    #     for j in range(ifm_height - filter_height + 1):  # Output height
    #         for k in range(ifm_width - filter_width + 1):  # Output width
    #             sum = 0
    #             for d in range(ic * icb):  # Input channels
    #                 for e in range(filter_height):  # Kernel height
    #                     for f in range(filter_width):  # Kernel width
    #                         partial_sum = ifmap[d][j + e][k + f] * filter[i][d][e][f]
    #                         if i == 2 and j == 0 and k == 0:  # 仅打印 out_sum[2][0][0]
    #                             print(f"Accumulating for out_sum[2][0][0]: "
    #                                  f"ifmap[{d}][{j + e}][{k + f}] = {ifmap[d][j + e][k + f]} * "
    #                                  f"filter[{i}][{d}][{e}][{f}] = {filter[i][d][e][f]} -> "
    #                                  f"partial_sum = {partial_sum}")
    #                             # print(f"Accumulating for out_sum[2][0][0]: "
    #                             #       f"ifmap[{d}][{j + e}][{k + f}] * filter[{i}][{d}][{e}][{f}] = {partial_sum}")
    #                         sum += partial_sum
    #                         # sum += ifmap[d][j + e][k + f] * filter[i][d][e][f]
    #             out_sum[i][j][k] = sum
    return out_sum
