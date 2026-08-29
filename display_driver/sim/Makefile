FILELIST_DIR = files.f

SRCS = $(wildcard *.sv) $(wildcard ../src/*.sv) $(wildcard ../src/*/*.sv)

TESTS = $(basename $(notdir $(wildcard test_*.sv)))

.PHONY: all clean list list-tests

all: $(TESTS)

clean:
	rm -rf obj_dir
	echo "Simulation files cleaned."

list-tests:
	@echo "Available tests:"
	@for test in $(TESTS); do \
		echo "  $$test"; \
	done

list:
	@echo "Available targets:"
	@echo "  all - Build all tests"
	@echo "  clean - Remove simulation files"
	@echo "  list - List all available targets"
	@echo "  list-tests - List available tests"
	@echo "  <test_name> - Build a specific test"
	@echo "  run_<test_name> - Run a specific test"

$(TESTS): $(SRCS)
	verilator --trace --binary -j 0 -f $(FILELIST_DIR) --top $@ $@.sv
	mv obj_dir/V$@ $@

run_%: %
	./$<
