import { Category } from "../interfaces/mangaResponse";

export class CreateMangaDto {
  name: string;
  description: string;
  relase_date: any;
  categories: Category[];

  constructor() {
      this.name = '';
      this.description = '';
      this.relase_date = null;
      this.categories = [];
  }
}
