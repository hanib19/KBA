CREATE DATABASE BDRestos;
USE BDRestos;


GO
CREATE TABLE Categories (
    idCategorie SMALLINT PRIMARY KEY, nomCategorie VARCHAR(30) NOT NULL
);

GO
CREATE TABLE Restaurants (
    idRestaurant INT IDENTITY(1,1) PRIMARY KEY, nomRestaurant VARCHAR(30) NOT NULL,
    adresse VARCHAR(50) NOT NULL, nbEtoiles SMALLINT NOT NULL CHECK (nbEtoiles BETWEEN 1 AND 5),
    prixMoyen MONEY NOT NULL, commentaire VARCHAR(100) NOT NULL,
    idCategorie SMALLINT FOREIGN KEY REFERENCES Categories(idCategorie)
);

INSERT INTO Categories (idCategorie, nomCategorie) VALUES 
(1, 'Cuisine Italienne'), 
(2, 'Cuisine Française'), 
(3, 'Cuisine Variée'), 
(4, 'Cuisine Japonaise');


GO
CREATE OR ALTER PROCEDURE sp_AjouterRestaurant
    @nomRestaurant VARCHAR(30), @adresse VARCHAR(50), @nbEtoiles SMALLINT,
    @prixMoyen MONEY, @commentaire VARCHAR(100), @idCategorie SMALLINT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Restaurants (nomRestaurant, adresse, nbEtoiles, prixMoyen, commentaire, idCategorie) VALUES (@nomRestaurant, @adresse, @nbEtoiles, @prixMoyen, @commentaire, @idCategorie);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
    END CATCH
END;

GO
CREATE OR ALTER PROCEDURE sp_ModifierEtoiles
    @idRestaurant INT, @nbEtoiles SMALLINT
AS
BEGIN
    BEGIN TRY
        UPDATE Restaurants 
        SET nbEtoiles = @nbEtoiles WHERE idRestaurant = @idRestaurant;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK;
    END CATCH
END;



GO
CREATE OR ALTER FUNCTION fn_RechercherTous()
RETURNS TABLE
AS
RETURN (
    SELECT r.idRestaurant, r.nomRestaurant, r.adresse, r.nbEtoiles, r.prixMoyen, r.commentaire, c.nomCategorie FROM Restaurants r
    INNER JOIN Categories c ON r.idCategorie = c.idCategorie
);


GO
CREATE OR ALTER FUNCTION fn_RechercherParCommentaire()
RETURNS TABLE
AS
RETURN (
    SELECT r.nomRestaurant, r.adresse, r.nbEtoiles, r.prixMoyen, r.commentaire, c.nomCategorie FROM Restaurants r
    INNER JOIN Categories c ON r.idCategorie = c.idCategorie
    WHERE r.commentaire LIKE '%excellent%' OR r.commentaire LIKE '%bon%'
);


GO
CREATE OR ALTER FUNCTION fn_RechercherParEtoiles (@nbEtoiles SMALLINT)
RETURNS TABLE
AS
RETURN (
    SELECT nomRestaurant, prixMoyen, nbEtoiles FROM Restaurants
    WHERE nbEtoiles = @nbEtoiles
);


GO
CREATE OR ALTER FUNCTION fn_RechercherParCategorie (@idCategorie SMALLINT)
RETURNS TABLE
AS
RETURN (
    SELECT nomRestaurant, nbEtoiles, prixMoyen, adresse FROM Restaurants
    WHERE idCategorie = @idCategorie
);



GO
EXEC sp_AjouterRestaurant 
    @nomRestaurant = 'La Trattoria', @adresse = '123 Rue Dante, Montréal', @nbEtoiles = 4, @prixMoyen = 45.00, 
    @commentaire = 'Un restaurant italien exceptionnel avec des pâtes fraîches.', @idCategorie = 1;
GO

-- 2. Test d'insertion : Le Petit Bistro
EXEC sp_AjouterRestaurant 
    @nomRestaurant = 'Le Petit Bistro', @adresse = '456 Avenue Laurier, Montréal', @nbEtoiles = 5, @prixMoyen = 85.00, 
    @commentaire = 'Un service remarquable et un repas tout à fait bon et raffiné.', @idCategorie = 2;
GO

-- 3. Test d'insertion : Chez Mario
EXEC sp_AjouterRestaurant 
    @nomRestaurant = 'Chez Mario', @adresse = '789 Boulevard Saint-Laurent, Montréal', @nbEtoiles = 3, @prixMoyen = 30.00,
    @commentaire = 'Correct mais sans plus.', @idCategorie = 1;
GO

-- 4. Test d'insertion : Le Gourmet Express
EXEC sp_AjouterRestaurant 
    @nomRestaurant = 'Le Gourmet Express', @adresse = '321 Rue Sherbrooke, Montréal', @nbEtoiles = 4, @prixMoyen = 55.00, 
    @commentaire = 'Un choix varié et de bons plats.', @idCategorie = 3;
GO
