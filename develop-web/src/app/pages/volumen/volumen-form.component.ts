import { Component, Inject, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import {
  MatDialog,
  MatDialogRef,
  MAT_DIALOG_DATA,
} from '@angular/material/dialog';

import Swal from 'sweetalert2';
import { DeleteFormComponent } from '../delete-form/delete-form.component';
import { Volumen } from 'src/app/models/interfaces/mangaResponse';
import { VolumenService } from 'src/app/services/volumen.service';
import { CreateVolumenDto } from 'src/app/models/dto/createVolumenDto';

export interface VolumenDialogData {
  idManga: string;
  volumen:Volumen;
}

@Component({
  selector: 'app-volumen',
  templateUrl: './volumen-form.component.html',
  styleUrls: ['./volumen-form.component.css'],
})
export class VolumenFormComponent implements OnInit {
  formulario = new FormGroup({
    nombre: new FormControl(''),
    precio : new FormControl(),
    cantidad:new FormControl(),
    isbn:new FormControl(''),
  });
  file!: File;
  createVolumenDto = new CreateVolumenDto();
  constructor(
    public dialogRef: MatDialogRef<VolumenFormComponent>,
    @Inject(MAT_DIALOG_DATA) public data: VolumenDialogData,
    private volumenService: VolumenService,
    private dialog: MatDialog
  ) {}

  ngOnInit(): void {
    this.formulario.patchValue(this.data.volumen);
  }

  onFileChanged(event: any) {
    this.file = event.target.files[0];
  }

  cancelar() {
    this.dialogRef.close();
  }

  editarCrear() {
    if (this.data.volumen != null) {
      this.createVolumenDto.idManga=this.data.idManga;
      this.createVolumenDto.precio=this.formulario.get("precio")?.value ?? "";
      this.createVolumenDto.nombre=this.formulario.get("nombre")?.value ?? "";
      this.createVolumenDto.cantidad=this.formulario.get("cantidad")?.value ?? "";
      this.volumenService.editarVolumen(
        this.createVolumenDto,
        this.data.volumen.id,
        this.file
      );
    } else {

      this.volumenService
        .create(this.formulario.value, this.data.idManga, this.file)
        .subscribe({
          next: (res) => {
            history.go(0);
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
      data: { idChapter: this.data.volumen.id },
    });
  }
}
