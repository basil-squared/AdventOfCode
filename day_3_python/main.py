from pathlib import Path

NUM_DIGITS_TO_COLLECT = 12


file_location = Path("./inputdata.txt")
file_content = file_location.read_text()
split_content = file_content.splitlines()


def find_best_subsequence(digits, k):
    """
    Finds the largest number that can be formed by picking k digits from the list
    in the order they appear.
    """
    if k == 0 or not digits:
        return ""

    # If a line has fewer digits than we need to collect, use all of them.
    actual_k = min(k, len(digits))

    def _find_recursive(d, num_to_pick):
        if num_to_pick == 0:
            return ""

        # We must leave at least num_to_pick - 1 digits for the rest.
        limit = len(d) - num_to_pick + 1

        best_digit_val = -1
        best_digit_idx = -1

        for i in range(limit):
            digit_val = int(d[i])
            if digit_val > best_digit_val:
                best_digit_val = digit_val
                best_digit_idx = i
                # Optimization: if we find a 9, we can't do better for this position.
                if best_digit_val == 9:
                    break

        if best_digit_idx == -1:
            # This should not be reached if digits are available and k > 0
            return ""

        return str(best_digit_val) + _find_recursive(
            d[best_digit_idx + 1 :], num_to_pick - 1
        )

    return _find_recursive(digits, actual_k)


tot = 0
for line in split_content:
    digits = [char for char in line if char.isdigit()]

    if not digits:
        continue

    if NUM_DIGITS_TO_COLLECT == 2 and len(digits) == 1:
        val_str = digits[0] + digits[0]
    else:
        val_str = find_best_subsequence(digits, NUM_DIGITS_TO_COLLECT)

    if val_str:
        tot += int(val_str)


print(tot)
