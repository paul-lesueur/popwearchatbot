class MessagesController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @deadline = @chat.deadline

    user_message = "Génère un message client pour prévenir d'un retard."

    @chat.messages.create!(
      role: "user",
      content: user_message
    )

    prompt = client_message_prompt(@deadline)

    response = RubyLLM.chat(model: "gpt-4o").ask(prompt)

    @chat.messages.create!(
      role: "assistant",
      content: response.content
    )

    redirect_to deadline_chat_path(@deadline, @chat)
  end

  private

  def client_message_prompt(deadline)
    <<~PROMPT
      Tu es un assistant IA spécialisé pour les couturiers, retoucheurs et cordonniers.

      L'artisan doit prévenir un client qu'une prestation risque d'avoir du retard.

      Informations de l'échéance :
      - Titre : #{deadline.title}
      - Description : #{deadline.description}
      - Catégorie : #{deadline.category}
      - Date limite : #{deadline.due_date}
      - Durée estimée : #{deadline.estimated_duration} minutes

      Ta mission :
      Rédige un message client poli, clair, professionnel et rassurant.

      Contraintes :
      - Réponds en français.
      - Le message doit être prêt à envoyer.
      - Le ton doit être humain et professionnel.
      - Ne sois pas trop long.
      - Ne mets pas de titre.
      - Ne mentionne pas que tu es une IA.
    PROMPT
  end
end
