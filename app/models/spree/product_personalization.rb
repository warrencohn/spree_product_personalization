module Spree
  class ProductPersonalization < ActiveRecord::Base
    include Spree::Core::CalculatedAdjustments

    belongs_to :product

    before_save { self.calculator.preferred_currency = Spree::Config[:currency] }

    def self.permitted_attributes 
      [:id, :name, :required, :limit, :_destroy, :calculator_attributes => [:id, :type, :preferred_amount]]
    end

  end
end
