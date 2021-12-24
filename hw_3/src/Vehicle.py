"""
Базовый класс для транспорта
"""


class Vehicle:

    def __init__(self, capacity, consumption):
        self.capacity = capacity
        self.consumption = consumption

    # Оператор сравнения (меньше, чем).
    def __lt__(self, other):
        return self.max_distance() < other.max_distance()

    # Оператор сравнения (меньше или равно, чем).
    def __le__(self, other):
        return self.max_distance() <= other.max_distance()

    def max_distance(self):
        return round(100*(self.capacity/self.consumption), 3)

    def to_string(self):
        return " fuel tank capacity (gallons): " + str(
            self.capacity) + " fuel consumption per 100 km: " + str(self.consumption)
