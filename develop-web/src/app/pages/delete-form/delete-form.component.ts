import { Component, Inject, OnInit } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { CategoryService } from 'src/app/services/category.service';

import { MangaService } from 'src/app/services/manga.service';
import { UserService } from 'src/app/services/user.service';
import Swal from 'sweetalert2';

export interface DialogData {

  idUser:String,
  idManga:String,
  idChapter:String,
  idCategory:String
}

@Component({
  selector: 'app-delete-form',
  templateUrl: './delete-form.component.html',
  styleUrls: ['./delete-form.component.css']
})
export class DeleteFormComponent implements OnInit {

  constructor(public dialogRef: MatDialogRef<DeleteFormComponent>,
    @Inject(MAT_DIALOG_DATA) public data: DialogData,
    private userService:UserService, private mangaService: MangaService,
   /* private chapterService: ChapterService,*/ private categoryService: CategoryService) { }

  ngOnInit(): void {
  }

  eliminar(){
   /* if(this.data.idComment != null){
      this.commentService.delete(this.data.idComment).subscribe({
        next: ( res => {
          history.go(0);
        }),
        error: err => Swal.fire({
          icon: 'error',
          title: 'Oops...',
          text: err.error.mensaje,
        })
      });
    }*/
    if(this.data.idUser != null){
      this.mangaService.delete(this.data.idUser).subscribe({
        next: ( res => {
          history.go(0);
        }),
        error: err => Swal.fire({
          icon: 'error',
          title: 'Oops...',
          text: err.error.mensaje,
        })
      });
    }
    if(this.data.idManga != null){
      this.mangaService.delete(this.data.idManga).subscribe({
        next: ( res => {
          history.go(0);
        }),
        error: err => Swal.fire({
          icon: 'error',
          title: 'Oops...',
          text: err.error.mensaje,
        })
      });
    }
   /* if(this.data.idChapter != null){
      this.chapterService.delete(this.data.idChapter).subscribe({
        next: ( res => {
          history.go(0);
        }),
        error: err => Swal.fire({
          icon: 'error',
          title: 'Oops...',
          text: err.error.mensaje,
        })
      });
    }*/
    if(this.data.idCategory != null){
      this.categoryService.delete(this.data.idCategory).subscribe({
        next: ( res => {
          history.go(0);
        }),
        error: err => Swal.fire({
          icon: 'error',
          title: 'Oops...',
          text: err.error.mensaje,
        })
      });
    }
  }

  cancelar() {
    this.dialogRef.close();
  }

}
