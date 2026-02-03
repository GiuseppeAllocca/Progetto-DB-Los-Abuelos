import os
import csv
import json

input_folder = "JSON"
output_folder = "CSV"

os.makedirs(output_folder, exist_ok=True)

for filename in os.listdir(input_folder):
    if filename.endswith(".json"):
        input_path = os.path.join(input_folder, filename)
        output_path = os.path.join(output_folder, filename.replace(".json", ".csv"))

        data = []

        with open(input_path, "r", encoding="utf-8") as f:
            try:
                data = json.load(f)
                if isinstance(data, dict):
                    data = [data]
            except json.JSONDecodeError:
                f.seek(0)
                for line in f:
                    line = line.strip()
                    if line:
                        data.append(json.loads(line))

        keys = data[0].keys()

        with open(output_path, "w", newline="", encoding="utf-8") as f_out:
            writer = csv.DictWriter(f_out, fieldnames=keys)
            writer.writeheader()
            writer.writerows(data)

        print(f"DONE: {output_path}")
