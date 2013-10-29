class CompareGraphVertices
  # To change this template use File | Settings | File Templates.
=begin
    * every vertex is compared with every other vertex
    * Compares the vertices from across the two graphs to identify matches and quantify various metrics
    * v1- vertices of the submission/past review and v2 - vertices from new review
=end
  def compare_vertices(vertex_match, pos_tagger, rev, subm, num_rev_vert, num_sub_vert, speller)
    #for double dimensional arrays, one of the dimensions should be initialized
    vertex_match = Array.new(num_rev_vert){Array.new}
    wnet = WordnetBasedSimilarity.new
    cum_vertex_match = 0.0
    count = 0
    max = 0.0
    flag = 0

    for i in (0..num_rev_vert - 1)
      #skipping frequent words from vertex comparison
      if(!rev.nil? and !rev[i].nil? && !wnet.is_frequent_word(rev[i].name))
        rev[i].node_id = i

        #looking for the best match
        #j tracks every element in the set of all vertices, some of which are null
        for j in (0..num_sub_vert - 1)
          if(!subm[j].nil? && !wnet.is_frequent_word(subm[j].name))
            if(subm[j].node_id == -1)
              subm[j].node_id = j
            end

            #comparing only if one of the two vertices is a noun
            if(rev[i].pos_tag.include?("NN") and subm[j].pos_tag.include?("NN"))
              vertex_match[i][j] = wnet.compare_strings(rev[i], subm[j], speller)
              #only if the "if" condition is satisfied, since there could be null objects in
              #between and you dont want unnecess. increments
              flag = 1
              if(vertex_match[i][j] > max)
                max = vertex_match[i][j]
              end
            end
          end
        end #end of for loop for the submission vertices

        flag_cond_var_set(cum_vertex_match, max, count, flag, bdg)
      end #end of if condition
    end #end of for loop

    return vertex_match, calculate_avg_match(cum_vertex_match, count)
  end #end of compare_vertices
end

def flag_cond_var_set(cum_vertex_match, max, count, flag, bdg)
  #if the review edge had any submission edges with which it was matched,
  #since not all S-V edges might have corresponding V-O edges to match with
  if(flag != 0)
    eval "#{cum_vertex_match} += #{max}", bdg
    eval "#{count} += 1", bdg
    eval "#{max} += 0.0", bdg
    eval "#{flag} += 0", bdg
  end
end

def calculate_avg_match(cum_vertex_match, count)
  #getting the average for all the review edges' matches with the submission's edges
  avg_match = 0.0
  if(count > 0)
    avg_match = cum_vertex_match.to_f/ count.to_f
  end
  return avg_match
end