---- N'oubliez pas le USE
CREATE DATABASE DbKnapsak;
USE DbKnapsak;

--- Les DROP.
/*
drop table SacAdos;
drop table Paniers;
drop table joueurs;
drop table Armes;
drop table ResitanceArmures;
drop table TypeDegats;
drop table Armures;
drop table Nourritures;
drop table Medicaments;
drop table Items;
*/
---------------Les CREATE
---Table Joueurs
create table Joueurs 
(
	idJoueur int identity(100,1),
	alias varchar(50) unique not null ,
	nom varchar(30),
	prenom varchar(30),
	caps int not null default 1000,
	nbPtvie int not null default 50,
	dexterite smallint not null default 100,
	poidMax int not null default 50,
	constraint pkJoueurs primary key(idJoueur),
	constraint ckMontantJoueurs check(caps >= 0),
	constraint ckvie check(nbPtvie>=0),
	constraint ckDex check(dexterite>=0),
	constraint ckPoidmax check(dexterite>=1),
);
---Table Items
create table Items 
(
	idItem int identity(1,1),
	nom varchar(30) not null,
	qtStock int not null,
	prix int not null,
	typeItem char(1) not null,
	flagDispo int not null default 1,
	poids int not null,
	constraint pkItems primary key(idItem),
	constraint ckType check(typeItem IN('A','R','M','N')),
	constraint ckQtStock check(qtStock >= 0),
	constraint ckFlagDispo check(flagDispo IN(0,1)),
	constraint ckPoids check(poids>=1)
);
----Table Panier
create table Paniers 
(
	idJoueur int not null,
	idItem int not null,
	qtItemPanier int not null,
	constraint pkPaniers primary key(idJoueur,idItem),
	constraint fkPaniersJoueurs foreign key(idJoueur) references Joueurs(idJoueur),
	constraint fkPaniersItems foreign key(idItem) references Items(idItem),
	constraint ckQttItemPaniers check(qtItemPanier >= 0)
);

---Table SacAdos
create table SacAdos
(
	idJoueur int not null,
	idItem int not null,
	qtItem int not null,
	constraint pkInventaire primary key(idJoueur,idItem),
	constraint fkItemsInventaire foreign key(idItem) references Items(idItem),
	constraint fkIdJoueur foreign key(idJoueur) references Joueurs(idJoueur),
	constraint ckQttItemInventaire check(qtItem >= 0)
);

--- Table Armes
create table Armes 
(
	idItem int not null,
	portee int not null,
	degat int not null,
	forceRequise int not null,
	constraint pkArmes primary key(idItem),
	constraint fkArmesItems foreign key(idItem) references Items(idItem)
);
--Table Armures
create table Armures (
idItem int not null,
matiere varchar(30) not null,
taille int not null,
constraint pkArmures primary key(idItem),
constraint fkArmuresItems foreign key(idItem) references Items(idItem)
);

-----Table TypeDegats
go
create table typeDegats
(
codeDegat char(3) not null,
nomDegat varchar(60) not null,
constraint pk_Ddegat primary key(codeDegat));

----Table ResistanceArmure
go
create table ResitanceArmures
(
codeDegat char(3) not null,
idItem int not null,
degre smallint not null,
constraint pk_resistance primary key(codeDegat,idItem),
constraint fk_resArmure foreign key (idItem) references Armures(idItem),
constraint fk_resDegat foreign key (codeDegat) references TypeDegats(codeDegat)
);

---Table Nourritures
create table Nourritures
(
idItem int not null,
calorie int not null,
nbDex int not null,
nbPtvie int not null,
constraint Ck_nbDexNour check (nbDex>=1),
constraint Ck_vieNour check (nbPtvie>=1),
constraint pk_Nourritur primary key(idItem),
constraint fkNourCons foreign key(idItem) references Items(idItem)
);
--- Table Medicaments
create table Medicaments
(idItem int not null,
 effet varchar(50),
 dureEffet int not null,
 indesirable varchar(30) not null,
 nbDex int not null,
 nbPtvie int not null,
constraint Ck_nbDexMedoc check (nbDex>=1),
constraint Ck_vieMedoc check (nbPtvie>=1),
constraint pk_medic primary key(idItem),
constraint fkMedicItem foreign key(idItem) references Items(idItem)
 );

insert into Joueurs(alias,nom,prenom) values('Maximus','Moeton','Aron');
insert into Joueurs(alias,nom,prenom) values('LaGoule','Walton','Kelly');
insert into Joueurs(alias,nom,prenom) values('Patoche','Patoche','Alain');
insert into Joueurs(alias,nom,prenom) values('Saturne','Lune','Bidou');
insert into Joueurs(alias,nom,prenom) values('Simba','Leroi','Lion');
insert into Joueurs(alias,nom,prenom) values('Tigris','Fafar','Milo');
insert into Joueurs(alias,nom,prenom) values('Tenebrus','Sparo','Jack');
insert into Joueurs(alias,nom,prenom) values('Modavere','Hello','Zack');

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
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- 2
GO
CREATE TRIGGER CTRLPtdeVie
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
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- 3
GO
CREATE TRIGGER CTRLInsertArme
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
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- 4
GO
CREATE TRIGGER CTRLInsertArmure
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
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- 5 (tests)
-- test pour CTRLPrixArme
-- 1. Insertion d'une nourriture à 100$
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES ('Pomme', 10, 100, 'N', 1);

-- 2. ÉCHEC attendu : Arme avec un prix <= 100
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES ('Épée en bois', 5, 80, 'A', 2);

-- 3. SUCCÈS attendu : Arme avec un prix > 100
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES ('Épée de fer', 5, 250, 'A', 3);


-- test pour CTRLPtdeVie
-- ID d'un item Nourriture (ex: idItem = 1)
INSERT INTO Nourritures (idItem, calorie, nbDex, nbPtvie) VALUES (1, 200, 1, 15);

-- Crée un item Médicament dans Items
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES ('Sirop', 5, 50, 'M', 1); -- idItem = 3

-- 1. ÉCHEC attendu : Médicament redonnant <= 15 PV
INSERT INTO Medicaments (idItem, effet, dureEffet, indesirable, nbDex, nbPtvie) VALUES (3, 'Soin basique', 10, 'Somnolence', 1, 10);

-- 2. SUCCÈS attendu : Médicament redonnant > 15 PV
INSERT INTO Medicaments (idItem, effet, dureEffet, indesirable, nbDex, nbPtvie) VALUES (3, 'Soin puissant', 10, 'Aucun', 1, 50);


-- test pour CTRLInsertArme et CTRLInsertArmure
-- Préparation d'un item de type Armure dans Items
INSERT INTO Items (nom, qtStock, prix, typeItem, poids) VALUES ('Casque Fer', 2, 30, 'R', 4); -- idItem = 4

-- Insertion légitime dans Armures
INSERT INTO Armures (idItem, matiere, taille) VALUES (4, 'Acier', 42);

-- 1. ÉCHEC attendu (CTRLInsertArme) : Tenter d'insérer l'idItem 4 dans Armes
INSERT INTO Armes (idItem, portee, degat, forceRequise) VALUES (4, 1, 10, 5);

-- Préparation d'un item de type Arme dans Items
-- (idItem = 2 créait déjà une "Épée de fer" dans les tests précédents)
INSERT INTO Armes (idItem, portee, degat, forceRequise) VALUES (2, 2, 35, 12);

-- 2. ÉCHEC attendu (CTRLInsertArmure) : Tenter d'insérer l'idItem 2 dans Armures
INSERT INTO Armures (idItem, matiere, taille) VALUES (2, 'Bronze', 40);

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

        DECLARE @idItem INT;

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

        DECLARE @idItem INT;

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

        DECLARE @idItem INT;

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

        DECLARE @idItem INT;

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

-- insertion dans TypeDegats
insert into TypeDegats values('exp', 'Explosion');
insert into TypeDegats values('feu', 'Tous les feux');
insert into TypeDegats values('pls', 'Plasma');
insert into TypeDegats values('las', 'Laser');
insert into TypeDegats values('ele', 'Electricité');

-- insertion dans la table Resistance
insert into ResitanceArmures values('exp',7,20);
insert into ResitanceArmures values('ele',7,30);
insert into ResitanceArmures values('feu',7,10);
insert into ResitanceArmures values('las',7,20);
insert into ResitanceArmures values('pls',7,10);

insert into ResitanceArmures values('exp',10,60);
insert into ResitanceArmures values('ele',10,50);
insert into ResitanceArmures values('feu',10,60);
insert into ResitanceArmures values('las',10,20);
insert into ResitanceArmures values('pls',10,90);

insert into ResitanceArmures values('exp',8,60);
insert into ResitanceArmures values('ele',8,50);
insert into ResitanceArmures values('feu',8,70);
insert into ResitanceArmures values('las',8,30);
insert into ResitanceArmures values('pls',8,90);

insert into ResitanceArmures values('exp',9,55);
insert into ResitanceArmures values('ele',9,45);
insert into ResitanceArmures values('feu',9,50);
insert into ResitanceArmures values('las',9,30);
insert into ResitanceArmures values('pls',9,70);

-- 6
-- vue pour les armes
GO
CREATE VIEW v_Armes AS
SELECT i.nom, i.qtStock, i.prix AS prixUnitaire, a.portee, a.degat, a.forceRequise
FROM Items i
JOIN Armes a ON i.idItem = a.idItem;

-- vue pour les armures
GO
CREATE VIEW v_Armures AS
SELECT i.nom, i.qtStock, i.prix AS prixUnitaire, a.matiere, a.taille, td.nomDegat, ra.degre
FROM Items i
JOIN Armures a ON i.idItem = a.idItem
LEFT JOIN ResitanceArmures ra ON a.idItem = ra.idItem
LEFT JOIN typeDegats td ON ra.codeDegat = td.codeDegat;

-- vue pour la nourriture
GO
CREATE VIEW v_Nourritures AS
SELECT i.nom, i.qtStock, i.prix AS prixUnitaire, n.calorie, n.nbDex, n.nbPtvie
FROM Items i
JOIN Nourritures n ON i.idItem = n.idItem;

-- vue pour les médicamments
GO
CREATE VIEW v_Medicaments AS
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
CREATE FUNCTION meilleureResistance
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