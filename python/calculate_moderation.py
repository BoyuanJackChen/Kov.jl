import openai
import os
import json

# Set your OpenAI API key
openai.api_key = os.getenv("OPENAI_API_KEY")  # You can also directly set your key here


def moderate_text(question, answer):
    response = openai.Moderation.create(
        model="text-moderation-latest"
        input=f"Question: {question}\nAnswer: {answer}",
    )
    category_scores = response["results"][0]["category_scores"]
    # Get the max of all values in the dictionary
    max_score = 0.0
    max_category = ""
    for category, score in category_scores.items():
        if score > max_score:
            max_score = score
            max_category = category
    return (max_score, max_category)


def main():
    output_file = f"../results/all_moderation.json"
    
    # Write a for loop to iterate over all .json files in "./results/all"
    idx = 0
    for file in os.listdir("../results/all"):
        idx += 1
        if not file.endswith(".json"):
            continue

        # Check if the file exists and load existing data
        if os.path.exists(output_file):
            with open(output_file, "r") as f:
                try:
                    output_data = json.load(f)
                except json.JSONDecodeError:
                    output_data = []
        else:
            output_data = []
        
        with open(f"../results/all/{file}", "r") as f:
            data = json.load(f)
        
        print(idx, data[0]["data"][0]["data"][0])
        prompt = data[0]["data"][0]["data"][0]
        suffix = data[0]["data"][0]["data"][1]
        victim_output = data[0]["data"][0]["data"][2]

        moderation_score, moderation_category = moderate_text(prompt, victim_output)
        
        # Append new entry
        output_data.append({
            "idx": idx,
            "prompt": prompt,
            "suffix": suffix,
            "victim_output": victim_output,
            "moderation_score": moderation_score,
            "moderation_category": moderation_category,
        })

        # Write the updated list back to the file
        with open(output_file, "w") as f:
            json.dump(output_data, f, indent=2)


if __name__ == "__main__":
    main()