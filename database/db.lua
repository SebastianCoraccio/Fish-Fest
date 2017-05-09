-- db
-- Creation of the database

local sqlite3 = require("sqlite3")
local path = system.pathForFile("database.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

db:exec[[
  CREATE TABLE Fish
  (
    fid INT NOT NULL,
    name VARCHAR(64) NOT NULL,
    description VARCHAR(512) NOT NULL,
    value INT NOT NULL,
    sizeMin FLOAT NOT NULL,
    sizeMax FLOAT NOT NULL,
    size VARCHAR(32) NOT NULL,
    largestCaught FLOAT NOT NULL,
    caught INT NOT NULL,
    PRIMARY KEY (fid)
  );

  CREATE TABLE River
  (
    fid INT NOT NULL,
    spawnRate INT NOT NULL,
    PRIMARY KEY (fid),
    FOREIGN KEY (fid) REFERENCES Fish(fid)
  );

  CREATE TABLE Beach
  (
    spawnRate INT NOT NULL,
    fid INT NOT NULL,
    PRIMARY KEY (fid),
    FOREIGN KEY (fid) REFERENCES Fish(fid)
  );

  INSERT INTO Fish VALUES (0, 'Sturgeon', 'Test description', 20, 100, 1000, 'medium', 0, 0);
  INSERT INTO Fish VALUES (1, 'Bass', 'Test description 2', 20, 100, 1000, 'small', 0, 0);
  INSERT INTO River VALUES(0, 100);
  INSERT INTO Beach VALUES(0, 80);
]]