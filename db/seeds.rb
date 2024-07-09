User.destroy_all

User.create!([
  { name: "Lionel messi", email: "messi@maas.com", password: 'contrasena' },
  { name: "Neymar", email: "neymar@maas.com", password: 'contrasena' },
  { name: "Cristiano ronaldo", email: "cristiano@maas.com", password: 'contrasena' },
])

puts 'Seeds insertados con éxito'