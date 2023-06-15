import { Component, OnInit } from "@angular/core";
import { FormControl, FormGroup, Validators } from "@angular/forms";
import { MatSnackBar } from "@angular/material/snack-bar";
import { Router } from "@angular/router";
import { LoginDto } from "src/app/models/dto/loginDto";
import { AuthService } from "src/app/services/auth.service";


const TOKEN = 'token'
const AVATAR = 'avatar'
const ROL = 'rol'

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  formulario = new FormGroup({
    username: new FormControl('', [Validators.required]),
    password: new FormControl('', [Validators.required]),
  });
  loginDto = new LoginDto();

  constructor(private authService: AuthService, private router:Router, private snackBar: MatSnackBar) { }

  ngOnInit(): void {
  }

  doLogin() {
    this.loginDto.username = this.formulario.get('username')?.value ?? '';
    this.loginDto.password = this.formulario.get('password')?.value ?? '';

    this.authService.login(this.loginDto).subscribe(loginResult => {
        localStorage.setItem(TOKEN, loginResult.token);
        localStorage.setItem(AVATAR, loginResult.image);
        localStorage.setItem(ROL, loginResult.role);
        localStorage.setItem('seleccionado', 'Mangas');
        this.router.navigate(['/manga']);
    });
  }
}
