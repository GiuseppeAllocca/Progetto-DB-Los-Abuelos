-- QUERY E VISTE --
-- Individuare le attività con la valutazione media più alta in una città
SELECT Nome, Valutazione_Media
FROM ATTIVITA_COMMERCIALI
WHERE Città = 'Indianapolis'
AND Valutazione_Media = 
(
    SELECT MAX(Valutazione_Media)
    FROM ATTIVITA_COMMERCIALI
    WHERE Città = 'Indianapolis'
);

-- Calcolare il numero medio di recensioni per categoria
CREATE MATERIALIZED VIEW Numero_Recensioni_Per_Categoria AS
SELECT AP.Categoria, COUNT(R.ID_Recensione) AS Num_Recensioni
FROM RECENSIONI R
JOIN APPARTENENZE_CATEGORIE AP ON R.Attivita = AP.Attivita
GROUP BY AP.Categoria;

-- Query per ottenere la media totale
SELECT AVG(Num_Recensioni) AS Numero_Recensioni_Medio_Per_Categoria
FROM Numero_Recensioni_Per_Categoria;

-- Determinare gli utenti più attivi o con il maggior numero  di complimenti
-- Utenti con il massimo numero di recensioni:
SELECT ID_Utente, Nome, Num_Recensioni
FROM UTENTI 
ORDER BY Num_Recensioni DESC
FETCH FIRST 10 ROWS ONLY;
-- Utenti per numero totale di complimenti:
SELECT ID_Utente, Nome, (Num_Complimenti_Cool + Num_Complimenti_Funny + Num_Complimenti_Useful) AS Totale_Complimenti
FROM UTENTI
ORDER BY Totale_Complimenti DESC
FETCH FIRST 10 ROWS ONLY;

-- Analizzare la distribuzione temporale dei check-in
SELECT 
    TO_CHAR(Data, 'Month', 'NLS_DATE_LANGUAGE = ITALIAN') AS Mese, 
    COUNT(*) AS Numero_di_Check_In
FROM CHECK_IN
GROUP BY 
    TO_CHAR(Data, 'Month', 'NLS_DATE_LANGUAGE = ITALIAN'),
    TO_CHAR(Data, 'MM')
ORDER BY 
    TO_CHAR(Data, 'MM') DESC;

-- Individuare le categorie di attività con maggior densità di fotografie
CREATE OR REPLACE VIEW FOTO_PER_ATTIVITA_CATEGORIA AS
SELECT AC.Categoria, AC.Attivita, COUNT(F.ID_Fotografia) AS Num_Fotografie
FROM APPARTENENZE_CATEGORIE AC 
LEFT JOIN FOTOGRAFIE F ON F.Attivita = AC.Attivita
GROUP BY AC.Categoria, AC.Attivita;

SELECT Categoria, AVG(Num_Fotografie) AS Densita_Foto
FROM FOTO_PER_ATTIVITA_CATEGORIA
GROUP BY Categoria
ORDER BY Densita_Foto ASC;
