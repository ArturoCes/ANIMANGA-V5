import { Component, Inject, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { DeleteFormComponent } from '../delete-form/delete-form.component';
import Swal from 'sweetalert2';
import { Category, Manga } from 'src/app/models/interfaces/mangaResponse';
import { CreateMangaDto } from 'src/app/models/dto/createMangaDto';
import { MangaService } from 'src/app/services/manga.service';
import { CategoryService } from 'src/app/services/category.service';

const TOKEN = 'token';

export interface MangaDialogData {
  manga: Manga;
}
@Component({
  selector: 'app-manga-form',
  templateUrl: './manga-form.component.html',
  styleUrls: ['./manga-form.component.css']
})
export class MangaFormComponent implements OnInit {
  formulario = new FormGroup({
    id: new FormControl(''),
    name: new FormControl(''),
    description: new FormControl(''),
    category: new FormControl(),
  });
  categoriesList: Category[] = [];
  categoriesSelect:Category[] = [];
  file!: File;
  createMangaDto = new CreateMangaDto;
  constructor(public dialogRef: MatDialogRef<MangaFormComponent>,
    @Inject(MAT_DIALOG_DATA) public data: MangaDialogData,
    private mangaService: MangaService, private categoryService: CategoryService,
    private dialog:MatDialog) {
     }

  ngOnInit(): void {
    this.categoryService.findAllCategories("0","100").subscribe({
      next: (res => {
        this.categoriesList = res.content;
        if(this.data!=null) {
          this.categoriesSelect = this.categoriesList.filter(g =>
            this.data.manga.categories.some(g2 =>
              g2.id == g.id
            )
          )
        }
        this.formulario.get('category')?.setValue(this.categoriesSelect);
        this.formulario.patchValue(this.data.manga);
      }),
      error: err => console.log(err.error.mensaje),
    });
  }

  onFileChanged(event: any) {
    this.file = event.target.files[0];
  }

  cancelar() {
    this.dialogRef.close();
  }

  editarCrear(){
    for (let index = 0; index < this.categoriesSelect.length; index++) {
      console.log(this.categoriesSelect[index].name);

    }
    this.createMangaDto.name= this.formulario.get('name')?.value ??'';
    this.createMangaDto.description= this.formulario.get('description')?.value??'';
    this.createMangaDto.categories= this.categoriesSelect;
    if(this.data!=null){
      this.mangaService.editarManga(this.createMangaDto, this.data.manga.id, this.file);
    } else {
      this.mangaService.create(this.createMangaDto, this.file).subscribe({
        next: (res => {
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

  eliminar() {
    this.dialog.open(DeleteFormComponent, {
      data: {idManga: this.data.manga.id},
    });
  }


}
