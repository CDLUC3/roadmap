-- # set SQL properties to resolve problems with institution.id = 0
SET SQL_MODE         = NO_AUTO_VALUE_ON_ZERO;
SET SQL_SAFE_UPDATES = 0;

-- # Copy the institutions of dmp2 into roadmaptest Orgs
-- To disable constraints  
ALTER TABLE `roadmaptest`.`orgs` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`orgs`;  

INSERT INTO `roadmaptest`.`orgs` (                          
  `id`,        `name`,        `abbreviation`,    `target_url`,  `wayfless_entity`,              
  `parent_id`,    `org_type`,      `is_other`,      `sort_name`,  `banner_text`,                
  `logo_file_name`,  `logo_uid`,      `logo_name`,    `region_id`,
  `contact_name`,   `contact_email`,   `created_at`,     `updated_at`,                  
  `language_id`)                    
                          
SELECT 
  `id`,        `full_name`,      `nickname`,      `url`,         NULL,                        
   NULL,            
   CASE  
     WHEN `full_name` LIKE '%University%' THEN 1
     WHEN `full_name` LIKE '%College%' THEN 1
     WHEN `full_name` LIKE '%Library%' THEN 1
     ELSE 3
   END,          NULL,         NULL,      `desc`,                
   NULL,             NULL,       NULL,         NULL,                      
  `contact_info`,   `contact_email`,  `created_at`,      `updated_at`,
  (SELECT `id` FROM `roadmaptest`.`languages` WHERE `roadmaptest`.`languages`.`default_language` = 1)

FROM `dmp2`.`institutions`;  

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`orgs` ENABLE KEYS;
-- ***FIELDS LEFT OUT**** `url_text`, `submission_mailer_subject`, `submission_mailer_body`, `logo` ****FIELDS LEFT OUT**
-- **********************************************************************************************************************

-- # Create GUidance Group for each Organization of roadmaptest as a default group.
-- To disable constraints  
ALTER TABLE `roadmaptest`.`guidance_groups` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`guidance_groups`;

INSERT INTO `roadmaptest`.`guidance_groups`(
  `name`,               `org_id`,     `optional_subset`,  `published`,   `created_at`,     `updated_at`)

SELECT
  CONCAT(`name`, " ", "Guidance"),   `id`,        0,          1,       `created_at`,    `updated_at`
FROM `roadmaptest`.`orgs`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`guidance_groups` ENABLE KEYS;
-- **********************************************************************************************************************

-- #Check for duplicate records in users table as there seem to be some duplicate values for email which has unqiue contraint in roadmaptest.
-- SELECT COUNT(*) FROM users;
-- 24443
-- SELECT COUNT(DISTINCT email) FROM dmp2.users;
-- 24440

-- select `id`, `institution_id`,  `email`, `first_name`, `last_name`, `created_at`, `updated_at` from users where email in (
--     select email from users
--     group by email having count(*) > 1
-- );
-- 13697  0  davi0635@stthomas.edu        Merrie    Davidson  2015-06-05 15:36:54  2015-06-05 15:36:54
-- 13698  0  davi0635@stthomas.edu        Merrie    Davidson  2015-06-05 15:36:54  2015-06-05 15:36:54
-- 13834  0  director.ejecutivo@cigiden.cl    Juan     Soto     2015-06-18 21:06:02  2015-06-18 21:06:02
-- 13835  0  director.ejecutivo@cigiden.cl    Juan     Soto     2015-06-18 21:06:02  2015-06-18 21:06:02
-- 15538  0  helene.n.andreassen@uit.no      Helene N.  Andreassen  2015-10-25 19:57:28  2015-10-25 20:00:36
-- 15539  0  helene.n.andreassen@uit.no      Helene N.  Andreassen  2015-10-25 19:57:31  2015-10-25 19:57:31


-- # Copy all of the dmp2 users into roadmaptest Users  
-- Disable the constraints
ALTER TABLE `roadmaptest`.`users` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`users`;  

INSERT IGNORE INTO `roadmaptest`.`users` (                          
  `id`,          `org_id`,          `email`,    `firstname`,  `surname`,              
  `orcid_id`,        `shibboleth_id`,      `encrypted_password`,                  
  `reset_password_token`,  `reset_password_sent_at`,  `remember_created_at`,                    
  `sign_in_count`,    `current_sign_in_at`,    `last_sign_in_at`,    `current_sign_in_ip`,                
  `last_sign_in_ip`,    `confirmed_at`,        `confirmation_sent_at`,    `confirmation_token`,                
  `invitation_token`,    `invitation_created_at`,  `invitation_sent_at`,  `invitation_accepted_at`,                
  `other_organisation`,  `accept_terms`,        `api_token`,                    
  `invited_by_id`,    `invited_by_type`,      `language_id`,      `recovery_email`,                        
  `created_at`,      `updated_at`)                                            
SELECT
  `id`,          `institution_id`,      `email`,    `first_name`,  `last_name`,                                    
  NULL,          NULL,            NULL,                    
  NULL,          NULL,            `created_at`,                    
  NULL,           NULL,            NULL,      NULL,                    
  NULL,          NULL,            NULL,      NULL,                  
  NULL,          NULL,            NULL,      NULL,                  
  NULL,          0,              `auth_token`,                    
  NULL,          NULL,            NULL,        NULL,                    
  `created_at`,       `updated_at`                  
FROM `dmp2`.`users`;  

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`users` ENABLE KEYS;
-- *******FIELDS LEFT OUT**** `token`, `token_expiration`, `login_id`,  `active`, `deleted_at` ****FIELDS LEFT OUT******
-- *********************************************************************************************************************

-- # Copy DMP authentications (shibboleth accounts) into roadmaptest user_identifiers and then copy identifier_scheme_id for shibboleth from roadmaptesttest Identifier Schemes into user_identifiers table    
-- Disable the constraints
ALTER TABLE `roadmaptest`.`user_identifiers` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;  
TRUNCATE TABLE `roadmaptest`.`user_identifiers`;  
    
INSERT INTO `roadmaptest`.`user_identifiers` (                          
  `identifier`,  `user_id`,  `created_at`,  `updated_at`,  
  `identifier_scheme_id`)                
                          
SELECT   
  `uid`,      `user_id`,  `created_at`,  `updated_at`, 
  (SELECT `id` from `roadmaptest`.`identifier_schemes` where `roadmaptest`.`identifier_schemes`.`name` = 'shibboleth')

FROM `dmp2`.`authentications`                          
WHERE `dmp2`.`authentications`.`provider` = 'shibboleth';  

INSERT INTO `roadmaptest`.`user_identifiers` (                          
  `identifier`,                `user_id`,    `created_at`,    `updated_at`,  
  `identifier_scheme_id`)                
                          
SELECT   
  SUBSTRING_INDEX(`orcid_id`, '/', -1),    `id`,      `created_at`,    `updated_at`, 
  (SELECT `id` from `roadmaptest`.`identifier_schemes` where `roadmaptest`.`identifier_schemes`.`name` = 'orcid')

FROM `dmp2`.`users`                          
WHERE `dmp2`.`users`.`orcid_id` IS NOT  NULL;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`user_identifiers` ENABLE KEYS;
-- *********************************************************************************************************************

-- #Copy DMP Users shib data into roadmaptest Org identifiers table  
-- Disable the constraints
ALTER TABLE `roadmaptest`.`org_identifiers` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;    
TRUNCATE TABLE `roadmaptest`.`org_identifiers`;  

INSERT INTO `roadmaptest`.`org_identifiers` (                          
  `identifier`,    `org_id`,    `attrs`,  
  `created_at`,    `updated_at`,  
  `identifier_scheme_id`)              
                          
SELECT  
  `shib_entity_id`,  `id`,       CONCAT( '{"domain":', `shib_domain` , '}' ),  
  `created_at`,    `updated_at`, 
  (SELECT id from roadmaptest.identifier_schemes where roadmaptest.identifier_schemes.name = 'shibboleth')

FROM `dmp2`.`institutions`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`org_identifiers` ENABLE KEYS;                    
-- *********************************************************************************************************************

-- # Copy dmp2 Authorizations into Roadmap UsersPerms join table. 
-- Disable the constraints
ALTER TABLE `roadmaptest`.`users_perms` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`users_perms`;

# DMP Admin gets all permissions of Perms table assigned.
INSERT INTO `roadmaptest`.`users_perms` (
  `user_id`,             `perm_id`)
SELECT 
  `dmp2`.`authorizations`.`user_id`,   `roadmaptest`.`perms`.`id`

FROM `dmp2`.`authorizations` 
CROSS JOIN `roadmaptest`.`perms`
WHERE `authorizations`.`role_id` = 1
ORDER BY `authorizations`.`user_id`, `perms`.`id`;

# All Other roles have certain Permsissions ("modify_templates", "modify_guidance", "grant_permissions", "change_org_details" ) assigned to them.
INSERT INTO `roadmaptest`.`users_perms` (
  `user_id`,             `perm_id`)
SELECT  DISTINCT
  `authorizations`.`user_id`,   `Select_Permissions`.`id`

FROM `dmp2`.`authorizations` 
CROSS JOIN 
(SELECT `id`, `name` from `roadmaptest`.`perms` 
WHERE `name` IN ("modify_templates", "modify_guidance", "grant_permissions", "change_org_details" )) as `Select_Permissions`
WHERE `authorizations`.`role_id` != 1
ORDER BY `authorizations`.`user_id`, `Select_Permissions`.`id`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`perms` ENABLE KEYS;

-- *********************************************************************************************************************

-- # Copy dmp2 Requirments Templates into Templates table of Roadmap.
-- Disable the constraints
ALTER TABLE `roadmaptest`.`templates` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`templates`;

INSERT INTO `roadmaptest`.`templates`(
  `id`,         `org_id`,         `title`,         `description`,      `locale`,     
  `published`,     `is_default`,       `version`,          `migrated`,      `dirty`,    
  `dmptemplate_id`,   `customization_of`,    `created_at`,       `updated_at`)
SELECT
  `id`,         `institution_id`,     `name`,         `name`,       "en",    
  `active`,         0,             0,               0,          0,      
  SUBSTRING(UUID_SHORT(),14) as dmptemplate_id,           NULL,        `created_at`,       `updated_at`

FROM `dmp2`.`requirements_templates`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`templates` ENABLE KEYS;
-- ************************************************************************************************************************

-- # Create a default Phase
-- Disable the constraints
ALTER TABLE `roadmaptest`.`phases` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`phases`;

-- Set a Default Phase for all Sections
INSERT into `roadmaptest`.`phases`(
     `title`,           `description`,                          `number`,     
     `template_id`,         `slug`,                            `modifiable`,
     `created_at`, `updated_at`)
SELECT
    "Data Management Plan",   NULL,      1,         
    `id` as `template_id`,     NULL,                `active`,
    `created_at`, `updated_at`
    
from `dmp2`.`requirements_templates`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`phases` ENABLE KEYS;
-- *********************************************************************************************************************

-- # Copy dmp2 Requirements with Ancestry Null and Group 0 as Sections under roadmaptest Section table
-- Disable the constraints
ALTER TABLE `roadmaptest`.`sections` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`sections`;

-- CREATE Sections that are NOT defined within the DMPTool (one question per section)
INSERT INTO `roadmaptest`.`sections` (
  `id`,             `title`,           `description`,                
  `number`,           `published`,         `phase_id`,   
  `modifiable`,         `created_at`,         `updated_at` )
SELECT
  `dmp2`.`requirements`.`id`,             `text_brief`,          NULL,   
  `position`,            0,            (SELECT `roadmaptest`.`phases`.`id` FROM `roadmaptest`.`phases` WHERE `roadmaptest`.`phases`.`template_id` = `dmp2`.`requirements_templates`.`id`) as PHASE, 
    0,            `dmp2`.`requirements`.`created_at`,         `dmp2`.`requirements`.`updated_at` 

FROM `dmp2`.`requirements`
INNER JOIN `dmp2`.`requirements_templates` 
ON `dmp2`.`requirements`.`requirements_template_id` = `dmp2`.`requirements_templates`.`id`
WHERE ancestry IS NULL and `group` = 0;

-- INSERT Section that are defined within the DMPTool
INSERT INTO `roadmaptest`.`sections` (
   `id`,             `title`,           `description`,                
   `number`,           `published`,         `phase_id`,   
   `modifiable`,         `created_at`,         `updated_at` )
SELECT
   `dmp2`.`requirements`.`id`,            `text_brief`,          NULL,   
   `position`,            0,            (SELECT `roadmaptest`.`phases`.`id` FROM `roadmaptest`.`phases` WHERE `roadmaptest`.`phases`.`template_id` = `dmp2`.`requirements_templates`.`id`) as PHASE,
     0,            `dmp2`.`requirements`.`created_at`,         `dmp2`.`requirements`.`updated_at` 
FROM `dmp2`.`requirements` 
INNER JOIN `dmp2`.`requirements_templates` 
ON `dmp2`.`requirements`.`requirements_template_id` = `dmp2`.`requirements_templates`.`id`
WHERE `group` = 1;


-- # Set a Phase id for each Section in Roadmap -- 
-- # Here there is a similar default Phase created for every template since DMPTool doesnt have the concept of phases
#SELECT @total:= COUNT(*) from `roadmaptest`.`phases`;
#UPDATE `roadmaptest`.`sections` t1 SET t1.`phase_id` = MOD(t1.`id`, @total)

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`sections` ENABLE KEYS;
-- *********************************************************************************************************************


-- # Copy dmp2 Requirements with Ancestry under roadmaptest Questions table
-- Disable the constraints
ALTER TABLE `roadmaptest`.`questions` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`questions`;

-- INSERT Questions that are NOT defined as parts of a Section within the DMPTool
INSERT INTO `roadmaptest`.`questions`(
  `id`,               `text`,                                   `default_value`,       `number`, 
   `question_format_id`,                                             `option_comment_display`,   `modifiable`,       
   `section_id`,          `created_at`,                                 `updated_at`)

SELECT
  r.`id`, CONCAT( '<p>', r.`text_full`,  '</p>' ), NULL, 1, 
  (case `requirement_type` when "text" then 1 when "numeric" then 6 when "date" then 7 end) as `format_type`, 
  1, rt.`active`, 
  (SELECT s.id 
   FROM `roadmaptest`.`sections` s INNER JOIN `roadmaptest`.`phases` p ON s.phase_id = p.id 
   WHERE p.template_id = rt.id AND s.title = r.`text_brief` COLLATE utf8mb4_general_ci),
  r.`created_at`,  r.`updated_at`
FROM `dmp2`.`requirements` r
INNER JOIN `dmp2`.`requirements_templates` rt
ON r.`requirements_template_id` = rt.`id`
WHERE ancestry IS  NULL and `group` = 0;

-- INSERT Questions that are defined as parts of a Section within the DMPTool
INSERT INTO `roadmaptest`.`questions` (
  `id`,               `text`,                                   `default_value`,       `number`,     
  `question_format_id`,                                             `option_comment_display`,  `modifiable`,       
  `section_id`,                                                 `created_at`,         `updated_at`)

SELECT 
  r.`id`, CONCAT( '<p>', r.`text_brief`, '<br />', r.`text_full`, '</p>' ), NULL, `position`, 
  (case `requirement_type` when "text" then 1 when "numeric" then 6 when "date" then 7 end) as `format_type`, 
  1, rt.`active`, 
  substring_index(`ancestry`, '/', -1) as `section`, r.`created_at`, r.`updated_at`
FROM `dmp2`.`requirements` r
INNER JOIN `dmp2`.`requirements_templates` rt
ON r.`requirements_template_id` = rt.`id`
WHERE `group` = 0 AND
ancestry IN ( SELECT  `dmp2`.`requirements`.`id` as `SECTION_iD` FROM `dmp2`.`requirements` WHERE `group` = 1); 

-- *********************************************************************************************************************
-- # Copy dmp2 Enumerations into roadmaptest Question Format labels table
-- Disable the constraints
ALTER TABLE `roadmaptest`.`question_format_labels` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `roadmaptest`.`question_format_labels`;

INSERT INTO `roadmaptest`.`question_format_labels`(
  `id`,   `description`,      `question_id`,       `number`,     `created_at`,   `updated_at`)
  
SELECT
  `id`,   `desc`,       `requirement_id`,     `position`,    `created_at`,   `updated_at`
FROM `dmp2`.`labels`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`question_format_labels` ENABLE KEYS;

-- Disable the constraints
ALTER TABLE `roadmaptest`.`sample_plans` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`sample_plans`;

INSERT INTO `roadmaptest`.`sample_plans`(
  `id`,   `label`,   `url`,   `template_id`,           `created_at`,   `updated_at`)

SELECT
  `id`,   `label`,   `url`,   `requirements_template_id`,    `created_at`,   `updated_at`
FROM `dmp2`.`sample_plans`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`sample_plans` ENABLE KEYS;
-- ***********************************************************************************************************************
-- # Copy Resources directly related to a Requirement from DMPTool into Roadmap Annotations.

-- Collect all of the Question level example_answers and guidance and add it to
-- the annotations table
DELIMITER //
DROP PROCEDURE IF EXISTS bundleQuestionLevelAnnotations;
CREATE PROCEDURE bundleQuestionLevelAnnotations(
  IN org_id INT, IN template_id INT, IN example_answer TEXT, IN guidance TEXT, IN links TEXT
)
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE question_id INT;
  DECLARE my_created_at DATETIME; 
  DECLARE my_updated_at DATETIME;
  DECLARE questions CURSOR FOR 
    SELECT `id`, `created_at`, `updated_at`
    FROM `dmp2`.`requirements` 
    WHERE `requirements_template_id` = template_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN questions;
  get_question: LOOP
    FETCH questions INTO question_id, my_created_at, my_updated_at;
    IF done = 1 THEN
      LEAVE get_question;
    END IF;

    SET @example_answer = (
      SELECT 
        GROUP_CONCAT(
          CONCAT(`resources`.`label`, ':<br />', `resources`.`text`)
        SEPARATOR '<br />') as question
      FROM `dmp2`.`resources` 
      INNER JOIN `dmp2`.`resource_contexts` on `resources`.`id` = `resource_contexts`.`resource_id`
      WHERE `resource_contexts`.`institution_id` IS NULL
      AND `resource_contexts`.`requirement_id` = question_id
      AND `resources`.`resource_type` IN ('suggested_response', 'example_response')
      AND `resource_contexts`.`requirements_template_id` = template_id);
  
    SET @guidance = (
      SELECT 
        GROUP_CONCAT(
          CASE `resources`.`resource_type`
          WHEN 'actionable_url' THEN
            CONCAT('<a href="', `resources`.`value`, '">', `resources`.`label`, '</a>')
          ELSE
            CONCAT(`resources`.`label`, ':<br />', `resources`.`text`)
          END
        SEPARATOR '<br />') as question
      FROM `dmp2`.`resources` 
      INNER JOIN `dmp2`.`resource_contexts` on `resources`.`id` = `resource_contexts`.`resource_id`
      WHERE `resource_contexts`.`institution_id` IS NULL
      AND `resource_contexts`.`requirement_id` = question_id
      AND `resources`.`resource_type` = 'help_text'
      AND `resource_contexts`.`requirements_template_id` = template_id);
    
    SET @links = (
      SELECT 
        GROUP_CONCAT(
          CASE `resources`.`resource_type`
          WHEN 'actionable_url' THEN
            CONCAT('<a href="', `resources`.`value`, '">', `resources`.`label`, '</a>')
          ELSE
            CONCAT(`resources`.`label`, ':<br />', `resources`.`text`)
          END
        SEPARATOR '<br />') as question
      FROM `dmp2`.`resources` 
      INNER JOIN `dmp2`.`resource_contexts` on `resources`.`id` = `resource_contexts`.`resource_id`
      WHERE `resource_contexts`.`institution_id` IS NULL
      AND `resource_contexts`.`requirement_id` = question_id
      AND `resources`.`resource_type` = 'actionable_url'
      AND `resource_contexts`.`requirements_template_id` = template_id);

    -- If there was Template level example answers and question level example answers concat them together
    IF example_answer IS NOT NULL THEN
      IF @example_answer IS NOT NULL THEN
        SET @example_answer = CONCAT(example_answer, '<br /><br />', @example_answer);
      ELSE
        SET @example_answer = example_answer;
      END IF;
    END IF;

    -- If there was Template level guidance and question level guidance concat them together
    IF guidance IS NOT NULL THEN
      IF @guidance IS NOT NULL THEN
        SET @guidance = CONCAT(guidance, '<br /><br />', @guidance);
      ELSE
        SET @guidance = guidance;
      END IF;
    END IF;

    -- If there was Template level links and question level links concat them together
    IF links IS NOT NULL THEN
      IF @links IS NOT NULL THEN
        SET @links = CONCAT(links, '<br /><br />', @links);
      ELSE
        SET @links = links;
      END IF;
    END IF;

    -- Combine the template level with the question level
    IF @example_answer IS NOT NULL THEN
      INSERT INTO `roadmaptest`.`annotations` (
        `text`, `question_id`, `org_id`, `type`, `created_at`, `updated_at`
      )VALUES(
        CONCAT('<p>', @example_answer,'</p>'), question_id, org_id, 0, my_created_at, my_updated_at
      );
    END IF;

    -- Combine the guidance and links
    IF @links IS NOT NULL THEN
      SET @guidance = CONCAT(COALESCE(@guidance, ''), '<br /><br />', @links);
    END IF;
    
    SET @val = (SELECT `text` FROM `roadmaptest`.`questions` WHERE `id` = question_id);
    
    -- If the question does not have any actual text then use the 
    -- question level guidance for the question text and the template level
    -- guidance as guidance annotation
    IF (@val IS NULL OR @val = '<p></p>') AND @guidance IS NOT NULL THEN
      UPDATE `roadmaptest`.`questions` SET `text` = CONCAT('<p>', @guidance, '</p>')
      WHERE `id` = question_id;
      
      IF guidance IS NOT NULL THEN
        INSERT INTO `roadmaptest`.`annotations` (
          `text`, `question_id`, `org_id`, `type`, `created_at`, `updated_at`
        )VALUES(
          CONCAT('<p>', guidance, '</p>'), question_id, org_id, 1, my_created_at, my_updated_at
        );
      END IF;
    ELSE
      IF @guidance IS NOT NULL THEN
        INSERT INTO `roadmaptest`.`annotations` (
          `text`, `question_id`, `org_id`, `type`, `created_at`, `updated_at`
        )VALUES(
          CONCAT('<p>', @guidance, '</p>'), question_id, org_id, 1, my_created_at, my_updated_at
        );
       END IF;
    END IF;
    
  END LOOP get_question;
  
  CLOSE questions;
END//

-- Collect all of the Template level example_answers and guidance
DROP PROCEDURE IF EXISTS bundleFunderAnnotations;
CREATE PROCEDURE bundleFunderAnnotations()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE my_org_id INT;
  DECLARE template_id INT;
  DECLARE templates CURSOR FOR SELECT `org_id`, `id` FROM `roadmaptest`.`templates`;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  
  OPEN templates;
  get_template: LOOP
    FETCH templates INTO my_org_id, template_id;
    IF done = 1 THEN
      LEAVE get_template;
    END IF;

    SET @example_answer = (
      SELECT 
        GROUP_CONCAT(
          CONCAT(`resources`.`label`, ':<br />', `resources`.`text`)
        SEPARATOR '<br />') as question
      FROM `dmp2`.`resources` 
      INNER JOIN `dmp2`.`resource_contexts` on `resources`.`id` = `resource_contexts`.`resource_id`
      WHERE `resource_contexts`.`institution_id` IS NULL
      AND `resource_contexts`.`requirement_id` IS NULL
      AND `resources`.`resource_type` IN ('suggested_response', 'example_response')
      AND `resource_contexts`.`requirements_template_id` = template_id);
  
    SET @guidance = (
      SELECT 
        GROUP_CONCAT(
          CASE `resources`.`resource_type`
          WHEN 'actionable_url' THEN
            CONCAT('<a href="', `resources`.`value`, '">', `resources`.`label`, '</a>')
          ELSE
            CONCAT(`resources`.`label`, ':<br />', `resources`.`text`)
          END
        SEPARATOR '<br />') as question
      FROM `dmp2`.`resources` 
      INNER JOIN `dmp2`.`resource_contexts` on `resources`.`id` = `resource_contexts`.`resource_id`
      WHERE `resource_contexts`.`institution_id` IS NULL
      AND `resource_contexts`.`requirement_id` IS NULL
      AND `resources`.`resource_type` = 'help_text'
      AND `resource_contexts`.`requirements_template_id` = template_id);
  
    SET @links = (
      SELECT 
        GROUP_CONCAT(
          CASE `resources`.`resource_type`
          WHEN 'actionable_url' THEN
            CONCAT('<a href="', `resources`.`value`, '">', `resources`.`label`, '</a>')
          ELSE
            CONCAT(`resources`.`label`, ':<br />', `resources`.`text`)
          END
        SEPARATOR '<br />') as question
      FROM `dmp2`.`resources` 
      INNER JOIN `dmp2`.`resource_contexts` on `resources`.`id` = `resource_contexts`.`resource_id`
      WHERE `resource_contexts`.`institution_id` IS NULL
      AND `resource_contexts`.`requirement_id` IS NULL
      AND `resources`.`resource_type` = 'actionable_url'
      AND `resource_contexts`.`requirements_template_id` = template_id);

--    IF @guidance IS NOT NULL AND @links IS NOT NULL THEN
--      SET @links = CONCAT('<br /><br />', @links);
--    END IF;
--    IF @links IS NOT NULL THEN
--      SET @guidance = CONCAT(COALESCE(@guidance, ''), @links);
--    END IF;

    CALL bundleQuestionLevelAnnotations(my_org_id, template_id, @example_answer, @guidance, @links);
  
  END LOOP get_template;
  
  CLOSE templates;
END//
DELIMITER ;

-- Disable the constraints
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`annotations`;

-- Insert all of the Funder Annotation
CALL bundleFunderAnnotations();

-- Remove any tabs and new line characters from the imported annotations
UPDATE `roadmaptest`.`annotations` SET `text` = REPLACE(REPLACE(REPLACE(`text`, '\n', '<br />'), '\r', ''), '\t', '  ');

DELETE FROM `roadmaptest`.`annotations` WHERE `text` IS NULL;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
-- ***********************************************************************************************************************

-- *********************************************************************************************************************

-- # Copy dmp2 Plans into roadmaptest Plans table where visibility is "Institutional"
-- Disable the constraints
ALTER TABLE `roadmaptest`.`plans` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`plans`;

INSERT INTO `roadmaptest`.`plans`(
  `id`,            `title`,                `template_id`,        `grant_number`,   `identifier`,  
  `description`,        `slug`,                  `funder_name`,          `visibility`,      
  `data_contact`,        `data_contact_email`,          `data_contact_phone`,
  `principal_investigator`,   `principal_investigator_identifier`,  `principal_investigator_email`,
  `created_at`,        `updated_at`)

SELECT   
  `id`,            `name`,                  `requirements_template_id`,     NULL,      `solicitation_identifier`,
  `name`,             NULL,                   NULL,                  0,  
   NULL,              NULL,                   NULL,
   NULL,             NULL,                      NULL,  
  `created_at`,        `updated_at`
FROM `dmp2`.`plans`
WHERE `visibility` = 'institutional'
AND LENGTH(`name`) < 255;

-- # Copy dmp2 Plans into roadmaptest Plans table where visibility is "Public"
INSERT INTO `roadmaptest`.`plans`(
  `id`,            `title`,                `template_id`,        `grant_number`,   `identifier`,  
  `description`,        `slug`,                  `funder_name`,          `visibility`,      
  `data_contact`,        `data_contact_email`,          `data_contact_phone`,
  `principal_investigator`,   `principal_investigator_identifier`,  `principal_investigator_email`,
  `created_at`,        `updated_at`)

SELECT   
  `id`,            `name`,                  `requirements_template_id`,      NULL,      `solicitation_identifier`,
  `name`,              NULL,                   NULL,                  1,  
   NULL,              NULL,                   NULL,
   NULL,              NULL,                   NULL,  
  `created_at`,        `updated_at`
FROM `dmp2`.`plans`
WHERE `visibility` = 'public'
AND LENGTH(`name`) < 255;

-- # Copy dmp2 Plans into roadmaptest Plans table where visibility is  "unit" or "test"
INSERT INTO `roadmaptest`.`plans`(
  `id`,            `title`,                `template_id`,        `grant_number`,   `identifier`,  
  `description`,        `slug`,                  `funder_name`,          `visibility`,      
  `data_contact`,        `data_contact_email`,          `data_contact_phone`,
  `principal_investigator`,   `principal_investigator_identifier`,  `principal_investigator_email`,
  `created_at`,        `updated_at`)

SELECT   
  `id`,            `name`,                  `requirements_template_id`,     NULL,      `solicitation_identifier`,
  `name`,             NULL,                   NULL,                  2,  
   NULL,              NULL,                   NULL,
   NULL,              NULL,                   NULL,  
  `created_at`,        `updated_at`
FROM `dmp2`.`plans`
WHERE `visibility` IN ('test', 'unit')
AND LENGTH(`name`) < 255;

-- # Copy dmp2 Plans into roadmaptest Plans table where visibility is "Private"
INSERT INTO `roadmaptest`.`plans`(
  `id`,            `title`,                `template_id`,        `grant_number`,   `identifier`,  
  `description`,        `slug`,                  `funder_name`,          `visibility`,      
  `data_contact`,        `data_contact_email`,          `data_contact_phone`,
  `principal_investigator`,   `principal_investigator_identifier`,  `principal_investigator_email`,
  `created_at`,        `updated_at`)

SELECT   
  `id`,            `name`,                  `requirements_template_id`,      NULL,      `solicitation_identifier`,
  `name`,             NULL,                    NULL,                3,  
   NULL,             NULL,                     NULL,
   NULL,             NULL,                    NULL,  
  `created_at`,        `updated_at`
FROM `dmp2`.`plans`
WHERE `visibility` = 'private'
AND LENGTH(`name`) < 255;

-- # Copy dmp2 Plans into roadmaptest Plans table where title length is too long.
INSERT INTO `roadmaptest`.`plans`(
  `id`,            `title`,                `template_id`,        `grant_number`,   `identifier`,  
  `description`,        `slug`,                  `funder_name`,          `visibility`,      
  `data_contact`,        `data_contact_email`,          `data_contact_phone`,
  `principal_investigator`,   `principal_investigator_identifier`,  `principal_investigator_email`,
  `created_at`,        `updated_at`)

SELECT   
  `id`,            SUBSTRING_INDEX(`name`, ' ', 6),    `requirements_template_id`,      NULL,      `solicitation_identifier`,
  `name`,             NULL,                    NULL,                3,  
   NULL,             NULL,                     NULL,
   NULL,             NULL,                    NULL,  
  `created_at`,        `updated_at`
FROM `dmp2`.`plans`
WHERE LENGTH(`name`) > 255
AND `visibility` = 'private';

INSERT INTO `roadmaptest`.`plans`(
  `id`,            `title`,                `template_id`,        `grant_number`,   `identifier`,  
  `description`,        `slug`,                  `funder_name`,          `visibility`,      
  `data_contact`,        `data_contact_email`,          `data_contact_phone`,
  `principal_investigator`,   `principal_investigator_identifier`,  `principal_investigator_email`,
  `created_at`,        `updated_at`)

SELECT   
  `id`,            SUBSTRING_INDEX(`name`, ' ', 6),    `requirements_template_id`,      NULL,      `solicitation_identifier`,
  `name`,             NULL,                    NULL,                2,  
   NULL,             NULL,                     NULL,
   NULL,             NULL,                    NULL,  
  `created_at`,        `updated_at`
FROM `dmp2`.`plans`
WHERE LENGTH(`name`) > 255
AND `visibility` IN ('test', 'unit');

INSERT INTO `roadmaptest`.`plans`(
  `id`,            `title`,                `template_id`,        `grant_number`,   `identifier`,  
  `description`,        `slug`,                  `funder_name`,          `visibility`,      
  `data_contact`,        `data_contact_email`,          `data_contact_phone`,
  `principal_investigator`,   `principal_investigator_identifier`,  `principal_investigator_email`,
  `created_at`,        `updated_at`)

SELECT   
  `id`,            SUBSTRING_INDEX(`name`, ' ', 6),    `requirements_template_id`,      NULL,      `solicitation_identifier`,
  `name`,             NULL,                    NULL,                1,  
   NULL,             NULL,                     NULL,
   NULL,             NULL,                    NULL,  
  `created_at`,        `updated_at`
FROM `dmp2`.`plans`
WHERE LENGTH(`name`) > 255
AND `visibility` IN ('public');

INSERT INTO `roadmaptest`.`plans`(
  `id`,            `title`,                `template_id`,        `grant_number`,   `identifier`,  
  `description`,        `slug`,                  `funder_name`,          `visibility`,      
  `data_contact`,        `data_contact_email`,          `data_contact_phone`,
  `principal_investigator`,   `principal_investigator_identifier`,  `principal_investigator_email`,
  `created_at`,        `updated_at`)

SELECT   
  `id`,            SUBSTRING_INDEX(`name`, ' ', 6),    `requirements_template_id`,      NULL,      `solicitation_identifier`,
  `name`,             NULL,                    NULL,                0,  
   NULL,             NULL,                     NULL,
   NULL,             NULL,                    NULL,  
  `created_at`,        `updated_at`
FROM `dmp2`.`plans`
WHERE LENGTH(`name`) > 255
AND `visibility` IN ('institutional');

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`plans` ENABLE KEYS;
-- *********************************************************************************************************************

-- # Copy user_plans of dmp2 into Roles in DMP Migration
-- Disable the constraints
ALTER TABLE `roadmaptest`.`roles` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`roles`;

-- Owners
INSERT INTO `roadmaptest`.`roles`(
  `id`,    `user_id`,      `plan_id`,    `access`,     `created_at`,        `updated_at`)

SELECT 
  `id`,    `user_id`,      `plan_id`,      14,     `created_at`,        `updated_at`
FROM `dmp2`.`user_plans`
WHERE `owner` = 0;

-- Coowners
INSERT INTO `roadmaptest`.`roles`(
  `id`,    `user_id`,      `plan_id`,    `access`,     `created_at`,        `updated_at`)

SELECT 
  `id`,    `user_id`,      `plan_id`,      15,     `created_at`,        `updated_at`
FROM `dmp2`.`user_plans`
WHERE `owner` = 1;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`roles` ENABLE KEYS;
-- ALTER TABLE `roadmaptest`.`roles` DROP FOREIGN KEY `fk_rails_ab35d699f0`;
-- **********************************************************************************************************************

-- # Copy dmp2 Responses into roadmaptest Answers table
-- Disable the constraints
ALTER TABLE `roadmaptest`.`answers` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`answers`;

INSERT INTO `roadmaptest`.`answers` (
  `id`,                     `plan_id`,                 

  `text`,                                       
  
  `question_id`,                 `lock_version`,            `user_id`,

  `label_id`,                                     `created_at`,                              `updated_at`)

SELECT
  `dmp2`.`responses`.`id`,           `dmp2`.`responses`.`plan_id`,    

  COALESCE(`dmp2`.`responses`.`text_value`,  `dmp2`.`responses`.`numeric_value`,   `dmp2`.`responses`.`date_value`),  
  
  `dmp2`.`responses`.`requirement_id`,     `dmp2`.`responses`.`lock_version`,   `userplan`.`user_id`,

  `dmp2`.`responses`.`label_id`,         `dmp2`.`responses`.`created_at`,   `dmp2`.`responses`.`updated_at`

FROM `dmp2`.`responses`
LEFT JOIN (select `user_id`, `plan_id` from `dmp2`.`user_plans` where `dmp2`.`user_plans`.`owner` = 1) `USERPLAN`
ON `dmp2`.`responses`.`plan_id` = `USERPLAN`.`plan_id`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`answers` ENABLE KEYS;
-- *********************************************************************************************************************

-- # Copy dmp2 Enumerations into roadmaptest Question Options table
-- Disable the constraints
ALTER TABLE `roadmaptest`.`question_options` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`question_options`;

INSERT INTO `roadmaptest`.`question_options`(
   `id`,  `question_id`,    `text`,    `number`,    `is_default`,  `created_at`,  `updated_at`)
 
SELECT 
  `id`,   `requirement_id`,   `value`,   `position`,    `default`,     `created_at`,   `updated_at`
FROM `dmp2`.`enumerations`;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`question_options` ENABLE KEYS;
-- #*********************************************************************************************************************

-- # Copy Enumeration ID of Responses into Answer Question Options table.
-- Disable the constraints
ALTER TABLE `roadmaptest`.`answers_question_options` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`answers_question_options`;

INSERT INTO `roadmaptest`.`answers_question_options`(
    `answer_id`,     `question_option_id`)

SELECT 
    `id`,         `enumeration_id`  
FROM  `dmp2`.`responses` 
WHERE `enumeration_id`  IS NOT NULL;

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`answers_question_options` ENABLE KEYS;
-- **********************************************************************************************************************

-- # Copy dmp2 Comments into Notes tale of roadmaptest and assign the 1st response of the respective plan as answer_id for the note.
-- Disable the constraints

ALTER TABLE `roadmaptest`.`notes` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`notes`;
        
INSERT INTO `roadmaptest`.`notes` ( 
  `id`,                `user_id`,                `text`,    
  `archived`,             `archived_by`,    
  `created_at`,             `updated_at`,               `answer_id`)

SELECT   
  `dmp2`.`comments`.`id`,       `dmp2`.`comments`.`user_id`,       `dmp2`.`comments`.`value`, 
    0,                  NULL , 
   `dmp2`.`comments`.`created_at`,   `dmp2`.`comments`.`updated_at`,     `RESPONSE`.`minresponse`

FROM `dmp2`.`comments`
LEFT JOIN (SELECT `dmp2`.`responses`.`plan_id`, MIN(`dmp2`.`responses`.`id`) as `minresponse`
FROM `dmp2`.`responses`
GROUP BY `dmp2`.`responses`.`plan_id`) `RESPONSE` 
ON `dmp2`.`comments`.`plan_id` = `RESPONSE`.`plan_id`
ORDER BY `dmp2`.`comments`.`id`;


-- ALTER TABLE `roadmaptest`.`notes` DROP FOREIGN KEY  fk_rails_907f8d48bf;  
-- ALTER TABLE `roadmaptest`.`notes` DROP FOREIGN KEY  fk_rails_7f2323ad43;
-- # If we dont want to have any responses as NULL values (i.e no Orphan comments) then tis is the sql query
-- INSERT INTO `roadmaptest`.`notes` ( 
--   `id`,  `user_id`,  `text`,    `archived`,   `archived_by`,    `created_at`,     `updated_at`,     `answer_id`)
-- SELECT   `dmp2`.`comments`.`id`, `dmp2`.`comments`.`user_id`, `dmp2`.`comments`.`value`,  0, NULL , `dmp2`.`comments`.`created_at`, `dmp2`.`comments`.`updated_at`, `RESPONSE`.`minresponse`
-- FROM `dmp2`.`comments`
-- INNER JOIN (SELECT    `dmp2`.`responses`.`plan_id`, MIN(`dmp2`.`responses`.`id`) as `minresponse`
-- FROM `dmp2`.`responses`
-- GROUP BY `dmp2`.`responses`.`plan_id`) `RESPONSE` 
-- ON `dmp2`.`comments`.`plan_id` = `RESPONSE`.`plan_id`
-- ORDER BY `dmp2`.`comments`.`id`

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`notes` ENABLE KEYS;
-- *********************************************************************************************************************

-- # Copy user_plans of dmp2 into Roles in DMP Migration
-- Disable the constraints
ALTER TABLE `roadmaptest`.`guidances` DISABLE KEYS;
SET FOREIGN_KEY_CHECKS = 0;      
TRUNCATE TABLE `roadmaptest`.`guidances`;

DELIMITER //
-- Collect all of the Insitutional Question level example_answers, links and guidance and add it to
-- the guidances table
DROP PROCEDURE IF EXISTS bundleInstitutionalGuidance;
CREATE PROCEDURE bundleInstitutionalGuidance(
  IN institution_id INT
)
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE my_guidance TEXT;
  DECLARE my_created DATETIME;
  DECLARE my_updated DATETIME;

  DECLARE guidances CURSOR FOR 
    SELECT DISTINCT 
      CONCAT(
        '<p>',
        CASE `resources`.`resource_type` 
          WHEN 'actionable_url' THEN
            CONCAT('<a href="', `resources`.`value`, '">', `resources`.`label`, '</a>')
          ELSE
            CONCAT(`resources`.`label`, ':<br />', `resources`.`text`)
        END,
        '</p>'),
      MIN(`resources`.`created_at`), MAX(`resources`.`updated_at`)
    FROM `dmp2`.`resources` 
    INNER JOIN `dmp2`.`resource_contexts` ON `resources`.`id` = `resource_contexts`.`resource_id` 
    INNER JOIN `dmp2`.`requirements_templates` ON `resource_contexts`.`requirements_template_id` = `requirements_templates`.`id`
    INNER JOIN `dmp2`.`institutions` ON `requirements_templates`.`institution_id` = `institutions`.`id`
    WHERE `resource_contexts`.`institution_id` = institution_id
    GROUP BY `resources`.`resource_type`, `resources`.`label`, `resources`.`value`, `resources`.`text`;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN guidances;
  get_guidance: LOOP
    FETCH guidances INTO my_guidance, my_created, my_updated;
    IF done = 1 THEN
      LEAVE get_guidance;
    END IF;

    SET @group = (SELECT `id` FROM `roadmaptest`.`guidance_groups` WHERE `org_id` = institution_id);

    INSERT INTO `roadmaptest`.`guidances` (`text`, `guidance_group_id`, `created_at`, `updated_at`, `published`)
    VALUES (my_guidance, @group, my_created, my_updated, 1);    
  END LOOP get_guidance;
  
  CLOSE guidances;
END//

DROP PROCEDURE IF EXISTS institutionalGuidance;
CREATE PROCEDURE institutionalGuidance()
BEGIN
  -- Gather all of the non-funder orgs and load their guidance
  DECLARE finished INT DEFAULT 0;
  DECLARE my_id INT;
  DECLARE institutions CURSOR FOR
    SELECT `id` FROM `roadmaptest`.`orgs` WHERE `org_type` != 2;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

  OPEN institutions;
  get_institution: LOOP
    FETCH institutions INTO my_id;
    IF finished = 1 THEN
      LEAVE get_institution;
    END IF;

    CALL bundleInstitutionalGuidance(my_id);
  END LOOP get_institution;
  
  CLOSE institutions;
END//
DELIMITER ;

call institutionalGuidance;

-- Remove any tabs and new line characters from the imported guidance
UPDATE `roadmaptest`.`guidances` SET `text` = REPLACE(REPLACE(REPLACE(`text`, '\n', '<br />'), '\r', ''), '\t', '  ');

-- Enable Back the constraints
SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE `roadmaptest`.`guidances` ENABLE KEYS;

DROP PROCEDURE institutionalGuidance;
DROP PROCEDURE bundleInstitutionalGuidance;
DROP PROCEDURE bundleFunderAnnotations;
DROP PROCEDURE bundleQuestionLevelAnnotations;