export class UserNewDto {
    username: string;
    fullName: string;
    email:    string;
    password: string;
    verifyPassword: string;

    constructor() {
      this.username = '';
      this.fullName = '';
      this.email = '';
      this.password = '';
      this.verifyPassword = '';
    }

  }
