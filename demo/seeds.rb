# Fictional data, exclusively for the isolated portfolio demonstration.
raise 'Demo database required' unless Mongoid.default_client.database.name == 'lynx_note_demo'
unless User.where(email: 'alex@example.com').exists?
  alex = User.create!(name: 'Alex', email: 'alex@example.com', password: 'DemoLynx2026!', role: 'user')
  sara = User.create!(name: 'Sara', email: 'sara@example.com', password: 'DemoLynx2026!', role: 'user')
  leo = User.create!(name: 'Leo', email: 'leo@example.com', password: 'DemoLynx2026!', role: 'user')
  User.create!(name: 'Admin demo', email: 'admin@example.com', password: 'DemoLynx2026!', role: 'admin')
  Friendship.create!(user: alex, friend: sara, status: 'accepted')
  Friendship.create!(user: leo, friend: alex, status: 'pending')
  welcome = Note.create!(user: alex, title: 'Ideas para mi portfolio', content: [
    {type: 'text', value: 'Un lugar para guardar ideas, preparar proyectos y compartir lo importante.'}.to_json,
    {type: 'list', value: 'Elegir los proyectos;Preparar una demo;Publicar el portfolio'}.to_json
  ])
  Note.create!(user: alex, title: 'Apuntes de Sistemas Web', content: [
    {type: 'text', value: 'Ruby on Rails organiza la aplicación con el patrón Modelo, Vista y Controlador.'}.to_json,
    {type: 'list', value: 'Rutas y controladores;Vistas y formularios;Persistencia con MongoDB'}.to_json
  ])
  Note.create!(user: alex, title: 'Próximos pasos', content: [{type: 'text', value: 'Revisar los apuntes y preparar la próxima entrega con el equipo.'}.to_json])
  Collection.create!(user: alex, name: 'Portfolio', notes: [welcome.id.to_s])
  Collection.create!(user: alex, name: 'Universidad', notes: [])
  shared = Note.create!(user: sara, title: 'Reunión del equipo', content: [
    {type: 'text', value: 'Propuesta de Sara para preparar la presentación del proyecto.'}.to_json,
    {type: 'list', value: 'Revisar el diseño;Repartir las tareas;Ensayar la presentación'}.to_json
  ])
  Sharing.create!(owner: sara, shareable: shared, shared_with: [alex.id.to_s])
  Notification.create!(user: alex, message: 'Leo sent you a friend request.', notification_type: 'friend_request')
end
