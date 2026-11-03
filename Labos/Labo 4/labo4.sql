-- Par Hani Belkhir & Ahmed Nabil
CREATE DATABASE BDRestos;
USE BDRestos;

DROP TABLE Restaurants;
DROP TABLE Categories;

GO
CREATE TABLE Categories (
    idCategorie INT PRIMARY KEY, nomCategorie VARCHAR(30) NOT NULL
);

GO
CREATE TABLE Restaurants (
    idRestaurant INT IDENTITY(1,1) PRIMARY KEY, nomRestaurant VARCHAR(30) NOT NULL,
    adresse VARCHAR(50) NOT NULL, nbEtoiles INT NOT NULL CHECK (nbEtoiles BETWEEN 1 AND 5),
    prixMoyen MONEY NOT NULL, commentaire VARCHAR(100) NOT NULL,
    idCategorie INT FOREIGN KEY REFERENCES Categories(idCategorie)
);

INSERT INTO Categories (idCategorie, nomCategorie) VALUES (1, 'Cuisine Italienne');
INSERT INTO Categories (idCategorie, nomCategorie) VALUES (2, 'Cuisine Française');
INSERT INTO Categories (idCategorie, nomCategorie) VALUES (3, 'Cuisine Variée'); 
INSERT INTO Categories (idCategorie, nomCategorie) VALUES (4, 'Cuisine Japonaise');


GO
CREATE OR ALTER PROCEDURE AjouterRestaurant
    @nomRestaurant VARCHAR(30), @adresse VARCHAR(50), @nbEtoiles INT,
    @prixMoyen MONEY, @commentaire VARCHAR(100), @idCategorie INT
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
CREATE OR ALTER PROCEDURE ModifierEtoiles
    @idRestaurant INT, @nbEtoiles INT
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
CREATE OR ALTER FUNCTION RechercherTous()
RETURNS TABLE
AS
RETURN (
    SELECT r.idRestaurant, r.nomRestaurant, r.adresse, r.nbEtoiles, r.prixMoyen, r.commentaire, c.nomCategorie FROM Restaurants r
    INNER JOIN Categories c ON r.idCategorie = c.idCategorie
);

GO
SELECT * FROM RechercherTous();

GO
CREATE OR ALTER FUNCTION RechercherParCommentaire()
RETURNS TABLE
AS
RETURN (
    SELECT r.nomRestaurant, r.adresse, r.nbEtoiles, r.prixMoyen, r.commentaire, c.nomCategorie FROM Restaurants r
    INNER JOIN Categories c ON r.idCategorie = c.idCategorie
    WHERE r.commentaire LIKE '%excellent%' OR r.commentaire LIKE '%bon%'
);

GO
SELECT * FROM RechercherParCommentaire();

GO
CREATE OR ALTER FUNCTION RechercherParEtoiles (@nbEtoiles INT)
RETURNS TABLE
AS
RETURN (
    SELECT nomRestaurant, prixMoyen, nbEtoiles FROM Restaurants
    WHERE nbEtoiles = @nbEtoiles
);


GO
SELECT * FROM RechercherParEtoiles(5);

GO
CREATE OR ALTER FUNCTION RechercherParCategorie (@idCategorie INT)
RETURNS TABLE
AS
RETURN (
    SELECT nomRestaurant, nbEtoiles, prixMoyen, adresse FROM Restaurants
    WHERE idCategorie = @idCategorie
);

GO
SELECT * FROM RechercherParCategorie(1);


GO
EXEC AjouterRestaurant 
    @nomRestaurant = 'La Trattoria', @adresse = '123 Rue Dante, Montréal', @nbEtoiles = 4, @prixMoyen = 45.00, 
    @commentaire = 'Un restaurant italien exceptionnel avec des pâtes fraîches.', @idCategorie = 1;


GO
EXEC AjouterRestaurant 
    @nomRestaurant = 'Le Petit Bistro', @adresse = '456 Avenue Laurier, Montréal', @nbEtoiles = 5, @prixMoyen = 85.00, 
    @commentaire = 'Un service génial et un repas tout à fait bon.', @idCategorie = 2;


GO
EXEC AjouterRestaurant 
    @nomRestaurant = 'Chez Mario', @adresse = '789 Boulevard Saint-Laurent, Montréal', @nbEtoiles = 3, @prixMoyen = 30.00,
    @commentaire = 'Correct.', @idCategorie = 1;


GO
EXEC AjouterRestaurant 
    @nomRestaurant = 'Le Gourmet Express', @adresse = '321 Rue Sherbrooke, Montréal', @nbEtoiles = 4, @prixMoyen = 55.00, 
    @commentaire = 'Plusieurs choix et de bons plats.', @idCategorie = 3;


GO
EXEC AjouterRestaurant 
    @nomRestaurant = 'Pizzeria Bella', @adresse = '999 Rue Sainte-Catherine, Montréal', @nbEtoiles = 5, @prixMoyen = 40.00, 
    @commentaire = 'Un excellent service et des pizzas fantastiques.', @idCategorie = 1;


GO
EXEC ModifierEtoiles @idRestaurant = 1, @nbEtoiles = 4;