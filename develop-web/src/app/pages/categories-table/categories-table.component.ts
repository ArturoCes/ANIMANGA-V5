
import { Component, OnInit, ViewChild } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { MatPaginator, PageEvent } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { SearchCategoryDto } from 'src/app/models/dto/searchCategoryDto';
import { Category } from 'src/app/models/interfaces/mangaResponse';
import { CategoryService } from 'src/app/services/category.service';
import { CategoriesFormComponent } from '../categories-form/categories-form.component';

@Component({
  selector: 'app-categories-table',
  templateUrl: './categories-table.component.html',
  styleUrls: ['./categories-table.component.css']
})
export class CategoriesTableComponent implements OnInit {
  displayedColumns: string[] = ['name', 'description', 'acciones'];
  totalElements: number = 0;
  page!:String;
  size!:String;
  dataSource:any;
  formulario = new FormGroup({
    texto: new FormControl(''),
  });
  searchCategoryDto = new SearchCategoryDto;
  @ViewChild(MatPaginator, { static: true }) paginator!: MatPaginator;
  constructor(private dialog:MatDialog, private categoryService: CategoryService) { }
  ngOnInit(): void {
    this.categoryService.findAllCategories("0","5").subscribe({
      next: (categoryResult => {
        this.totalElements = categoryResult.totalElements;
        this.dataSource = new MatTableDataSource<Category>(categoryResult.content);
        this.dataSource.paginator = this.paginator;
      }),
      error: err => console.log(err.error.mensaje),
    });
  }

  editarCategoria(category:Category){
    this.dialog.open(CategoriesFormComponent, {
     data: {category: category},
   });
  }

  crearCategoria() {
    this.dialog.open(CategoriesFormComponent, {
    });
  }

 nextPage(event: PageEvent) {
  this.page = event.pageIndex.toString();
  this.size = event.pageSize.toString();
  this.categoryService.findAllCategories(this.page, this.size).subscribe({
    next: (categoryResult => {
      this.totalElements = categoryResult.totalElements;
      this.dataSource = new MatTableDataSource<Category>(categoryResult.content);
    }),
    error: err => console.log(err.error.mensaje),
  });
 }

 buscar(){
  this.searchCategoryDto.name = this.formulario.get('texto')?.value??'';
  this.searchCategoryDto.description =this.formulario.get('texto')?.value??'';
  this.categoryService.buscar(this.searchCategoryDto).subscribe({
    next: (categoryResult => {
      this.totalElements = categoryResult.totalElements;
      this.dataSource = new MatTableDataSource<Category>(categoryResult.content);
    }),
    error: err => console.log(err.error.mensaje),
  });
  }

}
