#include <iostream> // For input/output operations (cin, cout)
#include <cctype>   // For tolower() character conversion

// Function Prototypes
void displayRules();
int generatePredictableNumber(int min, int max); // Replaces random number generation
double placeBet(double& playerMoney);
void getPlayerGuess(int& guess, int minGuess, int maxGuess);
void checkGuess(int winningNumber, int playerGuess, double* playerMoney, double betAmount);
// clearInputBuffer() function and its calls are removed

// Global variable for predictable "random" number generation
// In a real scenario, this would be a static variable within the function or a class member.
// Using global for simplicity given the "basic C++" constraint.
int predictableSeed = 0;

int main() {
    // No srand(time(0)); - predictability is intentional now.

    double playerMoney = 1000.0;
    char playAgain;
    const int MIN_NUMBER = 1;
    const int MAX_NUMBER = 10;
    // LUCKY_NUM_COUNT and playerLuckyNumbers array removed

    std::cout << "Welcome to the C++ Number Guessing Casino!" << std::endl;

    // Call to getLuckyNumbers() removed here

    displayRules();

    do {
        std::cout << "\n----------------------------------------" << std::endl;
        std::cout << "Your current money: $" << playerMoney << std::endl;

        if (playerMoney <= 0) {
            std::cout << "You've run out of money! Game Over." << std::endl;
            break;
        }

        double currentBet = placeBet(playerMoney);

        if (currentBet == 0) {
            std::cout << "Thanks for playing! You leave with $" << playerMoney << std::endl;
            break;
        }

        int playerGuess;
        getPlayerGuess(playerGuess, MIN_NUMBER, MAX_NUMBER);

        // Uses the predictable number generator
        int winningNumber = generatePredictableNumber(MIN_NUMBER, MAX_NUMBER);

        std::cout << "\nSpinning the wheel... The winning number is: " << winningNumber << "!" << std::endl;

        checkGuess(winningNumber, playerGuess, &playerMoney, currentBet);

        if (playerMoney > 0) {
            std::cout << "Do you want to play again? (y/n): ";
            std::cin >> playAgain;
            // No clearInputBuffer() here. Be aware of potential input issues!
            playAgain = tolower(playAgain);
        } else {
            playAgain = 'n';
        }

    } while (playerMoney > 0 && playAgain == 'y');

    std::cout << "\nThank you for playing the Casino Number Guessing Game!" << std::endl;
    std::cout << "Final money: $" << playerMoney << std::endl;

    return 0;
}

// Function Definitions

void displayRules() {
    std::cout << "\n-------------------- Game Rules --------------------" << std::endl;
    std::cout << "1. You start with $1000." << std::endl;
    std::cout << "2. Guess a number between 1 and 10." << std::endl;
    std::cout << "3. Place a bet on your guess." << std::endl;
    std::cout << "4. If your guess is correct, you win 10 times your bet!" << std::endl;
    std::cout << "5. If your guess is off by 1, you win 2 times your bet!" << std::endl;
    std::cout << "6. Otherwise, you lose your bet." << std::endl;
    std::cout << "7. You can quit at any time by entering '0' for your bet." << std::endl;
    std::cout << "----------------------------------------------------" << std::endl;
}

// Predictable "random" number generator
int generatePredictableNumber(int min, int max) {
    predictableSeed = (predictableSeed + 1) % (max - min + 1); // Increment and wrap
    return min + predictableSeed;
}

double placeBet(double& playerMoney) {
    double bet;
    while (true) {
        std::cout << "Enter your bet (or 0 to quit): $";
        std::cin >> bet;
        // No clearInputBuffer() here
        // IMPORTANT: If input fails (e.g., user types text), subsequent reads might fail.

        if (std::cin.fail() || bet < 0) {
            std::cout << "Invalid bet. Please enter a positive number." << std::endl;
            std::cin.clear();
            // No clearInputBuffer() here, leftover invalid input might cause issues
        } else if (bet > playerMoney) {
            std::cout << "You cannot bet more money than you have! Current money: $" << playerMoney << std::endl;
        } else {
            return bet;
        }
    }
}

void getPlayerGuess(int& guess, int minGuess, int maxGuess) {
    while (true) {
        std::cout << "Guess a number between " << minGuess << " and " << maxGuess << ": ";
        std::cin >> guess;
        // No clearInputBuffer() here
        // IMPORTANT: If input fails (e.g., user types text), subsequent reads might fail.

        if (std::cin.fail() || guess < minGuess || guess > maxGuess) {
            std::cout << "Invalid guess. Please enter a number between " << minGuess << " and " << maxGuess << "." << std::endl;
            std::cin.clear();
            // No clearInputBuffer() here, leftover invalid input might cause issues
        } else {
            break;
        }
    }
}

void checkGuess(int winningNumber, int playerGuess, double* playerMoney, double betAmount) {
    if (playerGuess == winningNumber) {
        std::cout << "Congratulations! You guessed the exact number! You win $" << (betAmount * 10) << "!" << std::endl;
        *playerMoney += (betAmount * 10);
    } else if (playerGuess == winningNumber - 1 || playerGuess == winningNumber + 1) {
        std::cout << "Close call! Your guess was off by one. You win $" << (betAmount * 2) << "!" << std::endl;
        *playerMoney += (betAmount * 2);
    } else {
        std::cout << "Sorry, your guess was incorrect. You lose $" << betAmount << "." << std::endl;
        *playerMoney -= betAmount;
    }
}

// The getLuckyNumbers() function has been removed.
