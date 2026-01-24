import pandas as pd

# Read the file (adjust separator if needed, e.g., sep='\t' for tab-separated)
df = pd.read_csv('hg38_t2t_merged.txt', sep='\t')
rows = df.shape[0]
# Count empty lists in 'start_new' and 'end_new'
empty_start = (df['ch13_start'] == '[]').sum()
empty_end = (df['ch13_end'] == '[]').sum()

print(f"Empty lists in 'start_new': {empty_start}, prop: {empty_start/rows}")
print(f"Empty lists in 'end_new': {empty_end}, prop: {empty_end/rows}")
print(f"Empty lists in 'total': {empty_end + empty_start}, prop: {(empty_start + empty_end)/rows/2}")
