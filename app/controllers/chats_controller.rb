class ChatsController < ApplicationController
  def create
    @deadline = current_user.deadlines.find(params[:deadline_id])

    @chat = @deadline.chats.find_or_create_by!(
      user: current_user,
      title: "Message client"
    )

    redirect_to deadline_chat_path(@deadline, @chat)
  end

  def show
    @deadline = current_user.deadlines.find(params[:deadline_id])
    @chat = @deadline.chats.find(params[:id])
    @messages = @chat.messages.order(:created_at)
  end
end
