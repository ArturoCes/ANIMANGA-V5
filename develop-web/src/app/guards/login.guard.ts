import { Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot, UrlTree } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class LoginGuard implements CanActivate {
  constructor(private authService:AuthService, private router:Router, private snackBar: MatSnackBar){
  }

  canActivate(){
    let token = this.authService.getToken();
    let userRol = this.authService.getRol();
    if(userRol!="ADMIN"||token==""||token==null){
      this.authService.logout();
      this.snackBar.open('Necesitas ser administrador para iniciar sesión', 'Aceptar');
      this.router.navigate(['login']);
      return false;
    }
    return true;
  }
}
