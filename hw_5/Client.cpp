//
// Created by nimmus on 18.12.2021.
//

#include <random>
#include "Client.h"

Client::Client() {
    budget = generateBudget();
}

/**
 * Метод генерирует бюджет клиента. Нижний порог генерации чисел установлен ниже
 * самого дешевого номера чтобы создать ситуации, где клиент не может заплатить ни за
 * один из номеров в гостинице.
 */
int Client::generateBudget() {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> distribution(150, 700);
    return distribution(gen);
}
