export interface MangaResponse {
  content:          Manga[];
  pageable:         Pageable;
  totalElements:    number;
  totalPages:       number;
  last:             boolean;
  size:             number;
  number:           number;
  sort:             Sort;
  numberOfElements: number;
  first:            boolean;
  empty:            boolean;
}

export interface Manga {
  id:          string;
  name:        string;
  description: string;
  releaseDate: Date;
  posterPath:  string;
  author:      string;
  categories:  Category[];
  volumenes:  Volumen[];

}



export interface Category {
  id:          string;
  name:        string;
  description: string;
}


export interface Pageable {
  sort:       Sort;
  offset:     number;
  pageNumber: number;
  pageSize:   number;
  unpaged:    boolean;
  paged:      boolean;
}

export interface Sort {
  empty:    boolean;
  unsorted: boolean;
  sorted:   boolean;
}

export interface Volumen {
  id:               string;
  mangaId:          string;
  nombre:           string;
  precio:           string;
  isbn:             string;
  cantidad:         string;
  posterPath:       string;
  nameManga:        string;
  descriptionManga: string;
  releaseDateManga: Date;
  posterPathManga:  string;
  authorManga:      string;
  categoriesManga:  Category[];
}
