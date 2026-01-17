#!/bin/bash

# Benchmark script to compare json-render (port 3000) vs toon-render (port 2999)
# REQUIREMENTS: Both servers must be running before executing this script
# Run with: ./benchmark.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV_FILE="$SCRIPT_DIR/uis.csv"

# API endpoints
JSON_RENDER_URL="http://localhost:3000/api/generate"
TOON_RENDER_URL="http://localhost:2999/api/generate"

# Temporary files for storing response headers
JSON_HEADERS_FILE=$(mktemp)
TOON_HEADERS_FILE=$(mktemp)

# Arrays to store metrics for averaging
declare -a json_input_tokens=()
declare -a json_output_tokens=()
declare -a json_total_tokens=()
declare -a json_costs=()
declare -a json_times=()

declare -a toon_input_tokens=()
declare -a toon_output_tokens=()
declare -a toon_total_tokens=()
declare -a toon_costs=()
declare -a toon_times=()

# Cleanup function
cleanup() {
    rm -f "$JSON_HEADERS_FILE" "$TOON_HEADERS_FILE"
}

trap cleanup EXIT

# Function to check if server is available
check_server() {
    local url=$1
    local name=$2
    
    if ! curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "${RED}ERROR: $name is not running!${NC}"
        echo -e "${YELLOW}Please start the servers first with: ./run_benchmark.sh${NC}"
        exit 1
    fi
}

# Function to make API request and extract metrics from headers
make_request() {
    local url=$1
    local prompt=$2
    local headers_file=$3
    
    # Make the request and save headers
    curl -s -D "$headers_file" -X POST "$url" \
        -H "Content-Type: application/json" \
        -d "{\"prompt\": \"$prompt\"}" \
        -o /dev/null
    
    # Extract metrics from headers (convert to lowercase for case-insensitive matching)
    local input_tokens=$(grep -i "x-input-tokens:" "$headers_file" | tr -d '\r' | cut -d: -f2 | xargs)
    local output_tokens=$(grep -i "x-output-tokens:" "$headers_file" | tr -d '\r' | cut -d: -f2 | xargs)
    local total_cost=$(grep -i "x-total-cost:" "$headers_file" | tr -d '\r' | cut -d: -f2 | xargs)
    local duration_ms=$(grep -i "x-duration-ms:" "$headers_file" | tr -d '\r' | cut -d: -f2 | xargs)
    
    # Return the values
    echo "$input_tokens $output_tokens $total_cost $duration_ms"
}

# Function to calculate percentage difference
calc_percentage() {
    local val1=$1
    local val2=$2
    
    if [ "$val2" = "0" ] || [ -z "$val2" ]; then
        echo "N/A"
    else
        awk "BEGIN {printf \"%.2f%%\", (($val1 - $val2) / $val2) * 100}"
    fi
}

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo -e "${RED}ERROR: CSV file not found at $CSV_FILE${NC}"
    exit 1
fi

# Check if both servers are running
echo -e "${YELLOW}Checking server availability...${NC}" >&2
check_server "http://localhost:3000" "json-render (port 3000)"
check_server "http://localhost:2999" "toon-render (port 2999)"
echo -e "${GREEN}✓ Both servers are running${NC}\n" >&2

# Print Markdown table header
printf "| %-5s | %-12s | %-12s | %-13s | %-13s | %-15s | %-15s | %-26s | %-25s | %-25s |\n" \
    "No." "Tokens JSONL" "Tokens TOON" "Cost JSONL" "Cost TOON" "Time JSONL (ms)" "Time TOON (ms)" "Token Diff (JSONL vs TOON)" "Cost Diff (JSONL vs TOON)" "Time Diff (JSONL vs TOON)"
printf "|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|\n" \
    "-------" "--------------" "-------------" "---------------" "---------------" "-----------------" "-----------------" "----------------------------" "---------------------------" "---------------------------"

# Read CSV file and process each prompt (skip header line)
question_num=0
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and header
    if [ -z "$line" ] || [ "$line" = "UI Prompt" ]; then
        continue
    fi
    
    question_num=$((question_num + 1))
    
    # Make request to json-render (silently)
    json_metrics=$(make_request "$JSON_RENDER_URL" "$line" "$JSON_HEADERS_FILE")
    read -r json_input json_output json_cost json_time <<< "$json_metrics"
    json_total=$((json_input + json_output))
    
    # Make request to toon-render (silently)
    toon_metrics=$(make_request "$TOON_RENDER_URL" "$line" "$TOON_HEADERS_FILE")
    read -r toon_input toon_output toon_cost toon_time <<< "$toon_metrics"
    toon_total=$((toon_input + toon_output))
    
    # Store metrics for averaging
    json_input_tokens+=("$json_input")
    json_output_tokens+=("$json_output")
    json_total_tokens+=("$json_total")
    json_costs+=("$json_cost")
    json_times+=("$json_time")
    
    toon_input_tokens+=("$toon_input")
    toon_output_tokens+=("$toon_output")
    toon_total_tokens+=("$toon_total")
    toon_costs+=("$toon_cost")
    toon_times+=("$toon_time")
    
    # Calculate differences
    token_diff=$((json_total - toon_total))
    token_pct=$(calc_percentage "$json_total" "$toon_total")
    
    cost_diff=$(awk "BEGIN {printf \"%.6f\", $json_cost - $toon_cost}")
    cost_pct=$(calc_percentage "$json_cost" "$toon_cost")
    
    time_diff=$((json_time - toon_time))
    time_pct=$(calc_percentage "$json_time" "$toon_time")
    
    # Print Markdown row
    printf "| %-5s | %-12s | %-12s | \$%-12s | \$%-12s | %-15s | %-15s | %-26s | \$%-24s | %-25s |\n" \
        "$question_num" \
        "$json_total" \
        "$toon_total" \
        "$json_cost" \
        "$toon_cost" \
        "$json_time" \
        "$toon_time" \
        "$token_diff ($token_pct)" \
        "$cost_diff ($cost_pct)" \
        "$time_diff ms ($time_pct)"
    
done < "$CSV_FILE"

# Calculate averages
if [ "$question_num" -gt 0 ]; then
    # JSON-RENDER averages
    json_input_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.2f", sum/NR}' <<< "$(printf '%s\n' "${json_input_tokens[@]}")")
    json_output_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.2f", sum/NR}' <<< "$(printf '%s\n' "${json_output_tokens[@]}")")
    json_total_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.2f", sum/NR}' <<< "$(printf '%s\n' "${json_total_tokens[@]}")")
    json_cost_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.6f", sum/NR}' <<< "$(printf '%s\n' "${json_costs[@]}")")
    json_time_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.2f", sum/NR}' <<< "$(printf '%s\n' "${json_times[@]}")")
    
    # TOON-RENDER averages
    toon_input_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.2f", sum/NR}' <<< "$(printf '%s\n' "${toon_input_tokens[@]}")")
    toon_output_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.2f", sum/NR}' <<< "$(printf '%s\n' "${toon_output_tokens[@]}")")
    toon_total_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.2f", sum/NR}' <<< "$(printf '%s\n' "${toon_total_tokens[@]}")")
    toon_cost_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.6f", sum/NR}' <<< "$(printf '%s\n' "${toon_costs[@]}")")
    toon_time_avg=$(awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.2f", sum/NR}' <<< "$(printf '%s\n' "${toon_times[@]}")")
    
    # Average differences
    token_diff_avg=$(awk "BEGIN {printf \"%.2f\", $json_total_avg - $toon_total_avg}")
    token_pct_avg=$(calc_percentage "$json_total_avg" "$toon_total_avg")
    
    cost_diff_avg=$(awk "BEGIN {printf \"%.6f\", $json_cost_avg - $toon_cost_avg}")
    cost_pct_avg=$(calc_percentage "$json_cost_avg" "$toon_cost_avg")
    
    time_diff_avg=$(awk "BEGIN {printf \"%.2f\", $json_time_avg - $toon_time_avg}")
    time_pct_avg=$(calc_percentage "$json_time_avg" "$toon_time_avg")
    
    # Print Markdown averages row
    printf "| %-5s | %-12s | %-12s | \$%-12s | \$%-12s | %-15s | %-15s | %-26s | \$%-24s | %-25s |\n" \
        "AVG" \
        "$json_total_avg" \
        "$toon_total_avg" \
        "$json_cost_avg" \
        "$toon_cost_avg" \
        "$json_time_avg" \
        "$toon_time_avg" \
        "$token_diff_avg ($token_pct_avg)" \
        "$cost_diff_avg ($cost_pct_avg)" \
        "$time_diff_avg ms ($time_pct_avg)"
fi

echo -e "\n${GREEN}✓ Benchmark completed!${NC}" >&2
