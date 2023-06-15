import { Component, OnInit, ViewChild } from '@angular/core';

import { FormControl, FormGroup } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { MatPaginator, PageEvent } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { Router } from '@angular/router';
import { MangaService } from 'src/app/services/manga.service';
import { Manga } from 'src/app/models/interfaces/mangaResponse';
import { MangaFormComponent } from '../manga-form/manga-form.component';

@Component({
  selector: 'app-manga-table',
  templateUrl: './manga-table.component.html',
  styleUrls: ['./manga-table.component.css'],
})
export class MangaTableComponent implements OnInit {
  displayedColumns: string[] = [
    'name',
    'description',
    'releaseDate',
    'posterPath',
    'author',
    'acciones',
  ];
  dataSource: any;
  totalElements: number = 0;
  page!: String;
  size!: String;
  formulario = new FormGroup({
    name: new FormControl(''),
  });

  @ViewChild(MatPaginator, { static: true }) paginator!: MatPaginator;
  constructor(
    private dialog: MatDialog,
    private mangaService: MangaService,

    private router: Router
  ) {}
  ngOnInit(): void {
    this.mangaService.findAllMangas('0', '5').subscribe({
      next: (mangaResult) => {
        this.totalElements = mangaResult.totalElements;
        this.dataSource = new MatTableDataSource<Manga>(mangaResult.content);
        this.dataSource.paginator = this.paginator;
      },
      error: (err) => console.log(err.error.mensaje),
    });
  }

  editarManga(manga:Manga){
    this.dialog.open(MangaFormComponent, {
     data: {manga: manga},
   });
 }

 crearManga() {
  this.dialog.open(MangaFormComponent, {
  });
 }

 nextPage(event: PageEvent) {

  this.page = event.pageIndex.toString();
  this.size = event.pageSize.toString();
  this.mangaService.findAllMangas(this.page, this.size).subscribe({
    next: (mangaResult => {
      this.totalElements = mangaResult.totalElements;
      this.dataSource = new MatTableDataSource<Manga>(mangaResult.content);
    }),
    error: err => console.log(err.error.mensaje),
    });
  }

  buscar(){
    const name = this.formulario.value.name;
    this.mangaService.buscar(name!).subscribe({
      next: (mangaResult => {
        this.totalElements = mangaResult.totalElements;
        this.dataSource = new MatTableDataSource<Manga>(mangaResult.content);
      }),
      error: err => console.log(err.error.mensaje),
    });
  }

}
