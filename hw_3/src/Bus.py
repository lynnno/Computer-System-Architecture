from Vehicle import Vehicle
"""
Класс автобуса (Bus).
"""


class Bus(Vehicle):
    def __init__(self, capacity, consumption, seats):
        super().__init__(capacity, consumption)
        self.seats = seats

    def to_string(self):
        return f"Bus: fuel tank capacity = {self.capacity}, fuel consumption per 100 km = {self.consumption}, " \
               f"passenger intake = {self.seats}. " \
               f"Maximum distance = {round(self.max_distance(), 4)};\n"
