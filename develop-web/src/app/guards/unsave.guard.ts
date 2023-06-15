import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanDeactivate, Router, RouterStateSnapshot, UrlTree } from '@angular/router';
import { Observable, of } from 'rxjs';
import Swal from 'sweetalert2';
import { ProfileComponent } from '../pages/profile/profile.component';


@Injectable({
  providedIn: 'root'
})
export class UnsaveGuard implements CanDeactivate<ProfileComponent> {
  constructor( private router:Router) {
  }

  canDeactivate(myComponent: ProfileComponent,
    ) {
   if(myComponent.formulario.dirty || myComponent.file!= null || myComponent.formularioPassword.dirty){
    Swal.fire({
      title: 'Tiene cambios sin guardar',
      showDenyButton: true,
      showCancelButton: true,
      confirmButtonText: 'Guardar',
      denyButtonText: `No guardar`,
      cancelButtonText: 'Cancelar',
      confirmButtonColor: '#71973F'
    }).then((result) => {
      if (result.isConfirmed) {
        myComponent.guardar();
      } else if (result.isDenied) {
        Swal.fire('Cambios descartados', '', 'info').then(r=>{
          history.go(0);
        })
      }
    });
    return false;
    }else {
      return true;
    }

  }


}

