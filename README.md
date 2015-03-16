● Rename methods like ​get_scores and get_members​to follow ruby naming conventions. There are lot of methods which are prefixed with “get” in this class.
● Methods ​get_submitted_files, get_files​should not be in this class. They deal with files and should be moved to appropriate file helper classes.
● reviewed_by?,quiz_taken_by?​do not belong to AssignmentParticipant model. Move them to appropriate models.
● Methods ​is_reviewed_by? , quiz_taken_by? a​re not getting invoked from anywhere. Find all such methods to see if we need them and delete the methods if we don’t need them.
● get_two_node_cycles,get_three_node_cycles, get_four_node_cycles,​get_cycle_similarity_score, get_cycle_deviation_score a​r e a l s o a v a i l a b l e i n ​C​o l l u s i o n C y c l e m o d e l . Determine if we need them in AssignmentParticipant model and delete the methods if we don’t need them.
