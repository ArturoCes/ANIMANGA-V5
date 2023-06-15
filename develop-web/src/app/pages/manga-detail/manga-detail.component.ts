import { DatePipe } from '@angular/common';
import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatPaginator } from '@angular/material/paginator';
import { ActivatedRoute } from '@angular/router';

import { MangaService } from 'src/app/services/manga.service';
import { Manga, Volumen } from 'src/app/models/interfaces/mangaResponse';
import { VolumenService } from 'src/app/services/volumen.service';
import { MatTableDataSource } from '@angular/material/table';
import { VolumenFormComponent } from '../volumen/volumen-form.component';

@Component({
  selector: 'app-manga-detail',
  templateUrl: './manga-detail.component.html',
  styleUrls: ['./manga-detail.component.css']
})
export class MangaDetailComponent implements OnInit {


  displayedColumns: string[] = ['nombre', 'precio', 'isbn', 'cantidad', 'posterPath', 'acciones'];
  idManga!: string;
  manga!:Manga;
  image = "http://localhost:8080/download/";
  dataSource:any;
  volumenList!:any;

  @ViewChild(MatPaginator, { static: true }) paginator!: MatPaginator;
  constructor(private mangaService: MangaService, private route: ActivatedRoute,
    private dialog:MatDialog, private volumenService: VolumenService) { }

  ngOnInit(): void {
    this.route.params.subscribe(params => {
      this.idManga = params['idManga'];
      this.mangaService.findById(this.idManga).subscribe({
        next: (result => {
          this.manga = result;
          this.image+= result.posterPath;
         this.volumenList = result.volumenes;
          this.dataSource = new MatTableDataSource<Volumen>(this.volumenList);
          this.dataSource.paginator = this.paginator;
        }),
        error: err => console.log(err.error.mensaje),
      });
    });
  }

 crearVolumen() {
    this.dialog.open(VolumenFormComponent, {
      data: {idManga:this.manga.id},
    });
   }

   editarVolumen(volumen:Volumen){
    this.dialog.open(VolumenFormComponent, {
     data: {
      idManga:this.manga.id,
      volumen: volumen
    },
   });
 }
}
