#include <iostream>
#include <thread>
#include <mutex>
#include "Client.h"

// Введение цветов для визуализирования различных типов информации при выводе в консоль.
#define NC "\e[0m"
#define RED "\e[0;31m" // Неудачное оформление клиента (нет доступных номеров).
#define GRN "\e[0;32m" // Цвет типа номера (Lux, Regular, Economy).
#define CYN "\e[0;36m"

const double simulationTime = 1;  // Примерное время симуляции (в минутах).
const int stayingTime = 20; // Время пребывания клиента в гостинице.

std::mutex mutex;

// Номер Люкс стоимостью 600. По условию задачи их 5.
int luxN = 5;
// Обычный номер стоимостью 400. По условию задачи их 10.
int regN = 10;
// Номер эконом класса стоимостью 200. Их так же 10.
int ecoN = 10;


Client *currentClient;

/**
 * Проверка на количество доступных номеров Люкс.
 * @return В случае, если их недостаточно, возвращается false, иначе - true.
 */
bool enoughLuxSuites() {
    return luxN > 0;
}

/**
 * Проверка на количество доступных Обычных номеров.
 * @return В случае, если их недостаточно, возвращается false, иначе - true.
 */
bool enoughRegularSuites() {
    return regN > 0;
}
/**
 * Проверка на количество доступных номеров Эконом класса.
 * @return
 */
bool enoughEconomySuites() {
    return ecoN > 0;
}


/**
 * Обслуживание клиентов-люкс.
 * @param количество секунд, в симуляции - дней, соответствующих длительности пребывания клиента в отеле.
 */
void luxClientServise(int days) {
    printf("A " GRN "Lux" NC " suite client just checked in!\n");
    std::this_thread::sleep_for(std::chrono::seconds(days));
    luxN++;
    printf("A " GRN "Lux" NC " suite client just checked out.\n");
}

/**
 * Обслуживание обычных клиентов.
 * @param количество секунд, в симуляции - дней, соответствующих длительности пребывания клиента в отеле.
 */
void regularClientServise(int days) {
    printf("A " GRN "Regular" NC " suite client just checked in!\n");

    std::this_thread::sleep_for(std::chrono::seconds(days));
    regN++;
    printf("A " GRN "Regular" NC " suite client just checked out.\n");
}

/**
 * Обслуживание клиентов эконом класса.
 * @param количество секунд, в симуляции - дней, соответствующих длительности пребывания клиента в отеле.
 */
void economyClientServise(int days) {
    printf("An " GRN "Economy" NC " suite client just checked in!\n");

    std::this_thread::sleep_for(std::chrono::seconds(days));
    ecoN++;
    printf("An " GRN "Economy" NC " suite client just checked out.\n");
}

/**
 * Обслуживание нового клиента.
 */
void newClient() {
    currentClient = new Client();
    // Далее - распределение клиентов сообвественно их бюджету.
    if (currentClient->budget >= 600) {
        // Здесь и далее (mutex) - блокировка информации для корректной проверки доступных номеров.
        mutex.lock();
        if (!enoughLuxSuites()) {
            printf(RED "Unfortunately, all the Lux rooms were taken, a client had to leave.\n" NC);
        } else {
            luxN--;
            std::thread reception(luxClientServise, stayingTime);
            reception.detach(); // Используется Detach для дальнейшей независимой работы потока.
        }
        mutex.unlock();
    } else if (currentClient->budget >= 400) {
        mutex.lock();
        if (!enoughRegularSuites()) {
            printf(RED "Unfortunately, all the Regular rooms were taken, a client had to leave.\n" NC);

        } else {
            regN--;
            std::thread reception(regularClientServise, stayingTime);
            reception.detach();
        }
        mutex.unlock();
    } else if (currentClient->budget >= 200) {
        mutex.lock();
        if (!enoughEconomySuites()) {
            printf(RED "Unfortunately, all Economy rooms were taken, a client had to leave.\n" NC);
        } else {
            ecoN--;
            std::thread reception(economyClientServise, stayingTime);
            reception.detach();
        }
        mutex.unlock();
    } else {
        printf(RED "Unfortunately, a client could not afford a suite and had to leave.\n" NC);
    }
}

int main() {

    printf(CYN " * A NEW HOTEL JUST OPENED! *\n" NC);

    for (int i = 0; i < simulationTime*60; i++) {
        /*
        Между клиентами есть небольшая пауза - 1 секунда - для
        более наглядного демонстрирования работы симуляции.
        */
        std::this_thread::sleep_for(std::chrono::seconds(1));
        newClient();
    }
    //std::this_thread::sleep_for(std::chrono::seconds(10));
    return 0;
}
