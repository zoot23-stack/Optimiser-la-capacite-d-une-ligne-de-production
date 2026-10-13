--Je supprime les tables existantes
DROP TABLE IF EXISTS L1_Production;
DROP TABLE IF EXISTS L2_Production;
DROP TABLE IF EXISTS L1_Planif;
DROP TABLE IF EXISTS L2_Planif;

--Création de la table L1_Planif
CREATE TABLE L1_Planif(
IDENT_LOT INTEGER NOT NULL,
NUM_PROD INTEGER NOT NULL,
FORMAT INTEGER NOT NULL,
DATE_PLANIF DATETIME NOT NULL
);

--Création de la table L2_Planif
CREATE TABLE L2_Planif(
IDENT_LOT INTEGER NOT NULL,
NUM_PROD INTEGER NOT NULL,
FORMAT INTEGER NOT NULL,
DATE_PLANIF DATETIME NOT NULL
);

--Création de la table L1_Production
CREATE TABLE L1_Production(
DATE_DEBUT DATETIME NOT NULL,
DATE_HEURE DATETIME NOT NULL,
TYPE_PLANIF VARCHAR(10) NOT NULL,
LOT_PLANIF INTEGER NOT NULL,
Product_ID INTEGER NOT NULL,
NB_Produits INTEGER NOT NULL
);

--Création de la table L2_Production
CREATE TABLE L2_Production(
DATE_DEBUT DATETIME NOT NULL,
DATE_HEURE DATETIME NOT NULL,
TYPE_PLANIF VARCHAR(10) NOT NULL,
LOT_PLANIF INTEGER NOT NULL,
Product_ID INTEGER NOT NULL,
NB_Produits INTEGER NOT NULL
);

--Vérifier format DATE
SELECT LENGTH(DATE_PLANIF) AS longueur, COUNT(*) AS nb
FROM L1_Planif
GROUP BY longueur;

SELECT LENGTH(DATE_DEBUT) AS longueur, COUNT(*) AS nb
FROM L1_Production
GROUP BY longueur;

SELECT LENGTH(DATE_PLANIF) AS longueur, COUNT(*) AS nb
FROM L2_Planif
GROUP BY longueur;

SELECT LENGTH(DATE_DEBUT) AS longueur, COUNT(*) AS nb
FROM L2_Production
GROUP BY longueur;

SELECT LENGTH(DATE_HEURE) AS longueur, COUNT(*) AS nb
FROM L2_Production
GROUP BY longueur;

SELECT LENGTH(DATE_HEURE) AS longueur, COUNT(*) AS nb
FROM L1_Production
GROUP BY longueur;

--le dates sources non pas de secondes (JJ/MM/AAAA HH:MM,16 caracteres)
--ajout de 00 pour obtenir le format ISO complet AAAA-MM-JJ HH:MM:SS (19 caractères)
--je cherche la requete pour convertir datatime == sqlite convert date dd/mm/yyyy hh:mm to yyyy-mm-dd hh:mm:ss
SELECT
    DATE_PLANIF,                            
    substr(DATE_PLANIF, 7, 4) || '-' ||
    substr(DATE_PLANIF, 4, 2) || '-' ||
    substr(DATE_PLANIF, 1, 2) || ' ' ||
    substr(DATE_PLANIF, 12, 5) || ':00'
    AS date_iso
FROM L1_Planif
LIMIT 10;

UPDATE L1_Planif                              -- La table à modifier
SET DATE_PLANIF =                             -- La colonne qui reçoit la nouvelle valeur
    substr(DATE_PLANIF, 7, 4) || '-' ||       -- Année
    substr(DATE_PLANIF, 4, 2) || '-' ||       -- Mois
    substr(DATE_PLANIF, 1, 2) || ' ' ||       -- Jour, puis une espace
    substr(DATE_PLANIF, 12, 5) || ':00'       -- Heure et minutes, puis les secondes
WHERE DATE_PLANIF LIKE '__/__/____ __:__';    -- Sécurité : seulement les dates pas encore converties

UPDATE L2_Planif
SET DATE_PLANIF =
    substr(DATE_PLANIF, 7, 4) || '-' ||
    substr(DATE_PLANIF, 4, 2) || '-' ||
    substr(DATE_PLANIF, 1, 2) || ' ' ||
    substr(DATE_PLANIF, 12, 5) || ':00'
WHERE DATE_PLANIF LIKE '__/__/____ __:__';

UPDATE L1_Production
SET DATE_DEBUT =
    substr(DATE_DEBUT, 7, 4) || '-' ||
    substr(DATE_DEBUT, 4, 2) || '-' ||
    substr(DATE_DEBUT, 1, 2) || ' ' ||
    substr(DATE_DEBUT, 12, 5) || ':00'
WHERE DATE_DEBUT LIKE '__/__/____ __:__';

UPDATE L2_Production
SET DATE_DEBUT =
    substr(DATE_DEBUT, 7, 4) || '-' ||
    substr(DATE_DEBUT, 4, 2) || '-' ||
    substr(DATE_DEBUT, 1, 2) || ' ' ||
    substr(DATE_DEBUT, 12, 5) || ':00'
WHERE DATE_DEBUT LIKE '__/__/____ __:__';

UPDATE L1_Production
SET DATE_HEURE =
    substr(DATE_HEURE, 7, 4) || '-' ||
    substr(DATE_HEURE, 4, 2) || '-' ||
    substr(DATE_HEURE, 1, 2) || ' ' ||
    substr(DATE_HEURE, 12, 5) || ':00'
WHERE DATE_HEURE LIKE '__/__/____ __:__';

UPDATE L2_Production
SET DATE_HEURE =
    substr(DATE_HEURE, 7, 4) || '-' ||
    substr(DATE_HEURE, 4, 2) || '-' ||
    substr(DATE_HEURE, 1, 2) || ' ' ||
    substr(DATE_HEURE, 12, 5) || ':00'
WHERE DATE_HEURE LIKE '__/__/____ __:__';

--je vérifie le nombre de caractères sur une table
SELECT LENGTH(DATE_PLANIF) AS longueur, COUNT(*) AS nb
FROM L1_Planif
GROUP BY longueur;

