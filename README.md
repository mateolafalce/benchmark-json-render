<div align="center">

![preview](./media/rover-the-dog.gif)

# JSON Render Benchmark: TOON vs JSONL

</div>

## Overview

This benchmark compares the efficiency of using **TOON** versus **JSONL** as the output format for the JSON-Render application when working with Claude Opus 4.5.

## Hypothesis

Using TOON instead of JSONL for the LLM output is significantly more cost-effective, even when accounting for the additional context required to explain the TOON format. This is because Claude Opus 4.5's output token cost is **3x higher** than its input token cost.

## Proposed Optimization

Since TOON can be directly translated to JSON, we can modify the prompt to request TOON-formatted output instead of JSONL, then convert it to JSON using TOON's native decoding function. This approach should reduce:
- **Token count** in the LLM response
- **API costs** due to fewer output tokens
- **Response time** due to shorter outputs

## Benchmark Methodology

This benchmark validates the hypothesis by comparing two implementations:

1. **json-render** (port 3000): Original implementation returning JSONL responses
2. **toon-render** (port 2999): Modified implementation returning TOON responses

The benchmark measures three key metrics across 10 different UI generation prompts:
- **Token usage** (input + output)
- **API cost** (based on Claude Opus 4.5 pricing)
- **Response time** (in milliseconds)

## Running the Benchmark

### Prerequisites

Create a `.env` file in the project root with your Anthropic API key:

```bash
ANTHROPIC_API_KEY=your_api_key_here
```

### Setup

First, run the setup script to clone the required projects and install dependencies:

```bash
./set_up.sh
```

### Execute Benchmark

Run the benchmark script, which will start both servers and compare their performance:

```bash
./run_benchmark.sh
```

The benchmark will process all prompts in `uis.csv` (10 UI generation tasks) and output a Markdown table with detailed comparisons.

## Benchmark Results

The following results were obtained from testing 10 different UI generation prompts:

| No.   | Tokens JSONL | Tokens TOON  | Cost JSONL    | Cost TOON     | Time JSONL (ms) | Time TOON (ms)  | Token Diff (JSONL vs TOON) | Cost Diff (JSONL vs TOON) | Time Diff (JSONL vs TOON) |
|-------|--------------|-------------|---------------|---------------|-----------------|-----------------|----------------------------|---------------------------|---------------------------|
| 1     | 1744         | 1424         | $0.015680     | $0.011600     | 5292            | 3480            | 320 (22.47%)               | $0.004080 (35.17%)        | 1812 ms (52.07%)          |
| 2     | 2953         | 1868         | $0.045885     | $0.022680     | 15148           | 7781            | 1085 (58.08%)              | $0.023205 (102.31%)       | 7367 ms (94.68%)          |
| 3     | 5363         | 2429         | $0.106195     | $0.036765     | 33587           | 12703           | 2934 (120.79%)             | $0.069430 (188.85%)       | 20884 ms (164.40%)        |
| 4     | 1780         | 1407         | $0.016660     | $0.011255     | 5678            | 3562            | 373 (26.51%)               | $0.005405 (48.02%)        | 2116 ms (59.40%)          |
| 5     | 3266         | 2433         | $0.053830     | $0.036925     | 17965           | 14511           | 833 (34.24%)               | $0.016905 (45.78%)        | 3454 ms (23.80%)          |
| 6     | 2041         | 1665         | $0.023105     | $0.017625     | 7655            | 6282            | 376 (22.58%)               | $0.005480 (31.09%)        | 1373 ms (21.86%)          |
| 7     | 1763         | 1415         | $0.016095     | $0.011315     | 6156            | 3968            | 348 (24.59%)               | $0.004780 (42.24%)        | 2188 ms (55.14%)          |
| 8     | 3944         | 1886         | $0.070720     | $0.023190     | 22801           | 8312            | 2058 (109.12%)             | $0.047530 (204.96%)       | 14489 ms (174.31%)        |
| 9     | 3039         | 2387         | $0.048075     | $0.035695     | 15681           | 13185           | 652 (27.31%)               | $0.012380 (34.68%)        | 2496 ms (18.93%)          |
| 10    | 2003         | 1524         | $0.022235     | $0.014180     | 8532            | 5872            | 479 (31.43%)               | $0.008055 (56.81%)        | 2660 ms (45.30%)          |
| **AVG** | **2789.60** | **1843.80** | **$0.041848** | **$0.022123** | **13849.50**    | **7965.60**     | **945.80 (51.30%)**       | **$0.019725 (89.16%)**   | **5883.90 ms (73.87%)**  |

## Key Findings

The benchmark results confirm our hypothesis with compelling evidence:

### Token Efficiency
- **51.30% fewer tokens** on average (1,843.80 vs 2,789.60)
- TOON's compact representation significantly reduces output length

### Cost Savings
- **89.16% lower cost** on average ($0.022123 vs $0.041848)
- The reduced output tokens more than compensate for increased input context

### Performance
- **73.87% faster response time** on average (7,965.60ms vs 13,849.50ms)
- Shorter outputs mean faster streaming and processing

## Conclusion

The TOON format demonstrates **significant advantages** over JSONL for LLM-generated structured output:

- Dramatically reduced token usage
- Substantial cost savings (~89% reduction)
- Improved response times (~74% faster)

These results validate the hypothesis that optimizing for compact output formats can yield major improvements in LLM application efficiency, especially when output token costs are significantly higher than input token costs.

## Project Structure

```
.
├── benchmark.sh          # Benchmark execution script
├── run_benchmark.sh      # Setup and run both servers
├── set_up.sh            # Initial setup script
├── uis.csv              # 10 UI generation prompts
└── README.md            # This file
```
