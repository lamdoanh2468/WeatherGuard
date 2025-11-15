import pandas as pd
import requests

url = "https://dht11anddht22-14fb9-default-rtdb.asia-southeast1.firebasedatabase.app/.json"
data = requests.get(url).json()

df = pd.DataFrame.from_dict(data, orient="index")
df.reset_index(drop=True, inplace=True)

df.to_csv("dht22_clean.csv", index=False)

print("Download + Clean Data Successful!")
