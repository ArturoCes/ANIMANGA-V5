import { Injectable } from '@angular/core';
import { CanActivate, Router} from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {

  constructor(private authService:AuthService, private router:Router){

  }

  canActivate(){
    let token = this.authService.getToken();
    let userRol = this.authService.getRol();
    if(userRol!="ADMIN"||token==""||token==null){
      this.authService.logout();
      this.router.navigate(['login']);
      return false;
    }
    return true;
  }

}
