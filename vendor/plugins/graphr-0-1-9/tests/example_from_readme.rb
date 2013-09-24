	# Lets crank out a simple graph...
	require 'graph/graphviz_dot'

	# We create a DotGraphPrinter from some links.
        # In this simple example we don't even have a "real" graph
	# just an Array with the links. The optional third 
        # element of a link is link information. The nodes in this graph
	# are implicit in the links. If we had additional nodes that were
	# not linked we would supply them in an array as 2nd parameter to new.
	links = [[:start, 1, "*"], [1, 1, "a"], [1, 2, "~a"], [2, :stop, "*"]]
        dgp = DotGraphPrinter.new(links)

	# We specialize the printer to change the shape of nodes
	# based on their names.
	dgp.node_shaper = proc{|n| 
	  ["start", "stop"].include?(n.to_s) ? "doublecircle" : "box"
        }

	# We can also set the attributes on individual nodes and edges. 
	# These settings override the default shapers and labelers.
	dgp.set_node_attributes(2, :shape => "diamond")

	# Add URL link from node (this only work in some output formats?)
	# Note the extra quotes needed!
	dgp.set_node_attributes(2, :URL => '"node2.html"')

	# And now output to files
	puts dgp.to_dot_specification
	dgp.write_to_file("g.png", "png") # Generate png file
	dgp.orientation = "landscape"      # Dot problem with PS orientation
	dgp.write_to_file("g.ps")          # Generate postscript file

