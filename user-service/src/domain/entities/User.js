class User {
  constructor({ id = null, email, password, name, points = 0, lastLogin = null }) {
    this.id = id;
    this.email = email;
    this.password = password;
    this.name = name;
    this.points = points;
    this.lastLogin = lastLogin;
  }

  toJSON() {
    return {
      id: this.id,
      email: this.email,
      name: this.name,
      points: this.points,
      lastLogin: this.lastLogin
    };
  }
}

module.exports = User; 