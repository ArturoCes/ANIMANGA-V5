import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { MangaFormComponent } from './pages/manga-form/manga-form.component';
import { DeleteFormComponent } from './pages/delete-form/delete-form.component';
//import { CategoriesFormComponent } from './pages/categories-form/categories-form.component';
import { LoginComponent } from './pages/login/login.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { CategoriesComponent } from './pages/categories/categories.component';
import { RegisterComponent } from './pages/register/register.component';
import { ProfileComponent } from './pages/profile/profile.component';
import { UserFormComponent } from './pages/user-form/user-form.component';
import { MangaDetailComponent } from './pages/manga-detail/manga-detail.component';
import { CategoriesTableComponent } from './pages/categories-table/categories-table.component';
import { UserTableComponent } from './pages/users-table/users-table.component';
import { MangaTableComponent } from './pages/manga-table/manga-table.component';
import { DialogComponent } from './dialogs/dialog/dialog.component';
import { ToolbarComponent } from './utils/toolbar/toolbar.component';
import { MaterialImportsModule } from './modules/material-imports.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { NavbarComponent } from './utils/navbar/navbar.component';
import { CategoriesFormComponent } from './pages/categories-form/categories-form.component';
import { VolumenFormComponent } from './pages/volumen/volumen-form.component';
import { PurchaseTableComponent } from './pages/purchase-table/purchase-table.component';

@NgModule({
  declarations: [
    AppComponent,
    MangaFormComponent,
    DeleteFormComponent,
    CategoriesFormComponent,
    LoginComponent,
    CategoriesComponent,
    RegisterComponent,
    ProfileComponent,
    UserFormComponent,
    MangaDetailComponent,
    CategoriesTableComponent,
    UserTableComponent,
    MangaTableComponent,
    DialogComponent,
    ToolbarComponent,
    NavbarComponent,
    ToolbarComponent,
    VolumenFormComponent,
    PurchaseTableComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    MaterialImportsModule,
    ReactiveFormsModule,
    FormsModule,
  ],
  providers: [],
  bootstrap: [AppComponent],
})
export class AppModule {}
