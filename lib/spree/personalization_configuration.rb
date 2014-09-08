module Spree
  class PersonalizationConfiguration < Preferences::Configuration
    preference :text_limit, :integer, default: 2000
    preference :label_limit, :integer, default: 100
  end
end