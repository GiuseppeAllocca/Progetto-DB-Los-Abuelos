-- COSTRUZIONE DEI TRIGGER --
-- Standardizzazione dei dati
-- Trigger per la tabella ATTIVITA
CREATE TRIGGER STANDARD_ATTIVITA
BEFORE INSERT ON ATTIVITA_COMMERCIALI
FOR EACH ROW
BEGIN
    IF :NEW.Num_Recensioni IS NULL THEN :NEW.Num_Recensioni := 0; END IF;
    IF :NEW.Valutazione_Media IS NULL THEN :NEW.Valutazione_Media := 0; END IF;
END;

-- Trigger per la tabella UTENTI
CREATE TRIGGER STANDARD_UTENTI
BEFORE INSERT ON UTENTI
FOR EACH ROW
BEGIN
    IF :NEW.Data_Iscrizione IS NULL THEN :NEW.Data_Iscrizione := SYSDATE; END IF;
    IF :NEW.Num_Recensioni IS NULL THEN :NEW.Num_Recensioni := 0; END IF;
    IF :NEW.Num_Complimenti_Cool IS NULL THEN :NEW.Num_Complimenti_Cool := 0; END IF;
    IF :NEW.Num_Complimenti_Funny IS NULL THEN :NEW.Num_Complimenti_Funny := 0; END IF;
    IF :NEW.Num_Complimenti_Useful IS NULL THEN :NEW.Num_Complimenti_Useful := 0; END IF;
    IF :NEW.Valutazione_Media_Recensioni IS NULL THEN :NEW.Valutazione_Media_Recensioni := 0; END IF;
END;

-- Trigger per la tabella RECENSIONI
CREATE TRIGGER STANDARD_RECENSIONI
BEFORE INSERT ON RECENSIONI
FOR EACH ROW
BEGIN
    IF :NEW.Data IS NULL THEN :NEW.Data := SYSDATE; END IF;
    IF :NEW.Num_Valutazioni_Divertenti IS NULL THEN :NEW.Num_Valutazioni_Divertenti := 0; END IF;
    IF :NEW.Num_Valutazioni_Interessanti IS NULL THEN :NEW.Num_Valutazioni_Interessanti := 0; END IF;
    IF :NEW.Num_Valutazioni_Utili IS NULL THEN :NEW.Num_Valutazioni_Utili := 0; END IF;
END;

-- Trigger per la tabella SUGGERIMENTI
CREATE TRIGGER STANDARD_SUGGERIMENTI
BEFORE INSERT ON SUGGERIMENTI
FOR EACH ROW
BEGIN
    IF :NEW.Num_Complimenti IS NULL THEN :NEW.Num_Complimenti := 0; END IF;
END;

-- Aggiornamento automatico della valutazione media di un’attività al momento dell’inserimento di una nuova recensione
CREATE OR REPLACE TRIGGER AGGIORNAMENTO_AUTOMATICO_ATTIVITA
AFTER INSERT OR UPDATE OR DELETE ON RECENSIONI
FOR EACH ROW
DECLARE
    -- Variabili di appoggio per recuperare lo stato corrente dal database
    Valutazione_Media_Attuale ATTIVITA_COMMERCIALI.Valutazione_Media%TYPE;
    Numero_Recensioni_Attuale ATTIVITA_COMMERCIALI.Num_Recensioni%TYPE;
BEGIN
    -- CASO 1: INSERIMENTO DI UNA NUOVA RECENSIONE
    IF INSERTING THEN
        UPDATE ATTIVITA_COMMERCIALI
        SET Valutazione_Media = ((Valutazione_Media * Num_Recensioni) + :NEW.Valutazione) / (Num_Recensioni + 1),
            Num_Recensioni    = Num_Recensioni + 1
        WHERE ID_Attivita = :NEW.Attivita;
  

    -- CASO 2: MODIFICA DI UNA RECENSIONE ESISTENTE
    ELSIF UPDATING THEN
        -- Leggiamo i valori attuali
        SELECT Valutazione_Media, Num_Recensioni
        INTO Valutazione_Media_Attuale, Numero_Recensioni_Attuale
        FROM ATTIVITA_COMMERCIALI
        WHERE ID_Attivita = :NEW.Attivita
        FOR UPDATE; -- Per la gestione della concorrenza delle transazioni
        -- se ci sono 0 recensioni, non facciamo nulla per evitare divisioni per zero
        IF Numero_Recensioni_Attuale > 0 THEN
            UPDATE ATTIVITA_COMMERCIALI
            SET Valutazione_Media = ((Valutazione_Media_Attuale * Numero_Recensioni_Attuale) - :OLD.Valutazione + :NEW.Valutazione) / Numero_Recensioni_Attuale
            WHERE ID_Attivita = :NEW.Attivita;
        END IF;

    -- CASO 3: CANCELLAZIONE DI UNA RECENSIONE ESISTENTE
    ELSIF DELETING THEN
        -- Recupero stato attuale del DB
        SELECT Valutazione_Media, Num_Recensioni
        INTO Valutazione_Media_Attuale, Numero_Recensioni_Attuale
        FROM ATTIVITA_COMMERCIALI
        WHERE ID_Attivita = :OLD.Attivita
        FOR UPDATE;

        IF Numero_Recensioni_Attuale <= 1 THEN
            -- Reset totale se era l'ultima recensione
            UPDATE ATTIVITA_COMMERCIALI
            SET Valutazione_Media = 0,
                Num_Recensioni = 0
            WHERE ID_Attivita = :OLD.Attivita;
        ELSE
            UPDATE ATTIVITA_COMMERCIALI
            SET Valutazione_Media = ((Valutazione_Media_Attuale * Numero_Recensioni_Attuale) - :OLD.Valutazione) / (Numero_Recensioni_Attuale - 1),
                Num_Recensioni = Numero_Recensioni_Attuale - 1
            WHERE ID_Attivita = :OLD.Attivita;
        END IF;

    END IF;

END;









-- Aggiornamento live della Valutazione_Media_Recensioni e Num_Recensioni in UTENTI

CREATE OR REPLACE TRIGGER AGGIORNAMENTO_AUTOMATICO_UTENTE
AFTER INSERT OR UPDATE OR DELETE ON RECENSIONI
FOR EACH ROW
DECLARE
    -- Variabili per leggere lo stato attuale dal database
    Valutazione_Media_Recensioni_Attuale UTENTI.Valutazione_Media_Recensioni%TYPE;
    Numero_Recensioni_Utente_Attuale UTENTI.Num_Recensioni%TYPE;
BEGIN
    -- CASO 1: INSERIMENTO DI UNA NUOVA RECENSIONE
    IF INSERTING THEN
  UPDATE UTENTI
        SET Valutazione_Media_Recensioni = ((Valutazione_Media_Recensioni * Num_Recensioni) + :NEW.Valutazione) / (Num_Recensioni + 1),
            Num_Recensioni    = Num_Recensioni + 1
        WHERE ID_Utente = :NEW.Utente;
  
    -- CASO 2: MODIFICA DI UNA RECENSIONE
    ELSIF UPDATING THEN
        -- Leggiamo i valori attuali
        SELECT Valutazione_Media_Recensioni, Num_Recensioni
        INTO Valutazione_Media_Recensioni_Attuale, Numero_Recensioni_Utente_Attuale
        FROM UTENTI
        WHERE ID_Utente = :NEW.Utente
        FOR UPDATE; -- Per la gestione della concorrenza delle transazioni
        -- se l’utente non aveva precedentemente scritto alcuna recensione , il DB non fa niente per evitare errori(n. recensioni = 0)
        IF Numero_Recensioni_Utente_Attuale > 0 THEN
            UPDATE UTENTI
            SET Valutazione_Media_Recensioni = ((Valutazione_Media_recensioni_Attuale * Numero_Recensioni_Utente_Attuale) - :OLD.Valutazione + :NEW.Valutazione) / Numero_Recensioni_Utente_Attuale
            WHERE ID_Utente = :NEW.Utente;
        END IF;

    -- CASO 3: CANCELLAZIONE DI UNA RECENSIONE ESISTENTE
    ELSIF DELETING THEN
        -- Recupero stato attuale
        SELECT Valutazione_Media_Recensioni, Num_Recensioni
        INTO Valutazione_Media_Recensioni_Attuale, Numero_Recensioni_Utente_Attuale
        FROM UTENTI
        WHERE ID_Utente = :OLD.Utente
        FOR UPDATE;

        IF Numero_Recensioni_Utente_Attuale <= 1 THEN
            -- Reset totale se era l'ultima recensione
            UPDATE UTENTI
            SET Valutazione_Media_Recensioni = 0,
                Num_Recensioni = 0
            WHERE ID_Utente = :OLD.Utente;
        ELSE
            UPDATE UTENTI
            SET Valutazione_Media_Recensioni = ((Valutazione_Media_Recensioni_Attuale * Numero_Recensioni_Utente_Attuale) - :OLD.Valutazione) / (Numero_Recensioni_Utente_Attuale - 1),
                Num_Recensioni = Numero_Recensioni_Utente_Attuale - 1
            WHERE ID_Utente = :OLD.Utente;
        END IF;

    END IF;

END;


-- Un check-in non può avere una data maggiore di SYSDATE
CREATE OR REPLACE TRIGGER VALIDAZIONE_DATA_CHECK_IN
BEFORE INSERT OR UPDATE ON CHECK_IN
FOR EACH ROW 
BEGIN 
-- Controllo: Se la data inserita è maggiore di adesso
IF :NEW.Data > SYSDATE THEN 
-- Blocca l'operazione e restituisce un errore personalizzato RAISE_APPLICATION_ERROR(-20001, 'Errore: Non è possibile inserire check-in con data futura.'); 
END IF; 
END;


-- DEFINIZIONE STORED PROCEDURE --
-- L’utente non può modificare le recensioni altrui
CREATE OR REPLACE PROCEDURE ABILITA_MODIFICA_RECENSIONE (
    -- Variabili della procedure di input(no modifica)
    ID_Recensione_Procedura IN VARCHAR2,
    Valutazione_Procedura IN INTEGER,
    Testo_Procedura IN CLOB,
    Utente_Procedura IN VARCHAR2 
) AS
    Proprietario_Recensione VARCHAR2(30);
BEGIN
    -- Trova chi è il proprietario della recensione
    SELECT Utente INTO Proprietario_Recensione
    FROM RECENSIONI
    WHERE ID_Recensione = ID_Recensione_Procedura;

    -- Se l'utente corrisponde, esegui l'update
    IF Proprietario_Recensione = Utente_Procedura THEN
        UPDATE RECENSIONI
        SET Valutazione = Valutazione_Procedura,
            Testo = Testo_Procedura,
            Data = SYSDATE
        WHERE ID_Recensione = ID_Recensione_Procedura;
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Errore: Non puoi modificare recensioni altrui.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Recensione non trovata.');
END;
/

-- L'utente non può modificare i suggerimenti altrui
CREATE OR REPLACE PROCEDURE ABILITA_MODIFICA_SUGGERIMENTO (
    Data_Procedura IN DATE,
    Attivita_Procedura IN VARCHAR2,
    Testo_Procedura IN CLOB,
    Utente_Procedura IN VARCHAR2 
) AS
    Contatore INTEGER;
BEGIN
    -- Controllo se esiste il record per questo utente
    SELECT COUNT(*)
    INTO Contatore
    FROM SUGGERIMENTI
    WHERE Data = Data_Procedura
      AND Attivita = Attivita_Procedura
      AND Utente = Utente_Procedura; 

    IF Contatore > 0 THEN
        -- Il record esiste ed è dell'utente: Eseguo l'Update
        UPDATE SUGGERIMENTI
        SET Testo = Testo_Procedura
        WHERE Data = Data_Procedura
          AND Attivita = Attivita_Procedura
          AND Utente = Utente_Procedura;
          
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Errore: Non puoi modificare i suggerimenti altrui.');
    END IF;

END;
/

-- Abilita la modifica della fotografia solo al proprietario
CREATE OR REPLACE PROCEDURE ABILITA_MODIFICA_FOTOGRAFIA(
    ID_Fotografia_Procedura IN VARCHAR2,
    Didascalia_Procedura IN CLOB,
    Etichetta_Procedura IN VARCHAR2,
    Utente_Procedura IN VARCHAR2
) AS
    Proprietario_Fotografia VARCHAR2(30);
BEGIN
    -- Trova chi è il proprietario della fotografia
    SELECT Utente INTO Proprietario_Fotografia
    FROM FOTOGRAFIE
    WHERE ID_Fotografia = ID_Fotografia_Procedura;

    -- Se l'utente corrisponde, esegui l'update
    IF Proprietario_Fotografia= Utente_Procedura THEN
        UPDATE FOTOGRAFIE
        SET Testo = Didascalia_Procedura,
            Etichetta = Etichetta_Procedura
            
        WHERE ID_Fotografia = ID_Fotografia_Procedura;

        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Errore: Non puoi modificare fotografie altrui.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Fotografia non trovata.');
END;
/

-- L’amico deve essere sempre diverso dall’utente e se gia è stato aggiunto non puo essere nuovamente inserito
CREATE OR REPLACE PROCEDURE AGGIUNGI_AMICO(
    Utente_Procedura_User IN VARCHAR2,
    Utente_Procedura_Amico IN VARCHAR2
) AS
    Conteggio INTEGER; -- Mancava il punto e virgola
BEGIN
    -- Controllo se sono lo stesso utente
    IF Utente_Procedura_Amico = Utente_Procedura_User THEN
        RAISE_APPLICATION_ERROR(-20001, 'Errore: Non puoi aggiungere te stesso come amico.');
    END IF;

    -- Controllo se l'amicizia esiste già
    SELECT COUNT(*)
    INTO Conteggio
    FROM AMICIZIE
    WHERE Utente = Utente_Procedura_User 
    AND Amico = Utente_Procedura_Amico;

    IF Conteggio > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Errore: Non puoi inserire nuovamente questo amico.');
    ELSE
        -- Sintassi INSERT corretta
        INSERT INTO AMICIZIE (Utente, Amico)
        VALUES (Utente_Procedura_User, Utente_Procedura_Amico);
        
        COMMIT; -- Mancava il punto e virgola
    END IF;
END;
/

-- Comandi che garantiscono la "logica sicura" appena definita dalle stored procedure
GRANT EXECUTE ON AGGIUNGI_AMICO TO RUOLO_USER;
GRANT EXECUTE ON ABILITA_MODIFICA_FOTOGRAFIA TO RUOLO_USER;
GRANT EXECUTE ON ABILITA_MODIFICA_RECENSIONE TO RUOLO_USER;
GRANT EXECUTE ON ABILITA_MODIFICA_SUGGERIMENTO TO RUOLO_USER;
