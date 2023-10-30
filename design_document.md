# Design guidelines for Expertiza

This document provides the common design features to be followed while developing or refactoring views in the Expertiza environment.

## Icon Library

Icons are available in 4 sizes : 16, 24, 32, 48. It is possibility that we might not have all sizes for all icons. Edit the number as per size chose, everything else will remain same.

**Sr. No.** | **Element Name** | **Image** | **Guide**	
|---|---|---|---|
|  1 |  Add assignment | ![Add Assignment](app/assets/images/tree_view/image4.png)  | To add 'add assignment' icon, use path **```/assets/tree_view/add-assignment-24.png```** |
|  2 |  Add Teaching assistant | ![Add TA](app/assets/images/tree_view/add-ta-24.png)  | To add 'add TA' icon, use path **```/assets/tree_view/add-ta-24.png```** |
|  3 |  Add Private | ![Add Private](app/assets/images/tree_view/add-private-24.png)  | To add 'add private' icon, use path **```/assets/tree_view/add-private-24.png```** |
|  4 |  Add Public | ![Add Public](app/assets/images/tree_view/add-public-24.png)  | To add 'add public' icon, use path **```/assets/tree_view/add-public-24.png```** |
|  5 |  Add Signup Sheet | ![Add Signup sheet](app/assets/images/tree_view/add-signup-sheet-24.png)  | To add 'add signup sheet' icon, use path **```/assets/tree_view/add-signup-sheet-24.png```** |
|  6 |  Assign Course Blue | ![Assign Course Blue](app/assets/images/tree_view/add-course-blue-24.png)  | To add 'Assign Course Blue' icon, use path **```/assets/tree_view/add-course-blue-24.png```** |
|  7 |  Assign Course Green | ![Assign Course Green](app/assets/images/tree_view/add-course-green-24.png)  | To add 'Assign Course Green' icon, use path **```/assets/tree_view/add-course-green-24.png```** |
|  8 |  Assign survey to | ![Assign survey to](app/assets/images/tree_view/assign-survey-24.png)  | To add 'Assign survey to' icon, use path **```/assets/tree_view/assign-survey-24.png```** |
|  9 |  Copy | ![Copy](app/assets/images/tree_view/Copy-icon-24.png)  | To add "Copy" icon, use path **```/assets/tree_view/Copy-icon-24.png```** |
|  10 |  Create Team | ![Create Team](app/assets/images/tree_view/create-teams-24.png)  | To add 'Create Team' icon, use path **```/assets/tree_view/create-teams-24.png```** |
|  11 |  Delete | ![Delete](app/assets/images/tree_view/delete-icon-24.png)  | To add "Delete" icon, use path **```/assets/tree_view/delete-icon-24.png```** |
|  12 |  (General) Edit | ![Edit](app/assets/images/tree_view/edit-icon-24.png)  | To add "Edit" icon, use path **```/assets/tree_view/edit-icon-24.png```** |
|  13 |  Edit Signup sheet | ![Edit Signup sheet](app/assets/images/tree_view/edit-signup-sheet-24.png)  | To add "Edit Signup sheet" icon, use path **```/assets/tree_view/edit-signup-sheet-24.png```** |
|  14 |  List All | ![List All](app/assets/images/tree_view/image8.png)  | To add "List All" icon, add class as "glyphicon glyphicon-list-alt" |
|  15 |  List Submissions | ![List Submissions](app/assets/images/tree_view/List-submisstions-24.png)  | To add "List Submissions" icon, use path **```/assets/tree_view/List-submisstions-24.png```** |
|  16 |  Make public from private | ![Make public from private](app/assets/images/tree_view/lock-off-disabled-icon-24.png)  | To add "Make public from private" icon,  use path **```/assets/tree_view/lock-off-disabled-icon-24.png```**   |
|  17 |  Private | ![Private](app/assets/images/tree_view/lock-disabled-icon-24.png)  | To add "Private" icon,  use path **```/assets/tree_view/lock-disabled-icon-24.png```**   |
|  18 |  Remove from Course | ![Remove from Course](app/assets/images/tree_view/remove-from-course-24.png)  | To add "Remove from Course" icon,  use path **```/assets/tree_view/remove-from-course-24.png```**   |
|  19 |  Run Lottery | ![Run Lottery](app/assets/images/tree_view/image27.png)  | To add "Run Lottery" icon,  use path **```/assets/tree_view/run-lottery.png```**   |
|  20 |  Search in data | ![Search in data](app/assets/images/tree_view/view-publish-rights-24.png)  | To add "Search in data" icon,  use path **```/assets/tree_view/view-publish-rights-24.png```**   |
|  21 |  View Review Report | ![View Review Report](app/assets/images/tree_view/view-review-report-24.png)  | To add "View Review Report " icon,  use path **```/assets/tree_view/view-review-report-24.png```**   |
|  22 |  View Scores | ![View Scores](app/assets/images/tree_view/view-scores-24.png)  | To add "View Score" icon,  use path **```/assets/tree_view/view-scores-24.png```**   |
|  23 |  View Suggestions | ![View Suggestions](app/assets/images/tree_view/view-suggestion-24.png)  | To add "View Suggestions" icon,  use path **```/assets/tree_view/view-suggestion-24.png```**   |
|  24 |  View Survey | ![View Survey](app/assets/images/tree_view/view-survey-24.png)  | To add "View Survey" icon,  use path **```/assets/tree_view/view-survey-24.png```**   |

---

## Buttons : 

**Sr. No.** | **Element Name** | **Image** | **Guide** | **Class**	
|---|---|---|---|---|
|  1 |  Button - Default style | *to be added*  | Default button | ```btn btn-default btn-md``` |
|  2 |  Button - Success style | *to be added*  | For accepting. | ```btn btn-success btn-md``` |
|  3 |  Button - Danger style | *to be added*  | For rejecting. | ```btn btn-danger btn-md``` |
|  4 |  Button - New style | *to be added*  | For create buttons alone. | ```btn btn-primary pull-right new-button btn-md``` |

---

## Tables :

For the tables, we recommend using bootstrap table class to make tables looks unified. We already include bootstrap reference, feel free to reference that table styles. For react.js tables, we can still use [react-bootstrap-table](http://allenfang.github.io/react-bootstrap-table/) to make tables unified.

The class to be used in a table tag is ```table table-striped```.

---

## Notifications :

**Sr. No.** | **Element Name** | **Image** | **Guide**	
|---|---|---|---|
|  1 |  Success | *to be added*  | For notification, add class as ```flash_note alert alert-success``` |
|  2 |  Error | *to be added*  | For notification, add class as ```flash_note alert alert-danger``` |
|  3 |  Info | *to be added*  | For notification, add class as ```flash_note alert alert-info``` |
|  3 |  Warn | *to be added*  | For notification, add class as ```flash_note alert alert-warning``` |

---

## Text :

* General Font name: ```verdana,arial,helvetica,sans-serif```

* Headings
Headings/ Main title of page should be given in ```<h2>Title</h2>``` tag

* Font Size	
	- font size of 13 px 
	- line height 30px 
	- (will be automatically applied)
* Content Headings ```<h2>Title</h2>```
* Content Subheadings
	- font size of 1.2 em 
	- line height 18px 
	- (will be automatically applied)
* Table data
	- font size of 15 px
	- line height 1.428 em
	- (will be applied autamatically)

* Color
	- Menu bar - #FFFFFF; //for menubar with red background
	- Other titles/ text - #333; (it will be applied automatically)
	- Text on red buttons - #fff;

## Forms :

All form elements must have the class ```form-control```

If it is a online form (an input with a submit button), the form must be given a class ```form-inline```. And appropriate width must be added to that element to make it uniform with the page.


## Dropdowns and Toggling dropdowns :
