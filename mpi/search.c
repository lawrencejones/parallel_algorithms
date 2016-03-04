#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mpi.h>
#include "vendorSha256.h"

static const char base[] = "CO409CryptographyEngineeringRunsNowForItsSecondYear";

void printDigest(char *digest)
{
  for (int i = 0; i < 32; i++)
  {
    printf("%02x", (uint8_t)digest[i]);
  }
}

static char* hexString(char *digest)
{
  char *hex = malloc(128 * sizeof(char));
  for (int i = 0; i < 32; i++)
  {
    sprintf(hex + 2*i, "%02x", (uint8_t)digest[i]);
  }

  return hex;
}

static inline void h(char data[], char digest[])
{
  char tempDigest[32];
  sha256(data, tempDigest);
  sha256(tempDigest, digest);
}

static inline int hasLeadingZeros(char data[], int n)
{
  for (int i = 0; i < n/2; i++)
  {
    if (data[i] != 0) return 0;
  }
  return 1;
}

/* start: number to check first
 * increment: value to add to `start` on every iteration
 * n: number of leading zeros in hexidecimal notation */
static char* findNLeadingZeros(char *base, int n, int start, int increment)
{
  char buffer[1024];
  char digest[32];

  char *result = (char*) malloc(2048 * sizeof(char));
  char *message = (char*) malloc(2048 * sizeof(char));

  // Have all processes wait for any messages
  int flag;
  MPI_Request request;
  MPI_Irecv(message, 2048, MPI_BYTE, MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &request);

  for (int i = start; i < 100 * 1000 * 1000; i += increment)
  {

    // Periodic check for a solution
    if ((i % (100 * 1000)) < increment) {
      if (start == 0) printf("[%d] Step %d\n", start, i);

      MPI_Test(&request, &flag, MPI_STATUS_IGNORE);

      if (flag) {
        printf("[%d] Received message from other process!\n", start);
        strcpy(result, message);
        goto found;
      }
    }

    sprintf(buffer, "%s%d", base, i);
    h(buffer, digest);

    if (hasLeadingZeros(digest, n)) {
      printf("[%d] Found!\n", start);
      char *hexDigest = hexString(digest);

      sprintf(result, "{ buffer: [%s]\n  digest: [0x%s] }", buffer, hexDigest);
      free(hexDigest);

      // MPI_Bcast(result, strlen(result), MPI_BYTE, start, MPI_COMM_WORLD);
      for (int j = 0; j < increment; j++) {
        if (j != start) {
          MPI_Send(result, strlen(result), MPI_BYTE, j, 0, MPI_COMM_WORLD);
        }
      }

      goto found;
    }
  }

found:

  free(message);
  return result;
}

int main(int argc, char **argv)
{
  if (argc < 2) {
    fprintf(stderr, "[Error] Requires leading 0 argument!\n");
    exit(255);
  }

  if (MPI_Init(&argc,&argv) != MPI_SUCCESS) {
    fprintf(stderr, "Failed to init MPI\n");
    exit(255);
  }

  int n = atoi(argv[1]);
  int rank, size;

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  printf("[%d] Running %d processes\n", rank, size);

  MPI_Barrier(MPI_COMM_WORLD);
  char *result = findNLeadingZeros((char*)base, n, rank, size);
  MPI_Barrier(MPI_COMM_WORLD);

  MPI_Finalize();

  if (rank == 0) {
    printf("%s\n", result);
  }

  free(result);
  return 0;
}
