-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.0.27-community


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema pg_development
--

CREATE DATABASE IF NOT EXISTS pg_development;
USE pg_development;

--
-- Definition of table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
CREATE TABLE `assignments` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `directory_path` varchar(255) default NULL,
  `submitter_count` int(10) unsigned NOT NULL default '0',
  `course_id` int(11) NOT NULL default '0',
  `instructor_id` int(11) NOT NULL default '0',
  `private` tinyint(1) NOT NULL default '0',
  `num_reviewers` int(11) NOT NULL default '0',
  `num_review_of_reviewers` int(11) NOT NULL default '0',
  `review_strategy_id` int(11) NOT NULL default '0',
  `mapping_strategy_id` int(11) NOT NULL default '0',
  `review_rubric_id` int(11) default NULL,
  `review_of_review_rubric_id` int(11) default NULL,
  `review_weight` float default NULL,
  `reviews_visible_to_all` tinyint(1) default NULL,
  `team_assignment` tinyint(1) default NULL,
  `wiki_assignment` tinyint(1) default NULL,
  `require_signup` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_assignments_review_rubrics` (`review_rubric_id`),
  KEY `fk_assignments_review_of_review_rubrics` (`review_of_review_rubric_id`),
  CONSTRAINT `fk_assignments_review_of_review_rubrics` FOREIGN KEY (`review_of_review_rubric_id`) REFERENCES `rubrics` (`id`),
  CONSTRAINT `fk_assignments_review_rubrics` FOREIGN KEY (`review_rubric_id`) REFERENCES `rubrics` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `assignments`
--

/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
INSERT INTO `assignments` (`id`,`name`,`directory_path`,`submitter_count`,`course_id`,`instructor_id`,`private`,`num_reviewers`,`num_review_of_reviewers`,`review_strategy_id`,`mapping_strategy_id`,`review_rubric_id`,`review_of_review_rubric_id`,`review_weight`,`reviews_visible_to_all`,`team_assignment`,`wiki_assignment`,`require_signup`) VALUES 
 (1,'TestAssign1','admin/test1/',0,4,2,0,0,0,0,0,1,NULL,NULL,1,1,1,1),
 (2,'TestAssign2','admin/test2/',0,0,2,0,17,9,1,1,2,NULL,NULL,NULL,NULL,NULL,NULL),
 (21,'TestingDuedates','admin/dueDateTest',0,0,2,0,0,0,0,0,1,1,4,1,1,1,0),
 (22,'Validation Test','admin/validation',0,0,2,0,0,0,0,0,1,1,NULL,1,1,1,1),
 (55,'NewTestJunegb','admin/validation2',0,0,2,0,0,0,0,0,1,1,NULL,0,0,0,0),
 (56,'NewTestJunegb','admin/validation2',0,0,2,0,0,0,0,0,1,1,NULL,0,0,0,0),
 (57,'dueDateTest','admin/juneTest',0,0,2,0,0,0,0,0,1,1,NULL,0,0,0,0),
 (58,'deadlines','admin/validation2',0,0,2,0,0,0,0,0,1,1,4,0,0,0,0),
 (59,'deadlines','admin/validation2',0,0,2,0,0,0,0,0,1,1,4,0,0,0,0);
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;


--
-- Definition of table `content_pages`
--

DROP TABLE IF EXISTS `content_pages`;
CREATE TABLE `content_pages` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `name` varchar(255) NOT NULL default '',
  `markup_style_id` int(11) default NULL,
  `content` text,
  `permission_id` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `content_cache` text,
  PRIMARY KEY  (`id`),
  KEY `fk_content_page_permission_id` (`permission_id`),
  KEY `fk_content_page_markup_style_id` (`markup_style_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `content_pages`
--

/*!40000 ALTER TABLE `content_pages` DISABLE KEYS */;
INSERT INTO `content_pages` (`id`,`title`,`name`,`markup_style_id`,`content`,`permission_id`,`created_at`,`updated_at`,`content_cache`) VALUES 
 (1,'Home Page','home',1,'<h1>Welcome to Expertiza</h1> <p> The Expertiza project is system for using peer review to create reusable learning objects.  Students do different assignments; then peer review selects the best work in each category, and assembles it to create a single unit.</p>',3,'2006-06-12 00:31:56','2007-02-23 10:17:45','<h1>Welcome to Expertiza</h1> <p> The Expertiza project is system for using peer review to create reusable learning objects.  Students do different assignments; then peer review selects the best work in each category, and assembles it to create a single unit.</p>'),
 (2,'Session Expired','expired',1,'h1. Session Expired\n\nYour session has expired due to inactivity.\n\nTo continue please login again.\n',3,'2006-06-12 00:33:14','2007-02-23 10:17:45','<h1>Session Expired</h1>\n\n\n	<p>Your session has expired due to inactivity.</p>\n\n\n	<p>To continue please login again.</p>'),
 (3,'Not Found!','notfound',1,'h1. Not Found\n\nThe page you requested was not found!\n\nPlease contact your system administrator.',3,'2006-06-12 00:33:49','2007-02-23 10:17:45','<h1>Not Found</h1>\n\n\n	<p>The page you requested was not found!</p>\n\n\n	<p>Please contact your system administrator.</p>');
INSERT INTO `content_pages` (`id`,`title`,`name`,`markup_style_id`,`content`,`permission_id`,`created_at`,`updated_at`,`content_cache`) VALUES 
 (4,'Permission Denied!','denied',1,'h1. Permission Denied\n\nSorry, but you don\'t have permission to view that page.\n\nPlease contact your system administrator.',3,'2006-06-12 00:34:30','2007-02-23 10:17:45','<h1>Permission Denied</h1>\n\n\n	<p>Sorry, but you don&#8217;t have permission to view that page.</p>\n\n\n	<p>Please contact your system administrator.</p>'),
 (6,'Contact Us','contact_us',1,'h1. Contact Us\n\nVisit the Goldberg Project Homepage at \"http://goldberg.rubyforge.org\":http://goldberg.rubyforge.org for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at \"http://rubyforge.org/projects/goldberg\":http://rubyforge.org/projects/goldberg to access the project\'s files and development information.\n',3,'2006-06-12 10:13:47','2007-02-23 10:17:46','<h1>Contact Us</h1>\n\n\n	<p>Visit the Goldberg Project Homepage at <a href=\"http://goldberg.rubyforge.org\">http://goldberg.rubyforge.org</a> for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at <a href=\"http://rubyforge.org/projects/goldberg\">http://rubyforge.org/projects/goldberg</a> to access the project&#8217;s files and development information.</p>'),
 (8,'Site Administration','site_admin',1,'h1. Goldberg Setup\n\nThis is where you will find all the Goldberg-specific administration and configuration features.  In here you can:\n\n* Set up Users.\n\n* Manage Roles and their Permissions.\n\n* Set up any Controllers and their Actions for your application.\n\n* Edit the Content Pages of the site.\n\n* Adjust Goldberg\'s system settings.\n\n\nh2. Users\n\nYou can set up Users with a username, password and a Role.\n\n\nh2. Roles and Permissions\n\nA User\'s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.\n\nA Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.\n\n\nh2. Controllers and Actions\n\nTo execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.\n\nYou start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.\n\nYou have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.\n\n\nh2. Content Pages\n\nGoldberg has a very simple CMS built in.  You can create pages to be displayed on the site, possibly in menu items.\n\n\nh2. Menu Editor\n\nOnce you have set up your Controller Actions and Content Pages, you can put them into the site\'s menu using the Menu Editor.\n\nIn the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.\n\nh2. System Settings\n\nGo here to view and edit the settings that determine how Goldberg operates.\n',1,'2006-06-21 21:32:35','2007-02-23 10:17:46','<h1>Goldberg Setup</h1>\n\n\n	<p>This is where you will find all the Goldberg-specific administration and configuration features.  In here you can:</p>\n\n\n	<ul>\n	<li>Set up Users.</li>\n	</ul>\n\n\n	<ul>\n	<li>Manage Roles and their Permissions.</li>\n	</ul>\n\n\n	<ul>\n	<li>Set up any Controllers and their Actions for your application.</li>\n	</ul>\n\n\n	<ul>\n	<li>Edit the Content Pages of the site.</li>\n	</ul>\n\n\n	<ul>\n	<li>Adjust Goldberg&#8217;s system settings.</li>\n	</ul>\n\n\n	<h2>Users</h2>\n\n\n	<p>You can set up Users with a username, password and a Role.</p>\n\n\n	<h2>Roles and Permissions</h2>\n\n\n	<p>A User&#8217;s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.</p>\n\n\n	<p>A Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.</p>\n\n\n	<h2>Controllers and Actions</h2>\n\n\n	<p>To execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.</p>\n\n\n	<p>You start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.</p>\n\n\n	<p>You have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.</p>\n\n\n	<h2>Content Pages</h2>\n\n\n	<p>Goldberg has a very simple <span class=\"caps\">CMS</span> built in.  You can create pages to be displayed on the site, possibly in menu items.</p>\n\n\n	<h2>Menu Editor</h2>\n\n\n	<p>Once you have set up your Controller Actions and Content Pages, you can put them into the site&#8217;s menu using the Menu Editor.</p>\n\n\n	<p>In the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.</p>\n\n\n	<h2>System Settings</h2>\n\n\n	<p>Go here to view and edit the settings that determine how Goldberg operates.</p>');
INSERT INTO `content_pages` (`id`,`title`,`name`,`markup_style_id`,`content`,`permission_id`,`created_at`,`updated_at`,`content_cache`) VALUES 
 (9,'Administration','admin',1,'h1. Site Administration\n\nThis is where the administrator can set up the site.\n\nThere is one menu item here by default -- \"Setup\":/menu/setup.  That contains all the Goldberg configuration options.\n\nYou can add more menu items here to administer your application if you want, by going to \"Setup, Menu Editor\":/menu/setup/menus.\n',1,'2006-06-26 16:47:09','2007-02-23 10:17:46','<h1>Site Administration</h1>\n\n\n	<p>This is where the administrator can set up the site.</p>\n\n\n	<p>There is one menu item here by default&#8212;<a href=\"/menu/setup\">Setup</a>.  That contains all the Goldberg configuration options.</p>\n\n\n	<p>You can add more menu items here to administer your application if you want, by going to <a href=\"/menu/setup/menus\">Setup, Menu Editor</a>.</p>'),
 (10,'Credits and Licence','credits',1,'h1. Credits and Licence\n\nGoldberg contains original material and third party material from various sources.\n\nAll original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.\n\nThe copyright for any third party material remains with the original author, and the material is distributed here under the original terms.  \n\nMaterial has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, BSD-style licences, and Creative Commons licences (but *not* Creative Commons Non-Commercial).\n\nIf you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).\n\n\nh2. Layouts\n\nGoldberg comes with a choice of layouts, adapted from various sources.\n\nh3. The Default\n\nThe default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2493/.\n\nAuthor\'s website: \"andreasviklund.com\":http://andreasviklund.com/.\n\n\nh3. \"Earth Wind and Fire\"\n\nOriginally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: \"Every template we create is completely open source, meaning you can take it and do whatever you want with it\").  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2453/.\n\nAuthor\'s website: \"www.madseason.co.uk\":http://www.madseason.co.uk/.\n\n\nh3. \"Snooker\"\n\n\"Snooker\" is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the \"A List Apart\":http://alistapart.com/articles/negativemargins website.\n\n\nh3. \"Spoiled Brat\"\n\nOriginally designed by \"Rayk Web Design\":http://www.raykdesign.net/ and distributed under the terms of the \"Creative Commons Attribution Share Alike\":http://creativecommons.org/licenses/by-sa/2.5/legalcode licence.  The original template can be obtained from \"Open Web Design\":http://www.openwebdesign.org/viewdesign.phtml?id=2894/.\n\nAuthor\'s website: \"www.csstinderbox.com\":http://www.csstinderbox.com/.\n\n\nh2. Other Features\n\nGoldberg also contains some miscellaneous code and techniques from other sources.\n\nh3. Suckerfish Menus\n\nThe three templates \"Earth Wind and Fire\", \"Snooker\" and \"Spoiled Brat\" have all been configured to use Suckerfish menus.  This technique of using a combination of CSS and Javascript to implement dynamic menus was first described by \"A List Apart\":http://www.alistapart.com/articles/dropdowns/.  Goldberg\'s implementation also incorporates techniques described by \"HTMLDog\":http://www.htmldog.com/articles/suckerfish/dropdowns/.\n\nh3. Tabbed Panels\n\nGoldberg\'s implementation of tabbed panels was adapted from \n\"InternetConnection\":http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml.\n',3,'2006-10-02 10:35:35','2007-02-23 10:17:46','<h1>Credits and Licence</h1>\n\n\n	<p>Goldberg contains original material and third party material from various sources.</p>\n\n\n	<p>All original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.</p>\n\n\n	<p>The copyright for any third party material remains with the original author, and the material is distributed here under the original terms.</p>\n\n\n	<p>Material has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, <span class=\"caps\">BSD</span>-style licences, and Creative Commons licences (but <strong>not</strong> Creative Commons Non-Commercial).</p>\n\n\n	<p>If you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).</p>\n\n\n	<h2>Layouts</h2>\n\n\n	<p>Goldberg comes with a choice of layouts, adapted from various sources.</p>\n\n\n	<h3>The Default</h3>\n\n\n	<p>The default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from <a href=\"http://www.oswd.org/design/preview/id/2493/\">Open Source Web Design</a>.</p>\n\n\n	<p>Author&#8217;s website: <a href=\"http://andreasviklund.com/\">andreasviklund.com</a>.</p>\n\n\n	<h3>&#8220;Earth Wind and Fire&#8221;</h3>\n\n\n	<p>Originally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: &#8220;Every template we create is completely open source, meaning you can take it and do whatever you want with it&#8221;).  The original template can be obtained from <a href=\"http://www.oswd.org/design/preview/id/2453/\">Open Source Web Design</a>.</p>\n\n\n	<p>Author&#8217;s website: <a href=\"http://www.madseason.co.uk/\">www.madseason.co.uk</a>.</p>\n\n\n	<h3>&#8220;Snooker&#8221;</h3>\n\n\n	<p>&#8220;Snooker&#8221; is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the <a href=\"http://alistapart.com/articles/negativemargins\">A List Apart</a> website.</p>\n\n\n	<h3>&#8220;Spoiled Brat&#8221;</h3>\n\n\n	<p>Originally designed by <a href=\"http://www.raykdesign.net/\">Rayk Web Design</a> and distributed under the terms of the <a href=\"http://creativecommons.org/licenses/by-sa/2.5/legalcode\">Creative Commons Attribution Share Alike</a> licence.  The original template can be obtained from <a href=\"http://www.openwebdesign.org/viewdesign.phtml?id=2894/\">Open Web Design</a>.</p>\n\n\n	<p>Author&#8217;s website: <a href=\"http://www.csstinderbox.com/\">www.csstinderbox.com</a>.</p>\n\n\n	<h2>Other Features</h2>\n\n\n	<p>Goldberg also contains some miscellaneous code and techniques from other sources.</p>\n\n\n	<h3>Suckerfish Menus</h3>\n\n\n	<p>The three templates &#8220;Earth Wind and Fire&#8221;, &#8220;Snooker&#8221; and &#8220;Spoiled Brat&#8221; have all been configured to use Suckerfish menus.  This technique of using a combination of <span class=\"caps\">CSS</span> and Javascript to implement dynamic menus was first described by <a href=\"http://www.alistapart.com/articles/dropdowns/\">A List Apart</a>.  Goldberg&#8217;s implementation also incorporates techniques described by <a href=\"http://www.htmldog.com/articles/suckerfish/dropdowns/\">HTMLDog</a>.</p>\n\n\n	<h3>Tabbed Panels</h3>\n\n\n	<p>Goldberg&#8217;s implementation of tabbed panels was adapted from \n<a href=\"http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml\">InternetConnection</a>.</p>');
/*!40000 ALTER TABLE `content_pages` ENABLE KEYS */;


--
-- Definition of table `controller_actions`
--

DROP TABLE IF EXISTS `controller_actions`;
CREATE TABLE `controller_actions` (
  `id` int(11) NOT NULL auto_increment,
  `site_controller_id` int(11) NOT NULL default '0',
  `name` varchar(255) NOT NULL default '',
  `permission_id` int(11) default NULL,
  `url_to_use` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_controller_action_permission_id` (`permission_id`),
  KEY `fk_controller_action_site_controller_id` (`site_controller_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `controller_actions`
--

/*!40000 ALTER TABLE `controller_actions` DISABLE KEYS */;
INSERT INTO `controller_actions` (`id`,`site_controller_id`,`name`,`permission_id`,`url_to_use`) VALUES 
 (1,1,'view_default',3,NULL),
 (2,1,'view',3,NULL),
 (3,7,'list',NULL,NULL),
 (4,6,'list',NULL,NULL),
 (5,3,'login',4,NULL),
 (6,3,'logout',4,NULL),
 (7,5,'link',4,NULL),
 (8,1,'list',NULL,NULL),
 (9,8,'list',NULL,NULL),
 (10,2,'list',NULL,NULL),
 (11,5,'list',NULL,NULL),
 (12,9,'list',NULL,NULL),
 (13,3,'forgotten',4,NULL),
 (14,3,'login_failed',4,NULL),
 (15,10,'list',NULL,NULL),
 (16,12,'list_instructors',9,''),
 (17,12,'list_administrators',6,''),
 (18,12,'list_super_administrators',1,''),
 (19,13,'list_folders',7,''),
 (20,14,'create',7,''),
 (21,15,'list',7,''),
 (22,15,'create_rubric',7,''),
 (23,15,'edit_rubric',7,''),
 (24,15,'copy_rubric',7,''),
 (25,15,'save_rubric',7,''),
 (26,20,'add_student',7,''),
 (28,20,'edit_team_members',7,''),
 (29,14,'new',7,''),
 (30,14,'list',4,''),
 (31,20,'list_students',7,''),
 (32,22,'list',6,''),
 (33,23,'list',8,''),
 (34,20,'list_courses',7,''),
 (35,20,'list_assignments',7,'');
INSERT INTO `controller_actions` (`id`,`site_controller_id`,`name`,`permission_id`,`url_to_use`) VALUES 
 (36,24,'list',4,''),
 (37,24,'show',4,'');
/*!40000 ALTER TABLE `controller_actions` ENABLE KEYS */;


--
-- Definition of table `courses`
--

DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `instructor_id` int(11) default NULL,
  `directory_path` varchar(255) default NULL,
  `info` text,
  PRIMARY KEY  (`id`),
  KEY `fk_course_users` (`instructor_id`),
  CONSTRAINT `fk_course_users` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `courses`
--

/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` (`id`,`title`,`instructor_id`,`directory_path`,`info`) VALUES 
 (1,'Course1',NULL,'abc/','Info'),
 (2,'Test Course',NULL,'abc/','Information'),
 (3,'CourseTest1',2,'abc/',''),
 (4,'CSC 499, Independent study in computer science',2,'admin/csc499','Neil Bergman is taking this course.');
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;


--
-- Definition of table `courses_users`
--

DROP TABLE IF EXISTS `courses_users`;
CREATE TABLE `courses_users` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `course_id` int(11) default NULL,
  `active` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_courses_users` (`user_id`),
  KEY `fk_users_courses` (`course_id`),
  CONSTRAINT `fk_courses_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_users_courses` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `courses_users`
--

/*!40000 ALTER TABLE `courses_users` DISABLE KEYS */;
INSERT INTO `courses_users` (`id`,`user_id`,`course_id`,`active`) VALUES 
 (5,5,4,NULL);
/*!40000 ALTER TABLE `courses_users` ENABLE KEYS */;


--
-- Definition of table `deadline_rights`
--

DROP TABLE IF EXISTS `deadline_rights`;
CREATE TABLE `deadline_rights` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(32) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `deadline_rights`
--

/*!40000 ALTER TABLE `deadline_rights` DISABLE KEYS */;
INSERT INTO `deadline_rights` (`id`,`name`) VALUES 
 (1,'No'),
 (2,'Late'),
 (3,'OK');
/*!40000 ALTER TABLE `deadline_rights` ENABLE KEYS */;


--
-- Definition of table `deadline_types`
--

DROP TABLE IF EXISTS `deadline_types`;
CREATE TABLE `deadline_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(32) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `deadline_types`
--

/*!40000 ALTER TABLE `deadline_types` DISABLE KEYS */;
INSERT INTO `deadline_types` (`id`,`name`) VALUES 
 (1,'submission'),
 (2,'review'),
 (3,'resubmission'),
 (4,'rereview'),
 (5,'review of review');
/*!40000 ALTER TABLE `deadline_types` ENABLE KEYS */;


--
-- Definition of table `due_dates`
--

DROP TABLE IF EXISTS `due_dates`;
CREATE TABLE `due_dates` (
  `id` int(11) NOT NULL auto_increment,
  `due_at` datetime default NULL,
  `deadline_type_id` int(11) default NULL,
  `assignment_id` int(11) default NULL,
  `late_policy_id` int(11) default NULL,
  `submission_allowed_id` int(11) default NULL,
  `review_allowed_id` int(11) default NULL,
  `resubmission_allowed_id` int(11) default NULL,
  `rereview_allowed_id` int(11) default NULL,
  `review_of_review_allowed_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_deadline_type_due_date` (`deadline_type_id`),
  KEY `fk_due_dates_assignments` (`assignment_id`),
  KEY `fk_due_date_late_policies` (`late_policy_id`),
  KEY `fk_due_date_submission_allowed` (`submission_allowed_id`),
  KEY `fk_due_date_review_allowed` (`review_allowed_id`),
  KEY `fk_due_date_resubmission_allowed` (`resubmission_allowed_id`),
  KEY `fk_due_date_rereview_allowed` (`rereview_allowed_id`),
  KEY `fk_due_date_review_of_review_allowed` (`review_of_review_allowed_id`),
  CONSTRAINT `fk_deadline_type_due_date` FOREIGN KEY (`deadline_type_id`) REFERENCES `deadline_types` (`id`),
  CONSTRAINT `fk_due_dates_assignments` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  CONSTRAINT `fk_due_date_late_policies` FOREIGN KEY (`late_policy_id`) REFERENCES `late_policies` (`id`),
  CONSTRAINT `fk_due_date_rereview_allowed` FOREIGN KEY (`rereview_allowed_id`) REFERENCES `deadline_rights` (`id`),
  CONSTRAINT `fk_due_date_resubmission_allowed` FOREIGN KEY (`resubmission_allowed_id`) REFERENCES `deadline_rights` (`id`),
  CONSTRAINT `fk_due_date_review_allowed` FOREIGN KEY (`review_allowed_id`) REFERENCES `deadline_rights` (`id`),
  CONSTRAINT `fk_due_date_review_of_review_allowed` FOREIGN KEY (`review_of_review_allowed_id`) REFERENCES `deadline_rights` (`id`),
  CONSTRAINT `fk_due_date_submission_allowed` FOREIGN KEY (`submission_allowed_id`) REFERENCES `deadline_rights` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `due_dates`
--

/*!40000 ALTER TABLE `due_dates` DISABLE KEYS */;
INSERT INTO `due_dates` (`id`,`due_at`,`deadline_type_id`,`assignment_id`,`late_policy_id`,`submission_allowed_id`,`review_allowed_id`,`resubmission_allowed_id`,`rereview_allowed_id`,`review_of_review_allowed_id`) VALUES 
 (1,'2007-04-23 00:00:00',1,1,NULL,NULL,NULL,NULL,NULL,NULL),
 (2,'2007-04-24 00:00:00',2,1,NULL,NULL,NULL,NULL,NULL,NULL),
 (3,'2007-04-25 00:00:00',3,1,NULL,NULL,NULL,NULL,NULL,NULL),
 (4,'2007-04-26 00:00:00',4,1,NULL,NULL,NULL,NULL,NULL,NULL),
 (5,'2007-04-27 00:00:00',5,1,NULL,NULL,NULL,NULL,NULL,NULL),
 (36,'2007-06-14 16:15:16',1,21,1,3,1,1,1,1),
 (37,'2007-06-20 16:15:16',2,21,1,2,3,1,1,1),
 (38,'2007-06-22 16:15:16',3,21,1,2,2,3,1,1),
 (39,'2007-06-23 16:15:16',4,21,1,2,2,2,3,1),
 (40,'2007-06-30 16:15:16',5,21,1,2,2,2,2,3),
 (41,'2007-06-16 17:32:27',1,22,1,3,1,1,1,1),
 (42,'2007-06-20 17:32:27',2,22,1,2,3,1,1,1),
 (43,'2007-06-07 17:32:27',3,22,1,2,2,3,1,1),
 (44,'2007-06-06 17:32:27',4,22,1,2,2,2,3,1),
 (45,'2007-06-28 17:32:27',5,22,1,2,2,2,2,3),
 (212,'2007-06-14 16:15:16',1,55,1,3,1,1,1,1),
 (213,NULL,2,55,1,2,3,1,1,1);
INSERT INTO `due_dates` (`id`,`due_at`,`deadline_type_id`,`assignment_id`,`late_policy_id`,`submission_allowed_id`,`review_allowed_id`,`resubmission_allowed_id`,`rereview_allowed_id`,`review_of_review_allowed_id`) VALUES 
 (214,'2007-06-10 20:29:30',3,55,1,2,2,3,1,1),
 (215,'2007-06-16 17:47:31',4,55,1,2,2,2,3,1),
 (216,'2007-06-18 17:33:46',5,55,1,2,2,2,2,3),
 (217,'2007-06-14 16:15:16',1,56,1,3,1,1,1,1),
 (218,NULL,2,56,1,2,3,1,1,1),
 (219,'2007-06-16 17:47:31',3,56,1,2,2,3,1,1),
 (220,'2007-06-17 17:32:27',4,56,1,2,2,2,3,1),
 (221,'2007-06-18 17:33:46',5,56,1,2,2,2,2,3),
 (222,'2007-06-06 13:58:57',1,57,1,3,1,1,1,1),
 (223,'2007-06-13 13:58:57',2,57,1,2,3,1,1,1),
 (224,'2007-06-14 20:29:30',3,57,1,2,2,3,1,1),
 (225,'2007-06-15 20:29:30',4,57,1,2,2,2,3,1),
 (226,'2007-06-16 18:12:04',5,57,1,2,2,2,2,3),
 (227,'2007-06-06 13:58:57',1,58,1,3,1,1,1,1),
 (228,'2007-06-13 13:58:57',2,58,1,2,3,1,1,1),
 (229,'2007-06-10 20:29:30',3,58,1,2,2,3,1,1),
 (230,'2007-06-06 17:32:27',4,58,1,2,2,2,3,1),
 (231,'2007-06-14 18:12:04',5,58,1,2,2,2,2,3);
INSERT INTO `due_dates` (`id`,`due_at`,`deadline_type_id`,`assignment_id`,`late_policy_id`,`submission_allowed_id`,`review_allowed_id`,`resubmission_allowed_id`,`rereview_allowed_id`,`review_of_review_allowed_id`) VALUES 
 (232,'2007-06-06 13:58:57',1,59,1,3,1,1,1,1),
 (233,'2007-06-13 13:58:57',2,59,1,2,3,1,1,2),
 (234,'2007-06-14 17:32:27',3,59,1,2,2,3,1,2),
 (235,'2007-06-15 20:29:30',4,59,1,2,2,2,3,2),
 (236,'2007-06-16 18:12:04',5,59,1,2,2,2,2,3);
/*!40000 ALTER TABLE `due_dates` ENABLE KEYS */;


--
-- Definition of table `goldberg_content_pages`
--

DROP TABLE IF EXISTS `goldberg_content_pages`;
CREATE TABLE `goldberg_content_pages` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `name` varchar(255) NOT NULL default '',
  `markup_style_id` int(11) default NULL,
  `content` text,
  `permission_id` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `content_cache` text,
  `markup_style` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_content_page_permission_id` (`permission_id`),
  KEY `fk_content_page_markup_style_id` (`markup_style_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_content_pages`
--

/*!40000 ALTER TABLE `goldberg_content_pages` DISABLE KEYS */;
INSERT INTO `goldberg_content_pages` (`id`,`title`,`name`,`markup_style_id`,`content`,`permission_id`,`created_at`,`updated_at`,`content_cache`,`markup_style`) VALUES 
 (1,'Home Page','home',1,'h1. Welcome to Goldberg!\n\nLooks like you have succeeded in getting Goldberg up and running.  Now you will probably want to customise your site.\n\n*Very important:* The default login for the administrator is \"admin\", password \"admin\".  You must change that before you make your site public!\n\nh2. Administering the Site\n\nAt the login prompt, enter an administrator username and password.  The top menu should change: a new item called \"Administration\" will appear.  Go there for further details.\n',3,'2006-06-12 00:31:56','2007-05-21 14:01:58','<h1>Welcome to Goldberg!</h1>\n\n\n	<p>Looks like you have succeeded in getting Goldberg up and running.  Now you will probably want to customise your site.</p>\n\n\n	<p><strong>Very important:</strong> The default login for the administrator is &#8220;admin&#8221;, password &#8220;admin&#8221;.  You must change that before you make your site public!</p>\n\n\n	<h2>Administering the Site</h2>\n\n\n	<p>At the login prompt, enter an administrator username and password.  The top menu should change: a new item called &#8220;Administration&#8221; will appear.  Go there for further details.</p>','Textile'),
 (2,'Session Expired','expired',1,'h1. Session Expired\n\nYour session has expired due to inactivity.\n\nTo continue please login again.\n',3,'2006-06-12 00:33:14','2007-05-21 14:01:58','<h1>Session Expired</h1>\n\n\n	<p>Your session has expired due to inactivity.</p>\n\n\n	<p>To continue please login again.</p>','Textile');
INSERT INTO `goldberg_content_pages` (`id`,`title`,`name`,`markup_style_id`,`content`,`permission_id`,`created_at`,`updated_at`,`content_cache`,`markup_style`) VALUES 
 (3,'Not Found!','notfound',1,'h1. Not Found\n\nThe page you requested was not found!\n\nPlease contact your system administrator.',3,'2006-06-12 00:33:49','2007-05-21 14:01:59','<h1>Not Found</h1>\n\n\n	<p>The page you requested was not found!</p>\n\n\n	<p>Please contact your system administrator.</p>','Textile'),
 (4,'Permission Denied!','denied',1,'h1. Permission Denied\n\nSorry, but you don\'t have permission to view that page.\n\nPlease contact your system administrator.',3,'2006-06-12 00:34:30','2007-05-21 14:01:59','<h1>Permission Denied</h1>\n\n\n	<p>Sorry, but you don&#8217;t have permission to view that page.</p>\n\n\n	<p>Please contact your system administrator.</p>','Textile'),
 (6,'Contact Us','contact_us',1,'h1. Contact Us\n\nVisit the Goldberg Project Homepage at \"http://goldberg.rubyforge.org\":http://goldberg.rubyforge.org for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at \"http://rubyforge.org/projects/goldberg\":http://rubyforge.org/projects/goldberg to access the project\'s files and development information.\n',3,'2006-06-12 10:13:47','2007-05-21 14:01:59','<h1>Contact Us</h1>\n\n\n	<p>Visit the Goldberg Project Homepage at <a href=\"http://goldberg.rubyforge.org\">http://goldberg.rubyforge.org</a> for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at <a href=\"http://rubyforge.org/projects/goldberg\">http://rubyforge.org/projects/goldberg</a> to access the project&#8217;s files and development information.</p>','Textile'),
 (8,'Site Administration','site_admin',1,'h1. Goldberg Setup\n\nThis is where you will find all the Goldberg-specific administration and configuration features.  In here you can:\n\n* Set up Users.\n\n* Manage Roles and their Permissions.\n\n* Set up any Controllers and their Actions for your application.\n\n* Edit the Content Pages of the site.\n\n* Adjust Goldberg\'s system settings.\n\n\nh2. Users\n\nYou can set up Users with a username, password and a Role.\n\n\nh2. Roles and Permissions\n\nA User\'s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.\n\nA Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.\n\n\nh2. Controllers and Actions\n\nTo execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.\n\nYou start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.\n\nYou have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.\n\n\nh2. Content Pages\n\nGoldberg has a very simple CMS built in.  You can create pages to be displayed on the site, possibly in menu items.\n\n\nh2. Menu Editor\n\nOnce you have set up your Controller Actions and Content Pages, you can put them into the site\'s menu using the Menu Editor.\n\nIn the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.\n\nh2. System Settings\n\nGo here to view and edit the settings that determine how Goldberg operates.\n',1,'2006-06-21 21:32:35','2007-05-21 14:01:59','<h1>Goldberg Setup</h1>\n\n\n	<p>This is where you will find all the Goldberg-specific administration and configuration features.  In here you can:</p>\n\n\n	<ul>\n	<li>Set up Users.</li>\n	</ul>\n\n\n	<ul>\n	<li>Manage Roles and their Permissions.</li>\n	</ul>\n\n\n	<ul>\n	<li>Set up any Controllers and their Actions for your application.</li>\n	</ul>\n\n\n	<ul>\n	<li>Edit the Content Pages of the site.</li>\n	</ul>\n\n\n	<ul>\n	<li>Adjust Goldberg&#8217;s system settings.</li>\n	</ul>\n\n\n	<h2>Users</h2>\n\n\n	<p>You can set up Users with a username, password and a Role.</p>\n\n\n	<h2>Roles and Permissions</h2>\n\n\n	<p>A User&#8217;s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.</p>\n\n\n	<p>A Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.</p>\n\n\n	<h2>Controllers and Actions</h2>\n\n\n	<p>To execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.</p>\n\n\n	<p>You start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.</p>\n\n\n	<p>You have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.</p>\n\n\n	<h2>Content Pages</h2>\n\n\n	<p>Goldberg has a very simple <span class=\"caps\">CMS</span> built in.  You can create pages to be displayed on the site, possibly in menu items.</p>\n\n\n	<h2>Menu Editor</h2>\n\n\n	<p>Once you have set up your Controller Actions and Content Pages, you can put them into the site&#8217;s menu using the Menu Editor.</p>\n\n\n	<p>In the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.</p>\n\n\n	<h2>System Settings</h2>\n\n\n	<p>Go here to view and edit the settings that determine how Goldberg operates.</p>','Textile');
INSERT INTO `goldberg_content_pages` (`id`,`title`,`name`,`markup_style_id`,`content`,`permission_id`,`created_at`,`updated_at`,`content_cache`,`markup_style`) VALUES 
 (9,'Administration','admin',1,'h1. Site Administration\n\nThis is where the administrator can set up the site.\n\nThere is one menu item here by default -- \"Setup\":/menu/setup.  That contains all the Goldberg configuration options.\n\nYou can add more menu items here to administer your application if you want, by going to \"Setup, Menu Editor\":/menu/setup/menus.\n',1,'2006-06-26 16:47:09','2007-05-21 14:01:59','<h1>Site Administration</h1>\n\n\n	<p>This is where the administrator can set up the site.</p>\n\n\n	<p>There is one menu item here by default&#8212;<a href=\"/menu/setup\">Setup</a>.  That contains all the Goldberg configuration options.</p>\n\n\n	<p>You can add more menu items here to administer your application if you want, by going to <a href=\"/menu/setup/menus\">Setup, Menu Editor</a>.</p>','Textile'),
 (10,'Credits and Licence','credits',1,'h1. Credits and Licence\n\nGoldberg contains original material and third party material from various sources.\n\nAll original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.\n\nThe copyright for any third party material remains with the original author, and the material is distributed here under the original terms.  \n\nMaterial has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, BSD-style licences, and Creative Commons licences (but *not* Creative Commons Non-Commercial).\n\nIf you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).\n\n\nh2. Layouts\n\nGoldberg comes with a choice of layouts, adapted from various sources.\n\nh3. The Default\n\nThe default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2493/.\n\nAuthor\'s website: \"andreasviklund.com\":http://andreasviklund.com/.\n\n\nh3. \"Earth Wind and Fire\"\n\nOriginally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: \"Every template we create is completely open source, meaning you can take it and do whatever you want with it\").  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2453/.\n\nAuthor\'s website: \"www.madseason.co.uk\":http://www.madseason.co.uk/.\n\n\nh3. \"Snooker\"\n\n\"Snooker\" is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the \"A List Apart\":http://alistapart.com/articles/negativemargins website.\n\n\nh3. \"Spoiled Brat\"\n\nOriginally designed by \"Rayk Web Design\":http://www.raykdesign.net/ and distributed under the terms of the \"Creative Commons Attribution Share Alike\":http://creativecommons.org/licenses/by-sa/2.5/legalcode licence.  The original template can be obtained from \"Open Web Design\":http://www.openwebdesign.org/viewdesign.phtml?id=2894/.\n\nAuthor\'s website: \"www.csstinderbox.com\":http://www.csstinderbox.com/.\n\n\nh2. Other Features\n\nGoldberg also contains some miscellaneous code and techniques from other sources.\n\nh3. Suckerfish Menus\n\nThe three templates \"Earth Wind and Fire\", \"Snooker\" and \"Spoiled Brat\" have all been configured to use Suckerfish menus.  This technique of using a combination of CSS and Javascript to implement dynamic menus was first described by \"A List Apart\":http://www.alistapart.com/articles/dropdowns/.  Goldberg\'s implementation also incorporates techniques described by \"HTMLDog\":http://www.htmldog.com/articles/suckerfish/dropdowns/.\n\nh3. Tabbed Panels\n\nGoldberg\'s implementation of tabbed panels was adapted from \n\"InternetConnection\":http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml.\n',3,'2006-10-02 10:35:35','2007-05-21 14:01:59','<h1>Credits and Licence</h1>\n\n\n	<p>Goldberg contains original material and third party material from various sources.</p>\n\n\n	<p>All original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.</p>\n\n\n	<p>The copyright for any third party material remains with the original author, and the material is distributed here under the original terms.</p>\n\n\n	<p>Material has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, <span class=\"caps\">BSD</span>-style licences, and Creative Commons licences (but <strong>not</strong> Creative Commons Non-Commercial).</p>\n\n\n	<p>If you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).</p>\n\n\n	<h2>Layouts</h2>\n\n\n	<p>Goldberg comes with a choice of layouts, adapted from various sources.</p>\n\n\n	<h3>The Default</h3>\n\n\n	<p>The default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from <a href=\"http://www.oswd.org/design/preview/id/2493/\">Open Source Web Design</a>.</p>\n\n\n	<p>Author&#8217;s website: <a href=\"http://andreasviklund.com/\">andreasviklund.com</a>.</p>\n\n\n	<h3>&#8220;Earth Wind and Fire&#8221;</h3>\n\n\n	<p>Originally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: &#8220;Every template we create is completely open source, meaning you can take it and do whatever you want with it&#8221;).  The original template can be obtained from <a href=\"http://www.oswd.org/design/preview/id/2453/\">Open Source Web Design</a>.</p>\n\n\n	<p>Author&#8217;s website: <a href=\"http://www.madseason.co.uk/\">www.madseason.co.uk</a>.</p>\n\n\n	<h3>&#8220;Snooker&#8221;</h3>\n\n\n	<p>&#8220;Snooker&#8221; is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the <a href=\"http://alistapart.com/articles/negativemargins\">A List Apart</a> website.</p>\n\n\n	<h3>&#8220;Spoiled Brat&#8221;</h3>\n\n\n	<p>Originally designed by <a href=\"http://www.raykdesign.net/\">Rayk Web Design</a> and distributed under the terms of the <a href=\"http://creativecommons.org/licenses/by-sa/2.5/legalcode\">Creative Commons Attribution Share Alike</a> licence.  The original template can be obtained from <a href=\"http://www.openwebdesign.org/viewdesign.phtml?id=2894/\">Open Web Design</a>.</p>\n\n\n	<p>Author&#8217;s website: <a href=\"http://www.csstinderbox.com/\">www.csstinderbox.com</a>.</p>\n\n\n	<h2>Other Features</h2>\n\n\n	<p>Goldberg also contains some miscellaneous code and techniques from other sources.</p>\n\n\n	<h3>Suckerfish Menus</h3>\n\n\n	<p>The three templates &#8220;Earth Wind and Fire&#8221;, &#8220;Snooker&#8221; and &#8220;Spoiled Brat&#8221; have all been configured to use Suckerfish menus.  This technique of using a combination of <span class=\"caps\">CSS</span> and Javascript to implement dynamic menus was first described by <a href=\"http://www.alistapart.com/articles/dropdowns/\">A List Apart</a>.  Goldberg&#8217;s implementation also incorporates techniques described by <a href=\"http://www.htmldog.com/articles/suckerfish/dropdowns/\">HTMLDog</a>.</p>\n\n\n	<h3>Tabbed Panels</h3>\n\n\n	<p>Goldberg&#8217;s implementation of tabbed panels was adapted from \n<a href=\"http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml\">InternetConnection</a>.</p>','Textile'),
 (11,'Not Permitted','unconfirmed',NULL,'h1. Not Permitted\n\nSorry, but you are not allowed to log into the site until your registration has been confirmed.\n\nIf there is an issue please contact the system administrator.\n',3,'2007-04-01 10:37:42','2007-05-21 14:01:59','<h1>Not Permitted</h1>\n\n\n	<p>Sorry, but you are not allowed to log into the site until your registration has been confirmed.</p>\n\n\n	<p>If there is an issue please contact the system administrator.</p>','Textile');
/*!40000 ALTER TABLE `goldberg_content_pages` ENABLE KEYS */;


--
-- Definition of table `goldberg_controller_actions`
--

DROP TABLE IF EXISTS `goldberg_controller_actions`;
CREATE TABLE `goldberg_controller_actions` (
  `id` int(11) NOT NULL auto_increment,
  `site_controller_id` int(11) NOT NULL default '0',
  `name` varchar(255) NOT NULL default '',
  `permission_id` int(11) default NULL,
  `url_to_use` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_controller_action_permission_id` (`permission_id`),
  KEY `fk_controller_action_site_controller_id` (`site_controller_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_controller_actions`
--

/*!40000 ALTER TABLE `goldberg_controller_actions` DISABLE KEYS */;
INSERT INTO `goldberg_controller_actions` (`id`,`site_controller_id`,`name`,`permission_id`,`url_to_use`) VALUES 
 (1,1,'view_default',3,NULL),
 (2,1,'view',3,NULL),
 (3,7,'list',NULL,NULL),
 (4,6,'list',NULL,NULL),
 (5,3,'login',4,NULL),
 (6,3,'logout',4,NULL),
 (7,5,'link',4,NULL),
 (8,1,'list',NULL,NULL),
 (9,8,'list',NULL,NULL),
 (10,2,'list',NULL,NULL),
 (11,5,'list',NULL,NULL),
 (12,9,'list',NULL,NULL),
 (13,3,'forgotten',4,NULL),
 (14,3,'login_failed',4,NULL),
 (15,10,'list',NULL,NULL),
 (16,10,'self_register',4,''),
 (17,10,'confirm_registration',4,''),
 (18,10,'confirm_registration_submit',4,''),
 (19,10,'self_create',4,''),
 (20,10,'forgot_password',4,''),
 (21,10,'forgot_password_submit',4,''),
 (22,10,'reset_password',4,''),
 (23,10,'reset_password_submit',4,'');
/*!40000 ALTER TABLE `goldberg_controller_actions` ENABLE KEYS */;


--
-- Definition of table `goldberg_markup_styles`
--

DROP TABLE IF EXISTS `goldberg_markup_styles`;
CREATE TABLE `goldberg_markup_styles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_markup_styles`
--

/*!40000 ALTER TABLE `goldberg_markup_styles` DISABLE KEYS */;
/*!40000 ALTER TABLE `goldberg_markup_styles` ENABLE KEYS */;


--
-- Definition of table `goldberg_menu_items`
--

DROP TABLE IF EXISTS `goldberg_menu_items`;
CREATE TABLE `goldberg_menu_items` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` int(11) default NULL,
  `name` varchar(255) NOT NULL default '',
  `label` varchar(255) NOT NULL default '',
  `seq` int(11) default NULL,
  `controller_action_id` int(11) default NULL,
  `content_page_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_menu_item_controller_action_id` (`controller_action_id`),
  KEY `fk_menu_item_content_page_id` (`content_page_id`),
  KEY `fk_menu_item_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_menu_items`
--

/*!40000 ALTER TABLE `goldberg_menu_items` DISABLE KEYS */;
INSERT INTO `goldberg_menu_items` (`id`,`parent_id`,`name`,`label`,`seq`,`controller_action_id`,`content_page_id`) VALUES 
 (1,NULL,'home','Home',1,NULL,1),
 (2,NULL,'contact_us','Contact Us',3,NULL,6),
 (3,NULL,'admin','Administration',2,NULL,9),
 (5,9,'setup/permissions','Permissions',3,4,NULL),
 (6,9,'setup/roles','Roles',2,3,NULL),
 (7,9,'setup/pages','Content Pages',5,8,NULL),
 (8,9,'setup/controllers','Controllers / Actions',4,9,NULL),
 (9,3,'setup','Setup',1,NULL,8),
 (11,9,'setup/menus','Menu Editor',6,11,NULL),
 (12,9,'setup/system_settings','System Settings',7,12,NULL),
 (13,9,'setup/users','Users',1,15,NULL),
 (14,2,'credits','Credits &amp; Licence',1,NULL,10);
/*!40000 ALTER TABLE `goldberg_menu_items` ENABLE KEYS */;


--
-- Definition of table `goldberg_permissions`
--

DROP TABLE IF EXISTS `goldberg_permissions`;
CREATE TABLE `goldberg_permissions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_permissions`
--

/*!40000 ALTER TABLE `goldberg_permissions` DISABLE KEYS */;
INSERT INTO `goldberg_permissions` (`id`,`name`) VALUES 
 (1,'Administer site'),
 (2,'Public pages - edit'),
 (3,'Public pages - view'),
 (4,'Public actions - execute'),
 (5,'Members only page -- view');
/*!40000 ALTER TABLE `goldberg_permissions` ENABLE KEYS */;


--
-- Definition of table `goldberg_roles`
--

DROP TABLE IF EXISTS `goldberg_roles`;
CREATE TABLE `goldberg_roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `parent_id` int(11) default NULL,
  `description` varchar(255) NOT NULL default '',
  `default_page_id` int(11) default NULL,
  `cache` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `start_path` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_role_parent_id` (`parent_id`),
  KEY `fk_role_default_page_id` (`default_page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_roles`
--

/*!40000 ALTER TABLE `goldberg_roles` DISABLE KEYS */;
INSERT INTO `goldberg_roles` (`id`,`name`,`parent_id`,`description`,`default_page_id`,`cache`,`created_at`,`updated_at`,`start_path`) VALUES 
 (1,'Public',NULL,'Members of the public who are not logged in.',NULL,'--- \n:credentials: !ruby/object:Goldberg::Credentials \n  actions: \n    goldberg/site_controllers: \n      list: false\n    goldberg/menu_items: \n      list: false\n      link: true\n    goldberg/roles: \n      list: false\n    goldberg/permissions: \n      list: false\n    goldberg/system_settings: \n      list: false\n    goldberg/content_pages: \n      list: false\n      view_default: true\n      view: true\n    goldberg/auth: \n      logout: true\n      forgotten: true\n      login_failed: true\n      login: true\n    goldberg/controller_actions: \n      list: false\n    goldberg/users: \n      self_register: true\n      list: false\n      forgot_password: true\n      forgot_password_submit: true\n      reset_password: true\n      reset_password_submit: true\n      confirm_registration: true\n      self_create: true\n      confirm_registration_submit: true\n  controllers: \n    goldberg/site_controllers: false\n    goldberg/roles_permissions: false\n    goldberg/menu_items: false\n    goldberg/permissions: false\n    goldberg/roles: false\n    goldberg/system_settings: false\n    goldberg/content_pages: false\n    goldberg/auth: false\n    goldberg/controller_actions: false\n    goldberg/users: false\n  pages: \n    notfound: true\n    admin: false\n    site_admin: false\n    unconfirmed: true\n    contact_us: true\n    credits: true\n    home: true\n    expired: true\n    denied: true\n  permission_ids: \n  - 4\n  - 3\n  role_id: 1\n  role_ids: \n  - 1\n  updated_at: 2007-03-31 20:37:43 -04:00\n:menu: !ruby/object:Goldberg::Menu \n  by_id: \n    1: &id003 !ruby/object:Goldberg::Menu::Node \n      content_page_id: 1\n      controller_action_id: \n      id: 1\n      label: Home\n      name: home\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /home\n    2: &id001 !ruby/object:Goldberg::Menu::Node \n      children: \n      - 14\n      content_page_id: 6\n      controller_action_id: \n      id: 2\n      label: Contact Us\n      name: contact_us\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /contact_us\n    14: &id002 !ruby/object:Goldberg::Menu::Node \n      content_page_id: 10\n      controller_action_id: \n      id: 14\n      label: Credits &amp; Licence\n      name: credits\n      parent: \n      parent_id: 2\n      site_controller_id: \n      url: /credits\n  by_name: \n    contact_us: *id001\n    credits: *id002\n    home: *id003\n  crumbs: \n  - 1\n  root: &id004 !ruby/object:Goldberg::Menu::Node \n    children: \n    - 1\n    - 2\n    parent: \n  selected: \n    1: *id003\n  vector: \n  - *id004\n  - *id003\n','2006-06-23 21:03:49','2007-05-21 14:02:01',NULL),
 (2,'Member',1,'',NULL,'--- \n:credentials: !ruby/object:Goldberg::Credentials \n  actions: \n    goldberg/site_controllers: \n      list: false\n    goldberg/menu_items: \n      list: false\n      link: true\n    goldberg/roles: \n      list: false\n    goldberg/permissions: \n      list: false\n    goldberg/system_settings: \n      list: false\n    goldberg/content_pages: \n      list: false\n      view_default: true\n      view: true\n    goldberg/auth: \n      logout: true\n      forgotten: true\n      login_failed: true\n      login: true\n    goldberg/controller_actions: \n      list: false\n    goldberg/users: \n      self_register: true\n      list: false\n      forgot_password: true\n      forgot_password_submit: true\n      reset_password: true\n      reset_password_submit: true\n      confirm_registration: true\n      self_create: true\n      confirm_registration_submit: true\n  controllers: \n    goldberg/site_controllers: false\n    goldberg/roles_permissions: false\n    goldberg/menu_items: false\n    goldberg/permissions: false\n    goldberg/roles: false\n    goldberg/system_settings: false\n    goldberg/content_pages: false\n    goldberg/auth: false\n    goldberg/controller_actions: false\n    goldberg/users: false\n  pages: \n    notfound: true\n    admin: false\n    site_admin: false\n    unconfirmed: true\n    contact_us: true\n    credits: true\n    home: true\n    expired: true\n    denied: true\n  permission_ids: \n  - 5\n  - 4\n  - 3\n  role_id: 2\n  role_ids: \n  - 2\n  - 1\n  updated_at: 2007-03-31 20:37:43 -04:00\n:menu: !ruby/object:Goldberg::Menu \n  by_id: \n    1: &id003 !ruby/object:Goldberg::Menu::Node \n      content_page_id: 1\n      controller_action_id: \n      id: 1\n      label: Home\n      name: home\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /home\n    2: &id001 !ruby/object:Goldberg::Menu::Node \n      children: \n      - 14\n      content_page_id: 6\n      controller_action_id: \n      id: 2\n      label: Contact Us\n      name: contact_us\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /contact_us\n    14: &id002 !ruby/object:Goldberg::Menu::Node \n      content_page_id: 10\n      controller_action_id: \n      id: 14\n      label: Credits &amp; Licence\n      name: credits\n      parent: \n      parent_id: 2\n      site_controller_id: \n      url: /credits\n  by_name: \n    contact_us: *id001\n    credits: *id002\n    home: *id003\n  crumbs: \n  - 1\n  root: &id004 !ruby/object:Goldberg::Menu::Node \n    children: \n    - 1\n    - 2\n    parent: \n  selected: \n    1: *id003\n  vector: \n  - *id004\n  - *id003\n','2006-06-23 21:03:50','2007-05-21 14:02:01',NULL);
INSERT INTO `goldberg_roles` (`id`,`name`,`parent_id`,`description`,`default_page_id`,`cache`,`created_at`,`updated_at`,`start_path`) VALUES 
 (3,'Administrator',2,'',8,'--- \n:credentials: !ruby/object:Goldberg::Credentials \n  actions: \n    goldberg/site_controllers: \n      list: true\n    goldberg/menu_items: \n      list: true\n      link: true\n    goldberg/roles: \n      list: true\n    goldberg/permissions: \n      list: true\n    goldberg/system_settings: \n      list: true\n    goldberg/content_pages: \n      list: true\n      view_default: true\n      view: true\n    goldberg/auth: \n      logout: true\n      forgotten: true\n      login_failed: true\n      login: true\n    goldberg/controller_actions: \n      list: true\n    goldberg/users: \n      self_register: true\n      list: true\n      forgot_password: true\n      forgot_password_submit: true\n      reset_password: true\n      reset_password_submit: true\n      confirm_registration: true\n      self_create: true\n      confirm_registration_submit: true\n  controllers: \n    goldberg/site_controllers: true\n    goldberg/roles_permissions: true\n    goldberg/menu_items: true\n    goldberg/permissions: true\n    goldberg/roles: true\n    goldberg/system_settings: true\n    goldberg/content_pages: true\n    goldberg/auth: true\n    goldberg/controller_actions: true\n    goldberg/users: true\n  pages: \n    notfound: true\n    admin: true\n    site_admin: true\n    unconfirmed: true\n    contact_us: true\n    credits: true\n    home: true\n    expired: true\n    denied: true\n  permission_ids: \n  - 1\n  - 5\n  - 4\n  - 2\n  - 3\n  role_id: 3\n  role_ids: \n  - 3\n  - 2\n  - 1\n  updated_at: 2007-03-31 20:37:43 -04:00\n:menu: !ruby/object:Goldberg::Menu \n  by_id: \n    5: &id009 !ruby/object:Goldberg::Menu::Node \n      content_page_id: \n      controller_action_id: 4\n      id: 5\n      label: Permissions\n      name: setup/permissions\n      parent: \n      parent_id: 9\n      site_controller_id: 6\n      url: /goldberg/permissions/list\n    11: &id004 !ruby/object:Goldberg::Menu::Node \n      content_page_id: \n      controller_action_id: 11\n      id: 11\n      label: Menu Editor\n      name: setup/menus\n      parent: \n      parent_id: 9\n      site_controller_id: 5\n      url: /goldberg/menu_items/list\n    6: &id006 !ruby/object:Goldberg::Menu::Node \n      content_page_id: \n      controller_action_id: 3\n      id: 6\n      label: Roles\n      name: setup/roles\n      parent: \n      parent_id: 9\n      site_controller_id: 7\n      url: /goldberg/roles/list\n    1: &id011 !ruby/object:Goldberg::Menu::Node \n      content_page_id: 1\n      controller_action_id: \n      id: 1\n      label: Home\n      name: home\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /home\n    12: &id003 !ruby/object:Goldberg::Menu::Node \n      content_page_id: \n      controller_action_id: 12\n      id: 12\n      label: System Settings\n      name: setup/system_settings\n      parent: \n      parent_id: 9\n      site_controller_id: 9\n      url: /goldberg/system_settings/list\n    7: &id002 !ruby/object:Goldberg::Menu::Node \n      content_page_id: \n      controller_action_id: 8\n      id: 7\n      label: Content Pages\n      name: setup/pages\n      parent: \n      parent_id: 9\n      site_controller_id: 1\n      url: /goldberg/content_pages/list\n    2: &id007 !ruby/object:Goldberg::Menu::Node \n      children: \n      - 14\n      content_page_id: 6\n      controller_action_id: \n      id: 2\n      label: Contact Us\n      name: contact_us\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /contact_us\n    13: &id001 !ruby/object:Goldberg::Menu::Node \n      content_page_id: \n      controller_action_id: 15\n      id: 13\n      label: Users\n      name: setup/users\n      parent: \n      parent_id: 9\n      site_controller_id: 10\n      url: /goldberg/users/list\n    8: &id012 !ruby/object:Goldberg::Menu::Node \n      content_page_id: \n      controller_action_id: 9\n      id: 8\n      label: Controllers / Actions\n      name: setup/controllers\n      parent: \n      parent_id: 9\n      site_controller_id: 8\n      url: /goldberg/site_controllers/list\n    3: &id005 !ruby/object:Goldberg::Menu::Node \n      children: \n      - 9\n      content_page_id: 9\n      controller_action_id: \n      id: 3\n      label: Administration\n      name: admin\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /admin\n    14: &id010 !ruby/object:Goldberg::Menu::Node \n      content_page_id: 10\n      controller_action_id: \n      id: 14\n      label: Credits &amp; Licence\n      name: credits\n      parent: \n      parent_id: 2\n      site_controller_id: \n      url: /credits\n    9: &id008 !ruby/object:Goldberg::Menu::Node \n      children: \n      - 13\n      - 6\n      - 5\n      - 8\n      - 7\n      - 11\n      - 12\n      content_page_id: 8\n      controller_action_id: \n      id: 9\n      label: Setup\n      name: setup\n      parent: \n      parent_id: 3\n      site_controller_id: \n      url: /site_admin\n  by_name: \n    setup/users: *id001\n    setup/pages: *id002\n    setup/system_settings: *id003\n    setup/menus: *id004\n    admin: *id005\n    setup/roles: *id006\n    contact_us: *id007\n    setup: *id008\n    setup/permissions: *id009\n    credits: *id010\n    home: *id011\n    setup/controllers: *id012\n  crumbs: \n  - 1\n  root: &id013 !ruby/object:Goldberg::Menu::Node \n    children: \n    - 1\n    - 3\n    - 2\n    parent: \n  selected: \n    1: *id011\n  vector: \n  - *id013\n  - *id011\n','2006-06-23 21:03:48','2007-05-21 14:02:01','/menu/admin');
/*!40000 ALTER TABLE `goldberg_roles` ENABLE KEYS */;


--
-- Definition of table `goldberg_roles_permissions`
--

DROP TABLE IF EXISTS `goldberg_roles_permissions`;
CREATE TABLE `goldberg_roles_permissions` (
  `id` int(11) NOT NULL auto_increment,
  `role_id` int(11) NOT NULL default '0',
  `permission_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_roles_permission_role_id` (`role_id`),
  KEY `fk_roles_permission_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_roles_permissions`
--

/*!40000 ALTER TABLE `goldberg_roles_permissions` DISABLE KEYS */;
INSERT INTO `goldberg_roles_permissions` (`id`,`role_id`,`permission_id`) VALUES 
 (4,3,1),
 (6,1,3),
 (7,3,2),
 (9,1,4),
 (10,2,5);
/*!40000 ALTER TABLE `goldberg_roles_permissions` ENABLE KEYS */;


--
-- Definition of table `goldberg_site_controllers`
--

DROP TABLE IF EXISTS `goldberg_site_controllers`;
CREATE TABLE `goldberg_site_controllers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `permission_id` int(11) NOT NULL default '0',
  `builtin` int(11) default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_site_controller_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_site_controllers`
--

/*!40000 ALTER TABLE `goldberg_site_controllers` DISABLE KEYS */;
INSERT INTO `goldberg_site_controllers` (`id`,`name`,`permission_id`,`builtin`) VALUES 
 (1,'goldberg/content_pages',1,1),
 (2,'goldberg/controller_actions',1,1),
 (3,'goldberg/auth',1,1),
 (5,'goldberg/menu_items',1,1),
 (6,'goldberg/permissions',1,1),
 (7,'goldberg/roles',1,1),
 (8,'goldberg/site_controllers',1,1),
 (9,'goldberg/system_settings',1,1),
 (10,'goldberg/users',1,1),
 (11,'goldberg/roles_permissions',1,1);
/*!40000 ALTER TABLE `goldberg_site_controllers` ENABLE KEYS */;


--
-- Definition of table `goldberg_system_settings`
--

DROP TABLE IF EXISTS `goldberg_system_settings`;
CREATE TABLE `goldberg_system_settings` (
  `id` int(11) NOT NULL auto_increment,
  `site_name` varchar(255) NOT NULL default '',
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
  `start_path` varchar(255) default NULL,
  `site_url_prefix` varchar(255) default NULL,
  `self_reg_enabled` tinyint(1) default NULL,
  `self_reg_role_id` int(11) default NULL,
  `self_reg_confirmation_required` tinyint(1) default NULL,
  `self_reg_confirmation_error_page_id` int(11) default NULL,
  `self_reg_send_confirmation_email` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_system_settings_public_role_id` (`public_role_id`),
  KEY `fk_system_settings_site_default_page_id` (`site_default_page_id`),
  KEY `fk_system_settings_not_found_page_id` (`not_found_page_id`),
  KEY `fk_system_settings_permission_denied_page_id` (`permission_denied_page_id`),
  KEY `fk_system_settings_session_expired_page_id` (`session_expired_page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_system_settings`
--

/*!40000 ALTER TABLE `goldberg_system_settings` DISABLE KEYS */;
INSERT INTO `goldberg_system_settings` (`id`,`site_name`,`site_subtitle`,`footer_message`,`public_role_id`,`session_timeout`,`default_markup_style_id`,`site_default_page_id`,`not_found_page_id`,`permission_denied_page_id`,`session_expired_page_id`,`menu_depth`,`start_path`,`site_url_prefix`,`self_reg_enabled`,`self_reg_role_id`,`self_reg_confirmation_required`,`self_reg_confirmation_error_page_id`,`self_reg_send_confirmation_email`) VALUES 
 (1,'Goldberg','A website development tool for Ruby on Rails','A <a href=\"http://goldberg.rubyforge.org\">Goldberg</a> site',1,7200,1,1,3,4,2,3,'','http://localhost:3000/',0,NULL,0,11,0);
/*!40000 ALTER TABLE `goldberg_system_settings` ENABLE KEYS */;


--
-- Definition of table `goldberg_users`
--

DROP TABLE IF EXISTS `goldberg_users`;
CREATE TABLE `goldberg_users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `password` varchar(40) NOT NULL default '',
  `role_id` int(11) NOT NULL default '0',
  `password_salt` varchar(255) default NULL,
  `fullname` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `start_path` varchar(255) default NULL,
  `self_reg_confirmation_required` tinyint(1) default NULL,
  `confirmation_key` varchar(255) default NULL,
  `password_changed_at` datetime default NULL,
  `password_expired` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_user_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `goldberg_users`
--

/*!40000 ALTER TABLE `goldberg_users` DISABLE KEYS */;
INSERT INTO `goldberg_users` (`id`,`name`,`password`,`role_id`,`password_salt`,`fullname`,`email`,`start_path`,`self_reg_confirmation_required`,`confirmation_key`,`password_changed_at`,`password_expired`) VALUES 
 (2,'admin','d033e22ae348aeb5660fc2140aec35850c4da997',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `goldberg_users` ENABLE KEYS */;


--
-- Definition of table `institutions`
--

DROP TABLE IF EXISTS `institutions`;
CREATE TABLE `institutions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `institutions`
--

/*!40000 ALTER TABLE `institutions` DISABLE KEYS */;
INSERT INTO `institutions` (`id`,`name`) VALUES 
 (1,'North Carolina State University');
/*!40000 ALTER TABLE `institutions` ENABLE KEYS */;


--
-- Definition of table `languages`
--

DROP TABLE IF EXISTS `languages`;
CREATE TABLE `languages` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(32) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `languages`
--

/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;


--
-- Definition of table `late_policies`
--

DROP TABLE IF EXISTS `late_policies`;
CREATE TABLE `late_policies` (
  `id` int(11) NOT NULL auto_increment,
  `penalty_period_in_minutes` int(11) default NULL,
  `penalty_per_unit` int(11) default NULL,
  `expressed_as_percentage` tinyint(1) default NULL,
  `max_penalty` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `penalty_period_length_unit` (`penalty_period_in_minutes`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `late_policies`
--

/*!40000 ALTER TABLE `late_policies` DISABLE KEYS */;
INSERT INTO `late_policies` (`id`,`penalty_period_in_minutes`,`penalty_per_unit`,`expressed_as_percentage`,`max_penalty`) VALUES 
 (1,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `late_policies` ENABLE KEYS */;


--
-- Definition of table `mapping_strategies`
--

DROP TABLE IF EXISTS `mapping_strategies`;
CREATE TABLE `mapping_strategies` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `mapping_strategies`
--

/*!40000 ALTER TABLE `mapping_strategies` DISABLE KEYS */;
INSERT INTO `mapping_strategies` (`id`,`name`) VALUES 
 (1,'Static, pseudo-random');
/*!40000 ALTER TABLE `mapping_strategies` ENABLE KEYS */;


--
-- Definition of table `markup_styles`
--

DROP TABLE IF EXISTS `markup_styles`;
CREATE TABLE `markup_styles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `markup_styles`
--

/*!40000 ALTER TABLE `markup_styles` DISABLE KEYS */;
INSERT INTO `markup_styles` (`id`,`name`) VALUES 
 (1,'Textile'),
 (2,'Markdown');
/*!40000 ALTER TABLE `markup_styles` ENABLE KEYS */;


--
-- Definition of table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
CREATE TABLE `menu_items` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` int(11) default NULL,
  `name` varchar(255) NOT NULL default '',
  `label` varchar(255) NOT NULL default '',
  `seq` int(11) default NULL,
  `controller_action_id` int(11) default NULL,
  `content_page_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_menu_item_controller_action_id` (`controller_action_id`),
  KEY `fk_menu_item_content_page_id` (`content_page_id`),
  KEY `fk_menu_item_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `menu_items`
--

/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
INSERT INTO `menu_items` (`id`,`parent_id`,`name`,`label`,`seq`,`controller_action_id`,`content_page_id`) VALUES 
 (1,NULL,'home','Home',1,NULL,1),
 (2,NULL,'contact_us','Contact Us',7,NULL,6),
 (3,NULL,'admin','Administration',2,NULL,9),
 (5,9,'setup/permissions','Permissions',3,4,NULL),
 (6,9,'setup/roles','Roles',2,3,NULL),
 (7,9,'setup/pages','Content Pages',5,8,NULL),
 (8,9,'setup/controllers','Controllers / Actions',4,9,NULL),
 (9,3,'setup','Setup',1,NULL,8),
 (11,9,'setup/menus','Menu Editor',6,11,NULL),
 (12,9,'setup/system_settings','System Settings',7,12,NULL),
 (13,9,'setup/users','Users',1,15,NULL),
 (14,2,'credits','Credits &amp; Licence',1,NULL,10),
 (15,3,'List Instructors','Instructors',3,16,NULL),
 (16,3,'List Administrators','Administrators',4,17,NULL),
 (17,3,'List Super-Administrators','Super-Administrators',5,18,NULL),
 (18,NULL,'Courses','Courses',3,19,NULL),
 (19,NULL,'assignments','Assignments',4,30,NULL),
 (20,NULL,'rubrics','Rubrics',5,21,NULL),
 (21,NULL,'participants','Participants',6,31,NULL),
 (22,3,'List Institutions','Institutions',2,32,NULL);
INSERT INTO `menu_items` (`id`,`parent_id`,`name`,`label`,`seq`,`controller_action_id`,`content_page_id`) VALUES 
 (24,21,'List courses','Add participants to course',2,34,NULL),
 (25,21,'List assignments','Add participants to assignment',1,35,NULL),
 (26,19,'review_feedback','Review feedback',1,36,NULL);
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;


--
-- Definition of table `participants`
--

DROP TABLE IF EXISTS `participants`;
CREATE TABLE `participants` (
  `id` int(11) NOT NULL auto_increment,
  `submit_allowed` tinyint(1) default NULL,
  `review_allowed` tinyint(1) default NULL,
  `user_id` int(11) default NULL,
  `assignment_id` int(11) default NULL,
  `directory_num` int(11) default NULL,
  `submitted_at` datetime default NULL,
  `topic` varchar(255) default NULL,
  `permission_granted` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_participant_users` (`user_id`),
  KEY `fk_participant_assignments` (`assignment_id`),
  CONSTRAINT `fk_participant_assignments` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  CONSTRAINT `fk_participant_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `participants`
--

/*!40000 ALTER TABLE `participants` DISABLE KEYS */;
INSERT INTO `participants` (`id`,`submit_allowed`,`review_allowed`,`user_id`,`assignment_id`,`directory_num`,`submitted_at`,`topic`,`permission_granted`) VALUES 
 (2,1,1,4,2,0,NULL,'Research Communication',NULL),
 (5,NULL,NULL,6,1,NULL,NULL,NULL,NULL),
 (6,NULL,NULL,3,1,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `participants` ENABLE KEYS */;


--
-- Definition of table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `permissions`
--

/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` (`id`,`name`) VALUES 
 (1,'Administer Goldberg'),
 (3,'Public pages - view'),
 (4,'Public actions - execute'),
 (6,'Administer PG'),
 (7,'Administer assignments'),
 (8,'Do assignments'),
 (9,'Administer instructors');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;


--
-- Definition of table `plugin_schema_info`
--

DROP TABLE IF EXISTS `plugin_schema_info`;
CREATE TABLE `plugin_schema_info` (
  `plugin_name` varchar(255) default NULL,
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `plugin_schema_info`
--

/*!40000 ALTER TABLE `plugin_schema_info` DISABLE KEYS */;
INSERT INTO `plugin_schema_info` (`plugin_name`,`version`) VALUES 
 ('goldberg',3);
/*!40000 ALTER TABLE `plugin_schema_info` ENABLE KEYS */;


--
-- Definition of table `question_advices`
--

DROP TABLE IF EXISTS `question_advices`;
CREATE TABLE `question_advices` (
  `id` int(11) NOT NULL auto_increment,
  `question_id` int(11) default NULL,
  `score` int(11) default NULL,
  `advice` text,
  PRIMARY KEY  (`id`),
  KEY `fk_question_question_advices` (`question_id`),
  CONSTRAINT `fk_question_question_advices` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `question_advices`
--

/*!40000 ALTER TABLE `question_advices` DISABLE KEYS */;
INSERT INTO `question_advices` (`id`,`question_id`,`score`,`advice`) VALUES 
 (1,1,1,'This answer is awful'),
 (2,1,2,'This answer is not so good.'),
 (3,1,3,'This answer is OK.'),
 (4,1,4,'This answer is pretty good'),
 (5,1,5,'This answer is perfect'),
 (6,2,0,'False!'),
 (7,2,1,'True!'),
 (8,3,1,'I want more questions'),
 (9,3,2,''),
 (10,3,3,''),
 (11,3,4,''),
 (12,3,5,'I am glad this is the last question'),
 (13,4,1,''),
 (14,4,2,''),
 (15,4,3,''),
 (16,4,4,''),
 (17,4,5,'');
/*!40000 ALTER TABLE `question_advices` ENABLE KEYS */;


--
-- Definition of table `questions`
--

DROP TABLE IF EXISTS `questions`;
CREATE TABLE `questions` (
  `id` int(11) NOT NULL auto_increment,
  `txt` text,
  `true_false` tinyint(1) default NULL,
  `weight` int(11) default NULL,
  `rubric_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_question_rubrics` (`rubric_id`),
  CONSTRAINT `fk_question_rubrics` FOREIGN KEY (`rubric_id`) REFERENCES `rubrics` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `questions`
--

/*!40000 ALTER TABLE `questions` DISABLE KEYS */;
INSERT INTO `questions` (`id`,`txt`,`true_false`,`weight`,`rubric_id`) VALUES 
 (1,'This is my first question.',0,1,1),
 (2,'This is my true/false question',1,1,1),
 (3,'This is my last question.',0,1,1),
 (4,'This is my very last question',0,1,1);
/*!40000 ALTER TABLE `questions` ENABLE KEYS */;


--
-- Definition of table `resubmission_times`
--

DROP TABLE IF EXISTS `resubmission_times`;
CREATE TABLE `resubmission_times` (
  `id` int(11) NOT NULL auto_increment,
  `participant_id` int(11) default NULL,
  `resubmitted_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_resubmission_times_participants` (`participant_id`),
  CONSTRAINT `fk_resubmission_times_participants` FOREIGN KEY (`participant_id`) REFERENCES `participants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `resubmission_times`
--

/*!40000 ALTER TABLE `resubmission_times` DISABLE KEYS */;
INSERT INTO `resubmission_times` (`id`,`participant_id`,`resubmitted_at`) VALUES 
 (1,2,'2007-05-07 10:05:09'),
 (2,2,'2007-05-07 10:05:22'),
 (3,2,'2007-05-07 10:07:28');
/*!40000 ALTER TABLE `resubmission_times` ENABLE KEYS */;


--
-- Definition of table `review_feedbacks`
--

DROP TABLE IF EXISTS `review_feedbacks`;
CREATE TABLE `review_feedbacks` (
  `id` int(11) NOT NULL auto_increment,
  `assignment_id` int(11) default NULL,
  `review_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `feedback_at` datetime default NULL,
  `txt` text,
  PRIMARY KEY  (`id`),
  KEY `fk_review_feedback_assignments` (`assignment_id`),
  KEY `fk_review_feedback_reviews` (`review_id`),
  CONSTRAINT `fk_review_feedback_assignments` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  CONSTRAINT `fk_review_feedback_reviews` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `review_feedbacks`
--

/*!40000 ALTER TABLE `review_feedbacks` DISABLE KEYS */;
INSERT INTO `review_feedbacks` (`id`,`assignment_id`,`review_id`,`user_id`,`feedback_at`,`txt`) VALUES 
 (1,2,1,NULL,NULL,'fsdfsdfsdfsdfsfsdf'),
 (2,2,2,NULL,NULL,'sdfsfsfsdf'),
 (3,2,3,NULL,NULL,'dfsvxvbxg zsg dffgsdgsd'),
 (4,2,4,NULL,NULL,'sdfsff a fatvfaf');
/*!40000 ALTER TABLE `review_feedbacks` ENABLE KEYS */;


--
-- Definition of table `review_mappings`
--

DROP TABLE IF EXISTS `review_mappings`;
CREATE TABLE `review_mappings` (
  `id` int(11) NOT NULL auto_increment,
  `author_id` int(11) default NULL,
  `team_id` int(11) default NULL,
  `reviewer_id` int(11) default NULL,
  `assignment_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_review_mapping_assignments` (`assignment_id`),
  CONSTRAINT `fk_review_mapping_assignments` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `review_mappings`
--

/*!40000 ALTER TABLE `review_mappings` DISABLE KEYS */;
INSERT INTO `review_mappings` (`id`,`author_id`,`team_id`,`reviewer_id`,`assignment_id`) VALUES 
 (1,3,NULL,4,2),
 (2,3,NULL,4,2),
 (3,4,NULL,3,2),
 (4,4,NULL,3,2);
/*!40000 ALTER TABLE `review_mappings` ENABLE KEYS */;


--
-- Definition of table `review_of_review_mappings`
--

DROP TABLE IF EXISTS `review_of_review_mappings`;
CREATE TABLE `review_of_review_mappings` (
  `id` int(11) NOT NULL auto_increment,
  `review_mapping_id` int(11) default NULL,
  `reviewer_id` int(11) default NULL,
  `review_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_review_of_review_mapping_reviews` (`review_id`),
  KEY `fk_review_of_review_mapping_review_mappings` (`review_mapping_id`),
  CONSTRAINT `fk_review_of_review_mapping_reviews` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`),
  CONSTRAINT `fk_review_of_review_mapping_review_mappings` FOREIGN KEY (`review_mapping_id`) REFERENCES `review_mappings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `review_of_review_mappings`
--

/*!40000 ALTER TABLE `review_of_review_mappings` DISABLE KEYS */;
/*!40000 ALTER TABLE `review_of_review_mappings` ENABLE KEYS */;


--
-- Definition of table `review_of_review_scores`
--

DROP TABLE IF EXISTS `review_of_review_scores`;
CREATE TABLE `review_of_review_scores` (
  `id` int(11) NOT NULL auto_increment,
  `review_of_review_id` int(11) default NULL,
  `question_id` int(11) default NULL,
  `score` int(11) default NULL,
  `comments` text,
  PRIMARY KEY  (`id`),
  KEY `fk_review_of_review_score_reviews` (`review_of_review_id`),
  KEY `fk_review_of_review_score_questions` (`question_id`),
  CONSTRAINT `fk_review_of_review_score_questions` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`),
  CONSTRAINT `fk_review_of_review_score_reviews` FOREIGN KEY (`review_of_review_id`) REFERENCES `review_of_reviews` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `review_of_review_scores`
--

/*!40000 ALTER TABLE `review_of_review_scores` DISABLE KEYS */;
/*!40000 ALTER TABLE `review_of_review_scores` ENABLE KEYS */;


--
-- Definition of table `review_of_reviews`
--

DROP TABLE IF EXISTS `review_of_reviews`;
CREATE TABLE `review_of_reviews` (
  `id` int(11) NOT NULL auto_increment,
  `reviewed_at` datetime default NULL,
  `review_of_review_mapping_id` int(11) default NULL,
  `review_num_for_author` int(11) default NULL,
  `review_num_for_reviewer` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_review_of_review_review_of_review_mappings` (`review_of_review_mapping_id`),
  CONSTRAINT `fk_review_of_review_review_of_review_mappings` FOREIGN KEY (`review_of_review_mapping_id`) REFERENCES `review_of_review_mappings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `review_of_reviews`
--

/*!40000 ALTER TABLE `review_of_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `review_of_reviews` ENABLE KEYS */;


--
-- Definition of table `review_scores`
--

DROP TABLE IF EXISTS `review_scores`;
CREATE TABLE `review_scores` (
  `id` int(11) NOT NULL auto_increment,
  `review_id` int(11) default NULL,
  `question_id` int(11) default NULL,
  `score` int(11) default NULL,
  `comments` text,
  PRIMARY KEY  (`id`),
  KEY `fk_review_score_reviews` (`review_id`),
  KEY `fk_review_score_questions` (`question_id`),
  CONSTRAINT `fk_review_score_questions` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`),
  CONSTRAINT `fk_review_score_reviews` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `review_scores`
--

/*!40000 ALTER TABLE `review_scores` DISABLE KEYS */;
INSERT INTO `review_scores` (`id`,`review_id`,`question_id`,`score`,`comments`) VALUES 
 (1,3,1,5,NULL),
 (2,3,2,5,NULL),
 (3,3,3,2,NULL),
 (4,3,4,2,NULL);
/*!40000 ALTER TABLE `review_scores` ENABLE KEYS */;


--
-- Definition of table `review_strategies`
--

DROP TABLE IF EXISTS `review_strategies`;
CREATE TABLE `review_strategies` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `review_strategies`
--

/*!40000 ALTER TABLE `review_strategies` DISABLE KEYS */;
INSERT INTO `review_strategies` (`id`,`name`) VALUES 
 (1,'Rubric');
/*!40000 ALTER TABLE `review_strategies` ENABLE KEYS */;


--
-- Definition of table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` int(11) NOT NULL auto_increment,
  `reviewed_at` datetime default NULL,
  `review_mapping_id` int(11) default NULL,
  `review_num_for_author` int(11) default NULL,
  `review_num_for_reviewer` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_review_mappings` (`review_mapping_id`),
  CONSTRAINT `fk_review_mappings` FOREIGN KEY (`review_mapping_id`) REFERENCES `review_mappings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `reviews`
--

/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` (`id`,`reviewed_at`,`review_mapping_id`,`review_num_for_author`,`review_num_for_reviewer`) VALUES 
 (1,NULL,1,NULL,NULL),
 (2,NULL,2,NULL,NULL),
 (3,NULL,3,NULL,NULL),
 (4,NULL,4,NULL,NULL);
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;


--
-- Definition of table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `parent_id` int(11) default NULL,
  `description` varchar(255) NOT NULL default '',
  `default_page_id` int(11) default NULL,
  `cache` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_role_parent_id` (`parent_id`),
  KEY `fk_role_default_page_id` (`default_page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `roles`
--

/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` (`id`,`name`,`parent_id`,`description`,`default_page_id`,`cache`,`created_at`,`updated_at`) VALUES 
 (1,'Student',NULL,'',NULL,'--- \n:menu: !ruby/object:Menu \n  by_id: \n    1: &id005 !ruby/object:Menu::Node \n      content_page_id: 1\n      controller_action_id: \n      id: 1\n      label: Home\n      name: home\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /home\n    2: &id003 !ruby/object:Menu::Node \n      children: \n      - 14\n      content_page_id: 6\n      controller_action_id: \n      id: 2\n      label: Contact Us\n      name: contact_us\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /contact_us\n    19: &id002 !ruby/object:Menu::Node \n      children: \n      - 26\n      content_page_id: \n      controller_action_id: 30\n      id: 19\n      label: Assignments\n      name: assignments\n      parent: \n      parent_id: \n      site_controller_id: 14\n      url: /assignment/list\n    14: &id004 !ruby/object:Menu::Node \n      content_page_id: 10\n      controller_action_id: \n      id: 14\n      label: Credits &amp; Licence\n      name: credits\n      parent: \n      parent_id: 2\n      site_controller_id: \n      url: /credits\n    26: &id001 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 36\n      id: 26\n      label: Review feedback\n      name: review_feedback\n      parent: \n      parent_id: 19\n      site_controller_id: 24\n      url: /review_feedback/list\n  by_name: \n    review_feedback: *id001\n    assignments: *id002\n    contact_us: *id003\n    credits: *id004\n    home: *id005\n  crumbs: \n  - 1\n  root: &id006 !ruby/object:Menu::Node \n    children: \n    - 1\n    - 19\n    - 2\n    parent: \n  selected: \n    1: *id005\n  vector: \n  - *id006\n  - *id005\n:credentials: !ruby/object:Credentials \n  actions: \n    menu_items: \n      list: false\n      link: true\n    roles: \n      list: false\n    auth: \n      logout: true\n      login_failed: true\n      forgotten: true\n      login: true\n    institution: \n      list: false\n    assignment: \n      new: false\n      list: true\n      create: false\n    site_controllers: \n      list: false\n    participants: \n      add_student: false\n      edit_team_members: false\n      list_assignments: false\n      list_courses: false\n      list_students: false\n    admin: \n      list_instructors: false\n      list_super_administrators: false\n      list_administrators: false\n    review_feedback: \n      list: true\n      show: true\n    student_assignment: \n      list: true\n    rubric: \n      copy_rubric: false\n      list: false\n      save_rubric: false\n      create_rubric: false\n      edit_rubric: false\n    users: \n      list: false\n    system_settings: \n      list: false\n    controller_actions: \n      list: false\n    permissions: \n      list: false\n    content_pages: \n      list: false\n      view_default: true\n      view: true\n    course: \n      list_folders: false\n  controllers: \n    roles: false\n    menu_items: false\n    publishing: true\n    submission: true\n    auth: false\n    institution: false\n    review: true\n    assignment: false\n    site_controllers: false\n    reviewing: false\n    markup_styles: false\n    participants: false\n    admin: false\n    review_feedback: true\n    student_assignment: true\n    rubric: false\n    roles_permissions: false\n    users: false\n    system_settings: false\n    permissions: false\n    controller_actions: false\n    content_pages: false\n    reports: true\n    course: false\n  pages: \n    admin: false\n    notfound: true\n    site_admin: false\n    contact_us: true\n    credits: true\n    denied: true\n    expired: true\n    home: true\n  permission_ids: \n  - 8\n  - 4\n  - 3\n  role_id: 1\n  role_ids: \n  - 1\n  updated_at: 2007-05-30 14:01:42 -04:00\n','2006-06-23 21:03:49','2007-05-30 14:01:42'),
 (2,'Instructor',1,'',NULL,'--- \n:menu: !ruby/object:Menu \n  by_id: \n    1: &id010 !ruby/object:Menu::Node \n      content_page_id: 1\n      controller_action_id: \n      id: 1\n      label: Home\n      name: home\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /home\n    18: &id007 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 19\n      id: 18\n      label: Courses\n      name: Courses\n      parent: \n      parent_id: \n      site_controller_id: 13\n      url: /course/list_folders\n    24: &id001 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 34\n      id: 24\n      label: Add participants to course\n      name: List courses\n      parent: \n      parent_id: 21\n      site_controller_id: 20\n      url: /participants/list_courses\n    2: &id008 !ruby/object:Menu::Node \n      children: \n      - 14\n      content_page_id: 6\n      controller_action_id: \n      id: 2\n      label: Contact Us\n      name: contact_us\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /contact_us\n    19: &id006 !ruby/object:Menu::Node \n      children: \n      - 26\n      content_page_id: \n      controller_action_id: 30\n      id: 19\n      label: Assignments\n      name: assignments\n      parent: \n      parent_id: \n      site_controller_id: 14\n      url: /assignment/list\n    25: &id002 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 35\n      id: 25\n      label: Add participants to assignment\n      name: List assignments\n      parent: \n      parent_id: 21\n      site_controller_id: 20\n      url: /participants/list_assignments\n    14: &id009 !ruby/object:Menu::Node \n      content_page_id: 10\n      controller_action_id: \n      id: 14\n      label: Credits &amp; Licence\n      name: credits\n      parent: \n      parent_id: 2\n      site_controller_id: \n      url: /credits\n    20: &id005 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 21\n      id: 20\n      label: Rubrics\n      name: rubrics\n      parent: \n      parent_id: \n      site_controller_id: 15\n      url: /rubric/list\n    26: &id004 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 36\n      id: 26\n      label: Review feedback\n      name: review_feedback\n      parent: \n      parent_id: 19\n      site_controller_id: 24\n      url: /review_feedback/list\n    21: &id003 !ruby/object:Menu::Node \n      children: \n      - 25\n      - 24\n      content_page_id: \n      controller_action_id: 31\n      id: 21\n      label: Participants\n      name: participants\n      parent: \n      parent_id: \n      site_controller_id: 20\n      url: /participants/list_students\n  by_name: \n    List courses: *id001\n    List assignments: *id002\n    participants: *id003\n    review_feedback: *id004\n    rubrics: *id005\n    assignments: *id006\n    Courses: *id007\n    contact_us: *id008\n    credits: *id009\n    home: *id010\n  crumbs: \n  - 1\n  root: &id011 !ruby/object:Menu::Node \n    children: \n    - 1\n    - 18\n    - 19\n    - 20\n    - 21\n    - 2\n    parent: \n  selected: \n    1: *id010\n  vector: \n  - *id011\n  - *id010\n:credentials: !ruby/object:Credentials \n  actions: \n    menu_items: \n      list: false\n      link: true\n    roles: \n      list: false\n    auth: \n      logout: true\n      login_failed: true\n      forgotten: true\n      login: true\n    institution: \n      list: false\n    assignment: \n      new: true\n      list: true\n      create: true\n    site_controllers: \n      list: false\n    participants: \n      add_student: true\n      edit_team_members: true\n      list_assignments: true\n      list_courses: true\n      list_students: true\n    admin: \n      list_instructors: false\n      list_super_administrators: false\n      list_administrators: false\n    review_feedback: \n      list: true\n      show: true\n    student_assignment: \n      list: true\n    rubric: \n      copy_rubric: true\n      list: true\n      save_rubric: true\n      create_rubric: true\n      edit_rubric: true\n    users: \n      list: false\n    system_settings: \n      list: false\n    controller_actions: \n      list: false\n    permissions: \n      list: false\n    content_pages: \n      list: false\n      view_default: true\n      view: true\n    course: \n      list_folders: true\n  controllers: \n    roles: false\n    menu_items: false\n    publishing: true\n    submission: true\n    auth: false\n    institution: false\n    review: true\n    assignment: true\n    site_controllers: false\n    reviewing: true\n    markup_styles: false\n    participants: true\n    admin: false\n    review_feedback: true\n    student_assignment: true\n    rubric: true\n    roles_permissions: false\n    users: false\n    system_settings: false\n    permissions: false\n    controller_actions: false\n    content_pages: false\n    reports: true\n    course: true\n  pages: \n    admin: false\n    notfound: true\n    site_admin: false\n    contact_us: true\n    credits: true\n    denied: true\n    expired: true\n    home: true\n  permission_ids: \n  - 7\n  - 8\n  - 4\n  - 3\n  role_id: 2\n  role_ids: \n  - 2\n  - 1\n  updated_at: 2007-05-30 14:01:42 -04:00\n','2006-06-23 21:03:50','2007-05-30 14:01:42');
INSERT INTO `roles` (`id`,`name`,`parent_id`,`description`,`default_page_id`,`cache`,`created_at`,`updated_at`) VALUES 
 (3,'Administrator',2,'',8,'--- \n:menu: !ruby/object:Menu \n  by_id: \n    1: &id010 !ruby/object:Menu::Node \n      content_page_id: 1\n      controller_action_id: \n      id: 1\n      label: Home\n      name: home\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /home\n    18: &id007 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 19\n      id: 18\n      label: Courses\n      name: Courses\n      parent: \n      parent_id: \n      site_controller_id: 13\n      url: /course/list_folders\n    24: &id001 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 34\n      id: 24\n      label: Add participants to course\n      name: List courses\n      parent: \n      parent_id: 21\n      site_controller_id: 20\n      url: /participants/list_courses\n    2: &id008 !ruby/object:Menu::Node \n      children: \n      - 14\n      content_page_id: 6\n      controller_action_id: \n      id: 2\n      label: Contact Us\n      name: contact_us\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /contact_us\n    19: &id006 !ruby/object:Menu::Node \n      children: \n      - 26\n      content_page_id: \n      controller_action_id: 30\n      id: 19\n      label: Assignments\n      name: assignments\n      parent: \n      parent_id: \n      site_controller_id: 14\n      url: /assignment/list\n    25: &id002 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 35\n      id: 25\n      label: Add participants to assignment\n      name: List assignments\n      parent: \n      parent_id: 21\n      site_controller_id: 20\n      url: /participants/list_assignments\n    14: &id009 !ruby/object:Menu::Node \n      content_page_id: 10\n      controller_action_id: \n      id: 14\n      label: Credits &amp; Licence\n      name: credits\n      parent: \n      parent_id: 2\n      site_controller_id: \n      url: /credits\n    20: &id005 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 21\n      id: 20\n      label: Rubrics\n      name: rubrics\n      parent: \n      parent_id: \n      site_controller_id: 15\n      url: /rubric/list\n    26: &id004 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 36\n      id: 26\n      label: Review feedback\n      name: review_feedback\n      parent: \n      parent_id: 19\n      site_controller_id: 24\n      url: /review_feedback/list\n    21: &id003 !ruby/object:Menu::Node \n      children: \n      - 25\n      - 24\n      content_page_id: \n      controller_action_id: 31\n      id: 21\n      label: Participants\n      name: participants\n      parent: \n      parent_id: \n      site_controller_id: 20\n      url: /participants/list_students\n  by_name: \n    List courses: *id001\n    List assignments: *id002\n    participants: *id003\n    review_feedback: *id004\n    rubrics: *id005\n    assignments: *id006\n    Courses: *id007\n    contact_us: *id008\n    credits: *id009\n    home: *id010\n  crumbs: \n  - 1\n  root: &id011 !ruby/object:Menu::Node \n    children: \n    - 1\n    - 18\n    - 19\n    - 20\n    - 21\n    - 2\n    parent: \n  selected: \n    1: *id010\n  vector: \n  - *id011\n  - *id010\n:credentials: !ruby/object:Credentials \n  actions: \n    menu_items: \n      list: false\n      link: true\n    roles: \n      list: false\n    auth: \n      logout: true\n      login_failed: true\n      forgotten: true\n      login: true\n    institution: \n      list: false\n    assignment: \n      new: true\n      list: true\n      create: true\n    site_controllers: \n      list: false\n    participants: \n      add_student: true\n      edit_team_members: true\n      list_assignments: true\n      list_courses: true\n      list_students: true\n    admin: \n      list_instructors: false\n      list_super_administrators: false\n      list_administrators: false\n    review_feedback: \n      list: true\n      show: true\n    student_assignment: \n      list: true\n    rubric: \n      copy_rubric: true\n      list: true\n      save_rubric: true\n      create_rubric: true\n      edit_rubric: true\n    users: \n      list: false\n    system_settings: \n      list: false\n    controller_actions: \n      list: false\n    permissions: \n      list: false\n    content_pages: \n      list: false\n      view_default: true\n      view: true\n    course: \n      list_folders: true\n  controllers: \n    roles: false\n    menu_items: false\n    publishing: true\n    submission: true\n    auth: false\n    institution: false\n    review: true\n    assignment: true\n    site_controllers: false\n    reviewing: true\n    markup_styles: false\n    participants: true\n    admin: false\n    review_feedback: true\n    student_assignment: true\n    rubric: true\n    roles_permissions: false\n    users: false\n    system_settings: false\n    permissions: false\n    controller_actions: false\n    content_pages: false\n    reports: true\n    course: true\n  pages: \n    admin: false\n    notfound: true\n    site_admin: false\n    contact_us: true\n    credits: true\n    denied: true\n    expired: true\n    home: true\n  permission_ids: \n  - 7\n  - 7\n  - 8\n  - 4\n  - 3\n  role_id: 3\n  role_ids: \n  - 3\n  - 2\n  - 1\n  updated_at: 2007-05-30 14:01:43 -04:00\n','2006-06-23 21:03:48','2007-05-30 14:01:43'),
 (4,'Super-Administrator',3,'A super-administrator can administer Goldberg, as well as create/remove PG super-administrators and PG administrators.',NULL,'--- \n:menu: !ruby/object:Menu \n  by_id: \n    5: &id016 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 4\n      id: 5\n      label: Permissions\n      name: setup/permissions\n      parent: \n      parent_id: 9\n      site_controller_id: 6\n      url: /permissions/list\n    16: &id006 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 17\n      id: 16\n      label: Administrators\n      name: List Administrators\n      parent: \n      parent_id: 3\n      site_controller_id: 12\n      url: /admin/list_administrators\n    11: &id007 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 11\n      id: 11\n      label: Menu Editor\n      name: setup/menus\n      parent: \n      parent_id: 9\n      site_controller_id: 5\n      url: /menu_items/list\n    22: &id004 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 32\n      id: 22\n      label: Institutions\n      name: List Institutions\n      parent: \n      parent_id: 3\n      site_controller_id: 22\n      url: /institution/list\n    6: &id009 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 3\n      id: 6\n      label: Roles\n      name: setup/roles\n      parent: \n      parent_id: 9\n      site_controller_id: 7\n      url: /roles/list\n    17: &id019 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 18\n      id: 17\n      label: Super-Administrators\n      name: List Super-Administrators\n      parent: \n      parent_id: 3\n      site_controller_id: 12\n      url: /admin/list_super_administrators\n    12: &id005 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 12\n      id: 12\n      label: System Settings\n      name: setup/system_settings\n      parent: \n      parent_id: 9\n      site_controller_id: 9\n      url: /system_settings/list\n    1: &id023 !ruby/object:Menu::Node \n      content_page_id: 1\n      controller_action_id: \n      id: 1\n      label: Home\n      name: home\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /home\n    7: &id002 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 8\n      id: 7\n      label: Content Pages\n      name: setup/pages\n      parent: \n      parent_id: 9\n      site_controller_id: 1\n      url: /content_pages/list\n    18: &id015 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 19\n      id: 18\n      label: Courses\n      name: Courses\n      parent: \n      parent_id: \n      site_controller_id: 13\n      url: /course/list_folders\n    24: &id001 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 34\n      id: 24\n      label: Add participants to course\n      name: List courses\n      parent: \n      parent_id: 21\n      site_controller_id: 20\n      url: /participants/list_courses\n    13: &id003 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 15\n      id: 13\n      label: Users\n      name: setup/users\n      parent: \n      parent_id: 9\n      site_controller_id: 10\n      url: /users/list\n    2: &id018 !ruby/object:Menu::Node \n      children: \n      - 14\n      content_page_id: 6\n      controller_action_id: \n      id: 2\n      label: Contact Us\n      name: contact_us\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /contact_us\n    8: &id021 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 9\n      id: 8\n      label: Controllers / Actions\n      name: setup/controllers\n      parent: \n      parent_id: 9\n      site_controller_id: 8\n      url: /site_controllers/list\n    19: &id014 !ruby/object:Menu::Node \n      children: \n      - 26\n      content_page_id: \n      controller_action_id: 30\n      id: 19\n      label: Assignments\n      name: assignments\n      parent: \n      parent_id: \n      site_controller_id: 14\n      url: /assignment/list\n    25: &id008 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 35\n      id: 25\n      label: Add participants to assignment\n      name: List assignments\n      parent: \n      parent_id: 21\n      site_controller_id: 20\n      url: /participants/list_assignments\n    14: &id020 !ruby/object:Menu::Node \n      content_page_id: 10\n      controller_action_id: \n      id: 14\n      label: Credits &amp; Licence\n      name: credits\n      parent: \n      parent_id: 2\n      site_controller_id: \n      url: /credits\n    3: &id011 !ruby/object:Menu::Node \n      children: \n      - 9\n      - 22\n      - 15\n      - 16\n      - 17\n      content_page_id: 9\n      controller_action_id: \n      id: 3\n      label: Administration\n      name: admin\n      parent: \n      parent_id: \n      site_controller_id: \n      url: /admin\n    9: &id017 !ruby/object:Menu::Node \n      children: \n      - 13\n      - 6\n      - 5\n      - 8\n      - 7\n      - 11\n      - 12\n      content_page_id: 8\n      controller_action_id: \n      id: 9\n      label: Setup\n      name: setup\n      parent: \n      parent_id: 3\n      site_controller_id: \n      url: /site_admin\n    20: &id013 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 21\n      id: 20\n      label: Rubrics\n      name: rubrics\n      parent: \n      parent_id: \n      site_controller_id: 15\n      url: /rubric/list\n    26: &id012 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 36\n      id: 26\n      label: Review feedback\n      name: review_feedback\n      parent: \n      parent_id: 19\n      site_controller_id: 24\n      url: /review_feedback/list\n    15: &id022 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 16\n      id: 15\n      label: Instructors\n      name: List Instructors\n      parent: \n      parent_id: 3\n      site_controller_id: 12\n      url: /admin/list_instructors\n    21: &id010 !ruby/object:Menu::Node \n      children: \n      - 25\n      - 24\n      content_page_id: \n      controller_action_id: 31\n      id: 21\n      label: Participants\n      name: participants\n      parent: \n      parent_id: \n      site_controller_id: 20\n      url: /participants/list_students\n  by_name: \n    List courses: *id001\n    setup/pages: *id002\n    setup/users: *id003\n    List Institutions: *id004\n    setup/system_settings: *id005\n    List Administrators: *id006\n    setup/menus: *id007\n    List assignments: *id008\n    setup/roles: *id009\n    participants: *id010\n    admin: *id011\n    review_feedback: *id012\n    rubrics: *id013\n    assignments: *id014\n    Courses: *id015\n    setup/permissions: *id016\n    setup: *id017\n    contact_us: *id018\n    List Super-Administrators: *id019\n    credits: *id020\n    setup/controllers: *id021\n    List Instructors: *id022\n    home: *id023\n  crumbs: \n  - 1\n  root: &id024 !ruby/object:Menu::Node \n    children: \n    - 1\n    - 3\n    - 18\n    - 19\n    - 20\n    - 21\n    - 2\n    parent: \n  selected: \n    1: *id023\n  vector: \n  - *id024\n  - *id023\n:credentials: !ruby/object:Credentials \n  actions: \n    menu_items: \n      list: true\n      link: true\n    roles: \n      list: true\n    auth: \n      logout: true\n      login_failed: true\n      forgotten: true\n      login: true\n    institution: \n      list: true\n    assignment: \n      new: true\n      list: true\n      create: true\n    site_controllers: \n      list: true\n    participants: \n      add_student: true\n      edit_team_members: true\n      list_assignments: true\n      list_courses: true\n      list_students: true\n    admin: \n      list_instructors: true\n      list_super_administrators: true\n      list_administrators: true\n    review_feedback: \n      list: true\n      show: true\n    student_assignment: \n      list: true\n    rubric: \n      copy_rubric: true\n      list: true\n      save_rubric: true\n      create_rubric: true\n      edit_rubric: true\n    users: \n      list: true\n    system_settings: \n      list: true\n    controller_actions: \n      list: true\n    permissions: \n      list: true\n    content_pages: \n      list: true\n      view_default: true\n      view: true\n    course: \n      list_folders: true\n  controllers: \n    roles: true\n    menu_items: true\n    publishing: true\n    submission: true\n    auth: true\n    institution: true\n    review: true\n    assignment: true\n    site_controllers: true\n    reviewing: true\n    markup_styles: true\n    participants: true\n    admin: true\n    review_feedback: true\n    student_assignment: true\n    rubric: true\n    roles_permissions: true\n    users: true\n    system_settings: true\n    permissions: true\n    controller_actions: true\n    content_pages: true\n    reports: true\n    course: true\n  pages: \n    admin: true\n    notfound: true\n    site_admin: true\n    contact_us: true\n    credits: true\n    denied: true\n    expired: true\n    home: true\n  permission_ids: \n  - 7\n  - 7\n  - 7\n  - 1\n  - 9\n  - 6\n  - 8\n  - 4\n  - 3\n  role_id: 4\n  role_ids: \n  - 4\n  - 3\n  - 2\n  - 1\n  updated_at: 2007-05-30 14:01:43 -04:00\n','2007-03-05 10:59:36','2007-05-30 14:01:43');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;


--
-- Definition of table `roles_permissions`
--

DROP TABLE IF EXISTS `roles_permissions`;
CREATE TABLE `roles_permissions` (
  `id` int(11) NOT NULL auto_increment,
  `role_id` int(11) NOT NULL default '0',
  `permission_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_roles_permission_role_id` (`role_id`),
  KEY `fk_roles_permission_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `roles_permissions`
--

/*!40000 ALTER TABLE `roles_permissions` DISABLE KEYS */;
INSERT INTO `roles_permissions` (`id`,`role_id`,`permission_id`) VALUES 
 (6,1,3),
 (7,3,2),
 (9,1,4),
 (10,2,5),
 (11,4,6),
 (12,4,1),
 (14,2,7),
 (15,3,7),
 (16,4,7),
 (17,4,9),
 (18,1,8);
/*!40000 ALTER TABLE `roles_permissions` ENABLE KEYS */;


--
-- Definition of table `rubrics`
--

DROP TABLE IF EXISTS `rubrics`;
CREATE TABLE `rubrics` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(64) default NULL,
  `instructor_id` int(11) NOT NULL default '0',
  `private` tinyint(1) NOT NULL default '0',
  `min_question_score` int(11) NOT NULL default '0',
  `max_question_score` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `rubrics`
--

/*!40000 ALTER TABLE `rubrics` DISABLE KEYS */;
INSERT INTO `rubrics` (`id`,`name`,`instructor_id`,`private`,`min_question_score`,`max_question_score`) VALUES 
 (1,'rubric1',2,0,1,5),
 (2,'rubric2',5,1,3,5),
 (3,'rubric3',5,0,5,8);
/*!40000 ALTER TABLE `rubrics` ENABLE KEYS */;


--
-- Definition of table `schema_info`
--

DROP TABLE IF EXISTS `schema_info`;
CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `schema_info`
--

/*!40000 ALTER TABLE `schema_info` DISABLE KEYS */;
INSERT INTO `schema_info` (`version`) VALUES 
 (28);
/*!40000 ALTER TABLE `schema_info` ENABLE KEYS */;


--
-- Definition of table `site_controllers`
--

DROP TABLE IF EXISTS `site_controllers`;
CREATE TABLE `site_controllers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `permission_id` int(11) NOT NULL default '0',
  `builtin` int(11) default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_site_controller_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `site_controllers`
--

/*!40000 ALTER TABLE `site_controllers` DISABLE KEYS */;
INSERT INTO `site_controllers` (`id`,`name`,`permission_id`,`builtin`) VALUES 
 (1,'content_pages',1,1),
 (2,'controller_actions',1,1),
 (3,'auth',1,1),
 (4,'markup_styles',1,1),
 (5,'menu_items',1,1),
 (6,'permissions',1,1),
 (7,'roles',1,1),
 (8,'site_controllers',1,1),
 (9,'system_settings',1,1),
 (10,'users',1,1),
 (11,'roles_permissions',1,1),
 (12,'admin',1,0),
 (13,'course',7,0),
 (14,'assignment',7,0),
 (15,'rubric',7,0),
 (16,'submission',8,0),
 (17,'publishing',8,0),
 (18,'review',8,0),
 (19,'reviewing',7,0),
 (20,'participants',7,0),
 (21,'reports',8,0),
 (22,'institution',6,0),
 (23,'student_assignment',8,0),
 (24,'review_feedback',3,0);
/*!40000 ALTER TABLE `site_controllers` ENABLE KEYS */;


--
-- Definition of table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL auto_increment,
  `site_name` varchar(255) NOT NULL default '',
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
  KEY `fk_system_settings_session_expired_page_id` (`session_expired_page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `system_settings`
--

/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` (`id`,`site_name`,`site_subtitle`,`footer_message`,`public_role_id`,`session_timeout`,`default_markup_style_id`,`site_default_page_id`,`not_found_page_id`,`permission_denied_page_id`,`session_expired_page_id`,`menu_depth`) VALUES 
 (1,'Expertiza','Reusable learning objects through peer review','<a href=\"http://research.csc.ncsu.edu/efg/expertiza/papers\">Expertiza</a>',1,7200,1,1,3,4,2,3);
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;


--
-- Definition of table `teams`
--

DROP TABLE IF EXISTS `teams`;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `teams`
--

/*!40000 ALTER TABLE `teams` DISABLE KEYS */;
/*!40000 ALTER TABLE `teams` ENABLE KEYS */;


--
-- Definition of table `teams_users`
--

DROP TABLE IF EXISTS `teams_users`;
CREATE TABLE `teams_users` (
  `id` int(11) NOT NULL auto_increment,
  `team_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_users_teams` (`team_id`),
  KEY `fk_teams_users` (`user_id`),
  CONSTRAINT `fk_teams_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_users_teams` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `teams_users`
--

/*!40000 ALTER TABLE `teams_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `teams_users` ENABLE KEYS */;


--
-- Definition of table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `password` varchar(40) NOT NULL default '',
  `institution_id` int(11) default NULL,
  `role_id` int(11) NOT NULL default '0',
  `password_salt` varchar(255) default NULL,
  `fullname` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `parent_id` int(11) default NULL,
  `private_by_default` tinyint(1) NOT NULL default '0',
  `mru_directory_path` varchar(128) default NULL,
  `email_on_review` tinyint(1) default NULL,
  `email_on_submission` tinyint(1) default NULL,
  `email_on_review_of_review` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `fk_user_role_id` (`role_id`),
  KEY `FK_institutions_users` (`institution_id`),
  CONSTRAINT `FK_institutions_users` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`id`,`name`,`password`,`institution_id`,`role_id`,`password_salt`,`fullname`,`email`,`parent_id`,`private_by_default`,`mru_directory_path`,`email_on_review`,`email_on_submission`,`email_on_review_of_review`) VALUES 
 (2,'admin','d033e22ae348aeb5660fc2140aec35850c4da997',1,4,NULL,'','',2,0,NULL,1,1,1),
 (3,'mkpatel2','3771d01a93f8f0cfde53310aa12c80731da960b3',1,3,'540479100.253843001416813','Patel, Mrunal Kamlesh','mkpatel2@ncsu.edu',2,0,NULL,1,1,0),
 (4,'riwesley','a9b6418664c4923c6440e86f114e13e06242ca3c',1,1,'543401600.413787803049252','Wesley, Ravinand Isaac','riwesley@ncsu.edu',2,0,NULL,1,1,1),
 (5,'nebergma','4f8c58af70760c2558adf4a366a82a1553dc73ab',1,3,'534087200.902863505664672','Bergman, Neil Edward','nebergma@ncsu.edu',2,0,NULL,1,1,1),
 (6,'efg','63385715e90ee8d967a54f571ccb979e26703b8c',1,2,'543441800.534784042656115','Gehringer, Ed','ed_gehringer@yahoo.com',2,0,NULL,1,1,1),
 (7,'pawagle','eb98ddcddf2fa788b37d452a694f2ed111617ca6',1,2,'539693100.232670195622564','Wagle, Prasad A.','pawagle@ncsu.edu',2,0,NULL,1,0,0),
 (8,'rrkariath','ced4290fa7d153fd9f727e4f21a21a30cf9c0752',1,2,'542691900.907644792930002','Riya Raju Kariath','riya_raju@yahoo.com',2,0,NULL,1,0,1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;


--
-- Definition of table `wiki_assignments`
--

DROP TABLE IF EXISTS `wiki_assignments`;
CREATE TABLE `wiki_assignments` (
  `id` int(10) unsigned NOT NULL auto_increment,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wiki_assignments`
--

/*!40000 ALTER TABLE `wiki_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `wiki_assignments` ENABLE KEYS */;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
