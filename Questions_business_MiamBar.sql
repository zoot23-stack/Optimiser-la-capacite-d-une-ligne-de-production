--QUESTIONS BUSINESS
--Question 1
SELECT Product_ID, SUM(NB_Produits) AS Quantite_totale_l1
FROM L1_production
GROUP BY Product_ID
ORDER BY Quantite_totale_l1 DESC;

--Question 2
SELECT Product_ID, SUM(NB_Produits) AS Quantite_totale_l2
FROM L2_production
GROUP BY Product_ID
ORDER BY Quantite_totale_l2 DESC;

--Question 3
SELECT 'L1' AS LIGNE, Product_ID, SUM(NB_Produits) AS Quantite_totale
FROM L1_production
GROUP BY Product_ID
UNION ALL
SELECT 'L2' AS LIGNE, Product_ID, SUM(NB_Produits) AS Quantite_totale
FROM L2_production
GROUP BY Product_ID
ORDER BY Quantite_totale DESC;

--Question 4
WITH Qte_produits_L1 AS (
SELECT Product_ID, SUM(NB_Produits) AS Quantite_totale_l1
FROM L1_Production
GROUP BY Product_ID
),
Qte_produits_L2 AS (
SELECT Product_ID, SUM(NB_Produits) AS Quantite_totale_l2
FROM L2_production
GROUP BY Product_ID
)
SELECT Qte_produits_L1.Product_ID, Quantite_totale_l1,
Quantite_totale_l2
FROM Qte_produits_L1
LEFT JOIN Qte_produits_L2 ON Qte_produits_L1.Product_ID =
Qte_produits_L2.Product_ID
UNION
SELECT Qte_produits_L2.Product_ID, Quantite_totale_l1,
Quantite_totale_l2
FROM Qte_produits_L2
LEFT JOIN Qte_produits_L1 ON Qte_produits_L2.Product_ID =
Qte_produits_L1.Product_ID;

--Question 5
SELECT L1_Production.*, L1_Planif.NUM_PROD
FROM L1_Production
JOIN L1_Planif ON L1_Production.LOT_PLANIF = L1_Planif.IDENT_LOT
ORDER BY NUM_PROD, DATE_DEBUT;

--Question 6
SELECT NUM_PROD, TYPE_PLANIF, strftime('%Y', L1_Planif.DATE_PLANIF) AS ANNEE
FROM L1_Production
JOIN L1_Planif ON L1_Production.LOT_PLANIF = L1_Planif.IDENT_LOT
WHERE L1_Production.TYPE_PLANIF = 'MULTIPLE'
GROUP BY NUM_PROD, TYPE_PLANIF, ANNEE
LIMIT 20;

--Question 7
WITH multiples AS (
SELECT NUM_PROD, TYPE_PLANIF, strftime('%Y', L1_Planif.DATE_PLANIF) AS ANNEE
FROM L1_Production
JOIN L1_Planif ON L1_Production.LOT_PLANIF = L1_Planif.IDENT_LOT
WHERE L1_Production.TYPE_PLANIF='MULTIPLE'
GROUP BY NUM_PROD, TYPE_PLANIF, ANNEE
),
uniques AS (
SELECT NUM_PROD, TYPE_PLANIF, strftime('%Y', L1_Planif.DATE_PLANIF) AS ANNEE
FROM L1_Production
JOIN L1_Planif ON L1_Production.LOT_PLANIF = L1_Planif.IDENT_LOT
WHERE L1_Production.TYPE_PLANIF='UNIQUE'
GROUP BY NUM_PROD, TYPE_PLANIF, ANNEE
)
SELECT multiples.NUM_PROD, multiples.TYPE_PLANIF AS Type_Multiple, multiples.ANNEE, uniques.TYPE_PLANIF AS Type_Unique
FROM multiples
JOIN uniques ON multiples.NUM_PROD=uniques.NUM_PROD AND multiples.ANNEE=uniques.ANNEE
ORDER BY multiples.ANNEE, multiples.NUM_PROD;

--Questions 8
SELECT NUM_PROD, strftime('%Y', L1_Planif.DATE_PLANIF) AS ANNEE, Product_ID, SUM(NB_Produits) AS Quantite_produits
FROM L1_Production
JOIN L1_Planif ON L1_Production.LOT_PLANIF = L1_Planif.IDENT_LOT
GROUP BY NUM_PROD, Product_ID, ANNEE
ORDER BY ANNEE, NUM_PROD, Product_ID;

--Question 9
-- Vue 1 : quantité par num_prod, année et variété
CREATE VIEW qtes_produit_vw AS
SELECT NUM_PROD, strftime('%Y', L1_Planif.DATE_PLANIF) AS ANNEE, Product_ID, SUM(NB_Produits) AS Quantite_produits
FROM L1_Production
JOIN L1_Planif ON L1_Production.LOT_PLANIF = L1_Planif.IDENT_LOT
GROUP BY NUM_PROD, ANNEE, Product_ID;
-- Vue 2 : quantité de la variété la moins produite, par num_prod et année
CREATE VIEW minimum_num_prod_vw AS
SELECT NUM_PROD, ANNEE, MIN(Quantite_produits) AS Quantite_minimum
FROM qtes_produit_vw
GROUP BY NUM_PROD, ANNEE;
-- Vue 3 : date de fin, nombre de références et quantité totale, par num_prod et année
CREATE VIEW infos_num_prod_vw AS
SELECT NUM_PROD, strftime('%Y', L1_Planif.DATE_PLANIF) AS ANNEE, MAX(DATE_HEURE) AS Date_fin,
       COUNT(DISTINCT Product_ID) AS Nbre_ref, SUM(NB_Produits) AS Qte_totale
FROM L1_Production
JOIN L1_Planif ON L1_Production.LOT_PLANIF = L1_Planif.IDENT_LOT
GROUP BY NUM_PROD, ANNEE;
-- déséquilibre total par num_prod et année
SELECT infos_num_prod_vw.NUM_PROD, infos_num_prod_vw.ANNEE, Date_fin, Nbre_ref, Qte_totale,
             SUM(Quantite_produits - Quantite_minimum) AS Desequilibre_total
FROM infos_num_prod_vw
JOIN qtes_produit_vw ON infos_num_prod_vw.NUM_PROD = qtes_produit_vw.NUM_PROD 
AND infos_num_prod_vw.ANNEE = qtes_produit_vw.ANNEE
JOIN minimum_num_prod_vw ON infos_num_prod_vw.NUM_PROD = minimum_num_prod_vw.NUM_PROD 
AND infos_num_prod_vw.ANNEE = minimum_num_prod_vw.ANNEE
GROUP BY infos_num_prod_vw.NUM_PROD, infos_num_prod_vw.ANNEE
ORDER BY Date_fin;

--Question 10
--question 9 + liste des variétés de chaque coffret (COFFRET_PROD)
SELECT infos_num_prod_vw.NUM_PROD, infos_num_prod_vw.ANNEE, Date_fin, Nbre_ref, Qte_totale,
       SUM(Quantite_produits - Quantite_minimum) AS Desequilibre_total,
       GROUP_CONCAT(DISTINCT Product_ID) AS COFFRET_PROD
FROM infos_num_prod_vw
JOIN qtes_produit_vw ON infos_num_prod_vw.NUM_PROD = qtes_produit_vw.NUM_PROD
                    AND infos_num_prod_vw.ANNEE = qtes_produit_vw.ANNEE
JOIN minimum_num_prod_vw ON infos_num_prod_vw.NUM_PROD = minimum_num_prod_vw.NUM_PROD
                        AND infos_num_prod_vw.ANNEE = minimum_num_prod_vw.ANNEE
GROUP BY infos_num_prod_vw.NUM_PROD, infos_num_prod_vw.ANNEE
ORDER BY Date_fin;

--Question 11
SELECT DISTINCT COFFRET_PROD FROM (
SELECT NUM_PROD, ANNEE, GROUP_CONCAT(DISTINCT Product_ID) AS COFFRET_PROD
FROM qtes_produit_vw
GROUP BY NUM_PROD, ANNEE
) AS Liste_coffret_prod;

--Question 12
SELECT DISTINCT COFFRET_PROD
FROM (
SELECT GROUP_CONCAT(DISTINCT Product_ID) AS COFFRET_PROD,
COUNT(DISTINCT Product_ID) AS Nb_variete
FROM qtes_produit_vw
GROUP BY NUM_PROD, ANNEE
) AS coffrets
WHERE Nb_variete IN (1,4);