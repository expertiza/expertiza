class CompareGraphEdges
#------------------------------------------#------------------------------------------
=begin
   * SAME TYPE COMPARISON!!
   * Compares the edges from across the two graphs to identify matches and quantify various metrics
   * compare SUBJECT-VERB edges with SUBJECT-VERB matches
   * where SUBJECT-SUBJECT and VERB-VERB or VERB-VERB and OBJECT-OBJECT comparisons are done
=end
  def compare_edges_non_syntax_diff(vertex_match,rev, subm, num_rev_edg, num_sub_edg)
    best_SV_SV_match = Array.new(num_rev_edg){Array.new}
    cum_edge_match = 0.0
    count = 0
    max = 0.0
    flag = 0
    wnet = WordnetBasedSimilarity.new
    for i in (0..num_rev_edg - 1)
      #null check and skipping edges with frequent words for vertices
      if(edge_nil_cond_check(rev[i]) && !wnet_frequent_word_check(wnet, rev[i]))
        #looking for best matches
        for j in (0..num_sub_edg - 1)
          #comparing in-vertex with out-vertex to make sure they are of the same type
          if(edge_nil_cond_check(subm[j]) && !wnet_frequent_word_check(wnet, subm[j]) &&
              edge_symm_vertex_type_check(rev[i], subm[j]) && !rev[i].label.nil? && !subm[j].label.nil?)
            cou, sum = sum_cou_symm_calculation(vertex_match, rev[i], subm[j])
            max, best_SV_SV_match[i][j] = max_calculation(cou,sum, rev[i], subm[j], max)
            flag = 1
          end
        end #end of for loop for the submission edges
        flag_cond_var_set(:cum_edge_match, :max, :count, :flag, binding)
      end
    end #end of 'for' loop for the review's edges
    return calculate_avg_match(cum_edge_match, count)
  end


#------------------------------------------#------------------------------------------
=begin
   * SAME TYPE COMPARISON!!
   * Compares the edges from across the two graphs to identify matches and quantify various metrics
   * compare SUBJECT-VERB edges with VERB-OBJECT matches and vice-versa
   * where SUBJECT-OBJECT and VERB_VERB comparisons are done - same type comparisons!!
=end

  def compare_edges_syntax_diff(vertex_match, rev, subm, num_rev_edg, num_sub_edg)
    best_SV_VS_match = Array.new(num_rev_edg){Array.new}
    cum_edge_match = 0.0
    count = 0
    max = 0.0
    flag = 0
    wnet = WordnetBasedSimilarity.new
    for i in (0..num_rev_edg - 1)
      if(edge_nil_cond_check(rev[i]) && !wnet_frequent_word_check(wnet, rev[i]))
        for j in (0..num_sub_edg - 1)
          if(edge_nil_cond_check(subm[j]) && !wnet_frequent_word_check(wnet, subm[j]) &&
              edge_asymm_vertex_type_check(rev[i],subm[j]))
            cou, sum = sum_cou_asymm_calculation(vertex_match, rev[i], subm[j])
            max, best_SV_VS_match[i][j] = max_calculation(cou,sum, rev[i], subm[j], max)
            flag = 1
          end #end of the if condition
        end #end of the for loop for the submission edges
        flag_cond_var_set(:cum_edge_match, :max, :count, :flag, binding)
      end
    end #end of 'for' loop for the review's edges
    return calculate_avg_match(cum_edge_match, count)
  end  #end of the method

  #------------------------------------------#------------------------------------------
=begin
DIFFERENT TYPE COMPARISON!!
* Compares the edges from across the two graphs to identify matches and quantify various metrics
* compare SUBJECT-VERB edges with VERB-OBJECT matches and vice-versa
* SUBJECT-VERB, VERB-SUBJECT, OBJECT-VERB, VERB-OBJECT comparisons are done!
=end
  def compare_edges_diff_types(vertex_match, rev, subm, num_rev_edg, num_sub_edg)
    best_SV_VS_match = Array.new(num_rev_edg){Array.new}
    cum_edge_match = max = 0.0
    count = flag = 0
    wnet = WordnetBasedSimilarity.new
    for i in (0..num_rev_edg - 1)
      if(edge_nil_cond_check(rev[i]) && !wnet_frequent_word_check(wnet, rev[i]))
        #identifying best match for edges
        for j in (0..num_sub_edg - 1)
          if(edge_nil_cond_check(subm[j]) && !wnet_frequent_word_check(wnet, subm[j]))
            #for S-V with S-V or V-O with V-O
            if(edge_symm_vertex_type_check(rev[i],subm[j]) || edge_asymm_vertex_type_check(rev[i],subm[j]))
              if(edge_symm_vertex_type_check(rev[i],subm[j]))
                cou, sum = sum_cou_asymm_calculation(vertex_match, rev[i], subm[j])
              else
                cou, sum = sum_cou_symm_calculation(vertex_match, rev[i], subm[j])
              end
              max, best_SV_VS_match[i][j] = max_calculation(cou,sum, rev[i], subm[j], max)
              flag = 1
            end
          end #end of the if condition
        end #end of the for loop for submission edges
        flag_cond_var_set(:cum_edge_match, :max, :count, :flag, binding)
      end
    end #end of 'for' loop for the review's edges
    return calculate_avg_match(cum_edge_match, count)
  end #end of the method


  ##################################################################################################
  ############################## Helper Methods ####################################################
  ##################################################################################################
  def sum_cou_symm_calculation(vertex_match, edge1, edge2)
    #taking each match separately because one or more of the terms may be a frequent word, for which no
    # @vertex_match exists!
    sum = 0.0
    cou = 0
    temp = vertex_match[edge1.in_vertex.node_id][edge2.in_vertex.node_id]
    if (!temp.nil?)
      sum = sum + temp
      cou +=1
    end
    temp = vertex_match[edge1.out_vertex.node_id][edge2.out_vertex.node_id]
    if (!temp.nil?)
      sum = sum + temp
      cou +=1
    end
    return cou, sum
  end

  def sum_cou_asymm_calculation(vertex_match, edge1, edge2)
    #taking each match separately because one or more of the terms may be a frequent word, for which no
    # @vertex_match exists!
    sum = 0.0
    cou = 0
    temp = vertex_match[edge1.in_vertex.node_id][edge2.out_vertex.node_id]
    if (!temp.nil?)
      sum = sum + temp
      cou +=1
    end
    temp = vertex_match[edge1.out_vertex.node_id][edge2.in_vertex.node_id]
    if (!temp.nil?)
      sum = sum + temp
      cou +=1
    end
    return cou, sum
  end

  def max_calculation(cou, sum, edge1, edge2, oldmax)
  #--Only vertex matches
    if(cou > 0)
      best_match = sum.to_f/cou.to_f
    else
      best_match = 0.0
    end
    #--Vertex and SRL - Dividing it by the label's match value
    best_match = best_match/ compare_labels(edge1, edge2)
    if(best_match > max)
      max = best_match
    else
      max = oldmax
    end
    return max, best_match
  end

  def calculate_avg_match(cum_edge_match, count)
    #getting the average for all the review edges' matches with the submission's edges
    avg_match = 0.0
    if(count > 0)
      avg_match = cum_edge_match/ count
    end
    return avg_match
  end

  def flag_cond_var_set(cum_edge_match, max, count, flag, bdg)
    #if the review edge had any submission edges with which it was matched, since not all
    # S-V edges might have corresponding V-O edges to match with
    if(flag != 0)
      eval "#{cum_edge_match} += #{max}", bdg
      eval "#{count} += 1", bdg
      eval "#{max} += 0.0", bdg
      eval "#{flag} += 0", bdg
    end
  end

  def edge_nil_cond_check(edge)
   return (!edge.nil? && edge.in_vertex.node_id != -1 && edge.out_vertex.node_id != -1)
  end

  def wnet_frequent_word_check(wnet, edge)
    return (wnet.is_frequent_word(edge.in_vertex.name) and wnet.is_frequent_word(edge.out_vertex.name))
  end

  def edge_symm_vertex_type_check(edge1, edge2)
    return (edge1.in_vertex.type == edge2.in_vertex.type && edge1.out_vertex.type == edge2.out_vertex.type)
  end

  def edge_asymm_vertex_type_check(edge1, edge2)
    return (edge1.in_vertex.type == edge2.out_vertex.type && edge1.out_vertex.type == edge2.in_vertex.type)
  end
end