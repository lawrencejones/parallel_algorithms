# Parallel Algorithms ![Build Status](https://circleci.com/gh/lawrencejones/parallel_algorithms.png)

Experiments for Imperial College's Parallel Algorithms course.

## MPI

Run the search with the command...

```sh
mpiexec -machinefile <hostfile> -np <no-of-workers> bin/search <no-of-leading-zeros>
```

To run locally, configure a hostfile with content `"127.0.0.1:<no-of-threads>"`.
Alternatively, create a `.env` with the following content.

```sh
# Convenience helper for running mpi binaries on localhost
mpi-local() {
  mpiexec -machinefile hosts -np 4 $@
}
```
