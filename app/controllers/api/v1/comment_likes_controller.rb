class Api::V1::CommentLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment

  def create
    @comment_like = current_user.comment_likes.find_or_initialize_by(comment: @comment)

    if @comment_like.persisted?
      render_comment_like("Comment already liked", :ok)
    elsif @comment_like.save
      render_comment_like("Comment liked successfully", :created)
    else
      render json: @comment_like.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment_like = current_user.comment_likes.find_by(comment: @comment)

    if @comment_like
      @comment_like.destroy
      render_comment_like("Comment unliked successfully", :ok)
    else
      render json: { error: "Comment like not found" }, status: :not_found
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def render_comment_like(message, status)
    @comment.reload
    render json: {
      message: message,
      comment_id: @comment.id,
      comment_likes_count: @comment.comment_likes_count
    }, status: status
  end
end
