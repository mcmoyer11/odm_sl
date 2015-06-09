# Author: Bruce Tesar
# 

# Temporarily turn off (verbose) warnings, to surpress (some of) the warnings
# about the source code for graphviz.
verbose_val = $VERBOSE
$VERBOSE = false
require 'graphviz'
require_relative 'dq'
$VERBOSE = verbose_val

# This class uses Graphviz to create ranking diagrams for appropriately
# formed comparative tableaux.
# When a new RankingDiagram object is created, a graphviz graph is
# automatically constructed for the provided comparative tableau.
# Image files can then be created by calling, on the RankingDiagram object,
# instance methods for the supported image formats.
# The ruby-graphviz gem presumes that you have the Graphviz software installed
# and accessible (on your search path). Graphviz is open source graph
# visualization software; for more information, and to download Graphviz,
# go to http://www.graphviz.org/.
class RankingDiagram

  def initialize(ct, label="RankingDiagram")
    @comp_tableau = ct
    @graph = GraphViz::new(label, "type" => "digraph" )
    create_graph
  end

  def create_graph
    set_graph_properties
    create_nodes
    create_edges
  end
  private :create_graph

  def set_graph_properties
    @graph.graph[:charset] = "UTF-8"
#    @graph.graph[:orientation] = "portrait"  # causes error with ruby-graphviz v. 1.0.5
    @graph.graph[:ranksep] = "0.3"
    @graph.graph[:pad] = ".1"
    #
    @graph.node[:fontname] = "Arial"
    @graph.node[:shape] = "box"
    @graph.node[:style] = "rounded"
    @graph.node[:color] =  "blue"
    @graph.node[:penwidth] = "0.5"
    #
    @graph.edge[:dir] = "none"
    @graph.edge[:penwidth] = "0.5"
  end
  private :set_graph_properties

  # Create a graph node for each constraint, using the name of
  # the constraint as both the name and the label of the node.
  def create_nodes
    @comp_tableau.constraint_list.each do |n|
      # Add a node for each constraint, using the constraint name
      # as both node name and node label.
      @graph.add_node(n.name).label = n.name
      # ruby-graphviz v.1.0.3 deprecated #add_node in favor of #add_nodes, so
      # the line below replaces the (commented out) line above.
      #@graph.add_nodes(n.name).label = n.name
    end
  end
  private :create_nodes

  # Create a directed graph edge for each W-L pair appearing in an ERC of
  # the comparative tableau. The directed edges are defined as going from
  # the W (dominating) constraint to the L (dominated) constraint.
  def create_edges
    edge_list = []
    @comp_tableau.each do |erc|
      # Convert sets of W and L constraints to arrays
      w_cons, l_cons = erc.w_cons.to_a, erc.l_cons.to_a
      # Take cartesian product of W and L constraints (W constraint first
      # in the pair), and add the pairs to the edge list.
      edge_list += w_cons.product(l_cons)
    end
    # For each W-L pair in the edge_list, add an edge to the graph.
    edge_list.each { |e| @graph.add_edge(e[0].name, e[1].name) }
    # ruby-graphviz v.1.0.3 deprecated #add_edge in favor of #add_edges, so
    # the line below replaces the (commented out) line above.
    #edge_list.each { |e| @graph.add_edges(e[0].name, e[1].name) }
  end
  private :create_edges

  # Generate a png (portable network graphics) image of the graph,
  # and store it in a file named as per the parameter.
  #--
  # Ruby-graphviz has trouble with filepaths with spaces in them,
  # so add double-quotes around the filepath/name.
  #++
  def png(outfilename)
    @graph.output(:png => "#{outfilename}.png".dq)
  end

  # Generate an eps (encapsulated postscript) image of the graph,
  # and store it in a file named as per the parameter.
  #--
  # Ruby-graphviz has trouble with filepaths with spaces in them,
  # so add double-quotes around the filepath/name.
  #++
  def eps(outfilename)
    @graph.output(:eps => "#{outfilename}.eps".dq)
  end

  # Returns the size of the PNG image stored in the file of name +fname+,
  # as an array [width, height] giving the values in points.
  def RankingDiagram.png_size(fname)
    # Read the first 24 bytes of the image file into a string.
    prefix = nil
    File.open(fname, mode: "rb"){|fh| prefix = fh.read(24)}
    # A PNG file has bytes 1-3 with the value "PNG".
    raise "RankingDiagram.png_size: file #{fname} is not PNG." unless prefix[1..3] == "PNG"
    # Read the picture size (in points) from bytes 16-24.
    return prefix[16..24].unpack('NN')
  end

end # class RankingDiagram
