-- Partie 1
CREATE DATABASE BDWillow;
USE BDWillow;
-- toutes les créations de tables ainsi que les insertions sont trouvés sur ScriptLabo2.sql

----- Partie 2
-- 1
GO
CREATE OR ALTER PROCEDURE ajouterMage
@alias VARCHAR(10), @idCategorie CHAR(1), @mana INT, @nbPtVie INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Joueurs (alias, nbPtVie, typeJoueur) VALUES (@alias, @nbPtVie, 'M');

        DECLARE @newId INT;

        INSERT INTO Mages (idMage, idCategorie, mana ) VALUES (@newId, @idCategorie, @mana);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
    END CATCH
END 

-- 2
GO
CREATE OR ALTER PROCEDURE ajouterAlchimiste
@alias VARCHAR(10), @typePotion CHAR(1), @niveau INT, @nbPtVie INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Joueurs (alias, nbPtVie, typeJoueur) VALUES (@alias, @nbPtVie, 'A');

        DECLARE @newId INT;

        INSERT INTO Alchimistes (idAlchimiste, niveau, typePotion) VALUES (@newId, @niveau, @typePotion);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
    END CATCH
END

-- 3
GO
CREATE OR ALTER PROCEDURE ListeJoueurs
@typeJoueur CHAR(1)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
    SELECT 
        j.alias, j.nbPtVie, m.mana, c.nomCategorie, a.niveau,
        CASE a.typePotion
            WHEN 'A' THEN 'Attaque'
            WHEN 'D' THEN 'Défense'
            WHEN 'T' THEN 'pour Tout'
            ELSE NULL
        END AS NomTypePotion
    FROM Joueurs j
    LEFT JOIN Mages m ON j.idJoueur = m.idMage
    LEFT JOIN Categories c ON m.idCategorie = c.idCategorie
    LEFT JOIN Alchimistes a ON j.idJoueur = a.idAlchimiste
    WHERE j.typeJoueur = @typeJoueur;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
    END CATCH
END

-- 4
GO
CREATE OR ALTER PROCEDURE LancerUnSort
@idMage INT, @idSort INT, @nbDegaInflige INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @coutMana INT;
        SELECT @coutMana = coutMana FROM Sorts WHERE idSort = @idSort;

        IF EXISTS (SELECT 1 FROM LancerSort WHERE idMage = @idMage AND idSort = @idSort)
        BEGIN
            UPDATE LancerSort
            SET nbPtDegat = nbPtDegat + @nbDegaInflige
            WHERE idMage = @idMage AND idSort = @idSort;
        END
        ELSE
        BEGIN
            INSERT INTO LancerSort (idMage, idSort, nbPtDegat) VALUES (@idMage, @idSort, @nbDegaInflige);
        END

        UPDATE Mages SET mana = mana - @coutMana WHERE idMage = @idMage;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
    END CATCH
END

-- 5
GO
CREATE OR ALTER FUNCTION listeMages()
RETURNS TABLE
AS
RETURN
(
    SELECT j.alias, m.mana, j.nbPtVie, c.nomCategorie
    FROM Mages m
    INNER JOIN Joueurs j ON m.idMage = j.idJoueur
    LEFT JOIN Categories c ON m.idCategorie = c.idCategorie
);

-- 6
GO
CREATE OR ALTER FUNCTION degatsTotal(@alias VARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @totalDegats INT;

    SELECT @totalDegats = ISNULL(SUM(ls.nbPtDegat), 0)
    FROM Joueurs j
    INNER JOIN Mages m ON j.idJoueur = m.idMage
    INNER JOIN LancerSort ls ON m.idMage = ls.idMage
    WHERE j.alias = @alias;

    RETURN @totalDegats;
END;

-- 7 (pour exécuter les questions précédentes)
GO -- 1
EXEC ajouterMage @alias = 'Merlin', @idCategorie = 'F', @mana = 1200, @nbPtVie = 100; 

GO -- 2
EXEC ajouterAlchimiste @alias = 'Mixix', @typePotion = 'A', @niveau = 2, @nbPtVie = 100; 

GO -- 3
EXEC ListeJoueurs @typeJoueur = 'M'; 
EXEC ListeJoueurs @typeJoueur = 'A'; -- on essaye avec les alchimistes

GO -- 4
EXEC LancerUnSort @idMage = 1, @idSort = 1000, @nbDegaInflige = 150;
EXEC LancerUnSort @idMage = 1, @idSort = 1001, @nbDegaInflige = 450; -- on fait un deuxième sort!

GO -- 5
SELECT * FROM listeMages();

GO -- 6
SELECT dbo.degatsTotal('Wilow') AS TotalDegats_Wilow;
SELECT dbo.degatsTotal('Madow') AS TotalDegats_Madow; -- et pour un mage qui n'a rien fait..