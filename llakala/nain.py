cache = {}


# Same process as getting the factors of a number, but for a length N, we
# don't include 1, and do include N. Splitting `123456` once to get
# `123456` is useless - but splitting it six times to get `1,2,3,4,5,6` is
# useful
def get_all_partitions(len):
    try:
        return cache[len]
    except:
        factors = []

        for factor in range(2, len + 1):
            if len % factor == 0:
                factors.append(factor)

        cache[len] = factors
        return factors


def check_split(split, str_num, num_len):
    split_width = num_len // split
    previous = None

    for i in range(0, num_len, split_width):
        current = str_num[i : i + split_width]

        if current != previous and previous != None:
            return False

        previous = current

    return True


def has_property(str_num):
    num_len = len(str_num)

    # these are the number of times we can evenly split the number
    # 2 splits = split `123456` to be `[123, 456]`
    valid_splits = get_all_partitions(num_len)

    for split in valid_splits:
        if check_split(split, str_num, num_len) == True:
            return True

    return False


for num in range(1, 1000000000):
    str_num = str(num)
    if has_property(str_num):
        print(str_num)
