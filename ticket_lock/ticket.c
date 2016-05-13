#include <stdio.h>
#include <pthread.h>
#include <sched.h>

const int N = 1000000;
const int NPROCS = 5;
const int TRIALS = 10;

int ticket=1, serving=1, count=0;
pthread_mutex_t mutex;

int fetch_and_add(int*);
void take_ticket();
void finish_ticket();
void *counter(void*);


int main() {
    pthread_t threads[NPROCS];

    int i,j;
    int wrongs = 0;
    for (i = 0; i < TRIALS; i++)
    {
        printf("Trial %d\n", i);
        count = 0;

        for (j = 0; j < NPROCS; j++) {
            pthread_create(&threads[j], NULL, counter, NULL);
        }

        for (j = 0; j < NPROCS; j++) {
           pthread_join(threads[j], NULL);     
        }

        if (count != NPROCS*N)
        {
            printf("Invalid count: %d\n", count);
            wrongs++;
        }
    }

    printf("%d incorrect runs out of %d trials\n", wrongs, TRIALS);
    return 0;
}

int fetch_and_add(int *num) {
    int val;

    pthread_mutex_lock(&mutex);
    val = *num;
    (*num)++;
    pthread_mutex_unlock(&mutex);

    return val;
}

void take_ticket() {

    int mytick;
    mytick = fetch_and_add(&ticket);

    while (mytick != serving)
        sched_yield();
}

void finish_ticket() {

    serving++;
}

void *counter(void* p) {
    int i;

    for (i = 0; i < N; i++) {
        take_ticket();
        count++;
        finish_ticket();
    }
}
