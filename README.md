# Construisez et testez une infrastructure de données ( Projet sous linux Mint )


# Description 
Projet sur des données météo avec Airbyte , Docker , Postgres et AWS pour le cloud


# installation 

1. Vérification si docker est bien installé ( sinon consulter la documentation pour l'installation suivant votre OS )

    Exécutez cette commande dans votre terminal pour vérification

        docker --version
        docker compose version

2. Installation de postgresql (le port a été modifie par 5433 si il y a postgresql déjà installé)

    Exécutez cette commande dans votre terminal 

        docker run --name pg-airbyte \
          -e POSTGRES_PASSWORD=postgres \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_DB=data_weather \
          -p 5433:5432 \
          -d postgres:15

    Modifier le user et password dans votre projet

    Autre méthode : utiliser le fichier 

        docker-compose.yml

        


3. Installation l'outil abctl

    Airbyte ne supporte plus Docker Compose : l’installation se fait désormais via abctl.

    Exécutez cette commande dans votre terminal pour télécharger et installer le CLI :

        curl -LsfS https://get.airbyte.com | bash -

4. Installation d'Airbyte

    Une fois abctl installé, lancez simplement la commande d'installation locale (assurez-vous que Docker / Docker Desktop est bien ouvert et actif) :

        abctl local install

    Si votre machine a peu de ressources (moins de 4 cœurs CPU), ajoutez l'option --low-resource-mode :

        abctl local install --low-resource-mode

5. Récupérer vos identifiants de connexion

    Pendant ou à la fin de l'installation, abctl va générer un mot de passe administrateur par défaut. Pour l'afficher, tapez :

        abctl local credentials

    Astuce : Si vous souhaitez définir votre propre mot de passe personnalisé, vous pouvez le modifier directement en tapant :

        abctl local credentials --password VotreNouveauMotDePasse

6. Vérification (Interface Web) 

    Ouvrez votre navigateur à l'adresse http://localhost:8000

    Résultat attendu : La page de connexion / l'interface d'Airbyte s'affiche correctement.


7. Vérification de la connexion avec Postgresql

    Lancer le script dans un terminal

        uv run test_pg.py

    Message : Succès : Connexion à PostgreSQL établie avec succès !

    Sinon : Erreur lors de la connexion à PostgreSQL ....


8. Activer la réplication logique et créer la publication

    Exécutez cette commande dans votre terminal

        docker exec -it pg-airbyte psql -U postgres -d data_weather

    ensuite quand  connexion 


        CREATE PUBLICATION airbyte_publication FOR ALL TABLES ;

    puis la commande 
        
        quit

    Exécutez cette commande dans votre terminal ( mettre votre user)

        docker exec -it pg-airbyte psql -U postgres -c "ALTER USER postgres REPLICATION;"

    Exécutez cette commande dans votre terminal

        docker exec -it pg-airbyte psql -U postgres -d data_weather

    ensuite quand  connexion 

        SHOW wal_level;

    Exécutez la commande suivante pour donner les droits d'utilisation (USAGE) sur le schéma public

        GRANT USAGE ON SCHEMA public TO postgres;


    Donner les droits  sur les tables actuelles et futures :
    
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres;

        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO postgres;

        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres;

        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;

        GRANT SELECT ON  TABLES TO postgres;

    puis la commande 
        
        quit ou \q


9. Désintallation de Airbyte (sous Linux Mint )

    Commande :

        abctl local uninstall

    Supprimer ensuite dans votre répertoire home

        sudo rm -rf ~/.airbyte


10. Créer les sources dans Airbyte pour les fichiers data

11. Créer la Destination vers Postgres SQL dans Airbyte

12. Faire la connexion entre les source et postgresql

13. Installer dbt dans le projet

    Commande

        uv add dbt-postgres

14. Créer vos requetes SQL pour chaque fichier dans le répertoire ex : weather_dbt/models

15. Créer votre fichier : dbt_project.yml

## 📂 Structure du Répertoire

```text
projet_8

└── data                                            # répertoire des données
|    └── Data_Source1_011024-071024.json            # fichier data
|    └── Weather_Underground_La_Madeleine_FR.xlsx   # fichier data
|    └── Weather_Underground_Ichtegem_BE.xlsx       # fichier data
└── test_connexion.py                               # test de la connexion avec postgresql
└── README.md                                       # Documentation du projet

└── weather_dtb/
    ├── dbt_project.yml
    └── models/
        ├── sources.yml                 -- Déclaration des sources brutes Airbyte
        ├── staging/
            ├── stg_weather_la_madeleine.sql
            ├── stg_weather_ichtegem.sql
            └── stg_infoclimat.sql
        ├── intermediate/
            └── int_weather_unified.sql  -- Modèle d'union des sources
        └── marts/
            ├── dim_weather_stations.sql -- Dimension des stations (avec vos métadonnées)
            └── fct_weather_measurements.sql -- Table de faits finale


```
