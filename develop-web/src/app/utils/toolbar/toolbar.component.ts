import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from 'src/app/services/auth.service';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-toolbar',
  templateUrl: './toolbar.component.html',
  styleUrls: ['./toolbar.component.css']
})
export class ToolbarComponent implements OnInit {

  constructor(private authService: AuthService, private router: Router) { }

  ngOnInit(): void {
  }

  logout() {
    Swal.fire({
      title: 'Cerrar Sesión',
      text: "¿Seguro que quieres salir?",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#d84e4e',
      cancelButtonColor: '#8CC63E',
      cancelButtonText:'No',
      confirmButtonText: 'Si'
    }).then((result) => {
      if (result.isConfirmed) {
        this.authService.logout();
      } else if (result.isDenied) {
        result.dismiss;
      }
    })
  }

  seleccionar(){
    localStorage.setItem('seleccionado', 'profile');
    this.router.navigateByUrl("profile").then(r=>{
      history.go(0);
    });

  }

}
