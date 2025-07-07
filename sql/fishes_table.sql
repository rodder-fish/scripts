CREATE TABLE fishes
(
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    fish_base_id     INTEGER UNIQUE,
    genus            TEXT,
    species          TEXT,
    author           TEXT,
    year             INTEGER,
    chinese_name     TEXT,
    chinese_alias    TEXT,
    chinese_synonyms TEXT, -- JSON array
    english_synonyms TEXT, -- JSON array
    attributes       TEXT, -- JSON array
    habitats         TEXT, -- JSON array
    waters           TEXT, -- JSON array
    description      TEXT,
    distribution     TEXT,
    size_info        TEXT,
    habitat_detail   TEXT,
    depth_info       TEXT,
    usage_info       TEXT
);
