# We precompute that 1 has no solutios, otherwise `2` would be counted as a
# nonprimitive word, which is silly
factor_cache = {1: []}

mask_cache = {}


def get_factor_pairs(len):
    try:
        return factor_cache[len]
    except:
        factors = []

        for i in range(1, len):
            if len % i == 0:
                # Order matters here - we want to generate (4, 1) instead of
                # (1,2). The first return value is the period, while the second
                # is the number of repetitions
                factors.append((i, len // i))

        factor_cache[len] = factors
        return factors


def get_masks(len):
    try:
        return mask_cache[len]
    except:
        masks = []

        for period, repetitions in get_factor_pairs(len):
            numerator = 10 ** (period * repetitions) - 1
            denominator = 10**period - 1
            masks.append(numerator // denominator)

        mask_cache[len] = masks
        return masks


def has_property(num, str_num):
    num_len = len(str_num)
    masks = get_masks(num_len)
    for mask in masks:
        if num % mask == 0:
            return True
    return False


for num in range(1, 10000000):
    str_num = str(num)
    if has_property(num, str_num):
        print(str_num)
