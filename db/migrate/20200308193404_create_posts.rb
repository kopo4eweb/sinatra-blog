class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.text :title
      t.text :post
      t.text :username

      t.timestamps
    end

    create_table :comments do |t|
      t.text :comment
      t.belongs_to :post

      t.timestamps
    end
  end
end
