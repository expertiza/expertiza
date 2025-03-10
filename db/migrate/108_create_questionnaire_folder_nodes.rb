class CreateQuestionnaireFolderNodes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tree_folders, :parent_id, :integer, null: true

    Node.where(['type in ("QuestionnaireTypeNode","QuestionnaireNode")']).find_each(&:destroy)

    parent = TreeFolder.find_by_name('Questionnaires')
    pNode = FolderNode.find_by_node_object_id(parent.id)

    fnode = TreeFolder.create(name: 'Review', child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: pNode.id, node_object_id: fnode.id)

    ReviewQuestionnaire.find_each do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end

    fnode = TreeFolder.create(name: 'Metareview', child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: pNode.id, node_object_id: fnode.id)

    MetareviewQuestionnaire.find_each  do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end

    fnode = TreeFolder.create(name: 'Author Feedback', child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: pNode.id, node_object_id: fnode.id)

    AuthorFeedbackQuestionnaire.find_each do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end

    fnode = TreeFolder.create(name: 'Teammate Review', child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: pNode.id, node_object_id: fnode.id)

    TeammateReviewQuestionnaire.find_each do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end

    fnode = TreeFolder.create(name: 'Survey', child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: pNode.id, node_object_id: fnode.id)

    SurveyQuestionnaire.find_each do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end

    fnode = TreeFolder.create(name: 'Global Survey', child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: pNode.id, node_object_id: fnode.id)

    GlobalSurveyQuestionnaire.find_each do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end

    fnode = TreeFolder.create(name: 'Course Evaluation', child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: pNode.id, node_object_id: fnode.id)

    CourseEvaluationQuestionnaire.find_each  do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end

    folders = TreeFolder.where(child_type: 'QuestionnaireNode')
    folders.each do |folder|
      folder.update_attribute('parent_id', parent.id)
    end
  end

  def self.down; end
end
