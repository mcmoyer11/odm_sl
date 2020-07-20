# frozen_string_literal: true

# Author: Bruce Tesar

require 'feature_instance'

# This class handles the calculation of "corresponding" feature instances
# with respect to some correspondence relation, where the relation holds
# between elements that bear the features.
class FeatureCorrRouter
  # The word defining the correspondence relations to be used.
  attr_accessor :word

  # :call-seq:
  #   FeatureCorrRouter.new -> router
  #--
  # feat_inst_class is a dependency injection used for testing.
  def initialize(feat_inst_class: FeatureInstance)
    @feat_inst_class = feat_inst_class
    @word = nil
  end

  # Given an output feature instance _out_finst_, this returns the
  # corresponding input feature instance.
  # Returns nil if _out_finst_ is not a member of the word's output.
  # Returns nil if _out_finst_ has no input correspondent in the word.
  def in_feat_corr_of_out(out_finst)
    # Ensure the parameter belongs to the output
    return nil unless @word.output.member?(out_finst.element)

    in_element = @word.io_in_corr(out_finst.element)
    return nil if in_element.nil?

    in_feature = in_element.get_feature(out_finst.feature.type)
    @feat_inst_class.new(in_element, in_feature)
  end

  # Given an input feature instance _in_finst_, this returns the
  # corresponding output feature instance.
  # Returns nil if _in_finst_ is not a member of the word's input.
  # Returns nil if _in_finst_ has no output correspondent in the word.
  def out_feat_corr_of_in(in_finst)
    # Ensure the parameter belongs to the input
    return nil unless @word.input.member?(in_finst.element)

    out_element = @word.io_out_corr(in_finst.element)
    return nil if out_element.nil?

    out_feature = out_element.get_feature(in_finst.feature.type)
    @feat_inst_class.new(out_element, out_feature)
  end

  # Given an input feature instance _in_finst_, this returns the
  # corresponding underlying feature instance.
  # Returns nil if _in_finst_ is not a member of the word's input.
  # Returns nil if _in_finst_ has no underlying correspondent in the word.
  def uf_feat_corr_of_in(in_finst)
    # Ensure the parameter belongs to the input
    return nil unless @word.input.member?(in_finst.element)

    uf_element = @word.ui_corr.under_corr(in_finst.element)
    return nil if uf_element.nil?

    uf_feature = uf_element.get_feature(in_finst.feature.type)
    @feat_inst_class.new(uf_element, uf_feature)
  end

  # Given a UF feature instance _uf_finst_, this returns the
  # corresponding input feature instance.
  # Returns nil if _uf_finst_ is not a member of the word's UF.
  # Returns nil if _uf_finst_ has no input correspondent in the word.
  def in_feat_corr_of_uf(uf_finst)
    # Ensure the parameter belongs to the UF
    return nil unless @word.ui_corr.in_corr?(uf_finst.element)

    in_element = @word.ui_corr.in_corr(uf_finst.element)
    return nil if in_element.nil?

    in_feature = in_element.get_feature(uf_finst.feature.type)
    @feat_inst_class.new(in_element, in_feature)
  end

  # Given a UF feature instance _uf_finst_, this returns the
  # corresponding output feature instance.
  # Returns nil if _uf_finst_ is not a member of the word's UF.
  # Returns nil if _uf_finst_ has no input correspondent in the word.
  def out_feat_corr_of_uf(uf_feat_inst)
    in_feat_inst = in_feat_corr_of_uf(uf_feat_inst)
    # If uf feat has no input correspondent, then it has no output
    # correspondent.
    return nil if in_feat_inst.nil?

    out_feat_corr_of_in(in_feat_inst)
  end
end
