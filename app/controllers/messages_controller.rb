class MessagesController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @deadline = @chat.deadline

    prompt = client_message_prompt(@deadline)

    @chat.messages.create!(
      role: "user",
      content: "Génère un message client pour prévenir d’un retard."
    )

    ai_response = fake_ai_response(@deadline)

    @chat.messages.create!(
      role: "assistant",
      content: ai_response
    )

    redirect_to deadline_chat_path(@deadline, @chat)
  end

  private

  def client_message_prompt(deadline)
    <<~PROMPT
      Rédige un message client poli et professionnel pour prévenir d'un retard.

      Informations de l'échéance :
      - Titre : #{deadline.title}
      - Description : #{deadline.description}
      - Catégorie : #{deadline.category}
      - Date limite : #{deadline.due_date}

      Le message doit être court, clair, rassurant et prêt à envoyer.
    PROMPT
  end

  def fake_ai_response(deadline)
    "Bonjour, je vous informe que votre commande « #{deadline.title} » prendra un peu plus de temps que prévu. Je fais le nécessaire pour la finaliser avec soin et je vous tiendrai informé très rapidement. Merci beaucoup pour votre compréhension."
  end
end
