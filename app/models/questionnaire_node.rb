class QuestionnaireNode < Node
  belongs_to :questionnaire, class_name: 'Questionnaire', foreign_key: 'node_object_id', inverse_of: false
  belongs_to :node_object, class_name: 'Questionnaire', foreign_key: 'node_object_id', inverse_of: false

  def self.table
    'questionnaires'
  end

  def self.get(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, _search = nil)
    user = User.find(user_id)
    is_ta = user.role.name == 'Teaching Assistant'

    if show
      conditions = is_ta ? 'questionnaires.instructor_id in (?)' : 'questionnaires.instructor_id = ?'
    else
      conditions = is_ta ? '(questionnaires.private = 0 or questionnaires.instructor_id in (?))' : '(questionnaires.private = 0 or questionnaires.instructor_id = ?)'
    end

    
    if is_ta 
      values = Ta.get_mapped_instructor_ids(user_id)
    else
      values = user_id
    end
    
    if parent_id
      name = TreeFolder.find(parent_id).name + 'Questionnaire'
      name.gsub!(/[^\w]/, '')
      conditions += " and questionnaires.type = \"#{name}\""
    end
    sortvar = 'name' if sortvar.nil? || (sortvar == 'directory_path')
    sortorder = 'ASC' if sortorder.nil?
    (includes(:questionnaire).where([conditions, values]).order("questionnaires.#{sortvar} #{sortorder}") if Questionnaire.column_names.include?(sortvar) &&
        %w[ASC DESC asc desc].include?(sortorder))
  end

  def get_attr(attr_name)
    Questionnaire.find_by(id: node_object_id).try(attr_name)
  end

  def get_name
    get_attr(:name)
  end

  # this method return instructor id associated with a questionnaire
  # expects no arguments
  # returns int
  def get_instructor_id
    get_attr(:instructor_id)
  end

  def get_private
    get_attr(:private)
  end

  def get_creation_date
    get_attr(:created_at)
  end

  def get_modified_date
    get_attr(:updated_at)
  end

  def is_leaf
    true
  end
end
