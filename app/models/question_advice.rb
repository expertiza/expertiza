# == Schema Information
#
# Table name: question_advices
#
#  id          :integer          not null, primary key
#  question_id :integer
#  score       :integer
#  advice      :text
#

class QuestionAdvice < ActiveRecord::Base
  belongs_to :question, :dependent => :destroy
end
