"""
Benchmark Visualization: TOON vs JSONL
Generate professional charts for Google Colab
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# Set style for better-looking plots
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (14, 8)
plt.rcParams['font.size'] = 11

# Benchmark data
data = {
    'No.': list(range(1, 11)),
    'Tokens_JSONL': [1744, 2953, 5363, 1780, 3266, 2041, 1763, 3944, 3039, 2003],
    'Tokens_TOON': [1424, 1868, 2429, 1407, 2433, 1665, 1415, 1886, 2387, 1524],
    'Cost_JSONL': [0.015680, 0.045885, 0.106195, 0.016660, 0.053830, 0.023105, 0.016095, 0.070720, 0.048075, 0.022235],
    'Cost_TOON': [0.011600, 0.022680, 0.036765, 0.011255, 0.036925, 0.017625, 0.011315, 0.023190, 0.035695, 0.014180],
    'Time_JSONL': [5292, 15148, 33587, 5678, 17965, 7655, 6156, 22801, 15681, 8532],
    'Time_TOON': [3480, 7781, 12703, 3562, 14511, 6282, 3968, 8312, 13185, 5872]
}

df = pd.DataFrame(data)

# Calculate differences and percentages
df['Token_Diff'] = df['Tokens_JSONL'] - df['Tokens_TOON']
df['Token_Pct'] = (df['Token_Diff'] / df['Tokens_TOON']) * 100
df['Cost_Diff'] = df['Cost_JSONL'] - df['Cost_TOON']
df['Cost_Pct'] = (df['Cost_Diff'] / df['Cost_TOON']) * 100
df['Time_Diff'] = df['Time_JSONL'] - df['Time_TOON']
df['Time_Pct'] = (df['Time_Diff'] / df['Time_TOON']) * 100

# Calculate averages
avg_row = {
    'No.': 'AVG',
    'Tokens_JSONL': df['Tokens_JSONL'].mean(),
    'Tokens_TOON': df['Tokens_TOON'].mean(),
    'Cost_JSONL': df['Cost_JSONL'].mean(),
    'Cost_TOON': df['Cost_TOON'].mean(),
    'Time_JSONL': df['Time_JSONL'].mean(),
    'Time_TOON': df['Time_TOON'].mean(),
    'Token_Diff': df['Token_Diff'].mean(),
    'Token_Pct': df['Token_Pct'].mean(),
    'Cost_Diff': df['Cost_Diff'].mean(),
    'Cost_Pct': df['Cost_Pct'].mean(),
    'Time_Diff': df['Time_Diff'].mean(),
    'Time_Pct': df['Time_Pct'].mean()
}

print("=" * 80)
print("BENCHMARK RESULTS: TOON vs JSONL")
print("=" * 80)
print(f"\n📊 Average Results:")
print(f"   Tokens: JSONL={avg_row['Tokens_JSONL']:.2f}, TOON={avg_row['Tokens_TOON']:.2f} ({avg_row['Token_Pct']:.2f}% reduction)")
print(f"   Cost:   JSONL=${avg_row['Cost_JSONL']:.6f}, TOON=${avg_row['Cost_TOON']:.6f} ({avg_row['Cost_Pct']:.2f}% reduction)")
print(f"   Time:   JSONL={avg_row['Time_JSONL']:.2f}ms, TOON={avg_row['Time_TOON']:.2f}ms ({avg_row['Time_Pct']:.2f}% reduction)")
print("\n" + "=" * 80 + "\n")

# ============================================================================
# CHART 1: Side-by-side comparison bars
# ============================================================================
fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('TOON vs JSONL: Performance Comparison', fontsize=16, fontweight='bold', y=1.02)

x = np.arange(len(df))
width = 0.35

# Tokens
axes[0].bar(x - width/2, df['Tokens_JSONL'], width, label='JSONL', color='#e74c3c', alpha=0.8)
axes[0].bar(x + width/2, df['Tokens_TOON'], width, label='TOON', color='#2ecc71', alpha=0.8)
axes[0].set_xlabel('Test Number', fontweight='bold')
axes[0].set_ylabel('Tokens', fontweight='bold')
axes[0].set_title('Token Usage', fontweight='bold')
axes[0].set_xticks(x)
axes[0].set_xticklabels(df['No.'])
axes[0].legend()
axes[0].grid(axis='y', alpha=0.3)

# Cost
axes[1].bar(x - width/2, df['Cost_JSONL'], width, label='JSONL', color='#e74c3c', alpha=0.8)
axes[1].bar(x + width/2, df['Cost_TOON'], width, label='TOON', color='#2ecc71', alpha=0.8)
axes[1].set_xlabel('Test Number', fontweight='bold')
axes[1].set_ylabel('Cost ($)', fontweight='bold')
axes[1].set_title('API Cost', fontweight='bold')
axes[1].set_xticks(x)
axes[1].set_xticklabels(df['No.'])
axes[1].legend()
axes[1].grid(axis='y', alpha=0.3)

# Time
axes[2].bar(x - width/2, df['Time_JSONL'], width, label='JSONL', color='#e74c3c', alpha=0.8)
axes[2].bar(x + width/2, df['Time_TOON'], width, label='TOON', color='#2ecc71', alpha=0.8)
axes[2].set_xlabel('Test Number', fontweight='bold')
axes[2].set_ylabel('Time (ms)', fontweight='bold')
axes[2].set_title('Response Time', fontweight='bold')
axes[2].set_xticks(x)
axes[2].set_xticklabels(df['No.'])
axes[2].legend()
axes[2].grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('comparison_bars.png', dpi=300, bbox_inches='tight')
plt.show()

# ============================================================================
# CHART 2: Percentage improvements
# ============================================================================
fig, ax = plt.subplots(figsize=(14, 8))

x = np.arange(len(df))
width = 0.25

bars1 = ax.bar(x - width, df['Token_Pct'], width, label='Token Reduction %', color='#3498db', alpha=0.8)
bars2 = ax.bar(x, df['Cost_Pct'], width, label='Cost Reduction %', color='#e67e22', alpha=0.8)
bars3 = ax.bar(x + width, df['Time_Pct'], width, label='Time Reduction %', color='#9b59b6', alpha=0.8)

ax.set_xlabel('Test Number', fontweight='bold', fontsize=12)
ax.set_ylabel('Improvement (%)', fontweight='bold', fontsize=12)
ax.set_title('TOON Improvement Over JSONL (Higher is Better)', fontweight='bold', fontsize=14)
ax.set_xticks(x)
ax.set_xticklabels(df['No.'])
ax.legend(fontsize=11)
ax.grid(axis='y', alpha=0.3)

# Add average line
ax.axhline(y=avg_row['Token_Pct'], color='#3498db', linestyle='--', alpha=0.5, linewidth=1)
ax.axhline(y=avg_row['Cost_Pct'], color='#e67e22', linestyle='--', alpha=0.5, linewidth=1)
ax.axhline(y=avg_row['Time_Pct'], color='#9b59b6', linestyle='--', alpha=0.5, linewidth=1)

# Add value labels on bars
for bars in [bars1, bars2, bars3]:
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.1f}%',
                ha='center', va='bottom', fontsize=8)

plt.tight_layout()
plt.savefig('improvement_percentages.png', dpi=300, bbox_inches='tight')
plt.show()

# ============================================================================
# CHART 3: Summary comparison (averages)
# ============================================================================
fig, ax = plt.subplots(figsize=(10, 6))

categories = ['Tokens', 'Cost ($)', 'Time (ms)']
jsonl_values = [avg_row['Tokens_JSONL'], avg_row['Cost_JSONL'] * 1000, avg_row['Time_JSONL'] / 10]
toon_values = [avg_row['Tokens_TOON'], avg_row['Cost_TOON'] * 1000, avg_row['Time_TOON'] / 10]

x = np.arange(len(categories))
width = 0.35

bars1 = ax.bar(x - width/2, jsonl_values, width, label='JSONL', color='#e74c3c', alpha=0.8)
bars2 = ax.bar(x + width/2, toon_values, width, label='TOON', color='#2ecc71', alpha=0.8)

ax.set_ylabel('Normalized Values', fontweight='bold', fontsize=12)
ax.set_title('Average Performance: TOON vs JSONL\n(Cost ×1000, Time ÷10 for visualization)', 
             fontweight='bold', fontsize=14)
ax.set_xticks(x)
ax.set_xticklabels(categories, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(axis='y', alpha=0.3)

# Add value labels
for bars in [bars1, bars2]:
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.1f}',
                ha='center', va='bottom', fontsize=10, fontweight='bold')

plt.tight_layout()
plt.savefig('average_comparison.png', dpi=300, bbox_inches='tight')
plt.show()

# ============================================================================
# CHART 4: Line plot showing trends
# ============================================================================
fig, axes = plt.subplots(1, 3, figsize=(18, 5))
fig.suptitle('Performance Trends Across Tests', fontsize=16, fontweight='bold', y=1.02)

# Tokens trend
axes[0].plot(df['No.'], df['Tokens_JSONL'], marker='o', linewidth=2, markersize=8, 
             label='JSONL', color='#e74c3c', alpha=0.8)
axes[0].plot(df['No.'], df['Tokens_TOON'], marker='s', linewidth=2, markersize=8, 
             label='TOON', color='#2ecc71', alpha=0.8)
axes[0].set_xlabel('Test Number', fontweight='bold')
axes[0].set_ylabel('Tokens', fontweight='bold')
axes[0].set_title('Token Usage Trend', fontweight='bold')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Cost trend
axes[1].plot(df['No.'], df['Cost_JSONL'], marker='o', linewidth=2, markersize=8, 
             label='JSONL', color='#e74c3c', alpha=0.8)
axes[1].plot(df['No.'], df['Cost_TOON'], marker='s', linewidth=2, markersize=8, 
             label='TOON', color='#2ecc71', alpha=0.8)
axes[1].set_xlabel('Test Number', fontweight='bold')
axes[1].set_ylabel('Cost ($)', fontweight='bold')
axes[1].set_title('API Cost Trend', fontweight='bold')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Time trend
axes[2].plot(df['No.'], df['Time_JSONL'], marker='o', linewidth=2, markersize=8, 
             label='JSONL', color='#e74c3c', alpha=0.8)
axes[2].plot(df['No.'], df['Time_TOON'], marker='s', linewidth=2, markersize=8, 
             label='TOON', color='#2ecc71', alpha=0.8)
axes[2].set_xlabel('Test Number', fontweight='bold')
axes[2].set_ylabel('Time (ms)', fontweight='bold')
axes[2].set_title('Response Time Trend', fontweight='bold')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('trends.png', dpi=300, bbox_inches='tight')
plt.show()

# ============================================================================
# CHART 5: Heatmap of improvements
# ============================================================================
fig, ax = plt.subplots(figsize=(12, 8))

heatmap_data = df[['Token_Pct', 'Cost_Pct', 'Time_Pct']].T
heatmap_data.columns = [f'Test {i}' for i in range(1, 11)]
heatmap_data.index = ['Token Reduction %', 'Cost Reduction %', 'Time Reduction %']

sns.heatmap(heatmap_data, annot=True, fmt='.1f', cmap='RdYlGn', center=50,
            cbar_kws={'label': 'Improvement %'}, linewidths=0.5, ax=ax)
ax.set_title('TOON Improvement Heatmap (% better than JSONL)', 
             fontweight='bold', fontsize=14, pad=20)
ax.set_xlabel('Test Number', fontweight='bold', fontsize=12)
ax.set_ylabel('Metric', fontweight='bold', fontsize=12)

plt.tight_layout()
plt.savefig('improvement_heatmap.png', dpi=300, bbox_inches='tight')
plt.show()

# ============================================================================
# Display summary table
# ============================================================================
print("\n📋 DETAILED RESULTS TABLE:")
print("=" * 120)
display_df = df[['No.', 'Tokens_JSONL', 'Tokens_TOON', 'Token_Pct', 
                  'Cost_JSONL', 'Cost_TOON', 'Cost_Pct',
                  'Time_JSONL', 'Time_TOON', 'Time_Pct']].copy()

display_df.columns = ['No.', 'Tokens\nJSONL', 'Tokens\nTOON', 'Token\nImpr%',
                       'Cost\nJSONL', 'Cost\nTOON', 'Cost\nImpr%',
                       'Time\nJSONL', 'Time\nTOON', 'Time\nImpr%']

print(display_df.to_string(index=False))
print("=" * 120)

print("\n✅ All charts saved successfully!")
print("   - comparison_bars.png")
print("   - improvement_percentages.png")
print("   - average_comparison.png")
print("   - trends.png")
print("   - improvement_heatmap.png")
