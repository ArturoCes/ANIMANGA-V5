export class SearchUserDto {
  username: string;
  fullName: string;
  email:    string;
  role: any;

  constructor() {
    this.username = '';
    this.fullName = '';
    this.email = '';
    this.role = null;
  }
}
