#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mpi.h>

static const char goal[] = "3.141592653589";

static inline
void printPi(long double pi)
{
	char piBuffer[256];
	sprintf(piBuffer, "%.20Lf", pi);
	piBuffer[strlen(goal)] = '\0';

	printf("%s", piBuffer);
}

static inline
long double estimatePi(int iterations, int start, int end)
{
	long double pi = 0;
	long double h = 1.0 / (double)iterations;

	#define F(i) 4.0 / (1.0 + i * i)
	#define Xi(i) (i - 1) * h

	#pragma omp for
	for (double i = start; i < end; i++) {
		long double fxi = F(Xi(i));
		long double fxi_1 = F(Xi(i + 1));

		#pragma omp atomic
		pi += (fxi + fxi_1) * (h / 2.0);
	}

	return pi;
}

int main(int argc, char **argv)
{
	if (MPI_Init(&argc,&argv) != MPI_SUCCESS) {
    fprintf(stderr, "Failed to init MPI\n");
    exit(255);
	}

	if (argc != 2) {
		fprintf(stderr, "Requires iterations arg!\n");
    exit(255);
	}

	int rank, size;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	int iterations = atoi(argv[1]);
	long double pi;

	if (rank == 0) {
		printf("[%d] Splitting %d iterations over %d workers...\n",
				    rank,          iterations,        size);
	}

	MPI_Barrier(MPI_COMM_WORLD);

	int iterationsPerWorker = iterations / size;
	int start = rank * iterationsPerWorker;
	int end = start + iterationsPerWorker;

	/* Deal with an iteration count that doesn't divide cleanly by size */
	if (rank == size - 1) {
		end = 1 + start + (iterations - rank * iterationsPerWorker);
	}

	printf("[%d] Computing %d-%d...\n", rank, start, end);
	long double piComponent = estimatePi(iterations, start, end);

	MPI_Allreduce(&piComponent, &pi, 1, MPI_LONG_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
	MPI_Barrier(MPI_COMM_WORLD);

	MPI_Finalize();

	if (rank == 0) {
		printf("Goal for pi is:\t\t%s\n", goal);
		printf("π estimated to be:\t"); printPi(pi); printf("\n");
	}

	return 0;
}
