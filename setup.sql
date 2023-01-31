BEGIN;


-- brisanje

DROP TABLE IF EXISTS parking_lot;
DROP TABLE IF EXISTS parking_space;
DROP TABLE IF EXISTS manager_parking_space;
DROP TABLE IF EXISTS parking;
DROP TABLE IF EXISTS product_replacement;
DROP TABLE IF EXISTS store_product;
DROP TABLE IF EXISTS store;
DROP TABLE IF EXISTS manager;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS company;


-- Pravljenje tabele kompanija


CREATE TABLE company (
	company_id integer PRIMARY KEY,
	company_name varchar(50),
	ceo varchar(50),
	office_address varchar(100),
	email varchar(100)
);


-- Pravljenje tabele prodavnica


CREATE TABLE store (
    store_id integer PRIMARY KEY,
    store_name varchar(50),
    store_address varchar(100) NOT NULL
);


-- Svaka kompanija moze imati vise prodavnica (ili nijednu)
-- Svaka prodavnica pripada tacno jednoj kompaniji
-- 'jedan na vise' (1-*)
-- Dodati kolonu u tabeli koja ima odnos vise
-- napraviti kolonu tako da je strani kljuc
-- na primarni kljuc u tabeli koja ima odnos jedan
-- primarni kljuc je kombinacija stranih kljuceva


ALTER TABLE store
ADD COLUMN company_id integer NOT NULL
CONSTRAINT store_fk_company 
REFERENCES company (company_id)
ON UPDATE CASCADE ON DELETE CASCADE;


-- Pravljenje tablele proizvod


CREATE TABLE product (
    product_id integer PRIMARY KEY,
    product_name varchar(50) NOT NULL,
    product_type varchar(50) NOT NULL,
    price integer NOT NULL
);


-- Svaka prodavnica moze imati vise proizvoda (ili nijednu)
-- Svaki proizvod moze biti u vise prodavnica (ili nijednoj)
-- 'vise na vise' (*-*)
-- Napraviti novu tabelu 
-- koja sadrzi primarni kljuc iz obe tabele
-- kao strani kljuc
-- primarni kljuc je kombinacija stranih kljuceva


CREATE TABLE store_product (
    store_id integer NOT NULL
        CONSTRAINT store_product_fk_store
        REFERENCES store (store_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    product_id integer NOT NULL
        CONSTRAINT store_product_fk_product
        REFERENCES product (product_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    quantity integer NOT NULL,
    CONSTRAINT pk_store_product
        PRIMARY KEY (store_id, product_id)
);


-- pravljenje tabele menadzer


CREATE TABLE manager (
    manager_id integer PRIMARY KEY,
    manager_name varchar(50) NOT NULL,
    email varchar(50) NOT NULL
);


-- Svaka prodavnica ima tacno jedog menazdera
-- Menadzer vodi jednu prodavnicu ili nijednu
-- 'najvise jedan na jedan' (0..1-1)
-- Dodati kolonu tabeli koja ima odnos jedan
-- Napraviti kolonu tako da je strani kljuc
-- na primarni kljuc u tabeli koja ima odnos nula ili jedan
-- Dodati ogranicenje da je strani kljuc jedinstven


ALTER TABLE store
ADD COLUMN manager_id integer NOT NULL UNIQUE
CONSTRAINT store_fk_manager 
REFERENCES manager (manager_id)
ON UPDATE CASCADE ON DELETE CASCADE;


-- neki proizvodi mogu biti zamenjeni drugim proizvodom
-- prvi moze biti zamenjen drugim, ali drugi ne mora biti zamenjiv prvim
-- 'najvise jedan na vise' (0..1-*)
-- Napraviti novu tabelu 
-- koja sadrzi primarni kljuc iz obe tabele
-- kao strani kljuc
-- tabeli koja je u odnosu najvise jedan
-- dodaje se jedinstvenost
-- primarni kljuc je kombinacija stranih
-- dodatno mozemo uvesti da proizvod ne moze biti zamena sam sebi


CREATE TABLE product_replacement (
    product_id integer NOT NULL UNIQUE
        CONSTRAINT replacement_product_fk_product
        REFERENCES product (product_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    replacement_id integer NOT NULL CHECK(replacement_id != product_id)
        CONSTRAINT replacement_replacement_fk_product
        REFERENCES product (product_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT pk_product_replacement
        PRIMARY KEY (product_id, replacement_id)
);


-- dodajemo tabelu mesto za parkiranje


CREATE TABLE parking_space (
    parking_space_id integer PRIMARY KEY,
    invalid boolean NOT NULL DEFAULT false
);


-- menadzer moze imati parking mesto ali ne mora
-- parking mesto pripada jednom menadzeru ali ne mora
-- 'najvise jedan na najvise jedan' (0..1-0..1)
-- Napraviti novu tabelu 
-- koja sadrzi primarni kljuc iz obe tabele
-- kao jedinstveni strani kljuc
-- primarni kljuc je proizvoljni strani kljuc


CREATE TABLE manager_parking_space (
    manager_id integer NOT NULL PRIMARY KEY
        CONSTRAINT manager_parking_space_fk_manager
        REFERENCES manager (manager_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    parking_space_id integer NOT NULL UNIQUE
        CONSTRAINT manager_parking_space_fk_parking_space
        REFERENCES product (product_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);


-- dodajemo tabelu parkiraliste


CREATE TABLE parking_lot (
    parking_lot_id integer PRIMARY KEY,
    address varchar(50)
);


-- parking mesto pripada tacno jednom parkiralistu
-- parkiraliste ima vise parking mesta ali mora imati bar jedno
-- 'jedan na bar jedan' (1-1..*)
-- u tabeli u odnosu bar jedan
-- dodamo strani kljuc na drugu tabelu
-- u tabeli koja je u odnosu jedan
-- primarni kljuc proglasimo
-- kao strani na drugu tabelu
-- i dodajemo jedno polje ka drugoj tabeli
-- poblem: ne moze se uneti jedan novi red bez drugog
-- provera na nivou transakcije umesto operacije


ALTER TABLE parking_space
ADD COLUMN parking_lot_id integer NOT NULL
CONSTRAINT parking_space_fk_parking_lot
REFERENCES parking_lot (parking_lot_id)
ON UPDATE CASCADE ON DELETE CASCADE
DEFERRABLE INITIALLY DEFERRED,
ADD UNIQUE (parking_space_id, parking_lot_id);

ALTER TABLE parking_lot
ADD COLUMN parking_space_id integer NOT NULL UNIQUE,
ADD CONSTRAINT parking_lot_fk_parking_space
FOREIGN KEY (parking_lot_id, parking_space_id)
REFERENCES parking_space (parking_lot_id, parking_space_id)
ON UPDATE CASCADE ON DELETE CASCADE
DEFERRABLE INITIALLY DEFERRED;


COMMIT;