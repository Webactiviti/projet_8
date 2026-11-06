import json
import os

def analyze_structure(data, indent=0):
    """Analyse récursivement la structure d'un objet JSON (clés et types)."""
    spacing = " " * indent
    if isinstance(data, dict):
        for key, value in data.items():
            val_type = type(value).__name__
            if isinstance(value, dict):
                print(f"{spacing}🔑 **{key}** (dict) :")
                analyze_structure(value, indent + 4)
            elif isinstance(value, list):
                print(f"{spacing}📋 **{key}** (list de {len(value)} élément(s)) :")
                if len(value) > 0:
                    # On analyse le premier élément pour donner un aperçu
                    analyze_structure(value[0], indent + 4)
            else:
                print(f"{spacing}- **{key}** : `{val_type}`")
    elif isinstance(data, list):
        print(f"{spacing}[Liste de {len(data)} éléments]")
        if len(data) > 0:
            analyze_structure(data[0], indent + 4)

# Définissez le chemin vers votre fichier dans le répertoire 'data'
# Remplacez 'votre_fichier.json' par le nom exact de votre fichier
file_path = os.path.join("data", "Data_Source1_011024-071024.json")

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = json.load(f)
        print(f"📂 Analyse de la structure pour : {file_path}\n")
        analyze_structure(content)
except FileNotFoundError:
    print(f"❌ Erreur : Le fichier est introuvable à l'emplacement '{file_path}'.")
except json.JSONDecodeError:
    print("❌ Erreur : Le fichier spécifié n'est pas un JSON valide.")
