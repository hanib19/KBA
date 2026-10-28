-- DEMO Procedure

-- CREATE DATABASE BDTrivia;
-- USE master;
-- DROP DATABASE BDTrivia

use BDTrivia;

DROP TABLE ReponseTrivia;
DROP TABLE QuestionTrivia;
DROP TABLE CategorieTrivia;

-----
create table CategorieTrivia
(
idCategorie char(1),
nomCategorie varchar(30) not null,
couleur varchar(30) not null,
constraint pk_categorieTrivia primary key (idCategorie)
);

----------------------------------
create table QuestionTrivia
(
idQuestion smallint identity(100,1),
enonce varchar(100) not null,
flag char(1) not null default 'n',
difficulte char(1) not null,
idCategorie char(1) not null,
constraint pk_QuestionTrivia primary key (idQuestion),
constraint ck_flagQuestion check(flag='o' or flag='n'),
constraint ck_difficulte check 
			(difficulte='d' or difficulte='m'or difficulte='f'),
constraint fk_categorieTrivia foreign key (idCategorie)
			references CategorieTrivia(idCategorie)
);

-----------------------------
create table ReponseTrivia
(
idReponse int identity (1,1),
laReponse varchar(100) not null,
estBonne char(1) not null,
idQuestion smallint not null,
constraint pk_reponse primary key(idReponse),
constraint ck_bonne check(estBonne='o' or estBonne ='n'),
constraint fk_question foreign key(idQuestion)
						references QuestionTrivia(idQuestion)
);
----------------------------------------

insert into CategorieTrivia values('s','sciences','vert');
insert into CategorieTrivia values('a','art et lettres','orange');
insert into CategorieTrivia values('h','histoire et geographie','bleu');
insert into CategorieTrivia values('g','général','Jaune');

----------------------------------------------
insert into QuestionTrivia(enonce,difficulte,idCategorie)
values('Quel élément dont le symbole est C, se retrouve dans toute forme de vie organique ?','f','s'); 

insert into QuestionTrivia(enonce,difficulte,idCategorie)
values('Quel élément chimique a comme symbole la lettre K ?','d','s'); 

insert into QuestionTrivia(enonce,difficulte,idCategorie)
values('Qui est l''inventeur du modèle relationnel en BD ?','f','s'); 

insert into QuestionTrivia(enonce,difficulte,idCategorie)
values('Quel est le double du quintuple de 248 ?','f','s');

insert into QuestionTrivia(enonce,difficulte,idCategorie)
values('Quel est le poids moyen d''un cerveau humain?','m','s');

insert into QuestionTrivia(enonce,difficulte,idCategorie)
values('Quelle est la couleur de Shrek','f','g');

insert into QuestionTrivia(enonce,difficulte,idCategorie)
values('Quel animal est le meilleu ami de Shrek','f','g');

insert into QuestionTrivia(enonce,difficulte,idCategorie)
values('Quelle phrase est souvent pronocée par Bart Simpson? ','d','g');

-----------------------------------------


--Reponses question 100
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Le carbone','o',100);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Le chlore','n',100);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Le calcium','n',100);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Le cobalte','n',100);
---reponses question 101
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Le phosphore','n',101);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Le potassium','o',101);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Le souffre','n',101);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Le chlore','n',101);

--reponse question 102
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Ivar Jacobson','n',102);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Tim Berners-Lee','n',102);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Steve Jobs','n',102);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('Edgar Frank « Ted » Codd ','o',102);
--reponses questions 103
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('2480','o',103);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('2500','n',103);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('2487','n',103);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('2600','n',103);
--reponses questions 104
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('2,3 kg','n',104);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('2 kg','n',104);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('1,3 kg','o',104);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('1kg','n',104);

--reponses questions 105
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('vert','o',105);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('bleu','n',105);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('jaune','n',105);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('rouge','n',105);

--reponses questions 106
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('chien','n',106);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('chat','n',106);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('âne','o',106);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('cheval','n',106);

---107
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('oh mon dieu !','n',107);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('ah caramba !','o',107);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('oh seigneur ! ','n',107);
insert into ReponseTrivia (laReponse,estBonne,idQuestion) values ('oups','n',107);


SELECT * FROM CategorieTrivia;
SELECT * FROM QuestionTrivia;
SELECT * FROM ReponseTrivia;

-- Creer une procedure qui permet d'ajouter une question et ses reponses --
GO;
CREATE OR ALTER PROCEDURE AjouterQuestion
	@Enonce varchar(100),
	@Categorie CHAR(1),
	@Difficulte CHAR(1),
	@Reponse1 VARCHAR(100),
	@Reponse2 VARCHAR(100),
	@Reponse3 VARCHAR(100),
	@Reponse4 VARCHAR(100),
	@EstBonne INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	DECLARE @IdQuestion INT;

	INSERT INTO QuestionTrivia (enonce, flag, difficulte, idCategorie)
	VALUES (@Enonce, 'n', @Difficulte, @Categorie);

	SET @IdQuestion = @@IDENTITY;

	INSERT INTO ReponseTrivia (laReponse, estBonne, idQuestion)
	VALUES (@Reponse1, CASE @EstBonne WHEN 1 THEN 'o' ELSE 'n' END, @IdQuestion);

	INSERT INTO ReponseTrivia (laReponse, estBonne, idQuestion)
	VALUES (@Reponse2, CASE @EstBonne WHEN 2 THEN 'o' ELSE 'n' END, @IdQuestion);

	INSERT INTO ReponseTrivia (laReponse, estBonne, idQuestion)
	VALUES (@Reponse3, CASE @EstBonne WHEN 3 THEN 'o' ELSE 'n' END, @IdQuestion);

	INSERT INTO ReponseTrivia (laReponse, estBonne, idQuestion)
	VALUES (@Reponse4, CASE @EstBonne WHEN 4 THEN 'o' ELSE 'n' END, @IdQuestion);

	COMMIT;

	END TRY
	BEGIN CATCH
		if @@TRANCOUNT > 0
			ROLLBACK;
	END CATCH;
END

EXEC AjouterQuestion
	@Enonce = 'Quel note je vais avoir en KBA?',
	@Categorie = '3',
	@Difficulte = 'f',
	@Reponse1 = '25%',
	@Reponse2 = '50%',
	@Reponse3 = '75%',
	@Reponse4 = '100%',
	@EstBonne = 4;



-- Creer une procedure qui supprime un question et ses reponses en cascade
GO;
CREATE OR ALTER PROCEDURE SupprimerQuestion
	@IdQuestion INT
AS
BEGIN

BEGIN TRANSACTION
BEGIN TRY

	DELETE FROM ReponseTrivia WHERE idQuestion = @IdQuestion;

	DELETE FROM QuestionTrivia WHERE idQuestion = @IdQuestion;

	COMMIT;
END TRY
BEGIN CATCH
	if @@TRANCOUNT > 0
		ROLLBACK;
END CATCH;
END;
GO;

EXECUTE SupprimerQuestion
	@IdQuestion = 108;


-- Creer une procedure qui permet de compter le nombre de question encore disponible
GO
CREATE OR ALTER PROC CompterQuestionDisponible
	@nombreQuestion INT OUT
AS
	SELECT @nombreQuestion = COUNT(idQuestion) FROM QuestionTrivia WHERE flag = 'n'

GO
-- Execute
DECLARE @nbreQuestion INT;

EXECUTE CompterQuestionDisponible
	@nombreQuestion = @nbreQuestion OUT;

PRINT @nbreQuestion

-- Creer une procedure qui permet de piger une question
-- Le flag de la question pige doit etre change
GO
CREATE OR ALTER PROCEDURE PigerQuestion
	@enonce VARCHAR(100) OUTPUT
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @nbreQuestion INT
	DECLARE @idQuestion INT

	EXECUTE CompterQuestionDisponible
		@nombreQuestion = @nbreQuestion OUTPUT;

	if @nbreQuestion <= 0
		THROW 51000, 'Aucune question disponible', 1

	SELECT TOP 1 @idQuestion = idQuestion, @enonce = enonce 
	FROM QuestionTrivia
	WHERE flag = 'n'

	UPDATE QuestionTrivia SET flag = 'o' WHERE idQuestion = @idQuestion

	COMMIT
END TRY
BEGIN CATCH
	if @@TRANCOUNT > 0
		ROLLBACK
END CATCH
END

GO
DECLARE @enoncePige VARCHAR(100)

EXECUTE PigerQuestion
	@enonce = @enoncePige OUTPUT;

PRINT @enoncePige;
