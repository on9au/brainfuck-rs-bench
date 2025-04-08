#!/bin/bash

# Path to your brainfuck compiler
BRAINFUCK_RS="brainfuckc"
# Path to bfc
BFC="./bfc"
# Path to bff
BFF="bff"

# List of Brainfuck programs to test
PROGRAMS=("programs/mandelbrot.bf" "programs/dquine.bf" "programs/squares.bf" "programs/jabh.bf") # Add more programs here
OUTPUT_FILE="benchmark_results.csv"

# Create CSV file with headers
echo "Program,brainfuck-rs (AOT),bfc (C/ASM),bff (Interpreter)" >"$OUTPUT_FILE"

# Run the benchmarks for each program
for prog in "${PROGRAMS[@]}"; do
    echo "Benchmarking $prog..."

    # Compile brainfuck-rs (AOT compiler)
    echo "Running brainfuck-rs (AOT) for $prog..."
    $BRAINFUCK_RS "$prog" -O3 -o "temp_mine"
    # Measure time for brainfuck-rs
    BF_RS_TIME=$( (time ./temp_mine) 2>&1 | grep real | awk '{print $2}' | sed 's/s//')

    # Compile bfc (Optimized C/ASM compiler)
    echo "Running bfc for $prog..."
    $BFC "$prog" -O2
    # Remove the .bf extension from the program name (to use it as the output filename)
    BFC_OUTPUT=$(basename -- "$prog")
    BFC_OUTPUT="${BFC_OUTPUT%.*}"
    # Measure time for bfc
    BFC_TIME=$( (time ./"$BFC_OUTPUT") 2>&1 | grep real | awk '{print $2}' | sed 's/s//')

    # Run bff (Interpreter)
    echo "Running bff (Interpreter) for $prog..."
    # Measure time for bff
    BFF_TIME=$( (time $BFF "$prog") 2>&1 | grep real | awk '{print $2}' | sed 's/s//')

    # If time is empty, we set it to N/A
    [ -z "$BF_RS_TIME" ] && BF_RS_TIME="N/A"
    [ -z "$BFC_TIME" ] && BFC_TIME="N/A"
    [ -z "$BFF_TIME" ] && BFF_TIME="N/A"

    # Append results to CSV
    echo "$prog,$BF_RS_TIME,$BFC_TIME,$BFF_TIME" >>"$OUTPUT_FILE"

    # Clean up temporary files
    rm -f temp_mine "$BFC_OUTPUT"
done

echo "Benchmarking complete. Results saved to $OUTPUT_FILE."
