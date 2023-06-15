import { Component, Inject, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import {
  MatDialog,
  MatDialogRef,
  MAT_DIALOG_DATA,
} from '@angular/material/dialog';

import Swal from 'sweetalert2';
import { DeleteFormComponent } from '../delete-form/delete-form.component';
import { Category } from 'src/app/models/interfaces/categoryResponse';
import { CategoryDto } from 'src/app/models/dto/createCategoryDto';
import { CategoryService } from 'src/app/services/category.service';

export interface CategoriesDialogData {
  category: Category;
}

@Component({
  selector: 'app-categories-form',
  templateUrl: './categories-form.component.html',
  styleUrls: ['./categories-form.component.css'],
})
export class CategoriesFormComponent implements OnInit {
  formulario = new FormGroup({
    name: new FormControl(''),
    description: new FormControl(''),
  });
  categoryDto = new CategoryDto();

  constructor(
    public dialogRef: MatDialogRef<CategoriesFormComponent>,
    @Inject(MAT_DIALOG_DATA) public data: CategoriesDialogData,
    private categoryService: CategoryService,
    private dialog: MatDialog
  ) {}
  ngOnInit(): void {
    if(this.data!=null){
      this.formulario.patchValue(this.data.category);
    }

  }
  cancelar() {
    this.dialogRef.close();
  }

  editarCrear () {
    this.categoryDto.name = this.formulario.get('name')?.value ?? '';
    this.categoryDto.description =
      this.formulario.get('description')?.value ?? '';
    if (this.data != null) {
      this.categoryService
        .update(this.categoryDto, this.data.category.id)
        .subscribe({
          next: (res) => {
            Swal.fire('Cambios Guardados', '', 'success').then(() => {
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
    } else {
      this.categoryService.create(this.categoryDto).subscribe({
        next: (res) => {
          Swal.fire('Cambios Guardados', '', 'success').then(() => {
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
    }
  }

  eliminar() {
    this.dialog.open(DeleteFormComponent, {
      data: { idCategory: this.data.category.id },
    });
  }
}
