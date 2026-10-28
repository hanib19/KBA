USE BDTourismo;

SELECT * FROM circuits;
SELECT * FROM circuitsmonuments;
SELECT * FROM monuments;

DECLARE @idCircuit INT = 51;
DECLARE @coutTotalVisite INT = 0;
DECLARE @coutCircuit INT;

DECLARE @idMonument INT,
	@nomMonument VARCHAR(30),
	@coutVisite INT;

-- 1 DECLARER
DECLARE curCircuit CURSOR FOR
	SELECT monuments.idMonument, nomMonument, coutVisite FROM circuitsmonuments
	INNER JOIN monuments ON circuitsmonuments.idMonument = monuments.idMonument
	WHERE idCircuit = @idCircuit;

-- 2 OUVRIR
OPEN curCircuit;
-- 3 WHILE READ
FETCH NEXT FROM curCircuit INTO @idMonument, @nomMonument, @coutVisite;

WHILE (@@FETCH_STATUS = 0)
BEGIN
	-- ACTIONS
	print CONCAT(@idMonument, ' - ', @nomMonument, ' : ', @coutVisite);
	SET @coutTotalVisite = @coutTotalVisite + @coutVisite;
	-- PROCHAIN FETCH
	FETCH NEXT FROM curCircuit INTO @idMonument, @nomMonument, @coutVisite;
END;

-- 4 CLOSE
CLOSE curCircuit;

-- 5 DEALLOCATE
DEALLOCATE curCircuit;

-- Compléter l'exemple
SELECT @coutCircuit = coutCircuit FROM circuits WHERE idCircuit = @idCircuit;
print CONCAT('Cout total des visites : ', @coutTotalVisite);
print CONCAT('Cout circuit : ', @coutCircuit);
print CONCAT('Profit : ', @coutCircuit - @coutTotalVisite);