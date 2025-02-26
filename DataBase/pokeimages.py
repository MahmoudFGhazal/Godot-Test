import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin

url = "https://archives.bulbagarden.net/wiki/Category:Generation_III_menu_sprites"
folder_path = "D:/Godot/Projects/Pokemon/Assets/Entities/Pokemon"

os.makedirs(folder_path, exist_ok=True)

response = requests.get(url)
soup = BeautifulSoup(response.text, "html.parser")

for img in soup.find_all("img"):
    img_url = urljoin("https:", img["src"])  # Ensure proper URL
    img_name = os.path.join(folder_path, img_url.split("/")[-1])

    with open(img_name, "wb") as f:
        img_data = requests.get(img_url).content
        f.write(img_data)
        print(f"Downloaded: {img_name}")
