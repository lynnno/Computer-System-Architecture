"""
Класс контейнера для сортировки и хранения транспорта.
"""


class Container:

    def __init__(self):
        self.data = []
        self.index = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.index < len(self.data):
            self.index += 1
            return self.data[self.index - 1]
        else:
            raise StopIteration

    def size(self):
        return len(self.data)

# Добавление элементов в контейнер.
    def append(self, vehicle):
        self.data.append(vehicle)

    def sort(self):
        self.data = merge_sort(self.data)


def merge_sort(lst):
    if len(lst) <= 1:
        return lst
    middle = len(lst) // 2
    left = lst[:middle]
    right = lst[middle:]
    s_left = merge_sort(left)
    s_right = merge_sort(right)
    return merge(s_left, s_right)


# Слияние двух массивов.
def merge(left, right):
    result = []
    while left and right:
        if left[0] < right[0]:
            result.append(left[0])
            left.pop(0)
        else:
            result.append(right[0])
            right.pop(0)
    if left:
        result += left
    if right:
        result += right
    return result
