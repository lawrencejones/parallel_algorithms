SRC=$(shell find mpi -name "*.c")
OBJ=$(SRC:.c=.o)

bin/search: $(OBJ)
	mpicc $^ -o $@

mpi/%.o: mpi/%.c
	mpicc -c $< -o $@

clean:
	rm -fv $(OBJ)

test:
	bundle exec rspec -r spec_helper.rb spec

lint:
	bundle exec rubocop
