import requests
import os
import shutil

# Change this to where you want to save images
base_folder = "D:/Godot/Projects/Pokemon/Assets/Entities/Pokemon"  # Windows
# base_folder = "/home/yourname/PokemonSprites"  # Linux/Mac

os.makedirs(base_folder, exist_ok=True)

# Get only the first 151 Pokémon (Gen 1)
url = "https://pokeapi.co/api/v2/pokemon?limit=151"
response = requests.get(url)
pokemon_list = response.json()["results"]

# Function to download an image
def download_image(img_url, save_path):
    if img_url:
        img_data = requests.get(img_url).content
        with open(save_path, "wb") as img_file:
            img_file.write(img_data)

# Download sprites for each Pokémon
for index, pokemon in enumerate(pokemon_list, start=1):
    print(f"Processing {pokemon['name']}...")
    
    pokemon_folder = os.path.join(base_folder, pokemon["name"])
    os.makedirs(pokemon_folder, exist_ok=True)
    
    pokemon_data = requests.get(f"https://pokeapi.co/api/v2/pokemon/{index}/").json()
    sprites = pokemon_data["sprites"]
    
    gen_iii = sprites["versions"].get("generation-iii", {})
    fire_red_leaf_green = gen_iii.get("firered-leafgreen", {})
    
    for sprite_name, sprite_url in fire_red_leaf_green.items():
        if sprite_url:
            image_path = os.path.join(pokemon_folder, f"firered_{sprite_name}.png")
            download_image(sprite_url, image_path)
            print(f"Downloaded {pokemon['name']} - FireRed {sprite_name}")
    
    # Move existing local sprite (e.g., 001MS3.png) if found
    sprite_filename = f"{str(index).zfill(3)}MS3.png"  # Format ID to 3 digits
    source_path = os.path.join(base_folder, sprite_filename)
    
    if os.path.exists(source_path):
        destination_path = os.path.join(pokemon_folder, sprite_filename)
        shutil.move(source_path, destination_path)
        print(f"Moved {sprite_filename} to {pokemon['name']} folder")

print("FireRed Pokémon sprites downloaded and organized!")