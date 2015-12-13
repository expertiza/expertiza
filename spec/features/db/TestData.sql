-- MySQL dump 10.13  Distrib 5.5.46, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: expertiza_development
-- ------------------------------------------------------
-- Server version	5.5.46-0ubuntu0.12.04.2

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

--
-- Table structure for table `answers`
--

DROP TABLE IF EXISTS `answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) NOT NULL DEFAULT '0',
  `answer` int(11) DEFAULT NULL,
  `comments` text COLLATE utf8_unicode_ci,
  `response_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_score_questions` (`question_id`) USING BTREE,
  KEY `fk_score_response` (`response_id`) USING BTREE,
  CONSTRAINT `fk_score_response` FOREIGN KEY (`response_id`) REFERENCES `responses` (`id`),
  CONSTRAINT `fk_score_questions` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `answers`
--

LOCK TABLES `answers` WRITE;
/*!40000 ALTER TABLE `answers` DISABLE KEYS */;
INSERT INTO `answers` VALUES (1,1,NULL,'Comment made in review form',1),(2,2,NULL,'Comment 2',1),(3,3,NULL,'Comment 3',1);
/*!40000 ALTER TABLE `answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignment_questionnaires`
--

DROP TABLE IF EXISTS `assignment_questionnaires`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignment_questionnaires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) DEFAULT NULL,
  `questionnaire_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `notification_limit` int(11) NOT NULL DEFAULT '15',
  `questionnaire_weight` int(11) NOT NULL DEFAULT '0',
  `used_in_round` int(11) DEFAULT NULL,
  `dropdown` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_aq_assignments_id` (`assignment_id`) USING BTREE,
  KEY `fk_aq_questionnaire_id` (`questionnaire_id`) USING BTREE,
  KEY `fk_aq_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_aq_questionnaire_id` FOREIGN KEY (`questionnaire_id`) REFERENCES `questionnaires` (`id`),
  CONSTRAINT `fk_aq_assignments_id` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignment_questionnaires`
--

LOCK TABLES `assignment_questionnaires` WRITE;
/*!40000 ALTER TABLE `assignment_questionnaires` DISABLE KEYS */;
INSERT INTO `assignment_questionnaires` VALUES (27,1,1,NULL,15,50,NULL,0),(28,1,2,NULL,0,50,NULL,0),(51,2,1,NULL,15,100,NULL,1),(52,2,2,NULL,15,0,NULL,1);
/*!40000 ALTER TABLE `assignment_questionnaires` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `directory_path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `submitter_count` int(11) NOT NULL DEFAULT '0',
  `course_id` int(11) DEFAULT '0',
  `instructor_id` int(11) DEFAULT '0',
  `private` tinyint(1) NOT NULL DEFAULT '0',
  `num_reviews` int(11) NOT NULL DEFAULT '0',
  `num_review_of_reviews` int(11) NOT NULL DEFAULT '0',
  `num_review_of_reviewers` int(11) NOT NULL DEFAULT '0',
  `review_questionnaire_id` int(11) DEFAULT NULL,
  `review_of_review_questionnaire_id` int(11) DEFAULT NULL,
  `teammate_review_questionnaire_id` int(11) DEFAULT NULL,
  `reviews_visible_to_all` tinyint(1) DEFAULT NULL,
  `wiki_type_id` int(11) NOT NULL DEFAULT '0',
  `num_reviewers` int(11) NOT NULL DEFAULT '0',
  `spec_location` text COLLATE utf8_unicode_ci,
  `author_feedback_questionnaire_id` int(11) DEFAULT NULL,
  `max_team_size` int(11) NOT NULL DEFAULT '0',
  `staggered_deadline` tinyint(1) DEFAULT NULL,
  `allow_suggestions` tinyint(1) DEFAULT NULL,
  `days_between_submissions` int(11) DEFAULT NULL,
  `review_assignment_strategy` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `max_reviews_per_submission` int(11) DEFAULT NULL,
  `review_topic_threshold` int(11) DEFAULT '0',
  `copy_flag` tinyint(1) DEFAULT '0',
  `rounds_of_reviews` int(11) DEFAULT '1',
  `microtask` tinyint(1) DEFAULT '0',
  `selfreview_questionnaire_id` int(11) DEFAULT NULL,
  `managerreview_questionnaire_id` int(11) DEFAULT NULL,
  `readerreview_questionnaire_id` int(11) DEFAULT NULL,
  `require_quiz` tinyint(1) DEFAULT NULL,
  `num_quiz_questions` int(11) NOT NULL DEFAULT '0',
  `is_coding_assignment` tinyint(1) DEFAULT NULL,
  `is_intelligent` tinyint(1) DEFAULT NULL,
  `calculate_penalty` tinyint(1) NOT NULL DEFAULT '0',
  `late_policy_id` int(11) DEFAULT NULL,
  `is_penalty_calculated` tinyint(1) NOT NULL DEFAULT '0',
  `max_bids` int(11) DEFAULT NULL,
  `show_teammate_reviews` tinyint(1) DEFAULT NULL,
  `availability_flag` tinyint(1) DEFAULT '1',
  `use_bookmark` tinyint(1) DEFAULT NULL,
  `can_review_same_topic` tinyint(1) DEFAULT '1',
  `can_choose_topic_to_review` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_assignments_courses` (`course_id`) USING BTREE,
  KEY `fk_assignments_instructors` (`instructor_id`) USING BTREE,
  KEY `fk_late_policy_id` (`late_policy_id`) USING BTREE,
  KEY `fk_assignments_review_of_review_questionnaires` (`review_of_review_questionnaire_id`) USING BTREE,
  KEY `fk_assignments_review_questionnaires` (`review_questionnaire_id`) USING BTREE,
  KEY `fk_assignments_wiki_types` (`wiki_type_id`) USING BTREE,
  CONSTRAINT `fk_assignments_wiki_types` FOREIGN KEY (`wiki_type_id`) REFERENCES `wiki_types` (`id`),
  CONSTRAINT `fk_assignments_instructors` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_assignments_review_of_review_questionnaires` FOREIGN KEY (`review_of_review_questionnaire_id`) REFERENCES `questionnaires` (`id`),
  CONSTRAINT `fk_assignments_review_questionnaires` FOREIGN KEY (`review_questionnaire_id`) REFERENCES `questionnaires` (`id`),
  CONSTRAINT `fk_late_policy_id` FOREIGN KEY (`late_policy_id`) REFERENCES `late_policies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
INSERT INTO `assignments` VALUES (1,'2015-12-12 20:04:48','2015-12-12 20:35:12','Assignment1','bin/assign',0,1,1,0,0,0,0,NULL,NULL,NULL,0,1,0,'sampleURL.com',NULL,2,0,0,NULL,'Auto-Selected',6,6,0,1,0,NULL,NULL,NULL,0,0,0,0,0,NULL,0,NULL,0,1,0,1,1),(2,'2015-12-13 18:24:38','2015-12-13 18:32:41','Assignment2','/bin',0,1,1,0,0,0,0,NULL,NULL,NULL,0,1,0,'www.google.com',NULL,1,0,0,NULL,'Auto-Selected',3,3,0,1,0,NULL,NULL,NULL,0,0,0,0,0,NULL,0,NULL,0,1,0,0,0);
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automated_metareviews`
--

DROP TABLE IF EXISTS `automated_metareviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automated_metareviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `relevance` float DEFAULT NULL,
  `content_summative` float DEFAULT NULL,
  `content_problem` float DEFAULT NULL,
  `content_advisory` float DEFAULT NULL,
  `tone_positive` float DEFAULT NULL,
  `tone_negative` float DEFAULT NULL,
  `tone_neutral` float DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `plagiarism` int(11) DEFAULT NULL,
  `version_num` int(11) DEFAULT NULL,
  `response_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_automated_metareviews_responses_id` (`response_id`) USING BTREE,
  CONSTRAINT `fk_automated_metareviews_responses_id` FOREIGN KEY (`response_id`) REFERENCES `responses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automated_metareviews`
--

LOCK TABLES `automated_metareviews` WRITE;
/*!40000 ALTER TABLE `automated_metareviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `automated_metareviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `topic_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bids_on_team_id` (`team_id`) USING BTREE,
  KEY `index_bids_on_topic_id` (`topic_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids`
--

LOCK TABLES `bids` WRITE;
/*!40000 ALTER TABLE `bids` DISABLE KEYS */;
/*!40000 ALTER TABLE `bids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookmark_ratings`
--

DROP TABLE IF EXISTS `bookmark_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bookmark_ratings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bookmark_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookmark_ratings`
--

LOCK TABLES `bookmark_ratings` WRITE;
/*!40000 ALTER TABLE `bookmark_ratings` DISABLE KEYS */;
/*!40000 ALTER TABLE `bookmark_ratings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookmarks`
--

DROP TABLE IF EXISTS `bookmarks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bookmarks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` text COLLATE utf8_unicode_ci,
  `title` text COLLATE utf8_unicode_ci,
  `description` text COLLATE utf8_unicode_ci,
  `user_id` int(11) DEFAULT NULL,
  `topic_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bookmarks_on_topic_id` (`topic_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookmarks`
--

LOCK TABLES `bookmarks` WRITE;
/*!40000 ALTER TABLE `bookmarks` DISABLE KEYS */;
/*!40000 ALTER TABLE `bookmarks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calculated_penalties`
--

DROP TABLE IF EXISTS `calculated_penalties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calculated_penalties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `participant_id` int(11) DEFAULT NULL,
  `deadline_type_id` int(11) DEFAULT NULL,
  `penalty_points` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calculated_penalties`
--

LOCK TABLES `calculated_penalties` WRITE;
/*!40000 ALTER TABLE `calculated_penalties` DISABLE KEYS */;
/*!40000 ALTER TABLE `calculated_penalties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `participant_id` int(11) NOT NULL DEFAULT '0',
  `private` tinyint(1) NOT NULL DEFAULT '0',
  `comment` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_pages`
--

DROP TABLE IF EXISTS `content_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `markup_style_id` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `permission_id` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `content_cache` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `fk_content_page_markup_style_id` (`markup_style_id`) USING BTREE,
  KEY `fk_content_page_permission_id` (`permission_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_pages`
--

LOCK TABLES `content_pages` WRITE;
/*!40000 ALTER TABLE `content_pages` DISABLE KEYS */;
INSERT INTO `content_pages` VALUES (1,'Home Page','home',1,'<h1>Welcome to Expertiza</h1> <p> The Expertiza project is a system for using peer review to create reusable learning objects.  Students do different assignments; then peer review selects the best work in each category, and assembles it to create a single unit.</p>',2,'2015-12-04 19:55:59','2015-12-04 19:55:59','<h1>Welcome to Expertiza</h1> <p> The Expertiza project is a system for using peer review to create reusable learning objects.  Students do different assignments; then peer review selects the best work in each category, and assembles it to create a single unit.</p>'),(2,'Session Expired','expired',1,'h1. Session Expired\n\nYour session has expired due to inactivity.\n\nTo continue please login again.\n',2,'2015-12-04 19:55:59','2015-12-04 19:55:59','<h1>Session Expired</h1>\n<p>Your session has expired due to inactivity.</p>\n<p>To continue please login again.</p>'),(3,'Not Found!','notfound',1,'h1. Not Found\n\nThe page you requested was not found!\n\nPlease contact your system administrator.',2,'2015-12-04 19:55:59','2015-12-04 19:55:59','<h1>Not Found</h1>\n<p>The page you requested was not found!</p>\n<p>Please contact your system administrator.</p>'),(4,'Permission Denied!','denied',1,'h1. Permission Denied\n\nSorry, but you don\'\'t have permission to view that page.\n\nPlease contact your system administrator.',2,'2015-12-04 19:55:59','2015-12-04 19:55:59','<h1>Permission Denied</h1>\n<p>Sorry, but you don&#8217;&#8217;t have permission to view that page.</p>\n<p>Please contact your system administrator.</p>'),(5,'Contact Us','contact_us',1,'h1. Contact Us\n\nVisit the Goldberg Project Homepage at \"http://goldberg.rubyforge.org\":http://goldberg.rubyforge.org for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at \"http://rubyforge.org/projects/goldberg\":http://rubyforge.org/projects/goldberg to access the project\'\'s files and development information.\n',2,'2015-12-04 19:55:59','2015-12-04 19:55:59','<h1>Contact Us</h1>\n<p>Visit the Goldberg Project Homepage at <a href=\"http://goldberg.rubyforge.org\">http://goldberg.rubyforge.org</a> for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at <a href=\"http://rubyforge.org/projects/goldberg\">http://rubyforge.org/projects/goldberg</a> to access the project&#8217;&#8217;s files and development information.</p>'),(6,'Site Administration','site_admin',1,'h1. Goldberg Setup\n\nThis is where you will find all the Goldberg-specific administration and configuration features.  In here you can:\n\n* Set up Users.\n\n* Manage Roles and their Permissions.\n\n* Set up any Controllers and their Actions for your application.\n\n* Edit the Content Pages of the site.\n\n* Adjust Goldberg\'\'s system settings.\n\n\nh2. Users\n\nYou can set up Users with a username, password and a Role.\n\n\nh2. Roles and Permissions\n\nA User\'\'s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.\n\nA Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.\n\n\nh2. Controllers and Actions\n\nTo execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.\n\nYou start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.\n\nYou have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.\n\n\nh2. Content Pages\n\nGoldberg has a very simple CMS built in.  You can create pages to be displayed on the site, possibly in menu items.\n\n\nh2. Menu Editor\n\nOnce you have set up your Controller Actions and Content Pages, you can put them into the site\'\'s menu using the Menu Editor.\n\nIn the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.\n\nh2. System Settings\n\nGo here to view and edit the settings that determine how Goldberg operates.\n',1,'2015-12-04 19:55:59','2015-12-04 19:55:59','<h1>Goldberg Setup</h1>\n<p>This is where you will find all the Goldberg-specific administration and configuration features.  In here you can:</p>\n<ul>\n	<li>Set up Users.</li>\n</ul>\n<ul>\n	<li>Manage Roles and their Permissions.</li>\n</ul>\n<ul>\n	<li>Set up any Controllers and their Actions for your application.</li>\n</ul>\n<ul>\n	<li>Edit the Content Pages of the site.</li>\n</ul>\n<ul>\n	<li>Adjust Goldberg&#8217;&#8217;s system settings.</li>\n</ul>\n<h2>Users</h2>\n<p>You can set up Users with a username, password and a Role.</p>\n<h2>Roles and Permissions</h2>\n<p>A User&#8217;&#8217;s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.</p>\n<p>A Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.</p>\n<h2>Controllers and Actions</h2>\n<p>To execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.</p>\n<p>You start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.</p>\n<p>You have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.</p>\n<h2>Content Pages</h2>\n<p>Goldberg has a very simple <span class=\"caps\">CMS</span> built in.  You can create pages to be displayed on the site, possibly in menu items.</p>\n<h2>Menu Editor</h2>\n<p>Once you have set up your Controller Actions and Content Pages, you can put them into the site&#8217;&#8217;s menu using the Menu Editor.</p>\n<p>In the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.</p>\n<h2>System Settings</h2>\n<p>Go here to view and edit the settings that determine how Goldberg operates.</p>'),(7,'Administration','admin',1,'h1. Site Administration\n\nThis is where the administrator can set up the site.\n\nThere is one menu item here by default -- \"Setup\":/menu/setup.  That contains all the Goldberg configuration options.\n\nYou can add more menu items here to administer your application if you want, by going to \"Setup, Menu Editor\":/menu/setup/menus.\n',5,'2015-12-04 19:55:59','2015-12-04 19:55:59','<h1>Site Administration</h1>\n<p>This is where the administrator can set up the site.</p>\n<p>There is one menu item here by default &#8212; <a href=\"/menu/setup\">Setup</a>.  That contains all the Goldberg configuration options.</p>\n<p>You can add more menu items here to administer your application if you want, by going to <a href=\"/menu/setup/menus\">Setup, Menu Editor</a>.</p>'),(8,'Credits and License','credits',1,'h1. Credits and License\n\nGoldberg contains original material and third-party material from various sources.\n\nAll original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.\n\nThe copyright for any third party material remains with the original author, and the material is distributed here under the original terms.  \n\nMaterial has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, BSD-style licences, and Creative Commons licences (but *not* Creative Commons Non-Commercial).\n\nIf you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).\n\n\nh2. Layouts\n\nGoldberg comes with a choice of layouts, adapted from various sources.\n\nh3. The Default\n\nThe default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2493/.\n\nAuthor\'\'s website: \"andreasviklund.com\":http://andreasviklund.com/.\n\n\nh3. \"Earth Wind and Fire\"\n\nOriginally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: \"Every template we create is completely open source, meaning you can take it and do whatever you want with it\").  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2453/.\n\nAuthor\'\'s website: \"www.madseason.co.uk\":http://www.madseason.co.uk/.\n\n\nh3. \"Snooker\"\n\n\"Snooker\" is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the \"A List Apart\":http://alistapart.com/articles/negativemargins website.\n\n\nh3. \"Spoiled Brat\"\n\nOriginally designed by \"Rayk Web Design\":http://www.raykdesign.net/ and distributed under the terms of the \"Creative Commons Attribution Share Alike\":http://creativecommons.org/licenses/by-sa/2.5/legalcode licence.  The original template can be obtained from \"Open Web Design\":http://www.openwebdesign.org/viewdesign.phtml?id=2894/.\n\nAuthor\'\'s website: \"www.csstinderbox.com\":http://www.csstinderbox.com/.\n\n\nh2. Other Features\n\nGoldberg also contains some miscellaneous code and techniques from other sources.\n\nh3. Suckerfish Menus\n\nThe three templates \"Earth Wind and Fire\", \"Snooker\" and \"Spoiled Brat\" have all been configured to use Suckerfish menus.  This technique of using a combination of CSS and Javascript to implement dynamic menus was first described by \"A List Apart\":http://www.alistapart.com/articles/dropdowns/.  Goldberg\'\'s implementation also incorporates techniques described by \"HTMLDog\":http://www.htmldog.com/articles/suckerfish/dropdowns/.\n\nh3. Tabbed Panels\n\nGoldberg\'\'s implementation of tabbed panels was adapted from \n\"InternetConnection\":http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml.\n',2,'2015-12-04 19:55:59','2015-12-04 19:55:59','<h1>Credits and License</h1>\n<p>Goldberg contains original material and third-party material from various sources.</p>\n<p>All original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.</p>\n<p>The copyright for any third party material remains with the original author, and the material is distributed here under the original terms.</p>\n<p>Material has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, <span class=\"caps\">BSD</span>-style licences, and Creative Commons licences (but <strong>not</strong> Creative Commons Non-Commercial).</p>\n<p>If you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).</p>\n<h2>Layouts</h2>\n<p>Goldberg comes with a choice of layouts, adapted from various sources.</p>\n<h3>The Default</h3>\n<p>The default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from <a href=\"http://www.oswd.org/design/preview/id/2493/\">Open Source Web Design</a>.</p>\n<p>Author&#8217;&#8217;s website: <a href=\"http://andreasviklund.com/\">andreasviklund.com</a>.</p>\n<h3>&#8220;Earth Wind and Fire&#8221;</h3>\n<p>Originally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: &#8220;Every template we create is completely open source, meaning you can take it and do whatever you want with it&#8221;).  The original template can be obtained from <a href=\"http://www.oswd.org/design/preview/id/2453/\">Open Source Web Design</a>.</p>\n<p>Author&#8217;&#8217;s website: <a href=\"http://www.madseason.co.uk/\">www.madseason.co.uk</a>.</p>\n<h3>&#8220;Snooker&#8221;</h3>\n<p>&#8220;Snooker&#8221; is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the <a href=\"http://alistapart.com/articles/negativemargins\">A List Apart</a> website.</p>\n<h3>&#8220;Spoiled Brat&#8221;</h3>\n<p>Originally designed by <a href=\"http://www.raykdesign.net/\">Rayk Web Design</a> and distributed under the terms of the <a href=\"http://creativecommons.org/licenses/by-sa/2.5/legalcode\">Creative Commons Attribution Share Alike</a> licence.  The original template can be obtained from <a href=\"http://www.openwebdesign.org/viewdesign.phtml?id=2894/\">Open Web Design</a>.</p>\n<p>Author&#8217;&#8217;s website: <a href=\"http://www.csstinderbox.com/\">www.csstinderbox.com</a>.</p>\n<h2>Other Features</h2>\n<p>Goldberg also contains some miscellaneous code and techniques from other sources.</p>\n<h3>Suckerfish Menus</h3>\n<p>The three templates &#8220;Earth Wind and Fire&#8221;, &#8220;Snooker&#8221; and &#8220;Spoiled Brat&#8221; have all been configured to use Suckerfish menus.  This technique of using a combination of <span class=\"caps\">CSS</span> and Javascript to implement dynamic menus was first described by <a href=\"http://www.alistapart.com/articles/dropdowns/\">A List Apart</a>.  Goldberg&#8217;&#8217;s implementation also incorporates techniques described by <a href=\"http://www.htmldog.com/articles/suckerfish/dropdowns/\">HTMLDog</a>.</p>\n<h3>Tabbed Panels</h3>\n<p>Goldberg&#8217;&#8217;s implementation of tabbed panels was adapted from <br />\n<a href=\"http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml\">InternetConnection</a>.</p>');
/*!40000 ALTER TABLE `content_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `controller_actions`
--

DROP TABLE IF EXISTS `controller_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `controller_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_controller_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `permission_id` int(11) DEFAULT NULL,
  `url_to_use` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_controller_action_permission_id` (`permission_id`) USING BTREE,
  KEY `fk_controller_action_site_controller_id` (`site_controller_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `controller_actions`
--

LOCK TABLES `controller_actions` WRITE;
/*!40000 ALTER TABLE `controller_actions` DISABLE KEYS */;
INSERT INTO `controller_actions` VALUES (1,1,'view_default',2,''),(2,1,'view',2,''),(3,1,'list',NULL,''),(4,2,'list',NULL,''),(5,3,'login',3,''),(6,3,'logout',3,''),(7,3,'login_failed',3,''),(8,5,'link',3,''),(9,5,'list',NULL,''),(10,6,'list',NULL,''),(11,7,'list',NULL,''),(12,8,'list',NULL,''),(13,9,'list',NULL,''),(14,10,'list',5,''),(15,10,'keys',6,''),(16,12,'list_instructors',7,''),(17,12,'list_administrators',4,''),(18,12,'list_super_administrators',1,''),(19,13,'list_folders',5,''),(20,14,'list',5,''),(21,15,'list',5,''),(22,15,'create_questionnaire',5,''),(23,15,'edit_questionnaire',5,''),(24,15,'copy_questionnaire',5,''),(25,15,'save_questionnaire',5,''),(26,17,'add_student',5,''),(27,17,'edit_team_members',5,''),(28,17,'list_students',5,''),(29,17,'list_courses',5,''),(30,17,'list_assignments',5,''),(31,17,'change_handle',6,''),(32,19,'list',4,''),(33,20,'list',6,''),(34,21,'edit',NULL,''),(35,22,'create',3,''),(36,22,'submit',NULL,''),(37,23,'list',NULL,''),(38,23,'list_assignments',NULL,''),(39,24,'list',NULL,''),(40,25,'start',NULL,''),(41,25,'impersonate',6,''),(42,27,'list',NULL,''),(43,27,'add_dynamic_reviewer',6,''),(44,27,'release_reservation',6,''),(45,27,'show_available_submissions',6,''),(46,27,'assign_reviewer_dynamically',6,''),(47,27,'assign_metareviewer_dynamically',6,''),(48,28,'view_my_scores',6,''),(49,31,'list',NULL,''),(50,32,'list_surveys',NULL,''),(51,33,'list',NULL,''),(52,33,'drill',NULL,''),(53,33,'goto_questionnaires',NULL,''),(54,33,'goto_author_feedbacks',NULL,''),(55,33,'goto_review_rubrics',NULL,''),(56,33,'goto_global_survey',NULL,''),(57,33,'goto_surveys',NULL,''),(58,33,'goto_course_evaluations',NULL,''),(59,33,'goto_courses',NULL,''),(60,33,'goto_assignments',NULL,''),(61,33,'goto_teammate_reviews',NULL,''),(62,33,'goto_metareview_rubrics',NULL,''),(63,33,'goto_teammatereview_rubrics',NULL,''),(64,44,'list',6,''),(65,44,'signup',6,''),(66,44,'delete_signup',6,''),(67,45,'create',6,''),(68,45,'new',6,''),(69,46,'index',NULL,''),(70,16,'edit_advice',5,''),(71,16,'save_advice',5,''),(72,48,'add_advertise_comment',6,''),(73,48,'edit',6,''),(74,48,'new',6,''),(75,48,'remove',6,''),(76,48,'update',6,''),(77,49,'create',6,''),(78,49,'decline',6,''),(79,49,'destroy',6,''),(80,49,'edit',6,''),(81,49,'index',6,''),(82,49,'new',6,''),(83,49,'show',6,''),(84,49,'update',6,'');
/*!40000 ALTER TABLE `controller_actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `instructor_id` int(11) DEFAULT NULL,
  `directory_path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `private` tinyint(1) NOT NULL DEFAULT '0',
  `institutions_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_course_users` (`instructor_id`) USING BTREE,
  CONSTRAINT `fk_course_users` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (1,'Course1',1,'/bin','Sample Course','2015-12-12 19:59:09','2015-12-12 19:59:09',0,NULL);
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deadline_rights`
--

DROP TABLE IF EXISTS `deadline_rights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deadline_rights` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deadline_rights`
--

LOCK TABLES `deadline_rights` WRITE;
/*!40000 ALTER TABLE `deadline_rights` DISABLE KEYS */;
INSERT INTO `deadline_rights` VALUES (1,'No'),(2,'Late'),(3,'OK'),(4,'No'),(5,'Late'),(6,'OK'),(7,'No'),(8,'Late'),(9,'OK');
/*!40000 ALTER TABLE `deadline_rights` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deadline_types`
--

DROP TABLE IF EXISTS `deadline_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deadline_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deadline_types`
--

LOCK TABLES `deadline_types` WRITE;
/*!40000 ALTER TABLE `deadline_types` DISABLE KEYS */;
INSERT INTO `deadline_types` VALUES (1,'submission'),(2,'review'),(3,'resubmission'),(4,'rereview'),(5,'metareview'),(6,'drop_topic'),(7,'signup'),(8,'team_formation'),(9,'drop_outstanding_reviews'),(10,'drop_one_member_topics'),(11,'submission'),(12,'review'),(13,'resubmission'),(14,'rereview'),(15,'metareview'),(16,'drop_topic'),(17,'signup'),(18,'team_formation'),(19,'drop_outstanding_reviews'),(20,'drop_one_member_topics'),(21,'submission'),(22,'review'),(23,'resubmission'),(24,'rereview'),(25,'metareview'),(26,'drop_topic'),(27,'signup'),(28,'team_formation'),(29,'drop_outstanding_reviews'),(30,'drop_one_member_topics');
/*!40000 ALTER TABLE `deadline_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delayed_jobs`
--

DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text COLLATE utf8_unicode_ci,
  `last_error` text COLLATE utf8_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `queue` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delayed_jobs`
--

LOCK TABLES `delayed_jobs` WRITE;
/*!40000 ALTER TABLE `delayed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `delayed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `due_dates`
--

DROP TABLE IF EXISTS `due_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `due_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `due_at` datetime DEFAULT NULL,
  `deadline_type_id` int(11) DEFAULT NULL,
  `assignment_id` int(11) DEFAULT NULL,
  `submission_allowed_id` int(11) DEFAULT NULL,
  `review_allowed_id` int(11) DEFAULT NULL,
  `resubmission_allowed_id` int(11) DEFAULT NULL,
  `rereview_allowed_id` int(11) DEFAULT NULL,
  `review_of_review_allowed_id` int(11) DEFAULT NULL,
  `round` int(11) DEFAULT NULL,
  `flag` tinyint(1) DEFAULT '0',
  `threshold` int(11) DEFAULT '1',
  `delayed_job_id` int(11) DEFAULT NULL,
  `deadline_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quiz_allowed_id` int(11) DEFAULT NULL,
  `teammate_review_allowed_id` int(11) DEFAULT '3',
  PRIMARY KEY (`id`),
  KEY `fk_due_dates_assignments` (`assignment_id`) USING BTREE,
  KEY `fk_deadline_type_due_date` (`deadline_type_id`) USING BTREE,
  KEY `fk_due_date_rereview_allowed` (`rereview_allowed_id`) USING BTREE,
  KEY `fk_due_date_resubmission_allowed` (`resubmission_allowed_id`) USING BTREE,
  KEY `fk_due_date_review_allowed` (`review_allowed_id`) USING BTREE,
  KEY `fk_due_date_review_of_review_allowed` (`review_of_review_allowed_id`) USING BTREE,
  KEY `fk_due_date_submission_allowed` (`submission_allowed_id`) USING BTREE,
  CONSTRAINT `fk_deadline_type_due_date` FOREIGN KEY (`deadline_type_id`) REFERENCES `deadline_types` (`id`),
  CONSTRAINT `fk_due_dates_assignments` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  CONSTRAINT `fk_due_date_rereview_allowed` FOREIGN KEY (`rereview_allowed_id`) REFERENCES `deadline_rights` (`id`),
  CONSTRAINT `fk_due_date_resubmission_allowed` FOREIGN KEY (`resubmission_allowed_id`) REFERENCES `deadline_rights` (`id`),
  CONSTRAINT `fk_due_date_review_allowed` FOREIGN KEY (`review_allowed_id`) REFERENCES `deadline_rights` (`id`),
  CONSTRAINT `fk_due_date_review_of_review_allowed` FOREIGN KEY (`review_of_review_allowed_id`) REFERENCES `deadline_rights` (`id`),
  CONSTRAINT `fk_due_date_submission_allowed` FOREIGN KEY (`submission_allowed_id`) REFERENCES `deadline_rights` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `due_dates`
--

LOCK TABLES `due_dates` WRITE;
/*!40000 ALTER TABLE `due_dates` DISABLE KEYS */;
INSERT INTO `due_dates` VALUES (7,'2015-12-12 21:00:00',1,1,3,1,NULL,NULL,1,1,0,1,NULL,NULL,NULL,NULL,1),(8,'2015-12-13 20:09:00',2,1,1,3,NULL,NULL,1,1,0,1,NULL,NULL,NULL,NULL,1),(9,'2015-12-13 17:00:00',1,2,3,1,NULL,NULL,1,1,0,1,NULL,NULL,NULL,NULL,1),(10,'2015-12-14 18:25:00',2,2,1,3,NULL,NULL,1,1,0,1,NULL,NULL,NULL,NULL,1);
/*!40000 ALTER TABLE `due_dates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `institutions`
--

DROP TABLE IF EXISTS `institutions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `institutions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `institutions`
--

LOCK TABLES `institutions` WRITE;
/*!40000 ALTER TABLE `institutions` DISABLE KEYS */;
/*!40000 ALTER TABLE `institutions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invitations`
--

DROP TABLE IF EXISTS `invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invitations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) DEFAULT NULL,
  `from_id` int(11) DEFAULT NULL,
  `to_id` int(11) DEFAULT NULL,
  `reply_status` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_invitation_assignments` (`assignment_id`) USING BTREE,
  KEY `fk_invitationfrom_users` (`from_id`) USING BTREE,
  KEY `fk_invitationto_users` (`to_id`) USING BTREE,
  CONSTRAINT `fk_invitationto_users` FOREIGN KEY (`to_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_invitationfrom_users` FOREIGN KEY (`from_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_invitation_assignments` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invitations`
--

LOCK TABLES `invitations` WRITE;
/*!40000 ALTER TABLE `invitations` DISABLE KEYS */;
INSERT INTO `invitations` VALUES (1,1,4,5,'A'),(2,1,6,7,'A');
/*!40000 ALTER TABLE `invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `join_team_requests`
--

DROP TABLE IF EXISTS `join_team_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `join_team_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `participant_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `comments` text COLLATE utf8_unicode_ci,
  `status` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `join_team_requests`
--

LOCK TABLES `join_team_requests` WRITE;
/*!40000 ALTER TABLE `join_team_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `join_team_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `late_policies`
--

DROP TABLE IF EXISTS `late_policies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `late_policies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `penalty_per_unit` float DEFAULT NULL,
  `max_penalty` int(11) NOT NULL DEFAULT '0',
  `penalty_unit` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `times_used` int(11) NOT NULL DEFAULT '0',
  `instructor_id` int(11) NOT NULL,
  `policy_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_instructor_id` (`instructor_id`) USING BTREE,
  CONSTRAINT `fk_instructor_id` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `late_policies`
--

LOCK TABLES `late_policies` WRITE;
/*!40000 ALTER TABLE `late_policies` DISABLE KEYS */;
/*!40000 ALTER TABLE `late_policies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leaderboards`
--

DROP TABLE IF EXISTS `leaderboards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `leaderboards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `questionnaire_type_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `qtype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leaderboards`
--

LOCK TABLES `leaderboards` WRITE;
/*!40000 ALTER TABLE `leaderboards` DISABLE KEYS */;
/*!40000 ALTER TABLE `leaderboards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `markup_styles`
--

DROP TABLE IF EXISTS `markup_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `markup_styles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `markup_styles`
--

LOCK TABLES `markup_styles` WRITE;
/*!40000 ALTER TABLE `markup_styles` DISABLE KEYS */;
INSERT INTO `markup_styles` VALUES (1,'Textile'),(2,'Markdown');
/*!40000 ALTER TABLE `markup_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `label` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `seq` int(11) DEFAULT NULL,
  `controller_action_id` int(11) DEFAULT NULL,
  `content_page_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_menu_item_content_page_id` (`content_page_id`) USING BTREE,
  KEY `fk_menu_item_controller_action_id` (`controller_action_id`) USING BTREE,
  KEY `fk_menu_item_parent_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_items`
--

LOCK TABLES `menu_items` WRITE;
/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
INSERT INTO `menu_items` VALUES (1,NULL,'home','Home',1,NULL,1),(2,NULL,'admin','Administration',2,NULL,6),(3,NULL,'manage instructor content','Manage...',3,52,NULL),(4,NULL,'Survey Deployments','Survey Deployments',4,49,NULL),(5,NULL,'student_task','Assignments',8,33,NULL),(6,NULL,'profile','Profile',9,34,NULL),(7,NULL,'contact_us','Contact Us',10,NULL,5),(8,1,'leaderboard','Leaderboard',1,69,NULL),(9,7,'credits','Credits &amp; Licence',1,NULL,8),(10,2,'setup','Setup',1,NULL,6),(11,2,'show','Show...',2,14,NULL),(12,10,'setup/roles','Roles',2,11,NULL),(13,10,'setup/permissions','Permissions',3,10,NULL),(14,10,'setup/controllers','Controllers / Actions',4,12,NULL),(15,10,'setup/pages','Content Pages',5,3,NULL),(16,10,'setup/menus','Menu Editor',6,9,NULL),(17,10,'setup/system_settings','System Settings',7,13,NULL),(18,4,'Statistical Test','Statistical Test',3,50,NULL),(19,3,'manage/users','Users',1,14,NULL),(20,3,'manage/questionnaires','Questionnaires',2,53,NULL),(21,3,'manage/courses','Courses',3,59,NULL),(22,3,'manage/assignments','Assignments',4,60,NULL),(23,3,'impersonate','Impersonate User',5,40,NULL),(24,20,'manage/questionnaires/review rubrics','Review rubrics',1,55,NULL),(25,20,'manage/questionnaires/metareview rubrics','Metareview rubrics',2,62,NULL),(26,20,'manage/questionnaires/teammate review rubrics','Teammate review rubrics',3,63,NULL),(27,20,'manage/questionnaires/author feedbacks','Author feedbacks',4,54,NULL),(28,20,'manage/questionnaires/global survey','Global survey',5,56,NULL),(29,20,'manage/questionnaires/surveys','Surveys',6,57,NULL),(30,20,'manage/questionnaires/course evaluations','Course evaluations',7,57,NULL),(31,11,'show/institutions','Institutions',1,32,NULL),(32,11,'show/super-administrators','Super-Administrators',2,18,NULL),(33,11,'show/administrators','Administrators',3,17,NULL),(34,11,'show/instructors','Instructors',4,16,NULL);
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nodes`
--

DROP TABLE IF EXISTS `nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `node_object_id` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nodes`
--

LOCK TABLES `nodes` WRITE;
/*!40000 ALTER TABLE `nodes` DISABLE KEYS */;
INSERT INTO `nodes` VALUES (1,NULL,1,'FolderNode'),(2,NULL,2,'FolderNode'),(3,NULL,3,'FolderNode'),(4,1,4,'FolderNode'),(5,1,5,'FolderNode'),(6,1,6,'FolderNode'),(7,1,7,'FolderNode'),(8,1,8,'FolderNode'),(9,1,9,'FolderNode'),(10,1,10,'FolderNode'),(11,NULL,1,'FolderNode'),(12,NULL,2,'FolderNode'),(13,NULL,3,'FolderNode'),(14,11,4,'FolderNode'),(15,11,5,'FolderNode'),(16,11,6,'FolderNode'),(17,11,7,'FolderNode'),(18,11,8,'FolderNode'),(19,11,9,'FolderNode'),(20,11,10,'FolderNode'),(21,NULL,1,'FolderNode'),(22,NULL,2,'FolderNode'),(23,NULL,3,'FolderNode'),(24,21,4,'FolderNode'),(25,21,5,'FolderNode'),(26,21,6,'FolderNode'),(27,21,7,'FolderNode'),(28,21,8,'FolderNode'),(29,21,9,'FolderNode'),(30,21,10,'FolderNode'),(31,2,1,'CourseNode'),(32,31,1,'AssignmentNode'),(33,1,1,'TeamNode'),(34,33,1,'TeamUserNode'),(35,1,2,'TeamNode'),(36,35,2,'TeamUserNode'),(37,35,3,'TeamUserNode'),(38,32,3,'TeamNode'),(39,38,4,'TeamUserNode'),(40,38,5,'TeamUserNode'),(41,31,2,'AssignmentNode'),(42,2,4,'TeamNode'),(43,42,6,'TeamUserNode'),(44,2,5,'TeamNode'),(45,44,7,'TeamUserNode');
/*!40000 ALTER TABLE `nodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_team_roles`
--

DROP TABLE IF EXISTS `participant_team_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participant_team_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_assignment_id` int(11) DEFAULT NULL,
  `participant_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_participant_id` (`participant_id`) USING BTREE,
  KEY `fk_role_assignment_id` (`role_assignment_id`) USING BTREE,
  CONSTRAINT `fk_role_assignment_id` FOREIGN KEY (`role_assignment_id`) REFERENCES `teamrole_assignment` (`id`),
  CONSTRAINT `fk_participant_id` FOREIGN KEY (`participant_id`) REFERENCES `participants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_team_roles`
--

LOCK TABLES `participant_team_roles` WRITE;
/*!40000 ALTER TABLE `participant_team_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `participant_team_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participants`
--

DROP TABLE IF EXISTS `participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `can_submit` tinyint(1) DEFAULT '1',
  `can_review` tinyint(1) DEFAULT '1',
  `user_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `directory_num` int(11) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `permission_granted` tinyint(1) DEFAULT NULL,
  `penalty_accumulated` int(11) NOT NULL DEFAULT '0',
  `submitted_hyperlinks` text COLLATE utf8_unicode_ci,
  `grade` float DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `handle` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `time_stamp` datetime DEFAULT NULL,
  `digital_signature` text COLLATE utf8_unicode_ci,
  `duty` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `can_take_quiz` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_participant_users` (`user_id`) USING BTREE,
  CONSTRAINT `fk_participant_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participants`
--

LOCK TABLES `participants` WRITE;
/*!40000 ALTER TABLE `participants` DISABLE KEYS */;
INSERT INTO `participants` VALUES (1,1,1,2,1,NULL,NULL,0,0,NULL,NULL,'AssignmentParticipant','student1',NULL,NULL,NULL,1),(2,1,1,3,1,NULL,NULL,0,0,NULL,NULL,'AssignmentParticipant','student2',NULL,NULL,NULL,1),(3,1,1,4,1,NULL,NULL,0,0,'---\n- http://www.google.com\n',NULL,'AssignmentParticipant','student3',NULL,NULL,NULL,1),(4,1,1,5,1,NULL,NULL,0,0,NULL,NULL,'AssignmentParticipant','student4',NULL,NULL,NULL,1),(5,1,1,6,1,NULL,NULL,0,0,NULL,NULL,'AssignmentParticipant','student5',NULL,NULL,NULL,1),(6,1,1,7,1,NULL,NULL,0,0,'---\n- http://www.facebook.com\n',NULL,'AssignmentParticipant','student6',NULL,NULL,NULL,1),(7,1,1,2,2,NULL,NULL,0,0,'---\n- http://www.facebook.com\n',NULL,'AssignmentParticipant','student1',NULL,NULL,NULL,1),(8,1,1,3,2,NULL,NULL,0,0,'---\n- http://www.google.com\n',NULL,'AssignmentParticipant','student2',NULL,NULL,NULL,1),(9,1,1,4,2,NULL,NULL,0,0,NULL,NULL,'AssignmentParticipant','student3',NULL,NULL,NULL,1);
/*!40000 ALTER TABLE `participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'administer goldberg'),(2,'public pages - view'),(3,'public actions - execute'),(4,'administer pg'),(5,'administer assignments'),(6,'do assignments'),(7,'administer instructors'),(8,'administer courses');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plugin_schema_info`
--

DROP TABLE IF EXISTS `plugin_schema_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plugin_schema_info` (
  `plugin_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `version` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plugin_schema_info`
--

LOCK TABLES `plugin_schema_info` WRITE;
/*!40000 ALTER TABLE `plugin_schema_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `plugin_schema_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_advices`
--

DROP TABLE IF EXISTS `question_advices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `question_advices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `advice` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `fk_question_question_advices` (`question_id`) USING BTREE,
  CONSTRAINT `fk_question_question_advices` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question_advices`
--

LOCK TABLES `question_advices` WRITE;
/*!40000 ALTER TABLE `question_advices` DISABLE KEYS */;
/*!40000 ALTER TABLE `question_advices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questionnaires`
--

DROP TABLE IF EXISTS `questionnaires`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `instructor_id` int(11) NOT NULL DEFAULT '0',
  `private` tinyint(1) NOT NULL DEFAULT '0',
  `min_question_score` int(11) NOT NULL DEFAULT '0',
  `max_question_score` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `display_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `instruction_loc` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questionnaires`
--

LOCK TABLES `questionnaires` WRITE;
/*!40000 ALTER TABLE `questionnaires` DISABLE KEYS */;
INSERT INTO `questionnaires` VALUES (1,'Review1',1,0,0,5,'2015-01-01 00:00:00','2015-01-02 00:00:00','ReviewQuestionnaire','ReviewQuestionnaire',NULL),(2,'Author1',1,0,0,5,'2015-01-01 00:00:00','2015-01-02 00:00:00','AuthorFeedbackQuestionnaire','AuthorFeedbackQuestionnaire',NULL);
/*!40000 ALTER TABLE `questionnaires` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questions`
--

DROP TABLE IF EXISTS `questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `txt` text COLLATE utf8_unicode_ci,
  `weight` int(11) DEFAULT NULL,
  `questionnaire_id` int(11) DEFAULT NULL,
  `seq` decimal(6,2) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `alternatives` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `break_before` tinyint(1) DEFAULT '1',
  `max_label` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `min_label` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `fk_question_questionnaires` (`questionnaire_id`) USING BTREE,
  CONSTRAINT `fk_question_questionnaires` FOREIGN KEY (`questionnaire_id`) REFERENCES `questionnaires` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questions`
--

LOCK TABLES `questions` WRITE;
/*!40000 ALTER TABLE `questions` DISABLE KEYS */;
INSERT INTO `questions` VALUES (1,'Question1: ',1,1,1.00,'TextField',NULL,NULL,1,NULL,NULL),(2,'Question2: ',1,1,2.00,'TextField',NULL,NULL,1,NULL,NULL),(3,'Question3: ',1,1,3.00,'TextField',NULL,NULL,1,NULL,NULL),(4,'Question1: ',1,2,1.00,'TextField',NULL,NULL,1,NULL,NULL),(5,'Question2: ',1,2,2.00,'TextField',NULL,NULL,1,NULL,NULL),(6,'Question3: ',1,2,3.00,'TextField',NULL,NULL,1,NULL,NULL);
/*!40000 ALTER TABLE `questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_question_choices`
--

DROP TABLE IF EXISTS `quiz_question_choices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quiz_question_choices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `txt` text COLLATE utf8_unicode_ci,
  `iscorrect` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_question_choices`
--

LOCK TABLES `quiz_question_choices` WRITE;
/*!40000 ALTER TABLE `quiz_question_choices` DISABLE KEYS */;
/*!40000 ALTER TABLE `quiz_question_choices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `response_maps`
--

DROP TABLE IF EXISTS `response_maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `response_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reviewed_object_id` int(11) NOT NULL DEFAULT '0',
  `reviewer_id` int(11) NOT NULL DEFAULT '0',
  `reviewee_id` int(11) NOT NULL DEFAULT '0',
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_response_map_reviewer` (`reviewer_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `response_maps`
--

LOCK TABLES `response_maps` WRITE;
/*!40000 ALTER TABLE `response_maps` DISABLE KEYS */;
INSERT INTO `response_maps` VALUES (1,1,5,2,'ReviewResponseMap','2015-12-13 17:16:21','2015-12-13 17:16:21');
/*!40000 ALTER TABLE `response_maps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `responses`
--

DROP TABLE IF EXISTS `responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `responses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `map_id` int(11) NOT NULL DEFAULT '0',
  `additional_comment` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version_num` int(11) DEFAULT NULL,
  `round` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_response_response_map` (`map_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `responses`
--

LOCK TABLES `responses` WRITE;
/*!40000 ALTER TABLE `responses` DISABLE KEYS */;
INSERT INTO `responses` VALUES (1,1,'        ','2015-12-13 17:16:53','2015-12-13 17:16:53',NULL,1);
/*!40000 ALTER TABLE `responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resubmission_times`
--

DROP TABLE IF EXISTS `resubmission_times`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resubmission_times` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `participant_id` int(11) DEFAULT NULL,
  `resubmitted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_resubmission_times_participants` (`participant_id`) USING BTREE,
  CONSTRAINT `fk_resubmission_times_participants` FOREIGN KEY (`participant_id`) REFERENCES `participants` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resubmission_times`
--

LOCK TABLES `resubmission_times` WRITE;
/*!40000 ALTER TABLE `resubmission_times` DISABLE KEYS */;
INSERT INTO `resubmission_times` VALUES (1,3,'2015-12-13 15:31:53'),(2,6,'2015-12-13 15:43:54'),(3,8,'2015-12-13 18:28:24'),(4,7,'2015-12-13 18:29:14');
/*!40000 ALTER TABLE `resubmission_times` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review_comments`
--

DROP TABLE IF EXISTS `review_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `review_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `review_file_id` int(11) DEFAULT NULL,
  `comment_content` text COLLATE utf8_unicode_ci,
  `reviewer_participant_id` int(11) DEFAULT NULL,
  `file_offset` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `initial_line_number` int(11) DEFAULT NULL,
  `last_line_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_comments`
--

LOCK TABLES `review_comments` WRITE;
/*!40000 ALTER TABLE `review_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `review_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review_files`
--

DROP TABLE IF EXISTS `review_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `review_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filepath` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `author_participant_id` int(11) DEFAULT NULL,
  `version_number` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_files`
--

LOCK TABLES `review_files` WRITE;
/*!40000 ALTER TABLE `review_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `review_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `parent_id` int(11) DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `default_page_id` int(11) DEFAULT NULL,
  `cache` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_role_default_page_id` (`default_page_id`) USING BTREE,
  KEY `fk_role_parent_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Student',NULL,'',NULL,'---\n:credentials: !ruby/object:Credentials\n  role_id: 1\n  updated_at: 2015-12-04 19:57:43.000000000 Z\n  role_ids:\n  - 1\n  permission_ids:\n  - 6\n  - 6\n  - 6\n  - 3\n  - 3\n  - 3\n  - 2\n  - 2\n  - 2\n  actions:\n    content_pages:\n      view_default: true\n      view: true\n      list: false\n    controller_actions:\n      list: false\n    auth:\n      login: true\n      logout: true\n      login_failed: true\n    menu_items:\n      link: true\n      list: false\n    permissions:\n      list: false\n    roles:\n      list: false\n    site_controllers:\n      list: false\n    system_settings:\n      list: false\n    users:\n      list: false\n      keys: true\n    admin:\n      list_instructors: false\n      list_administrators: false\n      list_super_administrators: false\n    course:\n      list_folders: false\n    assignment:\n      list: false\n    questionnaire:\n      list: false\n      create_questionnaire: false\n      edit_questionnaire: false\n      copy_questionnaire: false\n      save_questionnaire: false\n    participants:\n      add_student: false\n      edit_team_members: false\n      list_students: false\n      list_courses: false\n      list_assignments: false\n      change_handle: true\n    institution:\n      list: false\n    student_task:\n      list: true\n    profile:\n      edit: true\n    survey_response:\n      create: true\n      submit: true\n    team:\n      list: false\n      list_assignments: false\n    teams_users:\n      list: false\n    impersonate:\n      start: false\n      impersonate: true\n    review_mapping:\n      list: false\n      add_dynamic_reviewer: true\n      release_reservation: true\n      show_available_submissions: true\n      assign_reviewer_dynamically: true\n      assign_metareviewer_dynamically: true\n    grades:\n      view_my_scores: true\n    survey_deployment:\n      list: false\n    statistics:\n      list_surveys: false\n    tree_display:\n      list: false\n      drill: false\n      goto_questionnaires: false\n      goto_author_feedbacks: false\n      goto_review_rubrics: false\n      goto_global_survey: false\n      goto_surveys: false\n      goto_course_evaluations: false\n      goto_courses: false\n      goto_assignments: false\n      goto_teammate_reviews: false\n      goto_metareview_rubrics: false\n      goto_teammatereview_rubrics: false\n    sign_up_sheet:\n      list: true\n      signup: true\n      delete_signup: true\n    suggestion:\n      create: true\n      new: true\n    leaderboard:\n      index: true\n    advice:\n      edit_advice: false\n      save_advice: false\n    advertise_for_partner:\n      add_advertise_comment: true\n      edit: true\n      new: true\n      remove: true\n      update: true\n    join_team_requests:\n      create: true\n      decline: true\n      destroy: true\n      edit: true\n      index: true\n      new: true\n      show: true\n      update: true\n  controllers:\n    content_pages: false\n    controller_actions: false\n    auth: false\n    markup_styles: false\n    menu_items: false\n    permissions: false\n    roles: false\n    site_controllers: false\n    system_settings: false\n    users: true\n    roles_permissions: false\n    admin: false\n    course: false\n    assignment: false\n    questionnaire: false\n    advice: false\n    participants: false\n    reports: true\n    institution: false\n    student_task: true\n    profile: true\n    survey_response: true\n    team: false\n    teams_users: false\n    impersonate: false\n    import_file: false\n    review_mapping: false\n    grades: false\n    course_evaluation: true\n    participant_choices: false\n    survey_deployment: false\n    statistics: false\n    tree_display: false\n    student_team: true\n    invitation: true\n    survey: false\n    password_retrieval: true\n    submitted_content: true\n    eula: true\n    student_review: true\n    publishing: true\n    export_file: false\n    response: true\n    sign_up_sheet: false\n    suggestion: false\n    leaderboard: true\n    delete_object: false\n    advertise_for_partner: true\n    join_team_requests: true\n  pages:\n    home: true\n    expired: true\n    notfound: true\n    denied: true\n    contact_us: true\n    site_admin: false\n    admin: false\n    credits: true\n:menu: !ruby/object:Menu\n  root: &7 !ruby/object:Menu::Node\n    parent: \n    children:\n    - 1\n    - 5\n    - 6\n    - 7\n  by_id:\n    1: &1 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 8\n      parent_id: \n      name: home\n      id: 1\n      label: Home\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 1\n      url: \"/home\"\n    5: &2 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: student_task\n      id: 5\n      label: Assignments\n      site_controller_id: 20\n      controller_action_id: 33\n      content_page_id: \n      url: \"/student_task/list\"\n    6: &3 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: profile\n      id: 6\n      label: Profile\n      site_controller_id: 21\n      controller_action_id: 34\n      content_page_id: \n      url: \"/profile/edit\"\n    7: &4 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 9\n      parent_id: \n      name: contact_us\n      id: 7\n      label: Contact Us\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 5\n      url: \"/contact_us\"\n    8: &5 !ruby/object:Menu::Node\n      parent: \n      parent_id: 1\n      name: leaderboard\n      id: 8\n      label: Leaderboard\n      site_controller_id: 46\n      controller_action_id: 69\n      content_page_id: \n      url: \"/leaderboard/index\"\n    9: &6 !ruby/object:Menu::Node\n      parent: \n      parent_id: 7\n      name: credits\n      id: 9\n      label: Credits &amp; Licence\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 8\n      url: \"/credits\"\n  by_name:\n    home: *1\n    student_task: *2\n    profile: *3\n    contact_us: *4\n    leaderboard: *5\n    credits: *6\n  selected:\n    1: *1\n  vector:\n  - *7\n  - *1\n  crumbs:\n  - 1\n','2015-12-04 19:56:00','2015-12-04 19:57:44'),(2,'Teaching Assistant',1,'',NULL,'---\n:credentials: !ruby/object:Credentials\n  role_id: 2\n  updated_at: 2015-12-04 19:57:44.000000000 Z\n  role_ids:\n  - 2\n  - 1\n  permission_ids:\n  - 6\n  - 6\n  - 6\n  - 3\n  - 3\n  - 3\n  - 2\n  - 2\n  - 2\n  actions:\n    content_pages:\n      view_default: true\n      view: true\n      list: false\n    controller_actions:\n      list: false\n    auth:\n      login: true\n      logout: true\n      login_failed: true\n    menu_items:\n      link: true\n      list: false\n    permissions:\n      list: false\n    roles:\n      list: false\n    site_controllers:\n      list: false\n    system_settings:\n      list: false\n    users:\n      list: false\n      keys: true\n    admin:\n      list_instructors: false\n      list_administrators: false\n      list_super_administrators: false\n    course:\n      list_folders: false\n    assignment:\n      list: false\n    questionnaire:\n      list: false\n      create_questionnaire: false\n      edit_questionnaire: false\n      copy_questionnaire: false\n      save_questionnaire: false\n    participants:\n      add_student: false\n      edit_team_members: false\n      list_students: false\n      list_courses: false\n      list_assignments: false\n      change_handle: true\n    institution:\n      list: false\n    student_task:\n      list: true\n    profile:\n      edit: true\n    survey_response:\n      create: true\n      submit: true\n    team:\n      list: false\n      list_assignments: false\n    teams_users:\n      list: false\n    impersonate:\n      start: false\n      impersonate: true\n    review_mapping:\n      list: false\n      add_dynamic_reviewer: true\n      release_reservation: true\n      show_available_submissions: true\n      assign_reviewer_dynamically: true\n      assign_metareviewer_dynamically: true\n    grades:\n      view_my_scores: true\n    survey_deployment:\n      list: false\n    statistics:\n      list_surveys: false\n    tree_display:\n      list: false\n      drill: false\n      goto_questionnaires: false\n      goto_author_feedbacks: false\n      goto_review_rubrics: false\n      goto_global_survey: false\n      goto_surveys: false\n      goto_course_evaluations: false\n      goto_courses: false\n      goto_assignments: false\n      goto_teammate_reviews: false\n      goto_metareview_rubrics: false\n      goto_teammatereview_rubrics: false\n    sign_up_sheet:\n      list: true\n      signup: true\n      delete_signup: true\n    suggestion:\n      create: true\n      new: true\n    leaderboard:\n      index: true\n    advice:\n      edit_advice: false\n      save_advice: false\n    advertise_for_partner:\n      add_advertise_comment: true\n      edit: true\n      new: true\n      remove: true\n      update: true\n    join_team_requests:\n      create: true\n      decline: true\n      destroy: true\n      edit: true\n      index: true\n      new: true\n      show: true\n      update: true\n  controllers:\n    content_pages: false\n    controller_actions: false\n    auth: false\n    markup_styles: false\n    menu_items: false\n    permissions: false\n    roles: false\n    site_controllers: false\n    system_settings: false\n    users: true\n    roles_permissions: false\n    admin: false\n    course: false\n    assignment: false\n    questionnaire: false\n    advice: false\n    participants: false\n    reports: true\n    institution: false\n    student_task: true\n    profile: true\n    survey_response: true\n    team: false\n    teams_users: false\n    impersonate: false\n    import_file: false\n    review_mapping: false\n    grades: false\n    course_evaluation: true\n    participant_choices: false\n    survey_deployment: false\n    statistics: false\n    tree_display: false\n    student_team: true\n    invitation: true\n    survey: false\n    password_retrieval: true\n    submitted_content: true\n    eula: true\n    student_review: true\n    publishing: true\n    export_file: false\n    response: true\n    sign_up_sheet: false\n    suggestion: false\n    leaderboard: true\n    delete_object: false\n    advertise_for_partner: true\n    join_team_requests: true\n  pages:\n    home: true\n    expired: true\n    notfound: true\n    denied: true\n    contact_us: true\n    site_admin: false\n    admin: false\n    credits: true\n:menu: !ruby/object:Menu\n  root: &7 !ruby/object:Menu::Node\n    parent: \n    children:\n    - 1\n    - 5\n    - 6\n    - 7\n  by_id:\n    1: &1 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 8\n      parent_id: \n      name: home\n      id: 1\n      label: Home\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 1\n      url: \"/home\"\n    5: &2 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: student_task\n      id: 5\n      label: Assignments\n      site_controller_id: 20\n      controller_action_id: 33\n      content_page_id: \n      url: \"/student_task/list\"\n    6: &3 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: profile\n      id: 6\n      label: Profile\n      site_controller_id: 21\n      controller_action_id: 34\n      content_page_id: \n      url: \"/profile/edit\"\n    7: &4 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 9\n      parent_id: \n      name: contact_us\n      id: 7\n      label: Contact Us\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 5\n      url: \"/contact_us\"\n    8: &5 !ruby/object:Menu::Node\n      parent: \n      parent_id: 1\n      name: leaderboard\n      id: 8\n      label: Leaderboard\n      site_controller_id: 46\n      controller_action_id: 69\n      content_page_id: \n      url: \"/leaderboard/index\"\n    9: &6 !ruby/object:Menu::Node\n      parent: \n      parent_id: 7\n      name: credits\n      id: 9\n      label: Credits &amp; Licence\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 8\n      url: \"/credits\"\n  by_name:\n    home: *1\n    student_task: *2\n    profile: *3\n    contact_us: *4\n    leaderboard: *5\n    credits: *6\n  selected:\n    1: *1\n  vector:\n  - *7\n  - *1\n  crumbs:\n  - 1\n','2015-12-04 19:56:00','2015-12-04 19:57:44'),(3,'Instructor',2,'',NULL,'---\n:credentials: !ruby/object:Credentials\n  role_id: 3\n  updated_at: 2015-12-04 19:57:44.000000000 Z\n  role_ids:\n  - 3\n  - 2\n  - 1\n  permission_ids:\n  - 5\n  - 5\n  - 5\n  - 6\n  - 6\n  - 6\n  - 3\n  - 3\n  - 3\n  - 2\n  - 2\n  - 2\n  actions:\n    content_pages:\n      view_default: true\n      view: true\n      list: false\n    controller_actions:\n      list: false\n    auth:\n      login: true\n      logout: true\n      login_failed: true\n    menu_items:\n      link: true\n      list: false\n    permissions:\n      list: false\n    roles:\n      list: false\n    site_controllers:\n      list: false\n    system_settings:\n      list: false\n    users:\n      list: true\n      keys: true\n    admin:\n      list_instructors: false\n      list_administrators: false\n      list_super_administrators: false\n    course:\n      list_folders: true\n    assignment:\n      list: true\n    questionnaire:\n      list: true\n      create_questionnaire: true\n      edit_questionnaire: true\n      copy_questionnaire: true\n      save_questionnaire: true\n    participants:\n      add_student: true\n      edit_team_members: true\n      list_students: true\n      list_courses: true\n      list_assignments: true\n      change_handle: true\n    institution:\n      list: false\n    student_task:\n      list: true\n    profile:\n      edit: true\n    survey_response:\n      create: true\n      submit: true\n    team:\n      list: true\n      list_assignments: true\n    teams_users:\n      list: true\n    impersonate:\n      start: true\n      impersonate: true\n    review_mapping:\n      list: true\n      add_dynamic_reviewer: true\n      release_reservation: true\n      show_available_submissions: true\n      assign_reviewer_dynamically: true\n      assign_metareviewer_dynamically: true\n    grades:\n      view_my_scores: true\n    survey_deployment:\n      list: true\n    statistics:\n      list_surveys: true\n    tree_display:\n      list: true\n      drill: true\n      goto_questionnaires: true\n      goto_author_feedbacks: true\n      goto_review_rubrics: true\n      goto_global_survey: true\n      goto_surveys: true\n      goto_course_evaluations: true\n      goto_courses: true\n      goto_assignments: true\n      goto_teammate_reviews: true\n      goto_metareview_rubrics: true\n      goto_teammatereview_rubrics: true\n    sign_up_sheet:\n      list: true\n      signup: true\n      delete_signup: true\n    suggestion:\n      create: true\n      new: true\n    leaderboard:\n      index: true\n    advice:\n      edit_advice: true\n      save_advice: true\n    advertise_for_partner:\n      add_advertise_comment: true\n      edit: true\n      new: true\n      remove: true\n      update: true\n    join_team_requests:\n      create: true\n      decline: true\n      destroy: true\n      edit: true\n      index: true\n      new: true\n      show: true\n      update: true\n  controllers:\n    content_pages: false\n    controller_actions: false\n    auth: false\n    markup_styles: false\n    menu_items: false\n    permissions: false\n    roles: false\n    site_controllers: false\n    system_settings: false\n    users: true\n    roles_permissions: false\n    admin: false\n    course: true\n    assignment: true\n    questionnaire: true\n    advice: true\n    participants: true\n    reports: true\n    institution: false\n    student_task: true\n    profile: true\n    survey_response: true\n    team: true\n    teams_users: true\n    impersonate: true\n    import_file: true\n    review_mapping: true\n    grades: true\n    course_evaluation: true\n    participant_choices: true\n    survey_deployment: true\n    statistics: true\n    tree_display: true\n    student_team: true\n    invitation: true\n    survey: true\n    password_retrieval: true\n    submitted_content: true\n    eula: true\n    student_review: true\n    publishing: true\n    export_file: true\n    response: true\n    sign_up_sheet: true\n    suggestion: true\n    leaderboard: true\n    delete_object: true\n    advertise_for_partner: true\n    join_team_requests: true\n  pages:\n    home: true\n    expired: true\n    notfound: true\n    denied: true\n    contact_us: true\n    site_admin: false\n    admin: true\n    credits: true\n:menu: !ruby/object:Menu\n  root: &23 !ruby/object:Menu::Node\n    parent: \n    children:\n    - 1\n    - 3\n    - 4\n    - 5\n    - 6\n    - 7\n  by_id:\n    1: &1 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 8\n      parent_id: \n      name: home\n      id: 1\n      label: Home\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 1\n      url: \"/home\"\n    3: &2 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 19\n      - 20\n      - 21\n      - 22\n      - 23\n      parent_id: \n      name: manage instructor content\n      id: 3\n      label: Manage...\n      site_controller_id: 33\n      controller_action_id: 52\n      content_page_id: \n      url: \"/tree_display/drill\"\n    4: &3 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 18\n      parent_id: \n      name: Survey Deployments\n      id: 4\n      label: Survey Deployments\n      site_controller_id: 31\n      controller_action_id: 49\n      content_page_id: \n      url: \"/survey_deployment/list\"\n    5: &4 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: student_task\n      id: 5\n      label: Assignments\n      site_controller_id: 20\n      controller_action_id: 33\n      content_page_id: \n      url: \"/student_task/list\"\n    6: &5 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: profile\n      id: 6\n      label: Profile\n      site_controller_id: 21\n      controller_action_id: 34\n      content_page_id: \n      url: \"/profile/edit\"\n    7: &6 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 9\n      parent_id: \n      name: contact_us\n      id: 7\n      label: Contact Us\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 5\n      url: \"/contact_us\"\n    8: &7 !ruby/object:Menu::Node\n      parent: \n      parent_id: 1\n      name: leaderboard\n      id: 8\n      label: Leaderboard\n      site_controller_id: 46\n      controller_action_id: 69\n      content_page_id: \n      url: \"/leaderboard/index\"\n    11: &8 !ruby/object:Menu::Node\n      parent: \n      parent_id: 2\n      name: show\n      id: 11\n      label: Show...\n      site_controller_id: 10\n      controller_action_id: 14\n      content_page_id: \n      url: \"/users/list\"\n    19: &9 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/users\n      id: 19\n      label: Users\n      site_controller_id: 10\n      controller_action_id: 14\n      content_page_id: \n      url: \"/users/list\"\n    20: &10 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 24\n      - 25\n      - 26\n      - 27\n      - 28\n      - 29\n      - 30\n      parent_id: 3\n      name: manage/questionnaires\n      id: 20\n      label: Questionnaires\n      site_controller_id: 33\n      controller_action_id: 53\n      content_page_id: \n      url: \"/tree_display/goto_questionnaires\"\n    21: &11 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/courses\n      id: 21\n      label: Courses\n      site_controller_id: 33\n      controller_action_id: 59\n      content_page_id: \n      url: \"/tree_display/goto_courses\"\n    22: &12 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/assignments\n      id: 22\n      label: Assignments\n      site_controller_id: 33\n      controller_action_id: 60\n      content_page_id: \n      url: \"/tree_display/goto_assignments\"\n    23: &13 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: impersonate\n      id: 23\n      label: Impersonate User\n      site_controller_id: 25\n      controller_action_id: 40\n      content_page_id: \n      url: \"/impersonate/start\"\n    18: &14 !ruby/object:Menu::Node\n      parent: \n      parent_id: 4\n      name: Statistical Test\n      id: 18\n      label: Statistical Test\n      site_controller_id: 32\n      controller_action_id: 50\n      content_page_id: \n      url: \"/statistics/list_surveys\"\n    9: &15 !ruby/object:Menu::Node\n      parent: \n      parent_id: 7\n      name: credits\n      id: 9\n      label: Credits &amp; Licence\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 8\n      url: \"/credits\"\n    24: &16 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/review rubrics\n      id: 24\n      label: Review rubrics\n      site_controller_id: 33\n      controller_action_id: 55\n      content_page_id: \n      url: \"/tree_display/goto_review_rubrics\"\n    25: &17 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/metareview rubrics\n      id: 25\n      label: Metareview rubrics\n      site_controller_id: 33\n      controller_action_id: 62\n      content_page_id: \n      url: \"/tree_display/goto_metareview_rubrics\"\n    26: &18 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/teammate review rubrics\n      id: 26\n      label: Teammate review rubrics\n      site_controller_id: 33\n      controller_action_id: 63\n      content_page_id: \n      url: \"/tree_display/goto_teammatereview_rubrics\"\n    27: &19 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/author feedbacks\n      id: 27\n      label: Author feedbacks\n      site_controller_id: 33\n      controller_action_id: 54\n      content_page_id: \n      url: \"/tree_display/goto_author_feedbacks\"\n    28: &20 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/global survey\n      id: 28\n      label: Global survey\n      site_controller_id: 33\n      controller_action_id: 56\n      content_page_id: \n      url: \"/tree_display/goto_global_survey\"\n    29: &21 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/surveys\n      id: 29\n      label: Surveys\n      site_controller_id: 33\n      controller_action_id: 57\n      content_page_id: \n      url: \"/tree_display/goto_surveys\"\n    30: &22 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/course evaluations\n      id: 30\n      label: Course evaluations\n      site_controller_id: 33\n      controller_action_id: 57\n      content_page_id: \n      url: \"/tree_display/goto_surveys\"\n  by_name:\n    home: *1\n    manage instructor content: *2\n    Survey Deployments: *3\n    student_task: *4\n    profile: *5\n    contact_us: *6\n    leaderboard: *7\n    show: *8\n    manage/users: *9\n    manage/questionnaires: *10\n    manage/courses: *11\n    manage/assignments: *12\n    impersonate: *13\n    Statistical Test: *14\n    credits: *15\n    manage/questionnaires/review rubrics: *16\n    manage/questionnaires/metareview rubrics: *17\n    manage/questionnaires/teammate review rubrics: *18\n    manage/questionnaires/author feedbacks: *19\n    manage/questionnaires/global survey: *20\n    manage/questionnaires/surveys: *21\n    manage/questionnaires/course evaluations: *22\n  selected:\n    1: *1\n  vector:\n  - *23\n  - *1\n  crumbs:\n  - 1\n','2015-12-04 19:56:00','2015-12-04 19:57:44'),(4,'Administrator',3,'',NULL,'---\n:credentials: !ruby/object:Credentials\n  role_id: 4\n  updated_at: 2015-12-04 19:57:44.000000000 Z\n  role_ids:\n  - 4\n  - 3\n  - 2\n  - 1\n  permission_ids:\n  - 5\n  - 5\n  - 5\n  - 5\n  - 5\n  - 5\n  - 6\n  - 6\n  - 6\n  - 3\n  - 3\n  - 3\n  - 2\n  - 2\n  - 2\n  actions:\n    content_pages:\n      view_default: true\n      view: true\n      list: false\n    controller_actions:\n      list: false\n    auth:\n      login: true\n      logout: true\n      login_failed: true\n    menu_items:\n      link: true\n      list: false\n    permissions:\n      list: false\n    roles:\n      list: false\n    site_controllers:\n      list: false\n    system_settings:\n      list: false\n    users:\n      list: true\n      keys: true\n    admin:\n      list_instructors: false\n      list_administrators: false\n      list_super_administrators: false\n    course:\n      list_folders: true\n    assignment:\n      list: true\n    questionnaire:\n      list: true\n      create_questionnaire: true\n      edit_questionnaire: true\n      copy_questionnaire: true\n      save_questionnaire: true\n    participants:\n      add_student: true\n      edit_team_members: true\n      list_students: true\n      list_courses: true\n      list_assignments: true\n      change_handle: true\n    institution:\n      list: false\n    student_task:\n      list: true\n    profile:\n      edit: true\n    survey_response:\n      create: true\n      submit: true\n    team:\n      list: true\n      list_assignments: true\n    teams_users:\n      list: true\n    impersonate:\n      start: true\n      impersonate: true\n    review_mapping:\n      list: true\n      add_dynamic_reviewer: true\n      release_reservation: true\n      show_available_submissions: true\n      assign_reviewer_dynamically: true\n      assign_metareviewer_dynamically: true\n    grades:\n      view_my_scores: true\n    survey_deployment:\n      list: true\n    statistics:\n      list_surveys: true\n    tree_display:\n      list: true\n      drill: true\n      goto_questionnaires: true\n      goto_author_feedbacks: true\n      goto_review_rubrics: true\n      goto_global_survey: true\n      goto_surveys: true\n      goto_course_evaluations: true\n      goto_courses: true\n      goto_assignments: true\n      goto_teammate_reviews: true\n      goto_metareview_rubrics: true\n      goto_teammatereview_rubrics: true\n    sign_up_sheet:\n      list: true\n      signup: true\n      delete_signup: true\n    suggestion:\n      create: true\n      new: true\n    leaderboard:\n      index: true\n    advice:\n      edit_advice: true\n      save_advice: true\n    advertise_for_partner:\n      add_advertise_comment: true\n      edit: true\n      new: true\n      remove: true\n      update: true\n    join_team_requests:\n      create: true\n      decline: true\n      destroy: true\n      edit: true\n      index: true\n      new: true\n      show: true\n      update: true\n  controllers:\n    content_pages: false\n    controller_actions: false\n    auth: false\n    markup_styles: false\n    menu_items: false\n    permissions: false\n    roles: false\n    site_controllers: false\n    system_settings: false\n    users: true\n    roles_permissions: false\n    admin: false\n    course: true\n    assignment: true\n    questionnaire: true\n    advice: true\n    participants: true\n    reports: true\n    institution: false\n    student_task: true\n    profile: true\n    survey_response: true\n    team: true\n    teams_users: true\n    impersonate: true\n    import_file: true\n    review_mapping: true\n    grades: true\n    course_evaluation: true\n    participant_choices: true\n    survey_deployment: true\n    statistics: true\n    tree_display: true\n    student_team: true\n    invitation: true\n    survey: true\n    password_retrieval: true\n    submitted_content: true\n    eula: true\n    student_review: true\n    publishing: true\n    export_file: true\n    response: true\n    sign_up_sheet: true\n    suggestion: true\n    leaderboard: true\n    delete_object: true\n    advertise_for_partner: true\n    join_team_requests: true\n  pages:\n    home: true\n    expired: true\n    notfound: true\n    denied: true\n    contact_us: true\n    site_admin: false\n    admin: true\n    credits: true\n:menu: !ruby/object:Menu\n  root: &23 !ruby/object:Menu::Node\n    parent: \n    children:\n    - 1\n    - 3\n    - 4\n    - 5\n    - 6\n    - 7\n  by_id:\n    1: &1 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 8\n      parent_id: \n      name: home\n      id: 1\n      label: Home\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 1\n      url: \"/home\"\n    3: &2 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 19\n      - 20\n      - 21\n      - 22\n      - 23\n      parent_id: \n      name: manage instructor content\n      id: 3\n      label: Manage...\n      site_controller_id: 33\n      controller_action_id: 52\n      content_page_id: \n      url: \"/tree_display/drill\"\n    4: &3 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 18\n      parent_id: \n      name: Survey Deployments\n      id: 4\n      label: Survey Deployments\n      site_controller_id: 31\n      controller_action_id: 49\n      content_page_id: \n      url: \"/survey_deployment/list\"\n    5: &4 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: student_task\n      id: 5\n      label: Assignments\n      site_controller_id: 20\n      controller_action_id: 33\n      content_page_id: \n      url: \"/student_task/list\"\n    6: &5 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: profile\n      id: 6\n      label: Profile\n      site_controller_id: 21\n      controller_action_id: 34\n      content_page_id: \n      url: \"/profile/edit\"\n    7: &6 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 9\n      parent_id: \n      name: contact_us\n      id: 7\n      label: Contact Us\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 5\n      url: \"/contact_us\"\n    8: &7 !ruby/object:Menu::Node\n      parent: \n      parent_id: 1\n      name: leaderboard\n      id: 8\n      label: Leaderboard\n      site_controller_id: 46\n      controller_action_id: 69\n      content_page_id: \n      url: \"/leaderboard/index\"\n    11: &8 !ruby/object:Menu::Node\n      parent: \n      parent_id: 2\n      name: show\n      id: 11\n      label: Show...\n      site_controller_id: 10\n      controller_action_id: 14\n      content_page_id: \n      url: \"/users/list\"\n    19: &9 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/users\n      id: 19\n      label: Users\n      site_controller_id: 10\n      controller_action_id: 14\n      content_page_id: \n      url: \"/users/list\"\n    20: &10 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 24\n      - 25\n      - 26\n      - 27\n      - 28\n      - 29\n      - 30\n      parent_id: 3\n      name: manage/questionnaires\n      id: 20\n      label: Questionnaires\n      site_controller_id: 33\n      controller_action_id: 53\n      content_page_id: \n      url: \"/tree_display/goto_questionnaires\"\n    21: &11 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/courses\n      id: 21\n      label: Courses\n      site_controller_id: 33\n      controller_action_id: 59\n      content_page_id: \n      url: \"/tree_display/goto_courses\"\n    22: &12 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/assignments\n      id: 22\n      label: Assignments\n      site_controller_id: 33\n      controller_action_id: 60\n      content_page_id: \n      url: \"/tree_display/goto_assignments\"\n    23: &13 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: impersonate\n      id: 23\n      label: Impersonate User\n      site_controller_id: 25\n      controller_action_id: 40\n      content_page_id: \n      url: \"/impersonate/start\"\n    18: &14 !ruby/object:Menu::Node\n      parent: \n      parent_id: 4\n      name: Statistical Test\n      id: 18\n      label: Statistical Test\n      site_controller_id: 32\n      controller_action_id: 50\n      content_page_id: \n      url: \"/statistics/list_surveys\"\n    9: &15 !ruby/object:Menu::Node\n      parent: \n      parent_id: 7\n      name: credits\n      id: 9\n      label: Credits &amp; Licence\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 8\n      url: \"/credits\"\n    24: &16 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/review rubrics\n      id: 24\n      label: Review rubrics\n      site_controller_id: 33\n      controller_action_id: 55\n      content_page_id: \n      url: \"/tree_display/goto_review_rubrics\"\n    25: &17 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/metareview rubrics\n      id: 25\n      label: Metareview rubrics\n      site_controller_id: 33\n      controller_action_id: 62\n      content_page_id: \n      url: \"/tree_display/goto_metareview_rubrics\"\n    26: &18 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/teammate review rubrics\n      id: 26\n      label: Teammate review rubrics\n      site_controller_id: 33\n      controller_action_id: 63\n      content_page_id: \n      url: \"/tree_display/goto_teammatereview_rubrics\"\n    27: &19 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/author feedbacks\n      id: 27\n      label: Author feedbacks\n      site_controller_id: 33\n      controller_action_id: 54\n      content_page_id: \n      url: \"/tree_display/goto_author_feedbacks\"\n    28: &20 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/global survey\n      id: 28\n      label: Global survey\n      site_controller_id: 33\n      controller_action_id: 56\n      content_page_id: \n      url: \"/tree_display/goto_global_survey\"\n    29: &21 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/surveys\n      id: 29\n      label: Surveys\n      site_controller_id: 33\n      controller_action_id: 57\n      content_page_id: \n      url: \"/tree_display/goto_surveys\"\n    30: &22 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/course evaluations\n      id: 30\n      label: Course evaluations\n      site_controller_id: 33\n      controller_action_id: 57\n      content_page_id: \n      url: \"/tree_display/goto_surveys\"\n  by_name:\n    home: *1\n    manage instructor content: *2\n    Survey Deployments: *3\n    student_task: *4\n    profile: *5\n    contact_us: *6\n    leaderboard: *7\n    show: *8\n    manage/users: *9\n    manage/questionnaires: *10\n    manage/courses: *11\n    manage/assignments: *12\n    impersonate: *13\n    Statistical Test: *14\n    credits: *15\n    manage/questionnaires/review rubrics: *16\n    manage/questionnaires/metareview rubrics: *17\n    manage/questionnaires/teammate review rubrics: *18\n    manage/questionnaires/author feedbacks: *19\n    manage/questionnaires/global survey: *20\n    manage/questionnaires/surveys: *21\n    manage/questionnaires/course evaluations: *22\n  selected:\n    1: *1\n  vector:\n  - *23\n  - *1\n  crumbs:\n  - 1\n','2015-12-04 19:56:00','2015-12-04 19:57:44'),(5,'Super-Administrator',4,'',NULL,'---\n:credentials: !ruby/object:Credentials\n  role_id: 5\n  updated_at: 2015-12-04 19:57:44.000000000 Z\n  role_ids:\n  - 5\n  - 4\n  - 3\n  - 2\n  - 1\n  permission_ids:\n  - 5\n  - 5\n  - 5\n  - 5\n  - 5\n  - 5\n  - 5\n  - 5\n  - 5\n  - 1\n  - 1\n  - 1\n  - 7\n  - 7\n  - 7\n  - 4\n  - 4\n  - 4\n  - 6\n  - 6\n  - 6\n  - 3\n  - 3\n  - 3\n  - 2\n  - 2\n  - 2\n  actions:\n    content_pages:\n      view_default: true\n      view: true\n      list: true\n    controller_actions:\n      list: true\n    auth:\n      login: true\n      logout: true\n      login_failed: true\n    menu_items:\n      link: true\n      list: true\n    permissions:\n      list: true\n    roles:\n      list: true\n    site_controllers:\n      list: true\n    system_settings:\n      list: true\n    users:\n      list: true\n      keys: true\n    admin:\n      list_instructors: true\n      list_administrators: true\n      list_super_administrators: true\n    course:\n      list_folders: true\n    assignment:\n      list: true\n    questionnaire:\n      list: true\n      create_questionnaire: true\n      edit_questionnaire: true\n      copy_questionnaire: true\n      save_questionnaire: true\n    participants:\n      add_student: true\n      edit_team_members: true\n      list_students: true\n      list_courses: true\n      list_assignments: true\n      change_handle: true\n    institution:\n      list: true\n    student_task:\n      list: true\n    profile:\n      edit: true\n    survey_response:\n      create: true\n      submit: true\n    team:\n      list: true\n      list_assignments: true\n    teams_users:\n      list: true\n    impersonate:\n      start: true\n      impersonate: true\n    review_mapping:\n      list: true\n      add_dynamic_reviewer: true\n      release_reservation: true\n      show_available_submissions: true\n      assign_reviewer_dynamically: true\n      assign_metareviewer_dynamically: true\n    grades:\n      view_my_scores: true\n    survey_deployment:\n      list: true\n    statistics:\n      list_surveys: true\n    tree_display:\n      list: true\n      drill: true\n      goto_questionnaires: true\n      goto_author_feedbacks: true\n      goto_review_rubrics: true\n      goto_global_survey: true\n      goto_surveys: true\n      goto_course_evaluations: true\n      goto_courses: true\n      goto_assignments: true\n      goto_teammate_reviews: true\n      goto_metareview_rubrics: true\n      goto_teammatereview_rubrics: true\n    sign_up_sheet:\n      list: true\n      signup: true\n      delete_signup: true\n    suggestion:\n      create: true\n      new: true\n    leaderboard:\n      index: true\n    advice:\n      edit_advice: true\n      save_advice: true\n    advertise_for_partner:\n      add_advertise_comment: true\n      edit: true\n      new: true\n      remove: true\n      update: true\n    join_team_requests:\n      create: true\n      decline: true\n      destroy: true\n      edit: true\n      index: true\n      new: true\n      show: true\n      update: true\n  controllers:\n    content_pages: true\n    controller_actions: true\n    auth: true\n    markup_styles: true\n    menu_items: true\n    permissions: true\n    roles: true\n    site_controllers: true\n    system_settings: true\n    users: true\n    roles_permissions: true\n    admin: true\n    course: true\n    assignment: true\n    questionnaire: true\n    advice: true\n    participants: true\n    reports: true\n    institution: true\n    student_task: true\n    profile: true\n    survey_response: true\n    team: true\n    teams_users: true\n    impersonate: true\n    import_file: true\n    review_mapping: true\n    grades: true\n    course_evaluation: true\n    participant_choices: true\n    survey_deployment: true\n    statistics: true\n    tree_display: true\n    student_team: true\n    invitation: true\n    survey: true\n    password_retrieval: true\n    submitted_content: true\n    eula: true\n    student_review: true\n    publishing: true\n    export_file: true\n    response: true\n    sign_up_sheet: true\n    suggestion: true\n    leaderboard: true\n    delete_object: true\n    advertise_for_partner: true\n    join_team_requests: true\n  pages:\n    home: true\n    expired: true\n    notfound: true\n    denied: true\n    contact_us: true\n    site_admin: true\n    admin: true\n    credits: true\n:menu: !ruby/object:Menu\n  root: &35 !ruby/object:Menu::Node\n    parent: \n    children:\n    - 1\n    - 2\n    - 3\n    - 4\n    - 5\n    - 6\n    - 7\n  by_id:\n    1: &1 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 8\n      parent_id: \n      name: home\n      id: 1\n      label: Home\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 1\n      url: \"/home\"\n    2: &2 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 10\n      - 11\n      parent_id: \n      name: admin\n      id: 2\n      label: Administration\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 6\n      url: \"/site_admin\"\n    3: &3 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 19\n      - 20\n      - 21\n      - 22\n      - 23\n      parent_id: \n      name: manage instructor content\n      id: 3\n      label: Manage...\n      site_controller_id: 33\n      controller_action_id: 52\n      content_page_id: \n      url: \"/tree_display/drill\"\n    4: &4 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 18\n      parent_id: \n      name: Survey Deployments\n      id: 4\n      label: Survey Deployments\n      site_controller_id: 31\n      controller_action_id: 49\n      content_page_id: \n      url: \"/survey_deployment/list\"\n    5: &5 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: student_task\n      id: 5\n      label: Assignments\n      site_controller_id: 20\n      controller_action_id: 33\n      content_page_id: \n      url: \"/student_task/list\"\n    6: &6 !ruby/object:Menu::Node\n      parent: \n      parent_id: \n      name: profile\n      id: 6\n      label: Profile\n      site_controller_id: 21\n      controller_action_id: 34\n      content_page_id: \n      url: \"/profile/edit\"\n    7: &7 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 9\n      parent_id: \n      name: contact_us\n      id: 7\n      label: Contact Us\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 5\n      url: \"/contact_us\"\n    8: &8 !ruby/object:Menu::Node\n      parent: \n      parent_id: 1\n      name: leaderboard\n      id: 8\n      label: Leaderboard\n      site_controller_id: 46\n      controller_action_id: 69\n      content_page_id: \n      url: \"/leaderboard/index\"\n    10: &9 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 12\n      - 13\n      - 14\n      - 15\n      - 16\n      - 17\n      parent_id: 2\n      name: setup\n      id: 10\n      label: Setup\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 6\n      url: \"/site_admin\"\n    11: &10 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 31\n      - 32\n      - 33\n      - 34\n      parent_id: 2\n      name: show\n      id: 11\n      label: Show...\n      site_controller_id: 10\n      controller_action_id: 14\n      content_page_id: \n      url: \"/users/list\"\n    19: &11 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/users\n      id: 19\n      label: Users\n      site_controller_id: 10\n      controller_action_id: 14\n      content_page_id: \n      url: \"/users/list\"\n    20: &12 !ruby/object:Menu::Node\n      parent: \n      children:\n      - 24\n      - 25\n      - 26\n      - 27\n      - 28\n      - 29\n      - 30\n      parent_id: 3\n      name: manage/questionnaires\n      id: 20\n      label: Questionnaires\n      site_controller_id: 33\n      controller_action_id: 53\n      content_page_id: \n      url: \"/tree_display/goto_questionnaires\"\n    21: &13 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/courses\n      id: 21\n      label: Courses\n      site_controller_id: 33\n      controller_action_id: 59\n      content_page_id: \n      url: \"/tree_display/goto_courses\"\n    22: &14 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: manage/assignments\n      id: 22\n      label: Assignments\n      site_controller_id: 33\n      controller_action_id: 60\n      content_page_id: \n      url: \"/tree_display/goto_assignments\"\n    23: &15 !ruby/object:Menu::Node\n      parent: \n      parent_id: 3\n      name: impersonate\n      id: 23\n      label: Impersonate User\n      site_controller_id: 25\n      controller_action_id: 40\n      content_page_id: \n      url: \"/impersonate/start\"\n    18: &16 !ruby/object:Menu::Node\n      parent: \n      parent_id: 4\n      name: Statistical Test\n      id: 18\n      label: Statistical Test\n      site_controller_id: 32\n      controller_action_id: 50\n      content_page_id: \n      url: \"/statistics/list_surveys\"\n    9: &17 !ruby/object:Menu::Node\n      parent: \n      parent_id: 7\n      name: credits\n      id: 9\n      label: Credits &amp; Licence\n      site_controller_id: \n      controller_action_id: \n      content_page_id: 8\n      url: \"/credits\"\n    12: &18 !ruby/object:Menu::Node\n      parent: \n      parent_id: 10\n      name: setup/roles\n      id: 12\n      label: Roles\n      site_controller_id: 7\n      controller_action_id: 11\n      content_page_id: \n      url: \"/roles/list\"\n    13: &19 !ruby/object:Menu::Node\n      parent: \n      parent_id: 10\n      name: setup/permissions\n      id: 13\n      label: Permissions\n      site_controller_id: 6\n      controller_action_id: 10\n      content_page_id: \n      url: \"/permissions/list\"\n    14: &20 !ruby/object:Menu::Node\n      parent: \n      parent_id: 10\n      name: setup/controllers\n      id: 14\n      label: Controllers / Actions\n      site_controller_id: 8\n      controller_action_id: 12\n      content_page_id: \n      url: \"/site_controllers/list\"\n    15: &21 !ruby/object:Menu::Node\n      parent: \n      parent_id: 10\n      name: setup/pages\n      id: 15\n      label: Content Pages\n      site_controller_id: 1\n      controller_action_id: 3\n      content_page_id: \n      url: \"/content_pages/list\"\n    16: &22 !ruby/object:Menu::Node\n      parent: \n      parent_id: 10\n      name: setup/menus\n      id: 16\n      label: Menu Editor\n      site_controller_id: 5\n      controller_action_id: 9\n      content_page_id: \n      url: \"/menu_items/list\"\n    17: &23 !ruby/object:Menu::Node\n      parent: \n      parent_id: 10\n      name: setup/system_settings\n      id: 17\n      label: System Settings\n      site_controller_id: 9\n      controller_action_id: 13\n      content_page_id: \n      url: \"/system_settings/list\"\n    31: &24 !ruby/object:Menu::Node\n      parent: \n      parent_id: 11\n      name: show/institutions\n      id: 31\n      label: Institutions\n      site_controller_id: 19\n      controller_action_id: 32\n      content_page_id: \n      url: \"/institution/list\"\n    32: &25 !ruby/object:Menu::Node\n      parent: \n      parent_id: 11\n      name: show/super-administrators\n      id: 32\n      label: Super-Administrators\n      site_controller_id: 12\n      controller_action_id: 18\n      content_page_id: \n      url: \"/admin/list_super_administrators\"\n    33: &26 !ruby/object:Menu::Node\n      parent: \n      parent_id: 11\n      name: show/administrators\n      id: 33\n      label: Administrators\n      site_controller_id: 12\n      controller_action_id: 17\n      content_page_id: \n      url: \"/admin/list_administrators\"\n    34: &27 !ruby/object:Menu::Node\n      parent: \n      parent_id: 11\n      name: show/instructors\n      id: 34\n      label: Instructors\n      site_controller_id: 12\n      controller_action_id: 16\n      content_page_id: \n      url: \"/admin/list_instructors\"\n    24: &28 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/review rubrics\n      id: 24\n      label: Review rubrics\n      site_controller_id: 33\n      controller_action_id: 55\n      content_page_id: \n      url: \"/tree_display/goto_review_rubrics\"\n    25: &29 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/metareview rubrics\n      id: 25\n      label: Metareview rubrics\n      site_controller_id: 33\n      controller_action_id: 62\n      content_page_id: \n      url: \"/tree_display/goto_metareview_rubrics\"\n    26: &30 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/teammate review rubrics\n      id: 26\n      label: Teammate review rubrics\n      site_controller_id: 33\n      controller_action_id: 63\n      content_page_id: \n      url: \"/tree_display/goto_teammatereview_rubrics\"\n    27: &31 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/author feedbacks\n      id: 27\n      label: Author feedbacks\n      site_controller_id: 33\n      controller_action_id: 54\n      content_page_id: \n      url: \"/tree_display/goto_author_feedbacks\"\n    28: &32 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/global survey\n      id: 28\n      label: Global survey\n      site_controller_id: 33\n      controller_action_id: 56\n      content_page_id: \n      url: \"/tree_display/goto_global_survey\"\n    29: &33 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/surveys\n      id: 29\n      label: Surveys\n      site_controller_id: 33\n      controller_action_id: 57\n      content_page_id: \n      url: \"/tree_display/goto_surveys\"\n    30: &34 !ruby/object:Menu::Node\n      parent: \n      parent_id: 20\n      name: manage/questionnaires/course evaluations\n      id: 30\n      label: Course evaluations\n      site_controller_id: 33\n      controller_action_id: 57\n      content_page_id: \n      url: \"/tree_display/goto_surveys\"\n  by_name:\n    home: *1\n    admin: *2\n    manage instructor content: *3\n    Survey Deployments: *4\n    student_task: *5\n    profile: *6\n    contact_us: *7\n    leaderboard: *8\n    setup: *9\n    show: *10\n    manage/users: *11\n    manage/questionnaires: *12\n    manage/courses: *13\n    manage/assignments: *14\n    impersonate: *15\n    Statistical Test: *16\n    credits: *17\n    setup/roles: *18\n    setup/permissions: *19\n    setup/controllers: *20\n    setup/pages: *21\n    setup/menus: *22\n    setup/system_settings: *23\n    show/institutions: *24\n    show/super-administrators: *25\n    show/administrators: *26\n    show/instructors: *27\n    manage/questionnaires/review rubrics: *28\n    manage/questionnaires/metareview rubrics: *29\n    manage/questionnaires/teammate review rubrics: *30\n    manage/questionnaires/author feedbacks: *31\n    manage/questionnaires/global survey: *32\n    manage/questionnaires/surveys: *33\n    manage/questionnaires/course evaluations: *34\n  selected:\n    1: *1\n  vector:\n  - *35\n  - *1\n  crumbs:\n  - 1\n','2015-12-04 19:56:00','2015-12-04 19:57:44');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles_permissions`
--

DROP TABLE IF EXISTS `roles_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL DEFAULT '0',
  `permission_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_roles_permission_permission_id` (`permission_id`) USING BTREE,
  KEY `fk_roles_permission_role_id` (`role_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles_permissions`
--

LOCK TABLES `roles_permissions` WRITE;
/*!40000 ALTER TABLE `roles_permissions` DISABLE KEYS */;
INSERT INTO `roles_permissions` VALUES (1,1,2),(2,1,3),(3,1,6),(4,3,5),(5,4,5),(6,5,1),(7,5,4),(8,5,5),(9,5,7),(10,1,2),(11,1,3),(12,1,6),(13,3,5),(14,4,5),(15,5,1),(16,5,4),(17,5,5),(18,5,7),(19,1,2),(20,1,3),(21,1,6),(22,3,5),(23,4,5),(24,5,1),(25,5,4),(26,5,5),(27,5,7);
/*!40000 ALTER TABLE `roles_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('0'),('1'),('10'),('100'),('101'),('102'),('103'),('104'),('105'),('106'),('107'),('108'),('109'),('11'),('110'),('111'),('112'),('113'),('114'),('115'),('116'),('117'),('118'),('119'),('12'),('120'),('121'),('122'),('123'),('124'),('125'),('126'),('127'),('128'),('129'),('13'),('130'),('131'),('132'),('133'),('134'),('135'),('136'),('14'),('15'),('16'),('17'),('18'),('19'),('2'),('20'),('20100920141223'),('20101001183244'),('20101018010541'),('20101018010542'),('20101116184601'),('20101116184602'),('20101117031216'),('20101128192024'),('20101205034327'),('20101214034327'),('20101222143748'),('20110205220301'),('20110210160753'),('20110304054311'),('20110323134426'),('20110324001445'),('20110407154154'),('20110408190423'),('20110410232719'),('20110512155258'),('20111023025047'),('20111025015938'),('20111101035638'),('20111122004351'),('20111122004447'),('20111124232053'),('20111127035024'),('20111127035200'),('20111129204549'),('20111129215405'),('20111129232252'),('20111130205809'),('20111130230523'),('20111201222103'),('20111202011414'),('20111217162506'),('20120619041353'),('20120829054506'),('20121018001330'),('20121019201555'),('20121116074455'),('20121116081903'),('20121116153522'),('20121116154051'),('20121116154318'),('20121116154625'),('20121116154802'),('20121124073045'),('20121127013927'),('20121128235814'),('20121204121644'),('20121208064006'),('20130403182858'),('20130418214537'),('20130418215246'),('20130606204315'),('20130724031046'),('20130730143615'),('20130827132007'),('20130905183106'),('20130916224736'),('20130930021106'),('20131029020318'),('20131103014327'),('20131112015730'),('20131112015931'),('20131112020041'),('20131112020128'),('20131112020213'),('20131112020248'),('20131112020403'),('20131112020440'),('20131112020506'),('20131112020534'),('20131117022304'),('20131117022508'),('20131120032234'),('20131122223434'),('20131123213736'),('20131124173014'),('20131124173146'),('20131124173225'),('20131124173258'),('20131124180730'),('20131124180940'),('20131124181007'),('20131124181037'),('20131201162327'),('20131201172300'),('20131201172400'),('20131201172600'),('20131201172700'),('20131201175200'),('20131203051315'),('20131205154647'),('20131205185858'),('20131205203433'),('20131206231914'),('20140321025833'),('20140331120322'),('20140808212437'),('20141111010259'),('20141126144930'),('20141203001749'),('20141204002000'),('20141204012100'),('20141204022200'),('20150105163040'),('20150105172921'),('20150106104625'),('20150424014221'),('20150507030527'),('20150515220601'),('20150526210708'),('20150526225814'),('20150527105416'),('20150527185412'),('20150702170648'),('20150714012523'),('20150714024954'),('20150714162923'),('20150717141742'),('20150720160445'),('20150721174405'),('20150722161550'),('20150725034036'),('20150726191229'),('20150727153308'),('20150729051150'),('20150729151749'),('20150729153252'),('20150730141035'),('20150730210515'),('20150802171710'),('20150804033946'),('20150804041459'),('20150804053945'),('20150805211012'),('20150805220759'),('20150805230305'),('20150806000053'),('20150809200412'),('20150812013456'),('20150812150214'),('20150812185955'),('20150812190750'),('20150827170101'),('20151011201717'),('20151021142107'),('21'),('22'),('23'),('24'),('25'),('26'),('27'),('28'),('29'),('3'),('30'),('31'),('32'),('33'),('34'),('35'),('36'),('37'),('38'),('39'),('4'),('40'),('41'),('42'),('43'),('44'),('45'),('46'),('47'),('48'),('49'),('5'),('50'),('51'),('52'),('53'),('54'),('55'),('56'),('57'),('58'),('59'),('6'),('60'),('61'),('62'),('63'),('64'),('65'),('66'),('67'),('68'),('69'),('7'),('70'),('71'),('72'),('73'),('74'),('75'),('76'),('77'),('78'),('79'),('8'),('80'),('81'),('82'),('83'),('84'),('85'),('86'),('87'),('88'),('89'),('9'),('90'),('91'),('92'),('93'),('94'),('95'),('96'),('97'),('98'),('99');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `score_views`
--

DROP TABLE IF EXISTS `score_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `score_views` (
  `question_weight` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `q1_id` int(11) DEFAULT '0',
  `q1_name` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `q1_instructor_id` int(11) DEFAULT '0',
  `q1_private` tinyint(1) DEFAULT '0',
  `q1_min_question_score` int(11) DEFAULT '0',
  `q1_max_question_score` int(11) DEFAULT NULL,
  `q1_created_at` datetime DEFAULT NULL,
  `q1_updated_at` datetime DEFAULT NULL,
  `q1_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `q1_display_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ques_id` int(11) NOT NULL DEFAULT '0',
  `ques_questionnaire_id` int(11) DEFAULT NULL,
  `s_id` int(11) DEFAULT '0',
  `s_question_id` int(11) DEFAULT '0',
  `s_score` int(11) DEFAULT NULL,
  `s_comments` text COLLATE utf8_unicode_ci,
  `s_response_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `score_views`
--

LOCK TABLES `score_views` WRITE;
/*!40000 ALTER TABLE `score_views` DISABLE KEYS */;
/*!40000 ALTER TABLE `score_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `desc_text` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections`
--

LOCK TABLES `sections` WRITE;
/*!40000 ALTER TABLE `sections` DISABLE KEYS */;
/*!40000 ALTER TABLE `sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `data` mediumtext COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`) USING BTREE,
  KEY `index_sessions_on_updated_at` (`updated_at`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (1,'81cae4058025a49c6bbd8a0e444a3d7e','BAh7EEkiEF9jc3JmX3Rva2VuBjoGRUZJIjE3ejE4bDFhVitINnZ4MFlWMERI\nSVEycnJKeUhZR0hNTjNvdTFwRXRZNzQ4PQY7AEZJIg5yZXR1cm5fdG8GOwBG\nSSI9aHR0cDovL2xvY2FsaG9zdDozMDAwL3NpZ25fdXBfc2hlZXQvbGlzdD9h\nc3NpZ25tZW50X2lkPTEGOwBUSSIVdXNlcl9jcmVkZW50aWFscwY7AEZJIgGA\nY2FjYzhjOWM3NzdlNjdkNDRlMmFiNDdkOGI1ZjliMjJmZjc3ZDcwOGRlMDNl\nZjcyZWQ0NzIzMGZkNTBiYWRjODFiYWVlMzVlOWQzN2YwZWM3NTQ5MTY4MzJi\nMWQxN2Y1ZDQzM2JjNTMyNTc0YjRkYTIyMDZhZjRkZDdkNjc4OTcGOwBUSSIY\ndXNlcl9jcmVkZW50aWFsc19pZAY7AEZpB0kiEmxhc3Rfb3Blbl90YWIGOwBG\nSSIGMgY7AFRJIgpjbGVhcgY7AEZUSSIJdXNlcgY7AEZvOglVc2VyEjoQQGF0\ndHJpYnV0ZXNvOh9BY3RpdmVSZWNvcmQ6OkF0dHJpYnV0ZVNldAY7B286JEFj\ndGl2ZVJlY29yZDo6TGF6eUF0dHJpYnV0ZUhhc2gKOgtAdHlwZXN9G0kiB2lk\nBjsAVG86IEFjdGl2ZVJlY29yZDo6VHlwZTo6SW50ZWdlcgk6D0BwcmVjaXNp\nb24wOgtAc2NhbGUwOgtAbGltaXRpCToLQHJhbmdlbzoKUmFuZ2UIOglleGNs\nVDoKYmVnaW5sLQcAAACAOghlbmRsKwcAAACASSIJbmFtZQY7AFRvOkhBY3Rp\ndmVSZWNvcmQ6OkNvbm5lY3Rpb25BZGFwdGVyczo6QWJzdHJhY3RNeXNxbEFk\nYXB0ZXI6Ok15c3FsU3RyaW5nCDsMMDsNMDsOaQH/SSIVY3J5cHRlZF9wYXNz\nd29yZAY7AFRvOxQIOwwwOw0wOw5pLUkiDHJvbGVfaWQGOwBUQBZJIhJwYXNz\nd29yZF9zYWx0BjsAVEAbSSINZnVsbG5hbWUGOwBUQBtJIgplbWFpbAY7AFRA\nG0kiDnBhcmVudF9pZAY7AFRAFkkiF3ByaXZhdGVfYnlfZGVmYXVsdAY7AFRv\nOiBBY3RpdmVSZWNvcmQ6OlR5cGU6OkJvb2xlYW4IOwwwOw0wOw5pBkkiF21y\ndV9kaXJlY3RvcnlfcGF0aAY7AFRvOxQIOwwwOw0wOw5pAYBJIhRlbWFpbF9v\nbl9yZXZpZXcGOwBUQCRJIhhlbWFpbF9vbl9zdWJtaXNzaW9uBjsAVEAkSSIe\nZW1haWxfb25fcmV2aWV3X29mX3JldmlldwY7AFRAJEkiEGlzX25ld191c2Vy\nBjsAVEAkSSIebWFzdGVyX3Blcm1pc3Npb25fZ3JhbnRlZAY7AFRvOwsJOwww\nOw0wOw5pBjsPbzsQCDsRVDsSaf+AOxNpAYBJIgtoYW5kbGUGOwBUQBtJIhhs\nZWFkZXJib2FyZF9wcml2YWN5BjsAVEAkSSIYZGlnaXRhbF9jZXJ0aWZpY2F0\nZQY7AFRvOh1BY3RpdmVSZWNvcmQ6OlR5cGU6OlRleHQIOwwwOw0wOw5pAv//\nSSIWcGVyc2lzdGVuY2VfdG9rZW4GOwBUQBtJIhF0aW1lem9uZXByZWYGOwBU\nQBtJIg9wdWJsaWNfa2V5BjsAVEAxSSITY29weV9vZl9lbWFpbHMGOwBUQCRv\nOh5BY3RpdmVSZWNvcmQ6OlR5cGU6OlZhbHVlCDsMMDsNMDsOMDoMQHZhbHVl\nc3sbSSIHaWQGOwBUaQtJIgluYW1lBjsAVEkiDXN0dWRlbnQ1BjsAVEkiFWNy\neXB0ZWRfcGFzc3dvcmQGOwBUSSItY2Y4NjUyZDk3M2FlMGUxMTFiZDllZjA3\nZDlmZWVjMmNhZmFjZGUxZQY7AFRJIgxyb2xlX2lkBjsAVGkGSSIScGFzc3dv\ncmRfc2FsdAY7AFRJIhhrektTUURSSXJuTnVKbE9VZEx4BjsAVEkiDWZ1bGxu\nYW1lBjsAVEkiElN0dWRlbnQsIEZpdmUGOwBUSSIKZW1haWwGOwBUSSIWc3R1\nZGVudDVAbmNzdS5lZHUGOwBUSSIOcGFyZW50X2lkBjsAVGkGSSIXcHJpdmF0\nZV9ieV9kZWZhdWx0BjsAVGkASSIXbXJ1X2RpcmVjdG9yeV9wYXRoBjsAVDBJ\nIhRlbWFpbF9vbl9yZXZpZXcGOwBUMEkiGGVtYWlsX29uX3N1Ym1pc3Npb24G\nOwBUMEkiHmVtYWlsX29uX3Jldmlld19vZl9yZXZpZXcGOwBUMEkiEGlzX25l\nd191c2VyBjsAVGkASSIebWFzdGVyX3Blcm1pc3Npb25fZ3JhbnRlZAY7AFRp\nAEkiC2hhbmRsZQY7AFQwSSIYbGVhZGVyYm9hcmRfcHJpdmFjeQY7AFRpAEki\nGGRpZ2l0YWxfY2VydGlmaWNhdGUGOwBUMEkiFnBlcnNpc3RlbmNlX3Rva2Vu\nBjsAVEkiAYBkMGM3ZDgzMDlkZWQ3MjhiZGE5MzE3OWM4MDEzZGUzY2M3NDJl\nYTBlODI2MmEyNTFhMzE5NDU2MWFmODgxYWUzZDY0YjRjMjlmZTMxZjU5YjZi\nYzNhMjI2Y2UzMGU2MWJlY2RiMTAzYmVlZWE0NDQ0MDVjZGZhZTYzOWM0NmI1\nOQY7AFRJIhF0aW1lem9uZXByZWYGOwBUSSIfRWFzdGVybiBUaW1lIChVUyAm\nIENhbmFkYSkGOwBUSSIPcHVibGljX2tleQY7AFQwSSITY29weV9vZl9lbWFp\nbHMGOwBUaQA6FkBhZGRpdGlvbmFsX3R5cGVzewA6EkBtYXRlcmlhbGl6ZWRG\nOhNAZGVsZWdhdGVfaGFzaHsJSSIRdGltZXpvbmVwcmVmBjsAVG86KkFjdGl2\nZVJlY29yZDo6QXR0cmlidXRlOjpGcm9tRGF0YWJhc2UJOgpAbmFtZUkiEXRp\nbWV6b25lcHJlZgY7AFQ6HEB2YWx1ZV9iZWZvcmVfdHlwZV9jYXN0QFI6CkB0\neXBlQBs6C0B2YWx1ZUkiH0Vhc3Rlcm4gVGltZSAoVVMgJiBDYW5hZGEpBjsA\nVEkiB2lkBjsARm87HAk7HUkiB2lkBjsARjseaQs7H0AWOyBpC0kiDHJvbGVf\naWQGOwBGbzscCTsdSSIMcm9sZV9pZAY7AEY7HmkGOx9AFjsgaQZJIgluYW1l\nBjsAVG87HAk7HUkiCW5hbWUGOwBUOx5AOjsfQBs7IEkiDXN0dWRlbnQ1BjsA\nVDoXQGFnZ3JlZ2F0aW9uX2NhY2hlewA6F0Bhc3NvY2lhdGlvbl9jYWNoZXsG\nOglyb2xlVTo1QWN0aXZlUmVjb3JkOjpBc3NvY2lhdGlvbnM6OkJlbG9uZ3NU\nb0Fzc29jaWF0aW9uWwc7I1sMWwc6C0Bvd25lckARWwc6DEBsb2FkZWRUWwc6\nDEB0YXJnZXRvOglSb2xlEjsHbzsIBjsHbzsJCjsKfQ1JIgdpZAY7AFRvOwsJ\nOwwwOw0wOw5pCTsPbzsQCDsRVDsSbC0HAAAAgDsTbCsHAAAAgEkiCW5hbWUG\nOwBUbzsUCDsMMDsNMDsOaQH/SSIOcGFyZW50X2lkBjsAVEBySSIQZGVzY3Jp\ncHRpb24GOwBUQHdJIhRkZWZhdWx0X3BhZ2VfaWQGOwBUQHJJIgpjYWNoZQY7\nAFRVOiNBY3RpdmVSZWNvcmQ6OlR5cGU6OlNlcmlhbGl6ZWRbCToLX192Ml9f\nWwc6DUBzdWJ0eXBlOgtAY29kZXJbB287Fgg7DDA7DTA7DmkC//9vOiVBY3Rp\ndmVSZWNvcmQ6OkNvZGVyczo6WUFNTENvbHVtbgY6EkBvYmplY3RfY2xhc3Nj\nC09iamVjdEABe0kiD2NyZWF0ZWRfYXQGOwBUVTpKQWN0aXZlUmVjb3JkOjpB\ndHRyaWJ1dGVNZXRob2RzOjpUaW1lWm9uZUNvbnZlcnNpb246OlRpbWVab25l\nQ29udmVydGVyWwk7KlsAWwBvOkpBY3RpdmVSZWNvcmQ6OkNvbm5lY3Rpb25B\nZGFwdGVyczo6QWJzdHJhY3RNeXNxbEFkYXB0ZXI6Ok15c3FsRGF0ZVRpbWUI\nOwwwOw0wOw4wSSIPdXBkYXRlZF9hdAY7AFRVOy9bCTsqWwBbAEABg287Fwg7\nDDA7DTA7DjA7GHsNSSIHaWQGOwBUaQZJIgluYW1lBjsAVEkiDFN0dWRlbnQG\nOwBUSSIOcGFyZW50X2lkBjsAVDBJIhBkZXNjcmlwdGlvbgY7AFRJIgAGOwBU\nSSIUZGVmYXVsdF9wYWdlX2lkBjsAVDBJIgpjYWNoZQY7AFRJIgLWFi0tLQo6\nY3JlZGVudGlhbHM6ICFydWJ5L29iamVjdDpDcmVkZW50aWFscwogIHJvbGVf\naWQ6IDEKICB1cGRhdGVkX2F0OiAyMDE1LTEyLTA0IDE5OjU3OjQzLjAwMDAw\nMDAwMCBaCiAgcm9sZV9pZHM6CiAgLSAxCiAgcGVybWlzc2lvbl9pZHM6CiAg\nLSA2CiAgLSA2CiAgLSA2CiAgLSAzCiAgLSAzCiAgLSAzCiAgLSAyCiAgLSAy\nCiAgLSAyCiAgYWN0aW9uczoKICAgIGNvbnRlbnRfcGFnZXM6CiAgICAgIHZp\nZXdfZGVmYXVsdDogdHJ1ZQogICAgICB2aWV3OiB0cnVlCiAgICAgIGxpc3Q6\nIGZhbHNlCiAgICBjb250cm9sbGVyX2FjdGlvbnM6CiAgICAgIGxpc3Q6IGZh\nbHNlCiAgICBhdXRoOgogICAgICBsb2dpbjogdHJ1ZQogICAgICBsb2dvdXQ6\nIHRydWUKICAgICAgbG9naW5fZmFpbGVkOiB0cnVlCiAgICBtZW51X2l0ZW1z\nOgogICAgICBsaW5rOiB0cnVlCiAgICAgIGxpc3Q6IGZhbHNlCiAgICBwZXJt\naXNzaW9uczoKICAgICAgbGlzdDogZmFsc2UKICAgIHJvbGVzOgogICAgICBs\naXN0OiBmYWxzZQogICAgc2l0ZV9jb250cm9sbGVyczoKICAgICAgbGlzdDog\nZmFsc2UKICAgIHN5c3RlbV9zZXR0aW5nczoKICAgICAgbGlzdDogZmFsc2UK\nICAgIHVzZXJzOgogICAgICBsaXN0OiBmYWxzZQogICAgICBrZXlzOiB0cnVl\nCiAgICBhZG1pbjoKICAgICAgbGlzdF9pbnN0cnVjdG9yczogZmFsc2UKICAg\nICAgbGlzdF9hZG1pbmlzdHJhdG9yczogZmFsc2UKICAgICAgbGlzdF9zdXBl\ncl9hZG1pbmlzdHJhdG9yczogZmFsc2UKICAgIGNvdXJzZToKICAgICAgbGlz\ndF9mb2xkZXJzOiBmYWxzZQogICAgYXNzaWdubWVudDoKICAgICAgbGlzdDog\nZmFsc2UKICAgIHF1ZXN0aW9ubmFpcmU6CiAgICAgIGxpc3Q6IGZhbHNlCiAg\nICAgIGNyZWF0ZV9xdWVzdGlvbm5haXJlOiBmYWxzZQogICAgICBlZGl0X3F1\nZXN0aW9ubmFpcmU6IGZhbHNlCiAgICAgIGNvcHlfcXVlc3Rpb25uYWlyZTog\nZmFsc2UKICAgICAgc2F2ZV9xdWVzdGlvbm5haXJlOiBmYWxzZQogICAgcGFy\ndGljaXBhbnRzOgogICAgICBhZGRfc3R1ZGVudDogZmFsc2UKICAgICAgZWRp\ndF90ZWFtX21lbWJlcnM6IGZhbHNlCiAgICAgIGxpc3Rfc3R1ZGVudHM6IGZh\nbHNlCiAgICAgIGxpc3RfY291cnNlczogZmFsc2UKICAgICAgbGlzdF9hc3Np\nZ25tZW50czogZmFsc2UKICAgICAgY2hhbmdlX2hhbmRsZTogdHJ1ZQogICAg\naW5zdGl0dXRpb246CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBzdHVkZW50X3Rh\nc2s6CiAgICAgIGxpc3Q6IHRydWUKICAgIHByb2ZpbGU6CiAgICAgIGVkaXQ6\nIHRydWUKICAgIHN1cnZleV9yZXNwb25zZToKICAgICAgY3JlYXRlOiB0cnVl\nCiAgICAgIHN1Ym1pdDogdHJ1ZQogICAgdGVhbToKICAgICAgbGlzdDogZmFs\nc2UKICAgICAgbGlzdF9hc3NpZ25tZW50czogZmFsc2UKICAgIHRlYW1zX3Vz\nZXJzOgogICAgICBsaXN0OiBmYWxzZQogICAgaW1wZXJzb25hdGU6CiAgICAg\nIHN0YXJ0OiBmYWxzZQogICAgICBpbXBlcnNvbmF0ZTogdHJ1ZQogICAgcmV2\naWV3X21hcHBpbmc6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICAgIGFkZF9keW5h\nbWljX3Jldmlld2VyOiB0cnVlCiAgICAgIHJlbGVhc2VfcmVzZXJ2YXRpb246\nIHRydWUKICAgICAgc2hvd19hdmFpbGFibGVfc3VibWlzc2lvbnM6IHRydWUK\nICAgICAgYXNzaWduX3Jldmlld2VyX2R5bmFtaWNhbGx5OiB0cnVlCiAgICAg\nIGFzc2lnbl9tZXRhcmV2aWV3ZXJfZHluYW1pY2FsbHk6IHRydWUKICAgIGdy\nYWRlczoKICAgICAgdmlld19teV9zY29yZXM6IHRydWUKICAgIHN1cnZleV9k\nZXBsb3ltZW50OgogICAgICBsaXN0OiBmYWxzZQogICAgc3RhdGlzdGljczoK\nICAgICAgbGlzdF9zdXJ2ZXlzOiBmYWxzZQogICAgdHJlZV9kaXNwbGF5Ogog\nICAgICBsaXN0OiBmYWxzZQogICAgICBkcmlsbDogZmFsc2UKICAgICAgZ290\nb19xdWVzdGlvbm5haXJlczogZmFsc2UKICAgICAgZ290b19hdXRob3JfZmVl\nZGJhY2tzOiBmYWxzZQogICAgICBnb3RvX3Jldmlld19ydWJyaWNzOiBmYWxz\nZQogICAgICBnb3RvX2dsb2JhbF9zdXJ2ZXk6IGZhbHNlCiAgICAgIGdvdG9f\nc3VydmV5czogZmFsc2UKICAgICAgZ290b19jb3Vyc2VfZXZhbHVhdGlvbnM6\nIGZhbHNlCiAgICAgIGdvdG9fY291cnNlczogZmFsc2UKICAgICAgZ290b19h\nc3NpZ25tZW50czogZmFsc2UKICAgICAgZ290b190ZWFtbWF0ZV9yZXZpZXdz\nOiBmYWxzZQogICAgICBnb3RvX21ldGFyZXZpZXdfcnVicmljczogZmFsc2UK\nICAgICAgZ290b190ZWFtbWF0ZXJldmlld19ydWJyaWNzOiBmYWxzZQogICAg\nc2lnbl91cF9zaGVldDoKICAgICAgbGlzdDogdHJ1ZQogICAgICBzaWdudXA6\nIHRydWUKICAgICAgZGVsZXRlX3NpZ251cDogdHJ1ZQogICAgc3VnZ2VzdGlv\nbjoKICAgICAgY3JlYXRlOiB0cnVlCiAgICAgIG5ldzogdHJ1ZQogICAgbGVh\nZGVyYm9hcmQ6CiAgICAgIGluZGV4OiB0cnVlCiAgICBhZHZpY2U6CiAgICAg\nIGVkaXRfYWR2aWNlOiBmYWxzZQogICAgICBzYXZlX2FkdmljZTogZmFsc2UK\nICAgIGFkdmVydGlzZV9mb3JfcGFydG5lcjoKICAgICAgYWRkX2FkdmVydGlz\nZV9jb21tZW50OiB0cnVlCiAgICAgIGVkaXQ6IHRydWUKICAgICAgbmV3OiB0\ncnVlCiAgICAgIHJlbW92ZTogdHJ1ZQogICAgICB1cGRhdGU6IHRydWUKICAg\nIGpvaW5fdGVhbV9yZXF1ZXN0czoKICAgICAgY3JlYXRlOiB0cnVlCiAgICAg\nIGRlY2xpbmU6IHRydWUKICAgICAgZGVzdHJveTogdHJ1ZQogICAgICBlZGl0\nOiB0cnVlCiAgICAgIGluZGV4OiB0cnVlCiAgICAgIG5ldzogdHJ1ZQogICAg\nICBzaG93OiB0cnVlCiAgICAgIHVwZGF0ZTogdHJ1ZQogIGNvbnRyb2xsZXJz\nOgogICAgY29udGVudF9wYWdlczogZmFsc2UKICAgIGNvbnRyb2xsZXJfYWN0\naW9uczogZmFsc2UKICAgIGF1dGg6IGZhbHNlCiAgICBtYXJrdXBfc3R5bGVz\nOiBmYWxzZQogICAgbWVudV9pdGVtczogZmFsc2UKICAgIHBlcm1pc3Npb25z\nOiBmYWxzZQogICAgcm9sZXM6IGZhbHNlCiAgICBzaXRlX2NvbnRyb2xsZXJz\nOiBmYWxzZQogICAgc3lzdGVtX3NldHRpbmdzOiBmYWxzZQogICAgdXNlcnM6\nIHRydWUKICAgIHJvbGVzX3Blcm1pc3Npb25zOiBmYWxzZQogICAgYWRtaW46\nIGZhbHNlCiAgICBjb3Vyc2U6IGZhbHNlCiAgICBhc3NpZ25tZW50OiBmYWxz\nZQogICAgcXVlc3Rpb25uYWlyZTogZmFsc2UKICAgIGFkdmljZTogZmFsc2UK\nICAgIHBhcnRpY2lwYW50czogZmFsc2UKICAgIHJlcG9ydHM6IHRydWUKICAg\nIGluc3RpdHV0aW9uOiBmYWxzZQogICAgc3R1ZGVudF90YXNrOiB0cnVlCiAg\nICBwcm9maWxlOiB0cnVlCiAgICBzdXJ2ZXlfcmVzcG9uc2U6IHRydWUKICAg\nIHRlYW06IGZhbHNlCiAgICB0ZWFtc191c2VyczogZmFsc2UKICAgIGltcGVy\nc29uYXRlOiBmYWxzZQogICAgaW1wb3J0X2ZpbGU6IGZhbHNlCiAgICByZXZp\nZXdfbWFwcGluZzogZmFsc2UKICAgIGdyYWRlczogZmFsc2UKICAgIGNvdXJz\nZV9ldmFsdWF0aW9uOiB0cnVlCiAgICBwYXJ0aWNpcGFudF9jaG9pY2VzOiBm\nYWxzZQogICAgc3VydmV5X2RlcGxveW1lbnQ6IGZhbHNlCiAgICBzdGF0aXN0\naWNzOiBmYWxzZQogICAgdHJlZV9kaXNwbGF5OiBmYWxzZQogICAgc3R1ZGVu\ndF90ZWFtOiB0cnVlCiAgICBpbnZpdGF0aW9uOiB0cnVlCiAgICBzdXJ2ZXk6\nIGZhbHNlCiAgICBwYXNzd29yZF9yZXRyaWV2YWw6IHRydWUKICAgIHN1Ym1p\ndHRlZF9jb250ZW50OiB0cnVlCiAgICBldWxhOiB0cnVlCiAgICBzdHVkZW50\nX3JldmlldzogdHJ1ZQogICAgcHVibGlzaGluZzogdHJ1ZQogICAgZXhwb3J0\nX2ZpbGU6IGZhbHNlCiAgICByZXNwb25zZTogdHJ1ZQogICAgc2lnbl91cF9z\naGVldDogZmFsc2UKICAgIHN1Z2dlc3Rpb246IGZhbHNlCiAgICBsZWFkZXJi\nb2FyZDogdHJ1ZQogICAgZGVsZXRlX29iamVjdDogZmFsc2UKICAgIGFkdmVy\ndGlzZV9mb3JfcGFydG5lcjogdHJ1ZQogICAgam9pbl90ZWFtX3JlcXVlc3Rz\nOiB0cnVlCiAgcGFnZXM6CiAgICBob21lOiB0cnVlCiAgICBleHBpcmVkOiB0\ncnVlCiAgICBub3Rmb3VuZDogdHJ1ZQogICAgZGVuaWVkOiB0cnVlCiAgICBj\nb250YWN0X3VzOiB0cnVlCiAgICBzaXRlX2FkbWluOiBmYWxzZQogICAgYWRt\naW46IGZhbHNlCiAgICBjcmVkaXRzOiB0cnVlCjptZW51OiAhcnVieS9vYmpl\nY3Q6TWVudQogIHJvb3Q6ICY3ICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAg\nICBwYXJlbnQ6IAogICAgY2hpbGRyZW46CiAgICAtIDEKICAgIC0gNQogICAg\nLSA2CiAgICAtIDcKICBieV9pZDoKICAgIDE6ICYxICFydWJ5L29iamVjdDpN\nZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIGNoaWxkcmVuOgogICAg\nICAtIDgKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTogaG9tZQogICAg\nICBpZDogMQogICAgICBsYWJlbDogSG9tZQogICAgICBzaXRlX2NvbnRyb2xs\nZXJfaWQ6IAogICAgICBjb250cm9sbGVyX2FjdGlvbl9pZDogCiAgICAgIGNv\nbnRlbnRfcGFnZV9pZDogMQogICAgICB1cmw6ICIvaG9tZSIKICAgIDU6ICYy\nICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAg\nIHBhcmVudF9pZDogCiAgICAgIG5hbWU6IHN0dWRlbnRfdGFzawogICAgICBp\nZDogNQogICAgICBsYWJlbDogQXNzaWdubWVudHMKICAgICAgc2l0ZV9jb250\ncm9sbGVyX2lkOiAyMAogICAgICBjb250cm9sbGVyX2FjdGlvbl9pZDogMzMK\nICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAiL3N0dWRlbnRf\ndGFzay9saXN0IgogICAgNjogJjMgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUK\nICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTog\ncHJvZmlsZQogICAgICBpZDogNgogICAgICBsYWJlbDogUHJvZmlsZQogICAg\nICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDIxCiAgICAgIGNvbnRyb2xsZXJfYWN0\naW9uX2lkOiAzNAogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6\nICIvcHJvZmlsZS9lZGl0IgogICAgNzogJjQgIXJ1Ynkvb2JqZWN0Ok1lbnU6\nOk5vZGUKICAgICAgcGFyZW50OiAKICAgICAgY2hpbGRyZW46CiAgICAgIC0g\nOQogICAgICBwYXJlbnRfaWQ6IAogICAgICBuYW1lOiBjb250YWN0X3VzCiAg\nICAgIGlkOiA3CiAgICAgIGxhYmVsOiBDb250YWN0IFVzCiAgICAgIHNpdGVf\nY29udHJvbGxlcl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAK\nICAgICAgY29udGVudF9wYWdlX2lkOiA1CiAgICAgIHVybDogIi9jb250YWN0\nX3VzIgogICAgODogJjUgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAg\ncGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAxCiAgICAgIG5hbWU6IGxlYWRl\ncmJvYXJkCiAgICAgIGlkOiA4CiAgICAgIGxhYmVsOiBMZWFkZXJib2FyZAog\nICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDQ2CiAgICAgIGNvbnRyb2xsZXJf\nYWN0aW9uX2lkOiA2OQogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1\ncmw6ICIvbGVhZGVyYm9hcmQvaW5kZXgiCiAgICA5OiAmNiAhcnVieS9vYmpl\nY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6\nIDcKICAgICAgbmFtZTogY3JlZGl0cwogICAgICBpZDogOQogICAgICBsYWJl\nbDogQ3JlZGl0cyAmYW1wOyBMaWNlbmNlCiAgICAgIHNpdGVfY29udHJvbGxl\ncl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAKICAgICAgY29u\ndGVudF9wYWdlX2lkOiA4CiAgICAgIHVybDogIi9jcmVkaXRzIgogIGJ5X25h\nbWU6CiAgICBob21lOiAqMQogICAgc3R1ZGVudF90YXNrOiAqMgogICAgcHJv\nZmlsZTogKjMKICAgIGNvbnRhY3RfdXM6ICo0CiAgICBsZWFkZXJib2FyZDog\nKjUKICAgIGNyZWRpdHM6ICo2CiAgc2VsZWN0ZWQ6CiAgICAxOiAqMQogIHZl\nY3RvcjoKICAtICo3CiAgLSAqMQogIGNydW1iczoKICAtIDEKBjsAVEkiD2Ny\nZWF0ZWRfYXQGOwBUSXU6CVRpbWUNk+wcwAAAAOAGOgl6b25lSSIIVVRDBjsA\nRkkiD3VwZGF0ZWRfYXQGOwBUSXU7MQ2T7BzAAADA5gY7MkkiCFVUQwY7AEY7\nGXsAOxpGOxt7BkkiCW5hbWUGOwBUbzscCTsdQGM7HkABjTsfQHc7IEkiDFN0\ndWRlbnQGOwBUOyF7ADsiewA6DkByZWFkb25seUY6D0BkZXN0cm95ZWRGOhxA\nbWFya2VkX2Zvcl9kZXN0cnVjdGlvbkY6HkBkZXN0cm95ZWRfYnlfYXNzb2Np\nYXRpb24wOhBAbmV3X3JlY29yZEY6CUB0eG4wOh5AX3N0YXJ0X3RyYW5zYWN0\naW9uX3N0YXRlewA6F0B0cmFuc2FjdGlvbl9zdGF0ZTA6FEByZWZsZWN0c19z\ndGF0ZVsGRjodQG1hc3NfYXNzaWdubWVudF9vcHRpb25zMFsHOhFAc3RhbGVf\nc3RhdGVJIgYxBjsARlsHOg5AaW52ZXJzZWRGWwc6DUB1cGRhdGVkRlsHOhdA\nYXNzb2NpYXRpb25fc2NvcGVvOiBSb2xlOjpBY3RpdmVSZWNvcmRfUmVsYXRp\nb24SOgtAa2xhc3NjCVJvbGU6C0B0YWJsZW86EEFyZWw6OlRhYmxlCzsdSSIK\ncm9sZXMGOwBUOgxAZW5naW5lQAGpOg1AY29sdW1uczA6DUBhbGlhc2VzWwA6\nEUB0YWJsZV9hbGlhczA6EUBwcmltYXJ5X2tleTA7GHsIOg5leHRlbmRpbmdb\nADoJYmluZFsGWwdvOkNBY3RpdmVSZWNvcmQ6OkNvbm5lY3Rpb25BZGFwdGVy\nczo6QWJzdHJhY3RNeXNxbEFkYXB0ZXI6OkNvbHVtbg46DEBzdHJpY3RUOg9A\nY29sbGF0aW9uMDoLQGV4dHJhSSITYXV0b19pbmNyZW1lbnQGOwBUOx1JIgdp\nZAY7AFQ6D0BjYXN0X3R5cGVAcjoOQHNxbF90eXBlSSIMaW50KDExKQY7AFQ6\nCkBudWxsRjoNQGRlZmF1bHQwOhZAZGVmYXVsdF9mdW5jdGlvbjBpBjoKd2hl\ncmVbBm86GkFyZWw6Ok5vZGVzOjpFcXVhbGl0eQc6CkBsZWZ0UzogQXJlbDo6\nQXR0cmlidXRlczo6QXR0cmlidXRlBzoNcmVsYXRpb25vO0QLOx1AAas7RWMX\nQWN0aXZlUmVjb3JkOjpCYXNlO0YwO0dbADtIMDtJMDoJbmFtZUkiB2lkBjsA\nVDoLQHJpZ2h0bzobQXJlbDo6Tm9kZXM6OkJpbmRQYXJhbQA6DUBvZmZzZXRz\newA7JjA6CkBhcmVsbzoYQXJlbDo6U2VsZWN0TWFuYWdlcgk7RUABqToJQGN0\neG86HEFyZWw6Ok5vZGVzOjpTZWxlY3RDb3JlDToMQHNvdXJjZW86HEFyZWw6\nOk5vZGVzOjpKb2luU291cmNlBztXQAGqO1tbADoJQHRvcDA6FEBzZXRfcXVh\nbnRpZmllcjA6EUBwcm9qZWN0aW9uc1sGUztYBztZQAGqO1pJQzocQXJlbDo6\nTm9kZXM6OlNxbExpdGVyYWwiBioGOwBUOgxAd2hlcmVzWwZvOhVBcmVsOjpO\nb2Rlczo6QW5kBjoOQGNoaWxkcmVuWwZAAbY6DEBncm91cHNbADoMQGhhdmlu\nZzA6DUB3aW5kb3dzWwA6EUBiaW5kX3ZhbHVlc1sAOglAYXN0bzohQXJlbDo6\nTm9kZXM6OlNlbGVjdFN0YXRlbWVudAs6C0Bjb3Jlc1sGQAG/OgxAb3JkZXJz\nWwA7DjA6CkBsb2NrMDoMQG9mZnNldDA6CkB3aXRoMDoWQHNjb3BlX2Zvcl9j\ncmVhdGUwOhJAb3JkZXJfY2xhdXNlMDoMQHRvX3NxbDA6CkBsYXN0MDoVQGpv\naW5fZGVwZW5kZW5jeTA6F0BzaG91bGRfZWFnZXJfbG9hZDA6DUByZWNvcmRz\nWwA7M0Y7NEY7NUY7NjA7N0Y7ODA7OXsAOzowOztbBkY7PDBJIhBjcmVkZW50\naWFscwY7AEZvOhBDcmVkZW50aWFscww6DUByb2xlX2lkaQY6EEB1cGRhdGVk\nX2F0SXU7MQ2T7BzAAACw5gY7MkkiCFVUQwY7AEY6DkByb2xlX2lkc1sGaQY6\nFEBwZXJtaXNzaW9uX2lkc1sOaQtpC2kLaQhpCGkIaQdpB2kHOg1AYWN0aW9u\nc3slSSISY29udGVudF9wYWdlcwY7AFR7CEkiEXZpZXdfZGVmYXVsdAY7AFRU\nSSIJdmlldwY7AFRUSSIJbGlzdAY7AFRGSSIXY29udHJvbGxlcl9hY3Rpb25z\nBjsAVHsGSSIJbGlzdAY7AFRGSSIJYXV0aAY7AFR7CEkiCmxvZ2luBjsAVFRJ\nIgtsb2dvdXQGOwBUVEkiEWxvZ2luX2ZhaWxlZAY7AFRUSSIPbWVudV9pdGVt\ncwY7AFR7B0kiCWxpbmsGOwBUVEkiCWxpc3QGOwBURkkiEHBlcm1pc3Npb25z\nBjsAVHsGSSIJbGlzdAY7AFRGSSIKcm9sZXMGOwBUewZJIglsaXN0BjsAVEZJ\nIhVzaXRlX2NvbnRyb2xsZXJzBjsAVHsGSSIJbGlzdAY7AFRGSSIUc3lzdGVt\nX3NldHRpbmdzBjsAVHsGSSIJbGlzdAY7AFRGSSIKdXNlcnMGOwBUewdJIgls\naXN0BjsAVEZJIglrZXlzBjsAVFRJIgphZG1pbgY7AFR7CEkiFWxpc3RfaW5z\ndHJ1Y3RvcnMGOwBURkkiGGxpc3RfYWRtaW5pc3RyYXRvcnMGOwBURkkiHmxp\nc3Rfc3VwZXJfYWRtaW5pc3RyYXRvcnMGOwBURkkiC2NvdXJzZQY7AFR7Bkki\nEWxpc3RfZm9sZGVycwY7AFRGSSIPYXNzaWdubWVudAY7AFR7BkkiCWxpc3QG\nOwBURkkiEnF1ZXN0aW9ubmFpcmUGOwBUewpJIglsaXN0BjsAVEZJIhljcmVh\ndGVfcXVlc3Rpb25uYWlyZQY7AFRGSSIXZWRpdF9xdWVzdGlvbm5haXJlBjsA\nVEZJIhdjb3B5X3F1ZXN0aW9ubmFpcmUGOwBURkkiF3NhdmVfcXVlc3Rpb25u\nYWlyZQY7AFRGSSIRcGFydGljaXBhbnRzBjsAVHsLSSIQYWRkX3N0dWRlbnQG\nOwBURkkiFmVkaXRfdGVhbV9tZW1iZXJzBjsAVEZJIhJsaXN0X3N0dWRlbnRz\nBjsAVEZJIhFsaXN0X2NvdXJzZXMGOwBURkkiFWxpc3RfYXNzaWdubWVudHMG\nOwBURkkiEmNoYW5nZV9oYW5kbGUGOwBUVEkiEGluc3RpdHV0aW9uBjsAVHsG\nSSIJbGlzdAY7AFRGSSIRc3R1ZGVudF90YXNrBjsAVHsGSSIJbGlzdAY7AFRU\nSSIMcHJvZmlsZQY7AFR7BkkiCWVkaXQGOwBUVEkiFHN1cnZleV9yZXNwb25z\nZQY7AFR7B0kiC2NyZWF0ZQY7AFRUSSILc3VibWl0BjsAVFRJIgl0ZWFtBjsA\nVHsHSSIJbGlzdAY7AFRGSSIVbGlzdF9hc3NpZ25tZW50cwY7AFRGSSIQdGVh\nbXNfdXNlcnMGOwBUewZJIglsaXN0BjsAVEZJIhBpbXBlcnNvbmF0ZQY7AFR7\nB0kiCnN0YXJ0BjsAVEZJIhBpbXBlcnNvbmF0ZQY7AFRUSSITcmV2aWV3X21h\ncHBpbmcGOwBUewtJIglsaXN0BjsAVEZJIhlhZGRfZHluYW1pY19yZXZpZXdl\ncgY7AFRUSSIYcmVsZWFzZV9yZXNlcnZhdGlvbgY7AFRUSSIfc2hvd19hdmFp\nbGFibGVfc3VibWlzc2lvbnMGOwBUVEkiIGFzc2lnbl9yZXZpZXdlcl9keW5h\nbWljYWxseQY7AFRUSSIkYXNzaWduX21ldGFyZXZpZXdlcl9keW5hbWljYWxs\neQY7AFRUSSILZ3JhZGVzBjsAVHsGSSITdmlld19teV9zY29yZXMGOwBUVEki\nFnN1cnZleV9kZXBsb3ltZW50BjsAVHsGSSIJbGlzdAY7AFRGSSIPc3RhdGlz\ndGljcwY7AFR7BkkiEWxpc3Rfc3VydmV5cwY7AFRGSSIRdHJlZV9kaXNwbGF5\nBjsAVHsSSSIJbGlzdAY7AFRGSSIKZHJpbGwGOwBURkkiGGdvdG9fcXVlc3Rp\nb25uYWlyZXMGOwBURkkiGmdvdG9fYXV0aG9yX2ZlZWRiYWNrcwY7AFRGSSIY\nZ290b19yZXZpZXdfcnVicmljcwY7AFRGSSIXZ290b19nbG9iYWxfc3VydmV5\nBjsAVEZJIhFnb3RvX3N1cnZleXMGOwBURkkiHGdvdG9fY291cnNlX2V2YWx1\nYXRpb25zBjsAVEZJIhFnb3RvX2NvdXJzZXMGOwBURkkiFWdvdG9fYXNzaWdu\nbWVudHMGOwBURkkiGmdvdG9fdGVhbW1hdGVfcmV2aWV3cwY7AFRGSSIcZ290\nb19tZXRhcmV2aWV3X3J1YnJpY3MGOwBURkkiIGdvdG9fdGVhbW1hdGVyZXZp\nZXdfcnVicmljcwY7AFRGSSISc2lnbl91cF9zaGVldAY7AFR7CEkiCWxpc3QG\nOwBUVEkiC3NpZ251cAY7AFRUSSISZGVsZXRlX3NpZ251cAY7AFRUSSIPc3Vn\nZ2VzdGlvbgY7AFR7B0kiC2NyZWF0ZQY7AFRUSSIIbmV3BjsAVFRJIhBsZWFk\nZXJib2FyZAY7AFR7BkkiCmluZGV4BjsAVFRJIgthZHZpY2UGOwBUewdJIhBl\nZGl0X2FkdmljZQY7AFRGSSIQc2F2ZV9hZHZpY2UGOwBURkkiGmFkdmVydGlz\nZV9mb3JfcGFydG5lcgY7AFR7CkkiGmFkZF9hZHZlcnRpc2VfY29tbWVudAY7\nAFRUSSIJZWRpdAY7AFRUSSIIbmV3BjsAVFRJIgtyZW1vdmUGOwBUVEkiC3Vw\nZGF0ZQY7AFRUSSIXam9pbl90ZWFtX3JlcXVlc3RzBjsAVHsNSSILY3JlYXRl\nBjsAVFRJIgxkZWNsaW5lBjsAVFRJIgxkZXN0cm95BjsAVFRJIgllZGl0BjsA\nVFRJIgppbmRleAY7AFRUSSIIbmV3BjsAVFRJIglzaG93BjsAVFRJIgt1cGRh\ndGUGOwBUVDoRQGNvbnRyb2xsZXJzezZJIhJjb250ZW50X3BhZ2VzBjsAVEZJ\nIhdjb250cm9sbGVyX2FjdGlvbnMGOwBURkkiCWF1dGgGOwBURkkiEm1hcmt1\ncF9zdHlsZXMGOwBURkkiD21lbnVfaXRlbXMGOwBURkkiEHBlcm1pc3Npb25z\nBjsAVEZJIgpyb2xlcwY7AFRGSSIVc2l0ZV9jb250cm9sbGVycwY7AFRGSSIU\nc3lzdGVtX3NldHRpbmdzBjsAVEZJIgp1c2VycwY7AFRUSSIWcm9sZXNfcGVy\nbWlzc2lvbnMGOwBURkkiCmFkbWluBjsAVEZJIgtjb3Vyc2UGOwBURkkiD2Fz\nc2lnbm1lbnQGOwBURkkiEnF1ZXN0aW9ubmFpcmUGOwBURkkiC2FkdmljZQY7\nAFRGSSIRcGFydGljaXBhbnRzBjsAVEZJIgxyZXBvcnRzBjsAVFRJIhBpbnN0\naXR1dGlvbgY7AFRGSSIRc3R1ZGVudF90YXNrBjsAVFRJIgxwcm9maWxlBjsA\nVFRJIhRzdXJ2ZXlfcmVzcG9uc2UGOwBUVEkiCXRlYW0GOwBURkkiEHRlYW1z\nX3VzZXJzBjsAVEZJIhBpbXBlcnNvbmF0ZQY7AFRGSSIQaW1wb3J0X2ZpbGUG\nOwBURkkiE3Jldmlld19tYXBwaW5nBjsAVEZJIgtncmFkZXMGOwBURkkiFmNv\ndXJzZV9ldmFsdWF0aW9uBjsAVFRJIhhwYXJ0aWNpcGFudF9jaG9pY2VzBjsA\nVEZJIhZzdXJ2ZXlfZGVwbG95bWVudAY7AFRGSSIPc3RhdGlzdGljcwY7AFRG\nSSIRdHJlZV9kaXNwbGF5BjsAVEZJIhFzdHVkZW50X3RlYW0GOwBUVEkiD2lu\ndml0YXRpb24GOwBUVEkiC3N1cnZleQY7AFRGSSIXcGFzc3dvcmRfcmV0cmll\ndmFsBjsAVFRJIhZzdWJtaXR0ZWRfY29udGVudAY7AFRUSSIJZXVsYQY7AFRU\nSSITc3R1ZGVudF9yZXZpZXcGOwBUVEkiD3B1Ymxpc2hpbmcGOwBUVEkiEGV4\ncG9ydF9maWxlBjsAVEZJIg1yZXNwb25zZQY7AFRUSSISc2lnbl91cF9zaGVl\ndAY7AFRGSSIPc3VnZ2VzdGlvbgY7AFRGSSIQbGVhZGVyYm9hcmQGOwBUVEki\nEmRlbGV0ZV9vYmplY3QGOwBURkkiGmFkdmVydGlzZV9mb3JfcGFydG5lcgY7\nAFRUSSIXam9pbl90ZWFtX3JlcXVlc3RzBjsAVFQ6C0BwYWdlc3sNSSIJaG9t\nZQY7AFRUSSIMZXhwaXJlZAY7AFRUSSINbm90Zm91bmQGOwBUVEkiC2Rlbmll\nZAY7AFRUSSIPY29udGFjdF91cwY7AFRUSSIPc2l0ZV9hZG1pbgY7AFRGSSIK\nYWRtaW4GOwBURkkiDGNyZWRpdHMGOwBUVEkiCW1lbnUGOwBGbzoJTWVudQs6\nCkByb290bzoPTWVudTo6Tm9kZQc6DEBwYXJlbnQwO2pbCWkGaQppC2kMOgtA\nYnlfaWR7C2kGbzsBgg87AYMwO2pbBmkNOg9AcGFyZW50X2lkMDsdSSIJaG9t\nZQY7AFQ6CEBpZGkGOgtAbGFiZWxJIglIb21lBjsAVDoYQHNpdGVfY29udHJv\nbGxlcl9pZDA6GkBjb250cm9sbGVyX2FjdGlvbl9pZDA6FUBjb250ZW50X3Bh\nZ2VfaWRpBjoJQHVybEkiCi9ob21lBjsAVGkKbzsBgg47AYMwOwGFMDsdSSIR\nc3R1ZGVudF90YXNrBjsAVDsBhmkKOwGHSSIQQXNzaWdubWVudHMGOwBUOwGI\naRk7AYlpJjsBijA7AYtJIhcvc3R1ZGVudF90YXNrL2xpc3QGOwBUaQtvOwGC\nDjsBgzA7AYUwOx1JIgxwcm9maWxlBjsAVDsBhmkLOwGHSSIMUHJvZmlsZQY7\nAFQ7AYhpGjsBiWknOwGKMDsBi0kiEi9wcm9maWxlL2VkaXQGOwBUaQxvOwGC\nDzsBgzA7alsGaQ47AYUwOx1JIg9jb250YWN0X3VzBjsAVDsBhmkMOwGHSSIP\nQ29udGFjdCBVcwY7AFQ7AYgwOwGJMDsBimkKOwGLSSIQL2NvbnRhY3RfdXMG\nOwBUaQ1vOwGCDjsBgzA7AYVpBjsdSSIQbGVhZGVyYm9hcmQGOwBUOwGGaQ07\nAYdJIhBMZWFkZXJib2FyZAY7AFQ7AYhpMzsBiWlKOwGKMDsBi0kiFy9sZWFk\nZXJib2FyZC9pbmRleAY7AFRpDm87AYIOOwGDMDsBhWkMOx1JIgxjcmVkaXRz\nBjsAVDsBhmkOOwGHSSIaQ3JlZGl0cyAmYW1wOyBMaWNlbmNlBjsAVDsBiDA7\nAYkwOwGKaQ07AYtJIg0vY3JlZGl0cwY7AFQ6DUBieV9uYW1lewtJIglob21l\nBjsAVEACrAFJIhFzdHVkZW50X3Rhc2sGOwBUQAKxAUkiDHByb2ZpbGUGOwBU\nQAK1AUkiD2NvbnRhY3RfdXMGOwBUQAK5AUkiEGxlYWRlcmJvYXJkBjsAVEAC\nvgFJIgxjcmVkaXRzBjsAVEACwgE6DkBzZWxlY3RlZHsGaQZAAqwBOgxAdmVj\ndG9yWwdAAqkBQAKsAToMQGNydW1ic1sGaQZJIg9zdXBlcl91c2VyBjsARm87\nBh47B287CAY7B287CQo7Cn0bSSIHaWQGOwBUbzsLCTsMMDsNMDsOaQk7D287\nEAg7EVQ7EmwtBwAAAIA7E2wrBwAAAIBJIgluYW1lBjsAVG87FAg7DDA7DTA7\nDmkB/0kiFWNyeXB0ZWRfcGFzc3dvcmQGOwBUbzsUCDsMMDsNMDsOaS1JIgxy\nb2xlX2lkBjsAVEAC1gFJIhJwYXNzd29yZF9zYWx0BjsAVEAC2wFJIg1mdWxs\nbmFtZQY7AFRAAtsBSSIKZW1haWwGOwBUQALbAUkiDnBhcmVudF9pZAY7AFRA\nAtYBSSIXcHJpdmF0ZV9ieV9kZWZhdWx0BjsAVG87FQg7DDA7DTA7DmkGSSIX\nbXJ1X2RpcmVjdG9yeV9wYXRoBjsAVG87FAg7DDA7DTA7DmkBgEkiFGVtYWls\nX29uX3JldmlldwY7AFRAAuQBSSIYZW1haWxfb25fc3VibWlzc2lvbgY7AFRA\nAuQBSSIeZW1haWxfb25fcmV2aWV3X29mX3JldmlldwY7AFRAAuQBSSIQaXNf\nbmV3X3VzZXIGOwBUQALkAUkiHm1hc3Rlcl9wZXJtaXNzaW9uX2dyYW50ZWQG\nOwBUbzsLCTsMMDsNMDsOaQY7D287EAg7EVQ7Emn/gDsTaQGASSILaGFuZGxl\nBjsAVEAC2wFJIhhsZWFkZXJib2FyZF9wcml2YWN5BjsAVEAC5AFJIhhkaWdp\ndGFsX2NlcnRpZmljYXRlBjsAVG87Fgg7DDA7DTA7DmkC//9JIhZwZXJzaXN0\nZW5jZV90b2tlbgY7AFRAAtsBSSIRdGltZXpvbmVwcmVmBjsAVEAC2wFJIg9w\ndWJsaWNfa2V5BjsAVEAC8QFJIhNjb3B5X29mX2VtYWlscwY7AFRAAuQBbzsX\nCDsMMDsNMDsOMDsYextJIgdpZAY7AFRpBkkiCW5hbWUGOwBUSSIKYWRtaW4G\nOwBUSSIVY3J5cHRlZF9wYXNzd29yZAY7AFRJIi1kMDMzZTIyYWUzNDhhZWI1\nNjYwZmMyMTQwYWVjMzU4NTBjNGRhOTk3BjsAVEkiDHJvbGVfaWQGOwBUaQpJ\nIhJwYXNzd29yZF9zYWx0BjsAVDBJIg1mdWxsbmFtZQY7AFQwSSIKZW1haWwG\nOwBUSSIcYW55dGhpbmdAbWFpbGluYXRvci5jb20GOwBUSSIOcGFyZW50X2lk\nBjsAVGkGSSIXcHJpdmF0ZV9ieV9kZWZhdWx0BjsAVGkASSIXbXJ1X2RpcmVj\ndG9yeV9wYXRoBjsAVDBJIhRlbWFpbF9vbl9yZXZpZXcGOwBUaQZJIhhlbWFp\nbF9vbl9zdWJtaXNzaW9uBjsAVGkGSSIeZW1haWxfb25fcmV2aWV3X29mX3Jl\ndmlldwY7AFRpBkkiEGlzX25ld191c2VyBjsAVGkASSIebWFzdGVyX3Blcm1p\nc3Npb25fZ3JhbnRlZAY7AFRpAEkiC2hhbmRsZQY7AFQwSSIYbGVhZGVyYm9h\ncmRfcHJpdmFjeQY7AFRpAEkiGGRpZ2l0YWxfY2VydGlmaWNhdGUGOwBUMEki\nFnBlcnNpc3RlbmNlX3Rva2VuBjsAVDBJIhF0aW1lem9uZXByZWYGOwBUMEki\nD3B1YmxpY19rZXkGOwBUMEkiE2NvcHlfb2ZfZW1haWxzBjsAVGkAOxl7ADsa\nRjsbextJIhVjcnlwdGVkX3Bhc3N3b3JkBjsAVG87HAk7HUkiFWNyeXB0ZWRf\ncGFzc3dvcmQGOwBUOx5AAvwBOx9AAt0BOyBJIi1kMDMzZTIyYWUzNDhhZWI1\nNjYwZmMyMTQwYWVjMzU4NTBjNGRhOTk3BjsAVEkiEnBhc3N3b3JkX3NhbHQG\nOwBUbzscCTsdSSIScGFzc3dvcmRfc2FsdAY7AFQ7HjA7H0AC2wE7IDBJIgxy\nb2xlX2lkBjsAVG87HAk7HUkiDHJvbGVfaWQGOwBUOx5pCjsfQALWATsgaQpJ\nIgdpZAY7AEZvOxwJOx1JIgdpZAY7AEY7HmkGOx9AAtYBOyBpBkkiEXRpbWV6\nb25lcHJlZgY7AFRvOiZBY3RpdmVSZWNvcmQ6OkF0dHJpYnV0ZTo6RnJvbVVz\nZXIJOx1JIhF0aW1lem9uZXByZWYGOwBUOx5JIh9FYXN0ZXJuIFRpbWUgKFVT\nICYgQ2FuYWRhKQY7AFQ7H0AC2wE7IEkiH0Vhc3Rlcm4gVGltZSAoVVMgJiBD\nYW5hZGEpBjsAVEkiCW5hbWUGOwBUbzscCTsdSSIJbmFtZQY7AFQ7HkAC+gE7\nH0AC2wE7IEkiCmFkbWluBjsAVEkiDWZ1bGxuYW1lBjsAVG87AZAJOx1JIg1m\ndWxsbmFtZQY7AFQ7HkkiEUFkbWluLCBBZG1pbgY7AFQ7H0AC2wE7IEkiEUFk\nbWluLCBBZG1pbgY7AFRJIgplbWFpbAY7AFRvOwGQCTsdSSIKZW1haWwGOwBU\nOx5JIhxhbnl0aGluZ0BtYWlsaW5hdG9yLmNvbQY7AFQ7H0AC2wE7IEkiHGFu\neXRoaW5nQG1haWxpbmF0b3IuY29tBjsAVEkiFGVtYWlsX29uX3JldmlldwY7\nAFRvOwGQCTsdSSIUZW1haWxfb25fcmV2aWV3BjsAVDseSSIJdHJ1ZQY7AFQ7\nH0AC5AE7IFRJIhhlbWFpbF9vbl9zdWJtaXNzaW9uBjsAVG87AZAJOx1JIhhl\nbWFpbF9vbl9zdWJtaXNzaW9uBjsAVDseSSIJdHJ1ZQY7AFQ7H0AC5AE7IFRJ\nIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsAVG87AZAJOx1JIh5lbWFp\nbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsAVDseSSIJdHJ1ZQY7AFQ7H0AC5AE7\nIFRJIhhsZWFkZXJib2FyZF9wcml2YWN5BjsAVG87HAk7HUkiGGxlYWRlcmJv\nYXJkX3ByaXZhY3kGOwBUOx5pADsfQALkATsgRkkiC2hhbmRsZQY7AFRvOwGQ\nCTsdSSILaGFuZGxlBjsAVDseSSIABjsAVDsfQALbATsgSSIABjsAVEkiFnBl\ncnNpc3RlbmNlX3Rva2VuBjsAVG87AZAJOx1JIhZwZXJzaXN0ZW5jZV90b2tl\nbgY7AFQ7HkkiAYBiZjQ2MDAyZTY4ZmQ5MzMwZTBiZTYxYmM0NmFhYjZmOGZj\nYmRhMWU5YTcwMmFiOGE3NjAyMzA5N2E3Y2NlNjc5MmMyNDNkMDA2ZWE1MDJk\nNzIyMDk5ZjJlNzU1MmQxMTRiZTgyN2U5ZTI0NmNiMWY2ODFlMDliMWIxNzI0\nNzEwYgY7AEY7H0AC2wE7IEkiAYBiZjQ2MDAyZTY4ZmQ5MzMwZTBiZTYxYmM0\nNmFhYjZmOGZjYmRhMWU5YTcwMmFiOGE3NjAyMzA5N2E3Y2NlNjc5MmMyNDNk\nMDA2ZWE1MDJkNzIyMDk5ZjJlNzU1MmQxMTRiZTgyN2U5ZTI0NmNiMWY2ODFl\nMDliMWIxNzI0NzEwYgY7AEZJIg5wYXJlbnRfaWQGOwBUbzscCTsdSSIOcGFy\nZW50X2lkBjsAVDseaQY7H0AC1gE7IGkGSSIXcHJpdmF0ZV9ieV9kZWZhdWx0\nBjsAVG87HAk7HUkiF3ByaXZhdGVfYnlfZGVmYXVsdAY7AFQ7HmkAOx9AAuQB\nOyBGSSIXbXJ1X2RpcmVjdG9yeV9wYXRoBjsAVG87HAk7HUkiF21ydV9kaXJl\nY3RvcnlfcGF0aAY7AFQ7HjA7H0AC5gE7IDBJIhBpc19uZXdfdXNlcgY7AFRv\nOxwJOx1JIhBpc19uZXdfdXNlcgY7AFQ7HmkAOx9AAuQBOyBGSSIebWFzdGVy\nX3Blcm1pc3Npb25fZ3JhbnRlZAY7AFRvOxwJOx1JIh5tYXN0ZXJfcGVybWlz\nc2lvbl9ncmFudGVkBjsAVDseaQA7H0AC7AE7IGkASSIYZGlnaXRhbF9jZXJ0\naWZpY2F0ZQY7AFRvOxwJOx1JIhhkaWdpdGFsX2NlcnRpZmljYXRlBjsAVDse\nMDsfQALxATsgMEkiD3B1YmxpY19rZXkGOwBUbzscCTsdSSIPcHVibGljX2tl\neQY7AFQ7HjA7H0AC8QE7IDBJIhNjb3B5X29mX2VtYWlscwY7AFRvOxwJOx1J\nIhNjb3B5X29mX2VtYWlscwY7AFQ7HmkAOx9AAuQBOyBGOyF7ADsiewc7I1U7\nJFsHOyNbDFsHOyVAAtEBWwc7JlRbBzsnbzsoEjsHbzsIBjsHbzsJCjsKfQ1J\nIgdpZAY7AFRAAtYBSSIJbmFtZQY7AFRAAtsBSSIOcGFyZW50X2lkBjsAVEAC\n1gFJIhBkZXNjcmlwdGlvbgY7AFRAAtsBSSIUZGVmYXVsdF9wYWdlX2lkBjsA\nVEAC1gFJIgpjYWNoZQY7AFRVOylbCTsqWwc7KzssWwdAAvEBbzstBjsuQAF9\nQALxAUkiD2NyZWF0ZWRfYXQGOwBUVTsvWwk7KlsAWwBvOzAIOwwwOw0wOw4w\nSSIPdXBkYXRlZF9hdAY7AFRVOy9bCTsqWwBbAEACgAJvOxcIOwwwOw0wOw4w\nOxh7DUkiB2lkBjsAVGkKSSIJbmFtZQY7AFRJIhhTdXBlci1BZG1pbmlzdHJh\ndG9yBjsAVEkiDnBhcmVudF9pZAY7AFRpCUkiEGRlc2NyaXB0aW9uBjsAVEki\nAAY7AFRJIhRkZWZhdWx0X3BhZ2VfaWQGOwBUMEkiCmNhY2hlBjsAVEkiAtw4\nLS0tCjpjcmVkZW50aWFsczogIXJ1Ynkvb2JqZWN0OkNyZWRlbnRpYWxzCiAg\ncm9sZV9pZDogNQogIHVwZGF0ZWRfYXQ6IDIwMTUtMTItMDQgMTk6NTc6NDQu\nMDAwMDAwMDAwIFoKICByb2xlX2lkczoKICAtIDUKICAtIDQKICAtIDMKICAt\nIDIKICAtIDEKICBwZXJtaXNzaW9uX2lkczoKICAtIDUKICAtIDUKICAtIDUK\nICAtIDUKICAtIDUKICAtIDUKICAtIDUKICAtIDUKICAtIDUKICAtIDEKICAt\nIDEKICAtIDEKICAtIDcKICAtIDcKICAtIDcKICAtIDQKICAtIDQKICAtIDQK\nICAtIDYKICAtIDYKICAtIDYKICAtIDMKICAtIDMKICAtIDMKICAtIDIKICAt\nIDIKICAtIDIKICBhY3Rpb25zOgogICAgY29udGVudF9wYWdlczoKICAgICAg\ndmlld19kZWZhdWx0OiB0cnVlCiAgICAgIHZpZXc6IHRydWUKICAgICAgbGlz\ndDogdHJ1ZQogICAgY29udHJvbGxlcl9hY3Rpb25zOgogICAgICBsaXN0OiB0\ncnVlCiAgICBhdXRoOgogICAgICBsb2dpbjogdHJ1ZQogICAgICBsb2dvdXQ6\nIHRydWUKICAgICAgbG9naW5fZmFpbGVkOiB0cnVlCiAgICBtZW51X2l0ZW1z\nOgogICAgICBsaW5rOiB0cnVlCiAgICAgIGxpc3Q6IHRydWUKICAgIHBlcm1p\nc3Npb25zOgogICAgICBsaXN0OiB0cnVlCiAgICByb2xlczoKICAgICAgbGlz\ndDogdHJ1ZQogICAgc2l0ZV9jb250cm9sbGVyczoKICAgICAgbGlzdDogdHJ1\nZQogICAgc3lzdGVtX3NldHRpbmdzOgogICAgICBsaXN0OiB0cnVlCiAgICB1\nc2VyczoKICAgICAgbGlzdDogdHJ1ZQogICAgICBrZXlzOiB0cnVlCiAgICBh\nZG1pbjoKICAgICAgbGlzdF9pbnN0cnVjdG9yczogdHJ1ZQogICAgICBsaXN0\nX2FkbWluaXN0cmF0b3JzOiB0cnVlCiAgICAgIGxpc3Rfc3VwZXJfYWRtaW5p\nc3RyYXRvcnM6IHRydWUKICAgIGNvdXJzZToKICAgICAgbGlzdF9mb2xkZXJz\nOiB0cnVlCiAgICBhc3NpZ25tZW50OgogICAgICBsaXN0OiB0cnVlCiAgICBx\ndWVzdGlvbm5haXJlOgogICAgICBsaXN0OiB0cnVlCiAgICAgIGNyZWF0ZV9x\ndWVzdGlvbm5haXJlOiB0cnVlCiAgICAgIGVkaXRfcXVlc3Rpb25uYWlyZTog\ndHJ1ZQogICAgICBjb3B5X3F1ZXN0aW9ubmFpcmU6IHRydWUKICAgICAgc2F2\nZV9xdWVzdGlvbm5haXJlOiB0cnVlCiAgICBwYXJ0aWNpcGFudHM6CiAgICAg\nIGFkZF9zdHVkZW50OiB0cnVlCiAgICAgIGVkaXRfdGVhbV9tZW1iZXJzOiB0\ncnVlCiAgICAgIGxpc3Rfc3R1ZGVudHM6IHRydWUKICAgICAgbGlzdF9jb3Vy\nc2VzOiB0cnVlCiAgICAgIGxpc3RfYXNzaWdubWVudHM6IHRydWUKICAgICAg\nY2hhbmdlX2hhbmRsZTogdHJ1ZQogICAgaW5zdGl0dXRpb246CiAgICAgIGxp\nc3Q6IHRydWUKICAgIHN0dWRlbnRfdGFzazoKICAgICAgbGlzdDogdHJ1ZQog\nICAgcHJvZmlsZToKICAgICAgZWRpdDogdHJ1ZQogICAgc3VydmV5X3Jlc3Bv\nbnNlOgogICAgICBjcmVhdGU6IHRydWUKICAgICAgc3VibWl0OiB0cnVlCiAg\nICB0ZWFtOgogICAgICBsaXN0OiB0cnVlCiAgICAgIGxpc3RfYXNzaWdubWVu\ndHM6IHRydWUKICAgIHRlYW1zX3VzZXJzOgogICAgICBsaXN0OiB0cnVlCiAg\nICBpbXBlcnNvbmF0ZToKICAgICAgc3RhcnQ6IHRydWUKICAgICAgaW1wZXJz\nb25hdGU6IHRydWUKICAgIHJldmlld19tYXBwaW5nOgogICAgICBsaXN0OiB0\ncnVlCiAgICAgIGFkZF9keW5hbWljX3Jldmlld2VyOiB0cnVlCiAgICAgIHJl\nbGVhc2VfcmVzZXJ2YXRpb246IHRydWUKICAgICAgc2hvd19hdmFpbGFibGVf\nc3VibWlzc2lvbnM6IHRydWUKICAgICAgYXNzaWduX3Jldmlld2VyX2R5bmFt\naWNhbGx5OiB0cnVlCiAgICAgIGFzc2lnbl9tZXRhcmV2aWV3ZXJfZHluYW1p\nY2FsbHk6IHRydWUKICAgIGdyYWRlczoKICAgICAgdmlld19teV9zY29yZXM6\nIHRydWUKICAgIHN1cnZleV9kZXBsb3ltZW50OgogICAgICBsaXN0OiB0cnVl\nCiAgICBzdGF0aXN0aWNzOgogICAgICBsaXN0X3N1cnZleXM6IHRydWUKICAg\nIHRyZWVfZGlzcGxheToKICAgICAgbGlzdDogdHJ1ZQogICAgICBkcmlsbDog\ndHJ1ZQogICAgICBnb3RvX3F1ZXN0aW9ubmFpcmVzOiB0cnVlCiAgICAgIGdv\ndG9fYXV0aG9yX2ZlZWRiYWNrczogdHJ1ZQogICAgICBnb3RvX3Jldmlld19y\ndWJyaWNzOiB0cnVlCiAgICAgIGdvdG9fZ2xvYmFsX3N1cnZleTogdHJ1ZQog\nICAgICBnb3RvX3N1cnZleXM6IHRydWUKICAgICAgZ290b19jb3Vyc2VfZXZh\nbHVhdGlvbnM6IHRydWUKICAgICAgZ290b19jb3Vyc2VzOiB0cnVlCiAgICAg\nIGdvdG9fYXNzaWdubWVudHM6IHRydWUKICAgICAgZ290b190ZWFtbWF0ZV9y\nZXZpZXdzOiB0cnVlCiAgICAgIGdvdG9fbWV0YXJldmlld19ydWJyaWNzOiB0\ncnVlCiAgICAgIGdvdG9fdGVhbW1hdGVyZXZpZXdfcnVicmljczogdHJ1ZQog\nICAgc2lnbl91cF9zaGVldDoKICAgICAgbGlzdDogdHJ1ZQogICAgICBzaWdu\ndXA6IHRydWUKICAgICAgZGVsZXRlX3NpZ251cDogdHJ1ZQogICAgc3VnZ2Vz\ndGlvbjoKICAgICAgY3JlYXRlOiB0cnVlCiAgICAgIG5ldzogdHJ1ZQogICAg\nbGVhZGVyYm9hcmQ6CiAgICAgIGluZGV4OiB0cnVlCiAgICBhZHZpY2U6CiAg\nICAgIGVkaXRfYWR2aWNlOiB0cnVlCiAgICAgIHNhdmVfYWR2aWNlOiB0cnVl\nCiAgICBhZHZlcnRpc2VfZm9yX3BhcnRuZXI6CiAgICAgIGFkZF9hZHZlcnRp\nc2VfY29tbWVudDogdHJ1ZQogICAgICBlZGl0OiB0cnVlCiAgICAgIG5ldzog\ndHJ1ZQogICAgICByZW1vdmU6IHRydWUKICAgICAgdXBkYXRlOiB0cnVlCiAg\nICBqb2luX3RlYW1fcmVxdWVzdHM6CiAgICAgIGNyZWF0ZTogdHJ1ZQogICAg\nICBkZWNsaW5lOiB0cnVlCiAgICAgIGRlc3Ryb3k6IHRydWUKICAgICAgZWRp\ndDogdHJ1ZQogICAgICBpbmRleDogdHJ1ZQogICAgICBuZXc6IHRydWUKICAg\nICAgc2hvdzogdHJ1ZQogICAgICB1cGRhdGU6IHRydWUKICBjb250cm9sbGVy\nczoKICAgIGNvbnRlbnRfcGFnZXM6IHRydWUKICAgIGNvbnRyb2xsZXJfYWN0\naW9uczogdHJ1ZQogICAgYXV0aDogdHJ1ZQogICAgbWFya3VwX3N0eWxlczog\ndHJ1ZQogICAgbWVudV9pdGVtczogdHJ1ZQogICAgcGVybWlzc2lvbnM6IHRy\ndWUKICAgIHJvbGVzOiB0cnVlCiAgICBzaXRlX2NvbnRyb2xsZXJzOiB0cnVl\nCiAgICBzeXN0ZW1fc2V0dGluZ3M6IHRydWUKICAgIHVzZXJzOiB0cnVlCiAg\nICByb2xlc19wZXJtaXNzaW9uczogdHJ1ZQogICAgYWRtaW46IHRydWUKICAg\nIGNvdXJzZTogdHJ1ZQogICAgYXNzaWdubWVudDogdHJ1ZQogICAgcXVlc3Rp\nb25uYWlyZTogdHJ1ZQogICAgYWR2aWNlOiB0cnVlCiAgICBwYXJ0aWNpcGFu\ndHM6IHRydWUKICAgIHJlcG9ydHM6IHRydWUKICAgIGluc3RpdHV0aW9uOiB0\ncnVlCiAgICBzdHVkZW50X3Rhc2s6IHRydWUKICAgIHByb2ZpbGU6IHRydWUK\nICAgIHN1cnZleV9yZXNwb25zZTogdHJ1ZQogICAgdGVhbTogdHJ1ZQogICAg\ndGVhbXNfdXNlcnM6IHRydWUKICAgIGltcGVyc29uYXRlOiB0cnVlCiAgICBp\nbXBvcnRfZmlsZTogdHJ1ZQogICAgcmV2aWV3X21hcHBpbmc6IHRydWUKICAg\nIGdyYWRlczogdHJ1ZQogICAgY291cnNlX2V2YWx1YXRpb246IHRydWUKICAg\nIHBhcnRpY2lwYW50X2Nob2ljZXM6IHRydWUKICAgIHN1cnZleV9kZXBsb3lt\nZW50OiB0cnVlCiAgICBzdGF0aXN0aWNzOiB0cnVlCiAgICB0cmVlX2Rpc3Bs\nYXk6IHRydWUKICAgIHN0dWRlbnRfdGVhbTogdHJ1ZQogICAgaW52aXRhdGlv\nbjogdHJ1ZQogICAgc3VydmV5OiB0cnVlCiAgICBwYXNzd29yZF9yZXRyaWV2\nYWw6IHRydWUKICAgIHN1Ym1pdHRlZF9jb250ZW50OiB0cnVlCiAgICBldWxh\nOiB0cnVlCiAgICBzdHVkZW50X3JldmlldzogdHJ1ZQogICAgcHVibGlzaGlu\nZzogdHJ1ZQogICAgZXhwb3J0X2ZpbGU6IHRydWUKICAgIHJlc3BvbnNlOiB0\ncnVlCiAgICBzaWduX3VwX3NoZWV0OiB0cnVlCiAgICBzdWdnZXN0aW9uOiB0\ncnVlCiAgICBsZWFkZXJib2FyZDogdHJ1ZQogICAgZGVsZXRlX29iamVjdDog\ndHJ1ZQogICAgYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyOiB0cnVlCiAgICBqb2lu\nX3RlYW1fcmVxdWVzdHM6IHRydWUKICBwYWdlczoKICAgIGhvbWU6IHRydWUK\nICAgIGV4cGlyZWQ6IHRydWUKICAgIG5vdGZvdW5kOiB0cnVlCiAgICBkZW5p\nZWQ6IHRydWUKICAgIGNvbnRhY3RfdXM6IHRydWUKICAgIHNpdGVfYWRtaW46\nIHRydWUKICAgIGFkbWluOiB0cnVlCiAgICBjcmVkaXRzOiB0cnVlCjptZW51\nOiAhcnVieS9vYmplY3Q6TWVudQogIHJvb3Q6ICYzNSAhcnVieS9vYmplY3Q6\nTWVudTo6Tm9kZQogICAgcGFyZW50OiAKICAgIGNoaWxkcmVuOgogICAgLSAx\nCiAgICAtIDIKICAgIC0gMwogICAgLSA0CiAgICAtIDUKICAgIC0gNgogICAg\nLSA3CiAgYnlfaWQ6CiAgICAxOiAmMSAhcnVieS9vYmplY3Q6TWVudTo6Tm9k\nZQogICAgICBwYXJlbnQ6IAogICAgICBjaGlsZHJlbjoKICAgICAgLSA4CiAg\nICAgIHBhcmVudF9pZDogCiAgICAgIG5hbWU6IGhvbWUKICAgICAgaWQ6IDEK\nICAgICAgbGFiZWw6IEhvbWUKICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAK\nICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IAogICAgICBjb250ZW50X3Bh\nZ2VfaWQ6IDEKICAgICAgdXJsOiAiL2hvbWUiCiAgICAyOiAmMiAhcnVieS9v\nYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBjaGlsZHJl\nbjoKICAgICAgLSAxMAogICAgICAtIDExCiAgICAgIHBhcmVudF9pZDogCiAg\nICAgIG5hbWU6IGFkbWluCiAgICAgIGlkOiAyCiAgICAgIGxhYmVsOiBBZG1p\nbmlzdHJhdGlvbgogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IAogICAgICBj\nb250cm9sbGVyX2FjdGlvbl9pZDogCiAgICAgIGNvbnRlbnRfcGFnZV9pZDog\nNgogICAgICB1cmw6ICIvc2l0ZV9hZG1pbiIKICAgIDM6ICYzICFydWJ5L29i\namVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIGNoaWxkcmVu\nOgogICAgICAtIDE5CiAgICAgIC0gMjAKICAgICAgLSAyMQogICAgICAtIDIy\nCiAgICAgIC0gMjMKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTogbWFu\nYWdlIGluc3RydWN0b3IgY29udGVudAogICAgICBpZDogMwogICAgICBsYWJl\nbDogTWFuYWdlLi4uCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMzMKICAg\nICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IDUyCiAgICAgIGNvbnRlbnRfcGFn\nZV9pZDogCiAgICAgIHVybDogIi90cmVlX2Rpc3BsYXkvZHJpbGwiCiAgICA0\nOiAmNCAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAog\nICAgICBjaGlsZHJlbjoKICAgICAgLSAxOAogICAgICBwYXJlbnRfaWQ6IAog\nICAgICBuYW1lOiBTdXJ2ZXkgRGVwbG95bWVudHMKICAgICAgaWQ6IDQKICAg\nICAgbGFiZWw6IFN1cnZleSBEZXBsb3ltZW50cwogICAgICBzaXRlX2NvbnRy\nb2xsZXJfaWQ6IDMxCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiA0OQog\nICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvc3VydmV5X2Rl\ncGxveW1lbnQvbGlzdCIKICAgIDU6ICY1ICFydWJ5L29iamVjdDpNZW51OjpO\nb2RlCiAgICAgIHBhcmVudDogCiAgICAgIHBhcmVudF9pZDogCiAgICAgIG5h\nbWU6IHN0dWRlbnRfdGFzawogICAgICBpZDogNQogICAgICBsYWJlbDogQXNz\naWdubWVudHMKICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAyMAogICAgICBj\nb250cm9sbGVyX2FjdGlvbl9pZDogMzMKICAgICAgY29udGVudF9wYWdlX2lk\nOiAKICAgICAgdXJsOiAiL3N0dWRlbnRfdGFzay9saXN0IgogICAgNjogJjYg\nIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAg\ncGFyZW50X2lkOiAKICAgICAgbmFtZTogcHJvZmlsZQogICAgICBpZDogNgog\nICAgICBsYWJlbDogUHJvZmlsZQogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6\nIDIxCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAzNAogICAgICBjb250\nZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvcHJvZmlsZS9lZGl0IgogICAg\nNzogJjcgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAK\nICAgICAgY2hpbGRyZW46CiAgICAgIC0gOQogICAgICBwYXJlbnRfaWQ6IAog\nICAgICBuYW1lOiBjb250YWN0X3VzCiAgICAgIGlkOiA3CiAgICAgIGxhYmVs\nOiBDb250YWN0IFVzCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogCiAgICAg\nIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAKICAgICAgY29udGVudF9wYWdlX2lk\nOiA1CiAgICAgIHVybDogIi9jb250YWN0X3VzIgogICAgODogJjggIXJ1Ynkv\nb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50\nX2lkOiAxCiAgICAgIG5hbWU6IGxlYWRlcmJvYXJkCiAgICAgIGlkOiA4CiAg\nICAgIGxhYmVsOiBMZWFkZXJib2FyZAogICAgICBzaXRlX2NvbnRyb2xsZXJf\naWQ6IDQ2CiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiA2OQogICAgICBj\nb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvbGVhZGVyYm9hcmQvaW5k\nZXgiCiAgICAxMDogJjkgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAg\ncGFyZW50OiAKICAgICAgY2hpbGRyZW46CiAgICAgIC0gMTIKICAgICAgLSAx\nMwogICAgICAtIDE0CiAgICAgIC0gMTUKICAgICAgLSAxNgogICAgICAtIDE3\nCiAgICAgIHBhcmVudF9pZDogMgogICAgICBuYW1lOiBzZXR1cAogICAgICBp\nZDogMTAKICAgICAgbGFiZWw6IFNldHVwCiAgICAgIHNpdGVfY29udHJvbGxl\ncl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAKICAgICAgY29u\ndGVudF9wYWdlX2lkOiA2CiAgICAgIHVybDogIi9zaXRlX2FkbWluIgogICAg\nMTE6ICYxMCAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6\nIAogICAgICBjaGlsZHJlbjoKICAgICAgLSAzMQogICAgICAtIDMyCiAgICAg\nIC0gMzMKICAgICAgLSAzNAogICAgICBwYXJlbnRfaWQ6IDIKICAgICAgbmFt\nZTogc2hvdwogICAgICBpZDogMTEKICAgICAgbGFiZWw6IFNob3cuLi4KICAg\nICAgc2l0ZV9jb250cm9sbGVyX2lkOiAxMAogICAgICBjb250cm9sbGVyX2Fj\ndGlvbl9pZDogMTQKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJs\nOiAiL3VzZXJzL2xpc3QiCiAgICAxOTogJjExICFydWJ5L29iamVjdDpNZW51\nOjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIHBhcmVudF9pZDogMwogICAg\nICBuYW1lOiBtYW5hZ2UvdXNlcnMKICAgICAgaWQ6IDE5CiAgICAgIGxhYmVs\nOiBVc2VycwogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDEwCiAgICAgIGNv\nbnRyb2xsZXJfYWN0aW9uX2lkOiAxNAogICAgICBjb250ZW50X3BhZ2VfaWQ6\nIAogICAgICB1cmw6ICIvdXNlcnMvbGlzdCIKICAgIDIwOiAmMTIgIXJ1Ynkv\nb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgY2hpbGRy\nZW46CiAgICAgIC0gMjQKICAgICAgLSAyNQogICAgICAtIDI2CiAgICAgIC0g\nMjcKICAgICAgLSAyOAogICAgICAtIDI5CiAgICAgIC0gMzAKICAgICAgcGFy\nZW50X2lkOiAzCiAgICAgIG5hbWU6IG1hbmFnZS9xdWVzdGlvbm5haXJlcwog\nICAgICBpZDogMjAKICAgICAgbGFiZWw6IFF1ZXN0aW9ubmFpcmVzCiAgICAg\nIHNpdGVfY29udHJvbGxlcl9pZDogMzMKICAgICAgY29udHJvbGxlcl9hY3Rp\nb25faWQ6IDUzCiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAgIHVybDog\nIi90cmVlX2Rpc3BsYXkvZ290b19xdWVzdGlvbm5haXJlcyIKICAgIDIxOiAm\nMTMgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAg\nICAgcGFyZW50X2lkOiAzCiAgICAgIG5hbWU6IG1hbmFnZS9jb3Vyc2VzCiAg\nICAgIGlkOiAyMQogICAgICBsYWJlbDogQ291cnNlcwogICAgICBzaXRlX2Nv\nbnRyb2xsZXJfaWQ6IDMzCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiA1\nOQogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvdHJlZV9k\naXNwbGF5L2dvdG9fY291cnNlcyIKICAgIDIyOiAmMTQgIXJ1Ynkvb2JqZWN0\nOk1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAz\nCiAgICAgIG5hbWU6IG1hbmFnZS9hc3NpZ25tZW50cwogICAgICBpZDogMjIK\nICAgICAgbGFiZWw6IEFzc2lnbm1lbnRzCiAgICAgIHNpdGVfY29udHJvbGxl\ncl9pZDogMzMKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IDYwCiAgICAg\nIGNvbnRlbnRfcGFnZV9pZDogCiAgICAgIHVybDogIi90cmVlX2Rpc3BsYXkv\nZ290b19hc3NpZ25tZW50cyIKICAgIDIzOiAmMTUgIXJ1Ynkvb2JqZWN0Ok1l\nbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAzCiAg\nICAgIG5hbWU6IGltcGVyc29uYXRlCiAgICAgIGlkOiAyMwogICAgICBsYWJl\nbDogSW1wZXJzb25hdGUgVXNlcgogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6\nIDI1CiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiA0MAogICAgICBjb250\nZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvaW1wZXJzb25hdGUvc3RhcnQi\nCiAgICAxODogJjE2ICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBh\ncmVudDogCiAgICAgIHBhcmVudF9pZDogNAogICAgICBuYW1lOiBTdGF0aXN0\naWNhbCBUZXN0CiAgICAgIGlkOiAxOAogICAgICBsYWJlbDogU3RhdGlzdGlj\nYWwgVGVzdAogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDMyCiAgICAgIGNv\nbnRyb2xsZXJfYWN0aW9uX2lkOiA1MAogICAgICBjb250ZW50X3BhZ2VfaWQ6\nIAogICAgICB1cmw6ICIvc3RhdGlzdGljcy9saXN0X3N1cnZleXMiCiAgICA5\nOiAmMTcgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAK\nICAgICAgcGFyZW50X2lkOiA3CiAgICAgIG5hbWU6IGNyZWRpdHMKICAgICAg\naWQ6IDkKICAgICAgbGFiZWw6IENyZWRpdHMgJmFtcDsgTGljZW5jZQogICAg\nICBzaXRlX2NvbnRyb2xsZXJfaWQ6IAogICAgICBjb250cm9sbGVyX2FjdGlv\nbl9pZDogCiAgICAgIGNvbnRlbnRfcGFnZV9pZDogOAogICAgICB1cmw6ICIv\nY3JlZGl0cyIKICAgIDEyOiAmMTggIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUK\nICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAxMAogICAgICBuYW1l\nOiBzZXR1cC9yb2xlcwogICAgICBpZDogMTIKICAgICAgbGFiZWw6IFJvbGVz\nCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogNwogICAgICBjb250cm9sbGVy\nX2FjdGlvbl9pZDogMTEKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAg\ndXJsOiAiL3JvbGVzL2xpc3QiCiAgICAxMzogJjE5ICFydWJ5L29iamVjdDpN\nZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIHBhcmVudF9pZDogMTAK\nICAgICAgbmFtZTogc2V0dXAvcGVybWlzc2lvbnMKICAgICAgaWQ6IDEzCiAg\nICAgIGxhYmVsOiBQZXJtaXNzaW9ucwogICAgICBzaXRlX2NvbnRyb2xsZXJf\naWQ6IDYKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IDEwCiAgICAgIGNv\nbnRlbnRfcGFnZV9pZDogCiAgICAgIHVybDogIi9wZXJtaXNzaW9ucy9saXN0\nIgogICAgMTQ6ICYyMCAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBw\nYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IDEwCiAgICAgIG5hbWU6IHNldHVw\nL2NvbnRyb2xsZXJzCiAgICAgIGlkOiAxNAogICAgICBsYWJlbDogQ29udHJv\nbGxlcnMgLyBBY3Rpb25zCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogOAog\nICAgICBjb250cm9sbGVyX2FjdGlvbl9pZDogMTIKICAgICAgY29udGVudF9w\nYWdlX2lkOiAKICAgICAgdXJsOiAiL3NpdGVfY29udHJvbGxlcnMvbGlzdCIK\nICAgIDE1OiAmMjEgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFy\nZW50OiAKICAgICAgcGFyZW50X2lkOiAxMAogICAgICBuYW1lOiBzZXR1cC9w\nYWdlcwogICAgICBpZDogMTUKICAgICAgbGFiZWw6IENvbnRlbnQgUGFnZXMK\nICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAxCiAgICAgIGNvbnRyb2xsZXJf\nYWN0aW9uX2lkOiAzCiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAgIHVy\nbDogIi9jb250ZW50X3BhZ2VzL2xpc3QiCiAgICAxNjogJjIyICFydWJ5L29i\namVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIHBhcmVudF9p\nZDogMTAKICAgICAgbmFtZTogc2V0dXAvbWVudXMKICAgICAgaWQ6IDE2CiAg\nICAgIGxhYmVsOiBNZW51IEVkaXRvcgogICAgICBzaXRlX2NvbnRyb2xsZXJf\naWQ6IDUKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IDkKICAgICAgY29u\ndGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAiL21lbnVfaXRlbXMvbGlzdCIK\nICAgIDE3OiAmMjMgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFy\nZW50OiAKICAgICAgcGFyZW50X2lkOiAxMAogICAgICBuYW1lOiBzZXR1cC9z\neXN0ZW1fc2V0dGluZ3MKICAgICAgaWQ6IDE3CiAgICAgIGxhYmVsOiBTeXN0\nZW0gU2V0dGluZ3MKICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiA5CiAgICAg\nIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAxMwogICAgICBjb250ZW50X3BhZ2Vf\naWQ6IAogICAgICB1cmw6ICIvc3lzdGVtX3NldHRpbmdzL2xpc3QiCiAgICAz\nMTogJjI0ICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDog\nCiAgICAgIHBhcmVudF9pZDogMTEKICAgICAgbmFtZTogc2hvdy9pbnN0aXR1\ndGlvbnMKICAgICAgaWQ6IDMxCiAgICAgIGxhYmVsOiBJbnN0aXR1dGlvbnMK\nICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAxOQogICAgICBjb250cm9sbGVy\nX2FjdGlvbl9pZDogMzIKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAg\ndXJsOiAiL2luc3RpdHV0aW9uL2xpc3QiCiAgICAzMjogJjI1ICFydWJ5L29i\namVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIHBhcmVudF9p\nZDogMTEKICAgICAgbmFtZTogc2hvdy9zdXBlci1hZG1pbmlzdHJhdG9ycwog\nICAgICBpZDogMzIKICAgICAgbGFiZWw6IFN1cGVyLUFkbWluaXN0cmF0b3Jz\nCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMTIKICAgICAgY29udHJvbGxl\ncl9hY3Rpb25faWQ6IDE4CiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAg\nIHVybDogIi9hZG1pbi9saXN0X3N1cGVyX2FkbWluaXN0cmF0b3JzIgogICAg\nMzM6ICYyNiAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6\nIAogICAgICBwYXJlbnRfaWQ6IDExCiAgICAgIG5hbWU6IHNob3cvYWRtaW5p\nc3RyYXRvcnMKICAgICAgaWQ6IDMzCiAgICAgIGxhYmVsOiBBZG1pbmlzdHJh\ndG9ycwogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDEyCiAgICAgIGNvbnRy\nb2xsZXJfYWN0aW9uX2lkOiAxNwogICAgICBjb250ZW50X3BhZ2VfaWQ6IAog\nICAgICB1cmw6ICIvYWRtaW4vbGlzdF9hZG1pbmlzdHJhdG9ycyIKICAgIDM0\nOiAmMjcgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAK\nICAgICAgcGFyZW50X2lkOiAxMQogICAgICBuYW1lOiBzaG93L2luc3RydWN0\nb3JzCiAgICAgIGlkOiAzNAogICAgICBsYWJlbDogSW5zdHJ1Y3RvcnMKICAg\nICAgc2l0ZV9jb250cm9sbGVyX2lkOiAxMgogICAgICBjb250cm9sbGVyX2Fj\ndGlvbl9pZDogMTYKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJs\nOiAiL2FkbWluL2xpc3RfaW5zdHJ1Y3RvcnMiCiAgICAyNDogJjI4ICFydWJ5\nL29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIHBhcmVu\ndF9pZDogMjAKICAgICAgbmFtZTogbWFuYWdlL3F1ZXN0aW9ubmFpcmVzL3Jl\ndmlldyBydWJyaWNzCiAgICAgIGlkOiAyNAogICAgICBsYWJlbDogUmV2aWV3\nIHJ1YnJpY3MKICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAzMwogICAgICBj\nb250cm9sbGVyX2FjdGlvbl9pZDogNTUKICAgICAgY29udGVudF9wYWdlX2lk\nOiAKICAgICAgdXJsOiAiL3RyZWVfZGlzcGxheS9nb3RvX3Jldmlld19ydWJy\naWNzIgogICAgMjU6ICYyOSAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAg\nICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IDIwCiAgICAgIG5hbWU6IG1h\nbmFnZS9xdWVzdGlvbm5haXJlcy9tZXRhcmV2aWV3IHJ1YnJpY3MKICAgICAg\naWQ6IDI1CiAgICAgIGxhYmVsOiBNZXRhcmV2aWV3IHJ1YnJpY3MKICAgICAg\nc2l0ZV9jb250cm9sbGVyX2lkOiAzMwogICAgICBjb250cm9sbGVyX2FjdGlv\nbl9pZDogNjIKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAi\nL3RyZWVfZGlzcGxheS9nb3RvX21ldGFyZXZpZXdfcnVicmljcyIKICAgIDI2\nOiAmMzAgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAK\nICAgICAgcGFyZW50X2lkOiAyMAogICAgICBuYW1lOiBtYW5hZ2UvcXVlc3Rp\nb25uYWlyZXMvdGVhbW1hdGUgcmV2aWV3IHJ1YnJpY3MKICAgICAgaWQ6IDI2\nCiAgICAgIGxhYmVsOiBUZWFtbWF0ZSByZXZpZXcgcnVicmljcwogICAgICBz\naXRlX2NvbnRyb2xsZXJfaWQ6IDMzCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9u\nX2lkOiA2MwogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIv\ndHJlZV9kaXNwbGF5L2dvdG9fdGVhbW1hdGVyZXZpZXdfcnVicmljcyIKICAg\nIDI3OiAmMzEgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50\nOiAKICAgICAgcGFyZW50X2lkOiAyMAogICAgICBuYW1lOiBtYW5hZ2UvcXVl\nc3Rpb25uYWlyZXMvYXV0aG9yIGZlZWRiYWNrcwogICAgICBpZDogMjcKICAg\nICAgbGFiZWw6IEF1dGhvciBmZWVkYmFja3MKICAgICAgc2l0ZV9jb250cm9s\nbGVyX2lkOiAzMwogICAgICBjb250cm9sbGVyX2FjdGlvbl9pZDogNTQKICAg\nICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAiL3RyZWVfZGlzcGxh\neS9nb3RvX2F1dGhvcl9mZWVkYmFja3MiCiAgICAyODogJjMyICFydWJ5L29i\namVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIHBhcmVudF9p\nZDogMjAKICAgICAgbmFtZTogbWFuYWdlL3F1ZXN0aW9ubmFpcmVzL2dsb2Jh\nbCBzdXJ2ZXkKICAgICAgaWQ6IDI4CiAgICAgIGxhYmVsOiBHbG9iYWwgc3Vy\ndmV5CiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMzMKICAgICAgY29udHJv\nbGxlcl9hY3Rpb25faWQ6IDU2CiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAg\nICAgIHVybDogIi90cmVlX2Rpc3BsYXkvZ290b19nbG9iYWxfc3VydmV5Igog\nICAgMjk6ICYzMyAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJl\nbnQ6IAogICAgICBwYXJlbnRfaWQ6IDIwCiAgICAgIG5hbWU6IG1hbmFnZS9x\ndWVzdGlvbm5haXJlcy9zdXJ2ZXlzCiAgICAgIGlkOiAyOQogICAgICBsYWJl\nbDogU3VydmV5cwogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDMzCiAgICAg\nIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiA1NwogICAgICBjb250ZW50X3BhZ2Vf\naWQ6IAogICAgICB1cmw6ICIvdHJlZV9kaXNwbGF5L2dvdG9fc3VydmV5cyIK\nICAgIDMwOiAmMzQgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFy\nZW50OiAKICAgICAgcGFyZW50X2lkOiAyMAogICAgICBuYW1lOiBtYW5hZ2Uv\ncXVlc3Rpb25uYWlyZXMvY291cnNlIGV2YWx1YXRpb25zCiAgICAgIGlkOiAz\nMAogICAgICBsYWJlbDogQ291cnNlIGV2YWx1YXRpb25zCiAgICAgIHNpdGVf\nY29udHJvbGxlcl9pZDogMzMKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6\nIDU3CiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAgIHVybDogIi90cmVl\nX2Rpc3BsYXkvZ290b19zdXJ2ZXlzIgogIGJ5X25hbWU6CiAgICBob21lOiAq\nMQogICAgYWRtaW46ICoyCiAgICBtYW5hZ2UgaW5zdHJ1Y3RvciBjb250ZW50\nOiAqMwogICAgU3VydmV5IERlcGxveW1lbnRzOiAqNAogICAgc3R1ZGVudF90\nYXNrOiAqNQogICAgcHJvZmlsZTogKjYKICAgIGNvbnRhY3RfdXM6ICo3CiAg\nICBsZWFkZXJib2FyZDogKjgKICAgIHNldHVwOiAqOQogICAgc2hvdzogKjEw\nCiAgICBtYW5hZ2UvdXNlcnM6ICoxMQogICAgbWFuYWdlL3F1ZXN0aW9ubmFp\ncmVzOiAqMTIKICAgIG1hbmFnZS9jb3Vyc2VzOiAqMTMKICAgIG1hbmFnZS9h\nc3NpZ25tZW50czogKjE0CiAgICBpbXBlcnNvbmF0ZTogKjE1CiAgICBTdGF0\naXN0aWNhbCBUZXN0OiAqMTYKICAgIGNyZWRpdHM6ICoxNwogICAgc2V0dXAv\ncm9sZXM6ICoxOAogICAgc2V0dXAvcGVybWlzc2lvbnM6ICoxOQogICAgc2V0\ndXAvY29udHJvbGxlcnM6ICoyMAogICAgc2V0dXAvcGFnZXM6ICoyMQogICAg\nc2V0dXAvbWVudXM6ICoyMgogICAgc2V0dXAvc3lzdGVtX3NldHRpbmdzOiAq\nMjMKICAgIHNob3cvaW5zdGl0dXRpb25zOiAqMjQKICAgIHNob3cvc3VwZXIt\nYWRtaW5pc3RyYXRvcnM6ICoyNQogICAgc2hvdy9hZG1pbmlzdHJhdG9yczog\nKjI2CiAgICBzaG93L2luc3RydWN0b3JzOiAqMjcKICAgIG1hbmFnZS9xdWVz\ndGlvbm5haXJlcy9yZXZpZXcgcnVicmljczogKjI4CiAgICBtYW5hZ2UvcXVl\nc3Rpb25uYWlyZXMvbWV0YXJldmlldyBydWJyaWNzOiAqMjkKICAgIG1hbmFn\nZS9xdWVzdGlvbm5haXJlcy90ZWFtbWF0ZSByZXZpZXcgcnVicmljczogKjMw\nCiAgICBtYW5hZ2UvcXVlc3Rpb25uYWlyZXMvYXV0aG9yIGZlZWRiYWNrczog\nKjMxCiAgICBtYW5hZ2UvcXVlc3Rpb25uYWlyZXMvZ2xvYmFsIHN1cnZleTog\nKjMyCiAgICBtYW5hZ2UvcXVlc3Rpb25uYWlyZXMvc3VydmV5czogKjMzCiAg\nICBtYW5hZ2UvcXVlc3Rpb25uYWlyZXMvY291cnNlIGV2YWx1YXRpb25zOiAq\nMzQKICBzZWxlY3RlZDoKICAgIDE6ICoxCiAgdmVjdG9yOgogIC0gKjM1CiAg\nLSAqMQogIGNydW1iczoKICAtIDEKBjsAVEkiD2NyZWF0ZWRfYXQGOwBUSXU7\nMQ2T7BzAAAAA4AY7MkkiCFVUQwY7AEZJIg91cGRhdGVkX2F0BjsAVEl1OzEN\nk+wcwAAAwOYGOzJJIghVVEMGOwBGOxl7ADsaRjsbewdJIgluYW1lBjsAVG87\nHAk7HUkiCW5hbWUGOwBUOx5AAooCOx9AAtsBOyBJIhhTdXBlci1BZG1pbmlz\ndHJhdG9yBjsAVEkiDnBhcmVudF9pZAY7AFRvOxwJOx1JIg5wYXJlbnRfaWQG\nOwBUOx5pCTsfQALWATsgaQk7IXsAOyJ7ADszRjs0Rjs1Rjs2MDs3Rjs4MDs5\newA7OjA7O1sGRjs8MFsHOz1JIgY1BjsARlsHOz5GWwc7P0ZbBztAbztBEjtC\nQAGpO0NvO0QLOx1JIgpyb2xlcwY7AFQ7RUABqTtGMDtHWwA7SDA7STA7GHsI\nO0pbADtLWwZbB287TA47TVQ7TjA7T0kiE2F1dG9faW5jcmVtZW50BjsAVDsd\nSSIHaWQGOwBUO1BAAtYBO1FJIgxpbnQoMTEpBjsAVDtSRjtTMDtUMGkKO1Vb\nBm87Vgc7V1M7WAc7WW87RAs7HUACqwI7RUABuTtGMDtHWwA7SDA7STA7Wkki\nB2lkBjsAVDtbbztcADtdewA7JjA7Xm87Xwk7RUABqTtgbzthDTtibztjBztX\nQAKqAjtbWwA7ZDA7ZTA7ZlsGUztYBztZQAKqAjtaSUM7ZyIGKgY7AFQ7aFsG\nbztpBjtqWwZAArYCO2tbADtsMDttWwA7blsAO29vO3ALO3FbBkACvgI7clsA\nOw4wO3MwO3QwO3UwO3YwO3cwO3gwO3kwO3owO3swO3xbADoNdmVyc2lvbnNV\nOjNBY3RpdmVSZWNvcmQ6OkFzc29jaWF0aW9uczo6SGFzTWFueUFzc29jaWF0\naW9uWwc7AZFbDFsHOyVAAtEBWwc7JkZbBzsnWwZvOhhQYXBlclRyYWlsOjpW\nZXJzaW9uGDsHbzsIBjsHbzsJCjsKfQxJIgdpZAY7AFRvOwsJOwwwOw0wOw5p\nCTsPbzsQCDsRVDsSbC0HAAAAgDsTbCsHAAAAgEkiDml0ZW1fdHlwZQY7AFRv\nOxQIOwwwOw0wOw5pAf9JIgxpdGVtX2lkBjsAVEAC2gJJIgpldmVudAY7AFRA\nAt8CSSIOd2hvZHVubml0BjsAVEAC3wJJIgtvYmplY3QGOwBUbzsWCDsMMDsN\nMDsOaQL//0kiD2NyZWF0ZWRfYXQGOwBUVTsvWwk7KlsAWwBvOzAIOwwwOw0w\nOw4wbzsXCDsMMDsNMDsOMDsYewxJIgdpZAY7AFQwSSIOaXRlbV90eXBlBjsA\nVDBJIgxpdGVtX2lkBjsAVDBJIgpldmVudAY7AFQwSSIOd2hvZHVubml0BjsA\nVDBJIgtvYmplY3QGOwBUMEkiD2NyZWF0ZWRfYXQGOwBUMDsZewA7GkY7G3sM\nSSIKZXZlbnQGOwBUbzsBkAk7HUkiCmV2ZW50BjsAVDseSSILdXBkYXRlBjsA\nVDsfQALfAjsgSSILdXBkYXRlBjsAVEkiC29iamVjdAY7AFRvOwGQCTsdSSIL\nb2JqZWN0BjsAVDseSSIC0gEtLS0KaWQ6IDEKbmFtZTogYWRtaW4KY3J5cHRl\nZF9wYXNzd29yZDogZDAzM2UyMmFlMzQ4YWViNTY2MGZjMjE0MGFlYzM1ODUw\nYzRkYTk5Nwpyb2xlX2lkOiA1CnBhc3N3b3JkX3NhbHQ6IApmdWxsbmFtZTog\nCmVtYWlsOiBhbnl0aGluZ0BtYWlsaW5hdG9yLmNvbQpwYXJlbnRfaWQ6IDEK\ncHJpdmF0ZV9ieV9kZWZhdWx0OiBmYWxzZQptcnVfZGlyZWN0b3J5X3BhdGg6\nIAplbWFpbF9vbl9yZXZpZXc6IHRydWUKZW1haWxfb25fc3VibWlzc2lvbjog\ndHJ1ZQplbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3OiB0cnVlCmlzX25ld191\nc2VyOiBmYWxzZQptYXN0ZXJfcGVybWlzc2lvbl9ncmFudGVkOiAwCmhhbmRs\nZTogCmxlYWRlcmJvYXJkX3ByaXZhY3k6IGZhbHNlCmRpZ2l0YWxfY2VydGlm\naWNhdGU6IApwZXJzaXN0ZW5jZV90b2tlbjogCnRpbWV6b25lcHJlZjogCnB1\nYmxpY19rZXk6IApjb3B5X29mX2VtYWlsczogZmFsc2UKBjsAVDsfQALkAjsg\nSSIC0gEtLS0KaWQ6IDEKbmFtZTogYWRtaW4KY3J5cHRlZF9wYXNzd29yZDog\nZDAzM2UyMmFlMzQ4YWViNTY2MGZjMjE0MGFlYzM1ODUwYzRkYTk5Nwpyb2xl\nX2lkOiA1CnBhc3N3b3JkX3NhbHQ6IApmdWxsbmFtZTogCmVtYWlsOiBhbnl0\naGluZ0BtYWlsaW5hdG9yLmNvbQpwYXJlbnRfaWQ6IDEKcHJpdmF0ZV9ieV9k\nZWZhdWx0OiBmYWxzZQptcnVfZGlyZWN0b3J5X3BhdGg6IAplbWFpbF9vbl9y\nZXZpZXc6IHRydWUKZW1haWxfb25fc3VibWlzc2lvbjogdHJ1ZQplbWFpbF9v\nbl9yZXZpZXdfb2ZfcmV2aWV3OiB0cnVlCmlzX25ld191c2VyOiBmYWxzZQpt\nYXN0ZXJfcGVybWlzc2lvbl9ncmFudGVkOiAwCmhhbmRsZTogCmxlYWRlcmJv\nYXJkX3ByaXZhY3k6IGZhbHNlCmRpZ2l0YWxfY2VydGlmaWNhdGU6IApwZXJz\naXN0ZW5jZV90b2tlbjogCnRpbWV6b25lcHJlZjogCnB1YmxpY19rZXk6IApj\nb3B5X29mX2VtYWlsczogZmFsc2UKBjsAVEkiDndob2R1bm5pdAY7AFRvOwGQ\nCTsdSSIOd2hvZHVubml0BjsAVDseaQY7H0AC3wI7IEkiBjEGOwBGSSIHaWQG\nOwBUbzsBkAk7HUkiB2lkBjsAVDseaVY7H0AC2gI7IGlWSSIOaXRlbV90eXBl\nBjsAVG87AZAJOx1JIg5pdGVtX3R5cGUGOwBUOx5JIglVc2VyBjsARjsfQALf\nAjsgSSIJVXNlcgY7AEZJIgxpdGVtX2lkBjsAVG87AZAJOx1JIgxpdGVtX2lk\nBjsAVDseaQY7H0AC2gI7IGkGSSIPY3JlYXRlZF9hdAY7AFRvOwGQCTsdSSIP\nY3JlYXRlZF9hdAY7AFQ7Hkl1OzENlO0cwJPr+jQJOzJJIghVVEMGOwBGOg1u\nYW5vX251bWkCbAI6DW5hbm9fZGVuaQY6DXN1Ym1pY3JvIgZiOx9AAuYCOyBV\nOiBBY3RpdmVTdXBwb3J0OjpUaW1lV2l0aFpvbmVbCEACFANJIghVVEMGOwBU\nQAIUAzshewA7InsAOzNGOzRGOzVGOzYwOzdGOzgwOzl7ADs6MDs7WwZGOzww\nOhhAY2hhbmdlZF9hdHRyaWJ1dGVzQzotQWN0aXZlU3VwcG9ydDo6SGFzaFdp\ndGhJbmRpZmZlcmVudEFjY2Vzc3sAOh1Ab3JpZ2luYWxfcmF3X2F0dHJpYnV0\nZXN7DEkiCmV2ZW50BjsAVEkiC3VwZGF0ZQY7AFRJIgtvYmplY3QGOwBUSSIC\n0gEtLS0KaWQ6IDEKbmFtZTogYWRtaW4KY3J5cHRlZF9wYXNzd29yZDogZDAz\nM2UyMmFlMzQ4YWViNTY2MGZjMjE0MGFlYzM1ODUwYzRkYTk5Nwpyb2xlX2lk\nOiA1CnBhc3N3b3JkX3NhbHQ6IApmdWxsbmFtZTogCmVtYWlsOiBhbnl0aGlu\nZ0BtYWlsaW5hdG9yLmNvbQpwYXJlbnRfaWQ6IDEKcHJpdmF0ZV9ieV9kZWZh\ndWx0OiBmYWxzZQptcnVfZGlyZWN0b3J5X3BhdGg6IAplbWFpbF9vbl9yZXZp\nZXc6IHRydWUKZW1haWxfb25fc3VibWlzc2lvbjogdHJ1ZQplbWFpbF9vbl9y\nZXZpZXdfb2ZfcmV2aWV3OiB0cnVlCmlzX25ld191c2VyOiBmYWxzZQptYXN0\nZXJfcGVybWlzc2lvbl9ncmFudGVkOiAwCmhhbmRsZTogCmxlYWRlcmJvYXJk\nX3ByaXZhY3k6IGZhbHNlCmRpZ2l0YWxfY2VydGlmaWNhdGU6IApwZXJzaXN0\nZW5jZV90b2tlbjogCnRpbWV6b25lcHJlZjogCnB1YmxpY19rZXk6IApjb3B5\nX29mX2VtYWlsczogZmFsc2UKBjsAVEkiDndob2R1bm5pdAY7AFRJIgYxBjsA\nRkkiDGl0ZW1faWQGOwBUaQZJIg5pdGVtX3R5cGUGOwBUSSIJVXNlcgY7AEZJ\nIg9jcmVhdGVkX2F0BjsARkkiGDIwMTUtMTItMTIgMjA6MTM6MTUGOwBUSSIH\naWQGOwBUaVY6GEB2YWxpZGF0aW9uX2NvbnRleHQwOgxAZXJyb3JzbzoYQWN0\naXZlTW9kZWw6OkVycm9ycwc6CkBiYXNlQALVAjoOQG1lc3NhZ2VzewA6FUBf\nYWxyZWFkeV9jYWxsZWR7BjopYXV0b3NhdmVfYXNzb2NpYXRlZF9yZWNvcmRz\nX2Zvcl9pdGVtRjoYQHByZXZpb3VzbHlfY2hhbmdlZEM7AZl7DEkiCmV2ZW50\nBjsAVFsHMEAC+gJJIgtvYmplY3QGOwBUWwcwQAL/AkkiDndob2R1bm5pdAY7\nAFRbBzBAAgMDSSIMaXRlbV9pZAY7AFRbBzBpBkkiDml0ZW1fdHlwZQY7AFRb\nBzBAAgsDSSIPY3JlYXRlZF9hdAY7AEZbBzBAAhUDSSIHaWQGOwBUWwcwaVZb\nBzs9MFsHOz5GWwc7QG86L1BhcGVyVHJhaWw6OlZlcnNpb246OkFjdGl2ZVJl\nY29yZF9SZWxhdGlvbhI7QmMYUGFwZXJUcmFpbDo6VmVyc2lvbjtDbztECzsd\nSSINdmVyc2lvbnMGOwBUO0VAAkADO0YwO0dbADtIMDtJMDsYeww7SlsAO0tb\nB1sHbztMDjtNVDtOMDtPSSIABjsAVDsdQAIOAztQQALaAjtRSSIMaW50KDEx\nKQY7AFQ7UkY7UzA7VDBpBlsHbztMDjtNVDtOSSIUdXRmOF91bmljb2RlX2Np\nBjsAVDtPSSIABjsAVDsdQAIJAztQQALfAjtRSSIRdmFyY2hhcigyNTUpBjsA\nVDtSRjtTMDtUMEkiCVVzZXIGOwBGO1VbB287Vgc7V1M7WAc7WW87RAs7HUAC\nQgM7RUABuTtGMDtHWwA7SDA7STA7WkkiDGl0ZW1faWQGOwBGO1tvO1wAbztW\nBztXUztYBztZQAJUAztaSSIOaXRlbV90eXBlBjsARjtbbztcADoKb3JkZXJb\nB286G0FyZWw6Ok5vZGVzOjpBc2NlbmRpbmcGOgpAZXhwclM7WAc7WUACQQM7\nWjoPY3JlYXRlZF9hdG87AaUGOwGmUztYBztZQAJBAztaSSIHaWQGOwBUOglm\ncm9tMDoJbG9jazA6DWluY2x1ZGVzWwA7XXsAOyYwO15vO18JO0VAAkADO2Bv\nO2ENO2JvO2MHO1dAAkEDO1tbADtkMDtlMDtmWwZTO1gHO1lAAkEDO1pJQztn\nIgYqBjsAVDtoWwZvO2kGO2pbB0ACUgNAAlgDO2tbADtsMDttWwA7blsAO29v\nO3ALO3FbBkACZQM7clsHQAJdA0ACXwM7DjA7czA7dDA7dTA7djA7dzA7eDA7\neTA7ejA7ezA7fFsAWwc6C0Bwcm94eW86Q1BhcGVyVHJhaWw6OlZlcnNpb246\nOkFjdGl2ZVJlY29yZF9Bc3NvY2lhdGlvbnNfQ29sbGVjdGlvblByb3h5CzoR\nQGFzc29jaWF0aW9uQALOAjtCQAJAAztDQAJBAzsYewo7VVsHQAJSA0ACWAM7\nS1sHQAJHA0ACSwM7AaRbB0ACXQNAAl8DOwGoMDsBqTA7XXsAOyZGOzNGOzRG\nOzVGOzYwOzdGOzgwOzl7ADs6MDs7WwZGOzwwOwGcbzsBnQc7AZ5AAtEBOwGf\new86DWZ1bGxuYW1lWwA6DXBhc3N3b3JkWwA6GnBhc3N3b3JkX2NvbmZpcm1h\ndGlvblsAOgplbWFpbFsAOhRlbWFpbF9vbl9yZXZpZXdbADoYZW1haWxfb25f\nc3VibWlzc2lvblsAOh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3WwA6GGxl\nYWRlcmJvYXJkX3ByaXZhY3lbADoLaGFuZGxlWwA6EXRpbWV6b25lcHJlZlsA\nOwGYQzsBmXsAOwGaextJIg1mdWxsbmFtZQY7AFRJIhFBZG1pbiwgQWRtaW4G\nOwBUSSIKZW1haWwGOwBUSSIcYW55dGhpbmdAbWFpbGluYXRvci5jb20GOwBU\nSSIUZW1haWxfb25fcmV2aWV3BjsAVFRJIhhlbWFpbF9vbl9zdWJtaXNzaW9u\nBjsAVFRJIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsAVFRJIgtoYW5k\nbGUGOwBUSSIABjsAVEkiEXRpbWV6b25lcHJlZgY7AFRJIh9FYXN0ZXJuIFRp\nbWUgKFVTICYgQ2FuYWRhKQY7AFRJIhZwZXJzaXN0ZW5jZV90b2tlbgY7AFRJ\nIgGAYmY0NjAwMmU2OGZkOTMzMGUwYmU2MWJjNDZhYWI2ZjhmY2JkYTFlOWE3\nMDJhYjhhNzYwMjMwOTdhN2NjZTY3OTJjMjQzZDAwNmVhNTAyZDcyMjA5OWYy\nZTc1NTJkMTE0YmU4MjdlOWUyNDZjYjFmNjgxZTA5YjFiMTcyNDcxMGIGOwBG\nSSIVY3J5cHRlZF9wYXNzd29yZAY7AFRJIi1kMDMzZTIyYWUzNDhhZWI1NjYw\nZmMyMTQwYWVjMzU4NTBjNGRhOTk3BjsAVEkiEnBhc3N3b3JkX3NhbHQGOwBU\nMEkiDHJvbGVfaWQGOwBUaQpJIgdpZAY7AEZpBkkiCW5hbWUGOwBUSSIKYWRt\naW4GOwBUSSIYbGVhZGVyYm9hcmRfcHJpdmFjeQY7AFRGSSIOcGFyZW50X2lk\nBjsAVGkGSSIXcHJpdmF0ZV9ieV9kZWZhdWx0BjsAVEZJIhdtcnVfZGlyZWN0\nb3J5X3BhdGgGOwBUMEkiEGlzX25ld191c2VyBjsAVEZAAlgCaQBJIhhkaWdp\ndGFsX2NlcnRpZmljYXRlBjsAVDBJIg9wdWJsaWNfa2V5BjsAVDBJIhNjb3B5\nX29mX2VtYWlscwY7AFRGOwGbMDoWQHBhc3N3b3JkX2NoYW5nZWQwOhtAcGFz\nc3dvcmRfY29uZmlybWF0aW9uSSIABjsAVDsBoHsZOjF2YWxpZGF0ZV9hc3Nv\nY2lhdGVkX3JlY29yZHNfZm9yX3BhcnRpY2lwYW50c0Y6PHZhbGlkYXRlX2Fz\nc29jaWF0ZWRfcmVjb3Jkc19mb3JfYXNzaWdubWVudF9wYXJ0aWNpcGFudHNG\nOjB2YWxpZGF0ZV9hc3NvY2lhdGVkX3JlY29yZHNfZm9yX2Fzc2lnbm1lbnRz\nRjowdmFsaWRhdGVfYXNzb2NpYXRlZF9yZWNvcmRzX2Zvcl90ZWFtc191c2Vy\nc0Y6KnZhbGlkYXRlX2Fzc29jaWF0ZWRfcmVjb3Jkc19mb3JfdGVhbXNGOjV2\nYWxpZGF0ZV9hc3NvY2lhdGVkX3JlY29yZHNfZm9yX3NlbnRfaW52aXRhdGlv\nbnNGOjl2YWxpZGF0ZV9hc3NvY2lhdGVkX3JlY29yZHNfZm9yX3JlY2VpdmVk\nX2ludml0YXRpb25zRjotdmFsaWRhdGVfYXNzb2NpYXRlZF9yZWNvcmRzX2Zv\ncl9jaGlsZHJlbkY6LXZhbGlkYXRlX2Fzc29jaWF0ZWRfcmVjb3Jkc19mb3Jf\ndmVyc2lvbnNGOithdXRvc2F2ZV9hc3NvY2lhdGVkX3JlY29yZHNfZm9yX3Bh\ncmVudEY6KWF1dG9zYXZlX2Fzc29jaWF0ZWRfcmVjb3Jkc19mb3Jfcm9sZUY6\nMWF1dG9zYXZlX2Fzc29jaWF0ZWRfcmVjb3Jkc19mb3JfcGFydGljaXBhbnRz\nRjo8YXV0b3NhdmVfYXNzb2NpYXRlZF9yZWNvcmRzX2Zvcl9hc3NpZ25tZW50\nX3BhcnRpY2lwYW50c0Y6MGF1dG9zYXZlX2Fzc29jaWF0ZWRfcmVjb3Jkc19m\nb3JfYXNzaWdubWVudHNGOjBhdXRvc2F2ZV9hc3NvY2lhdGVkX3JlY29yZHNf\nZm9yX3RlYW1zX3VzZXJzRjoqYXV0b3NhdmVfYXNzb2NpYXRlZF9yZWNvcmRz\nX2Zvcl90ZWFtc0Y6NWF1dG9zYXZlX2Fzc29jaWF0ZWRfcmVjb3Jkc19mb3Jf\nc2VudF9pbnZpdGF0aW9uc0Y6OWF1dG9zYXZlX2Fzc29jaWF0ZWRfcmVjb3Jk\nc19mb3JfcmVjZWl2ZWRfaW52aXRhdGlvbnNGOi1hdXRvc2F2ZV9hc3NvY2lh\ndGVkX3JlY29yZHNfZm9yX2NoaWxkcmVuRjotYXV0b3NhdmVfYXNzb2NpYXRl\nZF9yZWNvcmRzX2Zvcl92ZXJzaW9uc0Y6HkBza2lwX3Nlc3Npb25fbWFpbnRl\nbmFuY2VGOg9AX3Nlc3Npb25zWwZvOhBVc2VyU2Vzc2lvbg46C0BzY29wZXsA\nOhVAcHJpb3JpdHlfcmVjb3JkQALRAToWQGF0dGVtcHRlZF9yZWNvcmRvOwYU\nOwdvOwgGOwdvOwkKOwp9G0kiB2lkBjsAVEAC2gJJIgluYW1lBjsAVEAC3wJJ\nIhVjcnlwdGVkX3Bhc3N3b3JkBjsAVG87FAg7DDA7DTA7DmktSSIMcm9sZV9p\nZAY7AFRAAtoCSSIScGFzc3dvcmRfc2FsdAY7AFRAAt8CSSINZnVsbG5hbWUG\nOwBUQALfAkkiCmVtYWlsBjsAVEAC3wJJIg5wYXJlbnRfaWQGOwBUQALaAkki\nF3ByaXZhdGVfYnlfZGVmYXVsdAY7AFRvOxUIOwwwOw0wOw5pBkkiF21ydV9k\naXJlY3RvcnlfcGF0aAY7AFRvOxQIOwwwOw0wOw5pAYBJIhRlbWFpbF9vbl9y\nZXZpZXcGOwBUQAK7A0kiGGVtYWlsX29uX3N1Ym1pc3Npb24GOwBUQAK7A0ki\nHmVtYWlsX29uX3Jldmlld19vZl9yZXZpZXcGOwBUQAK7A0kiEGlzX25ld191\nc2VyBjsAVEACuwNAAlgCbzsLCTsMMDsNMDsOaQY7D287EAg7EVQ7Emn/gDsT\naQGASSILaGFuZGxlBjsAVEAC3wJJIhhsZWFkZXJib2FyZF9wcml2YWN5BjsA\nVEACuwNJIhhkaWdpdGFsX2NlcnRpZmljYXRlBjsAVEAC5AJJIhZwZXJzaXN0\nZW5jZV90b2tlbgY7AFRAAt8CSSIRdGltZXpvbmVwcmVmBjsAVEAC3wJJIg9w\ndWJsaWNfa2V5BjsAVEAC5AJJIhNjb3B5X29mX2VtYWlscwY7AFRAArsDbzsX\nCDsMMDsNMDsOMDsYextJIgdpZAY7AFRpB0kiCW5hbWUGOwBUSSINc3R1ZGVu\ndDEGOwBUSSIVY3J5cHRlZF9wYXNzd29yZAY7AFRJIi1iNjczYWEwYjFhNmY1\nNGZkNGM2M2Q0YjlmMWNlY2FmZjBiNzM5OGJlBjsAVEkiDHJvbGVfaWQGOwBU\naQZJIhJwYXNzd29yZF9zYWx0BjsAVEkiF0t0a0lMbEZaWGRmY1RGcHcyNQY7\nAFRJIg1mdWxsbmFtZQY7AFRJIhFTdHVkZW50LCBPbmUGOwBUSSIKZW1haWwG\nOwBUSSIWc3R1ZGVudDFAbmNzdS5lZHUGOwBUSSIOcGFyZW50X2lkBjsAVGkG\nSSIXcHJpdmF0ZV9ieV9kZWZhdWx0BjsAVGkASSIXbXJ1X2RpcmVjdG9yeV9w\nYXRoBjsAVDBJIhRlbWFpbF9vbl9yZXZpZXcGOwBUMEkiGGVtYWlsX29uX3N1\nYm1pc3Npb24GOwBUMEkiHmVtYWlsX29uX3Jldmlld19vZl9yZXZpZXcGOwBU\nMEkiEGlzX25ld191c2VyBjsAVGkASSIebWFzdGVyX3Blcm1pc3Npb25fZ3Jh\nbnRlZAY7AFRpAEkiC2hhbmRsZQY7AFRJIgAGOwBUSSIYbGVhZGVyYm9hcmRf\ncHJpdmFjeQY7AFRpAEkiGGRpZ2l0YWxfY2VydGlmaWNhdGUGOwBUMEkiFnBl\ncnNpc3RlbmNlX3Rva2VuBjsAVEkiAYBjYWNjOGM5Yzc3N2U2N2Q0NGUyYWI0\nN2Q4YjVmOWIyMmZmNzdkNzA4ZGUwM2VmNzJlZDQ3MjMwZmQ1MGJhZGM4MWJh\nZWUzNWU5ZDM3ZjBlYzc1NDkxNjgzMmIxZDE3ZjVkNDMzYmM1MzI1NzRiNGRh\nMjIwNmFmNGRkN2Q2Nzg5NwY7AFRJIhF0aW1lem9uZXByZWYGOwBUSSIfRWFz\ndGVybiBUaW1lIChVUyAmIENhbmFkYSkGOwBUSSIPcHVibGljX2tleQY7AFQw\nSSITY29weV9vZl9lbWFpbHMGOwBUaQA7GXsAOxpGOxt7G0kiFnBlcnNpc3Rl\nbmNlX3Rva2VuBjsAVG87HAk7HUACSQI7HkAC5gM7H0AC3wI7IEkiAYBjYWNj\nOGM5Yzc3N2U2N2Q0NGUyYWI0N2Q4YjVmOWIyMmZmNzdkNzA4ZGUwM2VmNzJl\nZDQ3MjMwZmQ1MGJhZGM4MWJhZWUzNWU5ZDM3ZjBlYzc1NDkxNjgzMmIxZDE3\nZjVkNDMzYmM1MzI1NzRiNGRhMjIwNmFmNGRkN2Q2Nzg5NwY7AFRJIgdpZAY7\nAFRvOxwJOx1JIgdpZAY7AFQ7HmkHOx9AAtoCOyBpB0kiCW5hbWUGOwBUbzsc\nCDsdSSIJbmFtZQY7AFQ7HkACzwM7H0AC3wJJIhVjcnlwdGVkX3Bhc3N3b3Jk\nBjsAVG87HAg7HUkiFWNyeXB0ZWRfcGFzc3dvcmQGOwBUOx5AAtEDOx9AArQD\nSSIMcm9sZV9pZAY7AFRvOxwIOx1JIgxyb2xlX2lkBjsAVDseaQY7H0AC2gJJ\nIhJwYXNzd29yZF9zYWx0BjsAVG87HAg7HUkiEnBhc3N3b3JkX3NhbHQGOwBU\nOx5AAtQDOx9AAt8CSSINZnVsbG5hbWUGOwBUbzscCDsdSSINZnVsbG5hbWUG\nOwBUOx5AAtYDOx9AAt8CSSIKZW1haWwGOwBUbzscCDsdSSIKZW1haWwGOwBU\nOx5AAtgDOx9AAt8CSSIOcGFyZW50X2lkBjsAVG87HAg7HUACTgI7HmkGOx9A\nAtoCSSIXcHJpdmF0ZV9ieV9kZWZhdWx0BjsAVG87HAg7HUACUQI7HmkAOx9A\nArsDSSIXbXJ1X2RpcmVjdG9yeV9wYXRoBjsAVG87HAg7HUACVAI7HjA7H0AC\nvQNJIhRlbWFpbF9vbl9yZXZpZXcGOwBUbzscCDsdSSIUZW1haWxfb25fcmV2\naWV3BjsAVDseMDsfQAK7A0kiGGVtYWlsX29uX3N1Ym1pc3Npb24GOwBUbzsc\nCDsdSSIYZW1haWxfb25fc3VibWlzc2lvbgY7AFQ7HjA7H0ACuwNAAsADbzsc\nCDsdSSIeZW1haWxfb25fcmV2aWV3X29mX3JldmlldwY7AFQ7HjA7H0ACuwNJ\nIhBpc19uZXdfdXNlcgY7AFRvOxwIOx1AAlcCOx5pADsfQAK7A0ACWAJvOxwI\nOx1AAloCOx5pADsfQALCA0kiC2hhbmRsZQY7AFRvOxwIOx1JIgtoYW5kbGUG\nOwBUOx5AAuIDOx9AAt8CSSIYbGVhZGVyYm9hcmRfcHJpdmFjeQY7AFRvOxwI\nOx1JIhhsZWFkZXJib2FyZF9wcml2YWN5BjsAVDseaQA7H0ACuwNJIhhkaWdp\ndGFsX2NlcnRpZmljYXRlBjsAVG87HAg7HUACXQI7HjA7H0AC5AJJIhF0aW1l\nem9uZXByZWYGOwBUbzscCDsdSSIRdGltZXpvbmVwcmVmBjsAVDseQALoAzsf\nQALfAkkiD3B1YmxpY19rZXkGOwBUbzscCDsdQAJgAjseMDsfQALkAkkiE2Nv\ncHlfb2ZfZW1haWxzBjsAVG87HAg7HUACYwI7HmkAOx9AArsDOyF7ADsiewA7\nM0Y7NEY7NUY7NjA7N0Y7ODA7OXsAOzowOztbBkY7PDA7AZhDOwGZewA7AZp7\nADoRQHJlbWVtYmVyX21lRjoSQHN0YWxlX3JlY29yZDA7AZxvOitBdXRobG9n\naWM6OlNlc3Npb246OlZhbGlkYXRpb246OkVycm9ycwc7AZ5AAqsDOwGfewA6\nGUB1bmF1dGhvcml6ZWRfcmVjb3JkQAKtAzoMQHJlY29yZEACrQM6EUBuZXdf\nc2Vzc2lvbkY6HEBuZXdfcmVjb3JkX2JlZm9yZV9zYXZlRjsBokM7AZl7CUki\nDWZ1bGxuYW1lBjsAVFsHMEACLQJJIgtoYW5kbGUGOwBUWwcwQAJGAkkiEXRp\nbWV6b25lcHJlZgY7AFRbBzBAAiQCSSIWcGVyc2lzdGVuY2VfdG9rZW4GOwBU\nWwcwQAJLAjoNQHZlcnNpb24wSSIKZmxhc2gGOwBUewdJIgxkaXNjYXJkBjsA\nVFsGSSIJbm90ZQY7AEZJIgxmbGFzaGVzBjsAVHsGQAI6BEkiKllvdXIgcmVz\ncG9uc2Ugd2FzIHN1Y2Nlc3NmdWxseSBzYXZlZC4GOwBU\n','2015-12-12 19:51:22','2015-12-13 17:16:59'),(4,'b05c77d0cdb1ffd0389b6646d7b939d7','BAh7CkkiEF9jc3JmX3Rva2VuBjoGRUZJIjFuUENLcEp6Q3BWUjM1SGhidTRY\ndWlWMW9Ea1N0dFY5RWN4Z1lUM0l2T1R3PQY7AEZJIgl1c2VyBjsARm86CVVz\nZXISOhBAYXR0cmlidXRlc286H0FjdGl2ZVJlY29yZDo6QXR0cmlidXRlU2V0\nBjsHbzokQWN0aXZlUmVjb3JkOjpMYXp5QXR0cmlidXRlSGFzaAo6C0B0eXBl\nc30bSSIHaWQGOwBUbzogQWN0aXZlUmVjb3JkOjpUeXBlOjpJbnRlZ2VyCToP\nQHByZWNpc2lvbjA6C0BzY2FsZTA6C0BsaW1pdGkJOgtAcmFuZ2VvOgpSYW5n\nZQg6CWV4Y2xUOgpiZWdpbmwtBwAAAIA6CGVuZGwrBwAAAIBJIgluYW1lBjsA\nVG86SEFjdGl2ZVJlY29yZDo6Q29ubmVjdGlvbkFkYXB0ZXJzOjpBYnN0cmFj\ndE15c3FsQWRhcHRlcjo6TXlzcWxTdHJpbmcIOwwwOw0wOw5pAf9JIhVjcnlw\ndGVkX3Bhc3N3b3JkBjsAVG87FAg7DDA7DTA7DmktSSIMcm9sZV9pZAY7AFRA\nDkkiEnBhc3N3b3JkX3NhbHQGOwBUQBNJIg1mdWxsbmFtZQY7AFRAE0kiCmVt\nYWlsBjsAVEATSSIOcGFyZW50X2lkBjsAVEAOSSIXcHJpdmF0ZV9ieV9kZWZh\ndWx0BjsAVG86IEFjdGl2ZVJlY29yZDo6VHlwZTo6Qm9vbGVhbgg7DDA7DTA7\nDmkGSSIXbXJ1X2RpcmVjdG9yeV9wYXRoBjsAVG87FAg7DDA7DTA7DmkBgEki\nFGVtYWlsX29uX3JldmlldwY7AFRAHEkiGGVtYWlsX29uX3N1Ym1pc3Npb24G\nOwBUQBxJIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsAVEAcSSIQaXNf\nbmV3X3VzZXIGOwBUQBxJIh5tYXN0ZXJfcGVybWlzc2lvbl9ncmFudGVkBjsA\nVG87Cwk7DDA7DTA7DmkGOw9vOxAIOxFUOxJp/4A7E2kBgEkiC2hhbmRsZQY7\nAFRAE0kiGGxlYWRlcmJvYXJkX3ByaXZhY3kGOwBUQBxJIhhkaWdpdGFsX2Nl\ncnRpZmljYXRlBjsAVG86HUFjdGl2ZVJlY29yZDo6VHlwZTo6VGV4dAg7DDA7\nDTA7DmkC//9JIhZwZXJzaXN0ZW5jZV90b2tlbgY7AFRAE0kiEXRpbWV6b25l\ncHJlZgY7AFRAE0kiD3B1YmxpY19rZXkGOwBUQClJIhNjb3B5X29mX2VtYWls\ncwY7AFRAHG86HkFjdGl2ZVJlY29yZDo6VHlwZTo6VmFsdWUIOwwwOw0wOw4w\nOgxAdmFsdWVzextJIgdpZAY7AFRpB0kiCW5hbWUGOwBUSSINc3R1ZGVudDEG\nOwBUSSIVY3J5cHRlZF9wYXNzd29yZAY7AFRJIi1iNjczYWEwYjFhNmY1NGZk\nNGM2M2Q0YjlmMWNlY2FmZjBiNzM5OGJlBjsAVEkiDHJvbGVfaWQGOwBUaQZJ\nIhJwYXNzd29yZF9zYWx0BjsAVEkiF0t0a0lMbEZaWGRmY1RGcHcyNQY7AFRJ\nIg1mdWxsbmFtZQY7AFRJIhFTdHVkZW50LCBPbmUGOwBUSSIKZW1haWwGOwBU\nSSIWc3R1ZGVudDFAbmNzdS5lZHUGOwBUSSIOcGFyZW50X2lkBjsAVGkGSSIX\ncHJpdmF0ZV9ieV9kZWZhdWx0BjsAVGkASSIXbXJ1X2RpcmVjdG9yeV9wYXRo\nBjsAVDBJIhRlbWFpbF9vbl9yZXZpZXcGOwBUMEkiGGVtYWlsX29uX3N1Ym1p\nc3Npb24GOwBUMEkiHmVtYWlsX29uX3Jldmlld19vZl9yZXZpZXcGOwBUMEki\nEGlzX25ld191c2VyBjsAVGkASSIebWFzdGVyX3Blcm1pc3Npb25fZ3JhbnRl\nZAY7AFRpAEkiC2hhbmRsZQY7AFRJIgAGOwBUSSIYbGVhZGVyYm9hcmRfcHJp\ndmFjeQY7AFRpAEkiGGRpZ2l0YWxfY2VydGlmaWNhdGUGOwBUMEkiFnBlcnNp\nc3RlbmNlX3Rva2VuBjsAVEkiAYBjYWNjOGM5Yzc3N2U2N2Q0NGUyYWI0N2Q4\nYjVmOWIyMmZmNzdkNzA4ZGUwM2VmNzJlZDQ3MjMwZmQ1MGJhZGM4MWJhZWUz\nNWU5ZDM3ZjBlYzc1NDkxNjgzMmIxZDE3ZjVkNDMzYmM1MzI1NzRiNGRhMjIw\nNmFmNGRkN2Q2Nzg5NwY7AFRJIhF0aW1lem9uZXByZWYGOwBUSSIfRWFzdGVy\nbiBUaW1lIChVUyAmIENhbmFkYSkGOwBUSSIPcHVibGljX2tleQY7AFQwSSIT\nY29weV9vZl9lbWFpbHMGOwBUaQA6FkBhZGRpdGlvbmFsX3R5cGVzewA6EkBt\nYXRlcmlhbGl6ZWRGOhNAZGVsZWdhdGVfaGFzaHsJSSIRdGltZXpvbmVwcmVm\nBjsAVG86KkFjdGl2ZVJlY29yZDo6QXR0cmlidXRlOjpGcm9tRGF0YWJhc2UJ\nOgpAbmFtZUkiEXRpbWV6b25lcHJlZgY7AFQ6HEB2YWx1ZV9iZWZvcmVfdHlw\nZV9jYXN0QEs6CkB0eXBlQBM6C0B2YWx1ZUkiH0Vhc3Rlcm4gVGltZSAoVVMg\nJiBDYW5hZGEpBjsAVEkiB2lkBjsARm87HAk7HUkiB2lkBjsARjseaQc7H0AO\nOyBpB0kiDHJvbGVfaWQGOwBGbzscCTsdSSIMcm9sZV9pZAY7AEY7HmkGOx9A\nDjsgaQZJIgluYW1lBjsAVG87HAk7HUkiCW5hbWUGOwBUOx5AMjsfQBM7IEki\nDXN0dWRlbnQxBjsAVDoXQGFnZ3JlZ2F0aW9uX2NhY2hlewA6F0Bhc3NvY2lh\ndGlvbl9jYWNoZXsGOglyb2xlVTo1QWN0aXZlUmVjb3JkOjpBc3NvY2lhdGlv\nbnM6OkJlbG9uZ3NUb0Fzc29jaWF0aW9uWwc7I1sMWwc6C0Bvd25lckAJWwc6\nDEBsb2FkZWRUWwc6DEB0YXJnZXRvOglSb2xlEjsHbzsIBjsHbzsJCjsKfQ1J\nIgdpZAY7AFRvOwsJOwwwOw0wOw5pCTsPbzsQCDsRVDsSbC0HAAAAgDsTbCsH\nAAAAgEkiCW5hbWUGOwBUbzsUCDsMMDsNMDsOaQH/SSIOcGFyZW50X2lkBjsA\nVEBrSSIQZGVzY3JpcHRpb24GOwBUQHBJIhRkZWZhdWx0X3BhZ2VfaWQGOwBU\nQGtJIgpjYWNoZQY7AFRVOiNBY3RpdmVSZWNvcmQ6OlR5cGU6OlNlcmlhbGl6\nZWRbCToLX192Ml9fWwc6DUBzdWJ0eXBlOgtAY29kZXJbB287Fgg7DDA7DTA7\nDmkC//9vOiVBY3RpdmVSZWNvcmQ6OkNvZGVyczo6WUFNTENvbHVtbgY6EkBv\nYmplY3RfY2xhc3NjC09iamVjdEB5SSIPY3JlYXRlZF9hdAY7AFRVOkpBY3Rp\ndmVSZWNvcmQ6OkF0dHJpYnV0ZU1ldGhvZHM6OlRpbWVab25lQ29udmVyc2lv\nbjo6VGltZVpvbmVDb252ZXJ0ZXJbCTsqWwBbAG86SkFjdGl2ZVJlY29yZDo6\nQ29ubmVjdGlvbkFkYXB0ZXJzOjpBYnN0cmFjdE15c3FsQWRhcHRlcjo6TXlz\ncWxEYXRlVGltZQg7DDA7DTA7DjBJIg91cGRhdGVkX2F0BjsAVFU7L1sJOypb\nAFsAQAF8bzsXCDsMMDsNMDsOMDsYew1JIgdpZAY7AFRpBkkiCW5hbWUGOwBU\nSSIMU3R1ZGVudAY7AFRJIg5wYXJlbnRfaWQGOwBUMEkiEGRlc2NyaXB0aW9u\nBjsAVEkiAAY7AFRJIhRkZWZhdWx0X3BhZ2VfaWQGOwBUMEkiCmNhY2hlBjsA\nVEkiAtYWLS0tCjpjcmVkZW50aWFsczogIXJ1Ynkvb2JqZWN0OkNyZWRlbnRp\nYWxzCiAgcm9sZV9pZDogMQogIHVwZGF0ZWRfYXQ6IDIwMTUtMTItMDQgMTk6\nNTc6NDMuMDAwMDAwMDAwIFoKICByb2xlX2lkczoKICAtIDEKICBwZXJtaXNz\naW9uX2lkczoKICAtIDYKICAtIDYKICAtIDYKICAtIDMKICAtIDMKICAtIDMK\nICAtIDIKICAtIDIKICAtIDIKICBhY3Rpb25zOgogICAgY29udGVudF9wYWdl\nczoKICAgICAgdmlld19kZWZhdWx0OiB0cnVlCiAgICAgIHZpZXc6IHRydWUK\nICAgICAgbGlzdDogZmFsc2UKICAgIGNvbnRyb2xsZXJfYWN0aW9uczoKICAg\nICAgbGlzdDogZmFsc2UKICAgIGF1dGg6CiAgICAgIGxvZ2luOiB0cnVlCiAg\nICAgIGxvZ291dDogdHJ1ZQogICAgICBsb2dpbl9mYWlsZWQ6IHRydWUKICAg\nIG1lbnVfaXRlbXM6CiAgICAgIGxpbms6IHRydWUKICAgICAgbGlzdDogZmFs\nc2UKICAgIHBlcm1pc3Npb25zOgogICAgICBsaXN0OiBmYWxzZQogICAgcm9s\nZXM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBzaXRlX2NvbnRyb2xsZXJzOgog\nICAgICBsaXN0OiBmYWxzZQogICAgc3lzdGVtX3NldHRpbmdzOgogICAgICBs\naXN0OiBmYWxzZQogICAgdXNlcnM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICAg\nIGtleXM6IHRydWUKICAgIGFkbWluOgogICAgICBsaXN0X2luc3RydWN0b3Jz\nOiBmYWxzZQogICAgICBsaXN0X2FkbWluaXN0cmF0b3JzOiBmYWxzZQogICAg\nICBsaXN0X3N1cGVyX2FkbWluaXN0cmF0b3JzOiBmYWxzZQogICAgY291cnNl\nOgogICAgICBsaXN0X2ZvbGRlcnM6IGZhbHNlCiAgICBhc3NpZ25tZW50Ogog\nICAgICBsaXN0OiBmYWxzZQogICAgcXVlc3Rpb25uYWlyZToKICAgICAgbGlz\ndDogZmFsc2UKICAgICAgY3JlYXRlX3F1ZXN0aW9ubmFpcmU6IGZhbHNlCiAg\nICAgIGVkaXRfcXVlc3Rpb25uYWlyZTogZmFsc2UKICAgICAgY29weV9xdWVz\ndGlvbm5haXJlOiBmYWxzZQogICAgICBzYXZlX3F1ZXN0aW9ubmFpcmU6IGZh\nbHNlCiAgICBwYXJ0aWNpcGFudHM6CiAgICAgIGFkZF9zdHVkZW50OiBmYWxz\nZQogICAgICBlZGl0X3RlYW1fbWVtYmVyczogZmFsc2UKICAgICAgbGlzdF9z\ndHVkZW50czogZmFsc2UKICAgICAgbGlzdF9jb3Vyc2VzOiBmYWxzZQogICAg\nICBsaXN0X2Fzc2lnbm1lbnRzOiBmYWxzZQogICAgICBjaGFuZ2VfaGFuZGxl\nOiB0cnVlCiAgICBpbnN0aXR1dGlvbjoKICAgICAgbGlzdDogZmFsc2UKICAg\nIHN0dWRlbnRfdGFzazoKICAgICAgbGlzdDogdHJ1ZQogICAgcHJvZmlsZToK\nICAgICAgZWRpdDogdHJ1ZQogICAgc3VydmV5X3Jlc3BvbnNlOgogICAgICBj\ncmVhdGU6IHRydWUKICAgICAgc3VibWl0OiB0cnVlCiAgICB0ZWFtOgogICAg\nICBsaXN0OiBmYWxzZQogICAgICBsaXN0X2Fzc2lnbm1lbnRzOiBmYWxzZQog\nICAgdGVhbXNfdXNlcnM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBpbXBlcnNv\nbmF0ZToKICAgICAgc3RhcnQ6IGZhbHNlCiAgICAgIGltcGVyc29uYXRlOiB0\ncnVlCiAgICByZXZpZXdfbWFwcGluZzoKICAgICAgbGlzdDogZmFsc2UKICAg\nICAgYWRkX2R5bmFtaWNfcmV2aWV3ZXI6IHRydWUKICAgICAgcmVsZWFzZV9y\nZXNlcnZhdGlvbjogdHJ1ZQogICAgICBzaG93X2F2YWlsYWJsZV9zdWJtaXNz\naW9uczogdHJ1ZQogICAgICBhc3NpZ25fcmV2aWV3ZXJfZHluYW1pY2FsbHk6\nIHRydWUKICAgICAgYXNzaWduX21ldGFyZXZpZXdlcl9keW5hbWljYWxseTog\ndHJ1ZQogICAgZ3JhZGVzOgogICAgICB2aWV3X215X3Njb3JlczogdHJ1ZQog\nICAgc3VydmV5X2RlcGxveW1lbnQ6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBz\ndGF0aXN0aWNzOgogICAgICBsaXN0X3N1cnZleXM6IGZhbHNlCiAgICB0cmVl\nX2Rpc3BsYXk6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICAgIGRyaWxsOiBmYWxz\nZQogICAgICBnb3RvX3F1ZXN0aW9ubmFpcmVzOiBmYWxzZQogICAgICBnb3Rv\nX2F1dGhvcl9mZWVkYmFja3M6IGZhbHNlCiAgICAgIGdvdG9fcmV2aWV3X3J1\nYnJpY3M6IGZhbHNlCiAgICAgIGdvdG9fZ2xvYmFsX3N1cnZleTogZmFsc2UK\nICAgICAgZ290b19zdXJ2ZXlzOiBmYWxzZQogICAgICBnb3RvX2NvdXJzZV9l\ndmFsdWF0aW9uczogZmFsc2UKICAgICAgZ290b19jb3Vyc2VzOiBmYWxzZQog\nICAgICBnb3RvX2Fzc2lnbm1lbnRzOiBmYWxzZQogICAgICBnb3RvX3RlYW1t\nYXRlX3Jldmlld3M6IGZhbHNlCiAgICAgIGdvdG9fbWV0YXJldmlld19ydWJy\naWNzOiBmYWxzZQogICAgICBnb3RvX3RlYW1tYXRlcmV2aWV3X3J1YnJpY3M6\nIGZhbHNlCiAgICBzaWduX3VwX3NoZWV0OgogICAgICBsaXN0OiB0cnVlCiAg\nICAgIHNpZ251cDogdHJ1ZQogICAgICBkZWxldGVfc2lnbnVwOiB0cnVlCiAg\nICBzdWdnZXN0aW9uOgogICAgICBjcmVhdGU6IHRydWUKICAgICAgbmV3OiB0\ncnVlCiAgICBsZWFkZXJib2FyZDoKICAgICAgaW5kZXg6IHRydWUKICAgIGFk\ndmljZToKICAgICAgZWRpdF9hZHZpY2U6IGZhbHNlCiAgICAgIHNhdmVfYWR2\naWNlOiBmYWxzZQogICAgYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyOgogICAgICBh\nZGRfYWR2ZXJ0aXNlX2NvbW1lbnQ6IHRydWUKICAgICAgZWRpdDogdHJ1ZQog\nICAgICBuZXc6IHRydWUKICAgICAgcmVtb3ZlOiB0cnVlCiAgICAgIHVwZGF0\nZTogdHJ1ZQogICAgam9pbl90ZWFtX3JlcXVlc3RzOgogICAgICBjcmVhdGU6\nIHRydWUKICAgICAgZGVjbGluZTogdHJ1ZQogICAgICBkZXN0cm95OiB0cnVl\nCiAgICAgIGVkaXQ6IHRydWUKICAgICAgaW5kZXg6IHRydWUKICAgICAgbmV3\nOiB0cnVlCiAgICAgIHNob3c6IHRydWUKICAgICAgdXBkYXRlOiB0cnVlCiAg\nY29udHJvbGxlcnM6CiAgICBjb250ZW50X3BhZ2VzOiBmYWxzZQogICAgY29u\ndHJvbGxlcl9hY3Rpb25zOiBmYWxzZQogICAgYXV0aDogZmFsc2UKICAgIG1h\ncmt1cF9zdHlsZXM6IGZhbHNlCiAgICBtZW51X2l0ZW1zOiBmYWxzZQogICAg\ncGVybWlzc2lvbnM6IGZhbHNlCiAgICByb2xlczogZmFsc2UKICAgIHNpdGVf\nY29udHJvbGxlcnM6IGZhbHNlCiAgICBzeXN0ZW1fc2V0dGluZ3M6IGZhbHNl\nCiAgICB1c2VyczogdHJ1ZQogICAgcm9sZXNfcGVybWlzc2lvbnM6IGZhbHNl\nCiAgICBhZG1pbjogZmFsc2UKICAgIGNvdXJzZTogZmFsc2UKICAgIGFzc2ln\nbm1lbnQ6IGZhbHNlCiAgICBxdWVzdGlvbm5haXJlOiBmYWxzZQogICAgYWR2\naWNlOiBmYWxzZQogICAgcGFydGljaXBhbnRzOiBmYWxzZQogICAgcmVwb3J0\nczogdHJ1ZQogICAgaW5zdGl0dXRpb246IGZhbHNlCiAgICBzdHVkZW50X3Rh\nc2s6IHRydWUKICAgIHByb2ZpbGU6IHRydWUKICAgIHN1cnZleV9yZXNwb25z\nZTogdHJ1ZQogICAgdGVhbTogZmFsc2UKICAgIHRlYW1zX3VzZXJzOiBmYWxz\nZQogICAgaW1wZXJzb25hdGU6IGZhbHNlCiAgICBpbXBvcnRfZmlsZTogZmFs\nc2UKICAgIHJldmlld19tYXBwaW5nOiBmYWxzZQogICAgZ3JhZGVzOiBmYWxz\nZQogICAgY291cnNlX2V2YWx1YXRpb246IHRydWUKICAgIHBhcnRpY2lwYW50\nX2Nob2ljZXM6IGZhbHNlCiAgICBzdXJ2ZXlfZGVwbG95bWVudDogZmFsc2UK\nICAgIHN0YXRpc3RpY3M6IGZhbHNlCiAgICB0cmVlX2Rpc3BsYXk6IGZhbHNl\nCiAgICBzdHVkZW50X3RlYW06IHRydWUKICAgIGludml0YXRpb246IHRydWUK\nICAgIHN1cnZleTogZmFsc2UKICAgIHBhc3N3b3JkX3JldHJpZXZhbDogdHJ1\nZQogICAgc3VibWl0dGVkX2NvbnRlbnQ6IHRydWUKICAgIGV1bGE6IHRydWUK\nICAgIHN0dWRlbnRfcmV2aWV3OiB0cnVlCiAgICBwdWJsaXNoaW5nOiB0cnVl\nCiAgICBleHBvcnRfZmlsZTogZmFsc2UKICAgIHJlc3BvbnNlOiB0cnVlCiAg\nICBzaWduX3VwX3NoZWV0OiBmYWxzZQogICAgc3VnZ2VzdGlvbjogZmFsc2UK\nICAgIGxlYWRlcmJvYXJkOiB0cnVlCiAgICBkZWxldGVfb2JqZWN0OiBmYWxz\nZQogICAgYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyOiB0cnVlCiAgICBqb2luX3Rl\nYW1fcmVxdWVzdHM6IHRydWUKICBwYWdlczoKICAgIGhvbWU6IHRydWUKICAg\nIGV4cGlyZWQ6IHRydWUKICAgIG5vdGZvdW5kOiB0cnVlCiAgICBkZW5pZWQ6\nIHRydWUKICAgIGNvbnRhY3RfdXM6IHRydWUKICAgIHNpdGVfYWRtaW46IGZh\nbHNlCiAgICBhZG1pbjogZmFsc2UKICAgIGNyZWRpdHM6IHRydWUKOm1lbnU6\nICFydWJ5L29iamVjdDpNZW51CiAgcm9vdDogJjcgIXJ1Ynkvb2JqZWN0Ok1l\nbnU6Ok5vZGUKICAgIHBhcmVudDogCiAgICBjaGlsZHJlbjoKICAgIC0gMQog\nICAgLSA1CiAgICAtIDYKICAgIC0gNwogIGJ5X2lkOgogICAgMTogJjEgIXJ1\nYnkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgY2hp\nbGRyZW46CiAgICAgIC0gOAogICAgICBwYXJlbnRfaWQ6IAogICAgICBuYW1l\nOiBob21lCiAgICAgIGlkOiAxCiAgICAgIGxhYmVsOiBIb21lCiAgICAgIHNp\ndGVfY29udHJvbGxlcl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lk\nOiAKICAgICAgY29udGVudF9wYWdlX2lkOiAxCiAgICAgIHVybDogIi9ob21l\nIgogICAgNTogJjIgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFy\nZW50OiAKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTogc3R1ZGVudF90\nYXNrCiAgICAgIGlkOiA1CiAgICAgIGxhYmVsOiBBc3NpZ25tZW50cwogICAg\nICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDIwCiAgICAgIGNvbnRyb2xsZXJfYWN0\naW9uX2lkOiAzMwogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6\nICIvc3R1ZGVudF90YXNrL2xpc3QiCiAgICA2OiAmMyAhcnVieS9vYmplY3Q6\nTWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IAog\nICAgICBuYW1lOiBwcm9maWxlCiAgICAgIGlkOiA2CiAgICAgIGxhYmVsOiBQ\ncm9maWxlCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMjEKICAgICAgY29u\ndHJvbGxlcl9hY3Rpb25faWQ6IDM0CiAgICAgIGNvbnRlbnRfcGFnZV9pZDog\nCiAgICAgIHVybDogIi9wcm9maWxlL2VkaXQiCiAgICA3OiAmNCAhcnVieS9v\nYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBjaGlsZHJl\nbjoKICAgICAgLSA5CiAgICAgIHBhcmVudF9pZDogCiAgICAgIG5hbWU6IGNv\nbnRhY3RfdXMKICAgICAgaWQ6IDcKICAgICAgbGFiZWw6IENvbnRhY3QgVXMK\nICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAKICAgICAgY29udHJvbGxlcl9h\nY3Rpb25faWQ6IAogICAgICBjb250ZW50X3BhZ2VfaWQ6IDUKICAgICAgdXJs\nOiAiL2NvbnRhY3RfdXMiCiAgICA4OiAmNSAhcnVieS9vYmplY3Q6TWVudTo6\nTm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IDEKICAgICAg\nbmFtZTogbGVhZGVyYm9hcmQKICAgICAgaWQ6IDgKICAgICAgbGFiZWw6IExl\nYWRlcmJvYXJkCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogNDYKICAgICAg\nY29udHJvbGxlcl9hY3Rpb25faWQ6IDY5CiAgICAgIGNvbnRlbnRfcGFnZV9p\nZDogCiAgICAgIHVybDogIi9sZWFkZXJib2FyZC9pbmRleCIKICAgIDk6ICY2\nICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAg\nIHBhcmVudF9pZDogNwogICAgICBuYW1lOiBjcmVkaXRzCiAgICAgIGlkOiA5\nCiAgICAgIGxhYmVsOiBDcmVkaXRzICZhbXA7IExpY2VuY2UKICAgICAgc2l0\nZV9jb250cm9sbGVyX2lkOiAKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6\nIAogICAgICBjb250ZW50X3BhZ2VfaWQ6IDgKICAgICAgdXJsOiAiL2NyZWRp\ndHMiCiAgYnlfbmFtZToKICAgIGhvbWU6ICoxCiAgICBzdHVkZW50X3Rhc2s6\nICoyCiAgICBwcm9maWxlOiAqMwogICAgY29udGFjdF91czogKjQKICAgIGxl\nYWRlcmJvYXJkOiAqNQogICAgY3JlZGl0czogKjYKICBzZWxlY3RlZDoKICAg\nIDE6ICoxCiAgdmVjdG9yOgogIC0gKjcKICAtICoxCiAgY3J1bWJzOgogIC0g\nMQoGOwBUSSIPY3JlYXRlZF9hdAY7AFRJdToJVGltZQ2T7BzAAAAA4AY6CXpv\nbmVJIghVVEMGOwBGSSIPdXBkYXRlZF9hdAY7AFRJdTsxDZPsHMAAAMDmBjsy\nSSIIVVRDBjsARjsZewA7GkY7G3sGSSIJbmFtZQY7AFRvOxwJOx1AXDseQAGG\nOx9AcDsgSSIMU3R1ZGVudAY7AFQ7IXsAOyJ7ADoOQHJlYWRvbmx5RjoPQGRl\nc3Ryb3llZEY6HEBtYXJrZWRfZm9yX2Rlc3RydWN0aW9uRjoeQGRlc3Ryb3ll\nZF9ieV9hc3NvY2lhdGlvbjA6EEBuZXdfcmVjb3JkRjoJQHR4bjA6HkBfc3Rh\ncnRfdHJhbnNhY3Rpb25fc3RhdGV7ADoXQHRyYW5zYWN0aW9uX3N0YXRlMDoU\nQHJlZmxlY3RzX3N0YXRlWwZGOh1AbWFzc19hc3NpZ25tZW50X29wdGlvbnMw\nWwc6EUBzdGFsZV9zdGF0ZUkiBjEGOwBGWwc6DkBpbnZlcnNlZEZbBzoNQHVw\nZGF0ZWRGWwc6F0Bhc3NvY2lhdGlvbl9zY29wZW86IFJvbGU6OkFjdGl2ZVJl\nY29yZF9SZWxhdGlvbhI6C0BrbGFzc2MJUm9sZToLQHRhYmxlbzoQQXJlbDo6\nVGFibGULOx1JIgpyb2xlcwY7AFQ6DEBlbmdpbmVAAaI6DUBjb2x1bW5zMDoN\nQGFsaWFzZXNbADoRQHRhYmxlX2FsaWFzMDoRQHByaW1hcnlfa2V5MDsYewg6\nDmV4dGVuZGluZ1sAOgliaW5kWwZbB286Q0FjdGl2ZVJlY29yZDo6Q29ubmVj\ndGlvbkFkYXB0ZXJzOjpBYnN0cmFjdE15c3FsQWRhcHRlcjo6Q29sdW1uDjoM\nQHN0cmljdFQ6D0Bjb2xsYXRpb24wOgtAZXh0cmFJIhNhdXRvX2luY3JlbWVu\ndAY7AFQ7HUkiB2lkBjsAVDoPQGNhc3RfdHlwZUBrOg5Ac3FsX3R5cGVJIgxp\nbnQoMTEpBjsAVDoKQG51bGxGOg1AZGVmYXVsdDA6FkBkZWZhdWx0X2Z1bmN0\naW9uMGkGOgp3aGVyZVsGbzoaQXJlbDo6Tm9kZXM6OkVxdWFsaXR5BzoKQGxl\nZnRTOiBBcmVsOjpBdHRyaWJ1dGVzOjpBdHRyaWJ1dGUHOg1yZWxhdGlvbm87\nRAs7HUABpDtFYxdBY3RpdmVSZWNvcmQ6OkJhc2U7RjA7R1sAO0gwO0kwOglu\nYW1lSSIHaWQGOwBUOgtAcmlnaHRvOhtBcmVsOjpOb2Rlczo6QmluZFBhcmFt\nADoNQG9mZnNldHN7ADsmMDoKQGFyZWxvOhhBcmVsOjpTZWxlY3RNYW5hZ2Vy\nCTtFQAGiOglAY3R4bzocQXJlbDo6Tm9kZXM6OlNlbGVjdENvcmUNOgxAc291\ncmNlbzocQXJlbDo6Tm9kZXM6OkpvaW5Tb3VyY2UHO1dAAaM7W1sAOglAdG9w\nMDoUQHNldF9xdWFudGlmaWVyMDoRQHByb2plY3Rpb25zWwZTO1gHO1lAAaM7\nWklDOhxBcmVsOjpOb2Rlczo6U3FsTGl0ZXJhbCIGKgY7AFQ6DEB3aGVyZXNb\nBm86FUFyZWw6Ok5vZGVzOjpBbmQGOg5AY2hpbGRyZW5bBkABrzoMQGdyb3Vw\nc1sAOgxAaGF2aW5nMDoNQHdpbmRvd3NbADoRQGJpbmRfdmFsdWVzWwA6CUBh\nc3RvOiFBcmVsOjpOb2Rlczo6U2VsZWN0U3RhdGVtZW50CzoLQGNvcmVzWwZA\nAbg6DEBvcmRlcnNbADsOMDoKQGxvY2swOgxAb2Zmc2V0MDoKQHdpdGgwOhZA\nc2NvcGVfZm9yX2NyZWF0ZTA6EkBvcmRlcl9jbGF1c2UwOgxAdG9fc3FsMDoK\nQGxhc3QwOhVAam9pbl9kZXBlbmRlbmN5MDoXQHNob3VsZF9lYWdlcl9sb2Fk\nMDoNQHJlY29yZHNbADszRjs0Rjs1Rjs2MDs3Rjs4MDs5ewA7OjA7O1sGRjs8\nMEkiEGNyZWRlbnRpYWxzBjsARm86EENyZWRlbnRpYWxzDDoNQHJvbGVfaWRp\nBjoQQHVwZGF0ZWRfYXRJdTsxDZPsHMAAALDmBjsySSIIVVRDBjsARjoOQHJv\nbGVfaWRzWwZpBjoUQHBlcm1pc3Npb25faWRzWw5pC2kLaQtpCGkIaQhpB2kH\naQc6DUBhY3Rpb25zeyVJIhJjb250ZW50X3BhZ2VzBjsAVHsISSIRdmlld19k\nZWZhdWx0BjsAVFRJIgl2aWV3BjsAVFRJIglsaXN0BjsAVEZJIhdjb250cm9s\nbGVyX2FjdGlvbnMGOwBUewZJIglsaXN0BjsAVEZJIglhdXRoBjsAVHsISSIK\nbG9naW4GOwBUVEkiC2xvZ291dAY7AFRUSSIRbG9naW5fZmFpbGVkBjsAVFRJ\nIg9tZW51X2l0ZW1zBjsAVHsHSSIJbGluawY7AFRUSSIJbGlzdAY7AFRGSSIQ\ncGVybWlzc2lvbnMGOwBUewZJIglsaXN0BjsAVEZJIgpyb2xlcwY7AFR7Bkki\nCWxpc3QGOwBURkkiFXNpdGVfY29udHJvbGxlcnMGOwBUewZJIglsaXN0BjsA\nVEZJIhRzeXN0ZW1fc2V0dGluZ3MGOwBUewZJIglsaXN0BjsAVEZJIgp1c2Vy\ncwY7AFR7B0kiCWxpc3QGOwBURkkiCWtleXMGOwBUVEkiCmFkbWluBjsAVHsI\nSSIVbGlzdF9pbnN0cnVjdG9ycwY7AFRGSSIYbGlzdF9hZG1pbmlzdHJhdG9y\ncwY7AFRGSSIebGlzdF9zdXBlcl9hZG1pbmlzdHJhdG9ycwY7AFRGSSILY291\ncnNlBjsAVHsGSSIRbGlzdF9mb2xkZXJzBjsAVEZJIg9hc3NpZ25tZW50BjsA\nVHsGSSIJbGlzdAY7AFRGSSIScXVlc3Rpb25uYWlyZQY7AFR7CkkiCWxpc3QG\nOwBURkkiGWNyZWF0ZV9xdWVzdGlvbm5haXJlBjsAVEZJIhdlZGl0X3F1ZXN0\naW9ubmFpcmUGOwBURkkiF2NvcHlfcXVlc3Rpb25uYWlyZQY7AFRGSSIXc2F2\nZV9xdWVzdGlvbm5haXJlBjsAVEZJIhFwYXJ0aWNpcGFudHMGOwBUewtJIhBh\nZGRfc3R1ZGVudAY7AFRGSSIWZWRpdF90ZWFtX21lbWJlcnMGOwBURkkiEmxp\nc3Rfc3R1ZGVudHMGOwBURkkiEWxpc3RfY291cnNlcwY7AFRGSSIVbGlzdF9h\nc3NpZ25tZW50cwY7AFRGSSISY2hhbmdlX2hhbmRsZQY7AFRUSSIQaW5zdGl0\ndXRpb24GOwBUewZJIglsaXN0BjsAVEZJIhFzdHVkZW50X3Rhc2sGOwBUewZJ\nIglsaXN0BjsAVFRJIgxwcm9maWxlBjsAVHsGSSIJZWRpdAY7AFRUSSIUc3Vy\ndmV5X3Jlc3BvbnNlBjsAVHsHSSILY3JlYXRlBjsAVFRJIgtzdWJtaXQGOwBU\nVEkiCXRlYW0GOwBUewdJIglsaXN0BjsAVEZJIhVsaXN0X2Fzc2lnbm1lbnRz\nBjsAVEZJIhB0ZWFtc191c2VycwY7AFR7BkkiCWxpc3QGOwBURkkiEGltcGVy\nc29uYXRlBjsAVHsHSSIKc3RhcnQGOwBURkkiEGltcGVyc29uYXRlBjsAVFRJ\nIhNyZXZpZXdfbWFwcGluZwY7AFR7C0kiCWxpc3QGOwBURkkiGWFkZF9keW5h\nbWljX3Jldmlld2VyBjsAVFRJIhhyZWxlYXNlX3Jlc2VydmF0aW9uBjsAVFRJ\nIh9zaG93X2F2YWlsYWJsZV9zdWJtaXNzaW9ucwY7AFRUSSIgYXNzaWduX3Jl\ndmlld2VyX2R5bmFtaWNhbGx5BjsAVFRJIiRhc3NpZ25fbWV0YXJldmlld2Vy\nX2R5bmFtaWNhbGx5BjsAVFRJIgtncmFkZXMGOwBUewZJIhN2aWV3X215X3Nj\nb3JlcwY7AFRUSSIWc3VydmV5X2RlcGxveW1lbnQGOwBUewZJIglsaXN0BjsA\nVEZJIg9zdGF0aXN0aWNzBjsAVHsGSSIRbGlzdF9zdXJ2ZXlzBjsAVEZJIhF0\ncmVlX2Rpc3BsYXkGOwBUexJJIglsaXN0BjsAVEZJIgpkcmlsbAY7AFRGSSIY\nZ290b19xdWVzdGlvbm5haXJlcwY7AFRGSSIaZ290b19hdXRob3JfZmVlZGJh\nY2tzBjsAVEZJIhhnb3RvX3Jldmlld19ydWJyaWNzBjsAVEZJIhdnb3RvX2ds\nb2JhbF9zdXJ2ZXkGOwBURkkiEWdvdG9fc3VydmV5cwY7AFRGSSIcZ290b19j\nb3Vyc2VfZXZhbHVhdGlvbnMGOwBURkkiEWdvdG9fY291cnNlcwY7AFRGSSIV\nZ290b19hc3NpZ25tZW50cwY7AFRGSSIaZ290b190ZWFtbWF0ZV9yZXZpZXdz\nBjsAVEZJIhxnb3RvX21ldGFyZXZpZXdfcnVicmljcwY7AFRGSSIgZ290b190\nZWFtbWF0ZXJldmlld19ydWJyaWNzBjsAVEZJIhJzaWduX3VwX3NoZWV0BjsA\nVHsISSIJbGlzdAY7AFRUSSILc2lnbnVwBjsAVFRJIhJkZWxldGVfc2lnbnVw\nBjsAVFRJIg9zdWdnZXN0aW9uBjsAVHsHSSILY3JlYXRlBjsAVFRJIghuZXcG\nOwBUVEkiEGxlYWRlcmJvYXJkBjsAVHsGSSIKaW5kZXgGOwBUVEkiC2Fkdmlj\nZQY7AFR7B0kiEGVkaXRfYWR2aWNlBjsAVEZJIhBzYXZlX2FkdmljZQY7AFRG\nSSIaYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyBjsAVHsKSSIaYWRkX2FkdmVydGlz\nZV9jb21tZW50BjsAVFRJIgllZGl0BjsAVFRJIghuZXcGOwBUVEkiC3JlbW92\nZQY7AFRUSSILdXBkYXRlBjsAVFRJIhdqb2luX3RlYW1fcmVxdWVzdHMGOwBU\new1JIgtjcmVhdGUGOwBUVEkiDGRlY2xpbmUGOwBUVEkiDGRlc3Ryb3kGOwBU\nVEkiCWVkaXQGOwBUVEkiCmluZGV4BjsAVFRJIghuZXcGOwBUVEkiCXNob3cG\nOwBUVEkiC3VwZGF0ZQY7AFRUOhFAY29udHJvbGxlcnN7NkkiEmNvbnRlbnRf\ncGFnZXMGOwBURkkiF2NvbnRyb2xsZXJfYWN0aW9ucwY7AFRGSSIJYXV0aAY7\nAFRGSSISbWFya3VwX3N0eWxlcwY7AFRGSSIPbWVudV9pdGVtcwY7AFRGSSIQ\ncGVybWlzc2lvbnMGOwBURkkiCnJvbGVzBjsAVEZJIhVzaXRlX2NvbnRyb2xs\nZXJzBjsAVEZJIhRzeXN0ZW1fc2V0dGluZ3MGOwBURkkiCnVzZXJzBjsAVFRJ\nIhZyb2xlc19wZXJtaXNzaW9ucwY7AFRGSSIKYWRtaW4GOwBURkkiC2NvdXJz\nZQY7AFRGSSIPYXNzaWdubWVudAY7AFRGSSIScXVlc3Rpb25uYWlyZQY7AFRG\nSSILYWR2aWNlBjsAVEZJIhFwYXJ0aWNpcGFudHMGOwBURkkiDHJlcG9ydHMG\nOwBUVEkiEGluc3RpdHV0aW9uBjsAVEZJIhFzdHVkZW50X3Rhc2sGOwBUVEki\nDHByb2ZpbGUGOwBUVEkiFHN1cnZleV9yZXNwb25zZQY7AFRUSSIJdGVhbQY7\nAFRGSSIQdGVhbXNfdXNlcnMGOwBURkkiEGltcGVyc29uYXRlBjsAVEZJIhBp\nbXBvcnRfZmlsZQY7AFRGSSITcmV2aWV3X21hcHBpbmcGOwBURkkiC2dyYWRl\ncwY7AFRGSSIWY291cnNlX2V2YWx1YXRpb24GOwBUVEkiGHBhcnRpY2lwYW50\nX2Nob2ljZXMGOwBURkkiFnN1cnZleV9kZXBsb3ltZW50BjsAVEZJIg9zdGF0\naXN0aWNzBjsAVEZJIhF0cmVlX2Rpc3BsYXkGOwBURkkiEXN0dWRlbnRfdGVh\nbQY7AFRUSSIPaW52aXRhdGlvbgY7AFRUSSILc3VydmV5BjsAVEZJIhdwYXNz\nd29yZF9yZXRyaWV2YWwGOwBUVEkiFnN1Ym1pdHRlZF9jb250ZW50BjsAVFRJ\nIglldWxhBjsAVFRJIhNzdHVkZW50X3JldmlldwY7AFRUSSIPcHVibGlzaGlu\nZwY7AFRUSSIQZXhwb3J0X2ZpbGUGOwBURkkiDXJlc3BvbnNlBjsAVFRJIhJz\naWduX3VwX3NoZWV0BjsAVEZJIg9zdWdnZXN0aW9uBjsAVEZJIhBsZWFkZXJi\nb2FyZAY7AFRUSSISZGVsZXRlX29iamVjdAY7AFRGSSIaYWR2ZXJ0aXNlX2Zv\ncl9wYXJ0bmVyBjsAVFRJIhdqb2luX3RlYW1fcmVxdWVzdHMGOwBUVDoLQHBh\nZ2Vzew1JIglob21lBjsAVFRJIgxleHBpcmVkBjsAVFRJIg1ub3Rmb3VuZAY7\nAFRUSSILZGVuaWVkBjsAVFRJIg9jb250YWN0X3VzBjsAVFRJIg9zaXRlX2Fk\nbWluBjsAVEZJIgphZG1pbgY7AFRGSSIMY3JlZGl0cwY7AFRUSSIJbWVudQY7\nAEZvOglNZW51CzoKQHJvb3RvOg9NZW51OjpOb2RlBzoMQHBhcmVudDA7alsJ\naQZpCmkLaQw6C0BieV9pZHsLaQZvOwGCDzsBgzA7alsGaQ06D0BwYXJlbnRf\naWQwOx1JIglob21lBjsAVDoIQGlkaQY6C0BsYWJlbEkiCUhvbWUGOwBUOhhA\nc2l0ZV9jb250cm9sbGVyX2lkMDoaQGNvbnRyb2xsZXJfYWN0aW9uX2lkMDoV\nQGNvbnRlbnRfcGFnZV9pZGkGOglAdXJsSSIKL2hvbWUGOwBUaQpvOwGCDjsB\ngzA7AYUwOx1JIhFzdHVkZW50X3Rhc2sGOwBUOwGGaQo7AYdJIhBBc3NpZ25t\nZW50cwY7AFQ7AYhpGTsBiWkmOwGKMDsBi0kiFy9zdHVkZW50X3Rhc2svbGlz\ndAY7AFRpC287AYIOOwGDMDsBhTA7HUkiDHByb2ZpbGUGOwBUOwGGaQs7AYdJ\nIgxQcm9maWxlBjsAVDsBiGkaOwGJaSc7AYowOwGLSSISL3Byb2ZpbGUvZWRp\ndAY7AFRpDG87AYIPOwGDMDtqWwZpDjsBhTA7HUkiD2NvbnRhY3RfdXMGOwBU\nOwGGaQw7AYdJIg9Db250YWN0IFVzBjsAVDsBiDA7AYkwOwGKaQo7AYtJIhAv\nY29udGFjdF91cwY7AFRpDW87AYIOOwGDMDsBhWkGOx1JIhBsZWFkZXJib2Fy\nZAY7AFQ7AYZpDTsBh0kiEExlYWRlcmJvYXJkBjsAVDsBiGkzOwGJaUo7AYow\nOwGLSSIXL2xlYWRlcmJvYXJkL2luZGV4BjsAVGkObzsBgg47AYMwOwGFaQw7\nHUkiDGNyZWRpdHMGOwBUOwGGaQ47AYdJIhpDcmVkaXRzICZhbXA7IExpY2Vu\nY2UGOwBUOwGIMDsBiTA7AYppDTsBi0kiDS9jcmVkaXRzBjsAVDoNQGJ5X25h\nbWV7C0kiCWhvbWUGOwBUQAKlAUkiEXN0dWRlbnRfdGFzawY7AFRAAqoBSSIM\ncHJvZmlsZQY7AFRAAq4BSSIPY29udGFjdF91cwY7AFRAArIBSSIQbGVhZGVy\nYm9hcmQGOwBUQAK3AUkiDGNyZWRpdHMGOwBUQAK7AToOQHNlbGVjdGVkewZp\nBkACpQE6DEB2ZWN0b3JbB0ACogFAAqUBOgxAY3J1bWJzWwZpBkkiDnJldHVy\nbl90bwY7AEZJIj5odHRwOi8vMTI3LjAuMC4xOjQzMTQ0L3NpZ25fdXBfc2hl\nZXQvbGlzdD9hc3NpZ25tZW50X2lkPTEGOwBU\n','2015-12-12 21:22:16','2015-12-12 21:22:31'),(5,'1bcc2d3f40ee8b24fefe15f8becc07ee','BAh7C0kiEF9jc3JmX3Rva2VuBjoGRUZJIjFtZDlIT3Vhc1owNWZ3Y1ZwT094\nampRSlE5NHBvTlNzQWllaEhlNE9QQ3RJPQY7AEZJIgl1c2VyBjsARm86CVVz\nZXISOhBAYXR0cmlidXRlc286H0FjdGl2ZVJlY29yZDo6QXR0cmlidXRlU2V0\nBjsHbzokQWN0aXZlUmVjb3JkOjpMYXp5QXR0cmlidXRlSGFzaAo6C0B0eXBl\nc30bSSIHaWQGOwBUbzogQWN0aXZlUmVjb3JkOjpUeXBlOjpJbnRlZ2VyCToP\nQHByZWNpc2lvbjA6C0BzY2FsZTA6C0BsaW1pdGkJOgtAcmFuZ2VvOgpSYW5n\nZQg6CWV4Y2xUOgpiZWdpbmwtBwAAAIA6CGVuZGwrBwAAAIBJIgluYW1lBjsA\nVG86SEFjdGl2ZVJlY29yZDo6Q29ubmVjdGlvbkFkYXB0ZXJzOjpBYnN0cmFj\ndE15c3FsQWRhcHRlcjo6TXlzcWxTdHJpbmcIOwwwOw0wOw5pAf9JIhVjcnlw\ndGVkX3Bhc3N3b3JkBjsAVG87FAg7DDA7DTA7DmktSSIMcm9sZV9pZAY7AFRA\nDkkiEnBhc3N3b3JkX3NhbHQGOwBUQBNJIg1mdWxsbmFtZQY7AFRAE0kiCmVt\nYWlsBjsAVEATSSIOcGFyZW50X2lkBjsAVEAOSSIXcHJpdmF0ZV9ieV9kZWZh\ndWx0BjsAVG86IEFjdGl2ZVJlY29yZDo6VHlwZTo6Qm9vbGVhbgg7DDA7DTA7\nDmkGSSIXbXJ1X2RpcmVjdG9yeV9wYXRoBjsAVG87FAg7DDA7DTA7DmkBgEki\nFGVtYWlsX29uX3JldmlldwY7AFRAHEkiGGVtYWlsX29uX3N1Ym1pc3Npb24G\nOwBUQBxJIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsAVEAcSSIQaXNf\nbmV3X3VzZXIGOwBUQBxJIh5tYXN0ZXJfcGVybWlzc2lvbl9ncmFudGVkBjsA\nVG87Cwk7DDA7DTA7DmkGOw9vOxAIOxFUOxJp/4A7E2kBgEkiC2hhbmRsZQY7\nAFRAE0kiGGxlYWRlcmJvYXJkX3ByaXZhY3kGOwBUQBxJIhhkaWdpdGFsX2Nl\ncnRpZmljYXRlBjsAVG86HUFjdGl2ZVJlY29yZDo6VHlwZTo6VGV4dAg7DDA7\nDTA7DmkC//9JIhZwZXJzaXN0ZW5jZV90b2tlbgY7AFRAE0kiEXRpbWV6b25l\ncHJlZgY7AFRAE0kiD3B1YmxpY19rZXkGOwBUQClJIhNjb3B5X29mX2VtYWls\ncwY7AFRAHG86HkFjdGl2ZVJlY29yZDo6VHlwZTo6VmFsdWUIOwwwOw0wOw4w\nOgxAdmFsdWVzextJIgdpZAY7AFRpB0kiCW5hbWUGOwBUSSINc3R1ZGVudDEG\nOwBUSSIVY3J5cHRlZF9wYXNzd29yZAY7AFRJIi1iNjczYWEwYjFhNmY1NGZk\nNGM2M2Q0YjlmMWNlY2FmZjBiNzM5OGJlBjsAVEkiDHJvbGVfaWQGOwBUaQZJ\nIhJwYXNzd29yZF9zYWx0BjsAVEkiF0t0a0lMbEZaWGRmY1RGcHcyNQY7AFRJ\nIg1mdWxsbmFtZQY7AFRJIhFTdHVkZW50LCBPbmUGOwBUSSIKZW1haWwGOwBU\nSSIWc3R1ZGVudDFAbmNzdS5lZHUGOwBUSSIOcGFyZW50X2lkBjsAVGkGSSIX\ncHJpdmF0ZV9ieV9kZWZhdWx0BjsAVGkASSIXbXJ1X2RpcmVjdG9yeV9wYXRo\nBjsAVDBJIhRlbWFpbF9vbl9yZXZpZXcGOwBUMEkiGGVtYWlsX29uX3N1Ym1p\nc3Npb24GOwBUMEkiHmVtYWlsX29uX3Jldmlld19vZl9yZXZpZXcGOwBUMEki\nEGlzX25ld191c2VyBjsAVGkASSIebWFzdGVyX3Blcm1pc3Npb25fZ3JhbnRl\nZAY7AFRpAEkiC2hhbmRsZQY7AFRJIgAGOwBUSSIYbGVhZGVyYm9hcmRfcHJp\ndmFjeQY7AFRpAEkiGGRpZ2l0YWxfY2VydGlmaWNhdGUGOwBUMEkiFnBlcnNp\nc3RlbmNlX3Rva2VuBjsAVEkiAYBjYWNjOGM5Yzc3N2U2N2Q0NGUyYWI0N2Q4\nYjVmOWIyMmZmNzdkNzA4ZGUwM2VmNzJlZDQ3MjMwZmQ1MGJhZGM4MWJhZWUz\nNWU5ZDM3ZjBlYzc1NDkxNjgzMmIxZDE3ZjVkNDMzYmM1MzI1NzRiNGRhMjIw\nNmFmNGRkN2Q2Nzg5NwY7AFRJIhF0aW1lem9uZXByZWYGOwBUSSIfRWFzdGVy\nbiBUaW1lIChVUyAmIENhbmFkYSkGOwBUSSIPcHVibGljX2tleQY7AFQwSSIT\nY29weV9vZl9lbWFpbHMGOwBUaQA6FkBhZGRpdGlvbmFsX3R5cGVzewA6EkBt\nYXRlcmlhbGl6ZWRGOhNAZGVsZWdhdGVfaGFzaHsJSSIRdGltZXpvbmVwcmVm\nBjsAVG86KkFjdGl2ZVJlY29yZDo6QXR0cmlidXRlOjpGcm9tRGF0YWJhc2UJ\nOgpAbmFtZUkiEXRpbWV6b25lcHJlZgY7AFQ6HEB2YWx1ZV9iZWZvcmVfdHlw\nZV9jYXN0QEs6CkB0eXBlQBM6C0B2YWx1ZUkiH0Vhc3Rlcm4gVGltZSAoVVMg\nJiBDYW5hZGEpBjsAVEkiB2lkBjsARm87HAk7HUkiB2lkBjsARjseaQc7H0AO\nOyBpB0kiDHJvbGVfaWQGOwBGbzscCTsdSSIMcm9sZV9pZAY7AEY7HmkGOx9A\nDjsgaQZJIgluYW1lBjsAVG87HAk7HUkiCW5hbWUGOwBUOx5AMjsfQBM7IEki\nDXN0dWRlbnQxBjsAVDoXQGFnZ3JlZ2F0aW9uX2NhY2hlewA6F0Bhc3NvY2lh\ndGlvbl9jYWNoZXsGOglyb2xlVTo1QWN0aXZlUmVjb3JkOjpBc3NvY2lhdGlv\nbnM6OkJlbG9uZ3NUb0Fzc29jaWF0aW9uWwc7I1sMWwc6C0Bvd25lckAJWwc6\nDEBsb2FkZWRUWwc6DEB0YXJnZXRvOglSb2xlEjsHbzsIBjsHbzsJCjsKfQ1J\nIgdpZAY7AFRvOwsJOwwwOw0wOw5pCTsPbzsQCDsRVDsSbC0HAAAAgDsTbCsH\nAAAAgEkiCW5hbWUGOwBUbzsUCDsMMDsNMDsOaQH/SSIOcGFyZW50X2lkBjsA\nVEBrSSIQZGVzY3JpcHRpb24GOwBUQHBJIhRkZWZhdWx0X3BhZ2VfaWQGOwBU\nQGtJIgpjYWNoZQY7AFRVOiNBY3RpdmVSZWNvcmQ6OlR5cGU6OlNlcmlhbGl6\nZWRbCToLX192Ml9fWwc6DUBzdWJ0eXBlOgtAY29kZXJbB287Fgg7DDA7DTA7\nDmkC//9vOiVBY3RpdmVSZWNvcmQ6OkNvZGVyczo6WUFNTENvbHVtbgY6EkBv\nYmplY3RfY2xhc3NjC09iamVjdEB5SSIPY3JlYXRlZF9hdAY7AFRVOkpBY3Rp\ndmVSZWNvcmQ6OkF0dHJpYnV0ZU1ldGhvZHM6OlRpbWVab25lQ29udmVyc2lv\nbjo6VGltZVpvbmVDb252ZXJ0ZXJbCTsqWwBbAG86SkFjdGl2ZVJlY29yZDo6\nQ29ubmVjdGlvbkFkYXB0ZXJzOjpBYnN0cmFjdE15c3FsQWRhcHRlcjo6TXlz\ncWxEYXRlVGltZQg7DDA7DTA7DjBJIg91cGRhdGVkX2F0BjsAVFU7L1sJOypb\nAFsAQAF8bzsXCDsMMDsNMDsOMDsYew1JIgdpZAY7AFRpBkkiCW5hbWUGOwBU\nSSIMU3R1ZGVudAY7AFRJIg5wYXJlbnRfaWQGOwBUMEkiEGRlc2NyaXB0aW9u\nBjsAVEkiAAY7AFRJIhRkZWZhdWx0X3BhZ2VfaWQGOwBUMEkiCmNhY2hlBjsA\nVEkiAtYWLS0tCjpjcmVkZW50aWFsczogIXJ1Ynkvb2JqZWN0OkNyZWRlbnRp\nYWxzCiAgcm9sZV9pZDogMQogIHVwZGF0ZWRfYXQ6IDIwMTUtMTItMDQgMTk6\nNTc6NDMuMDAwMDAwMDAwIFoKICByb2xlX2lkczoKICAtIDEKICBwZXJtaXNz\naW9uX2lkczoKICAtIDYKICAtIDYKICAtIDYKICAtIDMKICAtIDMKICAtIDMK\nICAtIDIKICAtIDIKICAtIDIKICBhY3Rpb25zOgogICAgY29udGVudF9wYWdl\nczoKICAgICAgdmlld19kZWZhdWx0OiB0cnVlCiAgICAgIHZpZXc6IHRydWUK\nICAgICAgbGlzdDogZmFsc2UKICAgIGNvbnRyb2xsZXJfYWN0aW9uczoKICAg\nICAgbGlzdDogZmFsc2UKICAgIGF1dGg6CiAgICAgIGxvZ2luOiB0cnVlCiAg\nICAgIGxvZ291dDogdHJ1ZQogICAgICBsb2dpbl9mYWlsZWQ6IHRydWUKICAg\nIG1lbnVfaXRlbXM6CiAgICAgIGxpbms6IHRydWUKICAgICAgbGlzdDogZmFs\nc2UKICAgIHBlcm1pc3Npb25zOgogICAgICBsaXN0OiBmYWxzZQogICAgcm9s\nZXM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBzaXRlX2NvbnRyb2xsZXJzOgog\nICAgICBsaXN0OiBmYWxzZQogICAgc3lzdGVtX3NldHRpbmdzOgogICAgICBs\naXN0OiBmYWxzZQogICAgdXNlcnM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICAg\nIGtleXM6IHRydWUKICAgIGFkbWluOgogICAgICBsaXN0X2luc3RydWN0b3Jz\nOiBmYWxzZQogICAgICBsaXN0X2FkbWluaXN0cmF0b3JzOiBmYWxzZQogICAg\nICBsaXN0X3N1cGVyX2FkbWluaXN0cmF0b3JzOiBmYWxzZQogICAgY291cnNl\nOgogICAgICBsaXN0X2ZvbGRlcnM6IGZhbHNlCiAgICBhc3NpZ25tZW50Ogog\nICAgICBsaXN0OiBmYWxzZQogICAgcXVlc3Rpb25uYWlyZToKICAgICAgbGlz\ndDogZmFsc2UKICAgICAgY3JlYXRlX3F1ZXN0aW9ubmFpcmU6IGZhbHNlCiAg\nICAgIGVkaXRfcXVlc3Rpb25uYWlyZTogZmFsc2UKICAgICAgY29weV9xdWVz\ndGlvbm5haXJlOiBmYWxzZQogICAgICBzYXZlX3F1ZXN0aW9ubmFpcmU6IGZh\nbHNlCiAgICBwYXJ0aWNpcGFudHM6CiAgICAgIGFkZF9zdHVkZW50OiBmYWxz\nZQogICAgICBlZGl0X3RlYW1fbWVtYmVyczogZmFsc2UKICAgICAgbGlzdF9z\ndHVkZW50czogZmFsc2UKICAgICAgbGlzdF9jb3Vyc2VzOiBmYWxzZQogICAg\nICBsaXN0X2Fzc2lnbm1lbnRzOiBmYWxzZQogICAgICBjaGFuZ2VfaGFuZGxl\nOiB0cnVlCiAgICBpbnN0aXR1dGlvbjoKICAgICAgbGlzdDogZmFsc2UKICAg\nIHN0dWRlbnRfdGFzazoKICAgICAgbGlzdDogdHJ1ZQogICAgcHJvZmlsZToK\nICAgICAgZWRpdDogdHJ1ZQogICAgc3VydmV5X3Jlc3BvbnNlOgogICAgICBj\ncmVhdGU6IHRydWUKICAgICAgc3VibWl0OiB0cnVlCiAgICB0ZWFtOgogICAg\nICBsaXN0OiBmYWxzZQogICAgICBsaXN0X2Fzc2lnbm1lbnRzOiBmYWxzZQog\nICAgdGVhbXNfdXNlcnM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBpbXBlcnNv\nbmF0ZToKICAgICAgc3RhcnQ6IGZhbHNlCiAgICAgIGltcGVyc29uYXRlOiB0\ncnVlCiAgICByZXZpZXdfbWFwcGluZzoKICAgICAgbGlzdDogZmFsc2UKICAg\nICAgYWRkX2R5bmFtaWNfcmV2aWV3ZXI6IHRydWUKICAgICAgcmVsZWFzZV9y\nZXNlcnZhdGlvbjogdHJ1ZQogICAgICBzaG93X2F2YWlsYWJsZV9zdWJtaXNz\naW9uczogdHJ1ZQogICAgICBhc3NpZ25fcmV2aWV3ZXJfZHluYW1pY2FsbHk6\nIHRydWUKICAgICAgYXNzaWduX21ldGFyZXZpZXdlcl9keW5hbWljYWxseTog\ndHJ1ZQogICAgZ3JhZGVzOgogICAgICB2aWV3X215X3Njb3JlczogdHJ1ZQog\nICAgc3VydmV5X2RlcGxveW1lbnQ6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBz\ndGF0aXN0aWNzOgogICAgICBsaXN0X3N1cnZleXM6IGZhbHNlCiAgICB0cmVl\nX2Rpc3BsYXk6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICAgIGRyaWxsOiBmYWxz\nZQogICAgICBnb3RvX3F1ZXN0aW9ubmFpcmVzOiBmYWxzZQogICAgICBnb3Rv\nX2F1dGhvcl9mZWVkYmFja3M6IGZhbHNlCiAgICAgIGdvdG9fcmV2aWV3X3J1\nYnJpY3M6IGZhbHNlCiAgICAgIGdvdG9fZ2xvYmFsX3N1cnZleTogZmFsc2UK\nICAgICAgZ290b19zdXJ2ZXlzOiBmYWxzZQogICAgICBnb3RvX2NvdXJzZV9l\ndmFsdWF0aW9uczogZmFsc2UKICAgICAgZ290b19jb3Vyc2VzOiBmYWxzZQog\nICAgICBnb3RvX2Fzc2lnbm1lbnRzOiBmYWxzZQogICAgICBnb3RvX3RlYW1t\nYXRlX3Jldmlld3M6IGZhbHNlCiAgICAgIGdvdG9fbWV0YXJldmlld19ydWJy\naWNzOiBmYWxzZQogICAgICBnb3RvX3RlYW1tYXRlcmV2aWV3X3J1YnJpY3M6\nIGZhbHNlCiAgICBzaWduX3VwX3NoZWV0OgogICAgICBsaXN0OiB0cnVlCiAg\nICAgIHNpZ251cDogdHJ1ZQogICAgICBkZWxldGVfc2lnbnVwOiB0cnVlCiAg\nICBzdWdnZXN0aW9uOgogICAgICBjcmVhdGU6IHRydWUKICAgICAgbmV3OiB0\ncnVlCiAgICBsZWFkZXJib2FyZDoKICAgICAgaW5kZXg6IHRydWUKICAgIGFk\ndmljZToKICAgICAgZWRpdF9hZHZpY2U6IGZhbHNlCiAgICAgIHNhdmVfYWR2\naWNlOiBmYWxzZQogICAgYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyOgogICAgICBh\nZGRfYWR2ZXJ0aXNlX2NvbW1lbnQ6IHRydWUKICAgICAgZWRpdDogdHJ1ZQog\nICAgICBuZXc6IHRydWUKICAgICAgcmVtb3ZlOiB0cnVlCiAgICAgIHVwZGF0\nZTogdHJ1ZQogICAgam9pbl90ZWFtX3JlcXVlc3RzOgogICAgICBjcmVhdGU6\nIHRydWUKICAgICAgZGVjbGluZTogdHJ1ZQogICAgICBkZXN0cm95OiB0cnVl\nCiAgICAgIGVkaXQ6IHRydWUKICAgICAgaW5kZXg6IHRydWUKICAgICAgbmV3\nOiB0cnVlCiAgICAgIHNob3c6IHRydWUKICAgICAgdXBkYXRlOiB0cnVlCiAg\nY29udHJvbGxlcnM6CiAgICBjb250ZW50X3BhZ2VzOiBmYWxzZQogICAgY29u\ndHJvbGxlcl9hY3Rpb25zOiBmYWxzZQogICAgYXV0aDogZmFsc2UKICAgIG1h\ncmt1cF9zdHlsZXM6IGZhbHNlCiAgICBtZW51X2l0ZW1zOiBmYWxzZQogICAg\ncGVybWlzc2lvbnM6IGZhbHNlCiAgICByb2xlczogZmFsc2UKICAgIHNpdGVf\nY29udHJvbGxlcnM6IGZhbHNlCiAgICBzeXN0ZW1fc2V0dGluZ3M6IGZhbHNl\nCiAgICB1c2VyczogdHJ1ZQogICAgcm9sZXNfcGVybWlzc2lvbnM6IGZhbHNl\nCiAgICBhZG1pbjogZmFsc2UKICAgIGNvdXJzZTogZmFsc2UKICAgIGFzc2ln\nbm1lbnQ6IGZhbHNlCiAgICBxdWVzdGlvbm5haXJlOiBmYWxzZQogICAgYWR2\naWNlOiBmYWxzZQogICAgcGFydGljaXBhbnRzOiBmYWxzZQogICAgcmVwb3J0\nczogdHJ1ZQogICAgaW5zdGl0dXRpb246IGZhbHNlCiAgICBzdHVkZW50X3Rh\nc2s6IHRydWUKICAgIHByb2ZpbGU6IHRydWUKICAgIHN1cnZleV9yZXNwb25z\nZTogdHJ1ZQogICAgdGVhbTogZmFsc2UKICAgIHRlYW1zX3VzZXJzOiBmYWxz\nZQogICAgaW1wZXJzb25hdGU6IGZhbHNlCiAgICBpbXBvcnRfZmlsZTogZmFs\nc2UKICAgIHJldmlld19tYXBwaW5nOiBmYWxzZQogICAgZ3JhZGVzOiBmYWxz\nZQogICAgY291cnNlX2V2YWx1YXRpb246IHRydWUKICAgIHBhcnRpY2lwYW50\nX2Nob2ljZXM6IGZhbHNlCiAgICBzdXJ2ZXlfZGVwbG95bWVudDogZmFsc2UK\nICAgIHN0YXRpc3RpY3M6IGZhbHNlCiAgICB0cmVlX2Rpc3BsYXk6IGZhbHNl\nCiAgICBzdHVkZW50X3RlYW06IHRydWUKICAgIGludml0YXRpb246IHRydWUK\nICAgIHN1cnZleTogZmFsc2UKICAgIHBhc3N3b3JkX3JldHJpZXZhbDogdHJ1\nZQogICAgc3VibWl0dGVkX2NvbnRlbnQ6IHRydWUKICAgIGV1bGE6IHRydWUK\nICAgIHN0dWRlbnRfcmV2aWV3OiB0cnVlCiAgICBwdWJsaXNoaW5nOiB0cnVl\nCiAgICBleHBvcnRfZmlsZTogZmFsc2UKICAgIHJlc3BvbnNlOiB0cnVlCiAg\nICBzaWduX3VwX3NoZWV0OiBmYWxzZQogICAgc3VnZ2VzdGlvbjogZmFsc2UK\nICAgIGxlYWRlcmJvYXJkOiB0cnVlCiAgICBkZWxldGVfb2JqZWN0OiBmYWxz\nZQogICAgYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyOiB0cnVlCiAgICBqb2luX3Rl\nYW1fcmVxdWVzdHM6IHRydWUKICBwYWdlczoKICAgIGhvbWU6IHRydWUKICAg\nIGV4cGlyZWQ6IHRydWUKICAgIG5vdGZvdW5kOiB0cnVlCiAgICBkZW5pZWQ6\nIHRydWUKICAgIGNvbnRhY3RfdXM6IHRydWUKICAgIHNpdGVfYWRtaW46IGZh\nbHNlCiAgICBhZG1pbjogZmFsc2UKICAgIGNyZWRpdHM6IHRydWUKOm1lbnU6\nICFydWJ5L29iamVjdDpNZW51CiAgcm9vdDogJjcgIXJ1Ynkvb2JqZWN0Ok1l\nbnU6Ok5vZGUKICAgIHBhcmVudDogCiAgICBjaGlsZHJlbjoKICAgIC0gMQog\nICAgLSA1CiAgICAtIDYKICAgIC0gNwogIGJ5X2lkOgogICAgMTogJjEgIXJ1\nYnkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgY2hp\nbGRyZW46CiAgICAgIC0gOAogICAgICBwYXJlbnRfaWQ6IAogICAgICBuYW1l\nOiBob21lCiAgICAgIGlkOiAxCiAgICAgIGxhYmVsOiBIb21lCiAgICAgIHNp\ndGVfY29udHJvbGxlcl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lk\nOiAKICAgICAgY29udGVudF9wYWdlX2lkOiAxCiAgICAgIHVybDogIi9ob21l\nIgogICAgNTogJjIgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFy\nZW50OiAKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTogc3R1ZGVudF90\nYXNrCiAgICAgIGlkOiA1CiAgICAgIGxhYmVsOiBBc3NpZ25tZW50cwogICAg\nICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDIwCiAgICAgIGNvbnRyb2xsZXJfYWN0\naW9uX2lkOiAzMwogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6\nICIvc3R1ZGVudF90YXNrL2xpc3QiCiAgICA2OiAmMyAhcnVieS9vYmplY3Q6\nTWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IAog\nICAgICBuYW1lOiBwcm9maWxlCiAgICAgIGlkOiA2CiAgICAgIGxhYmVsOiBQ\ncm9maWxlCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMjEKICAgICAgY29u\ndHJvbGxlcl9hY3Rpb25faWQ6IDM0CiAgICAgIGNvbnRlbnRfcGFnZV9pZDog\nCiAgICAgIHVybDogIi9wcm9maWxlL2VkaXQiCiAgICA3OiAmNCAhcnVieS9v\nYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBjaGlsZHJl\nbjoKICAgICAgLSA5CiAgICAgIHBhcmVudF9pZDogCiAgICAgIG5hbWU6IGNv\nbnRhY3RfdXMKICAgICAgaWQ6IDcKICAgICAgbGFiZWw6IENvbnRhY3QgVXMK\nICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAKICAgICAgY29udHJvbGxlcl9h\nY3Rpb25faWQ6IAogICAgICBjb250ZW50X3BhZ2VfaWQ6IDUKICAgICAgdXJs\nOiAiL2NvbnRhY3RfdXMiCiAgICA4OiAmNSAhcnVieS9vYmplY3Q6TWVudTo6\nTm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IDEKICAgICAg\nbmFtZTogbGVhZGVyYm9hcmQKICAgICAgaWQ6IDgKICAgICAgbGFiZWw6IExl\nYWRlcmJvYXJkCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogNDYKICAgICAg\nY29udHJvbGxlcl9hY3Rpb25faWQ6IDY5CiAgICAgIGNvbnRlbnRfcGFnZV9p\nZDogCiAgICAgIHVybDogIi9sZWFkZXJib2FyZC9pbmRleCIKICAgIDk6ICY2\nICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAg\nIHBhcmVudF9pZDogNwogICAgICBuYW1lOiBjcmVkaXRzCiAgICAgIGlkOiA5\nCiAgICAgIGxhYmVsOiBDcmVkaXRzICZhbXA7IExpY2VuY2UKICAgICAgc2l0\nZV9jb250cm9sbGVyX2lkOiAKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6\nIAogICAgICBjb250ZW50X3BhZ2VfaWQ6IDgKICAgICAgdXJsOiAiL2NyZWRp\ndHMiCiAgYnlfbmFtZToKICAgIGhvbWU6ICoxCiAgICBzdHVkZW50X3Rhc2s6\nICoyCiAgICBwcm9maWxlOiAqMwogICAgY29udGFjdF91czogKjQKICAgIGxl\nYWRlcmJvYXJkOiAqNQogICAgY3JlZGl0czogKjYKICBzZWxlY3RlZDoKICAg\nIDE6ICoxCiAgdmVjdG9yOgogIC0gKjcKICAtICoxCiAgY3J1bWJzOgogIC0g\nMQoGOwBUSSIPY3JlYXRlZF9hdAY7AFRJdToJVGltZQ2T7BzAAAAA4AY6CXpv\nbmVJIghVVEMGOwBGSSIPdXBkYXRlZF9hdAY7AFRJdTsxDZPsHMAAAMDmBjsy\nSSIIVVRDBjsARjsZewA7GkY7G3sGSSIJbmFtZQY7AFRvOxwJOx1AXDseQAGG\nOx9AcDsgSSIMU3R1ZGVudAY7AFQ7IXsAOyJ7ADoOQHJlYWRvbmx5RjoPQGRl\nc3Ryb3llZEY6HEBtYXJrZWRfZm9yX2Rlc3RydWN0aW9uRjoeQGRlc3Ryb3ll\nZF9ieV9hc3NvY2lhdGlvbjA6EEBuZXdfcmVjb3JkRjoJQHR4bjA6HkBfc3Rh\ncnRfdHJhbnNhY3Rpb25fc3RhdGV7ADoXQHRyYW5zYWN0aW9uX3N0YXRlMDoU\nQHJlZmxlY3RzX3N0YXRlWwZGOh1AbWFzc19hc3NpZ25tZW50X29wdGlvbnMw\nWwc6EUBzdGFsZV9zdGF0ZUkiBjEGOwBGWwc6DkBpbnZlcnNlZEZbBzoNQHVw\nZGF0ZWRGWwc6F0Bhc3NvY2lhdGlvbl9zY29wZW86IFJvbGU6OkFjdGl2ZVJl\nY29yZF9SZWxhdGlvbhI6C0BrbGFzc2MJUm9sZToLQHRhYmxlbzoQQXJlbDo6\nVGFibGULOx1JIgpyb2xlcwY7AFQ6DEBlbmdpbmVAAaI6DUBjb2x1bW5zMDoN\nQGFsaWFzZXNbADoRQHRhYmxlX2FsaWFzMDoRQHByaW1hcnlfa2V5MDsYewg6\nDmV4dGVuZGluZ1sAOgliaW5kWwZbB286Q0FjdGl2ZVJlY29yZDo6Q29ubmVj\ndGlvbkFkYXB0ZXJzOjpBYnN0cmFjdE15c3FsQWRhcHRlcjo6Q29sdW1uDjoM\nQHN0cmljdFQ6D0Bjb2xsYXRpb24wOgtAZXh0cmFJIhNhdXRvX2luY3JlbWVu\ndAY7AFQ7HUkiB2lkBjsAVDoPQGNhc3RfdHlwZUBrOg5Ac3FsX3R5cGVJIgxp\nbnQoMTEpBjsAVDoKQG51bGxGOg1AZGVmYXVsdDA6FkBkZWZhdWx0X2Z1bmN0\naW9uMGkGOgp3aGVyZVsGbzoaQXJlbDo6Tm9kZXM6OkVxdWFsaXR5BzoKQGxl\nZnRTOiBBcmVsOjpBdHRyaWJ1dGVzOjpBdHRyaWJ1dGUHOg1yZWxhdGlvbm87\nRAs7HUABpDtFYxdBY3RpdmVSZWNvcmQ6OkJhc2U7RjA7R1sAO0gwO0kwOglu\nYW1lSSIHaWQGOwBUOgtAcmlnaHRvOhtBcmVsOjpOb2Rlczo6QmluZFBhcmFt\nADoNQG9mZnNldHN7ADsmMDoKQGFyZWxvOhhBcmVsOjpTZWxlY3RNYW5hZ2Vy\nCTtFQAGiOglAY3R4bzocQXJlbDo6Tm9kZXM6OlNlbGVjdENvcmUNOgxAc291\ncmNlbzocQXJlbDo6Tm9kZXM6OkpvaW5Tb3VyY2UHO1dAAaM7W1sAOglAdG9w\nMDoUQHNldF9xdWFudGlmaWVyMDoRQHByb2plY3Rpb25zWwZTO1gHO1lAAaM7\nWklDOhxBcmVsOjpOb2Rlczo6U3FsTGl0ZXJhbCIGKgY7AFQ6DEB3aGVyZXNb\nBm86FUFyZWw6Ok5vZGVzOjpBbmQGOg5AY2hpbGRyZW5bBkABrzoMQGdyb3Vw\nc1sAOgxAaGF2aW5nMDoNQHdpbmRvd3NbADoRQGJpbmRfdmFsdWVzWwA6CUBh\nc3RvOiFBcmVsOjpOb2Rlczo6U2VsZWN0U3RhdGVtZW50CzoLQGNvcmVzWwZA\nAbg6DEBvcmRlcnNbADsOMDoKQGxvY2swOgxAb2Zmc2V0MDoKQHdpdGgwOhZA\nc2NvcGVfZm9yX2NyZWF0ZTA6EkBvcmRlcl9jbGF1c2UwOgxAdG9fc3FsMDoK\nQGxhc3QwOhVAam9pbl9kZXBlbmRlbmN5MDoXQHNob3VsZF9lYWdlcl9sb2Fk\nMDoNQHJlY29yZHNbADszRjs0Rjs1Rjs2MDs3Rjs4MDs5ewA7OjA7O1sGRjs8\nMEkiEGNyZWRlbnRpYWxzBjsARm86EENyZWRlbnRpYWxzDDoNQHJvbGVfaWRp\nBjoQQHVwZGF0ZWRfYXRJdTsxDZPsHMAAALDmBjsySSIIVVRDBjsARjoOQHJv\nbGVfaWRzWwZpBjoUQHBlcm1pc3Npb25faWRzWw5pC2kLaQtpCGkIaQhpB2kH\naQc6DUBhY3Rpb25zeyVJIhJjb250ZW50X3BhZ2VzBjsAVHsISSIRdmlld19k\nZWZhdWx0BjsAVFRJIgl2aWV3BjsAVFRJIglsaXN0BjsAVEZJIhdjb250cm9s\nbGVyX2FjdGlvbnMGOwBUewZJIglsaXN0BjsAVEZJIglhdXRoBjsAVHsISSIK\nbG9naW4GOwBUVEkiC2xvZ291dAY7AFRUSSIRbG9naW5fZmFpbGVkBjsAVFRJ\nIg9tZW51X2l0ZW1zBjsAVHsHSSIJbGluawY7AFRUSSIJbGlzdAY7AFRGSSIQ\ncGVybWlzc2lvbnMGOwBUewZJIglsaXN0BjsAVEZJIgpyb2xlcwY7AFR7Bkki\nCWxpc3QGOwBURkkiFXNpdGVfY29udHJvbGxlcnMGOwBUewZJIglsaXN0BjsA\nVEZJIhRzeXN0ZW1fc2V0dGluZ3MGOwBUewZJIglsaXN0BjsAVEZJIgp1c2Vy\ncwY7AFR7B0kiCWxpc3QGOwBURkkiCWtleXMGOwBUVEkiCmFkbWluBjsAVHsI\nSSIVbGlzdF9pbnN0cnVjdG9ycwY7AFRGSSIYbGlzdF9hZG1pbmlzdHJhdG9y\ncwY7AFRGSSIebGlzdF9zdXBlcl9hZG1pbmlzdHJhdG9ycwY7AFRGSSILY291\ncnNlBjsAVHsGSSIRbGlzdF9mb2xkZXJzBjsAVEZJIg9hc3NpZ25tZW50BjsA\nVHsGSSIJbGlzdAY7AFRGSSIScXVlc3Rpb25uYWlyZQY7AFR7CkkiCWxpc3QG\nOwBURkkiGWNyZWF0ZV9xdWVzdGlvbm5haXJlBjsAVEZJIhdlZGl0X3F1ZXN0\naW9ubmFpcmUGOwBURkkiF2NvcHlfcXVlc3Rpb25uYWlyZQY7AFRGSSIXc2F2\nZV9xdWVzdGlvbm5haXJlBjsAVEZJIhFwYXJ0aWNpcGFudHMGOwBUewtJIhBh\nZGRfc3R1ZGVudAY7AFRGSSIWZWRpdF90ZWFtX21lbWJlcnMGOwBURkkiEmxp\nc3Rfc3R1ZGVudHMGOwBURkkiEWxpc3RfY291cnNlcwY7AFRGSSIVbGlzdF9h\nc3NpZ25tZW50cwY7AFRGSSISY2hhbmdlX2hhbmRsZQY7AFRUSSIQaW5zdGl0\ndXRpb24GOwBUewZJIglsaXN0BjsAVEZJIhFzdHVkZW50X3Rhc2sGOwBUewZJ\nIglsaXN0BjsAVFRJIgxwcm9maWxlBjsAVHsGSSIJZWRpdAY7AFRUSSIUc3Vy\ndmV5X3Jlc3BvbnNlBjsAVHsHSSILY3JlYXRlBjsAVFRJIgtzdWJtaXQGOwBU\nVEkiCXRlYW0GOwBUewdJIglsaXN0BjsAVEZJIhVsaXN0X2Fzc2lnbm1lbnRz\nBjsAVEZJIhB0ZWFtc191c2VycwY7AFR7BkkiCWxpc3QGOwBURkkiEGltcGVy\nc29uYXRlBjsAVHsHSSIKc3RhcnQGOwBURkkiEGltcGVyc29uYXRlBjsAVFRJ\nIhNyZXZpZXdfbWFwcGluZwY7AFR7C0kiCWxpc3QGOwBURkkiGWFkZF9keW5h\nbWljX3Jldmlld2VyBjsAVFRJIhhyZWxlYXNlX3Jlc2VydmF0aW9uBjsAVFRJ\nIh9zaG93X2F2YWlsYWJsZV9zdWJtaXNzaW9ucwY7AFRUSSIgYXNzaWduX3Jl\ndmlld2VyX2R5bmFtaWNhbGx5BjsAVFRJIiRhc3NpZ25fbWV0YXJldmlld2Vy\nX2R5bmFtaWNhbGx5BjsAVFRJIgtncmFkZXMGOwBUewZJIhN2aWV3X215X3Nj\nb3JlcwY7AFRUSSIWc3VydmV5X2RlcGxveW1lbnQGOwBUewZJIglsaXN0BjsA\nVEZJIg9zdGF0aXN0aWNzBjsAVHsGSSIRbGlzdF9zdXJ2ZXlzBjsAVEZJIhF0\ncmVlX2Rpc3BsYXkGOwBUexJJIglsaXN0BjsAVEZJIgpkcmlsbAY7AFRGSSIY\nZ290b19xdWVzdGlvbm5haXJlcwY7AFRGSSIaZ290b19hdXRob3JfZmVlZGJh\nY2tzBjsAVEZJIhhnb3RvX3Jldmlld19ydWJyaWNzBjsAVEZJIhdnb3RvX2ds\nb2JhbF9zdXJ2ZXkGOwBURkkiEWdvdG9fc3VydmV5cwY7AFRGSSIcZ290b19j\nb3Vyc2VfZXZhbHVhdGlvbnMGOwBURkkiEWdvdG9fY291cnNlcwY7AFRGSSIV\nZ290b19hc3NpZ25tZW50cwY7AFRGSSIaZ290b190ZWFtbWF0ZV9yZXZpZXdz\nBjsAVEZJIhxnb3RvX21ldGFyZXZpZXdfcnVicmljcwY7AFRGSSIgZ290b190\nZWFtbWF0ZXJldmlld19ydWJyaWNzBjsAVEZJIhJzaWduX3VwX3NoZWV0BjsA\nVHsISSIJbGlzdAY7AFRUSSILc2lnbnVwBjsAVFRJIhJkZWxldGVfc2lnbnVw\nBjsAVFRJIg9zdWdnZXN0aW9uBjsAVHsHSSILY3JlYXRlBjsAVFRJIghuZXcG\nOwBUVEkiEGxlYWRlcmJvYXJkBjsAVHsGSSIKaW5kZXgGOwBUVEkiC2Fkdmlj\nZQY7AFR7B0kiEGVkaXRfYWR2aWNlBjsAVEZJIhBzYXZlX2FkdmljZQY7AFRG\nSSIaYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyBjsAVHsKSSIaYWRkX2FkdmVydGlz\nZV9jb21tZW50BjsAVFRJIgllZGl0BjsAVFRJIghuZXcGOwBUVEkiC3JlbW92\nZQY7AFRUSSILdXBkYXRlBjsAVFRJIhdqb2luX3RlYW1fcmVxdWVzdHMGOwBU\new1JIgtjcmVhdGUGOwBUVEkiDGRlY2xpbmUGOwBUVEkiDGRlc3Ryb3kGOwBU\nVEkiCWVkaXQGOwBUVEkiCmluZGV4BjsAVFRJIghuZXcGOwBUVEkiCXNob3cG\nOwBUVEkiC3VwZGF0ZQY7AFRUOhFAY29udHJvbGxlcnN7NkkiEmNvbnRlbnRf\ncGFnZXMGOwBURkkiF2NvbnRyb2xsZXJfYWN0aW9ucwY7AFRGSSIJYXV0aAY7\nAFRGSSISbWFya3VwX3N0eWxlcwY7AFRGSSIPbWVudV9pdGVtcwY7AFRGSSIQ\ncGVybWlzc2lvbnMGOwBURkkiCnJvbGVzBjsAVEZJIhVzaXRlX2NvbnRyb2xs\nZXJzBjsAVEZJIhRzeXN0ZW1fc2V0dGluZ3MGOwBURkkiCnVzZXJzBjsAVFRJ\nIhZyb2xlc19wZXJtaXNzaW9ucwY7AFRGSSIKYWRtaW4GOwBURkkiC2NvdXJz\nZQY7AFRGSSIPYXNzaWdubWVudAY7AFRGSSIScXVlc3Rpb25uYWlyZQY7AFRG\nSSILYWR2aWNlBjsAVEZJIhFwYXJ0aWNpcGFudHMGOwBURkkiDHJlcG9ydHMG\nOwBUVEkiEGluc3RpdHV0aW9uBjsAVEZJIhFzdHVkZW50X3Rhc2sGOwBUVEki\nDHByb2ZpbGUGOwBUVEkiFHN1cnZleV9yZXNwb25zZQY7AFRUSSIJdGVhbQY7\nAFRGSSIQdGVhbXNfdXNlcnMGOwBURkkiEGltcGVyc29uYXRlBjsAVEZJIhBp\nbXBvcnRfZmlsZQY7AFRGSSITcmV2aWV3X21hcHBpbmcGOwBURkkiC2dyYWRl\ncwY7AFRGSSIWY291cnNlX2V2YWx1YXRpb24GOwBUVEkiGHBhcnRpY2lwYW50\nX2Nob2ljZXMGOwBURkkiFnN1cnZleV9kZXBsb3ltZW50BjsAVEZJIg9zdGF0\naXN0aWNzBjsAVEZJIhF0cmVlX2Rpc3BsYXkGOwBURkkiEXN0dWRlbnRfdGVh\nbQY7AFRUSSIPaW52aXRhdGlvbgY7AFRUSSILc3VydmV5BjsAVEZJIhdwYXNz\nd29yZF9yZXRyaWV2YWwGOwBUVEkiFnN1Ym1pdHRlZF9jb250ZW50BjsAVFRJ\nIglldWxhBjsAVFRJIhNzdHVkZW50X3JldmlldwY7AFRUSSIPcHVibGlzaGlu\nZwY7AFRUSSIQZXhwb3J0X2ZpbGUGOwBURkkiDXJlc3BvbnNlBjsAVFRJIhJz\naWduX3VwX3NoZWV0BjsAVEZJIg9zdWdnZXN0aW9uBjsAVEZJIhBsZWFkZXJi\nb2FyZAY7AFRUSSISZGVsZXRlX29iamVjdAY7AFRGSSIaYWR2ZXJ0aXNlX2Zv\ncl9wYXJ0bmVyBjsAVFRJIhdqb2luX3RlYW1fcmVxdWVzdHMGOwBUVDoLQHBh\nZ2Vzew1JIglob21lBjsAVFRJIgxleHBpcmVkBjsAVFRJIg1ub3Rmb3VuZAY7\nAFRUSSILZGVuaWVkBjsAVFRJIg9jb250YWN0X3VzBjsAVFRJIg9zaXRlX2Fk\nbWluBjsAVEZJIgphZG1pbgY7AFRGSSIMY3JlZGl0cwY7AFRUSSIJbWVudQY7\nAEZvOglNZW51CzoKQHJvb3RvOg9NZW51OjpOb2RlBzoMQHBhcmVudDA7alsJ\naQZpCmkLaQw6C0BieV9pZHsLaQZvOwGCDzsBgzA7alsGaQ06D0BwYXJlbnRf\naWQwOx1JIglob21lBjsAVDoIQGlkaQY6C0BsYWJlbEkiCUhvbWUGOwBUOhhA\nc2l0ZV9jb250cm9sbGVyX2lkMDoaQGNvbnRyb2xsZXJfYWN0aW9uX2lkMDoV\nQGNvbnRlbnRfcGFnZV9pZGkGOglAdXJsSSIKL2hvbWUGOwBUaQpvOwGCDjsB\ngzA7AYUwOx1JIhFzdHVkZW50X3Rhc2sGOwBUOwGGaQo7AYdJIhBBc3NpZ25t\nZW50cwY7AFQ7AYhpGTsBiWkmOwGKMDsBi0kiFy9zdHVkZW50X3Rhc2svbGlz\ndAY7AFRpC287AYIOOwGDMDsBhTA7HUkiDHByb2ZpbGUGOwBUOwGGaQs7AYdJ\nIgxQcm9maWxlBjsAVDsBiGkaOwGJaSc7AYowOwGLSSISL3Byb2ZpbGUvZWRp\ndAY7AFRpDG87AYIPOwGDMDtqWwZpDjsBhTA7HUkiD2NvbnRhY3RfdXMGOwBU\nOwGGaQw7AYdJIg9Db250YWN0IFVzBjsAVDsBiDA7AYkwOwGKaQo7AYtJIhAv\nY29udGFjdF91cwY7AFRpDW87AYIOOwGDMDsBhWkGOx1JIhBsZWFkZXJib2Fy\nZAY7AFQ7AYZpDTsBh0kiEExlYWRlcmJvYXJkBjsAVDsBiGkzOwGJaUo7AYow\nOwGLSSIXL2xlYWRlcmJvYXJkL2luZGV4BjsAVGkObzsBgg47AYMwOwGFaQw7\nHUkiDGNyZWRpdHMGOwBUOwGGaQ47AYdJIhpDcmVkaXRzICZhbXA7IExpY2Vu\nY2UGOwBUOwGIMDsBiTA7AYppDTsBi0kiDS9jcmVkaXRzBjsAVDoNQGJ5X25h\nbWV7C0kiCWhvbWUGOwBUQAKlAUkiEXN0dWRlbnRfdGFzawY7AFRAAqoBSSIM\ncHJvZmlsZQY7AFRAAq4BSSIPY29udGFjdF91cwY7AFRAArIBSSIQbGVhZGVy\nYm9hcmQGOwBUQAK3AUkiDGNyZWRpdHMGOwBUQAK7AToOQHNlbGVjdGVkewZp\nBkACpQE6DEB2ZWN0b3JbB0ACogFAAqUBOgxAY3J1bWJzWwZpBkkiDnJldHVy\nbl90bwY7AEZJIj5odHRwOi8vMTI3LjAuMC4xOjQ2MzY0L3NpZ25fdXBfc2hl\nZXQvbGlzdD9hc3NpZ25tZW50X2lkPTEGOwBUSSIKZmxhc2gGOwBUewdJIgxk\naXNjYXJkBjsAVFsGSSIKZXJyb3IGOwBGSSIMZmxhc2hlcwY7AFR7BkACzwFJ\nIipZb3UndmUgYWxyZWFkeSBzaWduZWQgdXAgZm9yIGEgdG9waWMhBjsAVA==\n','2015-12-13 14:39:01','2015-12-13 14:39:21'),(6,'f4a539fd27d8b9fec2f6d224669f345d','BAh7C0kiEF9jc3JmX3Rva2VuBjoGRUZJIjFKRlordUxrV3lLNmgxRDBoNG9Z\nQjVDdUNZeHVBUkd5Z3dxaXRYcDNLckRVPQY7AEZJIgl1c2VyBjsARm86CVVz\nZXISOhBAYXR0cmlidXRlc286H0FjdGl2ZVJlY29yZDo6QXR0cmlidXRlU2V0\nBjsHbzokQWN0aXZlUmVjb3JkOjpMYXp5QXR0cmlidXRlSGFzaAo6C0B0eXBl\nc30bSSIHaWQGOwBUbzogQWN0aXZlUmVjb3JkOjpUeXBlOjpJbnRlZ2VyCToP\nQHByZWNpc2lvbjA6C0BzY2FsZTA6C0BsaW1pdGkJOgtAcmFuZ2VvOgpSYW5n\nZQg6CWV4Y2xUOgpiZWdpbmwtBwAAAIA6CGVuZGwrBwAAAIBJIgluYW1lBjsA\nVG86SEFjdGl2ZVJlY29yZDo6Q29ubmVjdGlvbkFkYXB0ZXJzOjpBYnN0cmFj\ndE15c3FsQWRhcHRlcjo6TXlzcWxTdHJpbmcIOwwwOw0wOw5pAf9JIhVjcnlw\ndGVkX3Bhc3N3b3JkBjsAVG87FAg7DDA7DTA7DmktSSIMcm9sZV9pZAY7AFRA\nDkkiEnBhc3N3b3JkX3NhbHQGOwBUQBNJIg1mdWxsbmFtZQY7AFRAE0kiCmVt\nYWlsBjsAVEATSSIOcGFyZW50X2lkBjsAVEAOSSIXcHJpdmF0ZV9ieV9kZWZh\ndWx0BjsAVG86IEFjdGl2ZVJlY29yZDo6VHlwZTo6Qm9vbGVhbgg7DDA7DTA7\nDmkGSSIXbXJ1X2RpcmVjdG9yeV9wYXRoBjsAVG87FAg7DDA7DTA7DmkBgEki\nFGVtYWlsX29uX3JldmlldwY7AFRAHEkiGGVtYWlsX29uX3N1Ym1pc3Npb24G\nOwBUQBxJIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsAVEAcSSIQaXNf\nbmV3X3VzZXIGOwBUQBxJIh5tYXN0ZXJfcGVybWlzc2lvbl9ncmFudGVkBjsA\nVG87Cwk7DDA7DTA7DmkGOw9vOxAIOxFUOxJp/4A7E2kBgEkiC2hhbmRsZQY7\nAFRAE0kiGGxlYWRlcmJvYXJkX3ByaXZhY3kGOwBUQBxJIhhkaWdpdGFsX2Nl\ncnRpZmljYXRlBjsAVG86HUFjdGl2ZVJlY29yZDo6VHlwZTo6VGV4dAg7DDA7\nDTA7DmkC//9JIhZwZXJzaXN0ZW5jZV90b2tlbgY7AFRAE0kiEXRpbWV6b25l\ncHJlZgY7AFRAE0kiD3B1YmxpY19rZXkGOwBUQClJIhNjb3B5X29mX2VtYWls\ncwY7AFRAHG86HkFjdGl2ZVJlY29yZDo6VHlwZTo6VmFsdWUIOwwwOw0wOw4w\nOgxAdmFsdWVzextJIgdpZAY7AFRpB0kiCW5hbWUGOwBUSSINc3R1ZGVudDEG\nOwBUSSIVY3J5cHRlZF9wYXNzd29yZAY7AFRJIi1iNjczYWEwYjFhNmY1NGZk\nNGM2M2Q0YjlmMWNlY2FmZjBiNzM5OGJlBjsAVEkiDHJvbGVfaWQGOwBUaQZJ\nIhJwYXNzd29yZF9zYWx0BjsAVEkiF0t0a0lMbEZaWGRmY1RGcHcyNQY7AFRJ\nIg1mdWxsbmFtZQY7AFRJIhFTdHVkZW50LCBPbmUGOwBUSSIKZW1haWwGOwBU\nSSIWc3R1ZGVudDFAbmNzdS5lZHUGOwBUSSIOcGFyZW50X2lkBjsAVGkGSSIX\ncHJpdmF0ZV9ieV9kZWZhdWx0BjsAVGkASSIXbXJ1X2RpcmVjdG9yeV9wYXRo\nBjsAVDBJIhRlbWFpbF9vbl9yZXZpZXcGOwBUMEkiGGVtYWlsX29uX3N1Ym1p\nc3Npb24GOwBUMEkiHmVtYWlsX29uX3Jldmlld19vZl9yZXZpZXcGOwBUMEki\nEGlzX25ld191c2VyBjsAVGkASSIebWFzdGVyX3Blcm1pc3Npb25fZ3JhbnRl\nZAY7AFRpAEkiC2hhbmRsZQY7AFRJIgAGOwBUSSIYbGVhZGVyYm9hcmRfcHJp\ndmFjeQY7AFRpAEkiGGRpZ2l0YWxfY2VydGlmaWNhdGUGOwBUMEkiFnBlcnNp\nc3RlbmNlX3Rva2VuBjsAVEkiAYBjYWNjOGM5Yzc3N2U2N2Q0NGUyYWI0N2Q4\nYjVmOWIyMmZmNzdkNzA4ZGUwM2VmNzJlZDQ3MjMwZmQ1MGJhZGM4MWJhZWUz\nNWU5ZDM3ZjBlYzc1NDkxNjgzMmIxZDE3ZjVkNDMzYmM1MzI1NzRiNGRhMjIw\nNmFmNGRkN2Q2Nzg5NwY7AFRJIhF0aW1lem9uZXByZWYGOwBUSSIfRWFzdGVy\nbiBUaW1lIChVUyAmIENhbmFkYSkGOwBUSSIPcHVibGljX2tleQY7AFQwSSIT\nY29weV9vZl9lbWFpbHMGOwBUaQA6FkBhZGRpdGlvbmFsX3R5cGVzewA6EkBt\nYXRlcmlhbGl6ZWRGOhNAZGVsZWdhdGVfaGFzaHsJSSIRdGltZXpvbmVwcmVm\nBjsAVG86KkFjdGl2ZVJlY29yZDo6QXR0cmlidXRlOjpGcm9tRGF0YWJhc2UJ\nOgpAbmFtZUkiEXRpbWV6b25lcHJlZgY7AFQ6HEB2YWx1ZV9iZWZvcmVfdHlw\nZV9jYXN0QEs6CkB0eXBlQBM6C0B2YWx1ZUkiH0Vhc3Rlcm4gVGltZSAoVVMg\nJiBDYW5hZGEpBjsAVEkiB2lkBjsARm87HAk7HUkiB2lkBjsARjseaQc7H0AO\nOyBpB0kiDHJvbGVfaWQGOwBGbzscCTsdSSIMcm9sZV9pZAY7AEY7HmkGOx9A\nDjsgaQZJIgluYW1lBjsAVG87HAk7HUkiCW5hbWUGOwBUOx5AMjsfQBM7IEki\nDXN0dWRlbnQxBjsAVDoXQGFnZ3JlZ2F0aW9uX2NhY2hlewA6F0Bhc3NvY2lh\ndGlvbl9jYWNoZXsGOglyb2xlVTo1QWN0aXZlUmVjb3JkOjpBc3NvY2lhdGlv\nbnM6OkJlbG9uZ3NUb0Fzc29jaWF0aW9uWwc7I1sMWwc6C0Bvd25lckAJWwc6\nDEBsb2FkZWRUWwc6DEB0YXJnZXRvOglSb2xlEjsHbzsIBjsHbzsJCjsKfQ1J\nIgdpZAY7AFRvOwsJOwwwOw0wOw5pCTsPbzsQCDsRVDsSbC0HAAAAgDsTbCsH\nAAAAgEkiCW5hbWUGOwBUbzsUCDsMMDsNMDsOaQH/SSIOcGFyZW50X2lkBjsA\nVEBrSSIQZGVzY3JpcHRpb24GOwBUQHBJIhRkZWZhdWx0X3BhZ2VfaWQGOwBU\nQGtJIgpjYWNoZQY7AFRVOiNBY3RpdmVSZWNvcmQ6OlR5cGU6OlNlcmlhbGl6\nZWRbCToLX192Ml9fWwc6DUBzdWJ0eXBlOgtAY29kZXJbB287Fgg7DDA7DTA7\nDmkC//9vOiVBY3RpdmVSZWNvcmQ6OkNvZGVyczo6WUFNTENvbHVtbgY6EkBv\nYmplY3RfY2xhc3NjC09iamVjdEB5SSIPY3JlYXRlZF9hdAY7AFRVOkpBY3Rp\ndmVSZWNvcmQ6OkF0dHJpYnV0ZU1ldGhvZHM6OlRpbWVab25lQ29udmVyc2lv\nbjo6VGltZVpvbmVDb252ZXJ0ZXJbCTsqWwBbAG86SkFjdGl2ZVJlY29yZDo6\nQ29ubmVjdGlvbkFkYXB0ZXJzOjpBYnN0cmFjdE15c3FsQWRhcHRlcjo6TXlz\ncWxEYXRlVGltZQg7DDA7DTA7DjBJIg91cGRhdGVkX2F0BjsAVFU7L1sJOypb\nAFsAQAF8bzsXCDsMMDsNMDsOMDsYew1JIgdpZAY7AFRpBkkiCW5hbWUGOwBU\nSSIMU3R1ZGVudAY7AFRJIg5wYXJlbnRfaWQGOwBUMEkiEGRlc2NyaXB0aW9u\nBjsAVEkiAAY7AFRJIhRkZWZhdWx0X3BhZ2VfaWQGOwBUMEkiCmNhY2hlBjsA\nVEkiAtYWLS0tCjpjcmVkZW50aWFsczogIXJ1Ynkvb2JqZWN0OkNyZWRlbnRp\nYWxzCiAgcm9sZV9pZDogMQogIHVwZGF0ZWRfYXQ6IDIwMTUtMTItMDQgMTk6\nNTc6NDMuMDAwMDAwMDAwIFoKICByb2xlX2lkczoKICAtIDEKICBwZXJtaXNz\naW9uX2lkczoKICAtIDYKICAtIDYKICAtIDYKICAtIDMKICAtIDMKICAtIDMK\nICAtIDIKICAtIDIKICAtIDIKICBhY3Rpb25zOgogICAgY29udGVudF9wYWdl\nczoKICAgICAgdmlld19kZWZhdWx0OiB0cnVlCiAgICAgIHZpZXc6IHRydWUK\nICAgICAgbGlzdDogZmFsc2UKICAgIGNvbnRyb2xsZXJfYWN0aW9uczoKICAg\nICAgbGlzdDogZmFsc2UKICAgIGF1dGg6CiAgICAgIGxvZ2luOiB0cnVlCiAg\nICAgIGxvZ291dDogdHJ1ZQogICAgICBsb2dpbl9mYWlsZWQ6IHRydWUKICAg\nIG1lbnVfaXRlbXM6CiAgICAgIGxpbms6IHRydWUKICAgICAgbGlzdDogZmFs\nc2UKICAgIHBlcm1pc3Npb25zOgogICAgICBsaXN0OiBmYWxzZQogICAgcm9s\nZXM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBzaXRlX2NvbnRyb2xsZXJzOgog\nICAgICBsaXN0OiBmYWxzZQogICAgc3lzdGVtX3NldHRpbmdzOgogICAgICBs\naXN0OiBmYWxzZQogICAgdXNlcnM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICAg\nIGtleXM6IHRydWUKICAgIGFkbWluOgogICAgICBsaXN0X2luc3RydWN0b3Jz\nOiBmYWxzZQogICAgICBsaXN0X2FkbWluaXN0cmF0b3JzOiBmYWxzZQogICAg\nICBsaXN0X3N1cGVyX2FkbWluaXN0cmF0b3JzOiBmYWxzZQogICAgY291cnNl\nOgogICAgICBsaXN0X2ZvbGRlcnM6IGZhbHNlCiAgICBhc3NpZ25tZW50Ogog\nICAgICBsaXN0OiBmYWxzZQogICAgcXVlc3Rpb25uYWlyZToKICAgICAgbGlz\ndDogZmFsc2UKICAgICAgY3JlYXRlX3F1ZXN0aW9ubmFpcmU6IGZhbHNlCiAg\nICAgIGVkaXRfcXVlc3Rpb25uYWlyZTogZmFsc2UKICAgICAgY29weV9xdWVz\ndGlvbm5haXJlOiBmYWxzZQogICAgICBzYXZlX3F1ZXN0aW9ubmFpcmU6IGZh\nbHNlCiAgICBwYXJ0aWNpcGFudHM6CiAgICAgIGFkZF9zdHVkZW50OiBmYWxz\nZQogICAgICBlZGl0X3RlYW1fbWVtYmVyczogZmFsc2UKICAgICAgbGlzdF9z\ndHVkZW50czogZmFsc2UKICAgICAgbGlzdF9jb3Vyc2VzOiBmYWxzZQogICAg\nICBsaXN0X2Fzc2lnbm1lbnRzOiBmYWxzZQogICAgICBjaGFuZ2VfaGFuZGxl\nOiB0cnVlCiAgICBpbnN0aXR1dGlvbjoKICAgICAgbGlzdDogZmFsc2UKICAg\nIHN0dWRlbnRfdGFzazoKICAgICAgbGlzdDogdHJ1ZQogICAgcHJvZmlsZToK\nICAgICAgZWRpdDogdHJ1ZQogICAgc3VydmV5X3Jlc3BvbnNlOgogICAgICBj\ncmVhdGU6IHRydWUKICAgICAgc3VibWl0OiB0cnVlCiAgICB0ZWFtOgogICAg\nICBsaXN0OiBmYWxzZQogICAgICBsaXN0X2Fzc2lnbm1lbnRzOiBmYWxzZQog\nICAgdGVhbXNfdXNlcnM6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBpbXBlcnNv\nbmF0ZToKICAgICAgc3RhcnQ6IGZhbHNlCiAgICAgIGltcGVyc29uYXRlOiB0\ncnVlCiAgICByZXZpZXdfbWFwcGluZzoKICAgICAgbGlzdDogZmFsc2UKICAg\nICAgYWRkX2R5bmFtaWNfcmV2aWV3ZXI6IHRydWUKICAgICAgcmVsZWFzZV9y\nZXNlcnZhdGlvbjogdHJ1ZQogICAgICBzaG93X2F2YWlsYWJsZV9zdWJtaXNz\naW9uczogdHJ1ZQogICAgICBhc3NpZ25fcmV2aWV3ZXJfZHluYW1pY2FsbHk6\nIHRydWUKICAgICAgYXNzaWduX21ldGFyZXZpZXdlcl9keW5hbWljYWxseTog\ndHJ1ZQogICAgZ3JhZGVzOgogICAgICB2aWV3X215X3Njb3JlczogdHJ1ZQog\nICAgc3VydmV5X2RlcGxveW1lbnQ6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBz\ndGF0aXN0aWNzOgogICAgICBsaXN0X3N1cnZleXM6IGZhbHNlCiAgICB0cmVl\nX2Rpc3BsYXk6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICAgIGRyaWxsOiBmYWxz\nZQogICAgICBnb3RvX3F1ZXN0aW9ubmFpcmVzOiBmYWxzZQogICAgICBnb3Rv\nX2F1dGhvcl9mZWVkYmFja3M6IGZhbHNlCiAgICAgIGdvdG9fcmV2aWV3X3J1\nYnJpY3M6IGZhbHNlCiAgICAgIGdvdG9fZ2xvYmFsX3N1cnZleTogZmFsc2UK\nICAgICAgZ290b19zdXJ2ZXlzOiBmYWxzZQogICAgICBnb3RvX2NvdXJzZV9l\ndmFsdWF0aW9uczogZmFsc2UKICAgICAgZ290b19jb3Vyc2VzOiBmYWxzZQog\nICAgICBnb3RvX2Fzc2lnbm1lbnRzOiBmYWxzZQogICAgICBnb3RvX3RlYW1t\nYXRlX3Jldmlld3M6IGZhbHNlCiAgICAgIGdvdG9fbWV0YXJldmlld19ydWJy\naWNzOiBmYWxzZQogICAgICBnb3RvX3RlYW1tYXRlcmV2aWV3X3J1YnJpY3M6\nIGZhbHNlCiAgICBzaWduX3VwX3NoZWV0OgogICAgICBsaXN0OiB0cnVlCiAg\nICAgIHNpZ251cDogdHJ1ZQogICAgICBkZWxldGVfc2lnbnVwOiB0cnVlCiAg\nICBzdWdnZXN0aW9uOgogICAgICBjcmVhdGU6IHRydWUKICAgICAgbmV3OiB0\ncnVlCiAgICBsZWFkZXJib2FyZDoKICAgICAgaW5kZXg6IHRydWUKICAgIGFk\ndmljZToKICAgICAgZWRpdF9hZHZpY2U6IGZhbHNlCiAgICAgIHNhdmVfYWR2\naWNlOiBmYWxzZQogICAgYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyOgogICAgICBh\nZGRfYWR2ZXJ0aXNlX2NvbW1lbnQ6IHRydWUKICAgICAgZWRpdDogdHJ1ZQog\nICAgICBuZXc6IHRydWUKICAgICAgcmVtb3ZlOiB0cnVlCiAgICAgIHVwZGF0\nZTogdHJ1ZQogICAgam9pbl90ZWFtX3JlcXVlc3RzOgogICAgICBjcmVhdGU6\nIHRydWUKICAgICAgZGVjbGluZTogdHJ1ZQogICAgICBkZXN0cm95OiB0cnVl\nCiAgICAgIGVkaXQ6IHRydWUKICAgICAgaW5kZXg6IHRydWUKICAgICAgbmV3\nOiB0cnVlCiAgICAgIHNob3c6IHRydWUKICAgICAgdXBkYXRlOiB0cnVlCiAg\nY29udHJvbGxlcnM6CiAgICBjb250ZW50X3BhZ2VzOiBmYWxzZQogICAgY29u\ndHJvbGxlcl9hY3Rpb25zOiBmYWxzZQogICAgYXV0aDogZmFsc2UKICAgIG1h\ncmt1cF9zdHlsZXM6IGZhbHNlCiAgICBtZW51X2l0ZW1zOiBmYWxzZQogICAg\ncGVybWlzc2lvbnM6IGZhbHNlCiAgICByb2xlczogZmFsc2UKICAgIHNpdGVf\nY29udHJvbGxlcnM6IGZhbHNlCiAgICBzeXN0ZW1fc2V0dGluZ3M6IGZhbHNl\nCiAgICB1c2VyczogdHJ1ZQogICAgcm9sZXNfcGVybWlzc2lvbnM6IGZhbHNl\nCiAgICBhZG1pbjogZmFsc2UKICAgIGNvdXJzZTogZmFsc2UKICAgIGFzc2ln\nbm1lbnQ6IGZhbHNlCiAgICBxdWVzdGlvbm5haXJlOiBmYWxzZQogICAgYWR2\naWNlOiBmYWxzZQogICAgcGFydGljaXBhbnRzOiBmYWxzZQogICAgcmVwb3J0\nczogdHJ1ZQogICAgaW5zdGl0dXRpb246IGZhbHNlCiAgICBzdHVkZW50X3Rh\nc2s6IHRydWUKICAgIHByb2ZpbGU6IHRydWUKICAgIHN1cnZleV9yZXNwb25z\nZTogdHJ1ZQogICAgdGVhbTogZmFsc2UKICAgIHRlYW1zX3VzZXJzOiBmYWxz\nZQogICAgaW1wZXJzb25hdGU6IGZhbHNlCiAgICBpbXBvcnRfZmlsZTogZmFs\nc2UKICAgIHJldmlld19tYXBwaW5nOiBmYWxzZQogICAgZ3JhZGVzOiBmYWxz\nZQogICAgY291cnNlX2V2YWx1YXRpb246IHRydWUKICAgIHBhcnRpY2lwYW50\nX2Nob2ljZXM6IGZhbHNlCiAgICBzdXJ2ZXlfZGVwbG95bWVudDogZmFsc2UK\nICAgIHN0YXRpc3RpY3M6IGZhbHNlCiAgICB0cmVlX2Rpc3BsYXk6IGZhbHNl\nCiAgICBzdHVkZW50X3RlYW06IHRydWUKICAgIGludml0YXRpb246IHRydWUK\nICAgIHN1cnZleTogZmFsc2UKICAgIHBhc3N3b3JkX3JldHJpZXZhbDogdHJ1\nZQogICAgc3VibWl0dGVkX2NvbnRlbnQ6IHRydWUKICAgIGV1bGE6IHRydWUK\nICAgIHN0dWRlbnRfcmV2aWV3OiB0cnVlCiAgICBwdWJsaXNoaW5nOiB0cnVl\nCiAgICBleHBvcnRfZmlsZTogZmFsc2UKICAgIHJlc3BvbnNlOiB0cnVlCiAg\nICBzaWduX3VwX3NoZWV0OiBmYWxzZQogICAgc3VnZ2VzdGlvbjogZmFsc2UK\nICAgIGxlYWRlcmJvYXJkOiB0cnVlCiAgICBkZWxldGVfb2JqZWN0OiBmYWxz\nZQogICAgYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyOiB0cnVlCiAgICBqb2luX3Rl\nYW1fcmVxdWVzdHM6IHRydWUKICBwYWdlczoKICAgIGhvbWU6IHRydWUKICAg\nIGV4cGlyZWQ6IHRydWUKICAgIG5vdGZvdW5kOiB0cnVlCiAgICBkZW5pZWQ6\nIHRydWUKICAgIGNvbnRhY3RfdXM6IHRydWUKICAgIHNpdGVfYWRtaW46IGZh\nbHNlCiAgICBhZG1pbjogZmFsc2UKICAgIGNyZWRpdHM6IHRydWUKOm1lbnU6\nICFydWJ5L29iamVjdDpNZW51CiAgcm9vdDogJjcgIXJ1Ynkvb2JqZWN0Ok1l\nbnU6Ok5vZGUKICAgIHBhcmVudDogCiAgICBjaGlsZHJlbjoKICAgIC0gMQog\nICAgLSA1CiAgICAtIDYKICAgIC0gNwogIGJ5X2lkOgogICAgMTogJjEgIXJ1\nYnkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgY2hp\nbGRyZW46CiAgICAgIC0gOAogICAgICBwYXJlbnRfaWQ6IAogICAgICBuYW1l\nOiBob21lCiAgICAgIGlkOiAxCiAgICAgIGxhYmVsOiBIb21lCiAgICAgIHNp\ndGVfY29udHJvbGxlcl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lk\nOiAKICAgICAgY29udGVudF9wYWdlX2lkOiAxCiAgICAgIHVybDogIi9ob21l\nIgogICAgNTogJjIgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFy\nZW50OiAKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTogc3R1ZGVudF90\nYXNrCiAgICAgIGlkOiA1CiAgICAgIGxhYmVsOiBBc3NpZ25tZW50cwogICAg\nICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDIwCiAgICAgIGNvbnRyb2xsZXJfYWN0\naW9uX2lkOiAzMwogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6\nICIvc3R1ZGVudF90YXNrL2xpc3QiCiAgICA2OiAmMyAhcnVieS9vYmplY3Q6\nTWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IAog\nICAgICBuYW1lOiBwcm9maWxlCiAgICAgIGlkOiA2CiAgICAgIGxhYmVsOiBQ\ncm9maWxlCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMjEKICAgICAgY29u\ndHJvbGxlcl9hY3Rpb25faWQ6IDM0CiAgICAgIGNvbnRlbnRfcGFnZV9pZDog\nCiAgICAgIHVybDogIi9wcm9maWxlL2VkaXQiCiAgICA3OiAmNCAhcnVieS9v\nYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBjaGlsZHJl\nbjoKICAgICAgLSA5CiAgICAgIHBhcmVudF9pZDogCiAgICAgIG5hbWU6IGNv\nbnRhY3RfdXMKICAgICAgaWQ6IDcKICAgICAgbGFiZWw6IENvbnRhY3QgVXMK\nICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAKICAgICAgY29udHJvbGxlcl9h\nY3Rpb25faWQ6IAogICAgICBjb250ZW50X3BhZ2VfaWQ6IDUKICAgICAgdXJs\nOiAiL2NvbnRhY3RfdXMiCiAgICA4OiAmNSAhcnVieS9vYmplY3Q6TWVudTo6\nTm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IDEKICAgICAg\nbmFtZTogbGVhZGVyYm9hcmQKICAgICAgaWQ6IDgKICAgICAgbGFiZWw6IExl\nYWRlcmJvYXJkCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogNDYKICAgICAg\nY29udHJvbGxlcl9hY3Rpb25faWQ6IDY5CiAgICAgIGNvbnRlbnRfcGFnZV9p\nZDogCiAgICAgIHVybDogIi9sZWFkZXJib2FyZC9pbmRleCIKICAgIDk6ICY2\nICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAg\nIHBhcmVudF9pZDogNwogICAgICBuYW1lOiBjcmVkaXRzCiAgICAgIGlkOiA5\nCiAgICAgIGxhYmVsOiBDcmVkaXRzICZhbXA7IExpY2VuY2UKICAgICAgc2l0\nZV9jb250cm9sbGVyX2lkOiAKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6\nIAogICAgICBjb250ZW50X3BhZ2VfaWQ6IDgKICAgICAgdXJsOiAiL2NyZWRp\ndHMiCiAgYnlfbmFtZToKICAgIGhvbWU6ICoxCiAgICBzdHVkZW50X3Rhc2s6\nICoyCiAgICBwcm9maWxlOiAqMwogICAgY29udGFjdF91czogKjQKICAgIGxl\nYWRlcmJvYXJkOiAqNQogICAgY3JlZGl0czogKjYKICBzZWxlY3RlZDoKICAg\nIDE6ICoxCiAgdmVjdG9yOgogIC0gKjcKICAtICoxCiAgY3J1bWJzOgogIC0g\nMQoGOwBUSSIPY3JlYXRlZF9hdAY7AFRJdToJVGltZQ2T7BzAAAAA4AY6CXpv\nbmVJIghVVEMGOwBGSSIPdXBkYXRlZF9hdAY7AFRJdTsxDZPsHMAAAMDmBjsy\nSSIIVVRDBjsARjsZewA7GkY7G3sGSSIJbmFtZQY7AFRvOxwJOx1AXDseQAGG\nOx9AcDsgSSIMU3R1ZGVudAY7AFQ7IXsAOyJ7ADoOQHJlYWRvbmx5RjoPQGRl\nc3Ryb3llZEY6HEBtYXJrZWRfZm9yX2Rlc3RydWN0aW9uRjoeQGRlc3Ryb3ll\nZF9ieV9hc3NvY2lhdGlvbjA6EEBuZXdfcmVjb3JkRjoJQHR4bjA6HkBfc3Rh\ncnRfdHJhbnNhY3Rpb25fc3RhdGV7ADoXQHRyYW5zYWN0aW9uX3N0YXRlMDoU\nQHJlZmxlY3RzX3N0YXRlWwZGOh1AbWFzc19hc3NpZ25tZW50X29wdGlvbnMw\nWwc6EUBzdGFsZV9zdGF0ZUkiBjEGOwBGWwc6DkBpbnZlcnNlZEZbBzoNQHVw\nZGF0ZWRGWwc6F0Bhc3NvY2lhdGlvbl9zY29wZW86IFJvbGU6OkFjdGl2ZVJl\nY29yZF9SZWxhdGlvbhI6C0BrbGFzc2MJUm9sZToLQHRhYmxlbzoQQXJlbDo6\nVGFibGULOx1JIgpyb2xlcwY7AFQ6DEBlbmdpbmVAAaI6DUBjb2x1bW5zMDoN\nQGFsaWFzZXNbADoRQHRhYmxlX2FsaWFzMDoRQHByaW1hcnlfa2V5MDsYewg6\nDmV4dGVuZGluZ1sAOgliaW5kWwZbB286Q0FjdGl2ZVJlY29yZDo6Q29ubmVj\ndGlvbkFkYXB0ZXJzOjpBYnN0cmFjdE15c3FsQWRhcHRlcjo6Q29sdW1uDjoM\nQHN0cmljdFQ6D0Bjb2xsYXRpb24wOgtAZXh0cmFJIhNhdXRvX2luY3JlbWVu\ndAY7AFQ7HUkiB2lkBjsAVDoPQGNhc3RfdHlwZUBrOg5Ac3FsX3R5cGVJIgxp\nbnQoMTEpBjsAVDoKQG51bGxGOg1AZGVmYXVsdDA6FkBkZWZhdWx0X2Z1bmN0\naW9uMGkGOgp3aGVyZVsGbzoaQXJlbDo6Tm9kZXM6OkVxdWFsaXR5BzoKQGxl\nZnRTOiBBcmVsOjpBdHRyaWJ1dGVzOjpBdHRyaWJ1dGUHOg1yZWxhdGlvbm87\nRAs7HUABpDtFYxdBY3RpdmVSZWNvcmQ6OkJhc2U7RjA7R1sAO0gwO0kwOglu\nYW1lSSIHaWQGOwBUOgtAcmlnaHRvOhtBcmVsOjpOb2Rlczo6QmluZFBhcmFt\nADoNQG9mZnNldHN7ADsmMDoKQGFyZWxvOhhBcmVsOjpTZWxlY3RNYW5hZ2Vy\nCTtFQAGiOglAY3R4bzocQXJlbDo6Tm9kZXM6OlNlbGVjdENvcmUNOgxAc291\ncmNlbzocQXJlbDo6Tm9kZXM6OkpvaW5Tb3VyY2UHO1dAAaM7W1sAOglAdG9w\nMDoUQHNldF9xdWFudGlmaWVyMDoRQHByb2plY3Rpb25zWwZTO1gHO1lAAaM7\nWklDOhxBcmVsOjpOb2Rlczo6U3FsTGl0ZXJhbCIGKgY7AFQ6DEB3aGVyZXNb\nBm86FUFyZWw6Ok5vZGVzOjpBbmQGOg5AY2hpbGRyZW5bBkABrzoMQGdyb3Vw\nc1sAOgxAaGF2aW5nMDoNQHdpbmRvd3NbADoRQGJpbmRfdmFsdWVzWwA6CUBh\nc3RvOiFBcmVsOjpOb2Rlczo6U2VsZWN0U3RhdGVtZW50CzoLQGNvcmVzWwZA\nAbg6DEBvcmRlcnNbADsOMDoKQGxvY2swOgxAb2Zmc2V0MDoKQHdpdGgwOhZA\nc2NvcGVfZm9yX2NyZWF0ZTA6EkBvcmRlcl9jbGF1c2UwOgxAdG9fc3FsMDoK\nQGxhc3QwOhVAam9pbl9kZXBlbmRlbmN5MDoXQHNob3VsZF9lYWdlcl9sb2Fk\nMDoNQHJlY29yZHNbADszRjs0Rjs1Rjs2MDs3Rjs4MDs5ewA7OjA7O1sGRjs8\nMEkiEGNyZWRlbnRpYWxzBjsARm86EENyZWRlbnRpYWxzDDoNQHJvbGVfaWRp\nBjoQQHVwZGF0ZWRfYXRJdTsxDZPsHMAAALDmBjsySSIIVVRDBjsARjoOQHJv\nbGVfaWRzWwZpBjoUQHBlcm1pc3Npb25faWRzWw5pC2kLaQtpCGkIaQhpB2kH\naQc6DUBhY3Rpb25zeyVJIhJjb250ZW50X3BhZ2VzBjsAVHsISSIRdmlld19k\nZWZhdWx0BjsAVFRJIgl2aWV3BjsAVFRJIglsaXN0BjsAVEZJIhdjb250cm9s\nbGVyX2FjdGlvbnMGOwBUewZJIglsaXN0BjsAVEZJIglhdXRoBjsAVHsISSIK\nbG9naW4GOwBUVEkiC2xvZ291dAY7AFRUSSIRbG9naW5fZmFpbGVkBjsAVFRJ\nIg9tZW51X2l0ZW1zBjsAVHsHSSIJbGluawY7AFRUSSIJbGlzdAY7AFRGSSIQ\ncGVybWlzc2lvbnMGOwBUewZJIglsaXN0BjsAVEZJIgpyb2xlcwY7AFR7Bkki\nCWxpc3QGOwBURkkiFXNpdGVfY29udHJvbGxlcnMGOwBUewZJIglsaXN0BjsA\nVEZJIhRzeXN0ZW1fc2V0dGluZ3MGOwBUewZJIglsaXN0BjsAVEZJIgp1c2Vy\ncwY7AFR7B0kiCWxpc3QGOwBURkkiCWtleXMGOwBUVEkiCmFkbWluBjsAVHsI\nSSIVbGlzdF9pbnN0cnVjdG9ycwY7AFRGSSIYbGlzdF9hZG1pbmlzdHJhdG9y\ncwY7AFRGSSIebGlzdF9zdXBlcl9hZG1pbmlzdHJhdG9ycwY7AFRGSSILY291\ncnNlBjsAVHsGSSIRbGlzdF9mb2xkZXJzBjsAVEZJIg9hc3NpZ25tZW50BjsA\nVHsGSSIJbGlzdAY7AFRGSSIScXVlc3Rpb25uYWlyZQY7AFR7CkkiCWxpc3QG\nOwBURkkiGWNyZWF0ZV9xdWVzdGlvbm5haXJlBjsAVEZJIhdlZGl0X3F1ZXN0\naW9ubmFpcmUGOwBURkkiF2NvcHlfcXVlc3Rpb25uYWlyZQY7AFRGSSIXc2F2\nZV9xdWVzdGlvbm5haXJlBjsAVEZJIhFwYXJ0aWNpcGFudHMGOwBUewtJIhBh\nZGRfc3R1ZGVudAY7AFRGSSIWZWRpdF90ZWFtX21lbWJlcnMGOwBURkkiEmxp\nc3Rfc3R1ZGVudHMGOwBURkkiEWxpc3RfY291cnNlcwY7AFRGSSIVbGlzdF9h\nc3NpZ25tZW50cwY7AFRGSSISY2hhbmdlX2hhbmRsZQY7AFRUSSIQaW5zdGl0\ndXRpb24GOwBUewZJIglsaXN0BjsAVEZJIhFzdHVkZW50X3Rhc2sGOwBUewZJ\nIglsaXN0BjsAVFRJIgxwcm9maWxlBjsAVHsGSSIJZWRpdAY7AFRUSSIUc3Vy\ndmV5X3Jlc3BvbnNlBjsAVHsHSSILY3JlYXRlBjsAVFRJIgtzdWJtaXQGOwBU\nVEkiCXRlYW0GOwBUewdJIglsaXN0BjsAVEZJIhVsaXN0X2Fzc2lnbm1lbnRz\nBjsAVEZJIhB0ZWFtc191c2VycwY7AFR7BkkiCWxpc3QGOwBURkkiEGltcGVy\nc29uYXRlBjsAVHsHSSIKc3RhcnQGOwBURkkiEGltcGVyc29uYXRlBjsAVFRJ\nIhNyZXZpZXdfbWFwcGluZwY7AFR7C0kiCWxpc3QGOwBURkkiGWFkZF9keW5h\nbWljX3Jldmlld2VyBjsAVFRJIhhyZWxlYXNlX3Jlc2VydmF0aW9uBjsAVFRJ\nIh9zaG93X2F2YWlsYWJsZV9zdWJtaXNzaW9ucwY7AFRUSSIgYXNzaWduX3Jl\ndmlld2VyX2R5bmFtaWNhbGx5BjsAVFRJIiRhc3NpZ25fbWV0YXJldmlld2Vy\nX2R5bmFtaWNhbGx5BjsAVFRJIgtncmFkZXMGOwBUewZJIhN2aWV3X215X3Nj\nb3JlcwY7AFRUSSIWc3VydmV5X2RlcGxveW1lbnQGOwBUewZJIglsaXN0BjsA\nVEZJIg9zdGF0aXN0aWNzBjsAVHsGSSIRbGlzdF9zdXJ2ZXlzBjsAVEZJIhF0\ncmVlX2Rpc3BsYXkGOwBUexJJIglsaXN0BjsAVEZJIgpkcmlsbAY7AFRGSSIY\nZ290b19xdWVzdGlvbm5haXJlcwY7AFRGSSIaZ290b19hdXRob3JfZmVlZGJh\nY2tzBjsAVEZJIhhnb3RvX3Jldmlld19ydWJyaWNzBjsAVEZJIhdnb3RvX2ds\nb2JhbF9zdXJ2ZXkGOwBURkkiEWdvdG9fc3VydmV5cwY7AFRGSSIcZ290b19j\nb3Vyc2VfZXZhbHVhdGlvbnMGOwBURkkiEWdvdG9fY291cnNlcwY7AFRGSSIV\nZ290b19hc3NpZ25tZW50cwY7AFRGSSIaZ290b190ZWFtbWF0ZV9yZXZpZXdz\nBjsAVEZJIhxnb3RvX21ldGFyZXZpZXdfcnVicmljcwY7AFRGSSIgZ290b190\nZWFtbWF0ZXJldmlld19ydWJyaWNzBjsAVEZJIhJzaWduX3VwX3NoZWV0BjsA\nVHsISSIJbGlzdAY7AFRUSSILc2lnbnVwBjsAVFRJIhJkZWxldGVfc2lnbnVw\nBjsAVFRJIg9zdWdnZXN0aW9uBjsAVHsHSSILY3JlYXRlBjsAVFRJIghuZXcG\nOwBUVEkiEGxlYWRlcmJvYXJkBjsAVHsGSSIKaW5kZXgGOwBUVEkiC2Fkdmlj\nZQY7AFR7B0kiEGVkaXRfYWR2aWNlBjsAVEZJIhBzYXZlX2FkdmljZQY7AFRG\nSSIaYWR2ZXJ0aXNlX2Zvcl9wYXJ0bmVyBjsAVHsKSSIaYWRkX2FkdmVydGlz\nZV9jb21tZW50BjsAVFRJIgllZGl0BjsAVFRJIghuZXcGOwBUVEkiC3JlbW92\nZQY7AFRUSSILdXBkYXRlBjsAVFRJIhdqb2luX3RlYW1fcmVxdWVzdHMGOwBU\new1JIgtjcmVhdGUGOwBUVEkiDGRlY2xpbmUGOwBUVEkiDGRlc3Ryb3kGOwBU\nVEkiCWVkaXQGOwBUVEkiCmluZGV4BjsAVFRJIghuZXcGOwBUVEkiCXNob3cG\nOwBUVEkiC3VwZGF0ZQY7AFRUOhFAY29udHJvbGxlcnN7NkkiEmNvbnRlbnRf\ncGFnZXMGOwBURkkiF2NvbnRyb2xsZXJfYWN0aW9ucwY7AFRGSSIJYXV0aAY7\nAFRGSSISbWFya3VwX3N0eWxlcwY7AFRGSSIPbWVudV9pdGVtcwY7AFRGSSIQ\ncGVybWlzc2lvbnMGOwBURkkiCnJvbGVzBjsAVEZJIhVzaXRlX2NvbnRyb2xs\nZXJzBjsAVEZJIhRzeXN0ZW1fc2V0dGluZ3MGOwBURkkiCnVzZXJzBjsAVFRJ\nIhZyb2xlc19wZXJtaXNzaW9ucwY7AFRGSSIKYWRtaW4GOwBURkkiC2NvdXJz\nZQY7AFRGSSIPYXNzaWdubWVudAY7AFRGSSIScXVlc3Rpb25uYWlyZQY7AFRG\nSSILYWR2aWNlBjsAVEZJIhFwYXJ0aWNpcGFudHMGOwBURkkiDHJlcG9ydHMG\nOwBUVEkiEGluc3RpdHV0aW9uBjsAVEZJIhFzdHVkZW50X3Rhc2sGOwBUVEki\nDHByb2ZpbGUGOwBUVEkiFHN1cnZleV9yZXNwb25zZQY7AFRUSSIJdGVhbQY7\nAFRGSSIQdGVhbXNfdXNlcnMGOwBURkkiEGltcGVyc29uYXRlBjsAVEZJIhBp\nbXBvcnRfZmlsZQY7AFRGSSITcmV2aWV3X21hcHBpbmcGOwBURkkiC2dyYWRl\ncwY7AFRGSSIWY291cnNlX2V2YWx1YXRpb24GOwBUVEkiGHBhcnRpY2lwYW50\nX2Nob2ljZXMGOwBURkkiFnN1cnZleV9kZXBsb3ltZW50BjsAVEZJIg9zdGF0\naXN0aWNzBjsAVEZJIhF0cmVlX2Rpc3BsYXkGOwBURkkiEXN0dWRlbnRfdGVh\nbQY7AFRUSSIPaW52aXRhdGlvbgY7AFRUSSILc3VydmV5BjsAVEZJIhdwYXNz\nd29yZF9yZXRyaWV2YWwGOwBUVEkiFnN1Ym1pdHRlZF9jb250ZW50BjsAVFRJ\nIglldWxhBjsAVFRJIhNzdHVkZW50X3JldmlldwY7AFRUSSIPcHVibGlzaGlu\nZwY7AFRUSSIQZXhwb3J0X2ZpbGUGOwBURkkiDXJlc3BvbnNlBjsAVFRJIhJz\naWduX3VwX3NoZWV0BjsAVEZJIg9zdWdnZXN0aW9uBjsAVEZJIhBsZWFkZXJi\nb2FyZAY7AFRUSSISZGVsZXRlX29iamVjdAY7AFRGSSIaYWR2ZXJ0aXNlX2Zv\ncl9wYXJ0bmVyBjsAVFRJIhdqb2luX3RlYW1fcmVxdWVzdHMGOwBUVDoLQHBh\nZ2Vzew1JIglob21lBjsAVFRJIgxleHBpcmVkBjsAVFRJIg1ub3Rmb3VuZAY7\nAFRUSSILZGVuaWVkBjsAVFRJIg9jb250YWN0X3VzBjsAVFRJIg9zaXRlX2Fk\nbWluBjsAVEZJIgphZG1pbgY7AFRGSSIMY3JlZGl0cwY7AFRUSSIJbWVudQY7\nAEZvOglNZW51CzoKQHJvb3RvOg9NZW51OjpOb2RlBzoMQHBhcmVudDA7alsJ\naQZpCmkLaQw6C0BieV9pZHsLaQZvOwGCDzsBgzA7alsGaQ06D0BwYXJlbnRf\naWQwOx1JIglob21lBjsAVDoIQGlkaQY6C0BsYWJlbEkiCUhvbWUGOwBUOhhA\nc2l0ZV9jb250cm9sbGVyX2lkMDoaQGNvbnRyb2xsZXJfYWN0aW9uX2lkMDoV\nQGNvbnRlbnRfcGFnZV9pZGkGOglAdXJsSSIKL2hvbWUGOwBUaQpvOwGCDjsB\ngzA7AYUwOx1JIhFzdHVkZW50X3Rhc2sGOwBUOwGGaQo7AYdJIhBBc3NpZ25t\nZW50cwY7AFQ7AYhpGTsBiWkmOwGKMDsBi0kiFy9zdHVkZW50X3Rhc2svbGlz\ndAY7AFRpC287AYIOOwGDMDsBhTA7HUkiDHByb2ZpbGUGOwBUOwGGaQs7AYdJ\nIgxQcm9maWxlBjsAVDsBiGkaOwGJaSc7AYowOwGLSSISL3Byb2ZpbGUvZWRp\ndAY7AFRpDG87AYIPOwGDMDtqWwZpDjsBhTA7HUkiD2NvbnRhY3RfdXMGOwBU\nOwGGaQw7AYdJIg9Db250YWN0IFVzBjsAVDsBiDA7AYkwOwGKaQo7AYtJIhAv\nY29udGFjdF91cwY7AFRpDW87AYIOOwGDMDsBhWkGOx1JIhBsZWFkZXJib2Fy\nZAY7AFQ7AYZpDTsBh0kiEExlYWRlcmJvYXJkBjsAVDsBiGkzOwGJaUo7AYow\nOwGLSSIXL2xlYWRlcmJvYXJkL2luZGV4BjsAVGkObzsBgg47AYMwOwGFaQw7\nHUkiDGNyZWRpdHMGOwBUOwGGaQ47AYdJIhpDcmVkaXRzICZhbXA7IExpY2Vu\nY2UGOwBUOwGIMDsBiTA7AYppDTsBi0kiDS9jcmVkaXRzBjsAVDoNQGJ5X25h\nbWV7C0kiCWhvbWUGOwBUQAKlAUkiEXN0dWRlbnRfdGFzawY7AFRAAqoBSSIM\ncHJvZmlsZQY7AFRAAq4BSSIPY29udGFjdF91cwY7AFRAArIBSSIQbGVhZGVy\nYm9hcmQGOwBUQAK3AUkiDGNyZWRpdHMGOwBUQAK7AToOQHNlbGVjdGVkewZp\nBkACpQE6DEB2ZWN0b3JbB0ACogFAAqUBOgxAY3J1bWJzWwZpBkkiDnJldHVy\nbl90bwY7AEZJIj5odHRwOi8vMTI3LjAuMC4xOjU5NTY4L3NpZ25fdXBfc2hl\nZXQvbGlzdD9hc3NpZ25tZW50X2lkPTEGOwBUSSIKZmxhc2gGOwBUewdJIgxk\naXNjYXJkBjsAVFsGSSIKZXJyb3IGOwBGSSIMZmxhc2hlcwY7AFR7BkACzwFJ\nIipZb3UndmUgYWxyZWFkeSBzaWduZWQgdXAgZm9yIGEgdG9waWMhBjsAVA==\n','2015-12-13 14:43:45','2015-12-13 14:44:06'),(7,'a190d0eef600ee3a308f48c034404cee','BAh7DUkiEF9jc3JmX3Rva2VuBjoGRUZJIjFsL0dHcmxCUXQvQ3FMWUNpdHNy\nVzRqTkJ6UCtzbWhSQk9FL2MzTUlyZ1BZPQY7AEZJIgl1c2VyBjsARm86CVVz\nZXISOhBAYXR0cmlidXRlc286H0FjdGl2ZVJlY29yZDo6QXR0cmlidXRlU2V0\nBjsHbzokQWN0aXZlUmVjb3JkOjpMYXp5QXR0cmlidXRlSGFzaAo6C0B0eXBl\nc30bSSIHaWQGOwBUbzogQWN0aXZlUmVjb3JkOjpUeXBlOjpJbnRlZ2VyCToP\nQHByZWNpc2lvbjA6C0BzY2FsZTA6C0BsaW1pdGkJOgtAcmFuZ2VvOgpSYW5n\nZQg6CWV4Y2xUOgpiZWdpbmwtBwAAAIA6CGVuZGwrBwAAAIBJIgluYW1lBjsA\nVG86SEFjdGl2ZVJlY29yZDo6Q29ubmVjdGlvbkFkYXB0ZXJzOjpBYnN0cmFj\ndE15c3FsQWRhcHRlcjo6TXlzcWxTdHJpbmcIOwwwOw0wOw5pAf9JIhVjcnlw\ndGVkX3Bhc3N3b3JkBjsAVG87FAg7DDA7DTA7DmktSSIMcm9sZV9pZAY7AFRA\nDkkiEnBhc3N3b3JkX3NhbHQGOwBUQBNJIg1mdWxsbmFtZQY7AFRAE0kiCmVt\nYWlsBjsAVEATSSIOcGFyZW50X2lkBjsAVEAOSSIXcHJpdmF0ZV9ieV9kZWZh\ndWx0BjsAVG86IEFjdGl2ZVJlY29yZDo6VHlwZTo6Qm9vbGVhbgg7DDA7DTA7\nDmkGSSIXbXJ1X2RpcmVjdG9yeV9wYXRoBjsAVG87FAg7DDA7DTA7DmkBgEki\nFGVtYWlsX29uX3JldmlldwY7AFRAHEkiGGVtYWlsX29uX3N1Ym1pc3Npb24G\nOwBUQBxJIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsAVEAcSSIQaXNf\nbmV3X3VzZXIGOwBUQBxJIh5tYXN0ZXJfcGVybWlzc2lvbl9ncmFudGVkBjsA\nVG87Cwk7DDA7DTA7DmkGOw9vOxAIOxFUOxJp/4A7E2kBgEkiC2hhbmRsZQY7\nAFRAE0kiGGxlYWRlcmJvYXJkX3ByaXZhY3kGOwBUQBxJIhhkaWdpdGFsX2Nl\ncnRpZmljYXRlBjsAVG86HUFjdGl2ZVJlY29yZDo6VHlwZTo6VGV4dAg7DDA7\nDTA7DmkC//9JIhZwZXJzaXN0ZW5jZV90b2tlbgY7AFRAE0kiEXRpbWV6b25l\ncHJlZgY7AFRAE0kiD3B1YmxpY19rZXkGOwBUQClJIhNjb3B5X29mX2VtYWls\ncwY7AFRAHG86HkFjdGl2ZVJlY29yZDo6VHlwZTo6VmFsdWUIOwwwOw0wOw4w\nOgxAdmFsdWVzextJIgdpZAY7AFRpCUkiCW5hbWUGOwBUSSINc3R1ZGVudDMG\nOwBUSSIVY3J5cHRlZF9wYXNzd29yZAY7AFRJIi0xY2Y4NWFmMWU1MjY2MzYz\nOWYyYzI2MDdhNzBiYzZhZTZhOWVmMDU5BjsAVEkiDHJvbGVfaWQGOwBUaQZJ\nIhJwYXNzd29yZF9zYWx0BjsAVEkiGTFUT3FsSjJZWWFnY3hmQU10bnBwBjsA\nVEkiDWZ1bGxuYW1lBjsAVEkiE1N0dWRlbnQsIFRocmVlBjsAVEkiCmVtYWls\nBjsAVEkiFnN0dWRlbnQzQG5jc3UuZWR1BjsAVEkiDnBhcmVudF9pZAY7AFRp\nBkkiF3ByaXZhdGVfYnlfZGVmYXVsdAY7AFRpAEkiF21ydV9kaXJlY3Rvcnlf\ncGF0aAY7AFQwSSIUZW1haWxfb25fcmV2aWV3BjsAVDBJIhhlbWFpbF9vbl9z\ndWJtaXNzaW9uBjsAVDBJIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsA\nVDBJIhBpc19uZXdfdXNlcgY7AFRpAEkiHm1hc3Rlcl9wZXJtaXNzaW9uX2dy\nYW50ZWQGOwBUaQBJIgtoYW5kbGUGOwBUSSIABjsAVEkiGGxlYWRlcmJvYXJk\nX3ByaXZhY3kGOwBUaQBJIhhkaWdpdGFsX2NlcnRpZmljYXRlBjsAVDBJIhZw\nZXJzaXN0ZW5jZV90b2tlbgY7AFRJIgGAMWI5NjBkOTZmYjQ3ZmU2MDU3NGNm\nMGRhZGE1NDU5MDg1MDc0N2FkMmRiNDM1MzBiMDBmNzJlMWUxYWZhZDlmM2I3\nZmRlMGFhM2E1YTM2ZmMyNTViMGI1ODdhMjliMjVlZjgzM2UxYmZkNDg3OTU2\nYmIzOWY4ZTEwZTY1MWU5NDkGOwBUSSIRdGltZXpvbmVwcmVmBjsAVEkiH0Vh\nc3Rlcm4gVGltZSAoVVMgJiBDYW5hZGEpBjsAVEkiD3B1YmxpY19rZXkGOwBU\nMEkiE2NvcHlfb2ZfZW1haWxzBjsAVGkAOhZAYWRkaXRpb25hbF90eXBlc3sA\nOhJAbWF0ZXJpYWxpemVkRjoTQGRlbGVnYXRlX2hhc2h7CUkiEXRpbWV6b25l\ncHJlZgY7AFRvOipBY3RpdmVSZWNvcmQ6OkF0dHJpYnV0ZTo6RnJvbURhdGFi\nYXNlCToKQG5hbWVJIhF0aW1lem9uZXByZWYGOwBUOhxAdmFsdWVfYmVmb3Jl\nX3R5cGVfY2FzdEBLOgpAdHlwZUATOgtAdmFsdWVJIh9FYXN0ZXJuIFRpbWUg\nKFVTICYgQ2FuYWRhKQY7AFRJIgdpZAY7AEZvOxwJOx1JIgdpZAY7AEY7HmkJ\nOx9ADjsgaQlJIgxyb2xlX2lkBjsARm87HAk7HUkiDHJvbGVfaWQGOwBGOx5p\nBjsfQA47IGkGSSIJbmFtZQY7AFRvOxwJOx1AWjseQDI7H0ATOyBJIg1zdHVk\nZW50MwY7AFQ6F0BhZ2dyZWdhdGlvbl9jYWNoZXsAOhdAYXNzb2NpYXRpb25f\nY2FjaGV7BjoJcm9sZVU6NUFjdGl2ZVJlY29yZDo6QXNzb2NpYXRpb25zOjpC\nZWxvbmdzVG9Bc3NvY2lhdGlvblsHOyNbDFsHOgtAb3duZXJACVsHOgxAbG9h\nZGVkVFsHOgxAdGFyZ2V0bzoJUm9sZRI7B287CAY7B287CQo7Cn0NSSIHaWQG\nOwBUbzsLCTsMMDsNMDsOaQk7D287EAg7EVQ7EmwtBwAAAIA7E2wrBwAAAIBJ\nIgluYW1lBjsAVG87FAg7DDA7DTA7DmkB/0kiDnBhcmVudF9pZAY7AFRAakki\nEGRlc2NyaXB0aW9uBjsAVEBvSSIUZGVmYXVsdF9wYWdlX2lkBjsAVEBqSSIK\nY2FjaGUGOwBUVTojQWN0aXZlUmVjb3JkOjpUeXBlOjpTZXJpYWxpemVkWwk6\nC19fdjJfX1sHOg1Ac3VidHlwZToLQGNvZGVyWwdvOxYIOwwwOw0wOw5pAv//\nbzolQWN0aXZlUmVjb3JkOjpDb2RlcnM6OllBTUxDb2x1bW4GOhJAb2JqZWN0\nX2NsYXNzYwtPYmplY3RAeEkiD2NyZWF0ZWRfYXQGOwBUVTpKQWN0aXZlUmVj\nb3JkOjpBdHRyaWJ1dGVNZXRob2RzOjpUaW1lWm9uZUNvbnZlcnNpb246OlRp\nbWVab25lQ29udmVydGVyWwk7KlsAWwBvOkpBY3RpdmVSZWNvcmQ6OkNvbm5l\nY3Rpb25BZGFwdGVyczo6QWJzdHJhY3RNeXNxbEFkYXB0ZXI6Ok15c3FsRGF0\nZVRpbWUIOwwwOw0wOw4wSSIPdXBkYXRlZF9hdAY7AFRVOy9bCTsqWwBbAEAB\ne287Fwg7DDA7DTA7DjA7GHsNSSIHaWQGOwBUaQZJIgluYW1lBjsAVEkiDFN0\ndWRlbnQGOwBUSSIOcGFyZW50X2lkBjsAVDBJIhBkZXNjcmlwdGlvbgY7AFRJ\nIgAGOwBUSSIUZGVmYXVsdF9wYWdlX2lkBjsAVDBJIgpjYWNoZQY7AFRJIgLW\nFi0tLQo6Y3JlZGVudGlhbHM6ICFydWJ5L29iamVjdDpDcmVkZW50aWFscwog\nIHJvbGVfaWQ6IDEKICB1cGRhdGVkX2F0OiAyMDE1LTEyLTA0IDE5OjU3OjQz\nLjAwMDAwMDAwMCBaCiAgcm9sZV9pZHM6CiAgLSAxCiAgcGVybWlzc2lvbl9p\nZHM6CiAgLSA2CiAgLSA2CiAgLSA2CiAgLSAzCiAgLSAzCiAgLSAzCiAgLSAy\nCiAgLSAyCiAgLSAyCiAgYWN0aW9uczoKICAgIGNvbnRlbnRfcGFnZXM6CiAg\nICAgIHZpZXdfZGVmYXVsdDogdHJ1ZQogICAgICB2aWV3OiB0cnVlCiAgICAg\nIGxpc3Q6IGZhbHNlCiAgICBjb250cm9sbGVyX2FjdGlvbnM6CiAgICAgIGxp\nc3Q6IGZhbHNlCiAgICBhdXRoOgogICAgICBsb2dpbjogdHJ1ZQogICAgICBs\nb2dvdXQ6IHRydWUKICAgICAgbG9naW5fZmFpbGVkOiB0cnVlCiAgICBtZW51\nX2l0ZW1zOgogICAgICBsaW5rOiB0cnVlCiAgICAgIGxpc3Q6IGZhbHNlCiAg\nICBwZXJtaXNzaW9uczoKICAgICAgbGlzdDogZmFsc2UKICAgIHJvbGVzOgog\nICAgICBsaXN0OiBmYWxzZQogICAgc2l0ZV9jb250cm9sbGVyczoKICAgICAg\nbGlzdDogZmFsc2UKICAgIHN5c3RlbV9zZXR0aW5nczoKICAgICAgbGlzdDog\nZmFsc2UKICAgIHVzZXJzOgogICAgICBsaXN0OiBmYWxzZQogICAgICBrZXlz\nOiB0cnVlCiAgICBhZG1pbjoKICAgICAgbGlzdF9pbnN0cnVjdG9yczogZmFs\nc2UKICAgICAgbGlzdF9hZG1pbmlzdHJhdG9yczogZmFsc2UKICAgICAgbGlz\ndF9zdXBlcl9hZG1pbmlzdHJhdG9yczogZmFsc2UKICAgIGNvdXJzZToKICAg\nICAgbGlzdF9mb2xkZXJzOiBmYWxzZQogICAgYXNzaWdubWVudDoKICAgICAg\nbGlzdDogZmFsc2UKICAgIHF1ZXN0aW9ubmFpcmU6CiAgICAgIGxpc3Q6IGZh\nbHNlCiAgICAgIGNyZWF0ZV9xdWVzdGlvbm5haXJlOiBmYWxzZQogICAgICBl\nZGl0X3F1ZXN0aW9ubmFpcmU6IGZhbHNlCiAgICAgIGNvcHlfcXVlc3Rpb25u\nYWlyZTogZmFsc2UKICAgICAgc2F2ZV9xdWVzdGlvbm5haXJlOiBmYWxzZQog\nICAgcGFydGljaXBhbnRzOgogICAgICBhZGRfc3R1ZGVudDogZmFsc2UKICAg\nICAgZWRpdF90ZWFtX21lbWJlcnM6IGZhbHNlCiAgICAgIGxpc3Rfc3R1ZGVu\ndHM6IGZhbHNlCiAgICAgIGxpc3RfY291cnNlczogZmFsc2UKICAgICAgbGlz\ndF9hc3NpZ25tZW50czogZmFsc2UKICAgICAgY2hhbmdlX2hhbmRsZTogdHJ1\nZQogICAgaW5zdGl0dXRpb246CiAgICAgIGxpc3Q6IGZhbHNlCiAgICBzdHVk\nZW50X3Rhc2s6CiAgICAgIGxpc3Q6IHRydWUKICAgIHByb2ZpbGU6CiAgICAg\nIGVkaXQ6IHRydWUKICAgIHN1cnZleV9yZXNwb25zZToKICAgICAgY3JlYXRl\nOiB0cnVlCiAgICAgIHN1Ym1pdDogdHJ1ZQogICAgdGVhbToKICAgICAgbGlz\ndDogZmFsc2UKICAgICAgbGlzdF9hc3NpZ25tZW50czogZmFsc2UKICAgIHRl\nYW1zX3VzZXJzOgogICAgICBsaXN0OiBmYWxzZQogICAgaW1wZXJzb25hdGU6\nCiAgICAgIHN0YXJ0OiBmYWxzZQogICAgICBpbXBlcnNvbmF0ZTogdHJ1ZQog\nICAgcmV2aWV3X21hcHBpbmc6CiAgICAgIGxpc3Q6IGZhbHNlCiAgICAgIGFk\nZF9keW5hbWljX3Jldmlld2VyOiB0cnVlCiAgICAgIHJlbGVhc2VfcmVzZXJ2\nYXRpb246IHRydWUKICAgICAgc2hvd19hdmFpbGFibGVfc3VibWlzc2lvbnM6\nIHRydWUKICAgICAgYXNzaWduX3Jldmlld2VyX2R5bmFtaWNhbGx5OiB0cnVl\nCiAgICAgIGFzc2lnbl9tZXRhcmV2aWV3ZXJfZHluYW1pY2FsbHk6IHRydWUK\nICAgIGdyYWRlczoKICAgICAgdmlld19teV9zY29yZXM6IHRydWUKICAgIHN1\ncnZleV9kZXBsb3ltZW50OgogICAgICBsaXN0OiBmYWxzZQogICAgc3RhdGlz\ndGljczoKICAgICAgbGlzdF9zdXJ2ZXlzOiBmYWxzZQogICAgdHJlZV9kaXNw\nbGF5OgogICAgICBsaXN0OiBmYWxzZQogICAgICBkcmlsbDogZmFsc2UKICAg\nICAgZ290b19xdWVzdGlvbm5haXJlczogZmFsc2UKICAgICAgZ290b19hdXRo\nb3JfZmVlZGJhY2tzOiBmYWxzZQogICAgICBnb3RvX3Jldmlld19ydWJyaWNz\nOiBmYWxzZQogICAgICBnb3RvX2dsb2JhbF9zdXJ2ZXk6IGZhbHNlCiAgICAg\nIGdvdG9fc3VydmV5czogZmFsc2UKICAgICAgZ290b19jb3Vyc2VfZXZhbHVh\ndGlvbnM6IGZhbHNlCiAgICAgIGdvdG9fY291cnNlczogZmFsc2UKICAgICAg\nZ290b19hc3NpZ25tZW50czogZmFsc2UKICAgICAgZ290b190ZWFtbWF0ZV9y\nZXZpZXdzOiBmYWxzZQogICAgICBnb3RvX21ldGFyZXZpZXdfcnVicmljczog\nZmFsc2UKICAgICAgZ290b190ZWFtbWF0ZXJldmlld19ydWJyaWNzOiBmYWxz\nZQogICAgc2lnbl91cF9zaGVldDoKICAgICAgbGlzdDogdHJ1ZQogICAgICBz\naWdudXA6IHRydWUKICAgICAgZGVsZXRlX3NpZ251cDogdHJ1ZQogICAgc3Vn\nZ2VzdGlvbjoKICAgICAgY3JlYXRlOiB0cnVlCiAgICAgIG5ldzogdHJ1ZQog\nICAgbGVhZGVyYm9hcmQ6CiAgICAgIGluZGV4OiB0cnVlCiAgICBhZHZpY2U6\nCiAgICAgIGVkaXRfYWR2aWNlOiBmYWxzZQogICAgICBzYXZlX2FkdmljZTog\nZmFsc2UKICAgIGFkdmVydGlzZV9mb3JfcGFydG5lcjoKICAgICAgYWRkX2Fk\ndmVydGlzZV9jb21tZW50OiB0cnVlCiAgICAgIGVkaXQ6IHRydWUKICAgICAg\nbmV3OiB0cnVlCiAgICAgIHJlbW92ZTogdHJ1ZQogICAgICB1cGRhdGU6IHRy\ndWUKICAgIGpvaW5fdGVhbV9yZXF1ZXN0czoKICAgICAgY3JlYXRlOiB0cnVl\nCiAgICAgIGRlY2xpbmU6IHRydWUKICAgICAgZGVzdHJveTogdHJ1ZQogICAg\nICBlZGl0OiB0cnVlCiAgICAgIGluZGV4OiB0cnVlCiAgICAgIG5ldzogdHJ1\nZQogICAgICBzaG93OiB0cnVlCiAgICAgIHVwZGF0ZTogdHJ1ZQogIGNvbnRy\nb2xsZXJzOgogICAgY29udGVudF9wYWdlczogZmFsc2UKICAgIGNvbnRyb2xs\nZXJfYWN0aW9uczogZmFsc2UKICAgIGF1dGg6IGZhbHNlCiAgICBtYXJrdXBf\nc3R5bGVzOiBmYWxzZQogICAgbWVudV9pdGVtczogZmFsc2UKICAgIHBlcm1p\nc3Npb25zOiBmYWxzZQogICAgcm9sZXM6IGZhbHNlCiAgICBzaXRlX2NvbnRy\nb2xsZXJzOiBmYWxzZQogICAgc3lzdGVtX3NldHRpbmdzOiBmYWxzZQogICAg\ndXNlcnM6IHRydWUKICAgIHJvbGVzX3Blcm1pc3Npb25zOiBmYWxzZQogICAg\nYWRtaW46IGZhbHNlCiAgICBjb3Vyc2U6IGZhbHNlCiAgICBhc3NpZ25tZW50\nOiBmYWxzZQogICAgcXVlc3Rpb25uYWlyZTogZmFsc2UKICAgIGFkdmljZTog\nZmFsc2UKICAgIHBhcnRpY2lwYW50czogZmFsc2UKICAgIHJlcG9ydHM6IHRy\ndWUKICAgIGluc3RpdHV0aW9uOiBmYWxzZQogICAgc3R1ZGVudF90YXNrOiB0\ncnVlCiAgICBwcm9maWxlOiB0cnVlCiAgICBzdXJ2ZXlfcmVzcG9uc2U6IHRy\ndWUKICAgIHRlYW06IGZhbHNlCiAgICB0ZWFtc191c2VyczogZmFsc2UKICAg\nIGltcGVyc29uYXRlOiBmYWxzZQogICAgaW1wb3J0X2ZpbGU6IGZhbHNlCiAg\nICByZXZpZXdfbWFwcGluZzogZmFsc2UKICAgIGdyYWRlczogZmFsc2UKICAg\nIGNvdXJzZV9ldmFsdWF0aW9uOiB0cnVlCiAgICBwYXJ0aWNpcGFudF9jaG9p\nY2VzOiBmYWxzZQogICAgc3VydmV5X2RlcGxveW1lbnQ6IGZhbHNlCiAgICBz\ndGF0aXN0aWNzOiBmYWxzZQogICAgdHJlZV9kaXNwbGF5OiBmYWxzZQogICAg\nc3R1ZGVudF90ZWFtOiB0cnVlCiAgICBpbnZpdGF0aW9uOiB0cnVlCiAgICBz\ndXJ2ZXk6IGZhbHNlCiAgICBwYXNzd29yZF9yZXRyaWV2YWw6IHRydWUKICAg\nIHN1Ym1pdHRlZF9jb250ZW50OiB0cnVlCiAgICBldWxhOiB0cnVlCiAgICBz\ndHVkZW50X3JldmlldzogdHJ1ZQogICAgcHVibGlzaGluZzogdHJ1ZQogICAg\nZXhwb3J0X2ZpbGU6IGZhbHNlCiAgICByZXNwb25zZTogdHJ1ZQogICAgc2ln\nbl91cF9zaGVldDogZmFsc2UKICAgIHN1Z2dlc3Rpb246IGZhbHNlCiAgICBs\nZWFkZXJib2FyZDogdHJ1ZQogICAgZGVsZXRlX29iamVjdDogZmFsc2UKICAg\nIGFkdmVydGlzZV9mb3JfcGFydG5lcjogdHJ1ZQogICAgam9pbl90ZWFtX3Jl\ncXVlc3RzOiB0cnVlCiAgcGFnZXM6CiAgICBob21lOiB0cnVlCiAgICBleHBp\ncmVkOiB0cnVlCiAgICBub3Rmb3VuZDogdHJ1ZQogICAgZGVuaWVkOiB0cnVl\nCiAgICBjb250YWN0X3VzOiB0cnVlCiAgICBzaXRlX2FkbWluOiBmYWxzZQog\nICAgYWRtaW46IGZhbHNlCiAgICBjcmVkaXRzOiB0cnVlCjptZW51OiAhcnVi\neS9vYmplY3Q6TWVudQogIHJvb3Q6ICY3ICFydWJ5L29iamVjdDpNZW51OjpO\nb2RlCiAgICBwYXJlbnQ6IAogICAgY2hpbGRyZW46CiAgICAtIDEKICAgIC0g\nNQogICAgLSA2CiAgICAtIDcKICBieV9pZDoKICAgIDE6ICYxICFydWJ5L29i\namVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIGNoaWxkcmVu\nOgogICAgICAtIDgKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTogaG9t\nZQogICAgICBpZDogMQogICAgICBsYWJlbDogSG9tZQogICAgICBzaXRlX2Nv\nbnRyb2xsZXJfaWQ6IAogICAgICBjb250cm9sbGVyX2FjdGlvbl9pZDogCiAg\nICAgIGNvbnRlbnRfcGFnZV9pZDogMQogICAgICB1cmw6ICIvaG9tZSIKICAg\nIDU6ICYyICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDog\nCiAgICAgIHBhcmVudF9pZDogCiAgICAgIG5hbWU6IHN0dWRlbnRfdGFzawog\nICAgICBpZDogNQogICAgICBsYWJlbDogQXNzaWdubWVudHMKICAgICAgc2l0\nZV9jb250cm9sbGVyX2lkOiAyMAogICAgICBjb250cm9sbGVyX2FjdGlvbl9p\nZDogMzMKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAiL3N0\ndWRlbnRfdGFzay9saXN0IgogICAgNjogJjMgIXJ1Ynkvb2JqZWN0Ok1lbnU6\nOk5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAKICAgICAg\nbmFtZTogcHJvZmlsZQogICAgICBpZDogNgogICAgICBsYWJlbDogUHJvZmls\nZQogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDIxCiAgICAgIGNvbnRyb2xs\nZXJfYWN0aW9uX2lkOiAzNAogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAg\nICB1cmw6ICIvcHJvZmlsZS9lZGl0IgogICAgNzogJjQgIXJ1Ynkvb2JqZWN0\nOk1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgY2hpbGRyZW46CiAg\nICAgIC0gOQogICAgICBwYXJlbnRfaWQ6IAogICAgICBuYW1lOiBjb250YWN0\nX3VzCiAgICAgIGlkOiA3CiAgICAgIGxhYmVsOiBDb250YWN0IFVzCiAgICAg\nIHNpdGVfY29udHJvbGxlcl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9u\nX2lkOiAKICAgICAgY29udGVudF9wYWdlX2lkOiA1CiAgICAgIHVybDogIi9j\nb250YWN0X3VzIgogICAgODogJjUgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUK\nICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAxCiAgICAgIG5hbWU6\nIGxlYWRlcmJvYXJkCiAgICAgIGlkOiA4CiAgICAgIGxhYmVsOiBMZWFkZXJi\nb2FyZAogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDQ2CiAgICAgIGNvbnRy\nb2xsZXJfYWN0aW9uX2lkOiA2OQogICAgICBjb250ZW50X3BhZ2VfaWQ6IAog\nICAgICB1cmw6ICIvbGVhZGVyYm9hcmQvaW5kZXgiCiAgICA5OiAmNiAhcnVi\neS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJl\nbnRfaWQ6IDcKICAgICAgbmFtZTogY3JlZGl0cwogICAgICBpZDogOQogICAg\nICBsYWJlbDogQ3JlZGl0cyAmYW1wOyBMaWNlbmNlCiAgICAgIHNpdGVfY29u\ndHJvbGxlcl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAKICAg\nICAgY29udGVudF9wYWdlX2lkOiA4CiAgICAgIHVybDogIi9jcmVkaXRzIgog\nIGJ5X25hbWU6CiAgICBob21lOiAqMQogICAgc3R1ZGVudF90YXNrOiAqMgog\nICAgcHJvZmlsZTogKjMKICAgIGNvbnRhY3RfdXM6ICo0CiAgICBsZWFkZXJi\nb2FyZDogKjUKICAgIGNyZWRpdHM6ICo2CiAgc2VsZWN0ZWQ6CiAgICAxOiAq\nMQogIHZlY3RvcjoKICAtICo3CiAgLSAqMQogIGNydW1iczoKICAtIDEKBjsA\nVEkiD2NyZWF0ZWRfYXQGOwBUSXU6CVRpbWUNk+wcwAAAAOAGOgl6b25lSSII\nVVRDBjsARkkiD3VwZGF0ZWRfYXQGOwBUSXU7MQ2T7BzAAADA5gY7MkkiCFVU\nQwY7AEY7GXsAOxpGOxt7BkBabzscCTsdQFo7HkABhTsfQG87IEkiDFN0dWRl\nbnQGOwBUOyF7ADsiewA6DkByZWFkb25seUY6D0BkZXN0cm95ZWRGOhxAbWFy\na2VkX2Zvcl9kZXN0cnVjdGlvbkY6HkBkZXN0cm95ZWRfYnlfYXNzb2NpYXRp\nb24wOhBAbmV3X3JlY29yZEY6CUB0eG4wOh5AX3N0YXJ0X3RyYW5zYWN0aW9u\nX3N0YXRlewA6F0B0cmFuc2FjdGlvbl9zdGF0ZTA6FEByZWZsZWN0c19zdGF0\nZVsGRjodQG1hc3NfYXNzaWdubWVudF9vcHRpb25zMFsHOhFAc3RhbGVfc3Rh\ndGVJIgYxBjsARlsHOg5AaW52ZXJzZWRGWwc6DUB1cGRhdGVkRlsHOhdAYXNz\nb2NpYXRpb25fc2NvcGVvOiBSb2xlOjpBY3RpdmVSZWNvcmRfUmVsYXRpb24S\nOgtAa2xhc3NjCVJvbGU6C0B0YWJsZW86EEFyZWw6OlRhYmxlCzsdSSIKcm9s\nZXMGOwBUOgxAZW5naW5lQAGgOg1AY29sdW1uczA6DUBhbGlhc2VzWwA6EUB0\nYWJsZV9hbGlhczA6EUBwcmltYXJ5X2tleTA7GHsIOg5leHRlbmRpbmdbADoJ\nYmluZFsGWwdvOkNBY3RpdmVSZWNvcmQ6OkNvbm5lY3Rpb25BZGFwdGVyczo6\nQWJzdHJhY3RNeXNxbEFkYXB0ZXI6OkNvbHVtbg46DEBzdHJpY3RUOg9AY29s\nbGF0aW9uMDoLQGV4dHJhSSITYXV0b19pbmNyZW1lbnQGOwBUOx1JIgdpZAY7\nAFQ6D0BjYXN0X3R5cGVAajoOQHNxbF90eXBlSSIMaW50KDExKQY7AFQ6CkBu\ndWxsRjoNQGRlZmF1bHQwOhZAZGVmYXVsdF9mdW5jdGlvbjBpBjoKd2hlcmVb\nBm86GkFyZWw6Ok5vZGVzOjpFcXVhbGl0eQc6CkBsZWZ0UzogQXJlbDo6QXR0\ncmlidXRlczo6QXR0cmlidXRlBzoNcmVsYXRpb25vO0QLOx1AAaI7RWMXQWN0\naXZlUmVjb3JkOjpCYXNlO0YwO0dbADtIMDtJMDoJbmFtZUkiB2lkBjsAVDoL\nQHJpZ2h0bzobQXJlbDo6Tm9kZXM6OkJpbmRQYXJhbQA6DUBvZmZzZXRzewA7\nJjA6CkBhcmVsbzoYQXJlbDo6U2VsZWN0TWFuYWdlcgk7RUABoDoJQGN0eG86\nHEFyZWw6Ok5vZGVzOjpTZWxlY3RDb3JlDToMQHNvdXJjZW86HEFyZWw6Ok5v\nZGVzOjpKb2luU291cmNlBztXQAGhO1tbADoJQHRvcDA6FEBzZXRfcXVhbnRp\nZmllcjA6EUBwcm9qZWN0aW9uc1sGUztYBztZQAGhO1pJQzocQXJlbDo6Tm9k\nZXM6OlNxbExpdGVyYWwiBioGOwBUOgxAd2hlcmVzWwZvOhVBcmVsOjpOb2Rl\nczo6QW5kBjoOQGNoaWxkcmVuWwZAAa06DEBncm91cHNbADoMQGhhdmluZzA6\nDUB3aW5kb3dzWwA6EUBiaW5kX3ZhbHVlc1sAOglAYXN0bzohQXJlbDo6Tm9k\nZXM6OlNlbGVjdFN0YXRlbWVudAs6C0Bjb3Jlc1sGQAG2OgxAb3JkZXJzWwA7\nDjA6CkBsb2NrMDoMQG9mZnNldDA6CkB3aXRoMDoWQHNjb3BlX2Zvcl9jcmVh\ndGUwOhJAb3JkZXJfY2xhdXNlMDoMQHRvX3NxbDA6CkBsYXN0MDoVQGpvaW5f\nZGVwZW5kZW5jeTA6F0BzaG91bGRfZWFnZXJfbG9hZDA6DUByZWNvcmRzWwA7\nM0Y7NEY7NUY7NjA7N0Y7ODA7OXsAOzowOztbBkY7PDBJIhBjcmVkZW50aWFs\ncwY7AEZvOhBDcmVkZW50aWFscww6DUByb2xlX2lkaQY6EEB1cGRhdGVkX2F0\nSXU7MQ2T7BzAAACw5gY7MkkiCFVUQwY7AEY6DkByb2xlX2lkc1sGaQY6FEBw\nZXJtaXNzaW9uX2lkc1sOaQtpC2kLaQhpCGkIaQdpB2kHOg1AYWN0aW9uc3sl\nSSISY29udGVudF9wYWdlcwY7AFR7CEkiEXZpZXdfZGVmYXVsdAY7AFRUSSIJ\ndmlldwY7AFRUSSIJbGlzdAY7AFRGSSIXY29udHJvbGxlcl9hY3Rpb25zBjsA\nVHsGSSIJbGlzdAY7AFRGSSIJYXV0aAY7AFR7CEkiCmxvZ2luBjsAVFRJIgts\nb2dvdXQGOwBUVEkiEWxvZ2luX2ZhaWxlZAY7AFRUSSIPbWVudV9pdGVtcwY7\nAFR7B0kiCWxpbmsGOwBUVEkiCWxpc3QGOwBURkkiEHBlcm1pc3Npb25zBjsA\nVHsGSSIJbGlzdAY7AFRGSSIKcm9sZXMGOwBUewZJIglsaXN0BjsAVEZJIhVz\naXRlX2NvbnRyb2xsZXJzBjsAVHsGSSIJbGlzdAY7AFRGSSIUc3lzdGVtX3Nl\ndHRpbmdzBjsAVHsGSSIJbGlzdAY7AFRGSSIKdXNlcnMGOwBUewdJIglsaXN0\nBjsAVEZJIglrZXlzBjsAVFRJIgphZG1pbgY7AFR7CEkiFWxpc3RfaW5zdHJ1\nY3RvcnMGOwBURkkiGGxpc3RfYWRtaW5pc3RyYXRvcnMGOwBURkkiHmxpc3Rf\nc3VwZXJfYWRtaW5pc3RyYXRvcnMGOwBURkkiC2NvdXJzZQY7AFR7BkkiEWxp\nc3RfZm9sZGVycwY7AFRGSSIPYXNzaWdubWVudAY7AFR7BkkiCWxpc3QGOwBU\nRkkiEnF1ZXN0aW9ubmFpcmUGOwBUewpJIglsaXN0BjsAVEZJIhljcmVhdGVf\ncXVlc3Rpb25uYWlyZQY7AFRGSSIXZWRpdF9xdWVzdGlvbm5haXJlBjsAVEZJ\nIhdjb3B5X3F1ZXN0aW9ubmFpcmUGOwBURkkiF3NhdmVfcXVlc3Rpb25uYWly\nZQY7AFRGSSIRcGFydGljaXBhbnRzBjsAVHsLSSIQYWRkX3N0dWRlbnQGOwBU\nRkkiFmVkaXRfdGVhbV9tZW1iZXJzBjsAVEZJIhJsaXN0X3N0dWRlbnRzBjsA\nVEZJIhFsaXN0X2NvdXJzZXMGOwBURkkiFWxpc3RfYXNzaWdubWVudHMGOwBU\nRkkiEmNoYW5nZV9oYW5kbGUGOwBUVEkiEGluc3RpdHV0aW9uBjsAVHsGSSIJ\nbGlzdAY7AFRGSSIRc3R1ZGVudF90YXNrBjsAVHsGSSIJbGlzdAY7AFRUSSIM\ncHJvZmlsZQY7AFR7BkkiCWVkaXQGOwBUVEkiFHN1cnZleV9yZXNwb25zZQY7\nAFR7B0kiC2NyZWF0ZQY7AFRUSSILc3VibWl0BjsAVFRJIgl0ZWFtBjsAVHsH\nSSIJbGlzdAY7AFRGSSIVbGlzdF9hc3NpZ25tZW50cwY7AFRGSSIQdGVhbXNf\ndXNlcnMGOwBUewZJIglsaXN0BjsAVEZJIhBpbXBlcnNvbmF0ZQY7AFR7B0ki\nCnN0YXJ0BjsAVEZJIhBpbXBlcnNvbmF0ZQY7AFRUSSITcmV2aWV3X21hcHBp\nbmcGOwBUewtJIglsaXN0BjsAVEZJIhlhZGRfZHluYW1pY19yZXZpZXdlcgY7\nAFRUSSIYcmVsZWFzZV9yZXNlcnZhdGlvbgY7AFRUSSIfc2hvd19hdmFpbGFi\nbGVfc3VibWlzc2lvbnMGOwBUVEkiIGFzc2lnbl9yZXZpZXdlcl9keW5hbWlj\nYWxseQY7AFRUSSIkYXNzaWduX21ldGFyZXZpZXdlcl9keW5hbWljYWxseQY7\nAFRUSSILZ3JhZGVzBjsAVHsGSSITdmlld19teV9zY29yZXMGOwBUVEkiFnN1\ncnZleV9kZXBsb3ltZW50BjsAVHsGSSIJbGlzdAY7AFRGSSIPc3RhdGlzdGlj\ncwY7AFR7BkkiEWxpc3Rfc3VydmV5cwY7AFRGSSIRdHJlZV9kaXNwbGF5BjsA\nVHsSSSIJbGlzdAY7AFRGSSIKZHJpbGwGOwBURkkiGGdvdG9fcXVlc3Rpb25u\nYWlyZXMGOwBURkkiGmdvdG9fYXV0aG9yX2ZlZWRiYWNrcwY7AFRGSSIYZ290\nb19yZXZpZXdfcnVicmljcwY7AFRGSSIXZ290b19nbG9iYWxfc3VydmV5BjsA\nVEZJIhFnb3RvX3N1cnZleXMGOwBURkkiHGdvdG9fY291cnNlX2V2YWx1YXRp\nb25zBjsAVEZJIhFnb3RvX2NvdXJzZXMGOwBURkkiFWdvdG9fYXNzaWdubWVu\ndHMGOwBURkkiGmdvdG9fdGVhbW1hdGVfcmV2aWV3cwY7AFRGSSIcZ290b19t\nZXRhcmV2aWV3X3J1YnJpY3MGOwBURkkiIGdvdG9fdGVhbW1hdGVyZXZpZXdf\ncnVicmljcwY7AFRGSSISc2lnbl91cF9zaGVldAY7AFR7CEkiCWxpc3QGOwBU\nVEkiC3NpZ251cAY7AFRUSSISZGVsZXRlX3NpZ251cAY7AFRUSSIPc3VnZ2Vz\ndGlvbgY7AFR7B0kiC2NyZWF0ZQY7AFRUSSIIbmV3BjsAVFRJIhBsZWFkZXJi\nb2FyZAY7AFR7BkkiCmluZGV4BjsAVFRJIgthZHZpY2UGOwBUewdJIhBlZGl0\nX2FkdmljZQY7AFRGSSIQc2F2ZV9hZHZpY2UGOwBURkkiGmFkdmVydGlzZV9m\nb3JfcGFydG5lcgY7AFR7CkkiGmFkZF9hZHZlcnRpc2VfY29tbWVudAY7AFRU\nSSIJZWRpdAY7AFRUSSIIbmV3BjsAVFRJIgtyZW1vdmUGOwBUVEkiC3VwZGF0\nZQY7AFRUSSIXam9pbl90ZWFtX3JlcXVlc3RzBjsAVHsNSSILY3JlYXRlBjsA\nVFRJIgxkZWNsaW5lBjsAVFRJIgxkZXN0cm95BjsAVFRJIgllZGl0BjsAVFRJ\nIgppbmRleAY7AFRUSSIIbmV3BjsAVFRJIglzaG93BjsAVFRJIgt1cGRhdGUG\nOwBUVDoRQGNvbnRyb2xsZXJzezZJIhJjb250ZW50X3BhZ2VzBjsAVEZJIhdj\nb250cm9sbGVyX2FjdGlvbnMGOwBURkkiCWF1dGgGOwBURkkiEm1hcmt1cF9z\ndHlsZXMGOwBURkkiD21lbnVfaXRlbXMGOwBURkkiEHBlcm1pc3Npb25zBjsA\nVEZJIgpyb2xlcwY7AFRGSSIVc2l0ZV9jb250cm9sbGVycwY7AFRGSSIUc3lz\ndGVtX3NldHRpbmdzBjsAVEZJIgp1c2VycwY7AFRUSSIWcm9sZXNfcGVybWlz\nc2lvbnMGOwBURkkiCmFkbWluBjsAVEZJIgtjb3Vyc2UGOwBURkkiD2Fzc2ln\nbm1lbnQGOwBURkkiEnF1ZXN0aW9ubmFpcmUGOwBURkkiC2FkdmljZQY7AFRG\nSSIRcGFydGljaXBhbnRzBjsAVEZJIgxyZXBvcnRzBjsAVFRJIhBpbnN0aXR1\ndGlvbgY7AFRGSSIRc3R1ZGVudF90YXNrBjsAVFRJIgxwcm9maWxlBjsAVFRJ\nIhRzdXJ2ZXlfcmVzcG9uc2UGOwBUVEkiCXRlYW0GOwBURkkiEHRlYW1zX3Vz\nZXJzBjsAVEZJIhBpbXBlcnNvbmF0ZQY7AFRGSSIQaW1wb3J0X2ZpbGUGOwBU\nRkkiE3Jldmlld19tYXBwaW5nBjsAVEZJIgtncmFkZXMGOwBURkkiFmNvdXJz\nZV9ldmFsdWF0aW9uBjsAVFRJIhhwYXJ0aWNpcGFudF9jaG9pY2VzBjsAVEZJ\nIhZzdXJ2ZXlfZGVwbG95bWVudAY7AFRGSSIPc3RhdGlzdGljcwY7AFRGSSIR\ndHJlZV9kaXNwbGF5BjsAVEZJIhFzdHVkZW50X3RlYW0GOwBUVEkiD2ludml0\nYXRpb24GOwBUVEkiC3N1cnZleQY7AFRGSSIXcGFzc3dvcmRfcmV0cmlldmFs\nBjsAVFRJIhZzdWJtaXR0ZWRfY29udGVudAY7AFRUSSIJZXVsYQY7AFRUSSIT\nc3R1ZGVudF9yZXZpZXcGOwBUVEkiD3B1Ymxpc2hpbmcGOwBUVEkiEGV4cG9y\ndF9maWxlBjsAVEZJIg1yZXNwb25zZQY7AFRUSSISc2lnbl91cF9zaGVldAY7\nAFRGSSIPc3VnZ2VzdGlvbgY7AFRGSSIQbGVhZGVyYm9hcmQGOwBUVEkiEmRl\nbGV0ZV9vYmplY3QGOwBURkkiGmFkdmVydGlzZV9mb3JfcGFydG5lcgY7AFRU\nSSIXam9pbl90ZWFtX3JlcXVlc3RzBjsAVFQ6C0BwYWdlc3sNSSIJaG9tZQY7\nAFRUSSIMZXhwaXJlZAY7AFRUSSINbm90Zm91bmQGOwBUVEkiC2RlbmllZAY7\nAFRUSSIPY29udGFjdF91cwY7AFRUSSIPc2l0ZV9hZG1pbgY7AFRGSSIKYWRt\naW4GOwBURkkiDGNyZWRpdHMGOwBUVEkiCW1lbnUGOwBGbzoJTWVudQs6CkBy\nb290bzoPTWVudTo6Tm9kZQc6DEBwYXJlbnQwO2pbCWkGaQppC2kMOgtAYnlf\naWR7C2kGbzsBgg87AYMwO2pbBmkNOg9AcGFyZW50X2lkMDsdSSIJaG9tZQY7\nAFQ6CEBpZGkGOgtAbGFiZWxJIglIb21lBjsAVDoYQHNpdGVfY29udHJvbGxl\ncl9pZDA6GkBjb250cm9sbGVyX2FjdGlvbl9pZDA6FUBjb250ZW50X3BhZ2Vf\naWRpBjoJQHVybEkiCi9ob21lBjsAVGkKbzsBgg47AYMwOwGFMDsdSSIRc3R1\nZGVudF90YXNrBjsAVDsBhmkKOwGHSSIQQXNzaWdubWVudHMGOwBUOwGIaRk7\nAYlpJjsBijA7AYtJIhcvc3R1ZGVudF90YXNrL2xpc3QGOwBUaQtvOwGCDjsB\ngzA7AYUwOx1JIgxwcm9maWxlBjsAVDsBhmkLOwGHSSIMUHJvZmlsZQY7AFQ7\nAYhpGjsBiWknOwGKMDsBi0kiEi9wcm9maWxlL2VkaXQGOwBUaQxvOwGCDzsB\ngzA7alsGaQ47AYUwOx1JIg9jb250YWN0X3VzBjsAVDsBhmkMOwGHSSIPQ29u\ndGFjdCBVcwY7AFQ7AYgwOwGJMDsBimkKOwGLSSIQL2NvbnRhY3RfdXMGOwBU\naQ1vOwGCDjsBgzA7AYVpBjsdSSIQbGVhZGVyYm9hcmQGOwBUOwGGaQ07AYdJ\nIhBMZWFkZXJib2FyZAY7AFQ7AYhpMzsBiWlKOwGKMDsBi0kiFy9sZWFkZXJi\nb2FyZC9pbmRleAY7AFRpDm87AYIOOwGDMDsBhWkMOx1JIgxjcmVkaXRzBjsA\nVDsBhmkOOwGHSSIaQ3JlZGl0cyAmYW1wOyBMaWNlbmNlBjsAVDsBiDA7AYkw\nOwGKaQ07AYtJIg0vY3JlZGl0cwY7AFQ6DUBieV9uYW1lewtJIglob21lBjsA\nVEACowFJIhFzdHVkZW50X3Rhc2sGOwBUQAKoAUkiDHByb2ZpbGUGOwBUQAKs\nAUkiD2NvbnRhY3RfdXMGOwBUQAKwAUkiEGxlYWRlcmJvYXJkBjsAVEACtQFJ\nIgxjcmVkaXRzBjsAVEACuQE6DkBzZWxlY3RlZHsGaQZAAqMBOgxAdmVjdG9y\nWwdAAqABQAKjAToMQGNydW1ic1sGaQZJIhJsYXN0X29wZW5fdGFiBjsARkki\nBjIGOwBUSSIOcmV0dXJuX3RvBjsARkkiLWh0dHA6Ly9sb2NhbGhvc3Q6MzAw\nMC9hc3NpZ25tZW50cy8yL2VkaXQGOwBUSSIKY2xlYXIGOwBGVEkiD3N1cGVy\nX3VzZXIGOwBGbzsGEjsHbzsIBjsHbzsJCjsKfRtJIgdpZAY7AFRvOwsJOwww\nOw0wOw5pCTsPbzsQCDsRVDsSbC0HAAAAgDsTbCsHAAAAgEkiCW5hbWUGOwBU\nbzsUCDsMMDsNMDsOaQH/SSIVY3J5cHRlZF9wYXNzd29yZAY7AFRvOxQIOwww\nOw0wOw5pLUkiDHJvbGVfaWQGOwBUQALSAUkiEnBhc3N3b3JkX3NhbHQGOwBU\nQALXAUkiDWZ1bGxuYW1lBjsAVEAC1wFJIgplbWFpbAY7AFRAAtcBSSIOcGFy\nZW50X2lkBjsAVEAC0gFJIhdwcml2YXRlX2J5X2RlZmF1bHQGOwBUbzsVCDsM\nMDsNMDsOaQZJIhdtcnVfZGlyZWN0b3J5X3BhdGgGOwBUbzsUCDsMMDsNMDsO\naQGASSIUZW1haWxfb25fcmV2aWV3BjsAVEAC4AFJIhhlbWFpbF9vbl9zdWJt\naXNzaW9uBjsAVEAC4AFJIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsA\nVEAC4AFJIhBpc19uZXdfdXNlcgY7AFRAAuABSSIebWFzdGVyX3Blcm1pc3Np\nb25fZ3JhbnRlZAY7AFRvOwsJOwwwOw0wOw5pBjsPbzsQCDsRVDsSaf+AOxNp\nAYBJIgtoYW5kbGUGOwBUQALXAUkiGGxlYWRlcmJvYXJkX3ByaXZhY3kGOwBU\nQALgAUkiGGRpZ2l0YWxfY2VydGlmaWNhdGUGOwBUbzsWCDsMMDsNMDsOaQL/\n/0kiFnBlcnNpc3RlbmNlX3Rva2VuBjsAVEAC1wFJIhF0aW1lem9uZXByZWYG\nOwBUQALXAUkiD3B1YmxpY19rZXkGOwBUQALtAUkiE2NvcHlfb2ZfZW1haWxz\nBjsAVEAC4AFvOxcIOwwwOw0wOw4wOxh7G0kiB2lkBjsAVGkGSSIJbmFtZQY7\nAFRJIgphZG1pbgY7AFRJIhVjcnlwdGVkX3Bhc3N3b3JkBjsAVEkiLWQwMzNl\nMjJhZTM0OGFlYjU2NjBmYzIxNDBhZWMzNTg1MGM0ZGE5OTcGOwBUSSIMcm9s\nZV9pZAY7AFRpCkkiEnBhc3N3b3JkX3NhbHQGOwBUMEkiDWZ1bGxuYW1lBjsA\nVEkiEUFkbWluLCBBZG1pbgY7AFRJIgplbWFpbAY7AFRJIhxhbnl0aGluZ0Bt\nYWlsaW5hdG9yLmNvbQY7AFRJIg5wYXJlbnRfaWQGOwBUaQZJIhdwcml2YXRl\nX2J5X2RlZmF1bHQGOwBUaQBJIhdtcnVfZGlyZWN0b3J5X3BhdGgGOwBUMEki\nFGVtYWlsX29uX3JldmlldwY7AFRpBkkiGGVtYWlsX29uX3N1Ym1pc3Npb24G\nOwBUaQZJIh5lbWFpbF9vbl9yZXZpZXdfb2ZfcmV2aWV3BjsAVGkGSSIQaXNf\nbmV3X3VzZXIGOwBUaQBJIh5tYXN0ZXJfcGVybWlzc2lvbl9ncmFudGVkBjsA\nVGkASSILaGFuZGxlBjsAVEkiAAY7AFRJIhhsZWFkZXJib2FyZF9wcml2YWN5\nBjsAVGkASSIYZGlnaXRhbF9jZXJ0aWZpY2F0ZQY7AFQwSSIWcGVyc2lzdGVu\nY2VfdG9rZW4GOwBUSSIBgGJmNDYwMDJlNjhmZDkzMzBlMGJlNjFiYzQ2YWFi\nNmY4ZmNiZGExZTlhNzAyYWI4YTc2MDIzMDk3YTdjY2U2NzkyYzI0M2QwMDZl\nYTUwMmQ3MjIwOTlmMmU3NTUyZDExNGJlODI3ZTllMjQ2Y2IxZjY4MWUwOWIx\nYjE3MjQ3MTBiBjsAVEkiEXRpbWV6b25lcHJlZgY7AFRJIh9FYXN0ZXJuIFRp\nbWUgKFVTICYgQ2FuYWRhKQY7AFRJIg9wdWJsaWNfa2V5BjsAVDBJIhNjb3B5\nX29mX2VtYWlscwY7AFRpADsZewA7GkY7G3sLSSIVY3J5cHRlZF9wYXNzd29y\nZAY7AFRvOxwJOx1JIhVjcnlwdGVkX3Bhc3N3b3JkBjsAVDseQAL4ATsfQALZ\nATsgSSItZDAzM2UyMmFlMzQ4YWViNTY2MGZjMjE0MGFlYzM1ODUwYzRkYTk5\nNwY7AFRJIhJwYXNzd29yZF9zYWx0BjsAVG87HAk7HUkiEnBhc3N3b3JkX3Nh\nbHQGOwBUOx4wOx9AAtcBOyAwSSIMcm9sZV9pZAY7AFRvOxwJOx1JIgxyb2xl\nX2lkBjsAVDseaQo7H0AC0gE7IGkKSSIHaWQGOwBGbzscCTsdSSIHaWQGOwBG\nOx5pBjsfQALSATsgaQZJIhF0aW1lem9uZXByZWYGOwBUbzscCTsdSSIRdGlt\nZXpvbmVwcmVmBjsAVDseQAIOAjsfQALXATsgSSIfRWFzdGVybiBUaW1lIChV\nUyAmIENhbmFkYSkGOwBUSSIJbmFtZQY7AFRvOxwJOx1JIgluYW1lBjsAVDse\nQAL2ATsfQALXATsgSSIKYWRtaW4GOwBUOyF7ADsiewY7I1U7JFsHOyNbDFsH\nOyVAAs0BWwc7JlRbBzsnbzsoEjsHbzsIBjsHbzsJCjsKfQ1JIgdpZAY7AFRA\nAtIBSSIJbmFtZQY7AFRAAtcBSSIOcGFyZW50X2lkBjsAVEAC0gFJIhBkZXNj\ncmlwdGlvbgY7AFRAAtcBSSIUZGVmYXVsdF9wYWdlX2lkBjsAVEAC0gFJIgpj\nYWNoZQY7AFRVOylbCTsqWwc7KzssWwdAAu0BbzstBjsuQHpAAu0BSSIPY3Jl\nYXRlZF9hdAY7AFRVOy9bCTsqWwBbAG87MAg7DDA7DTA7DjBJIg91cGRhdGVk\nX2F0BjsAVFU7L1sJOypbAFsAQAJEAm87Fwg7DDA7DTA7DjA7GHsNSSIHaWQG\nOwBUaQpJIgluYW1lBjsAVEkiGFN1cGVyLUFkbWluaXN0cmF0b3IGOwBUSSIO\ncGFyZW50X2lkBjsAVGkJSSIQZGVzY3JpcHRpb24GOwBUSSIABjsAVEkiFGRl\nZmF1bHRfcGFnZV9pZAY7AFQwSSIKY2FjaGUGOwBUSSIC3DgtLS0KOmNyZWRl\nbnRpYWxzOiAhcnVieS9vYmplY3Q6Q3JlZGVudGlhbHMKICByb2xlX2lkOiA1\nCiAgdXBkYXRlZF9hdDogMjAxNS0xMi0wNCAxOTo1Nzo0NC4wMDAwMDAwMDAg\nWgogIHJvbGVfaWRzOgogIC0gNQogIC0gNAogIC0gMwogIC0gMgogIC0gMQog\nIHBlcm1pc3Npb25faWRzOgogIC0gNQogIC0gNQogIC0gNQogIC0gNQogIC0g\nNQogIC0gNQogIC0gNQogIC0gNQogIC0gNQogIC0gMQogIC0gMQogIC0gMQog\nIC0gNwogIC0gNwogIC0gNwogIC0gNAogIC0gNAogIC0gNAogIC0gNgogIC0g\nNgogIC0gNgogIC0gMwogIC0gMwogIC0gMwogIC0gMgogIC0gMgogIC0gMgog\nIGFjdGlvbnM6CiAgICBjb250ZW50X3BhZ2VzOgogICAgICB2aWV3X2RlZmF1\nbHQ6IHRydWUKICAgICAgdmlldzogdHJ1ZQogICAgICBsaXN0OiB0cnVlCiAg\nICBjb250cm9sbGVyX2FjdGlvbnM6CiAgICAgIGxpc3Q6IHRydWUKICAgIGF1\ndGg6CiAgICAgIGxvZ2luOiB0cnVlCiAgICAgIGxvZ291dDogdHJ1ZQogICAg\nICBsb2dpbl9mYWlsZWQ6IHRydWUKICAgIG1lbnVfaXRlbXM6CiAgICAgIGxp\nbms6IHRydWUKICAgICAgbGlzdDogdHJ1ZQogICAgcGVybWlzc2lvbnM6CiAg\nICAgIGxpc3Q6IHRydWUKICAgIHJvbGVzOgogICAgICBsaXN0OiB0cnVlCiAg\nICBzaXRlX2NvbnRyb2xsZXJzOgogICAgICBsaXN0OiB0cnVlCiAgICBzeXN0\nZW1fc2V0dGluZ3M6CiAgICAgIGxpc3Q6IHRydWUKICAgIHVzZXJzOgogICAg\nICBsaXN0OiB0cnVlCiAgICAgIGtleXM6IHRydWUKICAgIGFkbWluOgogICAg\nICBsaXN0X2luc3RydWN0b3JzOiB0cnVlCiAgICAgIGxpc3RfYWRtaW5pc3Ry\nYXRvcnM6IHRydWUKICAgICAgbGlzdF9zdXBlcl9hZG1pbmlzdHJhdG9yczog\ndHJ1ZQogICAgY291cnNlOgogICAgICBsaXN0X2ZvbGRlcnM6IHRydWUKICAg\nIGFzc2lnbm1lbnQ6CiAgICAgIGxpc3Q6IHRydWUKICAgIHF1ZXN0aW9ubmFp\ncmU6CiAgICAgIGxpc3Q6IHRydWUKICAgICAgY3JlYXRlX3F1ZXN0aW9ubmFp\ncmU6IHRydWUKICAgICAgZWRpdF9xdWVzdGlvbm5haXJlOiB0cnVlCiAgICAg\nIGNvcHlfcXVlc3Rpb25uYWlyZTogdHJ1ZQogICAgICBzYXZlX3F1ZXN0aW9u\nbmFpcmU6IHRydWUKICAgIHBhcnRpY2lwYW50czoKICAgICAgYWRkX3N0dWRl\nbnQ6IHRydWUKICAgICAgZWRpdF90ZWFtX21lbWJlcnM6IHRydWUKICAgICAg\nbGlzdF9zdHVkZW50czogdHJ1ZQogICAgICBsaXN0X2NvdXJzZXM6IHRydWUK\nICAgICAgbGlzdF9hc3NpZ25tZW50czogdHJ1ZQogICAgICBjaGFuZ2VfaGFu\nZGxlOiB0cnVlCiAgICBpbnN0aXR1dGlvbjoKICAgICAgbGlzdDogdHJ1ZQog\nICAgc3R1ZGVudF90YXNrOgogICAgICBsaXN0OiB0cnVlCiAgICBwcm9maWxl\nOgogICAgICBlZGl0OiB0cnVlCiAgICBzdXJ2ZXlfcmVzcG9uc2U6CiAgICAg\nIGNyZWF0ZTogdHJ1ZQogICAgICBzdWJtaXQ6IHRydWUKICAgIHRlYW06CiAg\nICAgIGxpc3Q6IHRydWUKICAgICAgbGlzdF9hc3NpZ25tZW50czogdHJ1ZQog\nICAgdGVhbXNfdXNlcnM6CiAgICAgIGxpc3Q6IHRydWUKICAgIGltcGVyc29u\nYXRlOgogICAgICBzdGFydDogdHJ1ZQogICAgICBpbXBlcnNvbmF0ZTogdHJ1\nZQogICAgcmV2aWV3X21hcHBpbmc6CiAgICAgIGxpc3Q6IHRydWUKICAgICAg\nYWRkX2R5bmFtaWNfcmV2aWV3ZXI6IHRydWUKICAgICAgcmVsZWFzZV9yZXNl\ncnZhdGlvbjogdHJ1ZQogICAgICBzaG93X2F2YWlsYWJsZV9zdWJtaXNzaW9u\nczogdHJ1ZQogICAgICBhc3NpZ25fcmV2aWV3ZXJfZHluYW1pY2FsbHk6IHRy\ndWUKICAgICAgYXNzaWduX21ldGFyZXZpZXdlcl9keW5hbWljYWxseTogdHJ1\nZQogICAgZ3JhZGVzOgogICAgICB2aWV3X215X3Njb3JlczogdHJ1ZQogICAg\nc3VydmV5X2RlcGxveW1lbnQ6CiAgICAgIGxpc3Q6IHRydWUKICAgIHN0YXRp\nc3RpY3M6CiAgICAgIGxpc3Rfc3VydmV5czogdHJ1ZQogICAgdHJlZV9kaXNw\nbGF5OgogICAgICBsaXN0OiB0cnVlCiAgICAgIGRyaWxsOiB0cnVlCiAgICAg\nIGdvdG9fcXVlc3Rpb25uYWlyZXM6IHRydWUKICAgICAgZ290b19hdXRob3Jf\nZmVlZGJhY2tzOiB0cnVlCiAgICAgIGdvdG9fcmV2aWV3X3J1YnJpY3M6IHRy\ndWUKICAgICAgZ290b19nbG9iYWxfc3VydmV5OiB0cnVlCiAgICAgIGdvdG9f\nc3VydmV5czogdHJ1ZQogICAgICBnb3RvX2NvdXJzZV9ldmFsdWF0aW9uczog\ndHJ1ZQogICAgICBnb3RvX2NvdXJzZXM6IHRydWUKICAgICAgZ290b19hc3Np\nZ25tZW50czogdHJ1ZQogICAgICBnb3RvX3RlYW1tYXRlX3Jldmlld3M6IHRy\ndWUKICAgICAgZ290b19tZXRhcmV2aWV3X3J1YnJpY3M6IHRydWUKICAgICAg\nZ290b190ZWFtbWF0ZXJldmlld19ydWJyaWNzOiB0cnVlCiAgICBzaWduX3Vw\nX3NoZWV0OgogICAgICBsaXN0OiB0cnVlCiAgICAgIHNpZ251cDogdHJ1ZQog\nICAgICBkZWxldGVfc2lnbnVwOiB0cnVlCiAgICBzdWdnZXN0aW9uOgogICAg\nICBjcmVhdGU6IHRydWUKICAgICAgbmV3OiB0cnVlCiAgICBsZWFkZXJib2Fy\nZDoKICAgICAgaW5kZXg6IHRydWUKICAgIGFkdmljZToKICAgICAgZWRpdF9h\nZHZpY2U6IHRydWUKICAgICAgc2F2ZV9hZHZpY2U6IHRydWUKICAgIGFkdmVy\ndGlzZV9mb3JfcGFydG5lcjoKICAgICAgYWRkX2FkdmVydGlzZV9jb21tZW50\nOiB0cnVlCiAgICAgIGVkaXQ6IHRydWUKICAgICAgbmV3OiB0cnVlCiAgICAg\nIHJlbW92ZTogdHJ1ZQogICAgICB1cGRhdGU6IHRydWUKICAgIGpvaW5fdGVh\nbV9yZXF1ZXN0czoKICAgICAgY3JlYXRlOiB0cnVlCiAgICAgIGRlY2xpbmU6\nIHRydWUKICAgICAgZGVzdHJveTogdHJ1ZQogICAgICBlZGl0OiB0cnVlCiAg\nICAgIGluZGV4OiB0cnVlCiAgICAgIG5ldzogdHJ1ZQogICAgICBzaG93OiB0\ncnVlCiAgICAgIHVwZGF0ZTogdHJ1ZQogIGNvbnRyb2xsZXJzOgogICAgY29u\ndGVudF9wYWdlczogdHJ1ZQogICAgY29udHJvbGxlcl9hY3Rpb25zOiB0cnVl\nCiAgICBhdXRoOiB0cnVlCiAgICBtYXJrdXBfc3R5bGVzOiB0cnVlCiAgICBt\nZW51X2l0ZW1zOiB0cnVlCiAgICBwZXJtaXNzaW9uczogdHJ1ZQogICAgcm9s\nZXM6IHRydWUKICAgIHNpdGVfY29udHJvbGxlcnM6IHRydWUKICAgIHN5c3Rl\nbV9zZXR0aW5nczogdHJ1ZQogICAgdXNlcnM6IHRydWUKICAgIHJvbGVzX3Bl\ncm1pc3Npb25zOiB0cnVlCiAgICBhZG1pbjogdHJ1ZQogICAgY291cnNlOiB0\ncnVlCiAgICBhc3NpZ25tZW50OiB0cnVlCiAgICBxdWVzdGlvbm5haXJlOiB0\ncnVlCiAgICBhZHZpY2U6IHRydWUKICAgIHBhcnRpY2lwYW50czogdHJ1ZQog\nICAgcmVwb3J0czogdHJ1ZQogICAgaW5zdGl0dXRpb246IHRydWUKICAgIHN0\ndWRlbnRfdGFzazogdHJ1ZQogICAgcHJvZmlsZTogdHJ1ZQogICAgc3VydmV5\nX3Jlc3BvbnNlOiB0cnVlCiAgICB0ZWFtOiB0cnVlCiAgICB0ZWFtc191c2Vy\nczogdHJ1ZQogICAgaW1wZXJzb25hdGU6IHRydWUKICAgIGltcG9ydF9maWxl\nOiB0cnVlCiAgICByZXZpZXdfbWFwcGluZzogdHJ1ZQogICAgZ3JhZGVzOiB0\ncnVlCiAgICBjb3Vyc2VfZXZhbHVhdGlvbjogdHJ1ZQogICAgcGFydGljaXBh\nbnRfY2hvaWNlczogdHJ1ZQogICAgc3VydmV5X2RlcGxveW1lbnQ6IHRydWUK\nICAgIHN0YXRpc3RpY3M6IHRydWUKICAgIHRyZWVfZGlzcGxheTogdHJ1ZQog\nICAgc3R1ZGVudF90ZWFtOiB0cnVlCiAgICBpbnZpdGF0aW9uOiB0cnVlCiAg\nICBzdXJ2ZXk6IHRydWUKICAgIHBhc3N3b3JkX3JldHJpZXZhbDogdHJ1ZQog\nICAgc3VibWl0dGVkX2NvbnRlbnQ6IHRydWUKICAgIGV1bGE6IHRydWUKICAg\nIHN0dWRlbnRfcmV2aWV3OiB0cnVlCiAgICBwdWJsaXNoaW5nOiB0cnVlCiAg\nICBleHBvcnRfZmlsZTogdHJ1ZQogICAgcmVzcG9uc2U6IHRydWUKICAgIHNp\nZ25fdXBfc2hlZXQ6IHRydWUKICAgIHN1Z2dlc3Rpb246IHRydWUKICAgIGxl\nYWRlcmJvYXJkOiB0cnVlCiAgICBkZWxldGVfb2JqZWN0OiB0cnVlCiAgICBh\nZHZlcnRpc2VfZm9yX3BhcnRuZXI6IHRydWUKICAgIGpvaW5fdGVhbV9yZXF1\nZXN0czogdHJ1ZQogIHBhZ2VzOgogICAgaG9tZTogdHJ1ZQogICAgZXhwaXJl\nZDogdHJ1ZQogICAgbm90Zm91bmQ6IHRydWUKICAgIGRlbmllZDogdHJ1ZQog\nICAgY29udGFjdF91czogdHJ1ZQogICAgc2l0ZV9hZG1pbjogdHJ1ZQogICAg\nYWRtaW46IHRydWUKICAgIGNyZWRpdHM6IHRydWUKOm1lbnU6ICFydWJ5L29i\namVjdDpNZW51CiAgcm9vdDogJjM1ICFydWJ5L29iamVjdDpNZW51OjpOb2Rl\nCiAgICBwYXJlbnQ6IAogICAgY2hpbGRyZW46CiAgICAtIDEKICAgIC0gMgog\nICAgLSAzCiAgICAtIDQKICAgIC0gNQogICAgLSA2CiAgICAtIDcKICBieV9p\nZDoKICAgIDE6ICYxICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBh\ncmVudDogCiAgICAgIGNoaWxkcmVuOgogICAgICAtIDgKICAgICAgcGFyZW50\nX2lkOiAKICAgICAgbmFtZTogaG9tZQogICAgICBpZDogMQogICAgICBsYWJl\nbDogSG9tZQogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IAogICAgICBjb250\ncm9sbGVyX2FjdGlvbl9pZDogCiAgICAgIGNvbnRlbnRfcGFnZV9pZDogMQog\nICAgICB1cmw6ICIvaG9tZSIKICAgIDI6ICYyICFydWJ5L29iamVjdDpNZW51\nOjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIGNoaWxkcmVuOgogICAgICAt\nIDEwCiAgICAgIC0gMTEKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTog\nYWRtaW4KICAgICAgaWQ6IDIKICAgICAgbGFiZWw6IEFkbWluaXN0cmF0aW9u\nCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogCiAgICAgIGNvbnRyb2xsZXJf\nYWN0aW9uX2lkOiAKICAgICAgY29udGVudF9wYWdlX2lkOiA2CiAgICAgIHVy\nbDogIi9zaXRlX2FkbWluIgogICAgMzogJjMgIXJ1Ynkvb2JqZWN0Ok1lbnU6\nOk5vZGUKICAgICAgcGFyZW50OiAKICAgICAgY2hpbGRyZW46CiAgICAgIC0g\nMTkKICAgICAgLSAyMAogICAgICAtIDIxCiAgICAgIC0gMjIKICAgICAgLSAy\nMwogICAgICBwYXJlbnRfaWQ6IAogICAgICBuYW1lOiBtYW5hZ2UgaW5zdHJ1\nY3RvciBjb250ZW50CiAgICAgIGlkOiAzCiAgICAgIGxhYmVsOiBNYW5hZ2Uu\nLi4KICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAzMwogICAgICBjb250cm9s\nbGVyX2FjdGlvbl9pZDogNTIKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAg\nICAgdXJsOiAiL3RyZWVfZGlzcGxheS9kcmlsbCIKICAgIDQ6ICY0ICFydWJ5\nL29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIGNoaWxk\ncmVuOgogICAgICAtIDE4CiAgICAgIHBhcmVudF9pZDogCiAgICAgIG5hbWU6\nIFN1cnZleSBEZXBsb3ltZW50cwogICAgICBpZDogNAogICAgICBsYWJlbDog\nU3VydmV5IERlcGxveW1lbnRzCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDog\nMzEKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IDQ5CiAgICAgIGNvbnRl\nbnRfcGFnZV9pZDogCiAgICAgIHVybDogIi9zdXJ2ZXlfZGVwbG95bWVudC9s\naXN0IgogICAgNTogJjUgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAg\ncGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAKICAgICAgbmFtZTogc3R1ZGVu\ndF90YXNrCiAgICAgIGlkOiA1CiAgICAgIGxhYmVsOiBBc3NpZ25tZW50cwog\nICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDIwCiAgICAgIGNvbnRyb2xsZXJf\nYWN0aW9uX2lkOiAzMwogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1\ncmw6ICIvc3R1ZGVudF90YXNrL2xpc3QiCiAgICA2OiAmNiAhcnVieS9vYmpl\nY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6\nIAogICAgICBuYW1lOiBwcm9maWxlCiAgICAgIGlkOiA2CiAgICAgIGxhYmVs\nOiBQcm9maWxlCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMjEKICAgICAg\nY29udHJvbGxlcl9hY3Rpb25faWQ6IDM0CiAgICAgIGNvbnRlbnRfcGFnZV9p\nZDogCiAgICAgIHVybDogIi9wcm9maWxlL2VkaXQiCiAgICA3OiAmNyAhcnVi\neS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBjaGls\nZHJlbjoKICAgICAgLSA5CiAgICAgIHBhcmVudF9pZDogCiAgICAgIG5hbWU6\nIGNvbnRhY3RfdXMKICAgICAgaWQ6IDcKICAgICAgbGFiZWw6IENvbnRhY3Qg\nVXMKICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAKICAgICAgY29udHJvbGxl\ncl9hY3Rpb25faWQ6IAogICAgICBjb250ZW50X3BhZ2VfaWQ6IDUKICAgICAg\ndXJsOiAiL2NvbnRhY3RfdXMiCiAgICA4OiAmOCAhcnVieS9vYmplY3Q6TWVu\ndTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IDEKICAg\nICAgbmFtZTogbGVhZGVyYm9hcmQKICAgICAgaWQ6IDgKICAgICAgbGFiZWw6\nIExlYWRlcmJvYXJkCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogNDYKICAg\nICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IDY5CiAgICAgIGNvbnRlbnRfcGFn\nZV9pZDogCiAgICAgIHVybDogIi9sZWFkZXJib2FyZC9pbmRleCIKICAgIDEw\nOiAmOSAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAog\nICAgICBjaGlsZHJlbjoKICAgICAgLSAxMgogICAgICAtIDEzCiAgICAgIC0g\nMTQKICAgICAgLSAxNQogICAgICAtIDE2CiAgICAgIC0gMTcKICAgICAgcGFy\nZW50X2lkOiAyCiAgICAgIG5hbWU6IHNldHVwCiAgICAgIGlkOiAxMAogICAg\nICBsYWJlbDogU2V0dXAKICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAKICAg\nICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IAogICAgICBjb250ZW50X3BhZ2Vf\naWQ6IDYKICAgICAgdXJsOiAiL3NpdGVfYWRtaW4iCiAgICAxMTogJjEwICFy\ndWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIGNo\naWxkcmVuOgogICAgICAtIDMxCiAgICAgIC0gMzIKICAgICAgLSAzMwogICAg\nICAtIDM0CiAgICAgIHBhcmVudF9pZDogMgogICAgICBuYW1lOiBzaG93CiAg\nICAgIGlkOiAxMQogICAgICBsYWJlbDogU2hvdy4uLgogICAgICBzaXRlX2Nv\nbnRyb2xsZXJfaWQ6IDEwCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAx\nNAogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvdXNlcnMv\nbGlzdCIKICAgIDE5OiAmMTEgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAg\nICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAzCiAgICAgIG5hbWU6IG1h\nbmFnZS91c2VycwogICAgICBpZDogMTkKICAgICAgbGFiZWw6IFVzZXJzCiAg\nICAgIHNpdGVfY29udHJvbGxlcl9pZDogMTAKICAgICAgY29udHJvbGxlcl9h\nY3Rpb25faWQ6IDE0CiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAgIHVy\nbDogIi91c2Vycy9saXN0IgogICAgMjA6ICYxMiAhcnVieS9vYmplY3Q6TWVu\ndTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBjaGlsZHJlbjoKICAgICAg\nLSAyNAogICAgICAtIDI1CiAgICAgIC0gMjYKICAgICAgLSAyNwogICAgICAt\nIDI4CiAgICAgIC0gMjkKICAgICAgLSAzMAogICAgICBwYXJlbnRfaWQ6IDMK\nICAgICAgbmFtZTogbWFuYWdlL3F1ZXN0aW9ubmFpcmVzCiAgICAgIGlkOiAy\nMAogICAgICBsYWJlbDogUXVlc3Rpb25uYWlyZXMKICAgICAgc2l0ZV9jb250\ncm9sbGVyX2lkOiAzMwogICAgICBjb250cm9sbGVyX2FjdGlvbl9pZDogNTMK\nICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAiL3RyZWVfZGlz\ncGxheS9nb3RvX3F1ZXN0aW9ubmFpcmVzIgogICAgMjE6ICYxMyAhcnVieS9v\nYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRf\naWQ6IDMKICAgICAgbmFtZTogbWFuYWdlL2NvdXJzZXMKICAgICAgaWQ6IDIx\nCiAgICAgIGxhYmVsOiBDb3Vyc2VzCiAgICAgIHNpdGVfY29udHJvbGxlcl9p\nZDogMzMKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IDU5CiAgICAgIGNv\nbnRlbnRfcGFnZV9pZDogCiAgICAgIHVybDogIi90cmVlX2Rpc3BsYXkvZ290\nb19jb3Vyc2VzIgogICAgMjI6ICYxNCAhcnVieS9vYmplY3Q6TWVudTo6Tm9k\nZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IDMKICAgICAgbmFt\nZTogbWFuYWdlL2Fzc2lnbm1lbnRzCiAgICAgIGlkOiAyMgogICAgICBsYWJl\nbDogQXNzaWdubWVudHMKICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiAzMwog\nICAgICBjb250cm9sbGVyX2FjdGlvbl9pZDogNjAKICAgICAgY29udGVudF9w\nYWdlX2lkOiAKICAgICAgdXJsOiAiL3RyZWVfZGlzcGxheS9nb3RvX2Fzc2ln\nbm1lbnRzIgogICAgMjM6ICYxNSAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQog\nICAgICBwYXJlbnQ6IAogICAgICBwYXJlbnRfaWQ6IDMKICAgICAgbmFtZTog\naW1wZXJzb25hdGUKICAgICAgaWQ6IDIzCiAgICAgIGxhYmVsOiBJbXBlcnNv\nbmF0ZSBVc2VyCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMjUKICAgICAg\nY29udHJvbGxlcl9hY3Rpb25faWQ6IDQwCiAgICAgIGNvbnRlbnRfcGFnZV9p\nZDogCiAgICAgIHVybDogIi9pbXBlcnNvbmF0ZS9zdGFydCIKICAgIDE4OiAm\nMTYgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAg\nICAgcGFyZW50X2lkOiA0CiAgICAgIG5hbWU6IFN0YXRpc3RpY2FsIFRlc3QK\nICAgICAgaWQ6IDE4CiAgICAgIGxhYmVsOiBTdGF0aXN0aWNhbCBUZXN0CiAg\nICAgIHNpdGVfY29udHJvbGxlcl9pZDogMzIKICAgICAgY29udHJvbGxlcl9h\nY3Rpb25faWQ6IDUwCiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAgIHVy\nbDogIi9zdGF0aXN0aWNzL2xpc3Rfc3VydmV5cyIKICAgIDk6ICYxNyAhcnVi\neS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJl\nbnRfaWQ6IDcKICAgICAgbmFtZTogY3JlZGl0cwogICAgICBpZDogOQogICAg\nICBsYWJlbDogQ3JlZGl0cyAmYW1wOyBMaWNlbmNlCiAgICAgIHNpdGVfY29u\ndHJvbGxlcl9pZDogCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAKICAg\nICAgY29udGVudF9wYWdlX2lkOiA4CiAgICAgIHVybDogIi9jcmVkaXRzIgog\nICAgMTI6ICYxOCAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJl\nbnQ6IAogICAgICBwYXJlbnRfaWQ6IDEwCiAgICAgIG5hbWU6IHNldHVwL3Jv\nbGVzCiAgICAgIGlkOiAxMgogICAgICBsYWJlbDogUm9sZXMKICAgICAgc2l0\nZV9jb250cm9sbGVyX2lkOiA3CiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lk\nOiAxMQogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvcm9s\nZXMvbGlzdCIKICAgIDEzOiAmMTkgIXJ1Ynkvb2JqZWN0Ok1lbnU6Ok5vZGUK\nICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAxMAogICAgICBuYW1l\nOiBzZXR1cC9wZXJtaXNzaW9ucwogICAgICBpZDogMTMKICAgICAgbGFiZWw6\nIFBlcm1pc3Npb25zCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogNgogICAg\nICBjb250cm9sbGVyX2FjdGlvbl9pZDogMTAKICAgICAgY29udGVudF9wYWdl\nX2lkOiAKICAgICAgdXJsOiAiL3Blcm1pc3Npb25zL2xpc3QiCiAgICAxNDog\nJjIwICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAg\nICAgIHBhcmVudF9pZDogMTAKICAgICAgbmFtZTogc2V0dXAvY29udHJvbGxl\ncnMKICAgICAgaWQ6IDE0CiAgICAgIGxhYmVsOiBDb250cm9sbGVycyAvIEFj\ndGlvbnMKICAgICAgc2l0ZV9jb250cm9sbGVyX2lkOiA4CiAgICAgIGNvbnRy\nb2xsZXJfYWN0aW9uX2lkOiAxMgogICAgICBjb250ZW50X3BhZ2VfaWQ6IAog\nICAgICB1cmw6ICIvc2l0ZV9jb250cm9sbGVycy9saXN0IgogICAgMTU6ICYy\nMSAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAg\nICBwYXJlbnRfaWQ6IDEwCiAgICAgIG5hbWU6IHNldHVwL3BhZ2VzCiAgICAg\nIGlkOiAxNQogICAgICBsYWJlbDogQ29udGVudCBQYWdlcwogICAgICBzaXRl\nX2NvbnRyb2xsZXJfaWQ6IDEKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6\nIDMKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAiL2NvbnRl\nbnRfcGFnZXMvbGlzdCIKICAgIDE2OiAmMjIgIXJ1Ynkvb2JqZWN0Ok1lbnU6\nOk5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAxMAogICAg\nICBuYW1lOiBzZXR1cC9tZW51cwogICAgICBpZDogMTYKICAgICAgbGFiZWw6\nIE1lbnUgRWRpdG9yCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogNQogICAg\nICBjb250cm9sbGVyX2FjdGlvbl9pZDogOQogICAgICBjb250ZW50X3BhZ2Vf\naWQ6IAogICAgICB1cmw6ICIvbWVudV9pdGVtcy9saXN0IgogICAgMTc6ICYy\nMyAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAg\nICBwYXJlbnRfaWQ6IDEwCiAgICAgIG5hbWU6IHNldHVwL3N5c3RlbV9zZXR0\naW5ncwogICAgICBpZDogMTcKICAgICAgbGFiZWw6IFN5c3RlbSBTZXR0aW5n\ncwogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDkKICAgICAgY29udHJvbGxl\ncl9hY3Rpb25faWQ6IDEzCiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAg\nIHVybDogIi9zeXN0ZW1fc2V0dGluZ3MvbGlzdCIKICAgIDMxOiAmMjQgIXJ1\nYnkvb2JqZWN0Ok1lbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFy\nZW50X2lkOiAxMQogICAgICBuYW1lOiBzaG93L2luc3RpdHV0aW9ucwogICAg\nICBpZDogMzEKICAgICAgbGFiZWw6IEluc3RpdHV0aW9ucwogICAgICBzaXRl\nX2NvbnRyb2xsZXJfaWQ6IDE5CiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lk\nOiAzMgogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvaW5z\ndGl0dXRpb24vbGlzdCIKICAgIDMyOiAmMjUgIXJ1Ynkvb2JqZWN0Ok1lbnU6\nOk5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAxMQogICAg\nICBuYW1lOiBzaG93L3N1cGVyLWFkbWluaXN0cmF0b3JzCiAgICAgIGlkOiAz\nMgogICAgICBsYWJlbDogU3VwZXItQWRtaW5pc3RyYXRvcnMKICAgICAgc2l0\nZV9jb250cm9sbGVyX2lkOiAxMgogICAgICBjb250cm9sbGVyX2FjdGlvbl9p\nZDogMTgKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAiL2Fk\nbWluL2xpc3Rfc3VwZXJfYWRtaW5pc3RyYXRvcnMiCiAgICAzMzogJjI2ICFy\ndWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAgIHBh\ncmVudF9pZDogMTEKICAgICAgbmFtZTogc2hvdy9hZG1pbmlzdHJhdG9ycwog\nICAgICBpZDogMzMKICAgICAgbGFiZWw6IEFkbWluaXN0cmF0b3JzCiAgICAg\nIHNpdGVfY29udHJvbGxlcl9pZDogMTIKICAgICAgY29udHJvbGxlcl9hY3Rp\nb25faWQ6IDE3CiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAgIHVybDog\nIi9hZG1pbi9saXN0X2FkbWluaXN0cmF0b3JzIgogICAgMzQ6ICYyNyAhcnVi\neS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJl\nbnRfaWQ6IDExCiAgICAgIG5hbWU6IHNob3cvaW5zdHJ1Y3RvcnMKICAgICAg\naWQ6IDM0CiAgICAgIGxhYmVsOiBJbnN0cnVjdG9ycwogICAgICBzaXRlX2Nv\nbnRyb2xsZXJfaWQ6IDEyCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiAx\nNgogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvYWRtaW4v\nbGlzdF9pbnN0cnVjdG9ycyIKICAgIDI0OiAmMjggIXJ1Ynkvb2JqZWN0Ok1l\nbnU6Ok5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAyMAog\nICAgICBuYW1lOiBtYW5hZ2UvcXVlc3Rpb25uYWlyZXMvcmV2aWV3IHJ1YnJp\nY3MKICAgICAgaWQ6IDI0CiAgICAgIGxhYmVsOiBSZXZpZXcgcnVicmljcwog\nICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDMzCiAgICAgIGNvbnRyb2xsZXJf\nYWN0aW9uX2lkOiA1NQogICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1\ncmw6ICIvdHJlZV9kaXNwbGF5L2dvdG9fcmV2aWV3X3J1YnJpY3MiCiAgICAy\nNTogJjI5ICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDog\nCiAgICAgIHBhcmVudF9pZDogMjAKICAgICAgbmFtZTogbWFuYWdlL3F1ZXN0\naW9ubmFpcmVzL21ldGFyZXZpZXcgcnVicmljcwogICAgICBpZDogMjUKICAg\nICAgbGFiZWw6IE1ldGFyZXZpZXcgcnVicmljcwogICAgICBzaXRlX2NvbnRy\nb2xsZXJfaWQ6IDMzCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiA2Mgog\nICAgICBjb250ZW50X3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvdHJlZV9kaXNw\nbGF5L2dvdG9fbWV0YXJldmlld19ydWJyaWNzIgogICAgMjY6ICYzMCAhcnVi\neS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBwYXJl\nbnRfaWQ6IDIwCiAgICAgIG5hbWU6IG1hbmFnZS9xdWVzdGlvbm5haXJlcy90\nZWFtbWF0ZSByZXZpZXcgcnVicmljcwogICAgICBpZDogMjYKICAgICAgbGFi\nZWw6IFRlYW1tYXRlIHJldmlldyBydWJyaWNzCiAgICAgIHNpdGVfY29udHJv\nbGxlcl9pZDogMzMKICAgICAgY29udHJvbGxlcl9hY3Rpb25faWQ6IDYzCiAg\nICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAgIHVybDogIi90cmVlX2Rpc3Bs\nYXkvZ290b190ZWFtbWF0ZXJldmlld19ydWJyaWNzIgogICAgMjc6ICYzMSAh\ncnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAgICBw\nYXJlbnRfaWQ6IDIwCiAgICAgIG5hbWU6IG1hbmFnZS9xdWVzdGlvbm5haXJl\ncy9hdXRob3IgZmVlZGJhY2tzCiAgICAgIGlkOiAyNwogICAgICBsYWJlbDog\nQXV0aG9yIGZlZWRiYWNrcwogICAgICBzaXRlX2NvbnRyb2xsZXJfaWQ6IDMz\nCiAgICAgIGNvbnRyb2xsZXJfYWN0aW9uX2lkOiA1NAogICAgICBjb250ZW50\nX3BhZ2VfaWQ6IAogICAgICB1cmw6ICIvdHJlZV9kaXNwbGF5L2dvdG9fYXV0\naG9yX2ZlZWRiYWNrcyIKICAgIDI4OiAmMzIgIXJ1Ynkvb2JqZWN0Ok1lbnU6\nOk5vZGUKICAgICAgcGFyZW50OiAKICAgICAgcGFyZW50X2lkOiAyMAogICAg\nICBuYW1lOiBtYW5hZ2UvcXVlc3Rpb25uYWlyZXMvZ2xvYmFsIHN1cnZleQog\nICAgICBpZDogMjgKICAgICAgbGFiZWw6IEdsb2JhbCBzdXJ2ZXkKICAgICAg\nc2l0ZV9jb250cm9sbGVyX2lkOiAzMwogICAgICBjb250cm9sbGVyX2FjdGlv\nbl9pZDogNTYKICAgICAgY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAi\nL3RyZWVfZGlzcGxheS9nb3RvX2dsb2JhbF9zdXJ2ZXkiCiAgICAyOTogJjMz\nICFydWJ5L29iamVjdDpNZW51OjpOb2RlCiAgICAgIHBhcmVudDogCiAgICAg\nIHBhcmVudF9pZDogMjAKICAgICAgbmFtZTogbWFuYWdlL3F1ZXN0aW9ubmFp\ncmVzL3N1cnZleXMKICAgICAgaWQ6IDI5CiAgICAgIGxhYmVsOiBTdXJ2ZXlz\nCiAgICAgIHNpdGVfY29udHJvbGxlcl9pZDogMzMKICAgICAgY29udHJvbGxl\ncl9hY3Rpb25faWQ6IDU3CiAgICAgIGNvbnRlbnRfcGFnZV9pZDogCiAgICAg\nIHVybDogIi90cmVlX2Rpc3BsYXkvZ290b19zdXJ2ZXlzIgogICAgMzA6ICYz\nNCAhcnVieS9vYmplY3Q6TWVudTo6Tm9kZQogICAgICBwYXJlbnQ6IAogICAg\nICBwYXJlbnRfaWQ6IDIwCiAgICAgIG5hbWU6IG1hbmFnZS9xdWVzdGlvbm5h\naXJlcy9jb3Vyc2UgZXZhbHVhdGlvbnMKICAgICAgaWQ6IDMwCiAgICAgIGxh\nYmVsOiBDb3Vyc2UgZXZhbHVhdGlvbnMKICAgICAgc2l0ZV9jb250cm9sbGVy\nX2lkOiAzMwogICAgICBjb250cm9sbGVyX2FjdGlvbl9pZDogNTcKICAgICAg\nY29udGVudF9wYWdlX2lkOiAKICAgICAgdXJsOiAiL3RyZWVfZGlzcGxheS9n\nb3RvX3N1cnZleXMiCiAgYnlfbmFtZToKICAgIGhvbWU6ICoxCiAgICBhZG1p\nbjogKjIKICAgIG1hbmFnZSBpbnN0cnVjdG9yIGNvbnRlbnQ6ICozCiAgICBT\ndXJ2ZXkgRGVwbG95bWVudHM6ICo0CiAgICBzdHVkZW50X3Rhc2s6ICo1CiAg\nICBwcm9maWxlOiAqNgogICAgY29udGFjdF91czogKjcKICAgIGxlYWRlcmJv\nYXJkOiAqOAogICAgc2V0dXA6ICo5CiAgICBzaG93OiAqMTAKICAgIG1hbmFn\nZS91c2VyczogKjExCiAgICBtYW5hZ2UvcXVlc3Rpb25uYWlyZXM6ICoxMgog\nICAgbWFuYWdlL2NvdXJzZXM6ICoxMwogICAgbWFuYWdlL2Fzc2lnbm1lbnRz\nOiAqMTQKICAgIGltcGVyc29uYXRlOiAqMTUKICAgIFN0YXRpc3RpY2FsIFRl\nc3Q6ICoxNgogICAgY3JlZGl0czogKjE3CiAgICBzZXR1cC9yb2xlczogKjE4\nCiAgICBzZXR1cC9wZXJtaXNzaW9uczogKjE5CiAgICBzZXR1cC9jb250cm9s\nbGVyczogKjIwCiAgICBzZXR1cC9wYWdlczogKjIxCiAgICBzZXR1cC9tZW51\nczogKjIyCiAgICBzZXR1cC9zeXN0ZW1fc2V0dGluZ3M6ICoyMwogICAgc2hv\ndy9pbnN0aXR1dGlvbnM6ICoyNAogICAgc2hvdy9zdXBlci1hZG1pbmlzdHJh\ndG9yczogKjI1CiAgICBzaG93L2FkbWluaXN0cmF0b3JzOiAqMjYKICAgIHNo\nb3cvaW5zdHJ1Y3RvcnM6ICoyNwogICAgbWFuYWdlL3F1ZXN0aW9ubmFpcmVz\nL3JldmlldyBydWJyaWNzOiAqMjgKICAgIG1hbmFnZS9xdWVzdGlvbm5haXJl\ncy9tZXRhcmV2aWV3IHJ1YnJpY3M6ICoyOQogICAgbWFuYWdlL3F1ZXN0aW9u\nbmFpcmVzL3RlYW1tYXRlIHJldmlldyBydWJyaWNzOiAqMzAKICAgIG1hbmFn\nZS9xdWVzdGlvbm5haXJlcy9hdXRob3IgZmVlZGJhY2tzOiAqMzEKICAgIG1h\nbmFnZS9xdWVzdGlvbm5haXJlcy9nbG9iYWwgc3VydmV5OiAqMzIKICAgIG1h\nbmFnZS9xdWVzdGlvbm5haXJlcy9zdXJ2ZXlzOiAqMzMKICAgIG1hbmFnZS9x\ndWVzdGlvbm5haXJlcy9jb3Vyc2UgZXZhbHVhdGlvbnM6ICozNAogIHNlbGVj\ndGVkOgogICAgMTogKjEKICB2ZWN0b3I6CiAgLSAqMzUKICAtICoxCiAgY3J1\nbWJzOgogIC0gMQoGOwBUSSIPY3JlYXRlZF9hdAY7AFRJdTsxDZPsHMAAAADg\nBjsySSIIVVRDBjsARkkiD3VwZGF0ZWRfYXQGOwBUSXU7MQ2T7BzAAADA5gY7\nMkkiCFVUQwY7AEY7GXsAOxpGOxt7BkkiCW5hbWUGOwBUbzscCTsdSSIJbmFt\nZQY7AFQ7HkACTgI7H0AC1wE7IEkiGFN1cGVyLUFkbWluaXN0cmF0b3IGOwBU\nOyF7ADsiewA7M0Y7NEY7NUY7NjA7N0Y7ODA7OXsAOzowOztbBkY7PDBbBzs9\nSSIGNQY7AEZbBzs+RlsHOz9GWwc7QG87QRI7QkABoDtDbztECzsdSSIKcm9s\nZXMGOwBUO0VAAaA7RjA7R1sAO0gwO0kwOxh7CDtKWwA7S1sGWwdvO0wOO01U\nO04wO09JIhNhdXRvX2luY3JlbWVudAY7AFQ7HUkiB2lkBjsAVDtQQALSATtR\nSSIMaW50KDExKQY7AFQ7UkY7UzA7VDBpCjtVWwZvO1YHO1dTO1gHO1lvO0QL\nOx1AAmwCO0VAAbA7RjA7R1sAO0gwO0kwO1pJIgdpZAY7AFQ7W287XAA7XXsA\nOyYwO15vO18JO0VAAaA7YG87YQ07Ym87Ywc7V0ACawI7W1sAO2QwO2UwO2Zb\nBlM7WAc7WUACawI7WklDO2ciBioGOwBUO2hbBm87aQY7alsGQAJ3AjtrWwA7\nbDA7bVsAO25bADtvbztwCztxWwZAAn8CO3JbADsOMDtzMDt0MDt1MDt2MDt3\nMDt4MDt5MDt6MDt7MDt8WwA7M0Y7NEY7NUY7NjA7N0Y7ODA7OXsAOzowOztb\nBkY7PDA=\n','2015-12-13 18:23:51','2015-12-13 18:33:06');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sign_up_topics`
--

DROP TABLE IF EXISTS `sign_up_topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_up_topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `topic_name` text COLLATE utf8_unicode_ci NOT NULL,
  `assignment_id` int(11) NOT NULL DEFAULT '0',
  `max_choosers` int(11) NOT NULL DEFAULT '0',
  `category` text COLLATE utf8_unicode_ci,
  `topic_identifier` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `micropayment` int(11) DEFAULT '0',
  `private_to` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_sign_up_categories_sign_up_topics` (`assignment_id`) USING BTREE,
  KEY `index_sign_up_topics_on_assignment_id` (`assignment_id`) USING BTREE,
  CONSTRAINT `fk_sign_up_topics_assignments` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sign_up_topics`
--

LOCK TABLES `sign_up_topics` WRITE;
/*!40000 ALTER TABLE `sign_up_topics` DISABLE KEYS */;
INSERT INTO `sign_up_topics` VALUES (1,'Topic1',1,10,'TCAT','1',0,NULL),(2,'Topic2',1,10,'TCAT','2',0,NULL),(3,'Topic3',1,10,'TCAT','3',0,NULL);
/*!40000 ALTER TABLE `sign_up_topics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `signed_up_teams`
--

DROP TABLE IF EXISTS `signed_up_teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `signed_up_teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `topic_id` int(11) NOT NULL DEFAULT '0',
  `team_id` int(11) NOT NULL DEFAULT '0',
  `is_waitlisted` tinyint(1) NOT NULL DEFAULT '0',
  `preference_priority_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_signed_up_users_sign_up_topics` (`topic_id`) USING BTREE,
  CONSTRAINT `fk_signed_up_users_sign_up_topics` FOREIGN KEY (`topic_id`) REFERENCES `sign_up_topics` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `signed_up_teams`
--

LOCK TABLES `signed_up_teams` WRITE;
/*!40000 ALTER TABLE `signed_up_teams` DISABLE KEYS */;
INSERT INTO `signed_up_teams` VALUES (2,2,2,0,NULL),(3,3,3,0,NULL);
/*!40000 ALTER TABLE `signed_up_teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_controllers`
--

DROP TABLE IF EXISTS `site_controllers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_controllers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `permission_id` int(11) NOT NULL DEFAULT '0',
  `builtin` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_site_controller_permission_id` (`permission_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_controllers`
--

LOCK TABLES `site_controllers` WRITE;
/*!40000 ALTER TABLE `site_controllers` DISABLE KEYS */;
INSERT INTO `site_controllers` VALUES (1,'content_pages',1,1),(2,'controller_actions',1,1),(3,'auth',1,1),(4,'markup_styles',1,1),(5,'menu_items',1,1),(6,'permissions',1,1),(7,'roles',1,1),(8,'site_controllers',1,1),(9,'system_settings',1,1),(10,'users',6,1),(11,'roles_permissions',1,1),(12,'admin',1,0),(13,'course',5,0),(14,'assignment',5,0),(15,'questionnaire',5,0),(16,'advice',5,0),(17,'participants',5,0),(18,'reports',6,0),(19,'institution',4,0),(20,'student_task',6,0),(21,'profile',6,0),(22,'survey_response',3,0),(23,'team',5,0),(24,'teams_users',5,0),(25,'impersonate',5,0),(26,'import_file',5,0),(27,'review_mapping',5,0),(28,'grades',5,0),(29,'course_evaluation',6,0),(30,'participant_choices',5,0),(31,'survey_deployment',5,0),(32,'statistics',5,0),(33,'tree_display',5,0),(34,'student_team',6,0),(35,'invitation',6,0),(36,'survey',5,0),(37,'password_retrieval',3,0),(38,'submitted_content',6,0),(39,'eula',6,0),(40,'student_review',6,0),(41,'publishing',6,0),(42,'export_file',5,0),(43,'response',6,0),(44,'sign_up_sheet',5,0),(45,'suggestion',5,0),(46,'leaderboard',3,0),(47,'delete_object',5,0),(48,'advertise_for_partner',6,0),(49,'join_team_requests',6,0);
/*!40000 ALTER TABLE `site_controllers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suggestion_comments`
--

DROP TABLE IF EXISTS `suggestion_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suggestion_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `comments` text COLLATE utf8_unicode_ci,
  `commenter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vote` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suggestion_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suggestion_comments`
--

LOCK TABLES `suggestion_comments` WRITE;
/*!40000 ALTER TABLE `suggestion_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `suggestion_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suggestions`
--

DROP TABLE IF EXISTS `suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unityID` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signup_preference` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suggestions`
--

LOCK TABLES `suggestions` WRITE;
/*!40000 ALTER TABLE `suggestions` DISABLE KEYS */;
/*!40000 ALTER TABLE `suggestions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_deployments`
--

DROP TABLE IF EXISTS `survey_deployments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `survey_deployments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_evaluation_id` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `num_of_students` int(11) DEFAULT NULL,
  `last_reminder` datetime DEFAULT NULL,
  `course_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_deployments`
--

LOCK TABLES `survey_deployments` WRITE;
/*!40000 ALTER TABLE `survey_deployments` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_deployments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_participants`
--

DROP TABLE IF EXISTS `survey_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `survey_participants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `survey_deployment_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_participants`
--

LOCK TABLES `survey_participants` WRITE;
/*!40000 ALTER TABLE `survey_participants` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_responses`
--

DROP TABLE IF EXISTS `survey_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `survey_responses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `score` int(11) DEFAULT NULL,
  `comments` text COLLATE utf8_unicode_ci,
  `assignment_id` int(11) NOT NULL DEFAULT '0',
  `question_id` int(11) NOT NULL DEFAULT '0',
  `survey_id` int(11) NOT NULL DEFAULT '0',
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `survey_deployment_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_responses`
--

LOCK TABLES `survey_responses` WRITE;
/*!40000 ALTER TABLE `survey_responses` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `site_subtitle` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `footer_message` varchar(255) COLLATE utf8_unicode_ci DEFAULT '',
  `public_role_id` int(11) NOT NULL DEFAULT '0',
  `session_timeout` int(11) NOT NULL DEFAULT '0',
  `default_markup_style_id` int(11) DEFAULT '0',
  `site_default_page_id` int(11) NOT NULL DEFAULT '0',
  `not_found_page_id` int(11) NOT NULL DEFAULT '0',
  `permission_denied_page_id` int(11) NOT NULL DEFAULT '0',
  `session_expired_page_id` int(11) NOT NULL DEFAULT '0',
  `menu_depth` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_system_settings_not_found_page_id` (`not_found_page_id`) USING BTREE,
  KEY `fk_system_settings_permission_denied_page_id` (`permission_denied_page_id`) USING BTREE,
  KEY `fk_system_settings_public_role_id` (`public_role_id`) USING BTREE,
  KEY `fk_system_settings_session_expired_page_id` (`session_expired_page_id`) USING BTREE,
  KEY `fk_system_settings_site_default_page_id` (`site_default_page_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'Expertiza','Reusable learning objects through peer review','<a href=\"http://research.csc.ncsu.edu/efg/expertiza/papers\">Expertiza</a>',1,7200,1,1,3,4,2,3),(2,'Expertiza','Reusable learning objects through peer review','<a href=\"http://research.csc.ncsu.edu/efg/expertiza/papers\">Expertiza</a>',1,7200,1,1,3,4,2,3),(3,'Expertiza','Reusable learning objects through peer review','<a href=\"http://research.csc.ncsu.edu/efg/expertiza/papers\">Expertiza</a>',1,7200,1,1,3,4,2,3);
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ta_mappings`
--

DROP TABLE IF EXISTS `ta_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ta_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ta_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ta_mappings_course_id` (`course_id`) USING BTREE,
  KEY `fk_ta_mappings_ta_id` (`ta_id`) USING BTREE,
  CONSTRAINT `fk_ta_mappings_ta_id` FOREIGN KEY (`ta_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_ta_mappings_course_id` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ta_mappings`
--

LOCK TABLES `ta_mappings` WRITE;
/*!40000 ALTER TABLE `ta_mappings` DISABLE KEYS */;
/*!40000 ALTER TABLE `ta_mappings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tagname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_role_questionnaire`
--

DROP TABLE IF EXISTS `team_role_questionnaire`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `team_role_questionnaire` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_roles_id` int(11) DEFAULT NULL,
  `questionnaire_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_questionnaire_id` (`questionnaire_id`) USING BTREE,
  KEY `fk_team_roles_id` (`team_roles_id`) USING BTREE,
  CONSTRAINT `fk_team_roles_id` FOREIGN KEY (`team_roles_id`) REFERENCES `team_roles` (`id`),
  CONSTRAINT `fk_questionnaire_id` FOREIGN KEY (`questionnaire_id`) REFERENCES `questionnaires` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_role_questionnaire`
--

LOCK TABLES `team_role_questionnaire` WRITE;
/*!40000 ALTER TABLE `team_role_questionnaire` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_role_questionnaire` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_roles`
--

DROP TABLE IF EXISTS `team_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `team_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_names` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `questionnaire_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_team_roles_questionnaire` (`questionnaire_id`) USING BTREE,
  CONSTRAINT `fk_team_roles_questionnaire` FOREIGN KEY (`questionnaire_id`) REFERENCES `questionnaires` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_roles`
--

LOCK TABLES `team_roles` WRITE;
/*!40000 ALTER TABLE `team_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_rolesets`
--

DROP TABLE IF EXISTS `team_rolesets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `team_rolesets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roleset_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_rolesets`
--

LOCK TABLES `team_rolesets` WRITE;
/*!40000 ALTER TABLE `team_rolesets` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_rolesets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_rolesets_maps`
--

DROP TABLE IF EXISTS `team_rolesets_maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `team_rolesets_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_rolesets_id` int(11) DEFAULT NULL,
  `team_role_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_team_role_id` (`team_role_id`) USING BTREE,
  KEY `fk_team_rolesets_id` (`team_rolesets_id`) USING BTREE,
  CONSTRAINT `fk_team_rolesets_id` FOREIGN KEY (`team_rolesets_id`) REFERENCES `team_rolesets` (`id`),
  CONSTRAINT `fk_team_role_id` FOREIGN KEY (`team_role_id`) REFERENCES `team_roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_rolesets_maps`
--

LOCK TABLES `team_rolesets_maps` WRITE;
/*!40000 ALTER TABLE `team_rolesets_maps` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_rolesets_maps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teamrole_assignment`
--

DROP TABLE IF EXISTS `teamrole_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teamrole_assignment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_roleset_id` int(11) DEFAULT NULL,
  `assignment_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_teamrole_assignment_assignments` (`assignment_id`) USING BTREE,
  KEY `fk_teamrole_assignment_team_rolesets` (`team_roleset_id`) USING BTREE,
  CONSTRAINT `fk_teamrole_assignment_team_rolesets` FOREIGN KEY (`team_roleset_id`) REFERENCES `team_rolesets` (`id`),
  CONSTRAINT `fk_teamrole_assignment_assignments` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teamrole_assignment`
--

LOCK TABLES `teamrole_assignment` WRITE;
/*!40000 ALTER TABLE `teamrole_assignment` DISABLE KEYS */;
/*!40000 ALTER TABLE `teamrole_assignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comments_for_advertisement` text COLLATE utf8_unicode_ci,
  `advertise_for_partner` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teams`
--

LOCK TABLES `teams` WRITE;
/*!40000 ALTER TABLE `teams` DISABLE KEYS */;
INSERT INTO `teams` VALUES (1,'Assignment1_Team1',1,'AssignmentTeam',NULL,1),(2,'Assignment1_Team2',1,'AssignmentTeam',NULL,NULL),(3,'team3',1,'AssignmentTeam',NULL,NULL),(4,'Assignment2_Team1',2,'AssignmentTeam',NULL,NULL),(5,'Assignment2_Team2',2,'AssignmentTeam',NULL,NULL);
/*!40000 ALTER TABLE `teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teams_users`
--

DROP TABLE IF EXISTS `teams_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teams_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_users_teams` (`team_id`) USING BTREE,
  KEY `fk_teams_users` (`user_id`) USING BTREE,
  CONSTRAINT `fk_teams_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_users_teams` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teams_users`
--

LOCK TABLES `teams_users` WRITE;
/*!40000 ALTER TABLE `teams_users` DISABLE KEYS */;
INSERT INTO `teams_users` VALUES (1,1,2),(2,2,4),(3,2,5),(4,3,6),(5,3,7),(6,4,3),(7,5,2);
/*!40000 ALTER TABLE `teams_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `topic_deadlines`
--

DROP TABLE IF EXISTS `topic_deadlines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_deadlines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `due_at` datetime DEFAULT NULL,
  `deadline_type_id` int(11) DEFAULT NULL,
  `topic_id` int(11) DEFAULT NULL,
  `late_policy_id` int(11) DEFAULT NULL,
  `submission_allowed_id` int(11) DEFAULT NULL,
  `review_allowed_id` int(11) DEFAULT NULL,
  `resubmission_allowed_id` int(11) DEFAULT NULL,
  `rereview_allowed_id` int(11) DEFAULT NULL,
  `review_of_review_allowed_id` int(11) DEFAULT NULL,
  `round` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_deadline_type_topic_deadlines` (`deadline_type_id`) USING BTREE,
  KEY `fk_topic_deadlines_late_policies` (`late_policy_id`) USING BTREE,
  KEY `idx_rereview_allowed` (`rereview_allowed_id`) USING BTREE,
  KEY `idx_resubmission_allowed` (`resubmission_allowed_id`) USING BTREE,
  KEY `idx_review_allowed` (`review_allowed_id`) USING BTREE,
  KEY `idx_review_of_review_allowed` (`review_of_review_allowed_id`) USING BTREE,
  KEY `idx_submission_allowed` (`submission_allowed_id`) USING BTREE,
  KEY `fk_topic_deadlines_topics` (`topic_id`) USING BTREE,
  CONSTRAINT `fk_topic_deadlines_sign_up_topic` FOREIGN KEY (`topic_id`) REFERENCES `sign_up_topics` (`id`),
  CONSTRAINT `fk_topic_deadlines_deadline_type` FOREIGN KEY (`deadline_type_id`) REFERENCES `deadline_types` (`id`),
  CONSTRAINT `fk_topic_deadlines_late_policies` FOREIGN KEY (`late_policy_id`) REFERENCES `late_policies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `topic_deadlines`
--

LOCK TABLES `topic_deadlines` WRITE;
/*!40000 ALTER TABLE `topic_deadlines` DISABLE KEYS */;
/*!40000 ALTER TABLE `topic_deadlines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `topic_dependencies`
--

DROP TABLE IF EXISTS `topic_dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_dependencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `topic_id` int(11) NOT NULL DEFAULT '0',
  `dependent_on` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `topic_dependencies`
--

LOCK TABLES `topic_dependencies` WRITE;
/*!40000 ALTER TABLE `topic_dependencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `topic_dependencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tree_folders`
--

DROP TABLE IF EXISTS `tree_folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tree_folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `child_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tree_folders`
--

LOCK TABLES `tree_folders` WRITE;
/*!40000 ALTER TABLE `tree_folders` DISABLE KEYS */;
INSERT INTO `tree_folders` VALUES (1,'Questionnaires','QuestionnaireTypeNode',NULL),(2,'Courses','CourseNode',NULL),(3,'Assignments','AssignmentNode',NULL),(4,'Review','QuestionnaireNode',NULL),(5,'Metareview','QuestionnaireNode',NULL),(6,'Author Feedback','QuestionnaireNode',NULL),(7,'Teammate Review','QuestionnaireNode',NULL),(8,'Survey','QuestionnaireNode',NULL),(9,'Global Survey','QuestionnaireNode',NULL),(10,'Course Evaluation','QuestionnaireNode',NULL),(11,'Questionnaires','QuestionnaireTypeNode',NULL),(12,'Courses','CourseNode',NULL),(13,'Assignments','AssignmentNode',NULL),(14,'Review','QuestionnaireNode',NULL),(15,'Metareview','QuestionnaireNode',NULL),(16,'Author Feedback','QuestionnaireNode',NULL),(17,'Teammate Review','QuestionnaireNode',NULL),(18,'Survey','QuestionnaireNode',NULL),(19,'Global Survey','QuestionnaireNode',NULL),(20,'Course Evaluation','QuestionnaireNode',NULL),(21,'Questionnaires','QuestionnaireTypeNode',NULL),(22,'Courses','CourseNode',NULL),(23,'Assignments','AssignmentNode',NULL),(24,'Review','QuestionnaireNode',NULL),(25,'Metareview','QuestionnaireNode',NULL),(26,'Author Feedback','QuestionnaireNode',NULL),(27,'Teammate Review','QuestionnaireNode',NULL),(28,'Survey','QuestionnaireNode',NULL),(29,'Global Survey','QuestionnaireNode',NULL),(30,'Course Evaluation','QuestionnaireNode',NULL);
/*!40000 ALTER TABLE `tree_folders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `crypted_password` varchar(40) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `role_id` int(11) NOT NULL DEFAULT '0',
  `password_salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fullname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `private_by_default` tinyint(1) DEFAULT '0',
  `mru_directory_path` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_on_review` tinyint(1) DEFAULT NULL,
  `email_on_submission` tinyint(1) DEFAULT NULL,
  `email_on_review_of_review` tinyint(1) DEFAULT NULL,
  `is_new_user` tinyint(1) NOT NULL DEFAULT '1',
  `master_permission_granted` tinyint(4) DEFAULT '0',
  `handle` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `leaderboard_privacy` tinyint(1) DEFAULT '0',
  `digital_certificate` text COLLATE utf8_unicode_ci,
  `persistence_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timezonepref` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `public_key` text COLLATE utf8_unicode_ci,
  `copy_of_emails` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_user_role_id` (`role_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','d033e22ae348aeb5660fc2140aec35850c4da997',5,NULL,'Admin, Admin','anything@mailinator.com',1,0,NULL,1,1,1,0,0,'',0,NULL,'bf46002e68fd9330e0be61bc46aab6f8fcbda1e9a702ab8a76023097a7cce6792c243d006ea502d722099f2e7552d114be827e9e246cb1f681e09b1b1724710b','Eastern Time (US & Canada)',NULL,0),(2,'student1','b673aa0b1a6f54fd4c63d4b9f1cecaff0b7398be',1,'KtkILlFZXdfcTFpw25','Student, One','student1@ncsu.edu',1,0,NULL,NULL,NULL,NULL,0,0,'',0,NULL,'cacc8c9c777e67d44e2ab47d8b5f9b22ff77d708de03ef72ed47230fd50badc81baee35e9d37f0ec754916832b1d17f5d433bc532574b4da2206af4dd7d67897','Eastern Time (US & Canada)',NULL,0),(3,'student2','3af4f2b4a0cc164bc06855f28e111dc827b31d3a',1,'NHaTZJLgCz6HW3fuxw0V','Student, Two','student2@ncsu.edu',1,0,NULL,NULL,NULL,NULL,0,0,'',0,NULL,'44255d394703f7d97869f25549067ceca8e9bd26c52263c4fd6e5b47c57ca547fbb0c5a52a6ef25df0117e03a6524d76bcf27bfa0ba479ae560341e27c534d41','Eastern Time (US & Canada)',NULL,0),(4,'student3','1cf85af1e52663639f2c2607a70bc6ae6a9ef059',1,'1TOqlJ2YYagcxfAMtnpp','Student, Three','student3@ncsu.edu',1,0,NULL,NULL,NULL,NULL,0,0,'',0,NULL,'1b960d96fb47fe60574cf0dada54590850747ad2db43530b00f72e1e1afad9f3b7fde0aa3a5a36fc255b0b587a29b25ef833e1bfd487956bb39f8e10e651e949','Eastern Time (US & Canada)',NULL,0),(5,'student4','5e81569cf499625f7adaec86dd09912105e30fd0',1,'DRR84EGStngtJz1cO7','Student, Four','student4@ncsu.edu',1,0,NULL,NULL,NULL,NULL,0,0,'',0,NULL,'e90a70a885c9be96f7a86376f1cfc684ee8386d019ee8e3aa049cc33ac0c5980c4668814dd097a3a443c1406d59384a7e1a89bde41844cc5e99501838dbead8d','Eastern Time (US & Canada)',NULL,0),(6,'student5','cf8652d973ae0e111bd9ef07d9feec2cafacde1e',1,'kzKSQDRIrnNuJlOUdLx','Student, Five','student5@ncsu.edu',1,0,NULL,NULL,NULL,NULL,0,0,NULL,0,NULL,'d0c7d8309ded728bda93179c8013de3cc742ea0e8262a251a3194561af881ae3d64b4c29fe31f59b6bc3a226ce30e61becdb103beeea444405cdfae639c46b59','Eastern Time (US & Canada)',NULL,0),(7,'student6','277134342c4aced2578c8e1911c00cef3b88f1ce',1,'0B1Pk95VB9E8IFsVZiS','Student, Six','student6@ncsu.edu',1,0,NULL,NULL,NULL,NULL,0,0,NULL,0,NULL,'3e82e67bfeac06f008411845cbf69f32ebbd9422855463b7f31a667960cb753c1479f47eb45ab0e97b6ee6c6d4f3b56272b5a5fcfd38dbca9da3fbd8912bb802','Eastern Time (US & Canada)',NULL,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `versions`
--

DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `whodunnit` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=192 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `versions`
--

LOCK TABLES `versions` WRITE;
/*!40000 ALTER TABLE `versions` DISABLE KEYS */;
INSERT INTO `versions` VALUES (1,'User',1,'create',NULL,NULL,'2015-12-04 19:56:01'),(2,'Node',1,'create',NULL,NULL,'2015-12-04 19:56:01'),(3,'Node',2,'create',NULL,NULL,'2015-12-04 19:56:01'),(4,'Node',3,'create',NULL,NULL,'2015-12-04 19:56:01'),(5,'Node',4,'create',NULL,NULL,'2015-12-04 19:56:01'),(6,'Node',5,'create',NULL,NULL,'2015-12-04 19:56:01'),(7,'Node',6,'create',NULL,NULL,'2015-12-04 19:56:01'),(8,'Node',7,'create',NULL,NULL,'2015-12-04 19:56:01'),(9,'Node',8,'create',NULL,NULL,'2015-12-04 19:56:01'),(10,'Node',9,'create',NULL,NULL,'2015-12-04 19:56:01'),(11,'Node',10,'create',NULL,NULL,'2015-12-04 19:56:01'),(12,'Node',1,'update',NULL,'---\nid: 1\nparent_id: \nnode_object_id: 1\ntype: \n','2015-12-04 19:56:01'),(13,'Node',2,'update',NULL,'---\nid: 2\nparent_id: \nnode_object_id: 2\ntype: \n','2015-12-04 19:56:01'),(14,'Node',3,'update',NULL,'---\nid: 3\nparent_id: \nnode_object_id: 3\ntype: \n','2015-12-04 19:56:01'),(15,'Node',4,'update',NULL,'---\nid: 4\nparent_id: 1\nnode_object_id: 4\ntype: \n','2015-12-04 19:56:01'),(16,'Node',5,'update',NULL,'---\nid: 5\nparent_id: 1\nnode_object_id: 5\ntype: \n','2015-12-04 19:56:01'),(17,'Node',6,'update',NULL,'---\nid: 6\nparent_id: 1\nnode_object_id: 6\ntype: \n','2015-12-04 19:56:01'),(18,'Node',7,'update',NULL,'---\nid: 7\nparent_id: 1\nnode_object_id: 7\ntype: \n','2015-12-04 19:56:01'),(19,'Node',8,'update',NULL,'---\nid: 8\nparent_id: 1\nnode_object_id: 8\ntype: \n','2015-12-04 19:56:01'),(20,'Node',9,'update',NULL,'---\nid: 9\nparent_id: 1\nnode_object_id: 9\ntype: \n','2015-12-04 19:56:01'),(21,'Node',10,'update',NULL,'---\nid: 10\nparent_id: 1\nnode_object_id: 10\ntype: \n','2015-12-04 19:56:01'),(22,'User',1,'update',NULL,'---\nid: 1\nname: admin\ncrypted_password: d033e22ae348aeb5660fc2140aec35850c4da997\nrole_id: 5\npassword_salt: \nfullname: \nemail: anything@mailinator.com\nparent_id: \nprivate_by_default: false\nmru_directory_path: \nemail_on_review: true\nemail_on_submission: true\nemail_on_review_of_review: true\nis_new_user: false\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: \ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-04 19:56:18'),(23,'Node',11,'create',NULL,NULL,'2015-12-04 19:56:18'),(24,'Node',12,'create',NULL,NULL,'2015-12-04 19:56:18'),(25,'Node',13,'create',NULL,NULL,'2015-12-04 19:56:18'),(26,'Node',14,'create',NULL,NULL,'2015-12-04 19:56:18'),(27,'Node',15,'create',NULL,NULL,'2015-12-04 19:56:18'),(28,'Node',16,'create',NULL,NULL,'2015-12-04 19:56:18'),(29,'Node',17,'create',NULL,NULL,'2015-12-04 19:56:18'),(30,'Node',18,'create',NULL,NULL,'2015-12-04 19:56:18'),(31,'Node',19,'create',NULL,NULL,'2015-12-04 19:56:18'),(32,'Node',20,'create',NULL,NULL,'2015-12-04 19:56:18'),(33,'Node',11,'update',NULL,'---\nid: 11\nparent_id: \nnode_object_id: 1\ntype: \n','2015-12-04 19:56:18'),(34,'Node',12,'update',NULL,'---\nid: 12\nparent_id: \nnode_object_id: 2\ntype: \n','2015-12-04 19:56:18'),(35,'Node',13,'update',NULL,'---\nid: 13\nparent_id: \nnode_object_id: 3\ntype: \n','2015-12-04 19:56:18'),(36,'Node',14,'update',NULL,'---\nid: 14\nparent_id: 11\nnode_object_id: 4\ntype: \n','2015-12-04 19:56:18'),(37,'Node',15,'update',NULL,'---\nid: 15\nparent_id: 11\nnode_object_id: 5\ntype: \n','2015-12-04 19:56:18'),(38,'Node',16,'update',NULL,'---\nid: 16\nparent_id: 11\nnode_object_id: 6\ntype: \n','2015-12-04 19:56:18'),(39,'Node',17,'update',NULL,'---\nid: 17\nparent_id: 11\nnode_object_id: 7\ntype: \n','2015-12-04 19:56:18'),(40,'Node',18,'update',NULL,'---\nid: 18\nparent_id: 11\nnode_object_id: 8\ntype: \n','2015-12-04 19:56:18'),(41,'Node',19,'update',NULL,'---\nid: 19\nparent_id: 11\nnode_object_id: 9\ntype: \n','2015-12-04 19:56:18'),(42,'Node',20,'update',NULL,'---\nid: 20\nparent_id: 11\nnode_object_id: 10\ntype: \n','2015-12-04 19:56:18'),(43,'User',1,'update',NULL,'---\nid: 1\nname: admin\ncrypted_password: d033e22ae348aeb5660fc2140aec35850c4da997\nrole_id: 5\npassword_salt: \nfullname: \nemail: anything@mailinator.com\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: true\nemail_on_submission: true\nemail_on_review_of_review: true\nis_new_user: false\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: \ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-04 19:57:43'),(44,'Node',21,'create',NULL,NULL,'2015-12-04 19:57:43'),(45,'Node',22,'create',NULL,NULL,'2015-12-04 19:57:43'),(46,'Node',23,'create',NULL,NULL,'2015-12-04 19:57:43'),(47,'Node',24,'create',NULL,NULL,'2015-12-04 19:57:43'),(48,'Node',25,'create',NULL,NULL,'2015-12-04 19:57:43'),(49,'Node',26,'create',NULL,NULL,'2015-12-04 19:57:43'),(50,'Node',27,'create',NULL,NULL,'2015-12-04 19:57:43'),(51,'Node',28,'create',NULL,NULL,'2015-12-04 19:57:43'),(52,'Node',29,'create',NULL,NULL,'2015-12-04 19:57:43'),(53,'Node',30,'create',NULL,NULL,'2015-12-04 19:57:43'),(54,'Node',21,'update',NULL,'---\nid: 21\nparent_id: \nnode_object_id: 1\ntype: \n','2015-12-04 19:57:43'),(55,'Node',22,'update',NULL,'---\nid: 22\nparent_id: \nnode_object_id: 2\ntype: \n','2015-12-04 19:57:43'),(56,'Node',23,'update',NULL,'---\nid: 23\nparent_id: \nnode_object_id: 3\ntype: \n','2015-12-04 19:57:43'),(57,'Node',24,'update',NULL,'---\nid: 24\nparent_id: 21\nnode_object_id: 4\ntype: \n','2015-12-04 19:57:43'),(58,'Node',25,'update',NULL,'---\nid: 25\nparent_id: 21\nnode_object_id: 5\ntype: \n','2015-12-04 19:57:43'),(59,'Node',26,'update',NULL,'---\nid: 26\nparent_id: 21\nnode_object_id: 6\ntype: \n','2015-12-04 19:57:43'),(60,'Node',27,'update',NULL,'---\nid: 27\nparent_id: 21\nnode_object_id: 7\ntype: \n','2015-12-04 19:57:43'),(61,'Node',28,'update',NULL,'---\nid: 28\nparent_id: 21\nnode_object_id: 8\ntype: \n','2015-12-04 19:57:43'),(62,'Node',29,'update',NULL,'---\nid: 29\nparent_id: 21\nnode_object_id: 9\ntype: \n','2015-12-04 19:57:43'),(63,'Node',30,'update',NULL,'---\nid: 30\nparent_id: 21\nnode_object_id: 10\ntype: \n','2015-12-04 19:57:43'),(64,'User',2,'create','1',NULL,'2015-12-12 19:53:53'),(65,'User',2,'update','1','---\nid: 2\nname: student1\ncrypted_password: eefab284ec365a585bfaff461f6416baf49ac843\nrole_id: 1\npassword_salt: RxYfBwKQCjyQZBtmoHB\nfullname: Student, One\nemail: student1@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: b8186401b537ce5cc520f29a045b75242759f4a923efe70b2fb0fb489b34f49ca31d3df4cca16ea31cb83715153186f275d4509c955131fac35f56c3cc98a5c8\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 19:53:53'),(66,'User',3,'create','1',NULL,'2015-12-12 19:54:38'),(67,'User',3,'update','1','---\nid: 3\nname: student2\ncrypted_password: e41f4cdd239e32295288de11f8eb2aaf1e2f7a25\nrole_id: 1\npassword_salt: FFPqsRdr6o0f2Udj6ydN\nfullname: Student, Two\nemail: student2@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: cabe270711dae47fdb98d0be70cfea3248b9f542e90f84b6947bae694a2c2983e20605674588d9aa813ff01f9712570839407a016733ae3063e3a6083fb52290\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 19:54:38'),(68,'User',4,'create','1',NULL,'2015-12-12 19:55:25'),(69,'User',4,'update','1','---\nid: 4\nname: student3\ncrypted_password: ce60b9c3aefc4880ee50b9aa477a8f4544b03a0c\nrole_id: 1\npassword_salt: HMlGV4bLOTxPxOCiEGuU\nfullname: Student, Three\nemail: student3@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: cb0c63fb8f98969246f7a0b82b52d66bdb50a5514b87da60f848df63e430d022c7542a2199e579e0b895210884bcf1a9f350f7242466a2841d1507047d1e328b\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 19:55:25'),(70,'User',5,'create','1',NULL,'2015-12-12 19:56:49'),(71,'User',5,'update','1','---\nid: 5\nname: student4\ncrypted_password: bfe6d3f369c260fbebde8a02de5f67fabaa44ca1\nrole_id: 1\npassword_salt: max78rK3bW4uB5Pf7Svb\nfullname: Student, Four\nemail: student4@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: c0e12cb93d51ca05d9ebd3c8867cecdb0afee4c6eb1a77f1f9a7f2f734515f848b8c8095445b4dcd561a00858e5a2c6561181891c681d2fcb744bbeb4a2ea58b\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 19:56:49'),(72,'Course',1,'create','1',NULL,'2015-12-12 19:59:09'),(73,'Node',31,'create','1',NULL,'2015-12-12 19:59:09'),(74,'Assignment',1,'create','1',NULL,'2015-12-12 20:04:48'),(75,'Node',32,'create','1',NULL,'2015-12-12 20:04:48'),(76,'Node',32,'update','1','---\nid: 32\nparent_id: \nnode_object_id: 1\ntype: AssignmentNode\n','2015-12-12 20:04:48'),(77,'SignUpTopic',1,'create','1',NULL,'2015-12-12 20:07:23'),(78,'SignUpTopic',2,'create','1',NULL,'2015-12-12 20:08:11'),(79,'User',2,'update','2','---\nid: 2\nname: student1\ncrypted_password: 582a2d9188fe9998d951a57f8a2d9be49ccd710e\nrole_id: 1\npassword_salt: 6exGOusWqXGzOhRzgSl\nfullname: Student, One\nemail: student1@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: f2e95b92283d4a2919e55a9dfe77b05020dcfbcbac9c6cb7eaa72db495cb8583f69f21e13c4fc796ea2acbb419a74f4caa0188bb73639e4853aa2d0862fbd7d9\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:11:31'),(80,'User',2,'update','2','---\nid: 2\nname: student1\ncrypted_password: 582a2d9188fe9998d951a57f8a2d9be49ccd710e\nrole_id: 1\npassword_salt: 6exGOusWqXGzOhRzgSl\nfullname: Student, One\nemail: student1@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: false\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: f2e95b92283d4a2919e55a9dfe77b05020dcfbcbac9c6cb7eaa72db495cb8583f69f21e13c4fc796ea2acbb419a74f4caa0188bb73639e4853aa2d0862fbd7d9\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:12:04'),(81,'User',1,'update','1','---\nid: 1\nname: admin\ncrypted_password: d033e22ae348aeb5660fc2140aec35850c4da997\nrole_id: 5\npassword_salt: \nfullname: \nemail: anything@mailinator.com\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: true\nemail_on_submission: true\nemail_on_review_of_review: true\nis_new_user: false\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: \ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:13:15'),(82,'User',3,'update','3','---\nid: 3\nname: student2\ncrypted_password: e4448c34e2604ed1f821bdee3c0ea5248e979e87\nrole_id: 1\npassword_salt: TG5a2xJ5DIQW7skVgP\nfullname: Student, Two\nemail: student2@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: 68457972bcdfabe2513cc82819ecb41b956966ac359c0fcd8a4369a30c8f8e232a3559b10e7b3f33d2120bf64dae308ad10c8383d865f38118a1c950c053488b\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:14:16'),(83,'User',3,'update','3','---\nid: 3\nname: student2\ncrypted_password: e4448c34e2604ed1f821bdee3c0ea5248e979e87\nrole_id: 1\npassword_salt: TG5a2xJ5DIQW7skVgP\nfullname: Student, Two\nemail: student2@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: false\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: 68457972bcdfabe2513cc82819ecb41b956966ac359c0fcd8a4369a30c8f8e232a3559b10e7b3f33d2120bf64dae308ad10c8383d865f38118a1c950c053488b\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:14:48'),(84,'User',4,'update','4','---\nid: 4\nname: student3\ncrypted_password: 49ac1d520624d96045ab4d874c360dfd75447c08\nrole_id: 1\npassword_salt: JxBlegSOb7B5U4m4dYSc\nfullname: Student, Three\nemail: student3@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: e39bdae77948ad784faee8a9710b08164c30b0e88825ada49172b602ace6bf3a4637510190042c7b75028663ad70dd7d2c9a9592b6286cc4bbab4f760e62889d\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:16:42'),(85,'User',4,'update','4','---\nid: 4\nname: student3\ncrypted_password: 49ac1d520624d96045ab4d874c360dfd75447c08\nrole_id: 1\npassword_salt: JxBlegSOb7B5U4m4dYSc\nfullname: Student, Three\nemail: student3@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: false\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: e39bdae77948ad784faee8a9710b08164c30b0e88825ada49172b602ace6bf3a4637510190042c7b75028663ad70dd7d2c9a9592b6286cc4bbab4f760e62889d\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:17:51'),(86,'User',5,'update','5','---\nid: 5\nname: student4\ncrypted_password: 56c2a947ead024fbe245c980cc83b15f37c783b0\nrole_id: 1\npassword_salt: zmP8WhARBceCxM0HhKXp\nfullname: Student, Four\nemail: student4@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: ac34a01584bda22e4b70becb6a2905ca05d5841c61c0b7486dc67ce3a5f514510f43560760f192304c343d4cad5bf07695ff3786b1fd59ea4875d9ea42432380\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:18:55'),(87,'User',5,'update','5','---\nid: 5\nname: student4\ncrypted_password: 56c2a947ead024fbe245c980cc83b15f37c783b0\nrole_id: 1\npassword_salt: zmP8WhARBceCxM0HhKXp\nfullname: Student, Four\nemail: student4@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: false\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: ac34a01584bda22e4b70becb6a2905ca05d5841c61c0b7486dc67ce3a5f514510f43560760f192304c343d4cad5bf07695ff3786b1fd59ea4875d9ea42432380\ntimezonepref: \npublic_key: \ncopy_of_emails: false\n','2015-12-12 20:19:29'),(88,'Assignment',1,'update','1','---\nid: 1\ncreated_at: 2015-12-12 20:04:48.000000000 Z\nupdated_at: 2015-12-12 20:04:48.000000000 Z\nname: Aassignment1\ndirectory_path: bin/assign\nsubmitter_count: 0\ncourse_id: 1\ninstructor_id: 1\nprivate: false\nnum_reviews: 0\nnum_review_of_reviews: 0\nnum_review_of_reviewers: 0\nreview_questionnaire_id: \nreview_of_review_questionnaire_id: \nteammate_review_questionnaire_id: \nreviews_visible_to_all: false\nwiki_type_id: 1\nnum_reviewers: 0\nspec_location: sampleURL.com\nauthor_feedback_questionnaire_id: \nmax_team_size: 2\nstaggered_deadline: false\nallow_suggestions: \ndays_between_submissions: \nreview_assignment_strategy: \nmax_reviews_per_submission: \nreview_topic_threshold: 0\ncopy_flag: false\nrounds_of_reviews: 1\nmicrotask: false\nselfreview_questionnaire_id: \nmanagerreview_questionnaire_id: \nreaderreview_questionnaire_id: \nrequire_quiz: false\nnum_quiz_questions: 0\nis_coding_assignment: false\nis_intelligent: \ncalculate_penalty: false\nlate_policy_id: \nis_penalty_calculated: false\nmax_bids: \nshow_teammate_reviews: false\navailability_flag: true\nuse_bookmark: \ncan_review_same_topic: true\ncan_choose_topic_to_review: true\n','2015-12-12 20:20:16'),(89,'Assignment',1,'update','1','---\nid: 1\ncreated_at: 2015-12-12 20:04:48.000000000 Z\nupdated_at: 2015-12-12 20:20:16.000000000 Z\nname: Aassignment1\ndirectory_path: bin/assign\nsubmitter_count: 0\ncourse_id: 1\ninstructor_id: 1\nprivate: false\nnum_reviews: 0\nnum_review_of_reviews: 0\nnum_review_of_reviewers: 0\nreview_questionnaire_id: \nreview_of_review_questionnaire_id: \nteammate_review_questionnaire_id: \nreviews_visible_to_all: false\nwiki_type_id: 1\nnum_reviewers: 0\nspec_location: sampleURL.com\nauthor_feedback_questionnaire_id: \nmax_team_size: 2\nstaggered_deadline: false\nallow_suggestions: false\ndays_between_submissions: \nreview_assignment_strategy: Auto-Selected\nmax_reviews_per_submission: \nreview_topic_threshold: 0\ncopy_flag: false\nrounds_of_reviews: 1\nmicrotask: false\nselfreview_questionnaire_id: \nmanagerreview_questionnaire_id: \nreaderreview_questionnaire_id: \nrequire_quiz: false\nnum_quiz_questions: 0\nis_coding_assignment: false\nis_intelligent: false\ncalculate_penalty: false\nlate_policy_id: \nis_penalty_calculated: false\nmax_bids: \nshow_teammate_reviews: false\navailability_flag: true\nuse_bookmark: false\ncan_review_same_topic: true\ncan_choose_topic_to_review: true\n','2015-12-12 20:20:35'),(90,'AssignmentQuestionnaire',2,'create','1',NULL,'2015-12-12 20:29:24'),(91,'AssignmentQuestionnaire',3,'create','1',NULL,'2015-12-12 20:33:05'),(92,'AssignmentQuestionnaire',4,'create','1',NULL,'2015-12-12 20:33:05'),(93,'AssignmentQuestionnaire',5,'create','1',NULL,'2015-12-12 20:33:15'),(94,'AssignmentQuestionnaire',6,'create','1',NULL,'2015-12-12 20:33:15'),(95,'AssignmentQuestionnaire',7,'create','1',NULL,'2015-12-12 20:33:43'),(96,'AssignmentQuestionnaire',8,'create','1',NULL,'2015-12-12 20:33:43'),(97,'AssignmentQuestionnaire',9,'create','1',NULL,'2015-12-12 20:33:52'),(98,'AssignmentQuestionnaire',10,'create','1',NULL,'2015-12-12 20:33:52'),(99,'AssignmentQuestionnaire',11,'create','1',NULL,'2015-12-12 20:34:15'),(100,'AssignmentQuestionnaire',12,'create','1',NULL,'2015-12-12 20:34:15'),(101,'Assignment',1,'update','1','---\nid: 1\ncreated_at: 2015-12-12 20:04:48.000000000 Z\nupdated_at: 2015-12-12 20:20:35.000000000 Z\nname: Aassignment1\ndirectory_path: bin/assign\nsubmitter_count: 0\ncourse_id: 1\ninstructor_id: 1\nprivate: false\nnum_reviews: 0\nnum_review_of_reviews: 0\nnum_review_of_reviewers: 0\nreview_questionnaire_id: \nreview_of_review_questionnaire_id: \nteammate_review_questionnaire_id: \nreviews_visible_to_all: false\nwiki_type_id: 1\nnum_reviewers: 0\nspec_location: sampleURL.com\nauthor_feedback_questionnaire_id: \nmax_team_size: 2\nstaggered_deadline: false\nallow_suggestions: false\ndays_between_submissions: \nreview_assignment_strategy: Auto-Selected\nmax_reviews_per_submission: 6\nreview_topic_threshold: 6\ncopy_flag: false\nrounds_of_reviews: 1\nmicrotask: false\nselfreview_questionnaire_id: \nmanagerreview_questionnaire_id: \nreaderreview_questionnaire_id: \nrequire_quiz: false\nnum_quiz_questions: 0\nis_coding_assignment: false\nis_intelligent: false\ncalculate_penalty: false\nlate_policy_id: \nis_penalty_calculated: false\nmax_bids: \nshow_teammate_reviews: false\navailability_flag: true\nuse_bookmark: false\ncan_review_same_topic: true\ncan_choose_topic_to_review: true\n','2015-12-12 20:35:12'),(102,'AssignmentQuestionnaire',13,'create','1',NULL,'2015-12-12 20:35:12'),(103,'AssignmentQuestionnaire',14,'create','1',NULL,'2015-12-12 20:35:12'),(104,'AssignmentQuestionnaire',15,'create','1',NULL,'2015-12-12 20:35:14'),(105,'AssignmentQuestionnaire',16,'create','1',NULL,'2015-12-12 20:35:14'),(106,'AssignmentQuestionnaire',17,'create','1',NULL,'2015-12-12 20:35:18'),(107,'AssignmentQuestionnaire',18,'create','1',NULL,'2015-12-12 20:35:18'),(108,'AssignmentQuestionnaire',19,'create','1',NULL,'2015-12-12 20:35:20'),(109,'AssignmentQuestionnaire',20,'create','1',NULL,'2015-12-12 20:35:20'),(110,'AssignmentQuestionnaire',21,'create','1',NULL,'2015-12-12 20:35:23'),(111,'AssignmentQuestionnaire',22,'create','1',NULL,'2015-12-12 20:35:23'),(112,'Participant',1,'create','1',NULL,'2015-12-12 20:38:01'),(113,'Participant',2,'create','1',NULL,'2015-12-12 20:38:10'),(114,'Participant',3,'create','1',NULL,'2015-12-12 20:38:21'),(115,'Participant',4,'create','1',NULL,'2015-12-12 20:38:29'),(116,'AssignmentQuestionnaire',23,'create','1',NULL,'2015-12-12 21:01:56'),(117,'AssignmentQuestionnaire',24,'create','1',NULL,'2015-12-12 21:01:56'),(118,'AssignmentQuestionnaire',25,'create','1',NULL,'2015-12-12 21:03:02'),(119,'AssignmentQuestionnaire',26,'create','1',NULL,'2015-12-12 21:03:02'),(120,'Team',1,'create','2',NULL,'2015-12-12 21:22:36'),(121,'Node',33,'create','2',NULL,'2015-12-12 21:22:36'),(122,'TeamsUser',1,'create','2',NULL,'2015-12-12 21:22:36'),(123,'Node',34,'create','2',NULL,'2015-12-12 21:22:36'),(124,'Team',2,'create','4',NULL,'2015-12-13 15:23:44'),(125,'Node',35,'create','4',NULL,'2015-12-13 15:23:44'),(126,'TeamsUser',2,'create','4',NULL,'2015-12-13 15:23:44'),(127,'Node',36,'create','4',NULL,'2015-12-13 15:23:44'),(128,'TeamsUser',3,'create','5',NULL,'2015-12-13 15:26:43'),(129,'Node',37,'create','5',NULL,'2015-12-13 15:26:43'),(130,'Participant',3,'update','4','---\nid: 3\ncan_submit: true\ncan_review: true\nuser_id: 4\nparent_id: 1\ndirectory_num: \nsubmitted_at: \npermission_granted: false\npenalty_accumulated: 0\nsubmitted_hyperlinks: \ngrade: \ntype: AssignmentParticipant\nhandle: student3\ntime_stamp: \ndigital_signature: \nduty: \ncan_take_quiz: true\n','2015-12-13 15:31:53'),(131,'AssignmentQuestionnaire',27,'create','1',NULL,'2015-12-13 15:33:47'),(132,'AssignmentQuestionnaire',28,'create','1',NULL,'2015-12-13 15:33:47'),(133,'SignUpTopic',3,'create','1',NULL,'2015-12-13 15:34:15'),(134,'User',6,'create','1',NULL,'2015-12-13 15:35:19'),(135,'User',6,'update','1','---\nid: 6\nname: student5\ncrypted_password: 2ec2c7252adca5d5a74d216ce43fafc4663e88ad\nrole_id: 1\npassword_salt: J7XmRKXfCNiRudEtfjyo\nfullname: Student, Five\nemail: student5@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: 837650369bf54f6c86aef072c6e3dcf2d0bbea6a5fa75f30373959879937a26a3d9f8efe7af5e180b07ed5f1b755a76641847a058a524bde892eb78c7b804ebc\ntimezonepref: Eastern Time (US & Canada)\npublic_key: \ncopy_of_emails: false\n','2015-12-13 15:35:19'),(136,'User',7,'create','1',NULL,'2015-12-13 15:35:56'),(137,'User',7,'update','1','---\nid: 7\nname: student6\ncrypted_password: 54d70890b67cbce14afdd91f861b32662b42a58e\nrole_id: 1\npassword_salt: 3A5QVjhwpUNEgx9Ps4aa\nfullname: Student, Six\nemail: student6@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: 7ae26229a452db0415cff7c95a19a7cb05fe11653a92b6ec0740831e9a02b3b395357cb56a6b2637e375ce0523aa1c22f2eed9416a9ffd6af7753f064bf52c0c\ntimezonepref: Eastern Time (US & Canada)\npublic_key: \ncopy_of_emails: false\n','2015-12-13 15:35:56'),(138,'Participant',5,'create','1',NULL,'2015-12-13 15:36:32'),(139,'Participant',6,'create','1',NULL,'2015-12-13 15:36:41'),(140,'User',6,'update','6','---\nid: 6\nname: student5\ncrypted_password: cf8652d973ae0e111bd9ef07d9feec2cafacde1e\nrole_id: 1\npassword_salt: kzKSQDRIrnNuJlOUdLx\nfullname: Student, Five\nemail: student5@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: d0c7d8309ded728bda93179c8013de3cc742ea0e8262a251a3194561af881ae3d64b4c29fe31f59b6bc3a226ce30e61becdb103beeea444405cdfae639c46b59\ntimezonepref: Eastern Time (US & Canada)\npublic_key: \ncopy_of_emails: false\n','2015-12-13 15:37:46'),(141,'Team',3,'create','6',NULL,'2015-12-13 15:40:54'),(142,'Node',38,'create','6',NULL,'2015-12-13 15:40:54'),(143,'TeamsUser',4,'create','6',NULL,'2015-12-13 15:40:54'),(144,'Node',39,'create','6',NULL,'2015-12-13 15:40:54'),(145,'User',7,'update','7','---\nid: 7\nname: student6\ncrypted_password: 277134342c4aced2578c8e1911c00cef3b88f1ce\nrole_id: 1\npassword_salt: 0B1Pk95VB9E8IFsVZiS\nfullname: Student, Six\nemail: student6@ncsu.edu\nparent_id: 1\nprivate_by_default: false\nmru_directory_path: \nemail_on_review: \nemail_on_submission: \nemail_on_review_of_review: \nis_new_user: true\nmaster_permission_granted: 0\nhandle: \nleaderboard_privacy: false\ndigital_certificate: \npersistence_token: 3e82e67bfeac06f008411845cbf69f32ebbd9422855463b7f31a667960cb753c1479f47eb45ab0e97b6ee6c6d4f3b56272b5a5fcfd38dbca9da3fbd8912bb802\ntimezonepref: Eastern Time (US & Canada)\npublic_key: \ncopy_of_emails: false\n','2015-12-13 15:42:38'),(146,'TeamsUser',5,'create','7',NULL,'2015-12-13 15:43:03'),(147,'Node',40,'create','7',NULL,'2015-12-13 15:43:03'),(148,'Participant',6,'update','7','---\nid: 6\ncan_submit: true\ncan_review: true\nuser_id: 7\nparent_id: 1\ndirectory_num: \nsubmitted_at: \npermission_granted: false\npenalty_accumulated: 0\nsubmitted_hyperlinks: \ngrade: \ntype: AssignmentParticipant\nhandle: student6\ntime_stamp: \ndigital_signature: \nduty: \ncan_take_quiz: true\n','2015-12-13 15:43:54'),(149,'Assignment',2,'create','1',NULL,'2015-12-13 18:24:38'),(150,'Node',41,'create','1',NULL,'2015-12-13 18:24:38'),(151,'Node',41,'update','1','---\nid: 41\nparent_id: \nnode_object_id: 2\ntype: AssignmentNode\n','2015-12-13 18:24:38'),(152,'Assignment',2,'update','1','---\nid: 2\ncreated_at: 2015-12-13 18:24:38.000000000 Z\nupdated_at: 2015-12-13 18:24:38.000000000 Z\nname: Assignment2\ndirectory_path: \"/bin\"\nsubmitter_count: 0\ncourse_id: 1\ninstructor_id: 1\nprivate: false\nnum_reviews: 0\nnum_review_of_reviews: 0\nnum_review_of_reviewers: 0\nreview_questionnaire_id: \nreview_of_review_questionnaire_id: \nteammate_review_questionnaire_id: \nreviews_visible_to_all: false\nwiki_type_id: 1\nnum_reviewers: 0\nspec_location: www.google.com\nauthor_feedback_questionnaire_id: \nmax_team_size: 1\nstaggered_deadline: false\nallow_suggestions: \ndays_between_submissions: \nreview_assignment_strategy: \nmax_reviews_per_submission: \nreview_topic_threshold: 0\ncopy_flag: false\nrounds_of_reviews: 1\nmicrotask: false\nselfreview_questionnaire_id: \nmanagerreview_questionnaire_id: \nreaderreview_questionnaire_id: \nrequire_quiz: false\nnum_quiz_questions: 0\nis_coding_assignment: false\nis_intelligent: \ncalculate_penalty: false\nlate_policy_id: \nis_penalty_calculated: false\nmax_bids: \nshow_teammate_reviews: false\navailability_flag: true\nuse_bookmark: \ncan_review_same_topic: true\ncan_choose_topic_to_review: true\n','2015-12-13 18:24:46'),(153,'Assignment',2,'update','1','---\nid: 2\ncreated_at: 2015-12-13 18:24:38.000000000 Z\nupdated_at: 2015-12-13 18:24:46.000000000 Z\nname: Assignment2\ndirectory_path: \"/bin\"\nsubmitter_count: 0\ncourse_id: 1\ninstructor_id: 1\nprivate: false\nnum_reviews: 0\nnum_review_of_reviews: 0\nnum_review_of_reviewers: 0\nreview_questionnaire_id: \nreview_of_review_questionnaire_id: \nteammate_review_questionnaire_id: \nreviews_visible_to_all: false\nwiki_type_id: 1\nnum_reviewers: 0\nspec_location: www.google.com\nauthor_feedback_questionnaire_id: \nmax_team_size: 1\nstaggered_deadline: false\nallow_suggestions: false\ndays_between_submissions: \nreview_assignment_strategy: Auto-Selected\nmax_reviews_per_submission: \nreview_topic_threshold: 0\ncopy_flag: false\nrounds_of_reviews: 1\nmicrotask: false\nselfreview_questionnaire_id: \nmanagerreview_questionnaire_id: \nreaderreview_questionnaire_id: \nrequire_quiz: false\nnum_quiz_questions: 0\nis_coding_assignment: false\nis_intelligent: false\ncalculate_penalty: false\nlate_policy_id: \nis_penalty_calculated: false\nmax_bids: \nshow_teammate_reviews: false\navailability_flag: true\nuse_bookmark: false\ncan_review_same_topic: true\ncan_choose_topic_to_review: true\n','2015-12-13 18:25:01'),(154,'AssignmentQuestionnaire',29,'create','1',NULL,'2015-12-13 18:25:18'),(155,'AssignmentQuestionnaire',30,'create','1',NULL,'2015-12-13 18:25:18'),(156,'AssignmentQuestionnaire',31,'create','1',NULL,'2015-12-13 18:25:24'),(157,'AssignmentQuestionnaire',32,'create','1',NULL,'2015-12-13 18:25:24'),(158,'AssignmentQuestionnaire',33,'create','1',NULL,'2015-12-13 18:25:26'),(159,'AssignmentQuestionnaire',34,'create','1',NULL,'2015-12-13 18:25:26'),(160,'AssignmentQuestionnaire',35,'create','1',NULL,'2015-12-13 18:25:39'),(161,'AssignmentQuestionnaire',36,'create','1',NULL,'2015-12-13 18:25:39'),(162,'AssignmentQuestionnaire',37,'create','1',NULL,'2015-12-13 18:25:46'),(163,'AssignmentQuestionnaire',38,'create','1',NULL,'2015-12-13 18:25:46'),(164,'AssignmentQuestionnaire',39,'create','1',NULL,'2015-12-13 18:25:47'),(165,'AssignmentQuestionnaire',40,'create','1',NULL,'2015-12-13 18:25:47'),(166,'AssignmentQuestionnaire',41,'create','1',NULL,'2015-12-13 18:25:49'),(167,'AssignmentQuestionnaire',42,'create','1',NULL,'2015-12-13 18:25:49'),(168,'AssignmentQuestionnaire',43,'create','1',NULL,'2015-12-13 18:25:51'),(169,'AssignmentQuestionnaire',44,'create','1',NULL,'2015-12-13 18:25:51'),(170,'AssignmentQuestionnaire',45,'create','1',NULL,'2015-12-13 18:26:04'),(171,'AssignmentQuestionnaire',46,'create','1',NULL,'2015-12-13 18:26:04'),(172,'AssignmentQuestionnaire',47,'create','1',NULL,'2015-12-13 18:26:13'),(173,'AssignmentQuestionnaire',48,'create','1',NULL,'2015-12-13 18:26:13'),(174,'Participant',7,'create','1',NULL,'2015-12-13 18:26:54'),(175,'Participant',8,'create','1',NULL,'2015-12-13 18:27:04'),(176,'Participant',9,'create','1',NULL,'2015-12-13 18:27:15'),(177,'Team',4,'create','3',NULL,'2015-12-13 18:28:15'),(178,'Node',42,'create','3',NULL,'2015-12-13 18:28:15'),(179,'TeamsUser',6,'create','3',NULL,'2015-12-13 18:28:15'),(180,'Node',43,'create','3',NULL,'2015-12-13 18:28:15'),(181,'Participant',8,'update','3','---\nid: 8\ncan_submit: true\ncan_review: true\nuser_id: 3\nparent_id: 2\ndirectory_num: \nsubmitted_at: \npermission_granted: false\npenalty_accumulated: 0\nsubmitted_hyperlinks: \ngrade: \ntype: AssignmentParticipant\nhandle: student2\ntime_stamp: \ndigital_signature: \nduty: \ncan_take_quiz: true\n','2015-12-13 18:28:24'),(182,'Team',5,'create','2',NULL,'2015-12-13 18:29:03'),(183,'Node',44,'create','2',NULL,'2015-12-13 18:29:04'),(184,'TeamsUser',7,'create','2',NULL,'2015-12-13 18:29:04'),(185,'Node',45,'create','2',NULL,'2015-12-13 18:29:04'),(186,'Participant',7,'update','2','---\nid: 7\ncan_submit: true\ncan_review: true\nuser_id: 2\nparent_id: 2\ndirectory_num: \nsubmitted_at: \npermission_granted: false\npenalty_accumulated: 0\nsubmitted_hyperlinks: \ngrade: \ntype: AssignmentParticipant\nhandle: student1\ntime_stamp: \ndigital_signature: \nduty: \ncan_take_quiz: true\n','2015-12-13 18:29:14'),(187,'AssignmentQuestionnaire',49,'create','1',NULL,'2015-12-13 18:32:31'),(188,'AssignmentQuestionnaire',50,'create','1',NULL,'2015-12-13 18:32:31'),(189,'Assignment',2,'update','1','---\nid: 2\ncreated_at: 2015-12-13 18:24:38.000000000 Z\nupdated_at: 2015-12-13 18:25:01.000000000 Z\nname: Assignment2\ndirectory_path: \"/bin\"\nsubmitter_count: 0\ncourse_id: 1\ninstructor_id: 1\nprivate: false\nnum_reviews: 0\nnum_review_of_reviews: 0\nnum_review_of_reviewers: 0\nreview_questionnaire_id: \nreview_of_review_questionnaire_id: \nteammate_review_questionnaire_id: \nreviews_visible_to_all: false\nwiki_type_id: 1\nnum_reviewers: 0\nspec_location: www.google.com\nauthor_feedback_questionnaire_id: \nmax_team_size: 1\nstaggered_deadline: false\nallow_suggestions: false\ndays_between_submissions: \nreview_assignment_strategy: Auto-Selected\nmax_reviews_per_submission: \nreview_topic_threshold: 0\ncopy_flag: false\nrounds_of_reviews: 1\nmicrotask: false\nselfreview_questionnaire_id: \nmanagerreview_questionnaire_id: \nreaderreview_questionnaire_id: \nrequire_quiz: false\nnum_quiz_questions: 0\nis_coding_assignment: false\nis_intelligent: false\ncalculate_penalty: false\nlate_policy_id: \nis_penalty_calculated: false\nmax_bids: \nshow_teammate_reviews: false\navailability_flag: true\nuse_bookmark: false\ncan_review_same_topic: false\ncan_choose_topic_to_review: false\n','2015-12-13 18:32:41'),(190,'AssignmentQuestionnaire',51,'create','1',NULL,'2015-12-13 18:32:41'),(191,'AssignmentQuestionnaire',52,'create','1',NULL,'2015-12-13 18:32:41');
/*!40000 ALTER TABLE `versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wiki_types`
--

DROP TABLE IF EXISTS `wiki_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wiki_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wiki_types`
--

LOCK TABLES `wiki_types` WRITE;
/*!40000 ALTER TABLE `wiki_types` DISABLE KEYS */;
INSERT INTO `wiki_types` VALUES (1,'No'),(2,'No'),(3,'No');
/*!40000 ALTER TABLE `wiki_types` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-12-13 13:33:22
