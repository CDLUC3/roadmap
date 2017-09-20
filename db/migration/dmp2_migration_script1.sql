-- # create table sample plans in roadmaptest, similar to that in dmp2.
DROP TABLE IF EXISTS `roadmaptest`.`sample_plans`;
CREATE TABLE `roadmaptest`.`sample_plans`(
      id         INT,
      url        VARCHAR(255),
      label      VARCHAR(255),
      template_id   INT,
      created_at     DATETIME,
      updated_at    DATETIME);

-- # create table question_format_labels in roadmaptest.
DROP TABLE IF EXISTS `roadmaptest`.`question_format_labels`;
CREATE TABLE `roadmaptest`.`question_format_labels`(
      id         INT,
      description    VARCHAR(255),
      question_id   INT,
      number       INT,
      created_at     DATETIME,
      updated_at    DATETIME);

DROP PROCEDURE IF EXISTS AddColumn;
DELIMITER //
CREATE PROCEDURE AddColumn(IN db tinytext, IN tbl tinytext, IN col tinytext, IN typ text)
BEGIN
  IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE column_name = col 
    AND table_name = tbl 
    AND table_schema=db)
  THEN
    SET @drop = CONCAT('ALTER TABLE `', db, '`.`', tbl, '` DROP COLUMN `', col, '`');
    PREPARE stmt FROM @drop;
    EXECUTE stmt;
  END IF;

  IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE column_name = col 
    AND table_name = tbl 
    AND table_schema=db) 
  THEN
    SET @add = CONCAT('ALTER TABLE `', db, '`.`', tbl, '` ADD `', col, '` ', typ);
    PREPARE stmt FROM @add;
    EXECUTE stmt;
    END IF;
END;//
DELIMITER ;

-- # add contact_info column to Orgs table to keep track of the relationship between user and plan in user_plans table
call AddColumn('roadmaptest', 'orgs', 'contact_name', 'VARCHAR(255)');
call AddColumn('roadmaptest', 'answers', 'label_id', 'VARCHAR(255)');

#ALTER TABLE `roadmaptest`.`orgs`           DROP COLUMN `contact_name`;
#ALTER TABLE `roadmaptest`.`orgs`           ADD `contact_name`             VARCHAR(255);

-- # add label_id column to answers table
#ALTER TABLE `roadmaptest`.`answers`            DROP COLUMN `label_id`; 
#ALTER TABLE `roadmaptest`.`answers`            ADD `label_id`              VARCHAR(255);

-- *********************************************************************************************************************
-- *********************************************************************************************************************
-- INSERT MASTER TABELS DATA

-- # Insert data in Identifier Schemes
ALTER TABLE `roadmaptest`.`identifier_schemes` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`identifier_schemes`;

INSERT INTO `roadmaptest`.`identifier_schemes`(
       `id`,   `name`,      `description`,   `active`,   `logo_url`,         
                                `user_landing_url`,   `created_at`,    `updated_at`)

VALUES ( 1,    'orcid',    'ORCID',      1,    'http://orcid.org/sites/default/files/images/orcid_16x16.png',   
                                'https://orcid.org',  '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
     ( 2,    'shibboleth',  'Shibboleth',    1,     NULL,  
                                 NULL,           '2011-08-03 11:48:40',  '2011-08-03 11:48:40');


-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`identifier_schemes` ENABLE KEYS;
-- *********************************************************************************************************************

-- # Insert data in Languages
ALTER TABLE `roadmaptest`.`languages` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`languages`;

INSERT INTO `roadmaptest`.`languages`(
         `id`,   `abbreviation`,   `description`,   `name`,       `default_language`)
VALUES ( 1,   'en_GB',       '',         'English (GB)',    true),
       ( 2,   'en_US',       '',         'English (US)',    false),
       ( 3,   'fr',         '',         'Français',      false),
       ( 4,   'de',         '',         'Deutsch',      false),
       ( 5,   'es',         '',         'Español',      false);

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`languages` ENABLE KEYS;
-- *********************************************************************************************************************

-- # Insert data in Perms
ALTER TABLE `roadmaptest`.`perms` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`perms`;

INSERT INTO `roadmaptest`.`perms`(
         `id`,   `name`,         `created_at`,      `updated_at`)
VALUES  (1,   'admin',         '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (2,   'org_admin',       '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (3,    'add_organisations',   '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (4,   'change_org_affiliation','2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (5,   'grant_permissions',   '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (6,   'modify_templates',    '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (7,   'modify_guidance',    '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (8,   'use_api',        '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (9,   'change_org_details',  '2011-08-03 11:48:40',  '2011-08-03 11:48:40'),
       (10,   'grant_api_to_orgs',  '2011-08-03 11:48:40',  '2011-08-03 11:48:40');      

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`perms` ENABLE KEYS;
-- *********************************************************************************************************************

-- ## Insert data in Question Formats
ALTER TABLE `roadmaptest`.`question_formats` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`question_formats`;

INSERT INTO `roadmaptest`.`question_formats`(
       `id`, `title`,       `description`,   `created_at`,       `updated_at`,      `option_based`,  `formattype`)
VALUES  (1,    'Text area',      NULL,     '2014-04-01 08:53:26',  '2014-04-01 08:53:26',    0,        0),
     (2,    'Text field',      NULL,     '2014-04-01 08:54:20',  '2017-06-06 14:43:12',    0,        1),
     (3,    'Radio buttons',    NULL,     '2014-04-01 08:55:38',  '2017-06-06 14:43:12',    1,        2),
     (4,    'Check box',      NULL,     '2014-04-01 08:56:45',  '2017-06-06 14:43:12',    1,        3),
     (5,    'Dropdown',      NULL,     '2014-04-01 08:57:46',  '2017-06-06 14:43:12',    1,        4),
     (6,    'Multi select box',  NULL,     '2014-04-01 08:59:24',  '2017-06-06 14:43:12',    1,        5),  
     (7,    'Numeric',      NULL,     '2014-04-01 08:59:24',  '2017-06-06 14:43:12',    1,        6),  
     (8,    'Date',        NULL,     '2014-04-01 08:59:24',  '2017-06-06 14:43:12',    1,        7);

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`question_formats` ENABLE KEYS;
-- *********************************************************************************************************************

-- # # Insert data in Regions
ALTER TABLE `roadmaptest`.`regions` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`regions`;

INSERT into `roadmaptest`.`regions`(
      `id`,   `abbreviation`,   `description`,           `name`,     `super_region_id`)
VALUES  (1,   'uk',         'default region',         'UK',          NULL),
     (2,    'de',        NULL,              'DE',         NULL),
     (3,    'horizon',      'European super region',    'Horizon2020',    NULL);

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`regions` ENABLE KEYS;
-- **********************************************************************************************************************

-- Set proper datetime for the responses where the created_at is set as '0000-00-00 00:00:00' -- set same as updated_at
UPDATE `dmp2`.`responses` 
SET    `created_at` = `updated_at`
WHERE  CAST(`created_at` AS CHAR(20)) = '0000-00-00 00:00:00';
-- **********************************************************************************************************************
-- **********************************************************************************************************************

-- Seed the themes table based on the values in the project Wiki
ALTER TABLE `roadmaptest`.`themes` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`themes`;

INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Data description', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Data format', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Data volume', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Data collection', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Metadata & documentation', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Ethics & privacy', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Intellectual property rights', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Storage & security', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Data sharing', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Data repository', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Preservation', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Roles & responsibilities', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Budget', CURDATE(), CURDATE(), 'en');
INSERT INTO `roadmaptest`.`themes` (`title`, `created_at`, `updated_at`, `locale`) 
VALUES ('Related policies', CURDATE(), CURDATE(), 'en');

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`question_formats` ENABLE KEYS;

DROP PROCEDURE IF EXISTS AddColumn;