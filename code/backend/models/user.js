'use strict';

const { Model } = require('sequelize');
const bcrypt = require('bcryptjs');  // Add bcrypt for hashing passwords

module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    static associate(models) {
      // Define associations if any
    }

    // Instance method to check if the password matches
    // compare a provided password with the hashed password stored in the database.
    checkPassword(password) {
      return bcrypt.compareSync(password, this.password);
    }

    // Static method to hash password before saving to DB
    static hashPassword(password) {
      return bcrypt.hashSync(password, 10);
    }
  }

  User.init({
    userId: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
    password: { type: DataTypes.STRING, allowNull: false },
  }, {
    sequelize,
    modelName: 'User',
  });

  return User;
};
