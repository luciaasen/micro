#include <stdio.h>
#include <stdlib.h>

#define TRUE 1
#define FALSE 0
#define NUMBERATTEMPTS 5

unsigned int checkSecretNumber(unsigned char* number);
void fillUpAttempt(unsigned int attempt, unsigned char* attemptDigits);
unsigned int computeMatches(unsigned char* secretNum, unsigned char* attemptDigits);
unsigned int computeSemiMatches(unsigned char* secretNum, unsigned char* attemptDigits);
/*
int main(void){
    int t;
    unsigned char secretNum[4];
    unsigned char attemptDigits[4];
    unsigned int retorno;
    int i = 0, j;
    srand((unsigned) time(&t));    
    for(i = 0; i < 5; i++){
        printf("Lista: [");
        for(j = 0; j < 4; j++){
            secretNum[j] = rand() % 10;
            printf(" %u ", secretNum[j]);
        }
        printf("] -> IGUALES: ");
        retorno = checkSecretNumber(secretNum);
        printf("%u\n", retorno);
    }
    for(i = 0; i < 5; i++){
    	retorno = rand() % 10000;
        printf("Numero: %u ->", retorno);
        printf("Lista: [");
        fillUpAttempt(retorno, attemptDigits);
        for(j = 0; j < 4; j++){
            printf(" %u ", attemptDigits[j]);
        }
        printf("]\n");
    }
	for(i = 0; i < 5; i++){
        printf("Lista1: [");
        for(j = 0; j < 4; j++){
            secretNum[j] = rand() % 3;
            printf(" %u ", secretNum[j]);
        }
		printf("]\n");
		printf("Lista2: [");
		for(j = 0; j < 4; j++){
            attemptDigits[j] = rand() % 3;
            printf(" %u ", attemptDigits[j]);
        }
        printf("] -> IGUALES: ");
        retorno = computeMatches(secretNum, attemptDigits);
        printf("%u\n", retorno);
    }
	attemptDigits[0] = 1;
	attemptDigits[1] = 2;
	attemptDigits[2] = 3;
	attemptDigits[3] = 7;
	secretNum[0] = 2;
	secretNum[1] = 1;
	secretNum[2] = 7;
	secretNum[3] = 4;
	retorno = computeSemiMatches(secretNum, attemptDigits);
    printf("SEMI MATCHES %u\n", retorno);
    return 0;
}
*/
//////////////////////////////////////////////////////////////////////////
///// -------------------------- MAIN ------------------------------ /////
//////////////////////////////////////////////////////////////////////////

int main(void){
    int t;
	int scan;
    unsigned char secretNum[4];
    unsigned char attemptDigits[4];
    unsigned int numAttempts, attempt, matches, semimatches, repeated, i;
    srand((unsigned) time(&t));

    do {
        for (i=0; i<4; i++)
            secretNum[i] = rand() % 10;
        repeated = checkSecretNumber(secretNum);
    } while (repeated == TRUE);
    
    numAttempts = 0;
    do {
        numAttempts++;
    
        do{
            printf("Please enter attempt %u [0000 - 9999]: ", numAttempts );
			scanf("%u", &attempt);
        } while ( attempt > 9999);
        fillUpAttempt( attempt, attemptDigits );
		repeated = checkSecretNumber(attemptDigits);
		if (repeated){
			printf("Please, select a number with non repeated digits.\n");
			numAttempts--;
			continue;
		}
        matches = computeMatches(secretNum, attemptDigits);
        semimatches = computeSemiMatches(secretNum, attemptDigits);
        printf("Number of matches: %u\t", matches);
        printf("Number of semi-matches: %u\n", semimatches );
    
    } while ((matches != 4) && (numAttempts != NUMBERATTEMPTS));

    if (matches == 4)
        printf("Secret number guessed: YOU WIN!!!\n");
    else
        printf("Number of attempts exceeded: YOU LOSE :(\n");
    printf("Secret number: %u%u%u%u\n", secretNum[0], secretNum[1], secretNum[2], secretNum[3]);
    return 0;
}