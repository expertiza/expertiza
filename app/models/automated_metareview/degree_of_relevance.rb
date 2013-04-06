require 'automated_metareview/wordnet_based_similarity'
require 'automated_metareview/graph_generator'

class DegreeOfRelevance
#creating accessors for the instance variables
attr_accessor :vertex_match
attr_accessor :review
=begin
  Identifies relevance between a review and a submission
=end  
def get_relevance(reviews, submissions, num_reviews, pos_tagger, core_NLP_tagger, speller) #double dimensional arrays that contain the submissions and the reviews respectively
  review_vertices = nil
  review_edges = nil
  subm_vertices = nil
  subm_edges = nil
  num_rev_vert = 0
  num_rev_edg = 0 
  num_sub_vert = 0 
  numSubEdg = 0
  vert_match = 0.0
  edge_without_syn = 0.0
  edge_with_syn = 0.0
  edge_diff_type = 0.0
  double_edge = 0.0
  double_edge_with_syn = 0.0
  
    #since Reviews and Submissions "should" contain the same number of records review - submission pairs
    g = GraphGenerator.new
    #generating review's graph
    g.generate_graph(reviews, pos_tagger, core_NLP_tagger, true, false)
    review_vertices = g.vertices
    review_edges = g.edges
    num_rev_vert = g.num_vertices
    num_rev_edg = g.num_edges
    
    #assigning graph as a review graph to use in content classification
    @review = g.clone
      
    #generating the submission's graph
    g.generate_graph(submissions, pos_tagger, core_NLP_tagger, true, false)
    subm_vertices = g.vertices
    subm_edges = g.edges
    num_sub_vert = g.num_vertices
    num_sub_edg = g.num_edges
      
    vert_match = compare_vertices(pos_tagger, review_vertices, subm_vertices, num_rev_vert, num_sub_vert, speller)
    if(num_rev_edg > 0 and num_sub_edg > 0)
      edge_without_syn = compare_edges_non_syntax_diff(review_edges, subm_edges, num_rev_edg, num_sub_edg)
      edge_with_syn = compare_edges_syntax_diff(review_edges, subm_edges, num_rev_edg, num_sub_edg)
      edge_diff_type = compare_edges_diff_types(review_edges, subm_edges, num_rev_edg, num_sub_edg)
      edge_match = (edge_without_syn.to_f + edge_with_syn.to_f )/2.to_f #+ edge_diff_type.to_f
      double_edge = compare_SVO_edges(review_edges, subm_edges, num_rev_edg, num_sub_edg)
      double_edge_with_syn = compare_SVO_diff_syntax(review_edges, subm_edges, num_rev_edg, num_sub_edg)
      double_edge_match = (double_edge.to_f + double_edge_with_syn.to_f)/2.to_f
    else
      edge_match = 0
      double_edge_match = 0
    end
      
    #differently weighted cases
    #tweak this!!
    alpha = 0.55
    beta = 0.35
    gamma = 0.1 #alpha > beta > gamma
    relevance = (alpha.to_f * vert_match.to_f) + (beta * edge_match.to_f) + (gamma * double_edge_match.to_f) #case1's value will be in the range [0-6] (our semantic values) 
    scaled_relevance = relevance.to_f/6.to_f #scaled from [0-6] in the range [0-1]
    
    #printing values
    # puts("vertexMatch is [0-6]:: #{vert_match}")
    # puts("edgeWithoutSyn Match is [0-6]:: #{edge_without_syn}")
    # puts("edgeWithSyn Match is [0-6]:: #{edge_with_syn}")
    # puts("edgeDiffType Match is [0-6]:: #{edge_diff_type}")
    # puts("doubleEdge Match is [0-6]:: #{double_edge}")
    # puts("doubleEdge with syntax Match is [0-6]:: #{double_edge_with_syn}")
    # puts("relevance [0-6]:: #{relevance}")
    # puts("scaled relevance on [0-1]:: #{scaled_relevance}")
    # puts("*************************************************")
    return scaled_relevance
end  
=begin
   * every vertex is compared with every other vertex
   * Compares the vertices from across the two graphs to identify matches and quantify various metrics
   * v1- vertices of the submission/past review and v2 - vertices from new review 
=end
def compare_vertices(pos_tagger, rev, subm, num_rev_vert, num_sub_vert, speller)
  # puts("****Inside compare_vertices:: rev.length:: #{num_rev_vert} subm.length:: #{num_sub_vert}")
  #for double dimensional arrays, one of the dimensions should be initialized
  @vertex_match = Array.new(num_rev_vert){Array.new}
  wnet = WordnetBasedSimilarity.new
  cum_vertex_match = 0.0
  count = 0
  max = 0.0
  flag = 0
  
  for i in (0..num_rev_vert - 1)
    if(!rev.nil? and !rev[i].nil?)
      rev[i].node_id = i
      # puts("%%%%%%%%%%% Token #{rev[i].name} ::: POS tags:: rev[i].pos_tag:: #{rev[i].pos_tag} :: rev[i].node_id #{rev[i].node_id}")
      #skipping frequent words from vertex comparison
      if(wnet.is_frequent_word(rev[i].name))
        next #ruby equivalent for continue 
      end
      #looking for the best match
      #j tracks every element in the set of all vertices, some of which are null
      for j in (0..num_sub_vert - 1)
        if(!subm[j].nil?)
          if(subm[j].node_id == -1)
            subm[j].node_id = j
          end
          # puts("%%%%%%%%%%% Token #{subm[j].name} ::: POS tags:: subm[j].pos_tag:: #{subm[j].pos_tag} subm[j].node_id #{subm[j].node_id}")
          if(wnet.is_frequent_word(subm[j].name))
            next #ruby equivalent for continue 
          end
          #comparing only if one of the two vertices is a noun
          if(rev[i].pos_tag.include?("NN") and subm[j].pos_tag.include?("NN"))
            @vertex_match[i][j] = wnet.compare_strings(rev[i], subm[j], speller)    
            #only if the "if" condition is satisfied, since there could be null objects in between and you dont want unnecess. increments
            flag = 1
            if(@vertex_match[i][j] > max)
              max = @vertex_match[i][j]
            end
          end
        end
      end #end of for loop for the submission vertices
      
      if(flag != 0)#if the review edge had any submission edges with which it was matched, since not all S-V edges might have corresponding V-O edges to match with
        # puts("**** Best match for:: #{rev[i].name}-- #{max}")
        cum_vertex_match = cum_vertex_match + max
        count+=1
        max = 0.0 #re-initialize
        flag = 0
      end
    end #end of if condition
  end #end of for loop

  avg_match = 0.0
  if(count > 0)
    avg_match = cum_vertex_match/ count
  end
  return avg_match  
end #end of compare_vertices

#------------------------------------------#------------------------------------------
=begin 
   * SAME TYPE COMPARISON!!
   * Compares the edges from across the two graphs to identify matches and quantify various metrics
   * compare SUBJECT-VERB edges with SUBJECT-VERB matches
   * where SUBJECT-SUBJECT and VERB-VERB or VERB-VERB and OBJECT-OBJECT comparisons are done
=end
def compare_edges_non_syntax_diff(rev, subm, num_rev_edg, num_sub_edg)
  # puts("*****Inside compareEdgesnNonSyntaxDiff numRevEdg:: #{num_rev_edg} numSubEdg:: #{num_sub_edg}")   
  best_SV_SV_match = Array.new(num_rev_edg){Array.new}
  cum_edge_match = 0.0
  count = 0
  max = 0.0
  flag = 0
  
  wnet = WordnetBasedSimilarity.new
  for i in (0..num_rev_edg - 1)
    if(!rev[i].nil? and rev[i].in_vertex.node_id != -1 and rev[i].out_vertex.node_id != -1)
    #skipping edges with frequent words for vertices
    if(wnet.is_frequent_word(rev[i].in_vertex.name) and wnet.is_frequent_word(rev[i].out_vertex.name))
      next
    end
    
    #looking for best matches
    for j in (0..num_sub_edg - 1)
      #comparing in-vertex with out-vertex to make sure they are of the same type
      if(!subm[j].nil? && subm[j].in_vertex.node_id != -1 && subm[j].out_vertex.node_id != -1)
        
        #checking if the subm token is a frequent word
        if(wnet.is_frequent_word(subm[j].in_vertex.name) and wnet.is_frequent_word(subm[j].out_vertex.name))
          next
        end     
              
        #carrying out the normal comparison
        if(rev[i].in_vertex.type == subm[j].in_vertex.type && rev[i].out_vertex.type == subm[j].out_vertex.type)
          if(!rev[i].label.nil?)
            if(!subm[j].label.nil?)
              #taking each match separately because one or more of the terms may be a frequent word, for which no @vertex_match exists!
              sum = 0.0
              cou = 0
              if(!@vertex_match[rev[i].in_vertex.node_id][subm[j].in_vertex.node_id].nil?)
                sum = sum + @vertex_match[rev[i].in_vertex.node_id][subm[j].in_vertex.node_id]
                cou +=1
              end
              if(!@vertex_match[rev[i].out_vertex.node_id][subm[j].out_vertex.node_id].nil?)
                sum = sum + @vertex_match[rev[i].out_vertex.node_id][subm[j].out_vertex.node_id]
                cou +=1
              end  
              #--Only vertex matches
              if(cou > 0)
                best_SV_SV_match[i][j] = sum.to_f/cou.to_f
              else
                best_SV_SV_match[i][j] = 0.0
              end
              #--Vertex and SRL - Dividing it by the label's match value
              best_SV_SV_match[i][j] = best_SV_SV_match[i][j]/ compare_labels(rev[i], subm[j])
              flag = 1
              if(best_SV_SV_match[i][j] > max)
                max = best_SV_SV_match[i][j]
              end
            end
          end
        end
      end
    end #end of for loop for the submission edges
    
    #cumulating the review edges' matches in order to get its average value
    if(flag != 0) #if the review edge had any submission edges with which it was matched, since not all S-V edges might have corresponding V-O edges to match with
      # puts("**** Best match for:: #{rev[i].in_vertex.name} - #{rev[i].out_vertex.name} -- #{max}")
      cum_edge_match = cum_edge_match + max
      count+=1
      max = 0.0#re-initialize
      flag = 0
      end
    end
  end #end of 'for' loop for the review's edges
  
  #getting the average for all the review edges' matches with the submission's edges
  avg_match = 0.0
  if(count > 0)
    avg_match = cum_edge_match/ count
  end
  return avg_match
end
#------------------------------------------#------------------------------------------
=begin
   * SAME TYPE COMPARISON!!
   * Compares the edges from across the two graphs to identify matches and quantify various metrics
   * compare SUBJECT-VERB edges with VERB-OBJECT matches and vice-versa
   * where SUBJECT-OBJECT and VERB_VERB comparisons are done - same type comparisons!!
=end

def compare_edges_syntax_diff(rev, subm, num_rev_edg, num_sub_edg)
  # puts("*****Inside compareEdgesSyntaxDiff :: numRevEdg :: #{num_rev_edg} numSubEdg:: #{num_sub_edg}")    
  best_SV_VS_match = Array.new(num_rev_edg){Array.new}
  cum_edge_match = 0.0
  count = 0
  max = 0.0
  flag = 0
  wnet = WordnetBasedSimilarity.new  
  for i in (0..num_rev_edg - 1)
    if(!rev[i].nil? and rev[i].in_vertex.node_id != -1 and rev[i].out_vertex.node_id != -1)
      #skipping frequent word
      if(wnet.is_frequent_word(rev[i].in_vertex.name) and wnet.is_frequent_word(rev[i].out_vertex.name))
        next
      end
      for j in (0..num_sub_edg - 1)
        if(!subm[j].nil? and subm[j].in_vertex.node_id != -1 and subm[j].out_vertex.node_id != -1)
          #checking if the subm token is a frequent word
          if(wnet.is_frequent_word(subm[j].in_vertex.name) and wnet.is_frequent_word(subm[j].out_vertex.name))
            next
          end 
          if(rev[i].in_vertex.type == subm[j].out_vertex.type and rev[i].out_vertex.type == subm[j].in_vertex.type)
            #taking each match separately because one or more of the terms may be a frequent word, for which no @vertex_match exists!
            sum = 0.0
            cou = 0
            if(!@vertex_match[rev[i].in_vertex.node_id][subm[j].out_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i].in_vertex.node_id][subm[j].out_vertex.node_id]
              cou +=1
            end
            if(!@vertex_match[rev[i].out_vertex.node_id][subm[j].in_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i].out_vertex.node_id][subm[j].in_vertex.node_id]
              cou +=1
            end              
            
            if(cou > 0)
              best_SV_VS_match[i][j] = sum.to_f/cou.to_f
            else
              best_SV_VS_match[i][j] = 0.0
            end
            
            flag = 1
            if(best_SV_VS_match[i][j] > max)
              max = best_SV_VS_match[i][j]
            end
          end
        end #end of the if condition
      end #end of the for loop for the submission edges     
          
      if(flag != 0)#if the review edge had any submission edges with which it was matched, since not all S-V edges might have corresponding V-O edges to match with
        # puts("**** Best match for:: #{rev[i].in_vertex.name} - #{rev[i].out_vertex.name}-- #{max}")
        cum_edge_match = cum_edge_match + max
        count+=1
        max = 0.0 #re-initialize
        flag = 0
      end
        
    end #end of the if condition
  end #end of the for loop for the review
   
  avg_match = 0.0
  if(count > 0)
    avg_match = cum_edge_match.to_f/count.to_f
  end
  return avg_match
end  #end of the method
#------------------------------------------#------------------------------------------
=begin
   DIFFERENT TYPE COMPARISON!!
   * Compares the edges from across the two graphs to identify matches and quantify various metrics
   * compare SUBJECT-VERB edges with VERB-OBJECT matches and vice-versa
   * SUBJECT-VERB, VERB-SUBJECT, OBJECT-VERB, VERB-OBJECT comparisons are done! 
=end
def compare_edges_diff_types(rev, subm, num_rev_edg, num_sub_edg)
  # puts("*****Inside compareEdgesDiffTypes :: numRevEdg :: #{num_rev_edg} numSubEdg:: #{num_sub_edg}")   
  best_SV_VS_match = Array.new(num_rev_edg){Array.new}
  cum_edge_match = 0.0
  count = 0
  max = 0.0
  flag = 0
  wnet = WordnetBasedSimilarity.new  
  for i in (0..num_rev_edg - 1)
    if(!rev[i].nil? and rev[i].in_vertex.node_id != -1 and rev[i].out_vertex.node_id != -1)
      #skipping edges with frequent words for vertices
      if(wnet.is_frequent_word(rev[i].in_vertex.name) and wnet.is_frequent_word(rev[i].out_vertex.name))
        next
      end
      #identifying best match for edges
      for j in (0..num_sub_edg - 1) 
        if(!subm[j].nil? and subm[j].in_vertex.node_id != -1 and subm[j].out_vertex.node_id != -1)
          #checking if the subm token is a frequent word
          if(wnet.is_frequent_word(subm[j].in_vertex.name) and wnet.is_frequent_word(subm[j].out_vertex.name))
            next
          end 
          #for S-V with S-V or V-O with V-O
          if(rev[i].in_vertex.type == subm[j].in_vertex.type and rev[i].out_vertex.type == subm[j].out_vertex.type)
            #taking each match separately because one or more of the terms may be a frequent word, for which no @vertex_match exists!
            sum = 0.0
            cou = 0
            if(!@vertex_match[rev[i].in_vertex.node_id][subm[j].out_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i].in_vertex.node_id][subm[j].out_vertex.node_id]
              cou +=1
            end
            if(!@vertex_match[rev[i].out_vertex.node_id][subm[j].in_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i].out_vertex.node_id][subm[j].in_vertex.node_id]
              cou +=1
            end  
            if(cou > 0)
              best_SV_VS_match[i][j] = sum.to_f/cou.to_f
            else
              best_SV_VS_match[i][j] = 0.0
            end
            #-- Vertex and SRL
            best_SV_VS_match[i][j] = best_SV_VS_match[i][j]/ compare_labels(rev[i], subm[j])
            flag = 1
            if(best_SV_VS_match[i][j] > max)
              max = best_SV_VS_match[i][j]
            end
          #for S-V with V-O or V-O with S-V
          elsif(rev[i].in_vertex.type == subm[j].out_vertex.type and rev[i].out_vertex.type == subm[j].in_vertex.type)
            #taking each match separately because one or more of the terms may be a frequent word, for which no @vertex_match exists!
            sum = 0.0
            cou = 0
            if(!@vertex_match[rev[i].in_vertex.node_id][subm[j].in_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i].in_vertex.node_id][subm[j].in_vertex.node_id]
              cou +=1
            end
            if(!@vertex_match[rev[i].out_vertex.node_id][subm[j].out_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i].out_vertex.node_id][subm[j].out_vertex.node_id]
              cou +=1
            end  
            if(cou > 0)
              best_SV_VS_match[i][j] = sum.to_f/cou.to_f
            else
              best_SV_VS_match[i][j] =0.0
            end
            flag = 1
            if(best_SV_VS_match[i][j] > max)
              max = best_SV_VS_match[i][j]
            end
          end
        end #end of the if condition
      end #end of the for loop for submission edges
        
      if(flag != 0) #if the review edge had any submission edges with which it was matched, since not all S-V edges might have corresponding V-O edges to match with
        # puts("**** Best match for:: #{rev[i].in_vertex.name} - #{rev[i].out_vertex.name} -- #{max}")
        cum_edge_match = cum_edge_match + max
        count+=1
        max = 0.0 #re-initialize
        flag = 0
      end
    end #end of if condition
  end #end of for loop for review edges
    
  avg_match = 0.0
  if(count > 0)
    avg_match = cum_edge_match.to_f/ count.to_f
  end
  return avg_match
end #end of the method   
#------------------------------------------#------------------------------------------

def compare_SVO_edges(rev, subm, num_rev_edg, num_sub_edg)
  # puts("***********Inside compare SVO edges numRevEdg:: #{num_rev_edg} numSubEdg:: #{num_sub_edg}")
  best_SVO_SVO_edges_match = Array.new(num_rev_edg){Array.new}
  cum_double_edge_match = 0.0
  count = 0
  max = 0.0
  flag = 0
  wnet = WordnetBasedSimilarity.new  
  for i in (0..num_rev_edg - 1)
    if(!rev[i].nil? and !rev[i+1].nil? and rev[i].in_vertex.node_id != -1 and rev[i].out_vertex.node_id != -1 and 
      rev[i+1].out_vertex.node_id != -1  and rev[i].out_vertex == rev[i+1].in_vertex)
      #skipping edges with frequent words for vertices
      if(wnet.is_frequent_word(rev[i].in_vertex.name) and wnet.is_frequent_word(rev[i].out_vertex.name) and wnet.is_frequent_word(rev[i+1].out_vertex.name))
        next
      end
        #best match
        for j in (0..num_sub_edg - 1)
          if(!subm[j].nil? and !subm[j+1].nil? and subm[j].in_vertex.node_id != -1 and subm[j].out_vertex.node_id != -1 and 
            subm[j+1].out_vertex.node_id != -1 and subm[j].out_vertex == subm[j+1].in_vertex)
            #checking if the subm token is a frequent word
            if(wnet.is_frequent_word(subm[j].in_vertex.name) and wnet.is_frequent_word(subm[j].out_vertex.name))
              next
            end 
            #making sure the types are the same during comparison
            if(rev[i].in_vertex.type == subm[j].in_vertex.type and rev[i].out_vertex.type == subm[j].out_vertex.type and 
              rev[i+1].out_vertex.type == subm[j+1].out_vertex.type)
              #taking each match separately because one or more of the terms may be a frequent word, for which no @vertex_match exists!
              sum = 0.0
              cou = 0
              if(!@vertex_match[rev[i].in_vertex.node_id][subm[j].in_vertex.node_id].nil?)
                sum = sum + @vertex_match[rev[i].in_vertex.node_id][subm[j].in_vertex.node_id]
                cou +=1
              end
              if(!@vertex_match[rev[i].out_vertex.node_id][subm[j].out_vertex.node_id].nil?)
                sum = sum + @vertex_match[rev[i].out_vertex.node_id][subm[j].out_vertex.node_id]
                cou +=1
              end
              if(!@vertex_match[rev[i+1].out_vertex.node_id][subm[j+1].out_vertex.node_id].nil?)
                sum = sum + @vertex_match[rev[i+1].out_vertex.node_id][subm[j+1].out_vertex.node_id]
                cou +=1
              end
              #-- Only Vertex match
              if(cou > 0)
                best_SVO_SVO_edges_match[i][j] = sum.to_f/cou.to_f
              else
                best_SVO_SVO_edges_match[i][j] = 0.0
              end
              #-- Vertex and SRL
              best_SVO_SVO_edges_match[i][j] = best_SVO_SVO_edges_match[i][j].to_f/ compare_labels(rev[i], subm[j]).to_f
              best_SVO_SVO_edges_match[i][j] = best_SVO_SVO_edges_match[i][j].to_f/ compare_labels(rev[i+1], subm[j+1]).to_f
              #-- Only SRL
              if(best_SVO_SVO_edges_match[i][j] > max)
                max = best_SVO_SVO_edges_match[i][j]
              end
              flag = 1
           end
          end #end of 'if' condition
        end #end of 'for' loop for 'j'
        
        if(flag != 0) #if the review edge had any submission edges with which it was matched, since not all S-V edges might have corresponding V-O edges to match with
          # puts("**** Best match for:: #{rev[i].in_vertex.name} - #{rev[i].out_vertex.name} - #{rev[i+1].out_vertex.name} -- #{max}")
          cum_double_edge_match = cum_double_edge_match + max
          count+=1
          max = 0.0 #re-initialize
          flag = 0
        end
      end #end of 'if' condition
    end #end of 'for' loop for 'i'
    
  avg_match = 0.0
  if(count > 0)
    avg_match = cum_double_edge_match.to_f/ count.to_f
  end
  return avg_match
end
#------------------------------------------#------------------------------------------

def compare_SVO_diff_syntax(rev, subm, num_rev_edg, num_sub_edg)
  # puts("***********Inside compare SVO edges with syntax difference numRevEdg:: #{num_rev_edg} numSubEdg:: #{num_sub_edg}")
  best_SVO_OVS_edges_match = Array.new(num_rev_edg){ Array.new}
  cum_double_edge_match = 0.0
  count = 0
  max = 0.0
  flag = 0
  wnet = WordnetBasedSimilarity.new  
  for i in (0..num_rev_edg - 1) 
    if(!rev[i].nil? and !rev[i+1].nil? and rev[i].in_vertex.node_id != -1 and rev[i].out_vertex.node_id != -1 and 
      rev[i+1].out_vertex.node_id != -1 and rev[i].out_vertex == rev[i+1].in_vertex)
      #skipping edges with frequent words for vertices
      if(wnet.is_frequent_word(rev[i].in_vertex.name) and wnet.is_frequent_word(rev[i].out_vertex.name) and wnet.is_frequent_word(rev[i+1].out_vertex.name))
        next
      end
        
      for j in (0..num_sub_edg - 1)
        if(!subm[j].nil? and !subm[j+1].nil? and subm[j].in_vertex.node_id != -1 and subm[j].out_vertex.node_id != -1 and subm[j+1].out_vertex.node_id != -1 and subm[j].out_vertex == subm[j+1].in_vertex)
          #making sure the types are the same during comparison
          if(rev[i].in_vertex.type == subm[j+1].out_vertex.type and rev[i].out_vertex.type == subm[j].out_vertex.type and 
            rev[i+1].out_vertex.type == subm[j].in_vertex.type)
            #taking each match separately because one or more of the terms may be a frequent word, for which no @vertex_match exists!
            sum = 0.0
            cou = 0
            if(!@vertex_match[rev[i].in_vertex.node_id][subm[j+1].out_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i].in_vertex.node_id][subm[j+1].out_vertex.node_id]
              cou +=1
            end
            if(!@vertex_match[rev[i].out_vertex.node_id][subm[j].out_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i].out_vertex.node_id][subm[j].out_vertex.node_id]
              cou +=1
            end
            if(!@vertex_match[rev[i+1].out_vertex.node_id][subm[j].in_vertex.node_id].nil?)
              sum = sum + @vertex_match[rev[i+1].out_vertex.node_id][subm[j].in_vertex.node_id]
              cou +=1
            end
            #comparing s-v-o (from review) with o-v-s (from submission)
            if(cou > 0)
              best_SVO_OVS_edges_match[i][j] = sum.to_f/cou.to_f
            else
              best_SVO_OVS_edges_match[i][j] = 0.0
            end
            flag = 1
            if(best_SVO_OVS_edges_match[i][j] > max)
              max = best_SVO_OVS_edges_match[i][j]
            end
          end  
        end #end of 'if' condition
      end #end of 'for' loop for 'j'
      if(flag != 0)#if the review edge had any submission edges with which it was matched, since not all S-V edges might have corresponding V-O edges to match with
        # puts("**** Best match for:: #{rev[i].in_vertex.name} - #{rev[i].out_vertex.name} - #{rev[i+1].out_vertex.name}-- #{max}")
        cum_double_edge_match = cum_double_edge_match + max
        count+=1
        max = 0.0 #re-initialize
        flag = 0
      end
      
    end #end of if condition
  end #end of for loop for 'i'
    
  avg_match = 0.0
  if(count > 0)
    avg_match = cum_double_edge_match.to_f / count.to_f
  end
  return avg_match
end #end of method
#------------------------------------------#------------------------------------------
=begin  
   SR Labels and vertex matches are given equal importance
   * Problem is even if the vertices didn't match, the SRL labels would cause them to have a high similarity.
   * Consider "boy - said" and "chocolate - melted" - these edges have NOMATCH for vertices, but both edges have the same label "SBJ" and would get an EXACT match, 
   * resulting in an avg of 3! This cant be right!
   * We therefore use the labels to only decrease the match value found from vertices, i.e., if the labels were different.
   * Match value will be left as is, if the labels were the same.
=end
  def compare_labels(edge1, edge2)
    result = EQUAL
    if(!edge1.label.nil? and !edge2.label .nil?)
      if(edge1.label.downcase == edge2.label.downcase)
        result = EQUAL #divide by 1
      else
        result = DISTINCT #divide by 2
      end
    elsif((!edge1.label.nil? and !edge2.label.nil?) or (edge1.label.nil? and !edge2.label.nil? )) #if only one of the labels was null
        result = DISTINCT
    elsif(edge1.label.nil? and edge2.label.nil?) #if both labels were null!
        result = EQUAL
    end  
    return result
  end # end of method
end