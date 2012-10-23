--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: 
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: content_pages; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE content_pages (
    id serial NOT NULL,
    title character varying(255),
    name character varying(255) NOT NULL,
    markup_style_id integer,
    content text,
    permission_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: content_pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('content_pages', 'id'), 10, true);


--
-- Name: controller_actions; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE controller_actions (
    id serial NOT NULL,
    site_controller_id integer NOT NULL,
    name character varying(255) NOT NULL,
    permission_id integer
);


--
-- Name: controller_actions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('controller_actions', 'id'), 15, true);


--
-- Name: markup_styles; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE markup_styles (
    id serial NOT NULL,
    name character varying(255)
);


--
-- Name: markup_styles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('markup_styles', 'id'), 2, true);


--
-- Name: menu_items; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE menu_items (
    id serial NOT NULL,
    parent_id integer,
    name character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    seq integer,
    controller_action_id integer,
    content_page_id integer
);


--
-- Name: menu_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('menu_items', 'id'), 14, true);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE permissions (
    id serial NOT NULL,
    name character varying(255)
);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('permissions', 'id'), 5, true);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE roles (
    id serial NOT NULL,
    name character varying(255),
    parent_id integer,
    description character varying(1024),
    default_page_id integer,
    "cache" text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('roles', 'id'), 3, true);


--
-- Name: roles_permissions; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE roles_permissions (
    id serial NOT NULL,
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: roles_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('roles_permissions', 'id'), 10, true);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE sessions (
    id serial NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('sessions', 'id'), 1, false);


--
-- Name: site_controllers; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE site_controllers (
    id serial NOT NULL,
    name character varying(255) NOT NULL,
    permission_id integer NOT NULL,
    builtin integer
);


--
-- Name: site_controllers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('site_controllers', 'id'), 11, true);


--
-- Name: system_settings; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE system_settings (
    id serial NOT NULL,
    site_name character varying(255) NOT NULL,
    site_subtitle character varying(255),
    footer_message character varying(255),
    public_role_id integer NOT NULL,
    session_timeout integer NOT NULL,
    default_markup_style_id integer NOT NULL,
    site_default_page_id integer NOT NULL,
    not_found_page_id integer NOT NULL,
    permission_denied_page_id integer NOT NULL,
    session_expired_page_id integer NOT NULL,
    menu_depth integer NOT NULL
);


--
-- Name: system_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('system_settings', 'id'), 1, true);


--
-- Name: users; Type: TABLE; Schema: public; Owner: david; Tablespace: 
--

CREATE TABLE users (
    id serial NOT NULL,
    name character varying(255) NOT NULL,
    "password" character varying(40) NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: david
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('users', 'id'), 2, true);


--
-- Name: view_controller_actions; Type: VIEW; Schema: public; Owner: david
--

CREATE VIEW view_controller_actions AS
    SELECT controller_actions.id, site_controllers.id AS site_controller_id, site_controllers.name AS site_controller_name, controller_actions.name, COALESCE(controller_actions.permission_id, site_controllers.permission_id) AS permission_id FROM (site_controllers JOIN controller_actions ON ((site_controllers.id = controller_actions.site_controller_id)));


--
-- Name: view_menu_items; Type: VIEW; Schema: public; Owner: david
--

CREATE VIEW view_menu_items AS
    SELECT menu_items.id AS menu_item_id, menu_items.name AS menu_item_name, menu_items.label AS menu_item_label, menu_items.seq AS menu_item_seq, menu_items.parent_id AS menu_item_parent_id, view_controller_actions.site_controller_id, view_controller_actions.site_controller_name, view_controller_actions.id AS controller_action_id, view_controller_actions.name AS controller_action_name, content_pages.id AS content_page_id, content_pages.name AS content_page_name, content_pages.title AS content_page_title, permissions.id AS permission_id, permissions.name AS permission_name FROM ((((menu_items LEFT JOIN view_controller_actions ON ((menu_items.controller_action_id = view_controller_actions.id))) LEFT JOIN content_pages ON (((menu_items.content_page_id = content_pages.id) AND (menu_items.controller_action_id IS NULL)))) LEFT JOIN markup_styles ON ((content_pages.markup_style_id = markup_styles.id))) JOIN permissions ON ((COALESCE(view_controller_actions.permission_id, content_pages.permission_id) = permissions.id)));


--
-- Data for Name: content_pages; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO content_pages (id, title, name, markup_style_id, content, permission_id, created_at, updated_at) VALUES (1, 'Home Page', 'home', 1, 'h1. Welcome to Goldberg!

Looks like you have succeeded in getting Goldberg up and running.  Now you will probably want to customise your site.

*Very important:* The default login for the administrator is "admin", password "admin".  You must change that before you make your site public!

h2. Administering the Site

At the login prompt, enter an administrator username and password.  The top menu should change: a new item called "Administration" will appear.  Go there for further details.


', 3, '2006-06-12 00:31:56', '2006-10-01 23:43:39');
INSERT INTO content_pages (id, title, name, markup_style_id, content, permission_id, created_at, updated_at) VALUES (2, 'Session Expired', 'expired', 1, 'h1. Session Expired

Your session has expired due to inactivity.

To continue please login again.

', 3, '2006-06-12 00:33:14', '2006-10-01 23:43:03');
INSERT INTO content_pages (id, title, name, markup_style_id, content, permission_id, created_at, updated_at) VALUES (3, 'Not Found!', 'notfound', 1, 'h1. Not Found

The page you requested was not found!

Please contact your system administrator.', 3, '2006-06-12 00:33:49', '2006-10-01 23:44:55');
INSERT INTO content_pages (id, title, name, markup_style_id, content, permission_id, created_at, updated_at) VALUES (4, 'Permission Denied!', 'denied', 1, 'h1. Permission Denied

Sorry, but you don''t have permission to view that page.

Please contact your system administrator.', 3, '2006-06-12 00:34:30', '2006-10-01 23:41:24');
INSERT INTO content_pages (id, title, name, markup_style_id, content, permission_id, created_at, updated_at) VALUES (6, 'Contact Us', 'contact_us', 1, 'h1. Contact Us

Visit the Goldberg Project Homepage at "http://goldberg.rubyforge.org":http://goldberg.rubyforge.org for further information on Goldberg.  Visit the Goldberg RubyForge Project Info Page at "http://rubyforge.org/projects/goldberg":http://rubyforge.org/projects/goldberg to access the project''s files and development information.
', 3, '2006-06-12 10:13:47', '2006-10-02 14:01:19');
INSERT INTO content_pages (id, title, name, markup_style_id, content, permission_id, created_at, updated_at) VALUES (8, 'Site Administration', 'site_admin', 1, 'h1. Goldberg Setup

This is where you will find all the Goldberg-specific administration and configuration features.  In here you can:

* Set up Users.

* Manage Roles and their Permissions.

* Set up any Controllers and their Actions for your application.

* Edit the Content Pages of the site.

* Adjust Goldberg''s system settings.


h2. Users

You can set up Users with a username, password and a Role.


h2. Roles and Permissions

A User''s Permissions affect what Actions they can perform and what Pages they can see.  And because each Menu Item is based either on a Page or an Action, the Permissions determine what Menu Items the User can and cannot see.

A Role is a set of Permissions.  Roles are assigned to Users.  Roles are hierarchical: a Role can have a parent Role; and if so it will inherit the Permissions of the parent Role, and all its parents.


h2. Controllers and Actions

To execute any Action, a user must have the appropriate Permission.  Therefore all Controllers and Actions you set up for your Rails application need to be entered here, otherwise no user will be able to execute them.

You start by setting up the Controller and assigning it a Permission.  The Permission will be used as the default for any Actions invoked for that Controller.

You have the option of setting up specific Actions for the Controllers.  You would want to do that if the Action were to appear as a Menu Item, or if it were to have a different level of security to the default for the Controller.


h2. Content Pages

Goldberg has a very simple CMS built in.  You can create pages to be displayed on the site, possibly in menu items.


h2. Menu Editor

Once you have set up your Controller Actions and Content Pages, you can put them into the site''s menu using the Menu Editor.

In the Menu Editor you can add and remove Menu Items and move them around.  The security of a Menu Item (whether the user can see it or not) depends on the Permission of the Action or Page attached to that Menu Item.

h2. System Settings

Go here to view and edit the settings that determine how Goldberg operates.
', 1, '2006-06-21 21:32:35', '2006-10-01 23:46:01');
INSERT INTO content_pages (id, title, name, markup_style_id, content, permission_id, created_at, updated_at) VALUES (9, 'Administration', 'admin', 1, 'h1. Site Administration

This is where the administrator can set up the site.

There is one menu item here by default -- "Setup":/menu/setup.  That contains all the Goldberg configuration options.

You can add more menu items here to administer your application if you want, by going to "Setup, Menu Editor":/menu/setup/menus.
', 1, '2006-06-26 16:47:09', '2006-10-01 23:38:20');
INSERT INTO content_pages (id, title, name, markup_style_id, content, permission_id, created_at, updated_at) VALUES (10, 'Credits and Licence', 'credits', 1, 'h1. Credits and Licence

Goldberg contains original material and third party material from various sources.

All original material is (p) Public Domain, No Rights Reserved.  Goldberg comes with no warranty whatsoever.

The copyright for any third party material remains with the original author, and the material is distributed here under the original terms.  

Material has been selected from sources with licensing terms and conditions that allow use and redistribution for both personal and business purposes.  These licences include public domain, BSD-style licences, and Creative Commons licences (but *not* Creative Commons Non-Commercial).

If you are an author and you believe your copyrighted material has been included in Goldberg in breach of your licensing terms and conditions, please contact Dave Nelson (urbanus at 240gl dot org).


h2. Layouts

Goldberg comes with a choice of layouts, adapted from various sources.

h3. The Default

The default layout is a modified version of Andreas09 by Anreas Viklund.  Andreas09 is distributed under free/unlicensed terms, with an informal request that credit be given to the original author.  The original template can be obtained from "Open Source Web Design":http://www.oswd.org/design/preview/id/2493/.

Author''s website: "andreasviklund.com":http://andreasviklund.com/.


h3. "Earth Wind and Fire"

Originally designed by Brett Hillesheim (brett7481 at msn dot com) and distributed under free terms (from the MadSeason website: "Every template we create is completely open source, meaning you can take it and do whatever you want with it").  The original template can be obtained from "Open Source Web Design":http://www.oswd.org/design/preview/id/2453/.

Author''s website: "www.madseason.co.uk":http://www.madseason.co.uk/.


h3. "Snooker"

"Snooker" is an original design and is therefore Public Domain.  It incorporates dynamic two-column layout techniques described on the "A List Apart":http://alistapart.com/articles/negativemargins website.


h3. "Spoiled Brat"

Originally designed by "Rayk Web Design":http://www.raykdesign.net/ and distributed under the terms of the "Creative Commons Attribution Share Alike":http://creativecommons.org/licenses/by-sa/2.5/legalcode licence.  The original template can be obtained from "Open Web Design":http://www.openwebdesign.org/viewdesign.phtml?id=2894/.

Author''s website: "www.csstinderbox.com":http://www.csstinderbox.com/.


h2. Other Features

Goldberg also contains some miscellaneous code and techniques from other sources.

h3. Suckerfish Menus

The three templates "Earth Wind and Fire", "Snooker" and "Spoiled Brat" have all been configured to use Suckerfish menus.  This technique of using a combination of CSS and Javascript to implement dynamic menus was first described by "A List Apart":http://www.alistapart.com/articles/dropdowns/.  Goldberg''s implementation also incorporates techniques described by "HTMLDog":http://www.htmldog.com/articles/suckerfish/dropdowns/.

h3. Tabbed Panels

Goldberg''s implementation of tabbed panels was adapted from 
"InternetConnection":http://support.internetconnection.net/CODE_LIBRARY/Javascript_Show_Hide.shtml.

', 3, '2006-10-02 10:35:35', '2006-10-02 13:59:02');


--
-- Data for Name: controller_actions; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (1, 1, 'view_default', 3);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (2, 1, 'view', 3);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (3, 7, 'list', NULL);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (4, 6, 'list', NULL);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (5, 3, 'login', 4);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (6, 3, 'logout', 4);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (7, 5, 'link', 4);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (8, 1, 'list', NULL);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (9, 8, 'list', NULL);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (10, 2, 'list', NULL);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (11, 5, 'list', NULL);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (12, 9, 'list', NULL);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (13, 3, 'forgotten', 4);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (14, 3, 'login_failed', 4);
INSERT INTO controller_actions (id, site_controller_id, name, permission_id) VALUES (15, 10, 'list', NULL);


--
-- Data for Name: markup_styles; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO markup_styles (id, name) VALUES (1, 'Textile');
INSERT INTO markup_styles (id, name) VALUES (2, 'Markdown');


--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (1, NULL, 'home', 'Home', 1, NULL, 1);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (2, NULL, 'contact_us', 'Contact Us', 3, NULL, 6);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (3, NULL, 'admin', 'Administration', 2, NULL, 9);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (5, 9, 'setup/permissions', 'Permissions', 3, 4, NULL);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (6, 9, 'setup/roles', 'Roles', 2, 3, NULL);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (7, 9, 'setup/pages', 'Content Pages', 5, 8, NULL);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (8, 9, 'setup/controllers', 'Controllers / Actions', 4, 9, NULL);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (9, 3, 'setup', 'Setup', 1, NULL, 8);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (11, 9, 'setup/menus', 'Menu Editor', 6, 11, NULL);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (12, 9, 'setup/system_settings', 'System Settings', 7, 12, NULL);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (13, 9, 'setup/users', 'Users', 1, 15, NULL);
INSERT INTO menu_items (id, parent_id, name, label, seq, controller_action_id, content_page_id) VALUES (14, 2, 'credits', 'Credits &amp; Licence', 1, NULL, 10);


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO permissions (id, name) VALUES (1, 'Administer site');
INSERT INTO permissions (id, name) VALUES (2, 'Public pages - edit');
INSERT INTO permissions (id, name) VALUES (3, 'Public pages - view');
INSERT INTO permissions (id, name) VALUES (4, 'Public actions - execute');
INSERT INTO permissions (id, name) VALUES (5, 'Members only page -- view');


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO roles (id, name, parent_id, description, default_page_id, "cache", created_at, updated_at) VALUES (1, 'Public', NULL, 'Members of the public who are not logged in.', NULL, NULL, '2006-06-23 21:03:49', '2006-10-02 14:13:10');
INSERT INTO roles (id, name, parent_id, description, default_page_id, "cache", created_at, updated_at) VALUES (2, 'Member', 1, '', NULL, NULL, '2006-06-23 21:03:50', '2006-10-02 14:13:10');
INSERT INTO roles (id, name, parent_id, description, default_page_id, "cache", created_at, updated_at) VALUES (3, 'Administrator', 2, '', 8, NULL, '2006-06-23 21:03:48', '2006-10-02 14:13:10');


--
-- Data for Name: roles_permissions; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO roles_permissions (id, role_id, permission_id) VALUES (4, 3, 1);
INSERT INTO roles_permissions (id, role_id, permission_id) VALUES (6, 1, 3);
INSERT INTO roles_permissions (id, role_id, permission_id) VALUES (7, 3, 2);
INSERT INTO roles_permissions (id, role_id, permission_id) VALUES (9, 1, 4);
INSERT INTO roles_permissions (id, role_id, permission_id) VALUES (10, 2, 5);


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: david
--



--
-- Data for Name: site_controllers; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (1, 'content_pages', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (2, 'controller_actions', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (3, 'auth', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (4, 'markup_styles', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (5, 'menu_items', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (6, 'permissions', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (7, 'roles', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (8, 'site_controllers', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (9, 'system_settings', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (10, 'users', 1, 1);
INSERT INTO site_controllers (id, name, permission_id, builtin) VALUES (11, 'roles_permissions', 1, 1);


--
-- Data for Name: system_settings; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO system_settings (id, site_name, site_subtitle, footer_message, public_role_id, session_timeout, default_markup_style_id, site_default_page_id, not_found_page_id, permission_denied_page_id, session_expired_page_id, menu_depth) VALUES (1, 'Goldberg', 'A website development tool for Ruby on Rails', 'A <a href="http://goldberg.rubyforge.org">Goldberg</a> site', 1, 7200, 1, 1, 3, 4, 2, 3);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: david
--

INSERT INTO users (id, name, "password", role_id) VALUES (2, 'admin', 'd033e22ae348aeb5660fc2140aec35850c4da997', 3);


--
-- Name: content_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY content_pages
    ADD CONSTRAINT content_pages_pkey PRIMARY KEY (id);


--
-- Name: controller_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY controller_actions
    ADD CONSTRAINT controller_actions_pkey PRIMARY KEY (id);


--
-- Name: markup_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY markup_styles
    ADD CONSTRAINT markup_styles_pkey PRIMARY KEY (id);


--
-- Name: menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: roles_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY roles_permissions
    ADD CONSTRAINT roles_permissions_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: site_controllers_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY site_controllers
    ADD CONSTRAINT site_controllers_pkey PRIMARY KEY (id);


--
-- Name: system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: david; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: roles_permissions_permission_fkey; Type: FK CONSTRAINT; Schema: public; Owner: david
--

ALTER TABLE ONLY roles_permissions
    ADD CONSTRAINT roles_permissions_permission_fkey FOREIGN KEY (permission_id) REFERENCES permissions(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: roles_permissions_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: david
--

ALTER TABLE ONLY roles_permissions
    ADD CONSTRAINT roles_permissions_role_fkey FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

