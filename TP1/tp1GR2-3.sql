-- Par Hani Belkhir / TP1 (Groupe 2 & 3)
-- insertions des tables, joueurs et résistances ne sont pas incluses (question de garder ça moins long)
USE DbKnapsak;

-- Groupe 2
-- 1
GO
CREATE OR ALTER TRIGGER CTRLPrixArme
ON Items
AFTER INSERT, UPDATE AS
BEGIN
    -- Si aucun item de type 'A' n'est inséré ou modifié, on ne fait rien
    IF NOT EXISTS (SELECT 1 FROM inserted WHERE typeItem = 'A')
        RETURN;

    -- Vérification du prix uniquement pour les armes insérées
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE i.typeItem = 'A' AND i.prix <= (
              SELECT ISNULL(MAX(prix), 0) FROM Items 
              WHERE typeItem <> 'A' AND idItem NOT IN (SELECT idItem FROM inserted)
          )
    )
    BEGIN
        RAISERROR ('Le prix d''une arme doit être strictement supérieur au prix des autres types d''items.', 16, 1);
        ROLLBACK;
        RETURN;
    END
END;

-- 2
GO
CREATE OR ALTER TRIGGER CTRLPtdeVie
ON Medicaments
AFTER INSERT, UPDATE
AS
BEGIN
    -- Vérifie si un médicament inséré/modifié a un nbPtvie <= au nbPtvie max des nourritures
    IF EXISTS (
        SELECT 1 FROM inserted m
        WHERE m.nbPtvie <= (SELECT ISNULL(MAX(nbPtvie), 0) FROM Nourritures)
    )
    BEGIN
        RAISERROR ('Le nombre de points de vie d''un médicament doit être supérieur à celui d''une nourriture.', 16, 1);
        ROLLBACK;
        RETURN;
    END
END;

-- 3
GO
CREATE OR ALTER TRIGGER CTRLInsertArme
ON Armes
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE EXISTS (SELECT 1 FROM Armures WHERE idItem = i.idItem)
           OR EXISTS (SELECT 1 FROM Medicaments WHERE idItem = i.idItem)
           OR EXISTS (SELECT 1 FROM Nourritures WHERE idItem = i.idItem)
    )
    BEGIN
        RAISERROR ('Cet idItem existe déjà dans la table Armures, Medicaments ou Nourritures.', 16, 1);
        ROLLBACK;
        RETURN;
    END
END;

-- 4
GO
CREATE OR ALTER TRIGGER CTRLInsertArmure
ON Armures
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE EXISTS (SELECT 1 FROM Armes WHERE idItem = i.idItem)
           OR EXISTS (SELECT 1 FROM Nourritures WHERE idItem = i.idItem)
           OR EXISTS (SELECT 1 FROM Medicaments WHERE idItem = i.idItem)
    )
    BEGIN
        RAISERROR ('Cet idItem existe déjà dans la table Armes, Nourritures ou Medicaments.', 16, 1);
        ROLLBACK;
        RETURN;
    END
END;


-- Groupe 3
-- 1
GO
CREATE OR ALTER PROCEDURE ajouterArme
    @nom VARCHAR(30), @qtStock INT, @prix INT, @poids INT, @portee INT, @degat INT, @forceRequise INT, @flagDispo INT=1
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Insertion dans Items (type 'A' pour Arme)
        INSERT INTO Items (nom, qtStock, prix, typeItem, poids, flagDispo) VALUES (@nom, @qtStock, @prix, 'A', @poids, @flagDispo);

        DECLARE @idItem INT = @@IDENTITY;

        -- 2. Insertion dans Armes
        INSERT INTO Armes (idItem, portee, degat, forceRequise) VALUES (@idItem, @portee, @degat, @forceRequise);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
        ROLLBACK;
    END CATCH
END;

-- 2
GO
CREATE OR ALTER PROCEDURE ajouterArmure
    @nom VARCHAR(30), @qtStock INT, @prix INT, @poids INT, @matiere VARCHAR(30), @taille INT, @flagDispo INT=1
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Insertion dans Items (type 'R' pour ArmuRe)
        INSERT INTO Items (nom, qtStock, prix, typeItem, poids, flagDispo) VALUES (@nom, @qtStock, @prix, 'R', @poids, @flagDispo);

        DECLARE @idItem INT = @@IDENTITY;

        -- 2. Insertion dans Armures
        INSERT INTO Armures (idItem, matiere, taille) VALUES (@idItem, @matiere, @taille);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
        ROLLBACK;
    END CATCH
END;

-- 3
GO
CREATE OR ALTER PROCEDURE ajouterNourriture
    @nom VARCHAR(30), @qtStock INT, @prix INT, @poids INT, @calorie INT, @nbDex INT, @nbPtvie INT, @flagDispo INT=1
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Insertion dans Items (type 'N' pour Nourriture)
        INSERT INTO Items (nom, qtStock, prix, typeItem, poids, flagDispo) VALUES (@nom, @qtStock, @prix, 'N', @poids, @flagDispo);

        DECLARE @idItem INT = @@IDENTITY;

        -- 2. Insertion dans Nourritures
        INSERT INTO Nourritures (idItem, calorie, nbDex, nbPtvie) VALUES (@idItem, @calorie, @nbDex, @nbPtvie);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
        ROLLBACK;
    END CATCH
END;

-- 4
GO
CREATE OR ALTER PROCEDURE ajouterMedicament
    @nom VARCHAR(30), @qtStock INT, @prix INT, @poids INT, @effet VARCHAR(50), @dureEffet INT, @indesirable VARCHAR(30), @nbDex INT, @nbPtvie INT, @flagDispo INT = 1
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Items (nom, qtStock, prix, typeItem, poids, flagDispo) VALUES (@nom, @qtStock, @prix, 'M', @poids, @flagDispo);

        DECLARE @idItem INT = @@IDENTITY;

        INSERT INTO Medicaments (idItem, effet, dureEffet, indesirable, nbDex, nbPtvie) VALUES (@idItem, @effet, @dureEffet, @indesirable, @nbDex, @nbPtvie);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
        ROLLBACK;
    END CATCH
END;

-- 5 (insertions)
-- insertions des armes 
EXECUTE ajouterArme @nom = "Agile du desert", @qtStock=80, @prix=210, @poids=5, @portee=25, @degat=15, @forceRequise=4
EXECUTE ajouterArme @nom = "Carabine", @qtStock=10, @prix=210, @poids=5, @portee=40, @degat=20, @forceRequise=5
EXECUTE ajouterArme @nom = "Fusil d'assaut", @qtStock=10, @prix=300, @poids=15, @portee=45, @degat=16, @forceRequise=5
EXECUTE ajouterArme @nom = "Arme Red Ryder", @qtStock=5, @prix=1200, @poids=5, @portee=32, @degat=25, @forceRequise=5
EXECUTE ajouterArme @nom = "Lance Flamme", @qtStock=5, @prix=800, @poids=15, @portee=5, @degat=100, @forceRequise=6
EXECUTE ajouterArme @nom = "Arme Alien", @qtStock=2, @prix=800, @poids=5, @portee=10, @degat=100, @forceRequise=2, @flagDispo=0

-- insertion des armures
EXECUTE ajouterArmure @nom="Armure de combat", @qtStock=20, @prix=60, @poids=10, @matiere="Fer", @taille=8
EXECUTE ajouterArmure @nom="Veste en cuire", @qtStock=5, @prix=10, @poids=3, @matiere="Cuire", @taille=12
EXECUTE ajouterArmure @nom="Super Armure", @qtStock=2, @prix=150, @poids=15, @matiere="Cuivre", @taille=10
EXECUTE ajouterArmure @nom="Super Armure renforcée", @qtStock=4, @prix=200, @poids=15, @matiere="Cuivre et cuire", @taille=10

-- insertion de la nourriture
EXECUTE ajouterNourriture @nom="Viande de cheval", @qtStock=10, @prix=10, @poids=1, @calorie=200, @nbDex=5, @nbPtvie=2
EXECUTE ajouterNourriture @nom="Tas de fournies", @qtStock=100, @prix=20, @poids=2, @calorie=500, @nbDex=15, @nbPtvie=8
EXECUTE ajouterNourriture @nom="Viande de mouches", @qtStock=100, @prix=20, @poids=1, @calorie=50, @nbDex=2, @nbPtvie=2
EXECUTE ajouterNourriture @nom="Macaroni", @qtStock=50, @prix=20, @poids=3, @calorie=70, @nbDex=3, @nbPtvie=2

-- insertion des médicamments
EXECUTE ajouterMedicament @nom='Radix', @qtStock=30, @prix=40, @poids=1, @effet='enlève les radiations', @dureEffet=24, @indesirable='Vomissement', @nbDex=10, @nbPtvie=40;
EXECUTE ajouterMedicament @nom='Stimpak', @qtStock=200, @prix=70, @poids=4, @effet='soigne les seignements', @dureEffet=100, @indesirable='Vision flou', @nbDex=5, @nbPtvie=45;
EXECUTE ajouterMedicament @nom='Serum', @qtStock=12, @prix=60, @poids=1, @effet='se régénérer', @dureEffet=100, @indesirable='aucun', @nbDex=2, @nbPtvie=40;
EXECUTE ajouterMedicament @nom='Vim', @qtStock=5, @prix=50, @poids=2, @effet='reposant', @dureEffet=24, @indesirable='aucun', @nbDex=5, @nbPtvie=20;

-- insertion de la nourriture finale
EXECUTE ajouterNourriture @nom="Pâtée pour chien", @qtStock=30, @prix=6, @poids=2, @calorie=30, @nbDex=3, @nbPtvie=10
EXECUTE ajouterNourriture @nom="Viande de Lophius", @qtStock=20, @prix=30, @poids=3, @calorie=200, @nbDex=8, @nbPtvie=5

-- 6
-- vue pour les armes
GO
CREATE OR ALTER VIEW v_Armes AS
SELECT i.nom, i.qtStock, i.prix AS prixUnitaire, a.portee, a.degat, a.forceRequise
FROM Items i
JOIN Armes a ON i.idItem = a.idItem;

-- vue pour les armures
GO
CREATE OR ALTER VIEW v_Armures AS
SELECT i.nom, i.qtStock, i.prix AS prixUnitaire, a.matiere, a.taille, td.nomDegat, ra.degre
FROM Items i
JOIN Armures a ON i.idItem = a.idItem
LEFT JOIN ResitanceArmures ra ON a.idItem = ra.idItem
LEFT JOIN typeDegats td ON ra.codeDegat = td.codeDegat;

-- vue pour la nourriture
GO
CREATE OR ALTER VIEW v_Nourritures AS
SELECT i.nom, i.qtStock, i.prix AS prixUnitaire, n.calorie, n.nbDex, n.nbPtvie
FROM Items i
JOIN Nourritures n ON i.idItem = n.idItem;

-- vue pour les médicamments
GO
CREATE OR ALTER VIEW v_Medicaments AS
SELECT i.nom, i.qtStock, i.prix AS prixUnitaire, m.effet, m.dureEffet, m.indesirable, m.nbDex, m.nbPtvie
FROM Items i
JOIN Medicaments m ON i.idItem = m.idItem;

-- la procédure
GO
CREATE OR ALTER PROCEDURE afficherItems
    @typeItem CHAR(1)
AS
BEGIN
    IF @typeItem = 'A' SELECT * FROM v_Armes;
    ELSE IF @typeItem = 'R' SELECT * FROM v_Armures;
    ELSE IF @typeItem = 'N' SELECT * FROM v_Nourritures;
    ELSE IF @typeItem = 'M' SELECT * FROM v_Medicaments;
    ELSE RAISERROR ('Type d''item invalide. Utilisez ''A'', ''R'', ''N'' ou ''M''.', 16, 1);
END;

-- les tests!
EXEC afficherItems @typeItem = 'A';
EXEC afficherItems @typeItem = 'R';
EXEC afficherItems @typeItem = 'N';
EXEC afficherItems @typeItem = 'M';

-- 7
GO
CREATE OR ALTER FUNCTION prixMoyen()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        CASE i.typeItem
            WHEN 'A' THEN 'Armes'
            WHEN 'R' THEN 'Armures'
            WHEN 'M' THEN 'Medicaments'
            WHEN 'N' THEN 'Nourritures'
        END AS typeItem, AVG(i.prix) AS moyennePrix FROM Items i
    GROUP BY i.typeItem
);

-- test
GO 
SELECT * FROM dbo.prixMoyen();

-- 8
GO
CREATE OR ALTER FUNCTION meilleureResistance
(
    @nomDegat VARCHAR(60)
)
RETURNS TABLE 
AS
RETURN
(
    SELECT 
    i.nom, td.nomDegat, ra.degre FROM ResitanceArmures ra
    JOIN Armures a ON ra.idItem = a.idItem
    JOIN Items i ON a.idItem = i.idItem
    JOIN typeDegats td ON ra.codeDegat = td.codeDegat
    WHERE td.nomDegat = @nomDegat AND ra.degre = (
          SELECT MAX(ra2.degre) FROM ResitanceArmures ra2 -- on trouve la plus grande valeur de degre pour ce dégât
          JOIN typeDegats td2 ON ra2.codeDegat = td2.codeDegat
          WHERE td2.nomDegat = @nomDegat
      )
);

-- test
GO
SELECT * FROM dbo.meilleureResistance('Laser');