import requests
import json
import os
import time

arquivo_json = "database.json"

# URL para obter os itens
url = "https://pokeapi.co/api/v2/item?offset=0&limit=1000"
response = requests.get(url)
data = response.json()

# Jogos de interesse (terceira geração)
jogos_de_interesse = {"firered", "leafgreen", "ruby", "sapphire", "emerald"}

# Lista para armazenar os itens da terceira geração
itens_detalhados = []

# Função para verificar se o item pertence à terceira geração
def pertence_terceira_geracao(item_data):
    for detalhe in item_data.get("game_indices", []):
        version = detalhe.get("version", {}).get("name", "")
        print(f"Verificando versão: {version}")  # Debug: Exibir a versão encontrada
        if version in jogos_de_interesse:
            return True
    return False

# Itera sobre os itens disponíveis
for item in data["results"]:
    item_url = item["url"]
    item_response = requests.get(item_url)
    item_data = item_response.json()

    # Debug: Exibir os índices dos jogos para verificar a estrutura
    print(f"Item: {item_data['name']}, Game Indices: {item_data.get('game_indices', [])}")

    # Verifica se o item pertence à terceira geração
    if pertence_terceira_geracao(item_data):
        nome_item = item_data["name"]
        print(f"Item adicionado: {nome_item}")

        # Armazena os detalhes do item
        itens_detalhados.append({
            "nome": nome_item,
            "descricao": item_data.get("effect_entries", [{}])[0].get("effect", "Sem descrição"),
            "categoria": item_data["category"]["name"]
        })
    else:
        print("Não pertence à terceira geração.")

    # Pequeno delay para evitar sobrecarregar a API
    time.sleep(0.1)

# Carrega o JSON existente, se houver
if os.path.exists(arquivo_json):
    with open(arquivo_json, "r", encoding="utf-8") as file:
        try:
            dados_existentes = json.load(file)
        except json.JSONDecodeError:
            dados_existentes = {}
else:
    dados_existentes = {}

# Adiciona os novos itens ao JSON existente
if "database" not in dados_existentes:
    dados_existentes["database"] = {}

dados_existentes["database"]["itens"] = itens_detalhados

# Salva o JSON atualizado
with open(arquivo_json, "w", encoding="utf-8") as file:
    json.dump(dados_existentes, file, indent=4, ensure_ascii=False)

# Exibe os itens adicionados
print("Itens adicionados:")
for item in itens_detalhados:
    print(f"Nome: {item['nome']}")
    print(f"Descrição: {item['descricao']}")
    print(f"Categoria: {item['categoria']}")
    print("-" * 30)

print(f"Dados de itens adicionados a {arquivo_json} com sucesso!")
