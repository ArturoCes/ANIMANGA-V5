import { Component, OnInit, ViewChild } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { MatPaginator, PageEvent } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { UserService } from 'src/app/services/user.service';

import { UserFormComponent } from '../user-form/user-form.component';
import { SearchUserDto } from 'src/app/models/dto/searchDto';
import { User } from 'src/app/models/interfaces/userResponse';
import { DialogComponent } from 'src/app/dialogs/dialog/dialog.component';

@Component({
  selector: 'app-user-table',
  templateUrl: './users-table.component.html',
  styleUrls: ['./users-table.component.css']
})
export class UserTableComponent implements OnInit {
  displayedColumns: string[] = ['username', 'fullName','email', 'avatar', 'role', 'acciones'];
  totalElements: number = 0;
  page!:String;
  size!:String;
  dataSource:any;
  formulario = new FormGroup({
    texto: new FormControl(''),
    role: new FormControl('')
  });
  searchUserDto = new SearchUserDto
  @ViewChild(MatPaginator, { static: true }) paginator!: MatPaginator;
  constructor(private dialog:MatDialog, private userService: UserService) { }
  ngOnInit(): void {
    this.userService.findAllUsers("0","5").subscribe({
      next: (userResult => {
        this.totalElements = userResult.totalElements;
        this.dataSource = new MatTableDataSource<User>(userResult.content);
        this.dataSource.paginator = this.paginator;
      }),
      error: err => console.log(err.error.mensaje)
    });
  }

  editarUsuario(user:User){
    this.dialog.open(UserFormComponent, {
     data: {user: user},
   });
 }

 nextPage(event: PageEvent) {
  this.page = event.pageIndex.toString();
  this.size = event.pageSize.toString();
  this.userService.findAllUsers(this.page, this.size).subscribe({
    next: (userResult => {
      this.totalElements = userResult.totalElements;
      this.dataSource = new MatTableDataSource<User>(userResult.content);
    }),
    error: err => console.log(err.error.mensaje)
  });
}

  admin(user:User){
  this.dialog.open(DialogComponent, {
   data: {user: user},
    });
  }

  buscar(){
    this.searchUserDto.username=this.formulario.get('texto')?.value??'';
    this.searchUserDto.fullName=this.formulario.get('texto')?.value??'';
    this.searchUserDto.email=this.formulario.get('texto')?.value??'';
    if(this.formulario.get('role')?.value!=""){
      this.searchUserDto.role=this.formulario.get('role')?.value;
    }

    this.userService.buscar(this.searchUserDto).subscribe({
        next: (userResult => {
          this.totalElements = userResult.totalElements;
          this.dataSource = new MatTableDataSource<User>(userResult.content);
        }),
        error: err => console.log(err.error.mensaje)
      });
  }

}
