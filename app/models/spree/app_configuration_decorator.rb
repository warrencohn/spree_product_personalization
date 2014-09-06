module Spree
  AppConfiguration.class_eval do
    preference :personalization_text_limit, :integer, default: 2000

  end
end
