class QuestionnaireNode < Node
  belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "node_object_id", inverse_of: :questionnaire_node
  belongs_to :node_object, class_name: "Questionnaire", foreign_key: "node_object_id", inverse_of: :questionnaire_node

  def self.table
    "questionnaires"
  end

  def self.get(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, _search = nil)
    conditions = if show
                   if User.find(user_id).role.name != "Teaching Assistant"
                     'questionnaires.instructor_id = ?'
                   else
                     'questionnaires.instructor_id in (?)'
                   end
                 else
                   if User.find(user_id).role.name != "Teaching Assistant"
                     '(questionnaires.private = 0 or questionnaires.instructor_id = ?)'
                   else
                     '(questionnaires.private = 0 or questionnaires.instructor_id in (?))'
                   end
                 end

    values = if User.find(user_id).role.name != "Teaching Assistant"
               user_id
             else
               Ta.get_mapped_instructor_ids(user_id)
             end

    if parent_id
      name = TreeFolder.find(parent_id).name + "Questionnaire"
      name.gsub!(/[^\w]/, '')
      conditions += " and questionnaires.type = \"#{name}\""
    end
    sortvar = 'name' if sortvar.nil? or sortvar == 'directory_path'
    sortorder = 'ASC' if sortorder.nil?
    if Questionnaire.column_names.include? sortvar and %w[ASC DESC asc desc].include? sortorder
      self.includes(:questionnaire).where([conditions, values]).order("questionnaires.#{sortvar} #{sortorder}")
    end
  end

  def name
    Questionnaire.find_by(id: self.node_object_id).try(:name)
  end

  def private
    Questionnaire.find_by(id: self.node_object_id).try(:private)
  end

  def creation_date
    Questionnaire.find_by(id: self.node_object_id).try(:created_at)
  end

  def modified_date
    Questionnaire.find_by(id: self.node_object_id).try(:updated_at)
  end

  def leaf?
    true
  end
end
