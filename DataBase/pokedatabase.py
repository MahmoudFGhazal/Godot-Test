import requests
import json

gen1_pokemon_ids = list(range(1, 152))  # Você pode aumentar esse intervalo conforme necessário
pokemon_data = {}

for pokemon_id in gen1_pokemon_ids:
    print(pokemon_id)
    response = requests.get(f"https://pokeapi.co/api/v2/pokemon/{pokemon_id}")
    data = response.json()

    species_response = requests.get(data["species"]["url"])
    species_data = species_response.json()

    evolution_chain_response = requests.get(species_data["evolution_chain"]["url"])
    evolution_chain_data = evolution_chain_response.json()

    habilidades = [h["ability"]["name"] for h in data["abilities"]]
    evolui_para = []
    chain = evolution_chain_data["chain"]

    def buscar_evolucoes(chain):
        if chain["species"]["name"] == data["name"]:
            if "evolves_to" in chain and len(chain["evolves_to"]) > 0:
                for evo in chain["evolves_to"]:
                    metodo = []
                    if "evolution_details" in evo and len(evo["evolution_details"]) > 0:
                        for detalhe in evo["evolution_details"]:
                            metodo_atual = {}
                            if detalhe["min_level"] is not None:
                                metodo_atual["nivel"] = detalhe["min_level"]
                            if detalhe["item"] is not None:
                                metodo_atual["item"] = detalhe["item"]["name"]
                            if detalhe["trigger"]["name"] == "trade":
                                metodo_atual["troca"] = True
                            if detalhe["trigger"]["name"] == "shed":
                                metodo_atual["shed"] = True
                            if detalhe["known_move"] is not None:
                                metodo_atual["golpe"] = detalhe["known_move"]["name"]
                            if detalhe["known_move_type"] is not None:
                                metodo_atual["golpe_tipo"] = detalhe["known_move_type"]["name"]
                            if detalhe["location"] is not None:
                                metodo_atual["local"] = detalhe["location"]["name"]
                            metodo.append(metodo_atual)
                    evolui_para.append({"nome": evo["species"]["name"], "metodo": metodo})
        elif "evolves_to" in chain and len(chain["evolves_to"]) > 0:
            for evo in chain["evolves_to"]:
                buscar_evolucoes(evo)

    buscar_evolucoes(chain)

    altura = data["height"] / 10  # altura em metros
    peso = data["weight"] / 10    # peso em quilogramas

    movimentos = {
        "level-up": {},
        "tm": set(),
        "egg": set(),
        "tutor": set()
    }

    gen3_games = {"ruby_sapphire", "emerald", "firered-leafgreen"}

    for move in data["moves"]:
        for detail in move["version_group_details"]:
            if detail["version_group"]["name"] in gen3_games:
                metodo = detail["move_learn_method"]["name"]
                if metodo == "level-up":
                    level = detail.get("level_learned_at", None)
                    if level is not None:
                        if move["move"]["name"] not in movimentos["level-up"]:
                            movimentos["level-up"][move["move"]["name"]] = level
                elif metodo == "machine":
                    movimentos["tm"].add(move["move"]["name"])
                elif metodo in movimentos:
                    movimentos[metodo].add(move["move"]["name"])

    pokemon_data[data["name"]] = {
        "ID": data["id"],
        "nome": data["name"],
        "altura": altura,
        "peso": peso,
        "tipos": [t["type"]["name"] for t in data["types"]],
        "habilidades": habilidades,
        "especie": species_data["genera"][7]["genus"],
        "stats": {s["stat"]["name"]: s["base_stat"] for s in data["stats"]},
        "EV_yield": {s["stat"]["name"]: s["effort"] for s in data["stats"] if s["effort"] > 0},
        "catch_rate": species_data["capture_rate"],
        "base_xp": data["base_experience"],
        "base_friendship": species_data["base_happiness"],
        "growth_rate": species_data["growth_rate"]["name"],
        "egg_groups": [group["name"] for group in species_data["egg_groups"]],
        "egg_cycle": species_data["hatch_counter"],
        "genero": {
            "macho": 100 - species_data["gender_rate"] * 12.5 if species_data["gender_rate"] >= 0 else "Desconhecido",
            "femea": species_data["gender_rate"] * 12.5 if species_data["gender_rate"] >= 0 else "Desconhecido"
        },
        "movimentos": {
            "level-up": [{"move": move, "level": level} for move, level in movimentos["level-up"].items()],
            "tm": list(movimentos["tm"]),
            "egg": list(movimentos["egg"]),
            "tutor": list(movimentos["tutor"])
        },
        "evolui_para": evolui_para
    }

# Envolvendo tudo dentro da chave "pokemon"
database = {"pokemon": pokemon_data}

with open("database.json", "w", encoding="utf-8") as f:
    json.dump(database, f, indent=4, ensure_ascii=False)

print("Arquivo database.json salvo com sucesso!")
