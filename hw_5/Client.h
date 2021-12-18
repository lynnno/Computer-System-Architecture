//
// Created by nimmus on 18.12.2021.
//

#ifndef UNTITLED2_CLIENT_H
#define UNTITLED2_CLIENT_H

#include <string>

/**
 * Клиент гостиницы.
 */
class Client {
public:
    int budget;
    explicit Client();

    /**
     * Генерация бюджета клиента.
     * @return
     */
    static int generateBudget();
};

#endif //UNTITLED2_CLIENT_H
