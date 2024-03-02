set -e
for i in {1..100}; do
	fd -IH -td build -E 3rd-party | xargs rm -rf && make -C testbench/verilator/DP sim MODULE=RRF DEBUG=Y
done
