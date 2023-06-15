import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment.prod';
import { Category, CategoryResponse } from '../models/interfaces/categoryResponse';
import { SearchCategoryDto } from '../models/dto/searchCategoryDto';
import { CategoryDto } from '../models/dto/createCategoryDto';



const TOKEN = 'token';

@Injectable({
  providedIn: 'root'
})
export class CategoryService {

  constructor(private http:HttpClient) { }

  categoryBaseUrl =  `${environment.API_BASE_URL}category`;

  findAllCategories(page:String, size:String):Observable<CategoryResponse>{
    let encabezados= new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    return this.http.get<CategoryResponse>(`${this.categoryBaseUrl}/all?size=${size}&page=${page}`, { headers: encabezados });
  }

  create(category: CategoryDto){
    let encabezados= new HttpHeaders({
    /*   'Content-Type': 'application/json', */
      /* 'Accept':'application/json', */
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    let categoria = new FormData();
    categoria.append('category', new Blob([JSON.stringify(category)], {
      type: 'application/json'
    }));
    return this.http.post<Category>(`${this.categoryBaseUrl}/new`, categoria, { headers: encabezados });
  }

  findById(idCategory: number){

    return this.http.get<Category>(`${this.categoryBaseUrl}/${idCategory}`);
  }

  update(category: CategoryDto, idCategory: String){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    let categoria = new FormData();
    categoria.append('category', new Blob([JSON.stringify(category)], {
      type: 'application/json'
    }));
    return this.http.put<Category>(`${this.categoryBaseUrl}/${idCategory}`, categoria, { headers: encabezados });
  }

  delete(idCategory: String){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    return this.http.delete(`${this.categoryBaseUrl}/${idCategory}`, { headers: encabezados });
  }

  buscar(searchCategoryDto: SearchCategoryDto){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    let formData = new FormData();
    formData.append('search', new Blob([JSON.stringify(searchCategoryDto)], {
      type: 'application/json'
    }));
    return this.http.post<CategoryResponse>(`${this.categoryBaseUrl}/find/`, formData, { headers: encabezados });
  }
}
