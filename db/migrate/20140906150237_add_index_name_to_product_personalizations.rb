class AddIndexNameToProductPersonalizations < ActiveRecord::Migration
  def change
    add_index :spree_product_personalizations, [:product_id, :name], :unique => true
  end
end
