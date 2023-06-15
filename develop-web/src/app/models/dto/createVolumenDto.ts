export class CreateVolumenDto {
  idManga: string;
  nombre: string;
  precio: number;
  cantidad: number;
  isbn: string;


  constructor() {
    this.idManga ='';
    this.nombre = '';
    this.precio = 0;
    this.cantidad = 0;
    this.isbn ='';
  }
}
