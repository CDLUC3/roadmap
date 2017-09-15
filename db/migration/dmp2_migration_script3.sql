-- MANUAL CONTENT CURATION

-- Set the default template (currently using DCC generic template)
UPDATE `roadmaptest`.`templates` SET is_default = 1 WHERE id = 133;

-- Seed the default DCC/UC3 themed guidance
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Give a summary of the data you will collect or create, noting the content, coverage and data type, e.g., tabular data, survey data, experimental measurements, models, software, audiovisual data, physical samples, etc.</li><li>Consider how your data could complement and integrate with existing data, or whether there are any existing data or methods that you could reuse.</li><li>Indicate which data are of long-term value and should be shared and/or preserved.</li><li>If purchasing or reusing existing data, explain how issues such as copyright and IPR have been addressed. You should aim to minimise any restrictions on the reuse (and subsequent sharing) of third-party data.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Clearly note what format(s) your data will be in, e.g., plain text (.txt), comma-separated values (.csv), geo-referenced TIFF (.tif, .tfw).</li><li>Explain why you have chosen certain formats. Decisions may be based on staff expertise, a preference for open formats, the standards accepted by data centres or widespread usage within a given community.</li><li>Using standardised, interchangeable or open formats ensures the long-term usability of data; these are recommended for sharing and archiving.</li><li>See UK Data Service guidance on <a href="https://www.ukdataservice.ac.uk/manage-data/format/recommended-formats">recommended formats</a> or DataONE Best Practices for <a href="https://www.dataone.org/best-practices/document-and-store-data-using-stable-file-formats">file formats</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Note what volume of data you will create in MB/GB/TB. Indicate the proportions of raw data, processed data, and other secondary outputs (e.g., reports).</li><li>Consider the implications of data volumes in terms of storage, access and preservation. Do you need to include additional costs?</li><li>Consider whether the scale of the data will pose challenges when sharing or transferring data between sites; if so, how will you address these challenges?</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Outline how the data will be collected and processed. This should cover relevant standards or methods, quality assurance and data organisation.</li><li>Indicate how the data will be organised during the project, mentioning, e.g., naming conventions, version control and folder structures. Consistent, well-ordered research data will be easier to find, understand and reuse.</li><li>Explain how the consistency and quality of data collection will be controlled and documented. This may include processes such as calibration, repeat samples or measurements, standardised data capture, data entry validation, peer review of data or representation with controlled vocabularies.</li><li>See the DataOne Best Practices for <a href="https://www.dataone.org/best-practices/quality">data quality</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>What metadata will be provided to help others identify and discover the data?</li><li>Researchers are strongly encouraged to use community metadata standards where these are in place. The Research Data Alliance offers a <a href="http://rd-alliance.github.io/metadata-directory/">Directory of Metadata Standards</a>. Data repositories may also provide guidance about appropriate metadata standards.</li><li>Consider what other documentation is needed to enable reuse. This may include information on the methodology used to collect the data, analytical and procedural information, definitions of variables, units of measurement, any assumptions made, the format and file type of the data and software used to collect and/or process the data.</li><li>Consider how you will capture this information and where it will be recorded, e.g., in a database with links to each item, in a ‘readme’ text file, in file headers, etc.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Investigators carrying out research involving human participants should request consent to preserve and share the data. Do not just ask for permission to use the data in your study or make unnecessary promises to delete it at the end.</li><li>Consider how you will protect the identity of participants, e.g., via anonymisation or using managed access procedures.</li><li>Ethical issues may affect how you store and transfer data, who can see/use it and how long it is kept. You should demonstrate that you are aware of this and have planned accordingly.</li><li>See UK Data Service guidance on <a href="https://www.ukdataservice.ac.uk/manage-data/legal-ethical/consent-data-sharing">consent for data sharing</a>.</li><li>See <a href="http://www.icpsr.umich.edu/icpsrweb/content/datamanagement/confidentiality/index.html">ICPSR approach to confidentiality</a> and Health Insurance Portability and Accountability Act <a href="https://privacyruleandresearch.nih.gov/">(HIPAA) regulations for health research</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>State who will own the copyright and IPR of any existing data as well as new data that you will generate. For multi-partner projects, IPR ownership should be covered in the consortium agreement.</li><li>Outline any restrictions needed on data sharing, e.g., to protect proprietary or patentable data.</li><li>Explain how the data will be licensed for reuse. See the DCC guide on <a href="http://www.dcc.ac.uk/resources/how-guides/license-research-data">How to license research data</a> and EUDAT’s <a href="https://ufal.github.io/public-license-selector/">data and software licensing wizard</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Describe where the data will be stored and backed up during the course of research activities. This may vary if you are doing fieldwork or working across multiple sites so explain each procedure.</li><li>Identify who will be responsible for backup and how often this will be performed. The use of robust, managed storage with automatic backup, for example, that provided by university IT teams, is preferable. Storing data on laptops, computer hard drives or external storage devices alone is very risky.</li><li>See UK Data Service Guidance on <a href="https://www.ukdataservice.ac.uk/manage-data/store">data storage</a> or DataONE Best Practices for <a href="https://www.dataone.org/best-practices/storage">storage</a>.</li><li>Also consider data security, particularly if your data is sensitive e.g., detailed personal data, politically sensitive information or trade secrets. Note the main risks and how these will be managed. Also note whether any institutional data security policies are in place.</li><li>Identify any formal standards that you will comply with, e.g., <a href="http://www.dcc.ac.uk/resources/briefing-papers/standards-watch-papers/information-security-management-iso-27000-iso-27k-s">ISO 27001</a>. See the DCC Briefing Paper on Information Security Management - ISO 27000 and UK Data Service guidance on <a href="https://www.ukdataservice.ac.uk/manage-data/store/security">data security</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>How will you share the data e.g. deposit in a data repository, use a secure data service, handle data requests directly or use another mechanism? The methods used will depend on a number of factors such as the type, size, complexity and sensitivity of the data.</li><li>When will you make the data available? Research funders expect timely release. They typically allow embargoes but not prolonged exclusive use.</li><li>Who will be able to use your data? If you need to restrict access to certain communities or apply data sharing agreements, explain why.</li><li>Consider strategies to minimise restrictions on sharing. These may include anonymising or aggregating data, gaining participant consent for data sharing, gaining copyright permissions, and agreeing a limited embargo period.</li><li>How might your data be reused in other contexts? Where there is potential for reuse, you should use standards and formats that facilitate this, and ensure that appropriate metadata is available online so your data can be discovered. Persistent identifiers should be applied so people can reliably and efficiently find your data. They also help you to track citations and reuse.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Where will the data be deposited? If you do not propose to use an established repository, the data management plan should demonstrate that the data can be curated effectively beyond the lifetime of the grant.</li><li>It helps to show that you have consulted with the repository to understand their policies and procedures, including any metadata standards, and costs involved.</li><li>An international list of data repositories is available via <a href="http://www.re3data.org/">re3data</a> and some universities or publishers provide lists of recommendations e.g., <a href="http://journals.plos.org/plosone/s/data-availability#loc-recommended-repositories">PLOS ONE recommended repositories</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Outline the plans for data sharing and preservation - how long will the data be retained and where will it be archived? Will additional resources be needed to prepare data for deposit or meet any charges from data repositories?</li><li>See the DCC guide: <a href="http://www.dcc.ac.uk/resources/how-guides/appraise-select-data">How to appraise and select research data for curation</a> or DataONE Best Practices: <a href="https://www.dataone.org/best-practices/identify-data-long-term-value">Identifying data with long-term value</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Outline the roles and responsibilities for all activities, e.g., data capture, metadata production, data quality, storage and backup, data archiving & data sharing. Individuals should be named where possible.</li><li>For collaborative projects you should explain the coordination of data management responsibilities across partners.</li><li>See UK Data Service guidance on <a href="https://www.ukdataservice.ac.uk/manage-data/plan/roles-and-responsibilities">data management roles and responsibilities</a> or DataONE Best Practices: <a href="https://www.dataone.org/best-practices/define-roles-and-assign-responsibilities-data-management">Define roles and assign responsibilities for data management</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Carefully consider and justify any resources needed to deliver the plan. These may include storage costs, hardware, staff time, costs of preparing data for deposit and repository charges.</li><li>Outline any relevant technical expertise, support and training that is likely to be required and how it will be acquired.</li><li>If you are not depositing in a data repository, ensure you have appropriate resources and systems in place to share and preserve the data. See UK Data Service guidance on <a href="https://www.ukdataservice.ac.uk/manage-data/plan/costing">costing data management</a>.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));
INSERT INTO `roadmaptest`.`guidances` (guidance_group_id, `text`, published, `created_at`, `updated_at`) 
(SELECT id,
'<ul><li>Consider whether there are any existing procedures that you can base your approach on. If your group/department has local guidelines that you work to, point to them here.</li><li>List any other relevant funder, institutional, departmental or group policies on data management, data sharing and data security.</li></ul>'
, 1, CURDATE(), CURDATE() FROM guidance_groups where org_id IN (207));

-- Connect the DCC/UC3 themed guidance
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Give a summary of the data you will%')
	FROM `roadmaptest`.`themes` WHERE title = 'Data description'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Clearly note what format(s) your data%')
	FROM `roadmaptest`.`themes` WHERE title = 'Data format'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Note what volume of data you will create%')
	FROM `roadmaptest`.`themes` WHERE title = 'Data volume'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Outline how the data will be collected%')
	FROM `roadmaptest`.`themes` WHERE title = 'Data collection'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>What metadata will be provided to help%')
	FROM `roadmaptest`.`themes` WHERE title = 'Metadata & documentation'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Investigators carrying out research%')
	FROM `roadmaptest`.`themes` WHERE title = 'Ethics & privacy'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>State who will own the copyright%')
	FROM `roadmaptest`.`themes` WHERE title = 'Intellectual property rights'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Describe where the data will be%')
	FROM `roadmaptest`.`themes` WHERE title = 'Storage and security'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>How will you share the data e.g.%')
	FROM `roadmaptest`.`themes` WHERE title = 'Data sharing'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Where will the data be deposited?%')
	FROM `roadmaptest`.`themes` WHERE title = 'Data repository'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Outline the plans for data sharing%')
	FROM `roadmaptest`.`themes` WHERE title = 'Preservation'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Outline the roles and responsibilities%')
	FROM `roadmaptest`.`themes` WHERE title = 'Roles & responsibilities'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Carefully consider and justify any%')
	FROM `roadmaptest`.`themes` WHERE title = 'Budget'
);
INSERT INTO `roadmaptest`.`themes_in_guidance` (theme_id, guidance_id) (
  SELECT id,
  (SELECT id FROM `roadmaptest`.`guidances` WHERE `text` LIKE '<ul><li>Consider whether there are any%')
	FROM `roadmaptest`.`themes` WHERE title = 'Related policies'
);
