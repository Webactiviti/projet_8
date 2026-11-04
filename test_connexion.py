import psycopg2

# Configuration de connexion (remplacez par vos valeurs)
DB_CONFIG = {
    "host": "localhost",          # ou l'IP de votre serveur postgres
    "database": "data_weather",     # nom de votre base de données
    "user": "postgres",       # nom de l'utilisateur Airbyte
    "password": "postgres", # mot de passe
    "port": 5433
}

SCHEMA_NAME = "public"            # Le schéma visé (ex: public ou un autre nom)

try:
    print("1. Tentative de connexion au serveur PostgreSQL...")
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    print("✅ Connexion réussie !\n")

    print(f"2. Vérification du privilège USAGE sur le schéma '{SCHEMA_NAME}'...")
    cursor.execute(f"SELECT has_schema_privilege('{DB_CONFIG['user']}', '{SCHEMA_NAME}', 'USAGE');")
    has_usage = cursor.fetchone()[0]
    
    if has_usage:
        print(f"✅ L'utilisateur '{DB_CONFIG['user']}' a bien le droit d'utiliser (USAGE) le schéma '{SCHEMA_NAME}'.")
    else:
        print(f"❌ ERREUR : L'utilisateur n'a PAS le privilège USAGE sur le schéma '{SCHEMA_NAME}'.")
        print(f"   Exécutez : GRANT USAGE ON SCHEMA {SCHEMA_NAME} TO {DB_CONFIG['user']};")

    print(f"\n3. Vérification des tables visibles dans le schéma '{SCHEMA_NAME}'...")
    cursor.execute(f"""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = '{SCHEMA_NAME}';
    """)
    tables = cursor.fetchall()
    
    if tables:
        print(f"✅ Tables trouvées ({len(tables)}) : {[t[0] for t in tables]}")
    else:
        print(f"⚠️ Aucune table n'est visible pour cet utilisateur dans le schéma '{SCHEMA_NAME}'.")
        print("   (C'est normal si la base est vide et que vous configurez une destination, mais cela déclenche l'erreur Airbyte si vous configurez une Source).")

    cursor.close()
    conn.close()

except Exception as e:
    print(f"\n❌ ERREUR CRITIQUE de connexion : {e}")
