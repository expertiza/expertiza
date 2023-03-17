class QuestionnaireNode < Node
  belongs_to :questionnaire, class_name: 'Questionnaire', foreign_key: 'node_object_id', inverse_of: false
  belongs_to :node_object, class_name: 'Questionnaire', foreign_key: 'node_object_id', inverse_of: false

  def self.table
    'questionnaires'
  end

  def self.get(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, _search = nil)
    conditions = if show
                   if User.find(user_id).role.name != 'Teaching Assistant'
                     'questionnaires.instructor_id = ?'
                   else
                     'questionnaires.instructor_id in (?)'
                   end
                 elsif User.find(user_id).role.name != 'Teaching Assistant'
                   '(questionnaires.private = 0 or questionnaires.instructor_id = ?)'
                 else
                   '(questionnaires.private = 0 or questionnaires.instructor_id in (?))'
                 end

    values = if User.find(user_id).role.name == 'Teaching Assistant'
               Ta.get_mapped_instructor_ids(user_id)
             else
               user_id
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

  def get_attribute(attribute_name)
    Questionnaire.find_by(id: node_object_id)&.send(attribute_name)
  end
  
  # this method return name associated with a questionnaire
  # expects no arguments 
  # returns string
  def get_name
    get_attribute(:name)
  end

  # this method return instructor id associated with a questionnaire
  # expects no arguments
  # returns int
  def get_instructor_id
    get_attribute(:instructor_id)
  end
  
  def get_private
    get_attribute(:private)
  end

  def get_creation_date
    get_attribute(:created_at)
  end

  def get_modified_date
    get_attribute(:updated_at)
  end

  def is_leaf
    true
  end
end
