class Api::V1::TagsController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: Tag.order(:name)
  end

  def show
    @tag = Tag.find(params[:id])
    render json: @tag
  end
end
