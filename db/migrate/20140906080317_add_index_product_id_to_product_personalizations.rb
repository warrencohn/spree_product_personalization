class AddIndexProductIdToProductPersonalizations < ActiveRecord::Migration
  def change
    add_index :spree_product_personalizations, :product_id
  end
end
