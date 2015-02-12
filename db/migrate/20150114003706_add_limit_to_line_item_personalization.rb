class AddLimitToLineItemPersonalization < ActiveRecord::Migration
  def change
    add_column :spree_line_item_personalizations, :limit, :integer, :default => 255
  end
end
