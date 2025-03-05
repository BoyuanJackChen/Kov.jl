import bson
import json

for idx in range(2,14):
    # Read the BSON file
    file_path = f"results/gpt3-advbench{idx}-adv-mdp-data.bson"
    with open(file_path, "rb") as f:
        data = bson.decode_all(f.read())

    # Convert to JSON and save
    json_file_path = f"results/{idx}.json"
    with open(json_file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)

    print(f"Converted JSON saved to: {json_file_path}")
