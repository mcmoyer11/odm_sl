# frozen_string_literal: true

# Author: Bruce Tesar

# OTLearn contains code specifically related to learning in OT systems.
module OTLearn
  # Pre-defined type constants

  # Indicates phontactic learning step
  PHONOTACTIC = :phonotactic
  # Indicates single form learning step
  SINGLE_FORM = :single_form
  # indicates contrast pair learning step
  CONTRAST_PAIR = :contrast_pair
  # indicates induction learning step
  INDUCTION = :induction
  # indicates an error learning step
  ERROR = :error

  # indicates fewest set features induction substep
  FEWEST_SET_FEATURES = :fewest_set_features
  # indicates max mismatch ranking induction substep
  MAX_MISMATCH_RANKING = :max_mismatch_ranking
end
