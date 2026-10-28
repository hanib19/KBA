-- Par Hani Belkhir / TP1 (Groupe 4)
-- les insertions données dans les énoncés ne sont pas incluses 
USE DbKnapsak;

-- 1
GO
CREATE OR ALTER FUNCTION montantPanier
(
    @alias VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @montantTotal INT;
    SELECT @montantTotal = ISNULL(SUM(p.qtItemPanier * i.prix), 0) FROM Paniers p
    JOIN Items i ON p.idItem = i.idItem
    JOIN Joueurs j ON p.idJoueur = j.idJoueur
    WHERE j.alias = @alias;
    RETURN @montantTotal;
END;

GO
SELECT dbo.montantPanier('Maximus') AS montantTotal;

-- 2
GO
CREATE OR ALTER FUNCTION PoidsPanier
(
    @alias VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @poidsTotal INT;
    SELECT @poidsTotal = ISNULL(SUM(p.qtItemPanier * i.poids), 0) FROM Paniers p
    JOIN Items i ON p.idItem = i.idItem
    JOIN Joueurs j ON p.idJoueur = j.idJoueur
    WHERE j.alias = @alias;
    RETURN @poidsTotal;
END;

GO
SELECT dbo.PoidsPanier('Maximus') AS poidsTotalPanier;

-- 3
GO
CREATE OR ALTER FUNCTION PoidsSacAdos
(
    @alias VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @poidsTotal INT;
    SELECT @poidsTotal = ISNULL(SUM(sa.qtItem * i.poids), 0) FROM SacAdos sa
    JOIN Items i ON sa.idItem = i.idItem
    JOIN Joueurs j ON sa.idJoueur = j.idJoueur
    WHERE j.alias = @alias;
    RETURN @poidsTotal;
END;

GO
SELECT dbo.PoidsSacAdos('Maximus') AS poidsTotalSac;

-- 4
GO
CREATE OR ALTER PROCEDURE ajouterItemPanier
    @alias VARCHAR(50), @idItem INT, @qtItem INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @idJoueur INT, @caps INT, @poidMax INT;
        SELECT @idJoueur = idJoueur, @caps = caps, @poidMax = poidMax FROM Joueurs
        WHERE alias = @alias;

        IF @idJoueur IS NULL
        BEGIN
            RAISERROR ('Joueur introuvable.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        DECLARE @qtStock INT, @prix INT, @poidsUnit INT;
        SELECT @qtStock = qtStock, @prix = prix, @poidsUnit = poids FROM Items WHERE idItem = @idItem;

        IF @qtStock IS NULL
        BEGIN
            RAISERROR ('Item introuvable.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF @qtStock < @qtItem
        BEGIN
            RAISERROR ('Quantité en stock insuffisante.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        DECLARE @montantActuel INT = dbo.montantPanier(@alias);
        DECLARE @coutAjout INT = @qtItem * @prix;

        IF (@montantActuel + @coutAjout) > @caps
        BEGIN
            RAISERROR ('Solde (caps) insuffisant pour couvrir le panier.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        DECLARE @poidsSac INT = dbo.PoidsSacAdos(@alias);
        DECLARE @poidsPanierActuel INT = dbo.PoidsPanier(@alias);
        DECLARE @poidsAjout INT = @qtItem * @poidsUnit;
        DECLARE @poidsTotalPrevu INT = @poidsSac + @poidsPanierActuel + @poidsAjout;

        DECLARE @limitePoids INT = @poidMax * 1.5;

        IF @poidsTotalPrevu > @limitePoids
        BEGIN
            RAISERROR ('Le poids total dépasserait la limite permise (Poids max + 50%%).', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Paniers WHERE idJoueur = @idJoueur AND idItem = @idItem)
        BEGIN
            UPDATE Paniers
            SET qtItemPanier = qtItemPanier + @qtItem 
            WHERE idJoueur = @idJoueur AND idItem = @idItem;
        END
        ELSE
        BEGIN
            INSERT INTO Paniers (idJoueur, idItem, qtItemPanier) VALUES (@idJoueur, @idItem, @qtItem);
        END

        UPDATE Items
        SET qtStock = qtStock - @qtItem WHERE idItem = @idItem;
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
CREATE OR ALTER PROCEDURE supprimerItemPanier
    @idItem INT, @alias VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @idJoueur INT;
        SELECT @idJoueur = idJoueur FROM Joueurs 
        WHERE alias = @alias;

        IF @idJoueur IS NULL
        BEGIN
            RAISERROR ('Joueur introuvable.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        DECLARE @qtDansPanier INT;
        SELECT @qtDansPanier = qtItemPanier FROM Paniers 
        WHERE idJoueur = @idJoueur AND idItem = @idItem;

        IF @qtDansPanier IS NULL
        BEGIN
            RAISERROR ('Cet item n''est pas présent dans le panier du joueur.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        UPDATE Items
        SET qtStock = qtStock + @qtDansPanier
        WHERE idItem = @idItem;

        DELETE FROM Paniers
        WHERE idJoueur = @idJoueur AND idItem = @idItem;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
        THROW;
    END CATCH
END;

-- 6
GO
CREATE OR ALTER FUNCTION afficherPanier
(
    @alias VARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        i.nom,
        CASE i.typeItem
            WHEN 'A' THEN 'Arme'
            WHEN 'R' THEN 'Armure'
            WHEN 'N' THEN 'Nourriture'
            WHEN 'M' THEN 'Medicament'
        END AS typeItem, p.qtItemPanier AS quantite, (p.qtItemPanier * i.prix) AS prixTotal FROM Paniers p
    JOIN Items i ON p.idItem = i.idItem
    JOIN Joueurs j ON p.idJoueur = j.idJoueur
    WHERE j.alias = @alias
);

GO
SELECT * FROM dbo.afficherPanier('Maximus');

-- 7
GO
CREATE OR ALTER PROCEDURE payerPanier
    @alias VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @idJoueur INT, @caps INT, @dexterite INT, @poidMax INT;
        SELECT @idJoueur = idJoueur, @caps = caps, @dexterite = dexterite, @poidMax = poidMax FROM Joueurs
        WHERE alias = @alias;

        IF @idJoueur IS NULL
        BEGIN
            RAISERROR ('Joueur introuvable.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Paniers WHERE idJoueur = @idJoueur)
        BEGIN
            RAISERROR ('Le panier du joueur est vide.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        DECLARE @idItem INT, @qtItemPanier INT, @prixUnit INT, @poidsUnit INT;
        DECLARE @montantTotalPanier INT = 0;
        DECLARE @poidsTotalPanier INT = 0;

        DECLARE curseurPanier CURSOR FOR
            SELECT p.idItem, p.qtItemPanier, i.prix, i.poids FROM Paniers p
            JOIN Items i ON p.idItem = i.idItem
            WHERE p.idJoueur = @idJoueur;

        OPEN curseurPanier;

        FETCH NEXT FROM curseurPanier INTO @idItem, @qtItemPanier, @prixUnit, @poidsUnit;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @montantTotalPanier = @montantTotalPanier + (@qtItemPanier * @prixUnit);
            SET @poidsTotalPanier = @poidsTotalPanier + (@qtItemPanier * @poidsUnit);

            IF EXISTS (SELECT 1 FROM SacAdos WHERE idJoueur = @idJoueur AND idItem = @idItem)
            BEGIN
                UPDATE SacAdos
                SET qtItem = qtItem + @qtItemPanier
                WHERE idJoueur = @idJoueur AND idItem = @idItem;
            END
            ELSE
            BEGIN
                INSERT INTO SacAdos (idJoueur, idItem, qtItem) VALUES (@idJoueur, @idItem, @qtItemPanier);
            END

            FETCH NEXT FROM curseurPanier INTO @idItem, @qtItemPanier, @prixUnit, @poidsUnit;
        END

        CLOSE curseurPanier;
        DEALLOCATE curseurPanier;

        UPDATE Joueurs
        SET caps = caps - @montantTotalPanier
        WHERE idJoueur = @idJoueur;

        DECLARE @poidsSacExistant INT = dbo.PoidsSacAdos(@alias); 
        
        IF @poidsSacExistant > @poidMax
        BEGIN
            DECLARE @depassement INT = @poidsSacExistant - @poidMax;

            UPDATE Joueurs
            SET dexterite = CASE 
                                WHEN dexterite - @depassement < 0 THEN 0 
                                ELSE dexterite - @depassement 
                            END
            WHERE idJoueur = @idJoueur;
        END

        DELETE FROM Paniers
        WHERE idJoueur = @idJoueur;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
        THROW;
    END CATCH
END;

-- 8
GO
CREATE OR ALTER PROCEDURE supprimerPanier
    @alias VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @idJoueur INT;
        SELECT @idJoueur = idJoueur FROM Joueurs 
        WHERE alias = @alias;

        IF @idJoueur IS NULL
        BEGIN
            RAISERROR ('Joueur introuvable.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Paniers WHERE idJoueur = @idJoueur)
        BEGIN
            RAISERROR ('Le panier du joueur est déjà vide.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        DECLARE @idItem INT, @qtItemPanier INT;

        DECLARE curseurAbandon CURSOR FOR
            SELECT idItem, qtItemPanierFROM Paniers
            WHERE idJoueur = @idJoueur;

        OPEN curseurAbandon;

        FETCH NEXT FROM curseurAbandon INTO @idItem, @qtItemPanier;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Items
            SET qtStock = qtStock + @qtItemPanier
            WHERE idItem = @idItem;

            FETCH NEXT FROM curseurAbandon INTO @idItem, @qtItemPanier;
        END

        CLOSE curseurAbandon;
        DEALLOCATE curseurAbandon;

        DELETE FROM Paniers
        WHERE idJoueur = @idJoueur;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
        THROW;
    END CATCH
END;

-- 9
GO
CREATE OR ALTER PROCEDURE mangerNourriture
    @alias VARCHAR(50), @idItem INT, @qtItem INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @idJoueur INT;
        SELECT @idJoueur = idJoueur FROM Joueurs 
        WHERE alias = @alias;

        IF @idJoueur IS NULL
        BEGIN
            RAISERROR ('Joueur introuvable.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        DECLARE @gainDex INT, @gainVie INT;
        SELECT @gainDex = nbDex, @gainVie = nbPtvie FROM Nourritures
        WHERE idItem = @idItem;

        IF @gainDex IS NULL
        BEGIN
            RAISERROR ('Cet item n''est pas de la nourriture ou n''existe pas.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        DECLARE @qtEnSac INT;
        SELECT @qtEnSac = qtItem FROM SacAdos
        WHERE idJoueur = @idJoueur AND idItem = @idItem;

        IF @qtEnSac IS NULL OR @qtEnSac < @qtItem
        BEGIN
            RAISERROR ('La quantité de nourriture dans le sac à dos est insuffisante.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        UPDATE Joueurs
        SET dexterite = dexterite + (@gainDex * @qtItem),
            nbPtvie   = nbPtvie + (@gainVie * @qtItem)
        WHERE idJoueur = @idJoueur;

        IF @qtEnSac = @qtItem
        BEGIN
            DELETE FROM SacAdos
            WHERE idJoueur = @idJoueur AND idItem = @idItem;
        END
        ELSE
        BEGIN
            UPDATE SacAdos
            SET qtItem = qtItem - @qtItem
            WHERE idJoueur = @idJoueur AND idItem = @idItem;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
        THROW;
    END CATCH
END;

-- 10
GO
CREATE OR ALTER PROCEDURE seSoigner
    @alias VARCHAR(50), @idItem INT, @qtItem INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @idJoueur INT;
        SELECT @idJoueur = idJoueur FROM Joueurs 
        WHERE alias = @alias;

        IF @idJoueur IS NULL
        BEGIN
            RAISERROR ('Joueur introuvable.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        DECLARE @gainDex INT, @gainVie INT;
        SELECT @gainDex = nbDex, @gainVie = nbPtvie FROM Medicaments
        WHERE idItem = @idItem;

        IF @gainDex IS NULL
        BEGIN
            RAISERROR ('Cet item n''est pas un médicament ou n''existe pas.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        DECLARE @qtEnSac INT;
        SELECT @qtEnSac = qtItem FROM SacAdos
        WHERE idJoueur = @idJoueur AND idItem = @idItem;

        IF @qtEnSac IS NULL OR @qtEnSac < @qtItem
        BEGIN
            RAISERROR ('La quantité de médicament dans le sac à dos est insuffisante.', 16, 1);
            IF @@TRANCOUNT > 0 
            ROLLBACK;
            RETURN;
        END

        UPDATE Joueurs
        SET dexterite = dexterite + (@gainDex * @qtItem), 
            nbPtvie = nbPtvie + (@gainVie * @qtItem)
        WHERE idJoueur = @idJoueur;

        IF @qtEnSac = @qtItem
        BEGIN
            DELETE FROM SacAdos
            WHERE idJoueur = @idJoueur AND idItem = @idItem;
        END
        ELSE
        BEGIN
            UPDATE SacAdos
            SET qtItem = qtItem - @qtItem
            WHERE idJoueur = @idJoueur AND idItem = @idItem;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
        THROW;
    END CATCH
END;

-- 11
GO
CREATE OR ALTER FUNCTION afficherSacAdos
(
    @alias VARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        j.alias,
        i.nom,
        CASE i.typeItem
            WHEN 'A' THEN 'Arme'
            WHEN 'R' THEN 'Armure'
            WHEN 'N' THEN 'Nourriture'
            WHEN 'M' THEN 'Medicament'
        END AS typeItem, sa.qtItem AS quantite FROM SacAdos sa
    JOIN Items i ON sa.idItem = i.idItem
    JOIN Joueurs j ON sa.idJoueur = j.idJoueur
    WHERE j.alias = @alias
);

-- 12
GO
CREATE TRIGGER cascadeDeleteItem
ON Items
INSTEAD OF DELETE
AS
BEGIN
    UPDATE i
    SET i.flagDispo = 0 FROM Items i
    JOIN deleted d ON i.idItem = d.idItem
    WHERE EXISTS (
        SELECT 1 FROM SacAdos sa 
        WHERE sa.idItem = d.idItem
    );

    DELETE FROM Paniers
    WHERE idItem IN (
        SELECT d.idItem FROM deleted d
        WHERE NOT EXISTS (
            SELECT 1 FROM SacAdos sa 
            WHERE sa.idItem = d.idItem
        )
    );

    DELETE FROM Armes 
    WHERE idItem IN (
        SELECT d.idItem FROM deleted d 
        WHERE NOT EXISTS (SELECT 1 FROM SacAdos sa WHERE sa.idItem = d.idItem)
    );

    DELETE FROM ResitanceArmures 
    WHERE idItem IN (
        SELECT d.idItem FROM deleted d 
        WHERE NOT EXISTS (SELECT 1 FROM SacAdos sa WHERE sa.idItem = d.idItem)
    );

    DELETE FROM Armures 
    WHERE idItem IN (
        SELECT d.idItem FROM deleted d 
        WHERE NOT EXISTS (SELECT 1 FROM SacAdos sa WHERE sa.idItem = d.idItem)
    );

    DELETE FROM Nourritures 
    WHERE idItem IN (
        SELECT d.idItem FROM deleted d 
        WHERE NOT EXISTS (SELECT 1 FROM SacAdos sa WHERE sa.idItem = d.idItem)
    );

    DELETE FROM Medicaments 
    WHERE idItem IN (
        SELECT d.idItem FROM deleted d 
        WHERE NOT EXISTS (SELECT 1 FROM SacAdos sa WHERE sa.idItem = d.idItem)
    );

    DELETE FROM Items
    WHERE idItem IN (
        SELECT d.idItem FROM deleted d
        WHERE NOT EXISTS (
            SELECT 1 FROM SacAdos sa 
            WHERE sa.idItem = d.idItem
        )
    );
END;

-- 13
GO
CREATE TRIGGER CTRLPrixItem
ON Items
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN deleted d ON i.idItem = d.idItem
        WHERE i.prix < d.prix
    )
    BEGIN
        RAISERROR ('Le prix d''un item ne peut pas être révisé à la baisse.', 16, 1);
        ROLLBACK;
        RETURN;
    END
END;