class CreateQuestionnaireFolderNodes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tree_folders, :parent_id, :integer, null: true unless column_exists?(:tree_folders, :parent_id)

    # Destroy old nodes if present
    if defined?(Node)
      Node.where(type: ['QuestionnaireTypeNode', 'QuestionnaireNode']).find_each(&:destroy)
    end

    parent = TreeFolder.find_by(name: 'Questionnaires')
    return unless parent

    pNode = FolderNode.find_by(node_object_id: parent.id)
    return unless pNode

    # Helper to create safely
    create_questionnaire_folder('Review', pNode, defined?(ReviewQuestionnaire) ? ReviewQuestionnaire : nil)
    create_questionnaire_folder('Metareview', pNode, defined?(MetareviewQuestionnaire) ? MetareviewQuestionnaire : nil)
    create_questionnaire_folder('Author Feedback', pNode, defined?(AuthorFeedbackQuestionnaire) ? AuthorFeedbackQuestionnaire : nil)
    create_questionnaire_folder('Teammate Review', pNode, defined?(TeammateReviewQuestionnaire) ? TeammateReviewQuestionnaire : nil)
    create_questionnaire_folder('Survey', pNode, defined?(SurveyQuestionnaire) ? SurveyQuestionnaire : nil)
    create_questionnaire_folder('Global Survey', pNode, defined?(GlobalSurveyQuestionnaire) ? GlobalSurveyQuestionnaire : nil)
    create_questionnaire_folder('Course Evaluation', pNode, defined?(CourseEvaluationQuestionnaire) ? CourseEvaluationQuestionnaire : nil)

    # Update parents if present
    TreeFolder.where(child_type: 'QuestionnaireNode').each do |folder|
      folder.update_attribute('parent_id', parent.id)
    end
  end

  def self.down
    remove_column :tree_folders, :parent_id if column_exists?(:tree_folders, :parent_id)
  end

  private_class_method def self.create_questionnaire_folder(name, parent_node, model_class)
    fnode = TreeFolder.create(name: name, child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: parent_node.id, node_object_id: fnode.id)

    return unless model_class

    model_class.find_each do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end
  rescue StandardError => e
    Rails.logger.warn "Skipping folder #{name} due to error: #{e.message}"
  end
end