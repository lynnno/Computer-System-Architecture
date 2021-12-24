from enum import Enum

from Container import Container
from Car import Car
from Truck import Truck
from Bus import Bus
import sys
import random


class Vtype(Enum):
    CAR = 0
    TRUCK = 1
    BUS = 2


# Вывод при некорректном вводе аргументов из командной строки.
def incorrect_input():
    print("Incorrect input. Please, run \n"
          "\" -f <Name of the input file> <Name of the output file before sort> \""
          "<Name of the output file after Merge Sort>\n"
          "or \" -n <Number of vehicles to generate> <Name of the input file> "
          "<Name of the output file before sort> \"")


if __name__ == '__main__':
    if len(sys.argv) != 5:
        # В случае некорректного набора аргументов.
        incorrect_input()
        exit(1)

    # Инициализация нового контейнера.
    container = Container()

    # В случае, если пользователь выбрал чтение из файла.
    if sys.argv[1] == "-f":
        inputFileName = sys.argv[2]
        outputFileName = sys.argv[3]
        outputFileName2 = sys.argv[4]
        # Чтение из соответствующего файла.
        input_file = open(inputFileName)
        for line in input_file:
            data = line.strip().split(' ')
            if int(data[0]) == Vtype.CAR.value:
                container.append(Car(int(data[1]), float(data[2]), float(data[3])))
            elif int(data[0]) == Vtype.TRUCK.value:
                container.append(Bus(int(data[1]), float(data[2]), int(data[3])))
            elif int(data[0]) == Vtype.BUS.value:
                container.append(Bus(int(data[1]), float(data[2]), int(data[3])))
            else:
                # Вывод исключения в случае, если типы транспорта не указаны/указаны неверно.
                raise ValueError("Incorrect input")
        input_file.close()

    # В случае, если пользователь выбрал генерацию.
    elif sys.argv[1] == "-n":
        random_number = int(sys.argv[2])
        outputFileName = sys.argv[3]
        outputFileName2 = sys.argv[4]

        # Заполнение контейнера генерируемыми транспортными средствами.
        for i in range(random_number):
            vtype = random.randint(0, 2)
            # Заполнение полей, соответствующих любому типу (capacity, consumption).
            capacity = random.randint(100, 400)
            #  В consumption дополнительно добавляем значение от 0.0 до 1.0, тк расход топлива - действительное
            consumption = random.randint(1, 7) + random.random()
            # Заполнение индивидуальных значений, соответствующих каждому типу (speed, volume, seats).
            if int(vtype == Vtype.CAR.value):
                speed = random.randint(90, 250)
                container.append(Car(capacity, consumption, speed))
            elif int(vtype == Vtype.TRUCK.value):
                volume = random.randint(100, 2000)
                container.append(Truck(capacity, consumption, volume))
            elif int(vtype == Vtype.BUS.value):
                seats = random.randint(10, 100)
                container.append(Bus(capacity, consumption, seats))
    else:
        # В случае, если флаг не "-n" и не "-f"
        incorrect_input()
        exit()
        pass

    # Запись в первый файл.
    file = open(outputFileName, 'w')
    for vehicle in container:
        file.write(vehicle.to_string() + "\n")
    file.close()

    # Сортировка Straight Merge.
    container.index = 0
    container.sort()

    # Запись отсортированного контейнера во второй файл.
    container.index = 0
    file = open(outputFileName2, 'w')
    for vehicle in container:
        file.write(vehicle.to_string() + "\n")
    file.close()
