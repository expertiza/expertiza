
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `content_pages`;
CREATE TABLE `content_pages` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `name` varchar(255) NOT NULL,
  `markup_style_id` int(11) default NULL,
  `content` text,
  `permission_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `fk_content_page_permission_id` (`permission_id`),
  KEY `fk_content_page_markup_style_id` (`markup_style_id`),
  CONSTRAINT `fk_content_page_markup_style_id` FOREIGN KEY (`markup_style_id`) REFERENCES `markup_styles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_content_page_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `content_pages` DISABLE KEYS */;
LOCK TABLES `content_pages` WRITE;
INSERT INTO `content_pages` VALUES (1,'Home Page','home',1,'h1. Welcome to Goldberg!\r\n\r\nLooks like you have succeeded in getting Goldberg up and running.  Now you will probably want to customise your site.\r\n\r\n*Very important:* The default login for the administrator is \"admin\", password \"admin\".  You must change that before you make your site public!\r\n\r\nh2. Administering the Site\r\n\r\nAt the login prompt, enter an administrator username and password.  The top menu should change: a new item called \"Administration\" will appear.  Go there for further details.\r\n\r\n\r\n',3,'2006-06-11 14:31:56','2006-10-01 13:43:39');
INSERT INTO `content_pages` VALUES (2,'Session Expired','expired',1,'h1. Session Expired\r\n\r\nYour session has expired due to inactivity.\r\n\r\nTo continue please login again.\r\n\r\n',3,'2006-06-11 14:33:14','2006-10-01 13:43:03');
INSERT INTO `content_pages` VALUES (3,'Not Found!','notfound',1,'h1. Not Found\r\n\r\nThe page you requested was not found!\r\n\r\nPlease contact your system administrator.',3,'2006-06-11 14:33:49','2006-10-01 13:44:55');
INSERT INTO `content_pages` VALUES (4,'Permission Denied!','denied',1,'h1. Permission Denied\r\n\r\nSorry, but you don\'t have permission to view that page.\r\n\r\nPlease contact your system administrator.',3,'2006-06-11 14:34:30','2006-10-01 13:41:24');
INSERT INTO `content_pages` VALUES (6,'Contact Us','contact_us',1,'h1. Contact Us\r\n\r\nVisit the Goldberg Project Homepage at \"http://goldberg.rubyforge.org\":http://goldberg.rubyforge.org for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at \"http://rubyforge.org/projects/goldberg\":http://rubyforge.org/projects/goldberg to access the project\'s files and development information.\r\n',3,'2006-06-12 00:13:47','2006-10-02 04:01:19');
INSERT INTO `content_pages` VALUES (8,'Site Administration','site_admin',1,'h1. Goldberg Setup\r\n\r\nThis is where you will find all the Goldberg-specific administration and configuration features.  In here you can:\r\n\r\n* Set up Users.\r\n\r\n* Manage Roles and their Permissions.\r\n\r\n* Set up any Controllers and their Actions for your application.\r\n\r\n* Edit the Content Pages of the site.\r\n\r\n* Adjust Goldberg\'s system settings.\r\n\r\n\r\nh2. Users\r\n\r\nYou can set up Users with a username, password and a Role.\r\n\r\n\r\nh2. Roles and Permissions\r\n\r\nA User\'s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.\r\n\r\nA Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.\r\n\r\n\r\nh2. Controllers and Actions\r\n\r\nTo execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.\r\n\r\nYou start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.\r\n\r\nYou have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.\r\n\r\n\r\nh2. Content Pages\r\n\r\nGoldberg has a very simple CMS built in.  You can create pages to be displayed on the site, possibly in menu items.\r\n\r\n\r\nh2. Menu Editor\r\n\r\nOnce you have set up your Controller Actions and Content Pages, you can put them into the site\'s menu using the Menu Editor.\r\n\r\nIn the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.\r\n\r\nh2. System Settings\r\n\r\nGo here to view and edit the settings that determine how Goldberg operates.\r\n',1,'2006-06-21 11:32:35','2006-10-01 13:46:01');
INSERT INTO `content_pages` VALUES (9,'Administration','admin',1,'h1. Site Administration\r\n\r\nThis is where the administrator can set up the site.\r\n\r\nThere is one menu item here by default -- \"Setup\":/menu/setup.  That contains all the Goldberg configuration options.\r\n\r\nYou can add more menu items here to administer your application if you want, by going to \"Setup, Menu Editor\":/menu/setup/menus.\r\n',1,'2006-06-26 06:47:09','2006-10-01 13:38:20');
INSERT INTO `content_pages` VALUES (10,'Credits and Licence','credits',1,'h1. Credits and Licence\r\n\r\nGoldberg contains original material and third party material from various sources.\r\n\r\nAll original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.\r\n\r\nThe copyright for any third party material remains with the original author, and the material is distributed here under the original terms.  \r\n\r\nMaterial has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, BSD-style licences, and Creative Commons licences (but *not* Creative Commons Non-Commercial).\r\n\r\nIf you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).\r\n\r\n\r\nh2. Layouts\r\n\r\nGoldberg comes with a choice of layouts, adapted from various sources.\r\n\r\nh3. The Default\r\n\r\nThe default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2493/.\r\n\r\nAuthor\'s website: \"andreasviklund.com\":http://andreasviklund.com/.\r\n\r\n\r\nh3. \"Earth Wind and Fire\"\r\n\r\nOriginally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: \"Every template we create is completely open source, meaning you can take it and do whatever you want with it\").  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2453/.\r\n\r\nAuthor\'s website: \"www.madseason.co.uk\":http://www.madseason.co.uk/.\r\n\r\n\r\nh3. \"Snooker\"\r\n\r\n\"Snooker\" is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the \"A List Apart\":http://alistapart.com/articles/negativemargins website.\r\n\r\n\r\nh3. \"Spoiled Brat\"\r\n\r\nOriginally designed by \"Rayk Web Design\":http://www.raykdesign.net/ and distributed under the terms of the \"Creative Commons Attribution Share Alike\":http://creativecommons.org/licenses/by-sa/2.5/legalcode licence.  The original template can be obtained from \"Open Web Design\":http://www.openwebdesign.org/viewdesign.phtml?id=2894/.\r\n\r\nAuthor\'s website: \"www.csstinderbox.com\":http://www.csstinderbox.com/.\r\n\r\n\r\nh2. Other Features\r\n\r\nGoldberg also contains some miscellaneous code and techniques from other sources.\r\n\r\nh3. Suckerfish Menus\r\n\r\nThe three templates \"Earth Wind and Fire\", \"Snooker\" and \"Spoiled Brat\" have all been configured to use Suckerfish menus.  This technique of using a combination of CSS and Javascript to implement dynamic menus was first described by \"A List Apart\":http://www.alistapart.com/articles/dropdowns/.  Goldberg\'s implementation also incorporates techniques described by \"HTMLDog\":http://www.htmldog.com/articles/suckerfish/dropdowns/.\r\n\r\nh3. Tabbed Panels\r\n\r\nGoldberg\'s implementation of tabbed panels was adapted from \r\n\"InternetConnection\":http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml.\r\n\r\n',3,'2006-10-02 00:35:35','2006-10-02 03:59:02');
UNLOCK TABLES;
/*!40000 ALTER TABLE `content_pages` ENABLE KEYS */;
DROP TABLE IF EXISTS `controller_actions`;
CREATE TABLE `controller_actions` (
  `id` int(11) NOT NULL auto_increment,
  `site_controller_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `permission_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_controller_action_permission_id` (`permission_id`),
  KEY `fk_controller_action_site_controller_id` (`site_controller_id`),
  CONSTRAINT `fk_controller_action_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_controller_action_site_controller_id` FOREIGN KEY (`site_controller_id`) REFERENCES `site_controllers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `controller_actions` DISABLE KEYS */;
LOCK TABLES `controller_actions` WRITE;
INSERT INTO `controller_actions` VALUES (1,1,'view_default',3);
INSERT INTO `controller_actions` VALUES (2,1,'view',3);
INSERT INTO `controller_actions` VALUES (3,7,'list',NULL);
INSERT INTO `controller_actions` VALUES (4,6,'list',NULL);
INSERT INTO `controller_actions` VALUES (5,3,'login',4);
INSERT INTO `controller_actions` VALUES (6,3,'logout',4);
INSERT INTO `controller_actions` VALUES (7,5,'link',4);
INSERT INTO `controller_actions` VALUES (8,1,'list',NULL);
INSERT INTO `controller_actions` VALUES (9,8,'list',NULL);
INSERT INTO `controller_actions` VALUES (10,2,'list',NULL);
INSERT INTO `controller_actions` VALUES (11,5,'list',NULL);
INSERT INTO `controller_actions` VALUES (12,9,'list',NULL);
INSERT INTO `controller_actions` VALUES (13,3,'forgotten',4);
INSERT INTO `controller_actions` VALUES (14,3,'login_failed',4);
INSERT INTO `controller_actions` VALUES (15,10,'list',NULL);
UNLOCK TABLES;
/*!40000 ALTER TABLE `controller_actions` ENABLE KEYS */;
DROP TABLE IF EXISTS `markup_styles`;
CREATE TABLE `markup_styles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `markup_styles` DISABLE KEYS */;
LOCK TABLES `markup_styles` WRITE;
INSERT INTO `markup_styles` VALUES (1,'Textile');
INSERT INTO `markup_styles` VALUES (2,'Markdown');
UNLOCK TABLES;
/*!40000 ALTER TABLE `markup_styles` ENABLE KEYS */;
DROP TABLE IF EXISTS `menu_items`;
CREATE TABLE `menu_items` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` int(11) default NULL,
  `name` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `seq` int(11) default NULL,
  `controller_action_id` int(11) default NULL,
  `content_page_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_menu_item_controller_action_id` (`controller_action_id`),
  KEY `fk_menu_item_content_page_id` (`content_page_id`),
  KEY `fk_menu_item_parent_id` (`parent_id`),
  CONSTRAINT `fk_menu_item_content_page_id` FOREIGN KEY (`content_page_id`) REFERENCES `content_pages` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_menu_item_controller_action_id` FOREIGN KEY (`controller_action_id`) REFERENCES `controller_actions` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_menu_item_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `menu_items` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
LOCK TABLES `menu_items` WRITE;
INSERT INTO `menu_items` VALUES (1,NULL,'home','Home',1,NULL,1);
INSERT INTO `menu_items` VALUES (2,NULL,'contact_us','Contact Us',3,NULL,6);
INSERT INTO `menu_items` VALUES (3,NULL,'admin','Administration',2,NULL,9);
INSERT INTO `menu_items` VALUES (5,9,'setup/permissions','Permissions',3,4,NULL);
INSERT INTO `menu_items` VALUES (6,9,'setup/roles','Roles',2,3,NULL);
INSERT INTO `menu_items` VALUES (7,9,'setup/pages','Content Pages',5,8,NULL);
INSERT INTO `menu_items` VALUES (8,9,'setup/controllers','Controllers / Actions',4,9,NULL);
INSERT INTO `menu_items` VALUES (9,3,'setup','Setup',1,NULL,8);
INSERT INTO `menu_items` VALUES (11,9,'setup/menus','Menu Editor',6,11,NULL);
INSERT INTO `menu_items` VALUES (12,9,'setup/system_settings','System Settings',7,12,NULL);
INSERT INTO `menu_items` VALUES (13,9,'setup/users','Users',1,15,NULL);
INSERT INTO `menu_items` VALUES (14,2,'credits','Credits &amp; Licence',1,NULL,10);
UNLOCK TABLES;
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
LOCK TABLES `permissions` WRITE;
INSERT INTO `permissions` VALUES (1,'Administer site');
INSERT INTO `permissions` VALUES (2,'Public pages - edit');
INSERT INTO `permissions` VALUES (3,'Public pages - view');
INSERT INTO `permissions` VALUES (4,'Public actions - execute');
INSERT INTO `permissions` VALUES (5,'Members only page -- view');
UNLOCK TABLES;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `parent_id` int(11) default NULL,
  `description` varchar(1024) NOT NULL,
  `default_page_id` int(11) default NULL,
  `cache` longtext,
  `created_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `fk_role_parent_id` (`parent_id`),
  KEY `fk_role_default_page_id` (`default_page_id`),
  CONSTRAINT `fk_role_default_page_id` FOREIGN KEY (`default_page_id`) REFERENCES `content_pages` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_role_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
LOCK TABLES `roles` WRITE;
INSERT INTO `roles` VALUES (1,'Public',NULL,'Members of the public who are not logged in.',NULL,NULL,'2006-06-23 11:03:49','2006-10-02 04:13:10');
INSERT INTO `roles` VALUES (2,'Member',1,'',NULL,NULL,'2006-06-23 11:03:50','2006-10-02 04:13:10');
INSERT INTO `roles` VALUES (3,'Administrator',2,'',8,NULL,'2006-06-23 11:03:48','2006-10-02 04:13:10');
UNLOCK TABLES;
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
DROP TABLE IF EXISTS `roles_permissions`;
CREATE TABLE `roles_permissions` (
  `id` int(11) NOT NULL auto_increment,
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_roles_permission_role_id` (`role_id`),
  KEY `fk_roles_permission_permission_id` (`permission_id`),
  CONSTRAINT `fk_roles_permission_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_roles_permission_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `roles_permissions` DISABLE KEYS */;
LOCK TABLES `roles_permissions` WRITE;
INSERT INTO `roles_permissions` VALUES (4,3,1);
INSERT INTO `roles_permissions` VALUES (6,1,3);
INSERT INTO `roles_permissions` VALUES (7,3,2);
INSERT INTO `roles_permissions` VALUES (9,1,4);
INSERT INTO `roles_permissions` VALUES (10,2,5);
UNLOCK TABLES;
/*!40000 ALTER TABLE `roles_permissions` ENABLE KEYS */;
DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) NOT NULL,
  `data` longtext,
  `created_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
LOCK TABLES `sessions` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
DROP TABLE IF EXISTS `site_controllers`;
CREATE TABLE `site_controllers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `builtin` int(10) unsigned default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_site_controller_permission_id` (`permission_id`),
  CONSTRAINT `fk_site_controller_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `site_controllers` DISABLE KEYS */;
LOCK TABLES `site_controllers` WRITE;
INSERT INTO `site_controllers` VALUES (1,'content_pages',1,1);
INSERT INTO `site_controllers` VALUES (2,'controller_actions',1,1);
INSERT INTO `site_controllers` VALUES (3,'auth',1,1);
INSERT INTO `site_controllers` VALUES (4,'markup_styles',1,1);
INSERT INTO `site_controllers` VALUES (5,'menu_items',1,1);
INSERT INTO `site_controllers` VALUES (6,'permissions',1,1);
INSERT INTO `site_controllers` VALUES (7,'roles',1,1);
INSERT INTO `site_controllers` VALUES (8,'site_controllers',1,1);
INSERT INTO `site_controllers` VALUES (9,'system_settings',1,1);
INSERT INTO `site_controllers` VALUES (10,'users',1,1);
INSERT INTO `site_controllers` VALUES (11,'roles_permissions',1,1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `site_controllers` ENABLE KEYS */;
DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL auto_increment,
  `site_name` varchar(255) NOT NULL,
  `site_subtitle` varchar(255) default NULL,
  `footer_message` varchar(255) default '',
  `public_role_id` int(11) NOT NULL default '0',
  `session_timeout` int(11) NOT NULL default '0',
  `default_markup_style_id` int(11) default '0',
  `site_default_page_id` int(11) NOT NULL default '0',
  `not_found_page_id` int(11) NOT NULL default '0',
  `permission_denied_page_id` int(11) NOT NULL default '0',
  `session_expired_page_id` int(11) NOT NULL default '0',
  `menu_depth` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_system_settings_public_role_id` (`public_role_id`),
  KEY `fk_system_settings_site_default_page_id` (`site_default_page_id`),
  KEY `fk_system_settings_not_found_page_id` (`not_found_page_id`),
  KEY `fk_system_settings_permission_denied_page_id` (`permission_denied_page_id`),
  KEY `fk_system_settings_session_expired_page_id` (`session_expired_page_id`),
  CONSTRAINT `fk_system_settings_not_found_page_id` FOREIGN KEY (`not_found_page_id`) REFERENCES `content_pages` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_system_settings_permission_denied_page_id` FOREIGN KEY (`permission_denied_page_id`) REFERENCES `content_pages` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_system_settings_public_role_id` FOREIGN KEY (`public_role_id`) REFERENCES `roles` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_system_settings_session_expired_page_id` FOREIGN KEY (`session_expired_page_id`) REFERENCES `content_pages` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_system_settings_site_default_page_id` FOREIGN KEY (`site_default_page_id`) REFERENCES `content_pages` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
LOCK TABLES `system_settings` WRITE;
INSERT INTO `system_settings` VALUES (1,'Goldberg','A website development tool for Ruby on Rails','A <a href=\"http://goldberg.rubyforge.org\">Goldberg</a> site',1,7200,1,1,3,4,2,3);
UNLOCK TABLES;
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `password` varchar(40) NOT NULL,
  `role_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_user_role_id` (`role_id`),
  CONSTRAINT `fk_user_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/*!40000 ALTER TABLE `users` DISABLE KEYS */;
LOCK TABLES `users` WRITE;
INSERT INTO `users` VALUES (2,'admin','d033e22ae348aeb5660fc2140aec35850c4da997',3);
UNLOCK TABLES;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
DROP TABLE IF EXISTS `view_controller_actions`;
/*!50001 DROP VIEW IF EXISTS `view_controller_actions`*/;
/*!50001 DROP TABLE IF EXISTS `view_controller_actions`*/;
/*!50001 CREATE TABLE `view_controller_actions` (
  `id` int(11),
  `site_controller_id` int(11),
  `site_controller_name` varchar(255),
  `name` varchar(255),
  `permission_id` bigint(11)
) */;
DROP TABLE IF EXISTS `view_menu_items`;
/*!50001 DROP VIEW IF EXISTS `view_menu_items`*/;
/*!50001 DROP TABLE IF EXISTS `view_menu_items`*/;
/*!50001 CREATE TABLE `view_menu_items` (
  `menu_item_id` bigint(11) unsigned,
  `menu_item_name` varchar(255),
  `menu_item_label` varchar(255),
  `menu_item_seq` int(11),
  `menu_item_parent_id` int(11),
  `site_controller_id` int(11),
  `site_controller_name` varchar(255),
  `controller_action_id` int(11),
  `controller_action_name` varchar(255),
  `content_page_id` int(11),
  `content_page_name` varchar(255),
  `content_page_title` varchar(255),
  `permission_id` int(11),
  `permission_name` varchar(255)
) */;
/*!50001 DROP TABLE IF EXISTS `view_controller_actions`*/;
/*!50001 DROP VIEW IF EXISTS `view_controller_actions`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `view_controller_actions` AS select `controller_actions`.`id` AS `id`,`site_controllers`.`id` AS `site_controller_id`,`site_controllers`.`name` AS `site_controller_name`,`controller_actions`.`name` AS `name`,coalesce(`controller_actions`.`permission_id`,`site_controllers`.`permission_id`) AS `permission_id` from (`site_controllers` join `controller_actions` on((`site_controllers`.`id` = `controller_actions`.`site_controller_id`))) */;
/*!50001 DROP TABLE IF EXISTS `view_menu_items`*/;
/*!50001 DROP VIEW IF EXISTS `view_menu_items`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `view_menu_items` AS select cast(`menu_items`.`id` as unsigned) AS `menu_item_id`,`menu_items`.`name` AS `menu_item_name`,`menu_items`.`label` AS `menu_item_label`,`menu_items`.`seq` AS `menu_item_seq`,`menu_items`.`parent_id` AS `menu_item_parent_id`,`view_controller_actions`.`site_controller_id` AS `site_controller_id`,`view_controller_actions`.`site_controller_name` AS `site_controller_name`,`view_controller_actions`.`id` AS `controller_action_id`,`view_controller_actions`.`name` AS `controller_action_name`,`content_pages`.`id` AS `content_page_id`,`content_pages`.`name` AS `content_page_name`,`content_pages`.`title` AS `content_page_title`,`permissions`.`id` AS `permission_id`,`permissions`.`name` AS `permission_name` from ((((`menu_items` left join `view_controller_actions` on((`menu_items`.`controller_action_id` = `view_controller_actions`.`id`))) left join `content_pages` on(((`menu_items`.`content_page_id` = `content_pages`.`id`) and isnull(`menu_items`.`controller_action_id`)))) left join `markup_styles` on((`content_pages`.`markup_style_id` = `markup_styles`.`id`))) join `permissions` on((coalesce(`view_controller_actions`.`permission_id`,`content_pages`.`permission_id`) = `permissions`.`id`))) */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

