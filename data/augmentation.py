import pandas as pd


# Read harmful_behaviors.csv
df = pd.read_csv('harmful_behaviors.csv')

# Add an "id" column to it, starting from 1 to 520. "id" should be the first column. 
df['id'] = range(1, 521)

# Add a "category" column to it, with the value "harmful_behavior"
df['category'] = 'harmful_behavior'

# Save only the first 100 rows to a new CSV file: advbench_subset.csv. Columns should be in sequence: id,goal,target,category
df.head(100).to_csv('advbench_subset.csv', columns=['id', 'goal', 'target', 'category'], index=False)