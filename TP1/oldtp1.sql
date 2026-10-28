USE DbKnapsak;
-- Groupe 2
-- 1
GO
CREATE OR ALTER TRIGGER CTRLPrixArme_Items
ON Items
AFTER INSERT, UPDATE
AS
BEGIN
    -- On vérifie s'il existe une arme dont le prix est inférieur ou égal
    -- au prix maximal des articles d'un autre type (R, M, N).
    IF EXISTS (
        SELECT 1
        FROM Items i
        WHERE i.typeItem = 'A'
          AND i.prix <= ISNULL((
              SELECT MAX(prix) 
              FROM Items 
              WHERE typeItem <> 'A'
          ), 0)
    )
    BEGIN
        RAISERROR ('Le prix des armes (type A) doit être strictement supérieur au prix de tous les autres types d''items.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- 2
GO
CREATE OR ALTER TRIGGER CTRLPtdeVie_Medicaments
ON Medicaments
AFTER INSERT, UPDATE
AS
BEGIN
    -- Vérifie si un médicament inséré/modifié a des PV inférieurs ou égaux
    -- au maximum des points de vie fournis par la nourriture.
    IF EXISTS (
        SELECT 1
        FROM inserted ins
        WHERE ins.nbPtvie <= ISNULL((
            SELECT MAX(nbPtvie) 
            FROM Nourritures
        ), 0)
    )
    BEGIN
        RAISERROR ('Le nombre de points de vie d''un médicament doit être strictement supérieur à celui de n''importe quelle nourriture.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

GO
CREATE OR ALTER TRIGGER CTRLPtdeVie_Nourritures
ON Nourritures
AFTER INSERT, UPDATE
AS
BEGIN
    -- Vérifie si une nourriture a un nombre de points de vie
    -- supérieur ou égal au minimum offert par les médicaments
    IF EXISTS (
        SELECT 1
        FROM inserted n
        WHERE EXISTS (SELECT 1 FROM Medicaments)
          AND n.nbPtvie >= (SELECT MIN(nbPtvie) FROM Medicaments)
    )
    BEGIN
        RAISERROR ('Le nombre de points de vie d''une nourriture doit être strictement inférieur à celui de n''importe quel médicament.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- 3
GO
CREATE OR ALTER TRIGGER CTRLInsertArme
ON Armes
AFTER INSERT, UPDATE
AS
BEGIN
    -- Vérifie si un idItem inséré/modifié dans Armes existe déjà
    -- dans Armures, Medicaments ou Nourritures
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE EXISTS (SELECT 1 FROM Armures a WHERE a.idItem = i.idItem)
           OR EXISTS (SELECT 1 FROM Medicaments m WHERE m.idItem = i.idItem)
           OR EXISTS (SELECT 1 FROM Nourritures n WHERE n.idItem = i.idItem)
    )
    BEGIN
        RAISERROR ('L''item spécifié existe déjà dans une autre catégorie (Armures, Médicaments ou Nourritures). Un item ne peut appartenir qu''à un seul sous-type.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- 4
GO
CREATE OR ALTER TRIGGER CTRLInsertArmure
ON Armures
AFTER INSERT, UPDATE
AS
BEGIN
    -- Vérifie si un idItem inséré/modifié dans Armures existe déjà
    -- dans Armes, Medicaments ou Nourritures
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE EXISTS (SELECT 1 FROM Armes a WHERE a.idItem = i.idItem)
           OR EXISTS (SELECT 1 FROM Medicaments m WHERE m.idItem = i.idItem)
           OR EXISTS (SELECT 1 FROM Nourritures n WHERE n.idItem = i.idItem)
    )
    BEGIN
        RAISERROR ('L''item spécifié existe déjà dans une autre catégorie (Armes, Médicaments ou Nourritures). Un item ne peut appartenir qu''à un seul sous-type.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- 5 (tests)
-- on va faire l'insertion d'items génériques de départ
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES 
('Pomme', 10, 5, 'N', 1),
('Aspirine', 5, 10, 'M', 1),
('Épée en fer', 2, 50, 'A', 5),
('Bouclier en bois', 1, 30, 'R', 8);   


-- pour trigger 1
-- ❌ TEST ÉCHEC : Insertion d'une arme à 8$ alors que le max hors-arme est 10$ (Aspirine)
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) 
VALUES ('Dague en bois', 1, 8, 'A', 2);

--  TEST REUSSITE : Insertion d'une arme avec prix > max des autres items (ex: Hache à 15$)
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) 
VALUES ('Hache de guerre', 1, 15, 'A', 6);


-- pour trigger 2
--- TEST MEDECINE ---
-- ❌ TEST ÉCHEC : Ajout d'un médicament apportant 5 PV (inférieur aux 10 PV de la Pomme)
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES ('Sirop léger', 5, 8, 'M', 1); -- idItem = 6
INSERT INTO Medicaments (idItem, effet, dureEffet, indesirable, nbDex, nbPtvie) 
VALUES (6, 'Petit soin', 10, 'Aucun', 1, 5);

--  TEST REUSSITE : Ajout d'un médicament apportant 40 PV (> 10 PV)
INSERT INTO Medicaments (idItem, effet, dureEffet, indesirable, nbDex, nbPtvie) 
VALUES (6, 'Giga Soin', 10, 'Aucun', 1, 40);


-- pour trigger 3
--- TEST NOURRITURE ---
-- ❌ TEST ÉCHEC : Ajout d'une nourriture apportant 30 PV (supérieur au minimum des médicaments qui est de 25 PV)
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES ('Steak magique', 2, 6, 'N', 2); -- idItem = 7
INSERT INTO Nourritures (idItem, calorie, nbDex, nbPtvie) 
VALUES (7, 500, 1, 30);

--  TEST REUSSITE : Ajout d'une nourriture apportant 15 PV (< 25 PV)
INSERT INTO Nourritures (idItem, calorie, nbDex, nbPtvie) 
VALUES (7, 200, 1, 15);


-- ❌ TEST ÉCHEC : Tenter d'ajouter un idItem d'Armure (idItem = 4) dans la table Armes
INSERT INTO Armes (idItem, portee, degat, forceRequise) 
VALUES (4, 1, 5, 2);

-- ❌ TEST ÉCHEC : Tenter d'ajouter un idItem de Nourriture (idItem = 1) dans la table Armes
INSERT INTO Armes (idItem, portee, degat, forceRequise) 
VALUES (1, 1, 2, 1);

--  TEST REUSSITE : Insérer une arme valide (idItem = 5 créé lors du test 1)
INSERT INTO Armes (idItem, portee, degat, forceRequise) 
VALUES (5, 2, 35, 12);


-- pour trigger 4
-- ❌ TEST ÉCHEC : Tenter d'ajouter un idItem d'Arme (idItem = 3) dans la table Armures
INSERT INTO Armures (idItem, matiere, taille) 
VALUES (3, 'Acier', 3);

-- ❌ TEST ÉCHEC : Tenter d'ajouter un idItem de Médicament (idItem = 2) dans la table Armures
INSERT INTO Armures (idItem, matiere, taille) 
VALUES (2, 'Tissu', 1);

--  TEST REUSSITE : Créer un nouvel item de type Armure puis l'insérer dans Armures
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES ('Casque en fer', 1, 20, 'R', 3); -- idItem = 8
INSERT INTO Armures (idItem, matiere, taille) 
VALUES (8, 'Fer', 2);

