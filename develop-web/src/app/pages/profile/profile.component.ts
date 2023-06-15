import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { User } from 'src/app/models/interfaces/userResponse';

import { AuthService } from 'src/app/services/auth.service';
import { UserService } from 'src/app/services/user.service';

const AVATAR = 'avatar';
@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.css'],
})
export class ProfileComponent implements OnInit {
  editar = true;
  formulario = new FormGroup({
    username: new FormControl(''),
    fullName: new FormControl(''),
    email: new FormControl(''),
  });
  formularioPassword = new FormGroup({
    password: new FormControl(''),
    passwordNew: new FormControl(''),
    passwordNewVerify: new FormControl(''),
  });
  file!: File;
  image = localStorage.getItem('image');
  user!: User;
  constructor(
    private authService: AuthService,
    private userService: UserService
  ) {}

  ngOnInit(): void {
    this.authService.userLogged().subscribe({
      next: (m) => {
        this.formulario.patchValue(m);
        this.image = m.image;
        this.user = m;
      },
      error: (err) => console.log(err.error.mensaje),
    });
  }

  onFileChanged(event: any) {
    this.file = event.target.files[0];
  }

  guardar() {
    if (this.formularioPassword.get('password')?.value != '') {
      this.userService.editarUsuario(
        this.formulario.value,
        this.file,
        this.user.id,
        this.formularioPassword.value
      );
    } else {
      this.userService.editarUsuario(
        this.formulario.value,
        this.file,
        this.user.id
      );
    }
  }

  editarPerfil() {
    if (this.editar) {
      this.editar = false;
    } else {
      this.editar = true;
    }
  }
}
