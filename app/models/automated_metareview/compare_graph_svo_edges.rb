class CompareGraphSVOEdges
#------------------------------------------#------------------------------------------
  def compare_SVO_edges(vertex_match, rev, subm, num_rev_edg, num_sub_edg)
    best_SVO_SVO_edges_match = Array.new(num_rev_edg){Array.new}
    cum_double_edge_match = 0.0
    count = 0
    max = 0.0
    flag = 0
    wnet = WordnetBasedSimilarity.new
    for i in (0..num_rev_edg - 1)
      #null check and skipping edges with frequent words for vertices
      if(nilCondCheck(rev[i], rev[i+1]) && !wnetFrequentWordCheck2edges(wnet, rev[i], rev[i+1]))

        #best match
        for j in (0..num_sub_edg - 1)
          #comparing in and out vertex to make sure that the types are same and
          #checking if the subm token is a frequent word
          if nilCondCheck(subm[j], subm[j+1]) &&
              !wnetFrequentWordCheck(vnet, subm[j]) &&
              edge_vertex_check2(rev[i], subm[j], rev[i+1], subm[j+1])

            cou, sum = sum_cou_calculation(vertex_match, rev[i], subm[j], rev[i+1], subm[j+1])
            #-- Only Vertex match
            max, best_SVO_SVO_edges_match[i][j] = max_calculation(cou,sum, rev[i], subm[j], rev[i+1], subm[j+1], max)
            flag = 1
          end #end of 'if' condition
        end #end of 'for' loop for 'j'
        flag_cond_var_set(:cum_double_edge_match, :max, :count, :flag, binding)
      end #end of 'if' condition
    end #end of 'for' loop for 'i'
    return calculate_avg_match(cum_double_edge_match, count)
  end

  #------------------------------------------#------------------------------------------
  def compare_SVO_diff_syntax(vertex_match, rev, subm, num_rev_edg, num_sub_edg)
    best_SVO_OVS_edges_match = Array.new(num_rev_edg){ Array.new}
    cum_double_edge_match = 0.0
    count = 0
    max = 0.0
    flag = 0
    wnet = WordnetBasedSimilarity.new
    for i in (0..num_rev_edg - 1)
      #checking null and skipping edges with frequent words for vertices
      if(nilCondCheck(rev[i], rev[i+1]) && !wnetFrequentWordCheck2edges(wnet, rev[i], rev[i+1]))
        for j in (0..num_sub_edg - 1)
          #making nil check and making sure the types are the same during comparison
          if(!nilCondCheck(subm[j], subm[j+1]) &&
              edge_vertex_check1(rev[i], subm[j], rev[i+1], subm[j+1]))
            cou, sum = sum_cou_calculation(vertex_match, rev[i], subm[j], rev[i+1], subm[j+1])
            max, best_SVO_OVS_edges_match[i][j] = max_calculation_diff_syntax(cou,sum, max)
            flag = 1
          end #end of 'if' condition
        end #end of 'for' loop for 'j'
        flag_cond_var_set(cum_double_edge_match, max, count, flag, bdg)
      end #end of if condition
    end #end of for loop for 'i'

    return calculate_avg_match(cum_double_edge_match, count)
  end #end of method

##################################################################################################
############################## Helper Methods ####################################################
##################################################################################################
  def sum_cou_calculation(vertex_match, edge1, edge2, edge3, edge4)
    #taking each match separately because one or more of the terms may be a frequent word,
    #for which no @vertex_match exists!
    sum = 0.0
    cou = 0
    if(!vertex_match[edge1.in_vertex.node_id][edge2.in_vertex.node_id].nil?)
      sum = sum + vertex_match[edge1.in_vertex.node_id][edge2.in_vertex.node_id]
      cou +=1
    end
    if(!vertex_match[edge1.out_vertex.node_id][edge2.out_vertex.node_id].nil?)
      sum = sum + vertex_match[edge1.out_vertex.node_id][edge2.out_vertex.node_id]
      cou +=1
    end
    if(!vertex_match[edge3.out_vertex.node_id][edge4.out_vertex.node_id].nil?)
      sum = sum + vertex_match[edge3.out_vertex.node_id][edge4.out_vertex.node_id]
      cou +=1
    end
    return cou, sum
  end

  def max_calculation(cou, sum, edge1, edge2, edge3, edge4, oldmax)

    #--Only vertex matches
    if(cou > 0)
      best_match = sum.to_f/cou.to_f
    else
      best_match = 0.0
    end
    best_match = best_match.to_f/ compare_labels(edge1, edge2).to_f
    #--Vertex and SRL - Dividing it by the label's match value
    best_match = best_match.to_f/ compare_labels(edge3, edge4).to_f
    if(best_match > max)
      max = best_match
    else
      max = oldmax
    end
    return max, best_match
  end


  def nilCondCheck(edge1, edge2)
    return (!edge1.nil? and !edge2.nil? and edge1.in_vertex.node_id != -1 and edge1.out_vertex.node_id != -1 and
        edge2.out_vertex.node_id != -1  and edge1.out_vertex == edge2.in_vertex)
  end

  def wnetFrequentWordCheck2edges(wnet, edge1, edge2)
    return (wnet.is_frequent_word(edge1.in_vertex.name) and wnet.is_frequent_word(edge1.out_vertex.name) and
        wnet.is_frequent_word(edge2.out_vertex.name))
  end

  def wnetFrequentWordCheck(vnet, edge)
    return   (wnet.is_frequent_word(edge.in_vertex.name) and wnet.is_frequent_word(edge.out_vertex.name))
  end

  def edge_vertex_check1(edge1, edge2, edge3, edge4)
    return (edge1.in_vertex.type == edge4.out_vertex.type and
        edge1.out_vertex.type == edge2.out_vertex.type and
        edge3.out_vertex.type == edge2.in_vertex.type)
  end

  def edge_vertex_check2(edge1, edge2, edge3, edge4)
    return (edge1.in_vertex.type == edge2.in_vertex.type and
        edge1.out_vertex.type == edge2.out_vertex.type and
        edge3.out_vertex.type == edge4.out_vertex.type)
  end

  def sum_cou_calculation_diff_syntax(vertex_match,edge1, edge2, edge3, edge4)
    #taking each match separately because one or more of the terms may be a frequent word,
    #for which no @vertex_match exists!

    sum = 0.0
    cou = 0
    if(!vertex_match[edge1.in_vertex.node_id][edge4.out_vertex.node_id].nil?)
      sum = sum + vertex_match[edge1.in_vertex.node_id][edge4.out_vertex.node_id]
      cou +=1
    end
    if(!vertex_match[edge1.out_vertex.node_id][edge2.out_vertex.node_id].nil?)
      sum = sum + vertex_match[edge1.out_vertex.node_id][edge2.out_vertex.node_id]
      cou +=1
    end
    if(!vertex_match[edge3.out_vertex.node_id][edge2.in_vertex.node_id].nil?)
      sum = sum + vertex_match[edge3.out_vertex.node_id][edge2.in_vertex.node_id]
      cou +=1
    end

    return cou, sum
  end

  def max_calculation_diff_syntax(cou, sum, oldmax)
    #comparing s-v-o (from review) with o-v-s (from submission)
    if(cou > 0)
      best_match = sum.to_f/cou.to_f
    else
      best_match = 0.0
    end

    if(best_match > max)
      max = best_match
    else
      max = oldmax
    end
    return max, best_match
  end

  def flag_cond_var_set(cum_double_edge_match, max, count, flag, bdg)
    #if the review edge had any submission edges with which it was matched, since not all
    # S-V edges might have corresponding V-O edges to match with
    if(flag != 0)
      eval "#{cum_double_edge_match} += #{max}", bdg
      eval "#{count} += 1", bdg
      eval "#{max} += 0.0", bdg
      eval "#{flag} += 0", bdg
    end
  end

  def calculate_avg_match(cum_double_edge_match, count)
    #getting the average for all the review edges' matches with the submission's edges
    avg_match = 0.0
    if(count > 0)
      avg_match = cum_double_edge_match.to_f/ count.to_f
    end
    return avg_match
  end
end
