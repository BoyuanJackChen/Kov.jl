import bson
import json
import os

def main():
    dir = "../results"
    # Convert all files in the ending with "bson" to same name with "json"
    for file in os.listdir(dir):
        if file.endswith(".bson"):
            with open(os.path.join(dir, file), 'rb') as f:
                data = bson.decode_all(f.read())
                with open(os.path.join(dir, file.replace(".bson", ".json")), 'w') as j:
                    # Deump in nice indentations
                    json.dump(data, j, indent=4)

    # Remove all files in the dir that ends with .bson:
    for file in os.listdir(dir):
        if file.endswith(".bson"):
            os.remove(os.path.join(dir, file))

if __name__ == "__main__":
    main()