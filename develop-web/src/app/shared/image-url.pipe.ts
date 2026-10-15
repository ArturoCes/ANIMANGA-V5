import { Pipe, PipeTransform } from '@angular/core';
import { imageUrl } from '../core/api';

@Pipe({ name: 'imageUrl', standalone: true })
export class ImageUrlPipe implements PipeTransform {
  transform(path: string | null | undefined): string {
    return imageUrl(path);
  }
}
