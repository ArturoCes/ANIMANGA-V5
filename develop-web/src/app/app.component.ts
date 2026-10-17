import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ThemeService } from './core/theme.service';
import { ServerWakeComponent } from './shared/server-wake.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, ServerWakeComponent],
  template: '<router-outlet /><app-server-wake />',
})
export class AppComponent {
  // Aplica el tema guardado (o el del sistema) desde la primera pantalla
  private readonly theme = inject(ThemeService);
}
