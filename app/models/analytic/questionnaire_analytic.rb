require 'analytic/item_analytic'
module QuestionnaireAnalytic
  # return all possible item types
  def types
    type_list = []
    items.each do |item|
      type_list << item.type unless type_list.include?(item.type)
    end
    type_list
  end

  def num_items
    items.count
  end

  def items_text_list
    item_list = []
    items.each do |item|
      item_list << item.txt
    end
    if item_list.empty?
      [0]
    else
      item_list
    end
  end

  def word_count_list
    word_count_list = []
    items.each do |item|
      word_count_list << item.word_count
    end
    if word_count_list.empty?
      [0]
    else
      word_count_list
    end
  end

  def total_word_count
    word_count_list.inject(:+)
  end

  def average_word_count
    return total_word_count.to_f / num_items unless num_items == 0

    0
  end

  def character_count_list
    character_count_list = []
    items.each do |item|
      character_count_list << item.character_count
    end
    if character_count_list.empty?
      [0]
    else
      character_count_list
    end
  end

  def total_character_count
    character_count_list.inject(:+)
  end

  def average_character_count
    return total_character_count.to_f / num_items unless num_items == 0

    0
  end
end
