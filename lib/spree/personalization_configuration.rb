module Spree
  class PersonalizationConfiguration < Preferences::Configuration
    preference :text_limit, :integer, default: 2000
    preference :label_limit, :integer, default: 100
    preference :description_limit, :integer, default: 200
  end
end