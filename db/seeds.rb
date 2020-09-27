# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Product.create!([
  {
    name: 'Elk Ridge Survival Axe',
    description: 'The Elk Ridge Survival Axe is as sharp, versatile, and dependable as the man who wields it. A great enhancement for the outdoor guy.',
    quantity: 10,
    price: 59.99,
    photo: {
      filename: 'elk_ridge_survival_axe.jpg',
      io: open(Rails.root.join('db', 'seeds', 'photos', 'elk_ridge_survival_axe.jpg'))
    }
  },

  {
    name: 'Coffee Percolator Crate',
    description: 'Mornings are hard enough, keep coffee simple. The Coffee Percolator Crate is classic, campfire-brewed coffee sipped from a personalized mug.',
    quantity: 10,
    price: 59.99,
    photo: {
      filename: 'coffee_percolator_crate.jpg',
      io: open(Rails.root.join('db', 'seeds', 'photos', 'coffee_percolator_crate.jpg'))
    }
  },

  {
    name: 'Exotic Meats Crate',
    description: 'Go on a jerky safari with the Exotic Meats Crate, including faraway flavors like venison, wild boar, elk, pheasant, ostrich and duck jerky.',
    quantity: 10,
    price: 59.99,
    photo: {
      filename: 'exotic_meats_crate.jpg',
      io: open(Rails.root.join('db', 'seeds', 'photos', 'exotic_meats_crate.jpg'))
    }
  },

  {
    name: 'Pit Master Crate',
    description: 'The Pit Master Crate is the masterpiece of BBQ crates, and a perfect gift for the griller who appreciates "slow and low" meats and all the gear that accompanies it.',
    quantity: 0,
    price: 59.99,
    photo: {
      filename: 'pit_master_crate.jpg',
      io: open(Rails.root.join('db', 'seeds', 'photos', 'pit_master_crate.jpg'))
    }
  },
])
