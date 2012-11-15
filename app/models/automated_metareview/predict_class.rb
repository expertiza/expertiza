require 'automated_metareview/wordnet_based_similarity'
require 'automated_metareview/constants'

class PredictClass
=begin
 Identifies the probabilities of a review belonging to each of the three classes. 
 Returns an array of probablities (length = numClasses) 
=end
#predicting the review's class
def predict_classes(pos_tagger, core_NLP_tagger, review_text, review_graph, pattern_files_array, num_classes)
  #reading the patterns from the pattern files
  patterns_files = Array.new
  pattern_files_array.each do |file|
    patterns_files << file #collecting the file names for each class of patterns
  end
  
  tc = TextPreprocessing.new
  single_patterns = Array.new(num_classes){Array.new}
  #reading the patterns from each of the pattern files
  for i in (0..num_classes - 1) #for every class
    #read_patterns in TextPreprocessing helps read patterns in the format 'X = Y'
    single_patterns[i] = tc.read_patterns(patterns_files[i], pos_tagger) 
  end
  
  #Predicting the probability of the review belonging to each of the content classes
  wordnet = WordnetBasedSimilarity.new
  max_probability = 0.0
  class_value = 0          
  edges = review_graph.edges
  class_prob = Array.new #contains the probabilities for each of the classes - it contains 3 rows for the 3 classes    
  #comparing each test review text with patterns from each of the classes
  for k in (0..num_classes - 1)
    #comparing edges with patterns from a particular class
    class_prob[k] = compare_review_with_patterns(edges, single_patterns[k], wordnet)/6.to_f #normalizing the result 
    #we divide the match by 6 to ensure the value is in the range of [0-1]     
  end #end of for loop for the classes          
  
  #printing the probability values
  # puts("########## Probability for test review:: "+review_text[0]+" is::")  
  # for k in (0..num_classes - 1)
    # puts "class_prob[#{k}] .. #{class_prob[k]}"
  # end         
  return class_prob
end #end of the prediction method
#------------------------------------------#------------------------------------------#------------------------------------------

def compare_review_with_patterns(single_edges, single_patterns, wordnet)
  final_class_sum = 0.0
  final_edge_num = 0
  single_edge_matches = Array.new(single_edges.length){Array.new}
  #resetting the average_match values for all the edges, before matching with the single_patterns for a new class
  for i in 0..single_edges.length - 1
    if(!single_edges[i].nil?)
      single_edges[i].average_match = 0
    end  
  end
  
  #comparing each single edge with all the patterns
  for i in (0..single_edges.length - 1)  #iterating through the single edges
    max_match = 0
    if(!single_edges[i].nil?)
      for j in (0..single_patterns.length - 1) 
        if(!single_patterns[j].nil?)
          single_edge_matches[i][j] = compare_edges(single_edges[i], single_patterns[j], wordnet)
          if(single_edge_matches[i][j] > max_match)
            max_match = single_edge_matches[i][j]
          end 
        end 
      end #end of for loop for the patterns
      single_edges[i].average_match = max_match  
      
      #calculating class average
      if(single_edges[i].average_match != 0.0)
        final_class_sum = final_class_sum + single_edges[i].average_match
        final_edge_num+=1
      end
    end #end of the if condition
  end #end of for loop
  
  if(final_edge_num == 0)
    final_edge_num = 1  
  end
  
  # puts("final_class_sum:: #{final_class_sum} final_edge_num:: #{final_edge_num} Class average #{final_class_sum/final_edge_num}")
  return final_class_sum/final_edge_num #maxMatch
end #end of determineClass method
#------------------------------------------#------------------------------------------#------------------------------------------

def compare_edges(e1, e2, wordnet)
  speller = Aspell.new("en_US")
  speller.suggestion_mode = Aspell::NORMAL
  
  avg_match_without_syntax = 0
  #compare edges so that only non-nouns or non-subjects are compared
  # if(!e1.in_vertex.pos_tag.include?("NN") and !e1.out_vertex.pos_tag.include?("NN"))
    avg_match_without_syntax = (wordnet.compare_strings(e1.in_vertex, e2.in_vertex, speller) + 
                              wordnet.compare_strings(e1.out_vertex, e2.out_vertex, speller))/2.to_f
  # elsif(!e1.in_vertex.pos_tag.include?("NN"))
    # avg_match_without_syntax = wordnet.compare_strings(e1.in_vertex, e2.in_vertex, speller)
  # elsif(!e1.out_vertex.pos_tag.include?("NN"))
    # avg_match_without_syntax = wordnet.compare_strings(e1.out_vertex, e2.out_vertex, speller)
  # end
  
  avg_match_with_syntax = 0
  #matching in-out and out-in vertices
  # if(!e1.in_vertex.pos_tag.include?("NN") and !e1.out_vertex.pos_tag.include?("NN"))
  avg_match_with_syntax = (wordnet.compare_strings(e1.in_vertex, e2.out_vertex, speller) + 
                              wordnet.compare_strings(e1.out_vertex, e2.in_vertex, speller))/2.to_f
  # elsif(!e1.in_vertex.pos_tag.include?("NN"))
    # avg_match_with_syntax = wordnet.compare_strings(e1.in_vertex, e2.out_vertex, speller)
  # elsif(!e1.out_vertex.pos_tag.include?("NN"))
    # avg_match_with_syntax = wordnet.compare_strings(e1.out_vertex, e2.in_vertex, speller)
  # end
  
  if(avg_match_without_syntax > avg_match_with_syntax)
    return avg_match_without_syntax
  else
    return avg_match_with_syntax
  end
end #end of the compare_edges method
end