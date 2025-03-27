# Load from ../results/all_moderation.json
import json


data = []
with open("../results/all_moderation_asr.json", "r") as f:
    data = json.load(f)
    
# Check for repetitive "prompt" entry value in data
print(len(data))

sum_moderation_score = 0.0
sum_asr = 0.0
for entry in data:
    sum_moderation_score += entry["moderation_score"]
    sum_asr += entry["asr"]

average_moderation_score = sum_moderation_score / len(data)
average_asr = sum_asr / len(data)
print(average_moderation_score)
print(average_asr)

