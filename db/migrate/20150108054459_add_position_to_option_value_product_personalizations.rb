class AddPositionToOptionValueProductPersonalizations < ActiveRecord::Migration
  def change
    add_column :spree_option_value_product_personalizations, :position, :integer, :default => 1   
  end
end
