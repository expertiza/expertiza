class CreateTagPromptDeployments < ActiveRecord::Migration[4.2]
  def change
    create_table :tag_prompt_deployments do |t|
      t.references :tag_prompt, index: true, foreign_key: true
      t.references :assignment, index: true, foreign_key: true
      t.references :questionnaire, index: true, foreign_key: true
      t.string :question_type
      t.integer :answer_length_threshold

      t.timestamps null: false
    end
  end
end
