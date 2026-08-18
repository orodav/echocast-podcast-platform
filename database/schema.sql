CREATE DATABASE IF NOT EXISTS echocast;
USE echocast;

CREATE TABLE UTENTE (
    IdUtente INT AUTO_INCREMENT,
    Username VARCHAR(50) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Cognome VARCHAR(100) NOT NULL,
    PaeseResidenza VARCHAR(100) NOT NULL,
    DataNascita DATE NOT NULL,
    ImgProfilo VARCHAR(500) NULL,

    PRIMARY KEY (IdUtente),
    UNIQUE (Username),
    UNIQUE (Email)
);

CREATE TABLE CREATOR (
    IdUtente INT,
    Biografia TEXT NOT NULL,
    ImgCopertina VARCHAR(500) NOT NULL,

    PRIMARY KEY (IdUtente),

    FOREIGN KEY (IdUtente)
        REFERENCES UTENTE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE AMMINISTRATORE (
    IdUtente INT,

    PRIMARY KEY (IdUtente),

    FOREIGN KEY (IdUtente)
        REFERENCES UTENTE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE CATEGORIA (
    IdCategoria INT AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL,
    DataCreazione DATE NOT NULL,
    IdAmministratore INT NOT NULL,

    PRIMARY KEY (IdCategoria),
    UNIQUE (Nome),

    FOREIGN KEY (IdAmministratore)
        REFERENCES AMMINISTRATORE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE PODCAST (
    IdPodcast INT AUTO_INCREMENT,
    Titolo VARCHAR(255) NOT NULL,
    Descrizione TEXT,
    ImgCopertina VARCHAR(500) NOT NULL,
    IdCreator INT NOT NULL,
    IdCategoria INT NOT NULL,

    PRIMARY KEY (IdPodcast),

    FOREIGN KEY (IdCreator)
        REFERENCES CREATOR(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (IdCategoria)
        REFERENCES CATEGORIA(IdCategoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE EPISODIO (
    IdPodcast INT,
    NumeroEpisodio INT,
    Titolo VARCHAR(255) NOT NULL,
    Descrizione TEXT,
    DurataMinuti INT NOT NULL,
    DataPubblicazione DATE NOT NULL,

    PRIMARY KEY (IdPodcast, NumeroEpisodio),

    FOREIGN KEY (IdPodcast)
        REFERENCES PODCAST(IdPodcast)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (NumeroEpisodio > 0),
    CHECK (DurataMinuti > 0)
);

CREATE TABLE PLAYLIST (
    IdPlaylist INT AUTO_INCREMENT,
    Nome VARCHAR(150) NOT NULL,
    Descrizione TEXT,
    IdUtente INT NOT NULL,

    PRIMARY KEY (IdPlaylist),
    UNIQUE (IdUtente, Nome),

    FOREIGN KEY (IdUtente)
        REFERENCES UTENTE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE CONTENUTO_PLAYLIST (
    IdPlaylist INT,
    IdPodcast INT,
    NumeroEpisodio INT,

    PRIMARY KEY (
        IdPlaylist,
        IdPodcast,
        NumeroEpisodio
    ),

    FOREIGN KEY (IdPlaylist)
        REFERENCES PLAYLIST(IdPlaylist)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (IdPodcast, NumeroEpisodio)
        REFERENCES EPISODIO(IdPodcast, NumeroEpisodio)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE ASCOLTO (
    IdAscolto BIGINT AUTO_INCREMENT,
    IdUtente INT NOT NULL,
    IdPodcast INT NOT NULL,
    NumeroEpisodio INT NOT NULL,
    DataOra DATETIME NOT NULL,
    PercentualeCompletamento DECIMAL(5,2) NOT NULL,

    PRIMARY KEY (IdAscolto),

    FOREIGN KEY (IdUtente)
        REFERENCES UTENTE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (IdPodcast, NumeroEpisodio)
        REFERENCES EPISODIO(IdPodcast, NumeroEpisodio)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (
        PercentualeCompletamento >= 0
        AND PercentualeCompletamento <= 100
    )
);

CREATE TABLE RECENSIONE (
    IdUtente INT,
    IdPodcast INT,
    NumeroEpisodio INT,
    Voto TINYINT NOT NULL,
    Testo TEXT,
    DataOraRecensione DATETIME NOT NULL,

    PRIMARY KEY (
        IdUtente,
        IdPodcast,
        NumeroEpisodio
    ),

    FOREIGN KEY (IdUtente)
        REFERENCES UTENTE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (IdPodcast, NumeroEpisodio)
        REFERENCES EPISODIO(IdPodcast, NumeroEpisodio)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (Voto BETWEEN 1 AND 5)
);

CREATE TABLE ISCRIZIONE (
    IdIscrizione BIGINT AUTO_INCREMENT,
    IdUtente INT NOT NULL,
    IdPodcast INT NOT NULL,
    DataIscrizione DATETIME NOT NULL,
    DataAnnullamento DATETIME NULL,

    PRIMARY KEY (IdIscrizione),

    FOREIGN KEY (IdUtente)
        REFERENCES UTENTE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (IdPodcast)
        REFERENCES PODCAST(IdPodcast)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (
        DataAnnullamento IS NULL
        OR DataAnnullamento >= DataIscrizione
    )
);

CREATE TABLE DONAZIONE (
    IdDonazione BIGINT AUTO_INCREMENT,
    IdUtente INT NOT NULL,
    IdCreator INT NOT NULL,
    Importo DECIMAL(10,2) NOT NULL,
    DataOra DATETIME NOT NULL,

    PRIMARY KEY (IdDonazione),

    FOREIGN KEY (IdUtente)
        REFERENCES UTENTE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (IdCreator)
        REFERENCES CREATOR(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (Importo > 0)
);

CREATE TABLE SOSPENSIONE (
    IdSospensione BIGINT AUTO_INCREMENT,
    IdAmministratore INT NOT NULL,
    IdCreator INT NOT NULL,
    DataOraInizio DATETIME NOT NULL,
    DataOraFine DATETIME NULL,
    Descrizione TEXT,

    PRIMARY KEY (IdSospensione),

    FOREIGN KEY (IdAmministratore)
        REFERENCES AMMINISTRATORE(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (IdCreator)
        REFERENCES CREATOR(IdUtente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (
        DataOraFine IS NULL
        OR DataOraFine > DataOraInizio
    )
);