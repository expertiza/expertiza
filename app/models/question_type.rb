# == Schema Information
#
# Table name: question_types
#
#  id          :integer          not null, primary key
#  q_type      :string(255)      default(""), not null
#  parameters  :string(255)
#  question_id :integer          default(1), not null
#

class QuestionType < ActiveRecord::Base

    belongs_to :question

    validates_presence_of :q_type # user must define type for the custom question
end
