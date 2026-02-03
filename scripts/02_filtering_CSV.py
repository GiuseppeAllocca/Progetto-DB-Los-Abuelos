import pandas as pd
import ast

csv_file = "user"
output_path = f"filtered_{csv_file}.csv"

if csv_file == "checkin":
    df = pd.read_csv(f"CSV/{csv_file}.csv")
    df_exploded = (df.assign(date=df["date"].str.split(",")).explode("date"))
    df_exploded["date"] = df_exploded["date"].str.strip()

    df_exploded.to_csv(output_path, index=False)
elif csv_file == "business":
    df = pd.read_csv(f"CSV/{csv_file}.csv")
    df_limited = df[["business_id", "categories"]]
    df_exploded = (df_limited.assign(categories=df_limited["categories"].astype(str).str.split(",")).explode("categories"))
    df_exploded["categories"] = df_exploded["categories"].str.strip()
    df_exploded = df_exploded.rename(columns={"categories": "category"})

    df_exploded.to_csv(f"category_{output_path}", index=False)

    df_limited = df[["business_id", "hours"]]

    rows = []

    def format_time(t):
        h, m = t.split(":")
        return f"{int(h):02d}:{int(m):02d}"

    for _, row in df.iterrows():
        business_id = row["business_id"]
        hours = row["hours"]

        if pd.isna(hours):
            continue

        try:
            hours_dict = ast.literal_eval(hours)
        except Exception:
            continue

        for day, time in hours_dict.items():
            if time.strip() == "0:0-0:0":
                continue

            try:
                open_t, close_t = time.split("-")
                open_t = format_time(open_t.strip())
                close_t = format_time(close_t.strip())
            except Exception:
                continue

            rows.append({"business_id": business_id, "day": day, "open": open_t, "close": close_t})

    df_hours = pd.DataFrame(rows)

    day_order = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    df_hours["day"] = pd.Categorical(df_hours["day"], categories=day_order, ordered=True)
    df_hours = df_hours.sort_values(["business_id", "day"]).reset_index(drop=True)

    df_hours.to_csv(f"hours_{output_path}", index=False)
elif csv_file == "user":
    df = pd.read_csv(f"CSV/{csv_file}.csv", low_memory=False)
    df_limited = df[["user_id", "friends"]]

    df_exploded = (df_limited.assign(friends=df_limited["friends"].str.split(",")).explode("friends"))
    df_exploded["friends"] = df_exploded["friends"].str.strip()
    df_exploded = df_exploded.rename(columns={"friends": "friend"})

    df_exploded.to_csv(output_path, index=False)

print(f"DONE: {output_path}")
