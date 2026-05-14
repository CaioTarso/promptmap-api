class CreateCommentLikes < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :comment_likes_count, :integer, default: 0, null: false

    create_table :comment_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true

      t.timestamps
    end

    add_index :comment_likes, [ :user_id, :comment_id ], unique: true
  end
end
