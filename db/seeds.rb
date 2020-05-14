# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.destroy_all

Category.create!([
    {name: "Cardio"},
    {name: "Machines"},
    {name: "Free Weights"}
])

User.destroy_all

admin = User.create(email: "admin@admin.com", password: "123456")
admin.add_role :admin

User.create!([
    {email: "jets@test.com", password: "123456"},
    {email: "anytime@test.com", password: "123456"},
    {email: "golds@test.com", password: "123456"},
    {email: "renter@test.com", password: "123456"},
    {email: "rocky@test.com", password: "123456"},
    {email: "arnie@test.com", password: "123456"}
])