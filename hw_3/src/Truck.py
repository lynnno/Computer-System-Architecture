from Vehicle import Vehicle
"""
Класс грузовика (Truck)
"""


class Truck(Vehicle):
    def __init__(self, capacity, consumption, volume):
        super().__init__(capacity, consumption)
        self.volume = volume

    def to_string(self):
        return f"Truck: fuel tank capacity = {self.capacity}, fuel consumption per 100 km = {self.consumption}, " \
               f"volume = {self.volume}. " \
               f"Maximum distance = {round(self.max_distance(), 4)};\n"
