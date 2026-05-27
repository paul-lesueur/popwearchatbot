module DeadlinesHelper
  # Retourne la classe CSS selon l'urgence
  def urgency_class(deadline)
    days_left = (deadline.due_date - Date.today).to_i

    if days_left <= 0
      "urgency-red"
    elsif days_left <= 7
      "urgency-orange"
    else
      "urgency-green"
    end
  end

  # Retourne un label lisible selon l'urgence
  def urgency_label(deadline)
    days_left = (deadline.due_date - Date.today).to_i

    if days_left < 0
      "En retard"
    elsif days_left == 0
      "Aujourd'hui"
    elsif days_left <= 7
      "Cette semaine"
    else
      "Dans #{days_left} jours"
    end
  end

  # Traduit les catégories de la BDD pour l'affichage
  def category_label(category)
    {
      "client" => "Client",
      "atelier" => "Atelier",
      "administratif" => "Administratif",
      "comptable" => "Comptable"
    }[category] || category
  end

  # Traduit les statuts de la BDD pour l'affichage
  def status_label(status)
    {
      "todo" => "À faire",
      "in_progress" => "En cours",
      "done" => "Terminé"
    }[status] || status
  end
end
