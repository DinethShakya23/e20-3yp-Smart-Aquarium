'use strict';

module.exports = (sequelize, DataTypes) => {
    const User = sequelize.define('Profile', {
        email: {
            type: DataTypes.STRING,
            primaryKey: true,
            allowNull: false
        },
        name: DataTypes.STRING,
        phone: DataTypes.STRING,
        location: DataTypes.STRING,
        image_url: DataTypes.STRING,
    }, {
        tableName: 'profiles',
        timestamps: false,
    });

    return User;
};
