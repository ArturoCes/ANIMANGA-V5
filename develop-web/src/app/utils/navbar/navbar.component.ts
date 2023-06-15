import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-navbar',
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.css'],
})
export class NavbarComponent implements OnInit {
  open: boolean = true;
  select!: string;
  currentUrl!: string;
  pantalla1: any = {
    name: 'Usuarios',
    icon: 'users.svg',
    url: '/users',
  };
  pantalla2: any = {
    name: 'Mangas',
    icon: 'mangas.svg',
    url: '/manga',
  };

  pantalla3: any = {
    name: 'Categorías',
    icon: 'category.svg',
    url: '/categories',
  };
  pantalla4: any = {
    name: 'Compras',
    icon: 'category.svg',
    url: '/purchase',
  };

  listAux: any[] = [];
  constructor(private router: Router) {
    this.select = this.currentUrl;
    this.listAux.push(this.pantalla1);
    this.listAux.push(this.pantalla2);
    this.listAux.push(this.pantalla3);
    this.listAux.push(this.pantalla4);
  }

  ngOnInit(): void {
    this.select = localStorage.getItem('seleccionado') ?? '';
    if (window.localStorage) {
      window.addEventListener(
        'storage',
        (event) => {
          if (event.storageArea === localStorage) {
            if (window.localStorage.getItem('seleccionado') == 'perfil') {
              alert('Sidebar si existe en localStorage!!');
              //Elimina Sidebar
              localStorage.removeItem('seleccionado');
            }
          }
        },
        false
      );
    }
  }

  seleccionar(element: any) {
    this.select = element.name;
    this.router.navigateByUrl(element.url);
    localStorage.setItem('seleccionado', this.select);
  }
}
