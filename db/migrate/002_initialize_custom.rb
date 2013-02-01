class InitializeCustom < ActiveRecord::Migration
  def self.up
  create_table "permissions", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
  end
  execute "INSERT INTO `permissions` VALUES (1,'Administer Goldberg')"
  execute "INSERT INTO `permissions` VALUES (3,'Public pages - view')"
  execute "INSERT INTO `permissions` VALUES (4,'Public actions - execute')"
  execute "INSERT INTO `permissions` VALUES (6,'Administer PG')"
  execute "INSERT INTO `permissions` VALUES (7,'Administer assignments')"
  execute "INSERT INTO `permissions` VALUES (8,'Do assignments')"
  execute "INSERT INTO `permissions` VALUES (9,'Administer instructors')"
  
  create_table "markup_styles", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
  end    
    
  execute "INSERT INTO `markup_styles` VALUES (1,'Textile'),(2,'Markdown');"

  create_table "content_pages", :force => true do |t|
    t.column "title", :string
    t.column "name", :string, :default => "", :null => false
    t.column "markup_style_id", :integer
    t.column "content", :text
    t.column "permission_id", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "content_cache", :text
  end

  add_index "content_pages", ["permission_id"], :name => "fk_content_page_permission_id"
  add_index "content_pages", ["markup_style_id"], :name => "fk_content_page_markup_style_id"

  execute "INSERT INTO `content_pages` VALUES (1,'Home Page','home',1,'<h1>Welcome to Expertiza</h1> <p> The Expertiza project is system for using peer review to create reusable learning objects.  Students do different assignments; then peer review selects the best work in each category, and assembles it to create a single unit.</p>',3,'2006-06-12 00:31:56','2007-02-23 10:17:45','<h1>Welcome to Expertiza</h1> <p> The Expertiza project is system for using peer review to create reusable learning objects.  Students do different assignments; then peer review selects the best work in each category, and assembles it to create a single unit.</p>');"
  execute "INSERT INTO `content_pages` VALUES (2,'Session Expired','expired',1,'h1. Session Expired\n\nYour session has expired due to inactivity.\n\nTo continue please login again.\n',3,'2006-06-12 00:33:14','2007-02-23 10:17:45','<h1>Session Expired</h1>\n\n\n  <p>Your session has expired due to inactivity.</p>\n\n\n  <p>To continue please login again.</p>');"
  execute "INSERT INTO `content_pages` VALUES (3,'Not Found!','notfound',1,'h1. Not Found\n\nThe page you requested was not found!\n\nPlease contact your system administrator.',3,'2006-06-12 00:33:49','2007-02-23 10:17:45','<h1>Not Found</h1>\n\n\n  <p>The page you requested was not found!</p>\n\n\n  <p>Please contact your system administrator.</p>');"
  execute "INSERT INTO `content_pages` VALUES (4,'Permission Denied!','denied',1,'h1. Permission Denied\n\nSorry, but you don''t have permission to view that page.\n\nPlease contact your system administrator.',3,'2006-06-12 00:34:30','2007-02-23 10:17:45','<h1>Permission Denied</h1>\n\n\n <p>Sorry, but you don&#8217;t have permission to view that page.</p>\n\n\n  <p>Please contact your system administrator.</p>');"
  execute "INSERT INTO `content_pages` VALUES (6,'Contact Us','contact_us',1,'h1. Contact Us\n\nVisit the Goldberg Project Homepage at \"http://goldberg.rubyforge.org\":http://goldberg.rubyforge.org for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at \"http://rubyforge.org/projects/goldberg\":http://rubyforge.org/projects/goldberg to access the project''s files and development information.\n',3,'2006-06-12 10:13:47','2007-02-23 10:17:46','<h1>Contact Us</h1>\n\n\n  <p>Visit the Goldberg Project Homepage at <a href=\"http://goldberg.rubyforge.org\">http://goldberg.rubyforge.org</a> for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at <a href=\"http://rubyforge.org/projects/goldberg\">http://rubyforge.org/projects/goldberg</a> to access the project&#8217;s files and development information.</p>');"
  execute "INSERT INTO `content_pages` VALUES (8,'Site Administration','site_admin',1,'h1. Goldberg Setup\n\nThis is where you will find all the Goldberg-specific administration and configuration features.  In here you can:\n\n* Set up Users.\n\n* Manage Roles and their Permissions.\n\n* Set up any Controllers and their Actions for your application.\n\n* Edit the Content Pages of the site.\n\n* Adjust Goldberg''s system settings.\n\n\nh2. Users\n\nYou can set up Users with a username, password and a Role.\n\n\nh2. Roles and Permissions\n\nA User''s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.\n\nA Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.\n\n\nh2. Controllers and Actions\n\nTo execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.\n\nYou start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.\n\nYou have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.\n\n\nh2. Content Pages\n\nGoldberg has a very simple CMS built in.  You can create pages to be displayed on the site, possibly in menu items.\n\n\nh2. Menu Editor\n\nOnce you have set up your Controller Actions and Content Pages, you can put them into the site''s menu using the Menu Editor.\n\nIn the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.\n\nh2. System Settings\n\nGo here to view and edit the settings that determine how Goldberg operates.\n',1,'2006-06-21 21:32:35','2007-02-23 10:17:46','<h1>Goldberg Setup</h1>\n\n\n <p>This is where you will find all the Goldberg-specific administration and configuration features.  In here you can:</p>\n\n\n <ul>\n  <li>Set up Users.</li>\n  </ul>\n\n\n <ul>\n  <li>Manage Roles and their Permissions.</li>\n  </ul>\n\n\n <ul>\n  <li>Set up any Controllers and their Actions for your application.</li>\n </ul>\n\n\n <ul>\n  <li>Edit the Content Pages of the site.</li>\n  </ul>\n\n\n <ul>\n  <li>Adjust Goldberg&#8217;s system settings.</li>\n </ul>\n\n\n <h2>Users</h2>\n\n\n  <p>You can set up Users with a username, password and a Role.</p>\n\n\n <h2>Roles and Permissions</h2>\n\n\n  <p>A User&#8217;s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.</p>\n\n\n  <p>A Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.</p>\n\n\n <h2>Controllers and Actions</h2>\n\n\n  <p>To execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.</p>\n\n\n  <p>You start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.</p>\n\n\n <p>You have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.</p>\n\n\n <h2>Content Pages</h2>\n\n\n  <p>Goldberg has a very simple <span class=\"caps\">CMS</span> built in.  You can create pages to be displayed on the site, possibly in menu items.</p>\n\n\n  <h2>Menu Editor</h2>\n\n\n  <p>Once you have set up your Controller Actions and Content Pages, you can put them into the site&#8217;s menu using the Menu Editor.</p>\n\n\n <p>In the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.</p>\n\n\n <h2>System Settings</h2>\n\n\n  <p>Go here to view and edit the settings that determine how Goldberg operates.</p>');"
  execute "INSERT INTO `content_pages` VALUES (9,'Administration','admin',1,'h1. Site Administration\n\nThis is where the administrator can set up the site.\n\nThere is one menu item here by default -- \"Setup\":/menu/setup.  That contains all the Goldberg configuration options.\n\nYou can add more menu items here to administer your application if you want, by going to \"Setup, Menu Editor\":/menu/setup/menus.\n',1,'2006-06-26 16:47:09','2007-02-23 10:17:46','<h1>Site Administration</h1>\n\n\n  <p>This is where the administrator can set up the site.</p>\n\n\n <p>There is one menu item here by default&#8212;<a href=\"/menu/setup\">Setup</a>.  That contains all the Goldberg configuration options.</p>\n\n\n <p>You can add more menu items here to administer your application if you want, by going to <a href=\"/menu/setup/menus\">Setup, Menu Editor</a>.</p>');"
  execute "INSERT INTO `content_pages` VALUES (10,'Credits and Licence','credits',1,'h1. Credits and Licence\n\nGoldberg contains original material and third party material from various sources.\n\nAll original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.\n\nThe copyright for any third party material remains with the original author, and the material is distributed here under the original terms.  \n\nMaterial has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, BSD-style licences, and Creative Commons licences (but *not* Creative Commons Non-Commercial).\n\nIf you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).\n\n\nh2. Layouts\n\nGoldberg comes with a choice of layouts, adapted from various sources.\n\nh3. The Default\n\nThe default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2493/.\n\nAuthor''s website: \"andreasviklund.com\":http://andreasviklund.com/.\n\n\nh3. \"Earth Wind and Fire\"\n\nOriginally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: \"Every template we create is completely open source, meaning you can take it and do whatever you want with it\").  The original template can be obtained from \"Open Source Web Design\":http://www.oswd.org/design/preview/id/2453/.\n\nAuthor''s website: \"www.madseason.co.uk\":http://www.madseason.co.uk/.\n\n\nh3. \"Snooker\"\n\n\"Snooker\" is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the \"A List Apart\":http://alistapart.com/articles/negativemargins website.\n\n\nh3. \"Spoiled Brat\"\n\nOriginally designed by \"Rayk Web Design\":http://www.raykdesign.net/ and distributed under the terms of the \"Creative Commons Attribution Share Alike\":http://creativecommons.org/licenses/by-sa/2.5/legalcode licence.  The original template can be obtained from \"Open Web Design\":http://www.openwebdesign.org/viewdesign.phtml?id=2894/.\n\nAuthor''s website: \"www.csstinderbox.com\":http://www.csstinderbox.com/.\n\n\nh2. Other Features\n\nGoldberg also contains some miscellaneous code and techniques from other sources.\n\nh3. Suckerfish Menus\n\nThe three templates \"Earth Wind and Fire\", \"Snooker\" and \"Spoiled Brat\" have all been configured to use Suckerfish menus.  This technique of using a combination of CSS and Javascript to implement dynamic menus was first described by \"A List Apart\":http://www.alistapart.com/articles/dropdowns/.  Goldberg''s implementation also incorporates techniques described by \"HTMLDog\":http://www.htmldog.com/articles/suckerfish/dropdowns/.\n\nh3. Tabbed Panels\n\nGoldberg''s implementation of tabbed panels was adapted from \n\"InternetConnection\":http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml.\n',3,'2006-10-02 10:35:35','2007-02-23 10:17:46','<h1>Credits and Licence</h1>\n\n\n  <p>Goldberg contains original material and third party material from various sources.</p>\n\n\n <p>All original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.</p>\n\n\n <p>The copyright for any third party material remains with the original author, and the material is distributed here under the original terms.</p>\n\n\n  <p>Material has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, <span class=\"caps\">BSD</span>-style licences, and Creative Commons licences (but <strong>not</strong> Creative Commons Non-Commercial).</p>\n\n\n  <p>If you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).</p>\n\n\n  <h2>Layouts</h2>\n\n\n  <p>Goldberg comes with a choice of layouts, adapted from various sources.</p>\n\n\n <h3>The Default</h3>\n\n\n  <p>The default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from <a href=\"http://www.oswd.org/design/preview/id/2493/\">Open Source Web Design</a>.</p>\n\n\n  <p>Author&#8217;s website: <a href=\"http://andreasviklund.com/\">andreasviklund.com</a>.</p>\n\n\n <h3>&#8220;Earth Wind and Fire&#8221;</h3>\n\n\n  <p>Originally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: &#8220;Every template we create is completely open source, meaning you can take it and do whatever you want with it&#8221;).  The original template can be obtained from <a href=\"http://www.oswd.org/design/preview/id/2453/\">Open Source Web Design</a>.</p>\n\n\n  <p>Author&#8217;s website: <a href=\"http://www.madseason.co.uk/\">www.madseason.co.uk</a>.</p>\n\n\n <h3>&#8220;Snooker&#8221;</h3>\n\n\n  <p>&#8220;Snooker&#8221; is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the <a href=\"http://alistapart.com/articles/negativemargins\">A List Apart</a> website.</p>\n\n\n  <h3>&#8220;Spoiled Brat&#8221;</h3>\n\n\n <p>Originally designed by <a href=\"http://www.raykdesign.net/\">Rayk Web Design</a> and distributed under the terms of the <a href=\"http://creativecommons.org/licenses/by-sa/2.5/legalcode\">Creative Commons Attribution Share Alike</a> licence.  The original template can be obtained from <a href=\"http://www.openwebdesign.org/viewdesign.phtml?id=2894/\">Open Web Design</a>.</p>\n\n\n <p>Author&#8217;s website: <a href=\"http://www.csstinderbox.com/\">www.csstinderbox.com</a>.</p>\n\n\n <h2>Other Features</h2>\n\n\n <p>Goldberg also contains some miscellaneous code and techniques from other sources.</p>\n\n\n  <h3>Suckerfish Menus</h3>\n\n\n <p>The three templates &#8220;Earth Wind and Fire&#8221;, &#8220;Snooker&#8221; and &#8220;Spoiled Brat&#8221; have all been configured to use Suckerfish menus.  This technique of using a combination of <span class=\"caps\">CSS</span> and Javascript to implement dynamic menus was first described by <a href=\"http://www.alistapart.com/articles/dropdowns/\">A List Apart</a>.  Goldberg&#8217;s implementation also incorporates techniques described by <a href=\"http://www.htmldog.com/articles/suckerfish/dropdowns/\">HTMLDog</a>.</p>\n\n\n <h3>Tabbed Panels</h3>\n\n\n  <p>Goldberg&#8217;s implementation of tabbed panels was adapted from \n<a href=\"http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml\">InternetConnection</a>.</p>');"
  
  create_table "site_controllers", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
    t.column "permission_id", :integer, :default => 0, :null => false
    t.column "builtin", :integer, :default => 0
  end

  add_index "site_controllers", ["permission_id"], :name => "fk_site_controller_permission_id"

  execute "INSERT INTO `site_controllers` VALUES (1,'content_pages',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (2,'controller_actions',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (3,'auth',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (4,'markup_styles',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (5,'menu_items',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (6,'permissions',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (7,'roles',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (8,'site_controllers',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (9,'system_settings',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (10,'users',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (11,'roles_permissions',1,1)"
  execute "INSERT INTO `site_controllers` VALUES (12,'admin',1,0)"
  execute "INSERT INTO `site_controllers` VALUES (13,'course',7,0)"
  execute "INSERT INTO `site_controllers` VALUES (14,'assignment',7,0)"
  execute "INSERT INTO `site_controllers` VALUES (15,'questionnaire',7,0)"
  execute "INSERT INTO `site_controllers` VALUES (16,'submission',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (17,'publishing',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (18,'review',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (19,'reviewing',7,0)"
  execute "INSERT INTO `site_controllers` VALUES (20,'participants',7,0)"
  execute "INSERT INTO `site_controllers` VALUES (21,'reports',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (22,'institution',6,0)"
  execute "INSERT INTO `site_controllers` VALUES (23,'student_assignment',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (24,'review_of_review',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (25,'review_feedback',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (26,'profile',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (27,'survey_response',4,0)"
  execute "INSERT INTO `site_controllers` VALUES (28,'team',7,0)"
  execute "INSERT INTO `site_controllers` VALUES (29,'teams_participants',7,0)"
 
  create_table "controller_actions", :force => true do |t|
    t.column "site_controller_id", :integer, :default => 0, :null => false
    t.column "name", :string, :default => "", :null => false
    t.column "permission_id", :integer
    t.column "url_to_use", :string
  end

  add_index "controller_actions", ["permission_id"], :name => "fk_controller_action_permission_id"
  add_index "controller_actions", ["site_controller_id"], :name => "fk_controller_action_site_controller_id"

  execute "INSERT INTO `controller_actions` VALUES (1,1,'view_default',3,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (2,1,'view',3,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (3,7,'list',NULL,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (4,6,'list',NULL,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (5,3,'login',4,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (6,3,'logout',4,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (7,5,'link',4,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (8,1,'list',NULL,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (9,8,'list',NULL,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (10,2,'list',NULL,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (11,5,'list',NULL,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (12,9,'list',NULL,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (13,3,'forgotten',4,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (14,3,'login_failed',4,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (15,10,'list',NULL,NULL)"
  execute "INSERT INTO `controller_actions` VALUES (16,12,'list_instructors',9,'')"
  execute "INSERT INTO `controller_actions` VALUES (17,12,'list_administrators',6,'')"
  execute "INSERT INTO `controller_actions` VALUES (18,12,'list_super_administrators',1,'')"
  execute "INSERT INTO `controller_actions` VALUES (19,13,'list_folders',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (20,14,'create',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (21,15,'list',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (22,15,'create_questionnaire',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (23,15,'edit_questionnaire',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (24,15,'copy_questionnaire',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (25,15,'save_questionnaire',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (26,20,'add_student',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (28,20,'edit_team_members',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (29,14,'new',7,''),(30,14,'list',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (31,20,'list_students',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (32,22,'list',6,'')"
  execute "INSERT INTO `controller_actions` VALUES (33,23,'list',8,'')"
  execute "INSERT INTO `controller_actions` VALUES (34,20,'list_courses',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (35,20,'list_assignments',7,'')"
  execute "INSERT INTO `controller_actions` VALUES (36,26,'edit',NULL,'')"
  execute "INSERT INTO `controller_actions` VALUES (37,27,'create',4,'')"
  execute "INSERT INTO `controller_actions` VALUES (38,27,'submit',NULL,'')"
  execute "INSERT INTO `controller_actions` VALUES (39,28,'list',NULL,'')"
  execute "INSERT INTO `controller_actions` VALUES (40,28,'list_assignments',NULL,'')"
  execute "INSERT INTO `controller_actions` VALUES (41,29,'list',NULL,'')"

  create_table "institutions", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
  end

  execute "INSERT INTO `institutions` VALUES (1,'North Carolina State University');"

  create_table "languages", :force => true do |t|
    t.column "name", :string, :limit => 32
  end

  create_table "menu_items", :force => true do |t|
    t.column "parent_id", :integer
    t.column "name", :string, :default => "", :null => false
    t.column "label", :string, :default => "", :null => false
    t.column "seq", :integer
    t.column "controller_action_id", :integer
    t.column "content_page_id", :integer
  end

  add_index "menu_items", ["controller_action_id"], :name => "fk_menu_item_controller_action_id"
  add_index "menu_items", ["content_page_id"], :name => "fk_menu_item_content_page_id"
  add_index "menu_items", ["parent_id"], :name => "fk_menu_item_parent_id"

  execute "INSERT INTO `menu_items` VALUES (1,NULL,'home','Home',1,NULL,1),(2,NULL,'contact_us','Contact Us',9,NULL,6),(3,NULL,'admin','Administration',2,NULL,9),(5,9,'setup/permissions','Permissions',3,4,NULL),(6,9,'setup/roles','Roles',2,3,NULL),(7,9,'setup/pages','Content Pages',5,8,NULL),(8,9,'setup/controllers','Controllers / Actions',4,9,NULL),(9,3,'setup','Setup',1,NULL,8),(11,9,'setup/menus','Menu Editor',6,11,NULL),(12,9,'setup/system_settings','System Settings',7,12,NULL),(13,9,'setup/users','Users',1,15,NULL),(14,2,'credits','Credits &amp; Licence',1,NULL,10),(15,3,'List Instructors','Instructors',3,16,NULL),(16,3,'List Administrators','Administrators',4,17,NULL),(17,3,'List Super-Administrators','Super-Administrators',5,18,NULL),(18,NULL,'Courses','Courses',3,19,NULL),(19,NULL,'assignments','Assignment Creation',4,30,NULL),(21,NULL,'participants','Participants',5,31,NULL),(22,3,'List Institutions','Institutions',2,32,NULL),(24,21,'List courses','Add participants to course',2,34,NULL),(25,21,'List assignments','Add participants to assignment',1,35,NULL),(26,NULL,'student_assignment','Assignments',7,33,NULL),(27,NULL,'profile','Profile',8,36,NULL),(28,21,'Create team','Create team',3,40,NULL),(29,NULL,'questionnaires','Questionnaires',6,21,NULL);"

    create_table "roles", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "parent_id", :integer
      t.column "description", :string, :default => "", :null => false
      t.column "default_page_id", :integer
      t.column "cache", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    add_index "roles", ["parent_id"], :name => "fk_role_parent_id"
    add_index "roles", ["default_page_id"], :name => "fk_role_default_page_id"
    
    role = Role.create(:name => "Student", :parent_id => nil)
    role = Role.create(:name => "Instructor", :parent_id => role.id)
    role = Role.create(:name => "Administrator", :parent_id => role.id)
    role = Role.create(:name => "Super-Administrator", :parent_id => role.id)
     
    create_table "roles_permissions", :force => true do |t|
      t.column "role_id", :integer, :default => 0, :null => false
      t.column "permission_id", :integer, :default => 0, :null => false
    end

  add_index "roles_permissions", ["role_id"], :name => "fk_roles_permission_role_id"
  add_index "roles_permissions", ["permission_id"], :name => "fk_roles_permission_permission_id"
  
  execute "INSERT INTO `roles_permissions` VALUES (6,1,3),(7,3,2),(9,1,4),(10,2,5),(11,4,6),(12,4,1),(14,2,7),(15,3,7),(16,4,7),(17,4,9),(18,1,8);"
    
  Role.rebuild_cache
  
  create_table "system_settings", :force => true do |t|
    t.column "site_name", :string, :default => "", :null => false
    t.column "site_subtitle", :string
    t.column "footer_message", :string, :default => ""
    t.column "public_role_id", :integer, :default => 0, :null => false
    t.column "session_timeout", :integer, :default => 0, :null => false
    t.column "default_markup_style_id", :integer, :default => 0
    t.column "site_default_page_id", :integer, :default => 0, :null => false
    t.column "not_found_page_id", :integer, :default => 0, :null => false
    t.column "permission_denied_page_id", :integer, :default => 0, :null => false
    t.column "session_expired_page_id", :integer, :default => 0, :null => false
    t.column "menu_depth", :integer, :default => 0, :null => false
  end

  add_index "system_settings", ["public_role_id"], :name => "fk_system_settings_public_role_id"
  add_index "system_settings", ["site_default_page_id"], :name => "fk_system_settings_site_default_page_id"
  add_index "system_settings", ["not_found_page_id"], :name => "fk_system_settings_not_found_page_id"
  add_index "system_settings", ["permission_denied_page_id"], :name => "fk_system_settings_permission_denied_page_id"
  add_index "system_settings", ["session_expired_page_id"], :name => "fk_system_settings_session_expired_page_id"
  
  execute "INSERT INTO `system_settings` VALUES (1,'Expertiza','Reusable learning objects through peer review','<a href=\"http://research.csc.ncsu.edu/efg/expertiza/papers\">Expertiza</a>',1,7200,1,1,3,4,2,3);" 

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.column "plugin_name", :string
    t.column "version", :integer
  end
  
  execute "INSERT INTO `plugin_schema_info` VALUES ('goldberg',3);"
       
       
  end

  def self.down
  drop_table "permissions"
  drop_table "markup_styles"
  drop_table "content_pages"
  drop_table "site_controllers"
  drop_table "controller_actions"
  drop_table "institutions"
  drop_table "languages"
  drop_table "roles"
  drop_table "roles_permissions"
  drop_table "system_settings"
  drop_table "plugin_schema_info"    
  end
end
