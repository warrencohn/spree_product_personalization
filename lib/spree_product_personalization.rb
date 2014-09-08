require 'spree_core'
require 'spree_product_personalization/engine'

module Spree
  module Personalization
    def self.config(&block)
      yield(Spree::Personalization::Config)
    end
  end
end