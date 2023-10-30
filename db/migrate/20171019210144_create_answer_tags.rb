class CreateAnswerTags < ActiveRecord::Migration[4.2]
  def change
    create_table :answer_tags do |t|
      t.references :answer, index: true, foreign_key: true
      t.references :tag_prompt_deployment, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :value

      t.timestamps null: false
    end
  end
end
