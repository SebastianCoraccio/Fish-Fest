-- db
-- Creation of the database

local sqlite3 = require("sqlite3")
local path = system.pathForFile("database.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

db:exec[[
  CREATE TABLE FishCaught
  (
    fid INT NOT NULL,
    largestCaught FLOAT NOT NULL,
    PRIMARY KEY (fid)
  );
]]