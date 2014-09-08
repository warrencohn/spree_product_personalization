module Spree
  AppConfiguration.class_eval do
    preference :personalization_text_limit, :integer, default: 2000
    preference :personalization_label_limit, :integer, default: 100

  end
end
