-- Partie 1 / Triggers
USE BDWillow;

-- 1
GO
CREATE OR ALTER TRIGGER CTRLinsertMage
ON Alchimistes
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Mages m ON i.idAlchimiste = m.idMage
    )
    BEGIN
        ROLLBACK;
        RAISERROR('Erreur : Un mage ne peut pas être inséré dans la table Alchimistes.', 16, 1);
    END
END;

-- 2
GO
CREATE OR ALTER TRIGGER CTRLinsertAlchimiste
ON Mages
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Alchimistes a ON i.idMage = a.idAlchimiste
    )
    BEGIN
        ROLLBACK;
        RAISERROR('Erreur : Un alchimiste ne peut pas être inséré dans la table Mages.', 16, 1);
    END
END;

-- 3
GO
CREATE OR ALTER TRIGGER CTRLptDegat
ON LancerSort
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Sorts s ON i.idSort = s.idSort
        WHERE i.nbPtDegat < s.nbDegaMin 
           OR i.nbPtDegat > s.nbDegaMax
    )
    BEGIN
        ROLLBACK;
        RAISERROR('Erreur : Le nombre de dégâts doit être compris entre nbDegaMin et nbDegaMax du sort.', 16, 1);
    END
END;

-- 4
GO
CREATE OR ALTER TRIGGER CascadeDeleteCategorie
ON Categories
INSTEAD OF DELETE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE Mages
        SET idCategorie = NULL
        FROM Mages m
        INNER JOIN deleted d ON m.idCategorie = d.idCategorie;

        DELETE FROM Categories
        WHERE idCategorie IN (SELECT idCategorie FROM deleted);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END;

-- 5
GO
CREATE OR ALTER TRIGGER CascadeDeleteJoueur
ON Joueurs
INSTEAD OF DELETE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM LancerSort
        WHERE idMage IN (SELECT idJoueur FROM deleted);

        DELETE FROM Mages
        WHERE idMage IN (SELECT idJoueur FROM deleted);

        DELETE FROM Alchimistes
        WHERE idAlchimiste IN (SELECT idJoueur FROM deleted);

        DELETE FROM Joueurs
        WHERE idJoueur IN (SELECT idJoueur FROM deleted);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END;

-- Partie 2 / Compréhension
/*
-- 1
on utilise un TRIGGER (pas mal certain qu'un CHECK ne pourrait pas comparer le mana de deux mages différents..)

-- 2
on peut utiliser une contrainte CHECK ici

-- 3
parce qu'il n'y a pas seulement ajouterMages pour ajouter des Mages.. question de ne pas avoir d'alchimiste dans la table de mages

-- 4
les FOREIGN KEYs auraient empêcher le TRIGGER AFTER

*/