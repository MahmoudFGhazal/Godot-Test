import requests
import json
import os

arquivo_json = "database.json"
pokemon_id = 4  # Exemplo com Charmander

# URL da PokéAPI
url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_id}"
response = requests.get(url)
data = response.json()

# Jogos de interesse
jogos_de_interesse = {"firered-leafgreen", "ruby-sapphire", "emerald"}

# Dicionário para armazenar os golpes e seus detalhes
ataques_detalhados = {}

for movimento in data["moves"]:
    nome_movimento = movimento["move"]["name"]
    
    # Verifica se o movimento está presente nos jogos desejados
    for detalhe in movimento["version_group_details"]:
        jogo = detalhe["version_group"]["name"]
        if jogo in jogos_de_interesse:
            # Pega os detalhes do golpe na API
            move_url = movimento["move"]["url"]
            move_response = requests.get(move_url)
            move_data = move_response.json()
            
            # Define "faz_contato" baseado na categoria do golpe
            faz_contato = move_data["damage_class"]["name"] == "physical"

            # Armazena os detalhes do golpe
            ataques_detalhados[nome_movimento] = {
                "tipo": move_data["type"]["name"],
                "categoria": move_data["damage_class"]["name"],
                "poder": move_data["power"],
                "precisão": move_data["accuracy"],
                "pp": move_data["pp"],
                "faz_contato": faz_contato
            }
            break  # Para evitar salvar o mesmo golpe mais de uma vez

# Carrega o JSON existente, se houver
if os.path.exists(arquivo_json):
    with open(arquivo_json, "r", encoding="utf-8") as file:
        try:
            dados_existentes = json.load(file)
        except json.JSONDecodeError:
            dados_existentes = {}
else:
    dados_existentes = {}

# Adiciona os novos dados de ataques ao JSON existente, sob a chave 'itens'
dados_existentes["moves"] = ataques_detalhados

# Salva o JSON atualizado
with open(arquivo_json, "w", encoding="utf-8") as file:
    json.dump(dados_existentes, file, indent=4, ensure_ascii=False)

print(f"Dados de ataques adicionados a {arquivo_json} com sucesso!")
