from Vehicle import Vehicle

"""
Класс легкового автомобиля (Car).
"""


class Car(Vehicle):
    def __init__(self, capacity, consumption, speed):
        super().__init__(capacity, consumption)
        self.speed = speed

    def to_string(self):
        return f"Car: fuel tank capacity = {self.capacity}, fuel consumption per 100 km = {self.consumption}, " \
               f"max speed = {self.speed}. " \
               f"Maximum distance = {round(self.max_distance(), 4)};\n"
