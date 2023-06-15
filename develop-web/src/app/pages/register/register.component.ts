import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { LoginDto } from 'src/app/models/dto/loginDto';
import { UserNewDto } from 'src/app/models/dto/userNewDto';
import { AuthService } from 'src/app/services/auth.service';

const TOKEN = 'token'
const AVATAR = 'avatar'
const ROL = 'rol'

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {
  formulario = new FormGroup({
    username: new FormControl('', [Validators.required]),
    fullName: new FormControl(''),
    email: new FormControl('', [Validators.required]),
    password: new FormControl('', [Validators.required]),
    passwordVerify: new FormControl('', [Validators.required]),
  });
  userNewDto = new UserNewDto();

  constructor(private authService: AuthService, private router:Router) { }

  ngOnInit(): void {
  }


  registrarse(){
    this.userNewDto.username=this.formulario.get("username")?.value ?? "";
    this.userNewDto.fullName=this.formulario.get("fullName")?.value ?? "";
    this.userNewDto.email=this.formulario.get("email")?.value ?? "";
    this.userNewDto.password=this.formulario.get("password")?.value ?? "";
    this.userNewDto.verifyPassword=this.formulario.get("passwordVerify")?.value ?? "";
    this.authService.register(this.userNewDto).subscribe(loginResult => {
        localStorage.setItem(TOKEN, loginResult.token);
        localStorage.setItem(ROL, loginResult.role);
        localStorage.setItem(AVATAR, loginResult.image);
        this.router.navigate(['/manga']);
  });
  }

}
