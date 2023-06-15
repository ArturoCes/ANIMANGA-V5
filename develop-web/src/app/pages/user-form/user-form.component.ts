import { Component, Inject, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';

import { UserService } from 'src/app/services/user.service';

import { DeleteFormComponent } from '../delete-form/delete-form.component';
import { User } from 'src/app/models/interfaces/userResponse';

export interface UserDialogData {
  user: User;
}

@Component({
  selector: 'app-user-form',
  templateUrl: './user-form.component.html',
  styleUrls: ['./user-form.component.css']
})
export class UserFormComponent implements OnInit {
  formulario = new FormGroup({
    username: new FormControl(''),
    fullName: new FormControl(''),
    email:new FormControl('')
  });
  file!: File;

  constructor(public dialogRef: MatDialogRef<UserFormComponent>,
    @Inject(MAT_DIALOG_DATA) public data: UserDialogData,
    private userService: UserService, private dialog:MatDialog) {
     }

  ngOnInit(): void {
    this.formulario.patchValue(this.data.user);
    console.log(JSON.stringify(this.formulario.value));
  }

  onFileChanged(event: any) {
    this.file = event.target.files[0];
  }

  cancelar() {
    this.dialogRef.close();
  }

  editarCrear(){
      this.userService.editarUsuario(this.formulario.value, this.file, this.data.user.id);

    }

  eliminar() {
    this.dialog.open(DeleteFormComponent, {
      data: {idUser: this.data.user.id},
    });
  }


}
