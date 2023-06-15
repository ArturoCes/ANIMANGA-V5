import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { User } from 'src/app/models/interfaces/userResponse';
import { UserService } from 'src/app/services/user.service';
import Swal from 'sweetalert2';

export interface AdminDialogData {
  user:User,
}

@Component({
  selector: 'app-dialog',
  templateUrl: './dialog.component.html',
  styleUrls: ['./dialog.component.css']
})
export class DialogComponent implements OnInit{


  constructor(public dialogRef: MatDialogRef<DialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: AdminDialogData,
    private userService: UserService) { }

  ngOnInit(): void {
  }

  give(){
    if(this.data!= null){
      if(this.data.user.role=="USER") {
        this.userService.giveAdmin(this.data.user.id).subscribe({
          next: (res) => {
            Swal.fire({
              icon: 'success',
              title: 'Correcto',
              text: "Acción realizada correctamente",
            }).then(()=>{
              history.go(0);
            });
          },
          error: (err) =>
            Swal.fire({
              icon: 'error',
              title: 'Oops...',
              text: err.error.mensaje,
            }),

        });
        this.dialogRef.close();
      }else{
        this.userService.removeAdmin(this.data.user.id).subscribe({
          next: (res) => {
            Swal.fire({
              icon: 'success',
              title: 'Correcto',
              text: "Acción realizada correctamente",
            }).then(()=>{
              history.go(0);
            });
          },
          error: (err) =>
            Swal.fire({
              icon: 'error',
              title: 'Oops...',
              text: err.error.mensaje,
            }),

        });
        this.dialogRef.close();
      }
    }
  }

  cancelar() {
    this.dialogRef.close();
  }

}
