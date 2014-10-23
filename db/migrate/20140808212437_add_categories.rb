class AddCategories < ActiveRecord::Migration
  def self.up
    -    add_column :nodes, :name, :string
    -    add_column :nodes, :lft, :integer
    -    add_column :nodes, :rgt, :integer
    -    add_column :nodes, :depth, :integer
    +    create_table :categories do |t|
    Andrew KofinkCollaborator
    akofink added a note 2 days ago
    Revert this change. It looks like you haven't pulled from the rails4 branch. This will only complicate things for you. Please pull often.
Add a line note
+      t.string :name
+      t.integer :parent_id
+      t.integer :lft
+      t.integer :rgt
+      t.integer :depth # this is optional.
+    end
   end
 
   def self.down
-    remove_column :nodes, :name
-    remove_column :nodes, :lft
-    remove_column :nodes, :rgt
-    remove_column :nodes, :depth
+    drop_table :categories
   end
 end