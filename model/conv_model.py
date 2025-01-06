import numpy as np
def conv_model(oc, ocb, ic, icb, filter_height, filter_width, ifm_height, ifm_width, filter, ifmap):
    ofm_width = ifm_width - filter_width + 1
    ofm_height = ifm_height - filter_height + 1
    out_sum = np.zeros((oc * ocb, ofm_height, ofm_width))
    for i in range(oc * ocb):
        for j in range(ofm_height):
            for k in range(ofm_width):
                sum = 0
                for d in range(ic * icb):
                    for e in range(filter_height):
                        for f in range(filter_width):
                            sum += ifmap[d, j + e, k + f] * filter[i, d, e, f]
                            # for debug
                            # if i == 2 and j == 0 and k == 0:
                            #    print(f"Multiplying ifmap[{d}, {j + e}, {k + f}] * filter[{i}, {d}, {e}, {f}]")
                            #    print(f"Value of ifmap: {ifmap[d, j + e, k + f]}, Value of filter: {filter[i, d, e, f]}")
                            #    print(f"adder is : {ifmap[d, j + e, k + f] * filter[i, d, e, f]}")
                            #    print(f"sum is : {sum}")
                            # psum is 16b in RTL
                            sum = sum & 0xFFFF
                out_sum[i, j, k] = sum

    return out_sum
