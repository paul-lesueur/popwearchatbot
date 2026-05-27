# db/seeds.rb
puts "Cleaning database..."
Deadline.destroy_all
User.destroy_all

puts "Creating user..."
user = User.create!(
  email: "marie@popwear.com",
  password: "password"
)

puts "Creating deadlines..."

# Échéance URGENTE (aujourd'hui)
Deadline.create!(
  title: "Retouche robe Mme Dupont",
  description: "Ourlet à reprendre + ajustement taille",
  category: "client",
  due_date: Date.today,
  status: "todo",
  estimated_duration: 90,
  user: user
)

# Échéance cette semaine
Deadline.create!(
  title: "Commander tissu bleu marine",
  description: "5 mètres chez le fournisseur Bernard",
  category: "atelier",
  due_date: Date.today + 3.days,
  status: "todo",
  estimated_duration: 30,
  user: user
)

# Échéance plus lointaine
Deadline.create!(
  title: "Facturation du mois",
  description: "Préparer les factures clients de mai",
  category: "comptable",
  due_date: Date.today + 15.days,
  status: "todo",
  estimated_duration: 120,
  user: user
)

puts "Created #{User.count} user and #{Deadline.count} deadlines ✅"
