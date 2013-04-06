require 'automated_metareview/sentence_state'
require 'automated_metareview/edge'
require 'automated_metareview/vertex'

class GraphGenerator
#include SentenceState 
#creating accessors for the instance variables
attr_accessor :vertices, :num_vertices, :edges, :num_edges, :pipeline, :pos_tagger

# #global variables
# $vertices = Array.new
# $edges = Array.new

=begin
   * generates the graph for the given review text and 
   * INPUT: an array of sentences for a review or a submission. Every row in 'text' contains one sentence.
   * type - tells you if it was a review or s submission
   * type = 1 - submission/past review
   * type = 2 - new review
=end
def generate_graph(text, pos_tagger, coreNLPTagger, forRelevance, forPatternIdentify)
  #initializing common arrays 
  @vertices = Array.new
  @num_vertices = 0
  @edges = Array.new
  @num_edges = 0

  @pos_tagger = pos_tagger #part of speech tagger
  @pipeline = coreNLPTagger #dependency parsing
  #iterate through the sentences in the text
  for i in (0..text.length-1)
    if(text[i].empty? or text[i] == "" or text[i].split(" ").empty?)
      next
    end
    unTaggedString = text[i].split(" ")
    # puts "UnTagged String:: #{unTaggedString}"
    taggedString = @pos_tagger.get_readable(text[i])
    # puts "taggedString:: #{taggedString}"
    
    #Initializing some arrays
    nouns = Array.new
    nCount = 0
    verbs = Array.new
    vCount = 0
    adjectives = Array.new
    adjCount = 0
    adverbs = Array.new
    advCount = 0
    
    parents = Array.new
    labels = Array.new
    
    #------------------------------------------#------------------------------------------
    #finding parents
    parents = find_parents(text[i])
    parentCounter = 0
    #------------------------------------------#------------------------------------------
    #finding parents
    labels = find_labels(text[i])
    labelCounter = 0
    #------------------------------------------#------------------------------------------
    #find state
    sstate = SentenceState.new
    states_array = sstate.identify_sentence_state(taggedString)
    states_counter = 0
    state = states_array[states_counter]
    states_counter += 1
    #------------------------------------------#------------------------------------------
    
    taggedString = taggedString.split(" ")
    prevType = nil #initlializing the prevyp
    
    #iterate through the tokens
    for j in (0..taggedString.length-1)
      taggedToken = taggedString[j]
      plainToken = taggedToken[0...taggedToken.index("/")].to_s
      posTag = taggedToken[taggedToken.index("/")+1..taggedToken.length].to_s    
      #ignore periods
      if(plainToken == "." or taggedToken.include?("/POS") or (taggedToken.index("/") == taggedToken.length()-1) or (taggedToken.index("/") == taggedToken.length()-2))#this is for strings containinig "'s" or without POS
        next
      end
      
      #SETTING STATE
      #since the CC or IN are part of the following sentence segment, we set the STATE for that segment when we see a CC or IN
      if(taggedToken.include?("/CC"))#{//|| ps.contains("/IN")
        state = states_array[states_counter]
        states_counter+=1
      end
      # puts("**Value:: #{plainToken} LabelCounter:: #{labelCounter} ParentCounter:: #{parentCounter} POStag:: #{posTag} .. state = #{state}")

      #------------------------------------------
      #if the token is a noun
      if(taggedToken.include?("NN") or taggedToken.include?("PRP") or taggedToken.include?("IN") or taggedToken.include?("/EX") or taggedToken.include?("WP"))
        #either add on to a previous vertex or create a brand new noun vertex
        if(prevType == NOUN) #adding to a previous noun vertex
           nCount -= 1 #decrement, since we are accessing a previous noun vertex
           prevVertex = search_vertices(@vertices, nouns[nCount], i) #fetching the previous vertex
           nouns[nCount] = nouns[nCount].to_s + " " + plainToken #concatenating with contents of the previous noun vertex
           #checking if the previous noun concatenated with "s" already exists among the vertices
           if((nounVertex = search_vertices(@vertices, nouns[nCount], i)) == nil) 
              prevVertex.name = prevVertex.name.to_s + " " + plainToken #concatenating the nouns
              nounVertex = prevVertex #the current concatenated vertex will be considered
              if(labels[labelCounter] != "NMOD" or labels[labelCounter] != "PMOD")#resetting labels for the concatenated vertex
                nounVertex.label = labels[labelCounter]
              end
              #fAppendedVertex = 1
           end#if the vertex already exists, just use nounVertex - the returned vertex for ops.          
        else #if the previous token is not a noun, create a brand new vertex
           nouns[nCount] = plainToken #this is checked for later on
           nounVertex = search_vertices(@vertices, plainToken, i)
           if(nounVertex == nil) #the string doesn't already exist
              @vertices[@num_vertices] = Vertex.new(nouns[nCount], NOUN, i, state, labels[labelCounter], parents[parentCounter], posTag)
              nounVertex = @vertices[@num_vertices] #the newly formed vertex will be considered
              @num_vertices+=1
           end
        end #end of if prevType was noun
        remove_redundant_vertices(nouns[nCount], i)
        nCount+=1 #increment nCount for a new noun vertex just created (or existing previous vertex appended with new text)
        
        #checking if a noun existed before this one and if the adjective was attached to that noun.
        #if an adjective was found earlier, we add a new edge
        if(prevType == ADJ)
            #set previous noun's property to null, if it was set, if there is a noun before the adjective
            if(nCount > 1)
              v1 = search_vertices(@vertices, nouns[nCount-2], i) #fetching the previous noun, the one before the current noun (therefore -2)   
              v2 = search_vertices(@vertices, adjectives[adjCount-1], i) #fetching the previous adjective             
              #if such an edge exists - DELETE IT - search_edges_to_set_null() returns the position in the array at which such an edge exists
              if(!v1.nil? and !v2.nil? and (e = search_edges_to_set_null(@edges, v1, v2, i)) != -1) #-1 is when no such edge exists
                @edges[e] = nil #setting the edge to null
                #if @num_edges had been previously incremented, decrement it
                if(@num_edges > 0)
                  @num_edges-=1 #deducting an edge count
                end
              end             
            end
            #if this noun vertex was encountered for the first time, nCount < 1,
            #so do adding of edge outside the if condition            
            #add a new edge with v1 as the adjective and v2 as the new noun
            v1 = search_vertices(@vertices, adjectives[adjCount-1], i)
            v2 = nounVertex #the noun vertex that was just created
            #if such an edge did not already exist
            if(!v1.nil? and !v2.nil? and (e = search_edges(@edges, v1, v2, i)) == -1)
              @edges[@num_edges] = Edge.new("noun-property",VERB)
              @edges[@num_edges].in_vertex = v1
              @edges[@num_edges].out_vertex = v2
              @edges[@num_edges].index = i
              @num_edges+=1
              #since an edge was just added we try to check if there exist any redundant edges that can be removed
              remove_redundant_edges(v1, v2, i)
            end
         end
         #a noun has been found and has established a verb as an in_vertex and such an edge doesnt already previously exist
          if(vCount > 0) #and fAppendedVertex == 0 
            #add edge only when a fresh vertex is created not when existing vertex is appended to
            v1 = search_vertices(@vertices, verbs[vCount-1], i)
            v2 = nounVertex
            #if such an edge does not already exist add it
            if(!v1.nil? and !v2.nil? and (e = search_edges(@edges,v1, v2, i)) == -1)
              @edges[@num_edges] = Edge.new("verb", VERB)             
              @edges[@num_edges].in_vertex = v1 #for vCount = 0
              @edges[@num_edges].out_vertex = v2
              @edges[@num_edges].index = i
              @num_edges+=1
              #since an edge was just added we try to check if there exist any redundant edges that can be removed
              remove_redundant_edges(v1, v2, i)
            end
          end
          prevType = NOUN
      #------------------------------------------
      
      #if the string is an adjective
      #adjectives are vertices but they are not connected by an edge to the nouns, instead they are the noun's properties
      elsif(taggedToken.include?("/JJ"))                  
        adjective = nil
        if(prevType == ADJ) #combine the adjectives
          # puts("PREV ADJ here:: #{plainToken}")
          if(adjCount >= 1)
            adjCount = adjCount - 1
            prevVertex = search_vertices(@vertices, adjectives[adjCount], i) #fetching the previous vertex
            adjectives[adjCount] = adjectives[adjCount] + " " + plainToken              
            #if the concatenated vertex didn't already exist
            if((adjective = search_vertices(@vertices, adjectives[adjCount], i)).nil?)
              prevVertex.name = prevVertex.name+" "+plainToken
              adjective = prevVertex #set it as "adjective" for further execution
              if(labels[labelCounter] != "NMOD" or labels[labelCounter] != "PMOD") #resetting labels for the concatenated vertex
                adjective.label = labels[labelCounter]
              end
            end
          end
        else #new adjective vertex
          adjectives[adjCount] = plainToken
          if((adjective = search_vertices(@vertices, plainToken, i)).nil?) #the string doesn't already exist
            @vertices[@num_vertices] = Vertex.new(adjectives[adjCount], ADJ, i, state, labels[labelCounter], parents[parentCounter], posTag)
            adjective = @vertices[@num_vertices]
            @num_vertices+=1
          end
        end
        remove_redundant_vertices(adjectives[adjCount], i)        
        adjCount+=1 #incrementing, since a new adjective was created or an existing one updated.
        
        #by default associate the adjective with the previous/latest noun and if there is a noun following it immediately, then remove the property from the older noun (done under noun condition)
        if(nCount > 0) #gets the previous noun to form the edge
          v1 = search_vertices(@vertices, nouns[nCount-1], i)            
          v2 = adjective #the current adjective vertex
          #if such an edge does not already exist add it
          if(!v1.nil? and !v2.nil? and (e = search_edges(@edges, v1, v2, i)) == -1)
            # puts "** Adding noun-adj edge .. #{v1.name} - #{v2.name}"
            @edges[@num_edges] = Edge.new("noun-property",VERB)
            @edges[@num_edges].in_vertex = v1
            @edges[@num_edges].out_vertex = v2
            @edges[@num_edges].index = i
            @num_edges+=1        
            #since an edge was just added we try to check if there exist any redundant edges that can be removed
            remove_redundant_edges(v1, v2, i)    
          end
        end
        prevType = ADJ
        #end of if condition for adjective
        #------------------------------------------
        
        #if the string is a verb or a modal//length condition for verbs is, be, are...
        elsif(taggedToken.include?("/VB") or taggedToken.include?("MD"))
          verbVertex = nil
          if(prevType == VERB) #combine the verbs            
            vCount = vCount - 1
            prevVertex = search_vertices(@vertices, verbs[vCount], i) #fetching the previous vertex
            verbs[vCount] = verbs[vCount] + " " + plainToken            
            #if the concatenated vertex didn't already exist
            if((verbVertex = search_vertices(@vertices, verbs[vCount], i)) == nil)
              prevVertex.name = prevVertex.name + " " + plainToken
              verbVertex = prevVertex #concatenated vertex becomes the new verb vertex
              if(labels[labelCounter] != "NMOD" or labels[labelCounter] != "PMOD")#resetting labels for the concatenated vertex
                verbVertex.label = labels[labelCounter]
              end
            end
          else
            verbs[vCount] = plainToken
            if((verbVertex = search_vertices(@vertices, plainToken, i)) == nil)
              @vertices[@num_vertices] = Vertex.new(plainToken, VERB, i, state, labels[labelCounter], parents[parentCounter], posTag)
              verbVertex = @vertices[@num_vertices] #newly created verb vertex will be considered in the future
              @num_vertices+=1
            end
          end
          remove_redundant_vertices(verbs[vCount], i)
          vCount+=1
          
          #if an adverb was found earlier, we set that as the verb's property
          if(prevType == ADV)
            #set previous verb's property to null, if it was set, if there is a verb following the adverb
            if(vCount > 1)
              v1 = search_vertices(@vertices, verbs[vCount-2], i) #fetching the previous verb, the one before the current one (hence -2)            
              v2 = search_vertices(@vertices, adverbs[advCount-1], i) #fetching the previous adverb             
              #if such an edge exists - DELETE IT
              if(!v1.nil? and !v2.nil? and (e = search_edges_to_set_null(@edges, v1, v2, i)) != -1)
                @edges[e] = nil #setting the edge to null
                if(@num_edges > 0)
                  @num_edges-=1 #deducting an edge count
                end
              end
            end
            #if this verb vertex was encountered for the first time, vCount < 1,
            #so do adding of edge outside the if condition
            #add a new edge with v1 as the adverb and v2 as the new verb
            v1 = search_vertices(@vertices, adverbs[advCount-1], i)
            v2 = verbVertex
            #if such an edge did not already exist
            if(!v1.nil? and !v2.nil? and (e = search_edges(@edges, v1, v2, i)) == -1)
              @edges[@num_edges] = Edge.new("verb-property",VERB)
              @edges[@num_edges].in_vertex = v1
              @edges[@num_edges].out_vertex = v2
              @edges[@num_edges].index = i
              @num_edges+=1 
              #since an edge was just added we try to check if there exist any redundant edges that can be removed
              remove_redundant_edges(v1, v2, i)
            end
          end
          
          #making the previous noun, one of the vertices of the verb edge
          if(nCount > 0) #and fAppendedVertex == 0 
            #gets the previous noun to form the edge
            v1 = search_vertices(@vertices, nouns[nCount-1], i)
            v2 = verbVertex
            #if such an edge does not already exist add it
            if(!v1.nil? and !v2.nil? and (e = search_edges(@edges, v1, v2, i)) == -1)
              @edges[@num_edges] = Edge.new("verb",VERB)
              @edges[@num_edges].in_vertex = v1 #for nCount = 0;
              @edges[@num_edges].out_vertex = v2 #the verb
              @edges[@num_edges].index = i
              @num_edges+=1
              #since an edge was just added we try to check if there exist any redundant edges that can be removed
              remove_redundant_edges(v1, v2, i)
            end
          end
          prevType = VERB
        #------------------------------------------ 
        #if the string is an adverb
        elsif(taggedToken.include?("RB"))
          adverb = nil
          if(prevType == ADV) #appending to existing adverb
            if(advCount >= 1)
              advCount = advCount - 1
            end
            prevVertex = search_vertices(@vertices, adverbs[advCount], i) #fetching the previous vertex
            adverbs[advCount] = adverbs[advCount] + " " + plainToken
            #if the concatenated vertex didn't already exist
            if((adverb = search_vertices(@vertices, adverbs[advCount], i)) == nil)
              prevVertex.name = prevVertex.name + " " + plainToken
              adverb = prevVertex #setting it as "adverb" for further computation
              if(labels[labelCounter] != "NMOD" or labels[labelCounter] != "PMOD") #resetting labels for the concatenated vertex
                adverb.label = labels[labelCounter]
              end
            end
          else #else creating a new vertex
            adverbs[advCount] = plainToken
            if((adverb = search_vertices(@vertices, plainToken, i)) == nil)
              @vertices[@num_vertices] = Vertex.new(adverbs[advCount], ADV, i, state, labels[labelCounter], parents[parentCounter], posTag);
              adverb = @vertices[@num_vertices]
              @num_vertices+=1
            end
          end  
          remove_redundant_vertices(adverbs[advCount], i)        
          advCount+=1
          
          #by default associate it with the previous/latest verb and if there is a verb following it immediately, then remove the property from the verb
          if(vCount > 0) #gets the previous verb to form a verb-adverb edge
            v1 = search_vertices(@vertices, verbs[vCount-1], i)
            v2 = adverb
            #if such an edge does not already exist add it
            if(!v1.nil? and !v2.nil? && (e = search_edges(@edges, v1, v2, i)) == -1)
              @edges[@num_edges] = Edge.new("verb-property",VERB)
              @edges[@num_edges].in_vertex = v1 #for nCount = 0;
              @edges[@num_edges].out_vertex = v2 #the verb
              @edges[@num_edges].index = i
              @num_edges+=1
              #since an edge was just added we try to check if there exist any redundant edges that can be removed
              remove_redundant_edges(v1, v2, i)
            end
          end
          prevType = ADV
        #end of if condition for adverb
      end #end of if condition
      #------------------------------------------ 
      #incrementing counters for labels and parents
      labelCounter+=1
      parentCounter+=1      
    end #end of the for loop for the tokens
    #puts "here outside the for loop for tokens"
    nouns = nil
    verbs = nil
    adjectives = nil
    adverbs = nil
  end #end of number of sentences in the text

  @num_vertices = @num_vertices - 1 #since as a counter it was 1 ahead of the array's contents
  @num_edges = @num_edges - 1 #same reason as for num_vertices
  set_semantic_labels_for_edges
  #print_graph(@edges, @vertices)
  # puts("Number of edges:: #{@num_edges}")
  # puts("Number of vertices:: #{@num_vertices}")
  return @num_edges
end #end of the graphGenerate method

#------------------------------------------#------------------------------------------#------------------------------------------

def search_vertices(list, s, index)
    for i in (0..list.length-1)
      if(!list[i].nil? and !s.nil?)      
        #if the vertex exists and in the same sentence (index)
        if(list[i].name.casecmp(s) == 0 and list[i].index == index)
          # puts("***** search_vertices:: Returning:: #{s}")
          return list[i]
        end
      end
    end
    # puts("***** search_vertices:: Returning nil")
    return nil
end #end of the search_vertices method

#------------------------------------------#------------------------------------------#------------------------------------------

=begin
NULLIFY ALL VERTICES CONTAINING "ONLY SUBSTRINGS" (and not exact matches) OF THIS VERTEX IN THE SAME SENTENCE (verts[j].index == index)
And reset the @vertices array with non-null elements.
=end
def remove_redundant_vertices(s, index)
  # puts "**** remove_redundant_vertices:: string #{s}"
  j = @num_vertices - 1
  verts = @vertices
  while j >= 0
   if(!verts[j].nil? and verts[j].index == index and s.casecmp(verts[j].name) != 0 and 
     (s.downcase.include?(verts[j].name.downcase) and verts[j].name.length > 1)) 
     #the last 'length' condition is added so as to prevent "I" (an indiv. vertex) from being replaced by nil
     # puts "*** string index = #{index}... verts[j].index = #{verts[j].index}"
     # puts "**** remove_redundant_vertices setting #{verts[j].name} to nil!"
     #search through all the edges and set those with this vertex as in-out- vertex to null
     if(!@edges.nil?)
       for i in 0..@edges.length - 1
         edge = @edges[i]
         if(!edge.nil? and (edge.in_vertex == verts[j] or edge.out_vertex == verts[j]))
           # puts "edge #{edge.in_vertex.name} - #{edge.out_vertex.name}"
           @edges[i] = nil #setting that edge to nil
         end 
       end
     end
     #finally setting the vertex to  null
     verts[j] = nil
   end
   j-=1
  end #end of while loop

  # puts "**** remove_redundant_vertices Old @num_vertices:: #{@num_vertices}"          
  #recreating the vertices array without the nil values
  counter = 0
  vertices_array = Array.new
  for i in (0..verts.length-1)
    vertex = verts[i]
    if(!vertex.nil?)
      vertices_array << vertex
      counter+=1
    end
  end 
  @vertices = vertices_array
  @num_vertices = counter+1 #since @num_vertices is always one advanced of the last vertex
end  
  
#------------------------------------------#------------------------------------------#------------------------------------------

=begin
  Checks to see if an edge between vertices "in" and "out" exists.
  true - if an edge exists and false - if an edge doesn't exist
  edge[] list, vertex in, vertex out, int index
=end
def search_edges(list, in_vertex, out, index)
  edgePos = -1
  if(list.nil?)#if the list is null
    return edgePos
  end
  
  for i in (0..list.length-1)
    if(!list[i].nil? and !list[i].in_vertex.nil? and !list[i].out_vertex.nil?)
      #checking for exact match with an edge
      if(((list[i].in_vertex.name.casecmp(in_vertex.name)==0 or list[i].in_vertex.name.include?(in_vertex.name)) and 
        (list[i].out_vertex.name.casecmp(out.name)==0 or list[i].out_vertex.name.include?(out.name))) or 
        ((list[i].in_vertex.name.casecmp(out.name)==0 or list[i].in_vertex.name.include?(out.name)) and 
        (list[i].out_vertex.name.casecmp(in_vertex.name)==0 or list[i].out_vertex.name.include?(in_vertex.name))))
        # puts("***** Found edge! : index:: #{index} list[i].index:: #{list[i].index}")
        #if an edge was found
        edgePos = i #returning its position in the array
        #INCREMENT FREQUENCY IF THE EDGE WAS FOUND IN A DIFFERENT SENT. (CHECK BY MAINTAINING A TEXT NUMBER AND CHECKING IF THE NEW # IS DIFF FROM PREV #)
        if(index != list[i].index)
          list[i].frequency+=1
        end
      end
    end        
  end #end of the for loop  
  return edgePos
end # end of searchdges
#------------------------------------------#------------------------------------------#------------------------------------------

def search_edges_to_set_null(list, in_vertex, out, index)
  edgePos = -1
  # puts("***** Searching edge to set to null:: #{in_vertex.name} - #{out.name} ... num_edges #{@num_edges}")
  for i in 0..@num_edges - 1
    if(!list[i].nil? and !list[i].in_vertex.nil? and !list[i].out_vertex.nil?)
      # puts "comparing with #{list[i].in_vertex.name} - #{list[i].out_vertex.name}"
      #puts "#{list[i].in_vertex.name.downcase == in_vertex.name.downcase} - #{list[i].out_vertex.name.downcase == out.name.downcase}"
      #checking for exact match with an edge
      if((list[i].in_vertex.name.downcase == in_vertex.name.downcase and list[i].out_vertex.name.downcase == out.name.downcase) or
              (list[i].in_vertex.name.downcase == out.name.downcase and list[i].out_vertex.name.downcase == in_vertex.name.downcase))
        #if an edge was found
        edgePos = i #returning its position in the array
        #INCREMENT FREQUENCY IF THE EDGE WAS FOUND IN A DIFFERENT SENT. (CHECK BY MAINTAINING A TEXT NUMBER AND CHECKING IF THE NEW # IS DIFF FROM PREV #)
        if(index != list[i].index)
          list[i].frequency+=1
        end
      end
    end 
  end #end of the for loop 
  # puts("***** search_edges_to_set_null #{in_vertex.name} - #{out.name} returning:: #{edgePos}")
  return edgePos
end # end of the method search_edges_to_set_null 
#------------------------------------------#------------------------------------------#------------------------------------------
=begin
NULLIFY ALL EDGES CONTAINING "ONLY SUBSTRINGS" (and not exact matches) OF EITHER IN/OUT VERTICES IN THE SAME SENTENCE (verts[j].index == index)
And reset the @edges array with non-null elements.
=end

def remove_redundant_edges(in_vertex, out, index)
  list = @edges
  j = @num_edges - 1
  while j >= 0 do
    if(!list[j].nil? and list[j].index == index)
     #when invertices are eq and out-verts are substrings or vice versa
      if(in_vertex.name.casecmp(list[j].in_vertex.name) == 0 and out.name.casecmp(list[j].out_vertex.name) != 0 and out.name.downcase.include?(list[j].out_vertex.name.downcase))
        # puts("FOUND out_vertex match for edge:: #{list[j].in_vertex.name} - #{list[j].out_vertex.name}")
        list[j] = nil
        #@num_edges-=1
        #when in-vertices are only substrings and out-verts are equal
      elsif(in_vertex.name.casecmp(list[j].in_vertex.name)!=0 and in_vertex.name.downcase.include?(list[j].in_vertex.name.downcase) and out.name.casecmp(list[j].out_vertex.name)==0)
        # puts("FOUND in_vertex match for edge: #{list[j].in_vertex.name} - #{list[j].out_vertex.name}")
        list[j] = nil
        #@num_edges-=1
      end
    end
    j-=1
  end #end of the while loop
  # puts "**** search_edges:: Old number #{@num_edges}"
  #recreating the edges array without the nil values
  counter = 0
  edges_array = Array.new
  list.each{
    |edge|
    if(!edge.nil?)
      # puts "edge:: #{edge.in_vertex.name} - #{edge.out_vertex.name}"
      edges_array << edge
      counter+=1
    end
    }  
  @edges = edges_array
  @num_edges = counter+1
  # puts "**** search_edges:: New number of edges #{@num_edges}"
end

#------------------------------------------#------------------------------------------#------------------------------------------
def print_graph(edges, vertices)
  puts("*** List of vertices::")
  for j in (0..vertices.length-1) 
    if(!vertices[j].nil?)
      puts("@@@ Vertex:: #{vertices[j].name}")
      puts("*** Frequency:: #{vertices[j].frequency} State:: #{vertices[j].state}")
      puts("*** Label:: #{vertices[j].label} Parent:: #{vertices[j].parent}")
    end
  end
  puts("*******")
  puts("*** List of edges::")
  for j in (0..edges.length-1)
    if(!edges[j].nil? and !edges[j].in_vertex.nil? and !edges[j].out_vertex.nil?)
      puts("@@@ Edge:: #{edges[j].in_vertex.name} & #{edges[j].out_vertex.name}")
      puts("*** Frequency:: #{edges[j].frequency} State:: #{edges[j].in_vertex.state} & #{edges[j].out_vertex.state}")
      puts("*** Label:: #{edges[j].label}")
    end
  end
  puts("--------------")
end #end of print_graph method

#------------------------------------------#------------------------------------------#------------------------------------------
#Identifying parents and labels for the vertices
def find_parents(t)
  # puts "Inside find_parents.. text #{t}"
  tp = TextPreprocessing.new  
  unTaggedString = t.split(" ")
  parents = Array.new
  #  t = text[i]
  t = StanfordCoreNLP::Text.new(t) #the same variable has to be passed into the Textx.new method
  @pipeline.annotate(t)
  #for each sentence identify theparsed form of the sentence
  sentence = t.get(:sentences).toArray
  parsed_sentence = sentence[0].get(:collapsed_c_c_processed_dependencies)
  #puts "parsed sentence #{parsed_sentence}"  
  #iterating through the set of tokens and identifying each token's parent
  #puts "unTaggedString.length #{unTaggedString.length}"
  for j in (0..unTaggedString.length - 1)
    #puts "unTaggedString[#{j}] #{unTaggedString[j]}"
    if(tp.is_punct(unTaggedString[j]))
      next
    end
    if(tp.contains_punct(unTaggedString[j]))
      unTaggedString[j] = tp.contains_punct(unTaggedString[j])
      # puts "unTaggedString #{unTaggedString[j]} and #{tp.contains_punct_bool(unTaggedString[j])}"
    end
    if(!unTaggedString[j].nil? and !tp.contains_punct_bool(unTaggedString[j]))
      pat = parsed_sentence.getAllNodesByWordPattern(unTaggedString[j])
      pat = pat.toArray
      parent = parsed_sentence.getParents(pat[0]).toArray
    end
    #puts "parent of #{unTaggedString[j]} is #{parent[0]}"
    if(!parent.nil? and !parent[0].nil?)
      parents[j] =  (parent[0].to_s)[0..(parent[0].to_s).index("-")-1]#extracting the name of the parent (since it is in the foramt-> "name-POS")
      #puts "parents[#{j}] = #{parents[j]}"
    else
      parents[j] = nil
    end
  end
  return parents
end #end of find_parents method
#------------------------------------------#------------------------------------------#------------------------------------------
#Identifying parents and labels for the vertices
def find_labels(t)
  # puts "Inside find_labels"
  unTaggedString = t.split(" ")
  t = StanfordCoreNLP::Text.new(t)
  @pipeline.annotate(t)
  #for each sentence identify theparsed form of the sentence
  sentence = t.get(:sentences).toArray
  parsed_sentence = sentence[0].get(:collapsed_c_c_processed_dependencies)    
  labels = Array.new
  labelCounter = 0
  govDep = parsed_sentence.typedDependencies.toArray
  #for each untagged token
  for j in (0..unTaggedString.length - 1)
    unTaggedString[j].gsub!(".", "")
    unTaggedString[j].gsub!(",", "")
    #puts "Label for #{unTaggedString[j]}"
    #identify its corresponding position in govDep and fetch its label
    for k in (0..govDep.length - 1)
      #puts "Comparing with #{govDep[k].dep.value()}"
      if(govDep[k].dep.value() == unTaggedString[j])
        labels[j] = govDep[k].reln.getShortName()
        #puts labels[j]
        labelCounter+=1
        break
      end
    end
  end
  return labels
end # end of find_labels method
#------------------------------------------#------------------------------------------#------------------------------------------
=begin
   * Setting semantic labels for edges based on the labels vertices have with their parents
=end
def set_semantic_labels_for_edges
  # puts "*** inside set_semantic_labels_for_edges"
  for i in (0.. @vertices.length - 1)
    if(!@vertices[i].nil? and !@vertices[i].parent.nil?) #parent = null for ROOT
        #search for the parent vertex
        for j in (0..@vertices.length - 1)
          if(!@vertices[j].nil? and (@vertices[j].name.casecmp(@vertices[i].parent) == 0 or 
                @vertices[j].name.downcase.include?(@vertices[i].parent.downcase)))
            # puts("**Parent:: #{@vertices[j].name}")
            parent = @vertices[j]
            break #break out of search for the parent
          end
        end
        if(!parent.nil?)#{
          #check if an edge exists between vertices[i] and the parent
          for k in (0..@edges.length - 1)
            if(!@edges[k].nil? and !@edges[k].in_vertex.nil? and !@edges[k].out_vertex.nil?)
              if((@edges[k].in_vertex.name.equal?(@vertices[i].name) and @edges[k].out_vertex.name.equal?(parent.name)) or (@edges[k].in_vertex.name.equal?(parent.name) and @edges[k].out_vertex.name.equal?(@vertices[i].name)))
                #set the role label
                if(@edges[k].label.nil?)
                  @edges[k].label = @vertices[i].label
                elsif(!@edges[k].label.nil? and (@edges[k].label == "NMOD" or @edges[k].label == "PMOD") and (@vertices[i].label != "NMOD" or @vertices[i].label != "PMOD"))
                  @edges[k].label = @vertices[i].label
                end
              end  
            end
          end
        end#end of if paren.nil? condition
    end  
  end #end of for loop
end #end of set_semantic_labels_for_edges method 

end # end of the class GraphGenerator
#------------------------------------------#------------------------------------------#------------------------------------------
=begin
 Identifying frequency of edges and pruning out edges that do no meet the threshold conditions 
=end
def identify_frequency_and_prune_edges(edges, num)
  # puts "inside frequency threshold! :: num #{num}"
  #freqEdges maintains the top frequency edges from ALPHA_FREQ to BETA_FREQ
  freqEdges = Array.new #from alpha = 3 to beta = 10
  #iterating through all the edges
  for j in (0..num-1) 
    if(!edges[j].nil?)       
      if(edges[j].frequency <= BETA_FREQ and edges[j].frequency >= ALPHA_FREQ and !freqEdges[edges[j].frequency-1].nil?)#{
        for i in (0..freqEdges[edges[j].frequency-1].length - 1)#iterating to find i for which freqEdges is null
          if(!freqEdges[edges[j].frequency-1][i].nil?)
            break
          end
        end
        freqEdges[edges[j].frequency-1][i] = edges[j]
      end
    end
  end
  selectedEdges = Array.new  
  #Selecting only those edges that satisfy the frequency condition [between ALPHA and BETA]
  j = BETA_FREQ-1
  while j >= ALPHA_FREQ-1 do 
    if(!freqEdges[j].nil?)
      for i in (0..num-1)
        if(!freqEdges[j][i].nil?)
          selectedEdges[maxSelected] = freqEdges[j][i]
          maxSelected+=1
        end
      end
    end
    j-=1
  end
    
  if(maxSelected != 0)
    @num_edges = maxSelected #replacing numEdges with the number of selected edges
  end
  return selectedEdges
end 
#------------------------------------------#------------------------------------------#------------------------------------------