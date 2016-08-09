// g++  -Wall -g -pthread debugee.cpp -o debugee && ./debugee
#include <iostream>
#include <pthread.h>
#include <cstdlib>

int GLOBAL;

void * SetGlobalTo2(void * x) 
{
  GLOBAL = 2;
  return x;
}

void * SetGlobalTo3(void * x) 
{
  GLOBAL = 3;
  return x;
}

int main()
{
    char* buffer = (char *)malloc(256);
    buffer = (char *) realloc(buffer, 512);
    pthread_t thread1, thread2;
    pthread_create(&thread1, NULL, SetGlobalTo2, NULL);
    pthread_create(&thread2, NULL, SetGlobalTo3, NULL);
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    std::cout << GLOBAL << std::endl;
    //free(buffer);
    return 0;
}
