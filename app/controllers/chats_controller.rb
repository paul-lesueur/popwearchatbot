class ChatsController < ApplicationController
  def create
    @deadline = current_user.deadlines.find(params[:deadline_id])

    @chat = @deadline.chats
                     .where(user: current_user, title: "Message client")
                     .first_or_create!

    prompt = client_message_prompt(@deadline)

    @chat.messages.create!(
      role: "user",
      content: "Génère un message client pour cette échéance."
    )

    response = RubyLLM.chat(model: "gpt-4o").ask(prompt)

    @chat.messages.create!(
      role: "assistant",
      content: response.content
    )

    redirect_to deadline_path(@deadline), notice: "Message client généré."
  end

  def show
    @deadline = current_user.deadlines.find(params[:deadline_id])
    @chat = @deadline.chats.find(params[:id])
    @messages = @chat.messages.order(:created_at)
  end

  private

  def client_message_prompt(deadline)
    <<~PROMPT
      Tu es un assistant IA spécialisé dans la communication client professionnelle.

      L'utilisateur veut envoyer un message clair, poli et rassurant à un client.

      Informations sur l'échéance :
      - Titre : #{deadline.title}
      - Description : #{deadline.description}
      - Catégorie : #{deadline.category}
      - Date limite : #{deadline.due_date}
      - Statut : #{deadline.status}

      Ta mission :
      Rédige un message client prêt à être envoyé.

      Contraintes très importantes :
      - Réponds uniquement avec le message final.
      - Ne mets pas d'introduction avant le message.
      - Ne mets pas de guillemets.
      - Ne mets jamais de champ entre crochets.
      - N'écris jamais "[Nom du client]".
      - N'écris jamais "[Prénom du client]".
      - N'écris jamais "[Votre nom]".
      - N'écris jamais "[Nom de l'entreprise]".
      - N'invente aucun prénom, aucun nom de client, aucun nom d'entreprise.
      - Commence toujours le message par "Bonjour,".
      - Termine toujours le message par "Cordialement,".
      - N'ajoute rien après "Cordialement,".
      - Ton professionnel, naturel et rassurant.
      - Message court : entre 4 et 8 lignes maximum.
      - Écris en français.
    PROMPT
  end
end
