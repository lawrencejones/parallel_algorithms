SEARCH_SRC=$(shell find mpi/search -name "*.c")
PI_SRC=$(shell find mpi/pi -name "*.c")

MPI=mpicc -std=c99

all: bin/search bin/pi

bin/search: $(SEARCH_SRC:.c=.o)
	$(MPI) $^ -o $@

bin/pi: $(PI_SRC:.c=.o)
	$(MPI) $^ -o $@

mpi/%.o: mpi/%.c
	$(MPI) -c $< -o $@

clean:
	find mpi -type f -name "*.o" -print0 | xargs -0 rm -fv

test:
	bundle exec rspec -r spec_helper.rb spec

lint:
	bundle exec rubocop
